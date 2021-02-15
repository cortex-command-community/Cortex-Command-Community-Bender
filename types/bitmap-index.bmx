Rem
------- INDEXING ------------------------------------------------------------------------------------------------------
EndRem

Type TBitmapIndex
	'Color Value Bytes
	Global palR:Byte[256]
	Global palG:Byte[256]
	Global palB:Byte[256]
	
	'Data Streams
	Global dataStream:TStream

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Load color table file
	Function FLoadPalette()
		Local index:Int
		If IncbinLen("Assets/Palette") = 768
			Local paletteStream:TStream = ReadFile("Incbin::Assets/Palette")
			For index = 0 To 255
				palR[index] = ReadByte(paletteStream)
				palG[index] = ReadByte(paletteStream)
				palB[index] = ReadByte(paletteStream)
			Next
			CloseStream paletteStream
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	

	'Indexed Bitmap File Writer
	Function FPixmapToIndexedBitmap(image:TPixmap, filename:String)
		'Foolproofing
		If filename = "" Then
			TAppFileIO.FRevertPrep()
		Else
			'Variables
			Local paletteIndex:Int
			Local bmpWidth:Int, bmpWidthM4:Int
			Local bmpHeight:Int
			Local bmpSizeTotal:Int, bmpSizeTotalM4:Int
			
			'Dimensions calc
			bmpWidth = PixmapWidth(image)
			bmpWidthM4 = ((bmpWidth + 3) / 4) * 4
			bmpHeight = PixmapHeight(image)
			
			'Filesize calc
			bmpSizeTotal = (14 + 40) + (256 * 4) + (bmpWidthM4 * bmpHeight)
			bmpSizeTotalM4 = ((bmpSizeTotal + 3) / 4) * 4
			
			'Begin writing BMP file manually
			dataStream = WriteFile(filename)
			
	'------ Bitmap File Header
			'Data is stored in little-endian format (least-significant byte first)
			dataStream = LittleEndianStream(dataStream)
	
			WriteShort(dataStream, 19778)			'File ID (2 bytes (short)) - 19778 (deci) or 42 4D (hex) or BM (ascii) for bitmap
			WriteInt(dataStream, bmpSizeTotalM4)	'File Size (4 bytes (signed int))
			WriteInt(dataStream, 0)					'Reserved (4 bytes)
			WriteInt(dataStream, 1078)				'Pixel Array Offset (4 bytes) - pixel array starts at 1078th byte (14 bytes Header + 40 bytes DIB + 1024 (256 * 4) bytes Color Table)
	
	'------ DIB Header (File Info)
			WriteInt(dataStream, 40)				'DIB Header Size (4 bytes) - 40 bytes
			WriteInt(dataStream, bmpWidth)			'Bitmap Width (4 bytes)
			WriteInt(dataStream, bmpHeight)			'Bitmap Height (4 bytes)
			WriteShort(dataStream, 1)				'Color Planes (2 bytes) - Must be 1
			WriteShort(dataStream, 8)				'Color Depth (2 bytes) - Bits Per Pixel
			WriteInt(dataStream, 0)					'Compression Method (4 bytes) - 0 equals BI_RGB (no compression)
			WriteInt(dataStream, bmpSizeTotalM4)	'Size of the raw bitmap data (4 bytes) - 0 can be given for BI_RGB bitmaps
			WriteInt(dataStream, 2835)				'Horizontal resolution of the image (4 bytes) - Pixels Per Metre (2835 PPM equals 72.009 DPI/PPI)
			WriteInt(dataStream, 2835)				'Vertical resolution of the image (4 bytes) - Pixels Per Metre (2835 PPM equals 72.009 DPI/PPI)
			WriteInt(dataStream, 256)				'Number of colors in the color palette (4 bytes)
			WriteInt(dataStream, 0)					'Number of important colors (4 bytes) - 0 when every color is important
	
	'------ Color Table
			For paletteIndex = 0 To 255
				WriteByte(dataStream, palB[paletteIndex])	'Blue (1 byte)
				WriteByte(dataStream, palG[paletteIndex])	'Green (1 byte)
				WriteByte(dataStream, palR[paletteIndex])	'Red (1 byte)
				WriteByte(dataStream, 0)					'Reserved (1 byte) - Alpha channel, irrelevant for indexed bitmaps
				
				Rem
				Color Table is 4 bytes (ARGB) times the amount of colors in the palette
				EndRem
			Next
				
	'------ Pixel Array
			Local px:Int, py:Int
			Local pixelData:Long
			Local bestIndex:Int = 0
			Local magenta:Int = 16711935	
			For py = bmpHeight - 1 To 0 Step - 1
				For px = 0 To bmpWidthM4 - 1
					'if a valid pixel on canvas
					If px < bmpWidth
						'Read pixel data
						pixelData = ReadPixel(image, px, py)
						'skip diffing magenta
						If pixelData = 16711935 Then
							WriteByte(dataStream, 1)
						Else
							'Check all color indexes for best match by pythagora
							Local R:Int, G:Int, B:Int
							Local RDIFF:Int, GDIFF:Int, BDIFF:Int
							Local bestDistance:Int = 17000000
							Local distance:Int = 0
							For paletteIndex = 0 To 255
								R = (pixelData & $00FF0000) Shr 16
								G = (pixelData & $FF00) Shr 8
								B = (pixelData & $FF)
								RDIFF = Abs(R - palR[paletteIndex])
								GDIFF = Abs(G - palG[paletteIndex])
								BDIFF = Abs(B - palB[paletteIndex])
								distance = (RDIFF ^ 2 + GDIFF ^ 2 + BDIFF ^ 2)
								If distance <= bestDistance Then
									bestIndex = paletteIndex
									bestDistance = distance
								EndIf
							Next
						EndIf
						WriteByte(dataStream, bestIndex)
					Else
						WriteByte(dataStream, 0) 'line padding
					EndIf
				Next
			Next
			'eof padding
			For paletteIndex = 1 To bmpSizeTotalM4 - bmpSizeTotal
				WriteByte(dataStream, 0)
			Next
			'Writing file finished, close stream
			CloseStream(dataStream)
		EndIf
	EndFunction
EndType