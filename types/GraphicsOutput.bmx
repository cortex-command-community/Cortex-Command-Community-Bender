'//// GRAPHICS OUTPUT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type GraphicsOutput
	'Draw Bools
	Global m_RedoLimbTiles:Int = False
	'Constants
	Const c_MinZoom:Int = 4
	Const c_MaxZoom:Int = 11
	Const c_MinFrameCount:Int = 3
	Const c_MaxFrameCount:Int = 20
	'Graphic Assets
	Global m_SourceImage:TImage
	'Output Settings
	Global m_InputZoom:Int = g_DefaultInputZoom
	Global m_TileSize:Int = 24 * m_InputZoom
	Global m_Frames:Int = g_DefaultFrameCount
	Global m_BackgroundRed:Int = g_DefaultBackgroundRed
	Global m_BackgroundGreen:Int = g_DefaultBackgroundGreen
	Global m_BackgroundBlue:Int = g_DefaultBackgroundBlue

	Global m_PrepForSave:Int

	Global m_LimbManager:LimbManager

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function InitializeGraphicsOutput()
		DrawNoSourceImageScreen()

		m_LimbManager = New LimbManager(m_InputZoom, m_TileSize, m_FrameCount)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function LoadFile(fileToLoad:String)
		m_SourceImage = LoadImage(fileToLoad, 0)

		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function SetBackgroundColor(rgbValue:Int[])
		m_BackgroundRed = rgbValue[0]
		m_BackgroundGreen = rgbValue[1]
		m_BackgroundBlue = rgbValue[2]
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Update Output Window
	Function OutputUpdate()
		Local i:Int, f:Int, b:Int
		Cls
		'Left mouse to adjust joint markers, click or hold and drag
		If MouseDown(1) Then
			SetJointMarker()
		EndIf
		'Drawing Output
		'Set background color
		If m_PrepForSave
			SetClsColor(255, 0, 255)
		Else
			SetClsColor(m_BackgroundRed, m_BackgroundGreen, m_BackgroundBlue)
		EndIf
		'Draw source image
		If m_SourceImage <> Null Then
			DrawImageRect(m_SourceImage, 0, 0, ImageWidth(m_SourceImage) * m_InputZoom, ImageHeight(m_SourceImage) * m_InputZoom)
			'Draw names of rows
			SetColor(255, 230, 80)
			DrawText("Arm FG", 8, 145)
			DrawText("Arm BG", 8, 145 + 48)
			DrawText("Leg FG", 8, 145 + (48 * 2))
			DrawText("Leg BG", 8, 145 + (48 * 3))
			SetColor(255, 255, 255)

			If m_PrepForSave
				GrabOutputForSaving()
			Else
				Flip(1)
			EndIf
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Output copy for saving
	Function GrabOutputForSaving()
		If m_SourceImage = Null Then
			Notify("Nothing to save!", False)
		Else
			m_PrepForSave = True

			If Not g_FileIO.m_SaveAsFrames Then
				g_FileIO.SaveFile(GrabPixmap(55, 120, 34 * m_Frames, 210))
			Else
				Local framesToSave:TPixmap[c_LimbCount, m_Frames]
				Local tile:TImage = LoadImage("Incbin::Assets/Tile")
				For Local row:Int = 0 To 3
					For Local frame:Int = 0 To m_Frames - 1
						'Draw a tile outline around all frames to see we are within bounds.
						DrawImage(tile, 62 + (frame * (m_TileSize / m_InputZoom + 8)), 138 + (row * 48)) 'Doing this with an image because cba doing the math with DrawLine. Offsets are -1px because tile image is 26x26 for outline and tile is 24x24.
						'Grab pixmap inside tile bounds for saving
						framesToSave[row, frame] = GrabPixmap(63 + (frame * (m_TileSize / m_InputZoom + 8)), 139 + (row * 48), m_TileSize / m_InputZoom, m_TileSize / m_InputZoom)
						'HFlip the legs so they're facing right
						If row >= 2 Then
							framesToSave[row, frame] = XFlipPixmap(framesToSave[row, frame])
						EndIf
					Next
				Next
				g_FileIO.SaveFileAsFrames(framesToSave, m_Frames)
			EndIf
			Flip(1)
		EndIf
		m_PrepForSave = False
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawNoSourceImageScreen()
		SetClsColor(m_BackgroundRed, m_BackgroundGreen, m_BackgroundBlue)
		Cls()
		SetMaskColor(255, 0, 255)
		SetColor(255, 230, 80)
		SetScale(2, 2)
		Local textToDraw:String = "NO IMAGE LOADED!"
		DrawText(textToDraw, (GraphicsWidth() / 2) - TextWidth(textToDraw), (GraphicsHeight() / 2) - TextHeight(textToDraw))
		SetColor(255, 255, 255)
		SetScale(1, 1)
		Flip(1)
	EndFunction
EndType