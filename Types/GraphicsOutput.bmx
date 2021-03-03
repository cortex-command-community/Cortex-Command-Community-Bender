Import "SettingsManager.bmx"
Import "LimbManager.bmx"

'//// GRAPHICS OUTPUT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type GraphicsOutput
	Field m_CanvasVisibleArea:SVec2I = Null

	Field m_SourceImage:TImage = Null
	Field m_SourceImageSize:SVec2I = Null

	Field m_BackgroundColor:Int[] = [g_DefaultBackgroundRed, g_DefaultBackgroundGreen, g_DefaultBackgroundBlue]
	Field m_Magenta:Int[] = [255, 0, 255]

	Field m_MaxInputZoom:Int = 5 'Assume 1366px is the lowest resolution because it's not 1999. 1366px - 260px (left column) = 1106 / 192 (source image width) = 5 (floored).
	Field m_InputZoom:Int = g_DefaultInputZoom
	Field m_OutputZoom:Int = g_DefaultOutputZoom
	Field m_TileSize:Int = 24 * m_InputZoom
	Field m_FrameCount:Int = g_DefaultFrameCount

	Field m_DrawOutputFrameBounds:Int = False
	Field m_FrameBoundingBoxPosX:Int[c_LimbCount, c_MaxFrameCount]
	Field m_FrameBoundingBoxPosY:Int[c_LimbCount, c_MaxFrameCount]
	Field m_FrameBoundingBoxSize:SVec2I = Null

	Field m_OutputPanOffsetX:Int = 0
	Field m_OutputPanOffsetY:Int = 0

	Field m_BentLimbPartDrawOrder:Int[c_LimbCount]

	Field m_LimbManager:LimbManager = Null

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New(maxWorkspaceWidth:Int, canvasVisibleArea:SVec2I)
		SetClsColor(m_BackgroundColor[0], m_BackgroundColor[1], m_BackgroundColor[2])
		SetMaskColor(m_Magenta[0], m_Magenta[1], m_Magenta[2])

		m_CanvasVisibleArea = canvasVisibleArea
		m_MaxInputZoom = Int(FloorF(maxWorkspaceWidth / 192))

		m_LimbManager = New LimbManager()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method LoadFile:Int(fileToLoad:String)
		Local loadedImage:TImage = LoadImage(fileToLoad, 0)

		If loadedImage <> Null Then
			If loadedImage.Width = 192 And loadedImage.Height = 24 Then
				m_SourceImage = loadedImage
				m_SourceImageSize = New SVec2I(m_SourceImage.Width, m_SourceImage.Height)
				DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom) 'Draw the source image to the backbuffer so limb tiles can be created.
				m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
				Return True
			Else
				Notify("Attempting to load image with incorrect dimensions!~n~nMake sure the dimensions are exactly 192x24px!~nUse ~qInputTemplate~q for reference.", True)
			EndIf
		EndIf
		Return False
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetCanvasVisibleArea(visibleArea:SVec2I)
		m_CanvasVisibleArea = visibleArea
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetBackgroundColor:Int[](rgbValue:Int[])
		m_BackgroundColor[0] = Utility.Clamp(rgbValue[0], 0, 255)
		m_BackgroundColor[1] = Utility.Clamp(rgbValue[1], 0, 255)
		m_BackgroundColor[2] = Utility.Clamp(rgbValue[2], 0, 255)
		ChangeBackgroundColor(m_BackgroundColor)
		Return m_BackgroundColor
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method ChangeBackgroundColor(rgbValue:Int[])
		SetClsColor(rgbValue[0], rgbValue[1], rgbValue[2])
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method RevertBackgroundColorAfterSave(revertOrNot:Int)
		If revertOrNot Then
			ChangeBackgroundColor(m_BackgroundColor)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetInputZoom:Int(newZoom:Int)
		Local clampedNewZoom:Int = Utility.Clamp(newZoom, 1, m_MaxInputZoom)
		If m_InputZoom <> clampedNewZoom Then
			m_InputZoom = clampedNewZoom
			m_TileSize = 24 * m_InputZoom

			If m_SourceImage <> Null Then
				m_SourceImageSize = New SVec2I(m_SourceImage.Width, m_SourceImage.Height)
				DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom) 'Draw the source image to the backbuffer so limb tiles can be created.
				m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
			EndIf
		EndIf
		Return m_InputZoom
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetOutputZoom:Int(newZoom:Int)
		m_OutputZoom = Utility.Clamp(newZoom, 1, 5)
		m_OutputPanOffsetX = 0
		m_OutputPanOffsetY = 0
		Return m_OutputZoom
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetFrameCount:Int()
		Return m_FrameCount
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetFrameCount:Int(newCount:Int)
		m_FrameCount = Utility.Clamp(newCount, 1, c_MaxFrameCount)
		Return m_FrameCount
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetDrawOutputFrameBounds:Int(drawOrNot:Int)
		m_DrawOutputFrameBounds = drawOrNot
		Return m_DrawOutputFrameBounds
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetBentLimbPartDrawOrder(drawOrder:Int[])
		m_BentLimbPartDrawOrder = drawOrder
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetOutputPanOffset(mouseMovement:SVec2I)
		m_OutputPanOffsetX :- mouseMovement[0]
		m_OutputPanOffsetX = Utility.Clamp(m_OutputPanOffsetX, 0, 100 + (m_FrameCount * ((m_TileSize / m_InputZoom) + 8)) * m_OutputZoom)

		m_OutputPanOffsetY :- mouseMovement[1]
		m_OutputPanOffsetY = Utility.Clamp(m_OutputPanOffsetY, 0, 150 * m_OutputZoom)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GrabOutputForSaving:TPixmap()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
			Return Null
		Else
			ChangeBackgroundColor(m_Magenta)
			Draw(True)
			Flip(1) 'Have to flip again for background color to actually change (for the grabbed pixmap, not the canvas), not sure why but whatever.
			Return GrabPixmap(0, 12 + (m_SourceImageSize[1] * m_InputZoom), 100 + (m_FrameCount * ((m_TileSize / m_InputZoom) + 8)), 200)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GrabOutputFramesForSaving:TPixmap[,]()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
			Return Null
		Else
			ChangeBackgroundColor(m_Magenta)
			Draw(True)
			Flip(1) 'Have to flip again for background color to actually change (for the grabbed pixmaps, not the canvas), not sure why but whatever.

			Local framesToSave:TPixmap[c_LimbCount, m_FrameCount]
			For Local limb:Int = 0 Until c_LimbCount
				Local rotationAngle:Int = -90
				If limb >= 2 Then
					rotationAngle = 90
				EndIf
				For Local frame:Int = 0 Until m_FrameCount
					framesToSave[limb, frame] = Utility.RotatePixmap(GrabPixmap(m_FrameBoundingBoxPosX[limb, frame] + 1, m_FrameBoundingBoxPosY[limb, frame] + 1, m_FrameBoundingBoxSize[0] - 1, m_FrameBoundingBoxSize[1] - 1), rotationAngle)
					'HFlip the legs so they're facing the right direction.
					If limb >= 2 Then
						framesToSave[limb, frame] = XFlipPixmap(framesToSave[limb, frame])
					EndIf
				Next
			Next
			Return CropGrabbedOutputFrames(framesToSave)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method CropGrabbedOutputFrames:TPixmap[,](framesToCrop:TPixmap[,])
		Local croppedFrames:TPixmap[c_LimbCount, m_FrameCount]
		Local stackedLimbFrames:TPixmap = CreatePixmap(framesToCrop[0, 0].Width, framesToCrop[0, 0].Height, PF_RGBA8888)

		'This is seemingly inefficient but surprisingly fast garbage but I don't have anything better.
		For Local limb:Int = 0 Until c_LimbCount
			Cls()

			For Local frame:Int = 0 Until m_FrameCount
				'Mask the magenta and stack all the frames on top of each other, then grab the stacked frames to a new pixmap.
				DrawImage(LoadImage(MaskPixmap(framesToCrop[limb, frame], m_Magenta[0], m_Magenta[1], m_Magenta[2]), DYNAMICIMAGE | MASKEDIMAGE), 0, 0)
				stackedLimbFrames = GrabPixmap(0, 0, stackedLimbFrames.Width, stackedLimbFrames.Height)
			Next

			Local realDimensions:Int[] = Utility.GetPixmapNonMaskedPixelBounds(stackedLimbFrames, -65281) 'God knows why this is the value for magenta here but it is what it is.

			For Local frame:Int = 0 Until m_FrameCount
				'Copy the area that is the real dimensions to a new pixmap.
				Local croppedFrame:TPixmap = CreatePixmap(realDimensions[1] - realDimensions[0] + 1, realDimensions[3] - realDimensions[2] + 1, PF_RGBA8888)
				Local xCount:Int = 0
				Local yCount:Int = 0
				For Local pixelY:Int = realDimensions[2] To realDimensions[3]
					xCount = 0
					For Local pixelX:Int = realDimensions[0] To realDimensions[1]
						WritePixel(croppedFrame, xCount, yCount, ReadPixel(framesToCrop[limb, frame], pixelX, pixelY))
						xCount :+ 1
					Next
					yCount :+ 1
				Next
				croppedFrames[limb, frame] = croppedFrame
			Next
		Next
		Return croppedFrames
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method Update()
		If m_SourceImage <> Null Then
			'Getting these on mouse click is screwy so get them here.
			Local mouseMovement:SVec2I = New SVec2I(MouseXSpeed(), MouseYSpeed())

			If MouseDown(1) Then
				Local mousePos:SVec2I = New SVec2I(MouseX(), MouseY())
				If Utility.PointIsWithinBox(mousePos, New SVec2I(0, 0), m_SourceImageSize * m_InputZoom) Then
					m_LimbManager.SetJointMarker(mousePos)
				Else
					SetOutputPanOffset(mouseMovement)
				EndIf
			EndIf
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawNoSourceImageScreen()
		Cls()
		SetScale(2, 2)
		Local textToDraw:String = "NO IMAGE LOADED!"
		Local drawColor:Int[] = [255, 230, 80]
		Utility.DrawTextWithShadow(textToDraw, New SVec2I((m_CanvasVisibleArea[0] / 2) - TextWidth(textToDraw), (m_CanvasVisibleArea[1] / 2) - TextHeight(textToDraw)), drawColor)
		SetScale(1, 1)
		Flip(1)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawZoomedOutput()
		Local outputUnzoomedSize:SVec2I = New SVec2I(100 + (m_FrameCount * ((m_TileSize / m_InputZoom) + 8)), 230)
		Local outputCopyForZoom:TImage = CreateImage(outputUnzoomedSize[0], outputUnzoomedSize[1], 1, DYNAMICIMAGE)
		GrabImage(outputCopyForZoom, 0, m_SourceImageSize[1] * m_InputZoom)

		'Hide the unzoomed output.
		SetColor(m_BackgroundColor[0], m_BackgroundColor[1], m_BackgroundColor[2])
		DrawRect(0, m_SourceImageSize[1] * m_InputZoom, outputUnzoomedSize[0] + 20, outputUnzoomedSize[1] + 20)
		Utility.ResetDrawColor()

		SetImageHandle(outputCopyForZoom, m_OutputPanOffsetX, m_OutputPanOffsetY)
		DrawImageRect(outputCopyForZoom, 0, m_SourceImageSize[1] * m_InputZoom, outputCopyForZoom.Width * m_OutputZoom, outputCopyForZoom.Height * m_OutputZoom)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method Draw(disableOutputZoom:Int = False)
		If m_SourceImage = Null Then
			DrawNoSourceImageScreen()
		Else
			Cls()

			Local vertOffsetFromSource:Int = (m_SourceImageSize[1] * m_InputZoom) + 34
			m_LimbManager.DrawBentLimbs(New SVec2I(100, vertOffsetFromSource), m_FrameCount, m_BentLimbPartDrawOrder)

			Local drawColor:Int[] = [255, 230, 80]
			Utility.DrawTextWithShadow("Arm FG", New SVec2I(10, vertOffsetFromSource), drawColor)
			Utility.DrawTextWithShadow("Arm BG", New SVec2I(10, vertOffsetFromSource + 50 - 2), drawColor)
			Utility.DrawTextWithShadow("Leg FG", New SVec2I(10, vertOffsetFromSource + (50 * 2) - 4), drawColor)
			Utility.DrawTextWithShadow("Leg BG", New SVec2I(10, vertOffsetFromSource + (50 * 3) - 6), drawColor)

			If m_DrawOutputFrameBounds Then
				drawColor = [0, 0, 80]
				m_FrameBoundingBoxSize = New SVec2I(32, 48)
				For Local row:Int = 0 Until c_LimbCount
					For Local frame:Int = 0 Until m_FrameCount
						m_FrameBoundingBoxPosX[row, frame] = 100 - 20 + (frame * ((m_TileSize / m_InputZoom) + 8))
						m_FrameBoundingBoxPosY[row, frame] = vertOffsetFromSource - 12 + (row * 48)
						Utility.DrawRectOutline(New SVec2I(m_FrameBoundingBoxPosX[row, frame], m_FrameBoundingBoxPosY[row, frame]), m_FrameBoundingBoxSize, drawColor)
					Next
				Next
			EndIf

			If Not disableOutputZoom And m_OutputZoom > 1 Then
				DrawZoomedOutput()
			EndIf

			SetColor(m_Magenta[0], m_Magenta[1], m_Magenta[2])
			DrawRect(0, 0, GraphicsWidth(), (m_SourceImageSize[1] * m_InputZoom) + 1) 'Extend the source image magenta strip all the way to the right and adjust height to input zoom.
			Utility.ResetDrawColor()
			DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom)

			m_LimbManager.DrawTileOutlines()
			m_LimbManager.DrawJointMarkers()

			Flip(1)
		EndIf
	EndMethod
EndType