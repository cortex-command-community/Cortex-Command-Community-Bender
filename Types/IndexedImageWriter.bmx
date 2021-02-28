Import "Utility.bmx"
Import "IndexedPixmap.bmx"

'//// RGB COLOR /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Struct RGBColor
	Field m_R:Byte = 0
	Field m_G:Byte = 0
	Field m_B:Byte = 0
EndStruct

'//// INDEXED IMAGE WRITER //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type IndexedImageWriter
	Field m_Palette:RGBColor[256]

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New()
		LoadDefaultPalette()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method LoadDefaultPalette()
		'If IncbinLen("Assets/Palette") <> 768 Then
		'	Notify("Palette file size is incorrect! File was not loaded!", False)
		'EndIf

		Local paletteStream:TStream = ReadFile("Incbin::Assets/Palette")
		For Local index:Int = 0 To 255
			m_Palette[index].m_R = ReadByte(paletteStream)
			m_Palette[index].m_G = ReadByte(paletteStream)
			m_Palette[index].m_B = ReadByte(paletteStream)
		Next
		CloseStream(paletteStream)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method ConvertColorToClosestIndex:Byte(pixelData:Int)
		'pixelData is a 32bit integer with a decimal color value (0 - 16777215). Bits 24-31 alpha value, bits 16-23 red value, bits 8-15 green value, bits 0-7 blue value.
		Select pixelData
			Case 16711935 'Magenta (255, 0, 255)
				Return 0
			Case 0 'Black (0, 0, 0)
				Return 245
			Case 16777215 'White (255, 255, 255)
				Return 254
			Default
				Local bestIndex:Int = 0
				Local bestDistance:Int = 17000000 'Out of bounds color value (max is 16777215)
				For Local index:Int = 0 To 255
					Local redDiff:Int = Abs(((pixelData & $00FF0000) Shr 16) - m_Palette[index].m_R)
					Local greenDiff:Int = Abs(((pixelData & $FF00) Shr 8) - m_Palette[index].m_G)
					Local blueDiff:Int = Abs((pixelData & $FF) - m_Palette[index].m_B)
					Local distance:Int = (redDiff ^ 2) + (greenDiff ^ 2) + (blueDiff ^ 2)

					If distance <= bestDistance Then
						bestDistance = distance
						bestIndex = index
					EndIf
				Next
				Return bestIndex
			EndSelect
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method WriteIndexedBitmapFromPixmap:Int(sourcePixmap:TPixmap, filename:String)
		If filename = Null Then
			Return False
		Else
			Local bmpWidth:Int = sourcePixmap.Width
			Local bmpWidthM4:Int = ((bmpWidth + 3) / 4) * 4 'bmpWidth adjusted to be divisible by 4. Written file is spaghetti if not adjusted!
			Local bmpHeight:Int = sourcePixmap.Height
			Local bmpSizeTotal:Int = (14 + 40) + (256 * 4) + (bmpWidthM4 * bmpHeight) 'File header size + DIB header size + color table size + dimensions (with adjusted width)
			Local bmpSizeTotalM4:Int = ((bmpSizeTotal + 3) / 4) * 4 'bmpSizeTotal adjusted to be divisible by 4. Written file is spaghetti if not adjusted!

			'Begin writing BMP file manually
			Local outputStream:TStream = LittleEndianStream(WriteFile(filename)) 'Bitmap file data is stored in little-endian format (least-significant byte first)
			If Not outputStream Then
				Return False
			EndIf

			'Bitmap File Header
			WriteShort(outputStream, 19778)				'File ID (2 bytes) - 19778 (decimal) or 42 4D (hex) or BM (ascii) for bitmap
			WriteInt(outputStream, bmpSizeTotalM4)		'File Size (4 bytes)
			WriteInt(outputStream, 0)					'Reserved (4 bytes)
			WriteInt(outputStream, 1078)				'Pixel Array Offset (4 bytes) - pixel array starts at 1078th byte (14 bytes Header + 40 bytes DIB + 1024 (256 * 4) bytes Color Table)

			'DIB Header (File Info)
			WriteInt(outputStream, 40)					'DIB Header Size (4 bytes) - 40 bytes
			WriteInt(outputStream, bmpWidth)			'Bitmap Width (4 bytes)
			WriteInt(outputStream, bmpHeight)			'Bitmap Height (4 bytes)
			WriteShort(outputStream, 1)					'Color Planes (2 bytes) - Must be 1
			WriteShort(outputStream, 8)					'Color Depth (2 bytes) - Bits Per Pixel
			WriteInt(outputStream, 0)					'Compression Method (4 bytes) - 0 equals BI_RGB (no compression)
			WriteInt(outputStream, bmpSizeTotalM4)		'Size of the raw bitmap data (4 bytes) - 0 can be given for BI_RGB bitmaps
			WriteInt(outputStream, 2835)				'Horizontal resolution of the image (4 bytes) - Pixels Per Metre (2835 PPM equals 72.009 DPI/PPI)
			WriteInt(outputStream, 2835)				'Vertical resolution of the image (4 bytes) - Pixels Per Metre (2835 PPM equals 72.009 DPI/PPI)
			WriteInt(outputStream, 256)					'Number of colors in the color palette (4 bytes)
			WriteInt(outputStream, 0)					'Number of important colors (4 bytes) - 0 when every color is important

			'Color Table (4 bytes (RGBA) times the amount of colors in the palette)
			For Local paletteIndex:RGBColor = EachIn m_Palette
				WriteByte(outputStream, paletteIndex.m_R)	'Blue (1 byte)
				WriteByte(outputStream, paletteIndex.m_G)	'Green (1 byte)
				WriteByte(outputStream, paletteIndex.m_B)	'Red (1 byte)
				WriteByte(outputStream, 0)					'Reserved (1 byte) - Alpha channel, irrelevant for indexed bitmaps
			Next

			'Pixel Array
			For Local pixelY:Int = bmpHeight - 1 To 0 Step -1
				For Local pixelX:Int = 0 Until bmpWidthM4
					If pixelX < bmpWidth Then
						WriteByte(outputStream, ConvertColorToClosestIndex(ReadPixel(sourcePixmap, pixelX, pixelY)))
					Else
						WriteByte(outputStream, 0) 'Line padding
					EndIf
				Next
			Next

			'EOF padding
			For Local leftToPad:Int = 1 To bmpSizeTotalM4 - bmpSizeTotal
				WriteByte(outputStream, 0)
			Next

			CloseStream(outputStream)
			Return True
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method WriteIndexedPNGFromPixmap:Int(sourcePixmap:TPixmap, filename:String, compression:Int = 5)
		If filename = Null Then
			Return False
		Else
			'Begin writing PNG file manually
			Local outputStream:TStream = WriteStream(filename)
			If Not outputStream Then
				Return False
			EndIf

			Try
				Local pngPtr:Byte Ptr = png_create_write_struct("1.6.37", Null, Null, Null)
				Local pngInfoPtr:Byte Ptr = png_create_info_struct(pngPtr)

				png_set_write_fn(pngPtr, outputStream, Utility.PNGWriteStream, Utility.PNGFlushStream)
				png_set_compression_level(pngPtr, Utility.Clamp(compression, 0, 9))

				png_set_IHDR(pngPtr, pngInfoPtr, sourcePixmap.Width, sourcePixmap.Height, 8, PNG_COLOR_TYPE_PALETTE, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT) 'IHDR chunk - file properties
				png_set_PLTE(pngPtr, pngInfoPtr, Byte Ptr(m_Palette), m_Palette.Length) 'PLTE chunk - color table

				'Using the RGBA8888 source pixmap produces spaghetti output because of byte alignment, so conversion to RGB332 is needed
				'What happens is that 4 bytes are written when 1 is expected, so we're actually writing 4 pixels where the first pixel is correct and the following 3 are empty causing the output to stretch and spaghettify
				Local convertingPixmap:IndexedPixmap = New IndexedPixmap(sourcePixmap.Width, sourcePixmap.Height)
				For Local pixelY:Int = 0 Until sourcePixmap.Height
					For Local pixelX:Int = 0 Until sourcePixmap.Width
						'Convert the 32bit RGBA color value from the source pixmap to a 8bit index value and write it to the converting bitmap
						convertingPixmap.WritePixel(pixelX, pixelY, ConvertColorToClosestIndex(ReadPixel(sourcePixmap, pixelX, pixelY)))
					Next
				Next

				Local rows:Byte Ptr[sourcePixmap.Height]
				For Local i = 0 Until sourcePixmap.Height
					rows[i] = convertingPixmap.PixelPtr(0, i) 'Get row pointers from the converting bitmap (1 byte aligned so won't be spaghettified)
				Next
				png_set_rows(pngPtr, pngInfoPtr, rows)

				png_write_png(pngPtr, pngInfoPtr, 0, Null)
				png_destroy_write_struct(Varptr pngPtr, Varptr pngInfoPtr, Null)

				CloseStream(outputStream)
				Return True
			Catch error:String
				If error <> "PNG ERROR" Then
					Throw error
				EndIf
			EndTry
		EndIf
	EndMethod
EndType