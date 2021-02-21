'//// UTILITY FUNCTIONS /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type Utility

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function Clamp:Int(valueToClamp:Int, minValue:Int, maxValue:Int)
		If valueToClamp < minValue Then
			Return minValue
		ElseIf valueToClamp > maxValue Then
			Return maxValue
		EndIf
		Return valueToClamp
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawRectOutline(posX:Int, posY:Int, width:Int, height:Int)
		Local pos:SVec2I = New SVec2I(posX, posY)
		Local size:SVec2I = New SVec2I(width, height)
		DrawRectOutline(pos, size)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawRectOutline(pos:SVec2I, size:SVec2I)
		DrawLine(pos[0], pos[1], pos[0] + size[0], pos[1], True)
		DrawLine(pos[0] + size[0], pos[1], pos[0] + size[0], pos[1] + size[1], True)
		DrawLine(pos[0] + size[0], pos[1] + size[1], pos[0], pos[1] + size[1], True)
		DrawLine(pos[0], pos[1] + size[1], pos[0], pos[1], True)
		SetColor(255, 255, 255)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawCross(centerPosX:Int, centerPosY:Int, radius:Int = 2, drawShadow:Int = True)
		Local centerPos:SVec2I = New SVec2I(centerPosX, centerPosY)
		DrawCross(centerPos, radius, drawShadow)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawCross(centerPos:SVec2I, radius:Int = 2, drawShadow:Int = True)
		If drawShadow = True Then
			Local shadowOffset:Int = 1
			SetColor(0, 0, 80)
			DrawLine(centerPos[0] - radius + shadowOffset, centerPos[1] + shadowOffset, centerPos[0] + radius + shadowOffset, centerPos[1] + shadowOffset)
			DrawLine(centerPos[0] + shadowOffset, centerPos[1] - radius + shadowOffset, centerPos[0] + shadowOffset, centerPos[1] + radius + shadowOffset)
		EndIf

		SetColor(255, 230, 80)
		DrawLine(centerPos[0] - radius, centerPos[1], centerPos[0] + radius, centerPos[1])
		DrawLine(centerPos[0], centerPos[1] - radius, centerPos[0], centerPos[1] + radius)
		SetColor(255, 255, 255)
	EndFunction
EndType