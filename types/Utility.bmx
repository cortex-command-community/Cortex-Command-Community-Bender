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

	Function DrawTextWithShadow(text:String, pos:Svec2I, color:Int[])
		SetColor(0, 0, 80)
		DrawText(text, pos[0] + 1, pos[1] + 1)
		SetColor(color[0], color[1], color[2])
		DrawText(text, pos[0], pos[1])
		SetColor(255, 255, 255)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawRectOutline(posX:Int, posY:Int, width:Int, height:Int, color:Int[])
		Local pos:SVec2I = New SVec2I(posX, posY)
		Local size:SVec2I = New SVec2I(width, height)
		DrawRectOutline(pos, size, color)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawRectOutline(pos:SVec2I, size:SVec2I, color:Int[])
		SetColor(color[0], color[1], color[2])
		DrawLine(pos[0], pos[1], pos[0] + size[0], pos[1], True)
		DrawLine(pos[0] + size[0], pos[1], pos[0] + size[0], pos[1] + size[1], True)
		DrawLine(pos[0] + size[0], pos[1] + size[1], pos[0], pos[1] + size[1], True)
		DrawLine(pos[0], pos[1] + size[1], pos[0], pos[1], True)
		SetColor(255, 255, 255)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function PointIsWithinBox:Int(point:SVec2I, boxPos:SVec2I, boxSize:SVec2I)
		Return point[0] >= boxPos[0] And point[0] < (boxPos[0] + boxSize[0]) And point[1] >= boxPos[1] And point[1] < (boxPos[1] + boxSize[1])
	EndFunction
EndType