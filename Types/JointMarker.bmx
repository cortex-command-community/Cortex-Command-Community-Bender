'//// JOINT MARKER //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type JointMarker
	Field m_ParentTilePosOnCanvas:SVec2I = Null
	Field m_PosOnCanvasX:Int = 0
	Field m_PosOnCanvasY:Int = 0
	Field m_PosOnTileX:Int = 0
	Field m_PosOnTileY:Int = 0
	Field m_Radius:Int = 0
	Field m_Selected:Int = False

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New(parentTilePos:SVec2I, centerPosX:Int, centerPosY:Int, radius:Int)
		m_ParentTilePosOnCanvas = parentTilePos
		m_Radius = radius
		SetPosOnTile(centerPosX, centerPosY)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetParentTilePosOnCanvas:SVec2I()
		Return m_ParentTilePosOnCanvas
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetPosOnCanvasX:Int()
		Return m_PosOnCanvasX
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetPosOnCanvasY:Int()
		Return m_PosOnCanvasY
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetPosOnTileX:Int()
		Return m_PosOnTileX
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetPosOnTileY:Int()
		Return m_PosOnTileY
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetPosOnTile:SVec2I()
		Return New SVec2I(m_PosOnTileX, m_PosOnTileY)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetPosOnTile(centerPosX:Int, centerPosY:Int)
		m_PosOnTileX = centerPosX
		m_PosOnTileY = centerPosY
		m_PosOnCanvasX = m_ParentTilePosOnCanvas[0] + centerPosX
		m_PosOnCanvasY = m_ParentTilePosOnCanvas[1] + centerPosY
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetSelected()
		m_Selected = True
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method Draw()
		Local shadowOffset:Int = 1
		SetColor(0, 0, 80)
		DrawLine(m_PosOnCanvasX - m_Radius + shadowOffset, m_PosOnCanvasY + shadowOffset, m_PosOnCanvasX + m_Radius + shadowOffset, m_PosOnCanvasY + shadowOffset, True)
		DrawLine(m_PosOnCanvasX + shadowOffset, m_PosOnCanvasY - m_Radius + shadowOffset, m_PosOnCanvasX + shadowOffset, m_PosOnCanvasY + m_Radius + shadowOffset, True)

		If m_Selected Then
			SetColor(50, 255, 0)
		Else
			SetColor(255, 230, 80)
		EndIf
		DrawLine(m_PosOnCanvasX - m_Radius, m_PosOnCanvasY, m_PosOnCanvasX + m_Radius, m_PosOnCanvasY, True)
		DrawLine(m_PosOnCanvasX, m_PosOnCanvasY - m_Radius, m_PosOnCanvasX, m_PosOnCanvasY + m_Radius, True)
		m_Selected = False
	EndMethod
EndType