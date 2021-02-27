Import "SettingsManager.bmx"
Import "LimbManager.bmx"

'//// GRAPHICS OUTPUT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type GraphicsOutput
	Const c_MaxFrameCount:Int = 20

	Field m_MaxZoom:Int = 5 'Assume 1366px is the lowest resolution because it's not 1999. 1366px - 260px (left column) = 1106 / 192 (source image width) = 5 (floored)
	Field m_Magenta:Int[] = [255, 0, 255]

	Field m_SourceImage:TImage
	Field m_SourceImageSize:SVec2I

	Field m_InputZoom:Int = g_DefaultInputZoom
	Field m_TileSize:Int = 24 * m_InputZoom
	Field m_FrameCount:Int = g_DefaultFrameCount
	Field m_BackgroundColor:Int[] = [g_DefaultBackgroundRed, g_DefaultBackgroundGreen, g_DefaultBackgroundBlue]

	Field m_DrawOutputFrameBounds:Int
	Field m_FrameBoundingBoxPosX:Int[c_LimbCount, c_MaxFrameCount]
	Field m_FrameBoundingBoxPosY:Int[c_LimbCount, c_MaxFrameCount]
	Field m_FrameBoundingBoxSize:SVec2I

	Field m_LimbManager:LimbManager = New LimbManager()

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New(maxWorkspaceWidth:Int)
		SetClsColor(m_BackgroundColor[0], m_BackgroundColor[1], m_BackgroundColor[2])
		SetMaskColor(m_Magenta[0], m_Magenta[1], m_Magenta[2])

		m_MaxZoom = Int(FloorF(maxWorkspaceWidth / 192))
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method LoadFile:Int(fileToLoad:String)
		m_SourceImage = LoadImage(fileToLoad, 0)

		If m_SourceImage <> Null Then
			m_SourceImageSize = New SVec2I(m_SourceImage.Width, m_SourceImage.Height)
			DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom) 'Draw the source image to the backbuffer so limb tiles can be created
			m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
			Return True
		EndIf
		Return False
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetInputZoom:Int(newZoom:Int)
		Local clampedNewZoom:Int = Utility.Clamp(newZoom, 1, m_MaxZoom)
		If m_InputZoom <> clampedNewZoom Then
			m_InputZoom = clampedNewZoom
			m_TileSize = 24 * m_InputZoom

			m_SourceImageSize = New SVec2I(m_SourceImage.Width, m_SourceImage.Height)
			DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom) 'Draw the source image to the backbuffer so limb tiles can be created
			m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
		EndIf
		Return m_InputZoom
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetBackgroundColor:Int[](rgbValue:Int[])
		m_BackgroundColor = rgbValue
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

	Method GetFrameCount:Int()
		Return m_FrameCount
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetFrameCount:Int(newCount:Int)
		m_FrameCount = Utility.Clamp(newCount, 1, c_MaxFrameCount)
		Return m_FrameCount
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetDrawOutputFrameBounds(drawOrNot:Int)
		m_DrawOutputFrameBounds = drawOrNot
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GrabOutputForSaving:TPixmap()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
		Else
			ChangeBackgroundColor(m_Magenta)
			Draw()
			Flip(1) 'Have to flip again for background color to actually change (for the grabbed pixmap, not the canvas), not sure why but whatever
			Return GrabPixmap(55, 120, 34 * m_FrameCount, 210)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GrabOutputFramesForSaving:TPixmap[,]()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
		Else
			ChangeBackgroundColor(m_Magenta)
			Draw()
			Flip(1) 'Have to flip again for background color to actually change (for the grabbed pixmaps, not the canvas), not sure why but whatever

			Local framesToSave:TPixmap[c_LimbCount, m_FrameCount]
			For Local row:Int = 0 Until c_LimbCount
				Local rotationAngle:Int = -90
				If row >= 2 Then
					rotationAngle = 90
				EndIf
				For Local frame:Int = 0 Until m_FrameCount
					framesToSave[row, frame] = Utility.RotatePixmap(GrabPixmap(m_FrameBoundingBoxPosX[row, frame] + 1, m_FrameBoundingBoxPosY[row, frame] + 1, m_FrameBoundingBoxSize[0] - 1, m_FrameBoundingBoxSize[1] - 1), rotationAngle)
					'HFlip the legs so they're facing the right direction
					If row >= 2 Then
						framesToSave[row, frame] = XFlipPixmap(framesToSave[row, frame])
					EndIf
				Next
			Next
			Return framesToSave
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method Update()
		'Left mouse to adjust joint markers, click or hold and drag
		If MouseDown(1) Then
			Local mousePos:SVec2I = New SVec2I(MouseX(), MouseY())
			If Utility.PointIsWithinBox(mousePos, New SVec2I(0, 0), m_SourceImageSize * m_InputZoom) Then
				m_LimbManager.SetJointMarker(mousePos)
			EndIf
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawNoSourceImageScreen()
		Cls()
		SetScale(2, 2)
		Local textToDraw:String = "NO IMAGE LOADED!"
		Local drawColor:Int[] = [255, 230, 80]
		Utility.DrawTextWithShadow(textToDraw, New SVec2I((GraphicsWidth() / 2) - TextWidth(textToDraw), (GraphicsHeight() / 2) - TextHeight(textToDraw)), drawColor)
		SetScale(1, 1)
		Flip(1)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method Draw()
		If m_SourceImage = Null Then
			DrawNoSourceImageScreen()
		Else
			Cls()

			SetColor(m_Magenta[0], m_Magenta[1], m_Magenta[2])
			DrawRect(0, 0, GraphicsWidth(), (m_SourceImageSize[1] * m_InputZoom) + 1) 'Extend the source image magenta strip all the way to the right and adjust height to input zoom
			Utility.ResetDrawColor()
			DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom)

			m_LimbManager.DrawTileOutlines()
			m_LimbManager.DrawJointMarkers()

			Local vertOffsetFromSource:Int = (m_SourceImageSize[1] * m_InputZoom) + 34
			m_LimbManager.DrawBentLimbs(New SVec2I(100, vertOffsetFromSource), m_FrameCount)

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
						m_FrameBoundingBoxPosX[row, frame] = 100 - 20 + (frame * (m_TileSize / m_InputZoom + 8))
						m_FrameBoundingBoxPosY[row, frame] = vertOffsetFromSource - 12 + (row * 48)
						Utility.DrawRectOutline(New SVec2I(m_FrameBoundingBoxPosX[row, frame], m_FrameBoundingBoxPosY[row, frame]), m_FrameBoundingBoxSize, drawColor)
					Next
				Next
			EndIf
			Flip(1)
		EndIf
	EndMethod
EndType