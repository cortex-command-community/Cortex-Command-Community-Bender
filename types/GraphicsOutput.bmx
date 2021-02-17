'//// GRAPHICS OUTPUT ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type GraphicsOutput
	'Draw Bools
	Global m_RedoLimbTiles:Int = False
	'Constants
	Const c_MinZoom:Int = 1
	Const c_MaxZoom:Int = 4
	Const c_MinFrameCount:Int = 1
	Const c_MaxFrameCount:Int = 20
	Const c_MinBGColorValue:Int = 0
	Const c_MaxBGColorValue:Int = 255
	Const c_BoneCount:Int = 8
	Const c_LimbCount:Int = c_BoneCount / 2
	'Graphic Assets
	Global m_SourceImage:TImage
	Global m_BoneImage:TImage[c_BoneCount]
	'Output Settings
	Global m_InputZoom:Int = 1
	Global m_Frames:Int = 7
	Global m_BackgroundRed:Int = 50
	Global m_BackgroundGreen:Int = 170
	Global m_BackgroundBlue:Int = 255
	'Limb Parts
	Global m_JointX:Float[c_BoneCount]
	Global m_JointY:Float[c_BoneCount]
	Global m_BoneLength:Float[c_BoneCount]
	'Precalc for drawing
	Global m_TileSize:Int = 24
	Global m_BoneAngle:Int[c_BoneCount, 20]
	Global m_BoneX:Int[c_BoneCount, 20]
	Global m_BoneY:Int[c_BoneCount, 20]
	'Variables
	Global m_AngleA:Float
	Global m_AngleB:Float
	Global m_AngleC:Float

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Rotation Calc
	Function LawOfCosines(ab:Float, bc:Float, ca:Float)
		m_AngleA = ACos((ca ^ 2 + ab ^ 2 - bc ^ 2) / (2 * ca * ab))
		m_AngleB = ACos(( bc ^ 2 + ab ^ 2 - ca ^ 2) / (2 * bc * ab))
		m_AngleC = (180 -(m_AngleA + m_AngleB))
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Create limb part tiles from source image
	Function CreateLimbTiles()
		Local b:Int, i:Int
		For b = 0 To c_BoneCount-1 'Because I (arne) can't set handles on inidividial anim image frames, I must use my own frame sys
			m_BoneImage[b] = CreateImage(m_TileSize, m_TileSize, 1, DYNAMICIMAGE | MASKEDIMAGE)
			GrabImage(m_BoneImage[b], b * m_TileSize, 0)
			SetColor(120, 0, 120)
			DrawLine(i * m_TileSize, 0, i * m_TileSize, m_TileSize - 1, True)
		Next
		'Set up default bone sizes
		For i = 0 To c_BoneCount - 1
			m_JointX[i] = m_TileSize / 2
			m_JointY[i] = m_TileSize / 3.3 '3.6
			m_BoneLength[i] = (m_TileSize / 2 - m_JointY[i]) * 2
			SetImageHandle(m_BoneImage[i], m_JointX[i] / m_InputZoom, m_JointY[i] / m_InputZoom)
		Next
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Set Joint Marker
	Function SetJointMarker()
		Local xm:Int = MouseX()
		Local ym:Int = MouseY()
		If ym < (m_TileSize / 2 - 2) And ym > 0 And xm > 0 And xm < m_TileSize * c_BoneCount Then
			Local b:Int = xm / m_TileSize
			m_JointX[b] = m_TileSize / 2 		'X is always at center, so kinda pointless to even bother - at the moment
			m_JointY[b] = ym				'Determines length
			m_BoneLength[b] = (m_TileSize / 2 - ym) * 2
			SetImageHandle(m_BoneImage[b], m_JointX[b] / m_InputZoom, m_JointY[b] / m_InputZoom) 'Rotation handle.
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Bending
	Function LimbBend()
		Local maxExtend:Float = 0.99		'Possibly make definable in settings (slider)
		Local minExtend:Float = 0.30		'Possibly make definable in settings (slider)
		Local stepSize:Float = (maxExtend - minExtend) / (m_Frames - 1) ' -1 to make inclusive of last value (full range)
		Local b:Int, f:Int, l:Float, x:Float, y:Float, airLength:Float, upperLength:Float, lowerLength:Float
		For l = 0 To c_LimbCount - 1
			For f = 0 To m_Frames - 1
				b = l * 2
				x = (f * 32) + 80 						'Drawing position X
				y = ((l * 32) * 1.5 ) + 144				'Drawing position Y
				upperLength = m_BoneLength[b] / m_InputZoom
				lowerLength = m_BoneLength[b + 1] / m_InputZoom
				airLength = (stepSize * f + minExtend) * (upperLength + lowerLength)	'Sum of the two bones * step scaler for frame (hip-ankle)
				LawOfCosines(airLength, upperLength, lowerLength)
				m_BoneAngle[b, f] = m_AngleB
				m_BoneX[b, f] = x
				m_BoneY[b, f] = y
				x :- Sin(m_BoneAngle[b, f]) * upperLength		'Position of knee
				y :+ Cos(m_BoneAngle[b, f]) * upperLength		'Could just use another m_BoneAngle of the triangle though, but I (arne) didn't
				m_BoneAngle[b + 1, f] = m_AngleC + m_AngleB + 180	'It looks correct on screen so i'm (arne) just gonna leave it at that!
				m_BoneX[b + 1, f] = x
				m_BoneY[b + 1, f] = y
			Next
		Next
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Create Joint Markers
	Function CreateJointMarker(x:Float, y:Float)
		SetRotation(0)
		SetColor(0, 0, 80)
		x :+ 1 y :+ 1 'Add a shade for clarity on bright colours
		DrawLine(x - 1 - m_InputZoom, y, x + 1 + m_InputZoom, y)
		DrawLine(x, y - 1 - m_InputZoom, x, y + 1 + m_InputZoom)
		x :- 1 y :- 1 'Cross
		SetColor(255, 230, 80)
		DrawLine(x - 1 - m_InputZoom, y, x + 1 + m_InputZoom, y)
		DrawLine(x, y - 1 - m_InputZoom, x, y + 1 + m_InputZoom)
		SetColor(255, 255, 255)
	End Function

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
		If FileIO.m_PrepForSave
			SetClsColor(255, 0, 255)
		Else
			SetClsColor(m_BackgroundRed, m_BackgroundGreen, m_BackgroundBlue)
		EndIf
		'Draw source image
		If m_SourceImage <> Null Then
			DrawImageRect(m_SourceImage, 0, 0, ImageWidth(m_SourceImage) * m_InputZoom, ImageHeight(m_SourceImage) * m_InputZoom)
			If m_RedoLimbTiles Then
				CreateLimbTiles()
				m_RedoLimbTiles = False
			EndIf
			For i = 0 To c_BoneCount - 1
				'Draw limb tile dividers
				SetColor(120, 0, 120)
				DrawLine(i * m_TileSize, 0, i * m_TileSize, m_TileSize - 1, True)
				'Draw the joint markers
				CreateJointMarker(m_JointX[i] + i * m_TileSize, m_JointY[i])
				CreateJointMarker(m_JointX[i] + i * m_TileSize, m_JointY[i] + m_BoneLength[i])
			Next
			'Draw bent limbs
			LimbBend()
			SetColor(255, 255, 255)
			For f = 0 To m_Frames - 1
				'These might be in a specific draw-order for joint overlapping purposes
				b = 0 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 1 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 2 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 3 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 4 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 5 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 6 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
				b = 7 SetRotation(m_BoneAngle[b, f]) DrawImageRect(m_BoneImage[b], m_BoneX[b, f], m_BoneY[b, f], ImageWidth(m_BoneImage[b]) / m_InputZoom, ImageHeight(m_BoneImage[b]) / m_InputZoom)
			Next
			SetRotation(0)
			GrabOutputForSaving()
		Else
			SetColor(255, 230, 80)
			DrawText("NO IMAGE LOADED!", (GraphicsWidth() / 2) - (TextWidth("NO IMAGE LOADED!") / 2), GraphicsHeight() / 2)
			Flip(1)
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Create output window and draw assets
	Function OutputBoot()
		'Window background color
		SetClsColor(m_BackgroundRed, m_BackgroundGreen, m_BackgroundBlue)
		SetMaskColor(255, 0, 255)
		SetColor(255, 230, 80)
		DrawText("NO IMAGE LOADED!", (GraphicsWidth() / 2) - (TextWidth("NO IMAGE LOADED!") / 2), GraphicsHeight() / 2)
		OutputUpdate()
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Have to do all this so first loaded source image is zoomed in and has correct limb tiles and markers.
	Function LoadingFirstTime()
		DrawImageRect(m_SourceImage, 0, 0, ImageWidth(m_SourceImage) * m_InputZoom, ImageHeight(m_SourceImage) * m_InputZoom)
		CreateLimbTiles()
		m_InputZoom = 4
		SetGadgetText(g_UserInterface.m_SettingsZoomTextbox, GraphicsOutput.m_InputZoom)
		m_TileSize = 24 * GraphicsOutput.m_InputZoom
		m_RedoLimbTiles = True
		LimbBend()
		OutputUpdate()
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Output copy for saving
	Function GrabOutputForSaving()
		If FileIO.m_SaveAsFrames = True Then
			Local row:Int, frame:Int
			Local tile:TImage = LoadImage("Incbin::Assets/Tile")
			For row = 0 To 3
				For frame = 0 To m_Frames - 1
					'Draw a tile outline around all frames to see we are within bounds.
					DrawImage(tile, 62 + (frame * (m_TileSize / m_InputZoom + 8)), 138 + (row * 48)) 'Doing this with an image because cba doing the math with DrawLine. Offsets are -1px because tile image is 26x26 for outline and tile is 24x24.
					'Draw names of rows
					SetColor(255, 230, 80)
					DrawText("Arm FG", 8, 145)
					DrawText("Arm BG", 8, 145 + 48)
					DrawText("Leg FG", 8, 145 + (48 * 2))
					DrawText("Leg BG", 8, 145 + (48 * 3))
					'Grab pixmap inside tile bounds for saving
					FileIO.m_TempOutputFrameCopy[row,frame] = GrabPixmap(63 + (frame * (m_TileSize / m_InputZoom + 8)), 139 + (row * 48), m_TileSize / m_InputZoom, m_TileSize / m_InputZoom)
					'HFlip the legs so they're facing right
					If row >= 2 Then
						FileIO.m_TempOutputFrameCopy[row, frame] = XFlipPixmap(FileIO.m_TempOutputFrameCopy[row, frame])
					EndIf
				Next
			Next
		Else
			If FileIO.m_SaveAsIndexed = True Then
				'If saving indexed grab a smaller pixmap to speed up indexing
				FileIO.m_TempOutputImageCopy = GrabPixmap(55, 120, 34 * m_Frames, 210)
			Else
				FileIO.m_TempOutputImageCopy = GrabPixmap(0, 96, 768, 384)
			EndIf
		EndIf
		Flip(1)
		If FileIO.m_PrepForSave
			FileIO.PrepForSave()
		EndIf
	EndFunction
EndType