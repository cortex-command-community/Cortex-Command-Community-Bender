Include "Utility.bmx"
Include "JointMarker.bmx"

'//// LIMB MANAGER //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Const c_LimbPartCount:Int = 8
Const c_LimbCount:Int = c_LimbPartCount / 2
Const c_JointMarkerCount:Int = c_LimbPartCount * 2

Type LimbManager
	Const c_MinExtend:Float = 0.30	'Possibly make definable in settings (slider)
	Const c_MaxExtend:Float = 0.99	'Possibly make definable in settings (slider)

	Field m_InputZoom:Int
	Field m_TileSize:Int

	Field m_LimbPartTilePos:SVec2I[c_LimbPartCount]
	Field m_LimbPartImage:TImage[c_LimbPartCount]
	Field m_LimbPartLength:Float[c_LimbPartCount]
	Global m_LimbPartAngle:Int[c_LimbPartCount, 20]
	Global m_LimbPartPosX:Int[c_LimbPartCount, 20]
	Global m_LimbPartPosY:Int[c_LimbPartCount, 20]

	Field m_AngleA:Float
	Field m_AngleB:Float
	Field m_AngleC:Float
	Global m_JointMarkers:JointMarker[c_JointMarkerCount]

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method CreateLimbParts(inputZoom:Int, tileSize:Int)
		m_InputZoom = inputZoom
		m_TileSize = tileSize

		'Clear all the arrays before recreating
		For Local part:Int = 0 To c_LimbPartCount - 1
			m_LimbPartTilePos[part] = Null
			m_LimbPartImage[part] = Null
			m_LimbPartLength[part] = Null
		Next
		For Local marker:Int = 0 To c_JointMarkerCount - 1
			m_JointMarkers[marker] = Null
		Next

		For Local part:Int = 0 To c_LimbPartCount - 1
			m_LimbPartTilePos[part] = New SVec2I(part * m_TileSize, 0)
			m_LimbPartImage[part] = CreateImage(m_TileSize, m_TileSize, 1, DYNAMICIMAGE | MASKEDIMAGE)
			GrabImage(m_LimbPartImage[part], part * m_TileSize, 0)

			'Set up default limb part sizes
			m_LimbPartLength[part] = ((m_TileSize / 2.0) - (m_TileSize / 3.3)) * 2
			m_JointMarkers[part * 2] = New JointMarker(m_LimbPartTilePos[part], Int(m_TileSize / 2.0), Int(m_TileSize / 3.3), m_InputZoom) 'Top marker
			m_JointMarkers[(part * 2) + 1] = New JointMarker(m_LimbPartTilePos[part], Int(m_TileSize / 2.0), Int(m_JointMarkers[part * 2].GetPosOnCanvasY() + m_LimbPartLength[part]), m_InputZoom) 'Bottom marker
			SetImageHandle(m_LimbPartImage[part], m_JointMarkers[part * 2].GetPosOnTileX() / m_InputZoom, m_JointMarkers[part * 2].GetPosOnCanvasY() / m_InputZoom)
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
			SetImageHandle(m_LimbPartImage[part], m_LimbPartJointOffsetX[part] / m_InputZoom, m_LimbPartJointOffsetY[part] / m_InputZoom) 'Update rotation handle
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method BendLimbs(frameCount:Int)
		Local stepSize:Float = (c_MaxExtend - c_MinExtend) / (frameCount - 1) '-1 to make inclusive of last value (full range)
		For Local limb:Float = 0 To c_LimbCount - 1
			For Local frame:Int = 0 To frameCount - 1
				Local limbPart:Int = limb * 2
				Local posX:Float = (frame * 32)			'Drawing position X
				Local posY:Float = ((limb * 32) * 1.5 )	'Drawing position Y
				Local upperLength:Float = m_LimbPartLength[limbPart] / m_InputZoom
				Local lowerLength:Float = m_LimbPartLength[limbPart + 1] / m_InputZoom
				Local airLength:Float = ((stepSize * frame) + c_MinExtend) * (upperLength + lowerLength) 'Sum of the two bones * step scaler for frame (hip-ankle)
				LawOfCosines(airLength, upperLength, lowerLength)
				m_LimbPartAngle[limbPart, frame] = m_AngleB
				m_LimbPartPosX[limbPart, frame] = posX
				m_LimbPartPosY[limbPart, frame] = posY
				posX :- Sin(m_LimbPartAngle[limbPart, frame]) * upperLength 'Position of knee
				posY :+ Cos(m_LimbPartAngle[limbPart, frame]) * upperLength
				m_LimbPartAngle[limbPart + 1, frame] = m_AngleC + m_AngleB + 180
				m_LimbPartPosX[limbPart + 1, frame] = posX
				m_LimbPartPosY[limbPart + 1, frame] = posY
			Next
		Next
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawTileOutlines()
		Local frameSize:SVec2I = New SVec2I(m_TileSize, m_TileSize)
		Local drawColor:Int[] = [0, 0, 80]
		For Local part:Int = 0 To c_LimbPartCount - 1
			Utility.DrawRectOutline(m_LimbPartTilePos[part], frameSize, drawColor)
		Next
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawJointMarkers()
		SetRotation(0)
		For Local marker:JointMarker = EachIn m_JointMarkers
			marker.Draw()
		Next
		SetColor(255, 255, 255)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method DrawBentLimbs(drawPos:SVec2I, frameCount:Int)
		BendLimbs(frameCount)
		For Local frame:Int = 0 To frameCount - 1
			Local limbPart:Int
			'These might be in a specific draw-order for joint overlapping purposes
			'Arm FG
			limbPart = 0
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 1
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			'Arm BG
			limbPart = 2
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 3
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			'Leg FG
			limbPart = 4
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 5
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			'Leg BG
			limbPart = 6
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
			limbPart = 7
			SetRotation(m_LimbPartAngle[limbPart, frame])
			DrawImageRect(m_LimbPartImage[limbPart], m_LimbPartPosX[limbPart, frame] + drawPos[0], m_LimbPartPosY[limbPart, frame] + drawPos[1], ImageWidth(m_LimbPartImage[limbPart]) / m_InputZoom, ImageHeight(m_LimbPartImage[limbPart]) / m_InputZoom)
		Next
		SetRotation(0)
	EndMethod
EndType