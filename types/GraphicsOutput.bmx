Import "SettingsManager.bmx"
Import "LimbManager.bmx"

'//// GRAPHICS OUTPUT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type GraphicsOutput
	'Draw Bools
	Field m_RedoLimbTiles:Int = False
	'Constants
	Const c_MaxZoom:Int = 11
	Const c_MaxFrameCount:Int = 20
	Field c_Magenta:Int[] = [255, 0, 255]
	'Graphic Assets
	Field m_SourceImage:TImage
	Field m_SourceImageSize:Svec2I
	'Output Settings
	Field m_InputZoom:Int = g_DefaultInputZoom
	Field m_TileSize:Int = 24 * m_InputZoom
	Field m_FrameCount:Int = g_DefaultFrameCount
	Field m_BackgroundColor:Int[] = [g_DefaultBackgroundRed, g_DefaultBackgroundGreen, g_DefaultBackgroundBlue]

	Field m_DrawOutputFrameBounds:Int

	Field m_LimbManager:LimbManager = New LimbManager()

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New()
		SetClsColor(m_BackgroundColor[0], m_BackgroundColor[1], m_BackgroundColor[2])
		SetMaskColor(c_Magenta[0], c_Magenta[1], c_Magenta[2])
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method LoadFile(fileToLoad:String)
		m_SourceImage = LoadImage(fileToLoad, 0)

		If m_SourceImage <> Null Then
			m_SourceImageSize = New SVec2I(m_SourceImage.Width, m_SourceImage.Height)
			DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom) 'Draw the source image to the backbuffer so limb tiles can be created
			m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetBackgroundColor:Int[](rgbValue:Int[])
		m_BackgroundColor = rgbValue
		ChangeBackgroundColor(m_BackgroundColor)
		Return m_BackgroundColor
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetInputZoom:Int(newZoom:Int)
		Local clampedNewZoom:Int = Utility.Clamp(newZoom, 1, c_MaxZoom)
		If m_InputZoom <> clampedNewZoom Then
			m_InputZoom = clampedNewZoom
			m_TileSize = 24 * m_InputZoom

			m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
		EndIf
		Return m_InputZoom
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

	Method SetDrawOutputFrameBounds(drawOrNot:Int)
		m_DrawOutputFrameBounds = drawOrNot
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

	Method Draw()
		If m_SourceImage = Null Then
			DrawNoSourceImageScreen()
		Else
			Cls()

			SetColor(c_Magenta[0], c_Magenta[1], c_Magenta[2])
			DrawRect(0, 0, GraphicsWidth(), (m_SourceImageSize[1] * m_InputZoom) + 1) 'Extend the source image magenta strip all the way to the right and adjust height to input zoom
			Utility.ResetDrawColor()
			DrawImageRect(m_SourceImage, 0, 0, m_SourceImageSize[0] * m_InputZoom, m_SourceImageSize[1] * m_InputZoom)

			m_LimbManager.DrawTileOutlines()
			m_LimbManager.DrawJointMarkers()

			Local vertOffsetFromSource:Int = (m_SourceImageSize[1] * m_InputZoom) + 35
			m_LimbManager.DrawBentLimbs(New SVec2I(100, vertOffsetFromSource), m_FrameCount)

			Local drawColor:Int[] = [255, 230, 80]
			Utility.DrawTextWithShadow("Arm FG", New SVec2I(10, vertOffsetFromSource), drawColor)
			Utility.DrawTextWithShadow("Arm BG", New SVec2I(10, vertOffsetFromSource + 48), drawColor)
			Utility.DrawTextWithShadow("Leg FG", New SVec2I(10, vertOffsetFromSource + (48 * 2)), drawColor)
			Utility.DrawTextWithShadow("Leg BG", New SVec2I(10, vertOffsetFromSource + (48 * 3)), drawColor)

			If m_DrawOutputFrameBounds Then
				For Local row:Int = 0 To 3
					For Local frame:Int = 0 To m_FrameCount - 1
						Local tile:TImage = LoadImage("Incbin::Assets/Tile")

						'Doing this with an image because cba doing the math with DrawLine. Offsets are -1px because tile image is 26x26 for outline and tile is 24x24.
						DrawImage(tile, 62 + (frame * (m_TileSize / m_InputZoom + 8)), 138 + (row * 48))
					Next
				Next
			EndIf
			Flip(1)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GrabOutputForSaving:TPixmap()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
		Else
			ChangeBackgroundColor(c_Magenta)
			Draw()
			Flip(1) 'Have to flip again for background color to actually change, not sure why but whatever
			Return GrabPixmap(55, 120, 34 * m_FrameCount, 210)
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GrabOutputFramesForSaving:TPixmap[,]()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
		Else
			ChangeBackgroundColor(c_Magenta)
			Draw()
			Flip(1) 'Have to flip again for background color to actually change, not sure why but whatever

			Local framesToSave:TPixmap[c_LimbCount, m_FrameCount]
			For Local row:Int = 0 To 3
				For Local frame:Int = 0 Until m_FrameCount
					'Grab pixmap inside tile bounds for saving
					framesToSave[row, frame] = GrabPixmap(63 + (frame * (m_TileSize / m_InputZoom + 8)), 139 + (row * 48), m_TileSize / m_InputZoom, m_TileSize / m_InputZoom)
					'HFlip the legs so they're facing right
					If row >= 2 Then
						framesToSave[row, frame] = XFlipPixmap(framesToSave[row, frame])
					EndIf
				Next
			Next
			Return framesToSave
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
EndType