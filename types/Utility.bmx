'//// EXTERNAL FUNCTIONS ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Extern
	Function png_set_PLTE(png_ptr:Byte Ptr, info_ptr:Byte Ptr, palette:Byte Ptr, num_palette:Int) = "bmx_png_set_PLTE"
EndExtern

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

	Function ResetDrawColor()
		SetColor(255, 255, 255)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function DrawTextWithShadow(text:String, pos:SVec2I, color:Int[])
		SetColor(0, 0, 80)
		DrawText(text, pos[0] + 1, pos[1] + 1)
		SetColor(color[0], color[1], color[2])
		DrawText(text, pos[0], pos[1])
		ResetDrawColor()
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
		ResetDrawColor()
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function PointIsWithinBox:Int(point:SVec2I, boxPos:SVec2I, boxSize:SVec2I)
		Return point[0] >= boxPos[0] And point[0] < (boxPos[0] + boxSize[0]) And point[1] >= boxPos[1] And point[1] < (boxPos[1] + boxSize[1])
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function RotatePixmap:TPixmap(sourcePixmap:TPixmap, angle:Int)
		Local outputPixmap:TPixmap

		'This is pretty garbage but BlitzMax life is hard
		Select angle
			Case 90
				outputPixmap = CreatePixmap(sourcePixmap.Height, sourcePixmap.Width, sourcePixmap.Format)
				For Local x:Int = 0 Until sourcePixmap.Width
					For Local y:Int = 0 Until sourcePixmap.Height
						WritePixel(outputPixmap, sourcePixmap.Height - y - 1, x, ReadPixel(sourcePixmap, x, y))
					Next
				Next
			Case 180
				outputPixmap = CreatePixmap(sourcePixmap.Width, sourcePixmap.Height, sourcePixmap.Format)
				For Local x:Int = 0 Until sourcePixmap.Width
					For Local y:Int = 0 Until sourcePixmap.Height
						WritePixel(outputPixmap, sourcePixmap.Width - x - 1, sourcePixmap.Height - y - 1, ReadPixel(sourcePixmap, x, y))
					Next
				Next
			Case 270, -90
				outputPixmap = CreatePixmap(sourcePixmap.Height, sourcePixmap.Width, sourcePixmap.Format)
				For Local x:Int = 0 Until sourcePixmap.Width
					For Local y:Int = 0 Until sourcePixmap.Height
						WritePixel(outputPixmap, y, sourcePixmap.Width - x - 1, ReadPixel(sourcePixmap, x, y))
					Next
				Next
			Default
				outputPixmap = sourcePixmap
		EndSelect
		Return outputPixmap
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function PNGWriteStream(pngPtr:Byte Ptr, buf:Byte Ptr, size:Int)
		Local outputStream:TStream = TStream(png_get_io_ptr(pngPtr))
		Return outputStream.WriteBytes(buf, size)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function PNGFlushStream(pngPtr:Byte Ptr)
		Local outputStream:TStream = TStream(png_get_io_ptr(pngPtr))
		FlushStream(outputStream)
	EndFunction
EndType