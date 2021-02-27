Import "Utility.bmx"
Import "IndexedPixmap.bmx"

'//// INDEXED IMAGE WRITER //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Struct RGBColor
	Field m_R:Byte
	Field m_G:Byte
	Field m_B:Byte
EndStruct

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type IndexedImageWriter
	Field m_PalR:Byte[256]
	Field m_PalG:Byte[256]
	Field m_PalB:Byte[256]

	Field m_Palette:RGBColor[256]

	'Field m_CRCTable:Int[256]

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New()
		LoadDefaultPalette()
Rem
		'Initialize CRC table
		For Local i:Int = 0 To 255
			Local value:Int = i
			For Local j:Int = 0 To 7
				If (value & $1) Then
					value = (value Shr 1) ~ $EDB88320 '~ for XOR
				Else
					value = (value Shr 1)
				EndIf
			Next
			m_CRCTable[i] = value
		Next
EndRem
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Rem
	Method GenerateCRC32FromBank:Int(bank:TBank)
		Local crcResult:Int = $FFFFFFFF
		For Local i:Int = 0 Until BankSize(bank)
			crcResult = (crcResult Shr 8) ~ m_CRCTable[PeekByte(bank, i) ~ (crcResult & $FF)]
		Next
		Return ~crcResult '~ for bitwise complement
	EndMethod
EndRem
'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method LoadDefaultPalette()
		'If IncbinLen("Assets/Palette") <> 768 Then
		'	Notify("Palette file size is incorrect! File was not loaded!", False)
		'EndIf

		Local paletteStream:TStream = ReadFile("Incbin::Assets/Palette")
		For Local index:Int = 0 To 255
			m_PalR[index] = ReadByte(paletteStream)
			m_PalG[index] = ReadByte(paletteStream)
			m_PalB[index] = ReadByte(paletteStream)

			m_Palette[index].m_R = m_PalR[index]
			m_Palette[index].m_G = m_PalG[index]
			m_Palette[index].m_B = m_PalB[index]
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
					Local redDiff:Int = Abs(((pixelData & $00FF0000) Shr 16) - m_PalR[index])
					Local greenDiff:Int = Abs(((pixelData & $FF00) Shr 8) - m_PalG[index])
					Local blueDiff:Int = Abs((pixelData & $FF) - m_PalB[index])
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

			'Color Table (4 bytes (ARGB) times the amount of colors in the palette)
			For Local index:Int = 0 To 255
				WriteByte(outputStream, m_PalB[index])	'Blue (1 byte)
				WriteByte(outputStream, m_PalG[index])	'Green (1 byte)
				WriteByte(outputStream, m_PalR[index])	'Red (1 byte)
				WriteByte(outputStream, 0)				'Reserved (1 byte) - Alpha channel, irrelevant for indexed bitmaps
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
Rem
	Method WriteIndexedPNGFromPixmap:Int(sourcePixmap:TPixmap, filename:String)
		If filename = Null Then
			Return False
		Else
			Local pngWidth:Int = sourcePixmap.Width
			Local pngWidthM4:Int = ((pngWidth + 3) / 4) * 4 'pngWidth adjusted to be divisible by 4. Written file is spaghetti if not adjusted!
			Local pngHeight:Int = sourcePixmap.Height
			Local pngSizeTotal:Int = pngWidthM4 * pngHeight 'dimensions (with adjusted width)
			Local pngSizeTotalM4:Int = ((pngSizeTotal + 3) / 4) * 4 'bmpSizeTotal adjusted to be divisible by 4. Written file is spaghetti if not adjusted!

			'Begin writing PNG file manually
			Local outputStream:TStream = BigEndianStream(WriteFile(filename)) 'PNG file data is stored in network byte order (big-endian)

			'PNG file header
			WriteByte(outputStream, 137)				'Has the high bit set to detect transmission systems that do not support 8-bit data and to reduce the chance that a text file is mistakenly interpreted as a PNG, or vice versa. 89 (hex) (1 byte)
			WriteByte(outputStream, 80)					'File ID (in ASCII, the letters PNG). 50 4E 47 (hex) (3 bytes)
			WriteByte(outputStream, 78)
			WriteByte(outputStream, 71)
			WriteShort(outputStream, 3338)				'A DOS-style line ending (CRLF) to detect DOS-Unix line ending conversion of the data. 0D 0A (hex) (2 bytes)
			WriteByte(outputStream, 26)					'A byte that stops display of the file under DOS when the command type has been used—the end-of-file character. 1A (hex) (1 byte)
			WriteByte(outputStream, 10)					'A Unix-style line ending (LF) to detect Unix-DOS line ending conversion. 0A (hex) (1 byte)

			'IHDR chunk (file properties)
			WriteInt(outputStream, 13)					'Chunk Length (4 bytes) - 13 bytes for IHDR
			WriteInt(outputStream, 1229472850)			'Chunk Type (4 bytes) -  1229472850 (decimal) or 49 48 44 52 (hex) or IHDR (ascii)

			WriteInt(outputStream, pngWidth)			'Image Width (4 bytes)
			WriteInt(outputStream, pngHeight)			'Image Height (4 bytes)
			WriteByte(outputStream, 8)					'Bit Depth (1 byte)
			WriteByte(outputStream, 3)					'Color Type (1 byte) - 3 for indexed color
			WriteByte(outputStream, 0)					'Compression Method (1 byte)
			WriteByte(outputStream, 0)					'Filter Method (1 byte)
			WriteByte(outputStream, 0)					'Interlace Method (1 byte) - 0 for no interlace

			'Figure out how to generate correct CRC
			WriteInt(outputStream, 0)					'CRC-32 checksum (4 bytes)

			'PLTE chunk (color table)
			WriteInt(outputStream, 768)					'Chunk Length (4 bytes) - 4 bytes (ARGB) times the amount of colors in the palette = 1024 bytes
			WriteInt(outputStream, 1347179589)			'Chunk Type (4 bytes) - 1347179589 (decimal) or 50 4C 54 45 (hex) or PLTE (ascii)

			For Local index:Int = 0 To 255
				WriteByte(outputStream, m_PalB[index])	'Blue (1 byte)
				WriteByte(outputStream, m_PalG[index])	'Green (1 byte)
				WriteByte(outputStream, m_PalR[index])	'Red (1 byte)
			Next

			'Figure out how to generate correct CRC
			WriteInt(outputStream, 0)					'CRC-32 checksum (4 bytes)

			'IDAT chunk (pixel array)
			WriteInt(outputStream, pngSizeTotal)		'Chunk Length (4 bytes) - width times height of the image + padding
			WriteInt(outputStream, 1229209940)			'Chunk Type (4 bytes) - 1229209940 (decimal) or 49 44 41 54 (hex) or IDAT (ascii)

			For Local pixelY:Int = pngHeight - 1 To 0 Step -1
				For Local pixelX:Int = 0 Until pngWidth
					If pixelX < pngWidth Then
						WriteByte(outputStream, ConvertColorToClosestIndex(ReadPixel(sourcePixmap, pixelX, pixelY)))
					'Else
					'	WriteByte(outputStream, 0) 		'Line padding
					EndIf
				Next
			Next

			'Figure out how to generate correct CRC
			WriteInt(outputStream, 0)					'CRC-32 checksum (4 bytes)

			'IEND chunk (EOF)
			WriteInt(outputStream, 0)					'Chunk Length (4 bytes) - 0 for IEND
			WriteInt(outputStream, 1229278788)			'Chunk Type (4 bytes) - 1229278788 (decimal) or 49 45 4E 44 (hex) or IEND (ascii)

			'Figure out how to generate correct CRC
			WriteInt(outputStream, 0)					'CRC-32 checksum (4 bytes)

			CloseStream(outputStream)
			Return True
		EndIf
	EndMethod
