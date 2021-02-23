'//// LIMB MANAGER //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Const c_LimbPartCount:Int = 8
Const c_LimbCount:Int = c_LimbPartCount / 2
Const c_MinExtend:Float = 0.30	'Possibly make definable in settings (slider)
Const c_MaxExtend:Float = 0.99	'Possibly make definable in settings (slider)

Type LimbManager
	Field m_InputZoom:Int
	Field m_TileSize:Int

	Field m_LimbPartTilePos:SVec2I[c_LimbPartCount]

	Field m_LimbPartImage:TImage[c_LimbPartCount]
	Field m_LimbPartJointOffsetX:Float[c_LimbPartCount]
	Field m_LimbPartJointOffsetY:Float[c_LimbPartCount]
	Field m_LimbPartLength:Float[c_LimbPartCount]

	'Global m_LimbPartAngle:Int[c_LimbPartCount, c_MaxFrameCount]
	'Global m_LimbPartPosX:Int[c_LimbPartCount, c_MaxFrameCount]
	'Global m_LimbPartPosY:Int[c_LimbPartCount, c_MaxFrameCount]

	Global m_LimbPartAngle:Int[c_LimbPartCount, 20]
	Global m_LimbPartPosX:Int[c_LimbPartCount, 20]
	Global m_LimbPartPosY:Int[c_LimbPartCount, 20]

	Field m_AngleA:Float
	Field m_AngleB:Float
	Field m_AngleC:Float

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method CreateLimbParts(inputZoom:Int, tileSize:Int)
		m_InputZoom = inputZoom
		m_TileSize = tileSize

		'Clear all the arrays before recreating
		For Local part:Int = 0 To c_LimbPartCount - 1
			m_LimbPartImage[part] = Null
			m_LimbPartJointOffsetX[part] = Null
			m_LimbPartJointOffsetY[part] = Null
			m_LimbPartLength[part] = Null
		Next
		'DebugStop

		For Local part:Int = 0 To c_LimbPartCount - 1
			m_LimbPartImage[part] = CreateImage(m_TileSize, m_TileSize, 1, DYNAMICIMAGE | MASKEDIMAGE)
			GrabImage(m_LimbPartImage[part], part * m_TileSize, 0)
			m_LimbPartTilePos[part] = New SVec2I(part * m_TileSize, 0)

			'Set up default limb part sizes
			m_LimbPartJointOffsetX[part] = m_TileSize / 2
			m_LimbPartJointOffsetY[part] = m_TileSize / 3.3 '3.6
			m_LimbPartLength[part] = ((m_TileSize / 2) - m_LimbPartJointOffsetY[part]) * 2
			SetImageHandle(m_LimbPartImage[part], m_LimbPartJointOffsetX[part] / m_InputZoom, m_LimbPartJointOffsetY[part] / m_InputZoom)
		Next
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method LawOfCosines(ab:Float, bc:Float, ca:Float)
		m_AngleA = ACos((ca ^ 2 + ab ^ 2 - bc ^ 2) / (2 * ca * ab))
		m_AngleB = ACos(( bc ^ 2 + ab ^ 2 - ca ^ 2) / (2 * bc * ab))
		m_AngleC = (180 - (m_AngleA + m_AngleB))
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Set Joint Marker
	Method SetJointMarker()
		Local xm:Int = MouseX()
		Local ym:Int = MouseY()
		If ym < ((m_TileSize / 2) - 2) And ym > 0 And xm > 0 And xm < (m_TileSize * c_LimbPartCount) Then
			Local part:Int = xm / m_TileSize
			m_LimbPartJointOffsetX[part] = m_TileSize / 2 	'X is always at center, so kinda pointless to even bother - at the moment
			m_LimbPartJointOffsetY[part] = ym				'Determines length
			m_LimbPartLength[part] = ((m_TileSize / 2) - ym) * 2
			SetImageHandle(m_LimbPartImage[part], m_LimbPartJointOffsetX[part] / m_InputZoom, m_LimbPartJointOffsetY[part] / m_InputZoom) 'Update rotation handle.
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method BendLimbs(frameCount:Int)
		Local stepSize:Float = (c_MaxExtend - c_MinExtend) / (frameCount - 1) ' -1 to make inclusive of last value (full range)
		For Local limb:Float = 0 To c_LimbCount - 1
			For Local frame:Int = 0 To frameCount - 1
				Local limbPart:Int = limb * 2
				Local posX:Float = (frame * 32) + 80 				'Drawing position X
				Local posY:Float = ((limb * 32) * 1.5 ) + 144		'Drawing position Y
				Local upperLength:Float = m_LimbPartLength[limbPart] / m_InputZoom
				Local lowerLength:Float = m_LimbPartLength[limbPart + 1] / m_InputZoom
				Local airLength:Float = ((stepSize * frame) + c_MinExtend) * (upperLength + lowerLength)	'Sum of the two bones * step scaler for frame (hip-ankle)
				LawOfCosines(airLength, upperLength, lowerLength)
				m_LimbPartAngle[limbPart, frame] = m_AngleB
				m_LimbPartPosX[limbPart, frame] = posX
				m_LimbPartPosY[limbPart, frame] = posY
				posX :- Sin(m_LimbPartAngle[limbPart, frame]) * upperLength			'Position of knee
				posY :+ Cos(m_LimbPartAngle[limbPart, frame]) * upperLength			'Could just use another m_LimbPartAngle of the triangle though, but I (arne) didn't
				m_LimbPartAngle[limbPart + 1, frame] = m_AngleC + m_AngleB + 180	'It looks correct on screen so i'm (arne) just gonna leave it at that!
				m_LimbPartPosX[limbPart + 1, frame] = posX
				m_LimbPartPosY[limbPart + 1, frame] = posY
			Next
		Next
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawJointMarker(centerPosX:Float, centerPosY:Float, radius:Int = 2, drawShadow:Int = True)
		Local centerPos:SVec2F = New SVec2F(centerPosX, centerPosY)
		DrawJointMarker(centerPos, radius, drawShadow)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawJointMarker(centerPos:SVec2F, radius:Int = 2, drawShadow:Int = True)
		SetRotation(0)

		If drawShadow = True Then
			Local shadowOffset:Int = 1
			SetColor(0, 0, 80)
			DrawLine(centerPos[0] - radius + shadowOffset, centerPos[1] + shadowOffset, centerPos[0] + radius + shadowOffset, centerPos[1] + shadowOffset)
			DrawLine(centerPos[0] + shadowOffset, centerPos[1] - radius + shadowOffset, centerPos[0] + shadowOffset, centerPos[1] + radius + shadowOffset)
		EndIf

		SetColor(255, 230, 80)
		DrawLine(centerPos[0] - radius, centerPos[1], centerPos[0] + radius, centerPos[1])
		DrawLine(centerPos[0], centerPos[1] - radius, centerPos[0], centerPos[1] + radius)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawJointMarkers()
		For Local limbPart:Int = 0 To c_LimbPartCount - 1
			DrawJointMarker(New SVec2F(m_LimbPartJointOffsetX[limbPart] + (limbPart * m_TileSize), m_LimbPartJointOffsetY[limbPart]), m_InputZoom)
			DrawJointMarker(New SVec2F(m_LimbPartJointOffsetX[limbPart] + (limbPart * m_TileSize), m_LimbPartJointOffsetY[limbPart] + m_LimbPartLength[limbPart]), m_InputZoom)
		Next
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawBentLimbs(frameCount:Int)
		BendLimbs(frameCount)
		For Local frame:Int = 0 To frameCount - 1
			Local limbPart:Int
			'DebugStop
			'These might be in a specific draw-order for joint overlapping purposes
			limbPart = 0 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 1 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 2 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 3 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 4 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 5 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 6 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 7 SetRotation(m_LimbPartAngle[limbPart, frame]) DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame], m_LimbPartPosY[limbPart, frame], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
		Next
		SetRotation(0)
	EndMethod
EndType