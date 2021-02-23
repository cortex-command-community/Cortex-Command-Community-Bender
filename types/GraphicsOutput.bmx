Include "LimbManager.bmx"

'//// GRAPHICS OUTPUT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type GraphicsOutput
	'Draw Bools
	Global m_RedoLimbTiles:Int = False
	'Constants
	Const c_MaxZoom:Int = 11
	Const c_MaxFrameCount:Int = 20
	Global c_Magenta:Int[] = [255, 0, 255]
	'Graphic Assets
	Global m_SourceImage:TImage
	'Output Settings
	Global m_InputZoom:Int = g_DefaultInputZoom
	Global m_TileSize:Int = 24 * m_InputZoom
	Global m_FrameCount:Int = g_DefaultFrameCount
	Global m_BackgroundColor:Int[] = [g_DefaultBackgroundRed, g_DefaultBackgroundGreen, g_DefaultBackgroundBlue]

	Global m_PrepForSave:Int

	Global m_LimbManager:LimbManager

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function InitializeGraphicsOutput()
		SetClsColor(m_BackgroundColor[0], m_BackgroundColor[1], m_BackgroundColor[2])
		SetMaskColor(c_Magenta[0], c_Magenta[1], c_Magenta[2])
		DrawNoSourceImageScreen()

		m_LimbManager = New LimbManager(m_InputZoom, m_TileSize, m_FrameCount)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function LoadFile(fileToLoad:String)
		m_SourceImage = LoadImage(fileToLoad, 0)

		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function SetBackgroundColor:Int[](rgbValue:Int[])
		m_BackgroundColor = rgbValue
		ChangeBackgroundColor(m_BackgroundColor)
		Return m_BackgroundColor
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function SetInputZoom:Int(newZoom:Int)
		Local clampedNewZoom:Int = Utility.Clamp(newZoom, 1, c_MaxZoom)
		If m_InputZoom <> clampedNewZoom Then
			m_InputZoom = clampedNewZoom
			m_TileSize = 24 * m_InputZoom

			m_LimbManager.CreateLimbParts(m_InputZoom, m_TileSize)
		EndIf
		Return m_InputZoom
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function SetFrameCount:Int(newCount:Int)
		m_FrameCount = Utility.Clamp(newCount, 1, c_MaxFrameCount)
		Return m_FrameCount
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function ChangeBackgroundColor(rgbValue:Int[])
		SetClsColor(rgbValue[0], rgbValue[1], rgbValue[2])
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function ResetDrawColor()
		SetColor(255, 255, 255)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Update Output Window
	Function OutputUpdate()
		'Left mouse to adjust joint markers, click or hold and drag
		If MouseDown(1) Then
			m_LimbManager.SetJointMarker()
		EndIf

		If m_PrepForSave
			ChangeBackgroundColor(c_Magenta)
		Else
			ChangeBackgroundColor(m_BackgroundColor)
		EndIf

		Cls()
		If m_SourceImage = Null Then
			DrawNoSourceImageScreen()
		Else
			SetColor(255, 0, 255)
			DrawRect(0, 0, GraphicsWidth(), ImageHeight(m_SourceImage) * m_InputZoom) 'Extend the source image magenta strip all the way to the right and adjust height to input zoom
			ResetDrawColor()
			DrawImageRect(m_SourceImage, 0, 0, ImageWidth(m_SourceImage) * m_InputZoom, ImageHeight(m_SourceImage) * m_InputZoom)
			'Draw names of rows
			SetColor(255, 230, 80)
			Local textVertOffset:Int = 50 + (m_TileSize)

			DrawText("Arm FG", 8, textVertOffset)
			DrawText("Arm BG", 8, textVertOffset + 48)
			DrawText("Leg FG", 8, textVertOffset + (48 * 2))
			DrawText("Leg BG", 8, textVertOffset + (48 * 3))
			ResetDrawColor()

			m_LimbManager.DrawJointMarkers()
			ResetDrawColor()

			m_LimbManager.DrawBentLimbs()

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
				g_FileIO.SaveFile(GrabPixmap(55, 120, 34 * m_FrameCount, 210))
			Else
				Local framesToSave:TPixmap[c_LimbCount, m_FrameCount]
				Local tile:TImage = LoadImage("Incbin::Assets/Tile")
				For Local row:Int = 0 To 3
					For Local frame:Int = 0 To m_FrameCount - 1
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
				g_FileIO.SaveFileAsFrames(framesToSave, m_FrameCount)
			EndIf
			Flip(1)
		EndIf
		m_PrepForSave = False
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawNoSourceImageScreen()
		Cls()
		SetColor(255, 230, 80)
		SetScale(2, 2)
		Local textToDraw:String = "NO IMAGE LOADED!"
		DrawText(textToDraw, (GraphicsWidth() / 2) - TextWidth(textToDraw), (GraphicsHeight() / 2) - TextHeight(textToDraw))
		ResetDrawColor()
		SetScale(1, 1)
		Flip(1)
	EndFunction
EndType