EndRem
'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method WriteIndexedPNGFromPixmap:Int(sourcePixmap:TPixmap, filename:String, compression:Int = 5)
		If filename = Null Then
			Return False
		Else
			'Begin writing PNG file manually
			Local outputStream:TStream = WriteStream(filename)

			Try
				Local pngPtr:Byte Ptr = png_create_write_struct("1.6.37", Null, Null, Null)
				Local pngInfoPtr:Byte Ptr = png_create_info_struct(pngPtr)

				png_set_write_fn(pngPtr, outputStream, Utility.PNGWriteStream, Utility.PNGFlushStream)

				png_set_compression_level(pngPtr, Utility.Clamp(compression, 0, 9))
				png_set_IHDR(pngPtr, pngInfoPtr, sourcePixmap.Width, sourcePixmap.Height, 8, PNG_COLOR_TYPE_PALETTE, PNG_INTERLACE_NONE, PNG_COMPRESSION_TYPE_DEFAULT, PNG_FILTER_TYPE_DEFAULT)

				Local palettePtr:Byte Ptr = m_Palette
				png_set_PLTE(pngPtr, pngInfoPtr, palettePtr, 256);

				Local convertingPixmap:IndexedPixmap = New IndexedPixmap(sourcePixmap.Width, sourcePixmap.Height)
				For Local pixelY:Int = 0 Until sourcePixmap.Height
					For Local pixelX:Int = 0 Until sourcePixmap.Width
						convertingPixmap.WritePixel(pixelX, pixelY, ConvertColorToClosestIndex(ReadPixel(sourcePixmap, pixelX, pixelY)))
					Next
				Next

				Local rows:Byte Ptr[sourcePixmap.Height]
				For Local i = 0 Until sourcePixmap.Height
					rows[i] = convertingPixmap.PixelPtr(0, i)
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