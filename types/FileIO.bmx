Import BRL.PNGLoader
Import "IndexedImageWriter.bmx"

'//// FILE IO ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type FileIO
	Field m_ImportedFile:String = Null
	Field m_FileFilters:String

	Field m_SaveAsIndexed:Int = False
	Field m_SaveAsFrames:Int = False

	Field m_IndexedImageWriter:IndexedImageWriter

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New()
		m_IndexedImageWriter = New IndexedImageWriter()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetFileToLoad:String(pathFromDropEvent:String = Null)
		Local newImportFile:String = Null
		If pathFromDropEvent <> Null Then
			If pathFromDropEvent.EndsWith(".png") Or pathFromDropEvent.EndsWith(".bmp") Then
				newImportFile = pathFromDropEvent
			Else
				Notify("Can't load file with ~q." + ExtractExt(pathFromDropEvent) + "~q extension!~nValid extensions are ~q.bmp~q and ~q.png~q!")
				Return m_ImportedFile
			EndIf
		Else
			newImportFile = RequestFile("Select graphic file to open", "Image Files:png,bmp")
		EndIf
		If newImportFile <> Null And newImportFile <> m_ImportedFile Then
			m_ImportedFile = newImportFile
		EndIf
		Return m_ImportedFile
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetSaveAsFrames(framesOrNot:Int)
		m_SaveAsFrames = framesOrNot
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetSaveAsIndexed(indexedOrNot:Int)
		m_SaveAsIndexed = indexedOrNot
		If m_SaveAsIndexed = True Then
			m_FileFilters = "Image Files:bmp"
		Else
			m_FileFilters = "Image Files:png"
		EndIf
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SaveFile:Int(pixmapToSave:TPixmap)
		Local filename:String = RequestFile("Save graphic output", m_FileFilters, True)
		If CheckValidExportFileName(filename) Then
			Local saveSuccess:Int = True
			If m_SaveAsIndexed = True Then
				saveSuccess = m_IndexedImageWriter.WriteIndexedBitmapFromPixmap(pixmapToSave, filename)
				'saveSuccess = m_IndexedImageWriter.WriteIndexedPNGFromPixmap(pixmapToSave, filename)
			Else
				saveSuccess = SavePixmapPNG(pixmapToSave, filename)
			EndIf
			If Not saveSuccess Then
				Notify("Failed to save file: " + filename)
			EndIf
		EndIf
		Return True 'Retrun something to indicate function finished so workspace can be reverted
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SaveFileAsFrames:Int(pixmapToSave:TPixmap[,], frameCount:Int)
		Local filename:String = RequestFile("Save graphic output", Null, True) 'No file extensions here, we add them later manually otherwise exported file name is messed up.
		If CheckValidExportFileName(filename) Then
			For Local row:Int = 0 To 3
				Local rowName:String 'Name the rows - by default: ArmFG, ArmBG, LegFG, LegBG in this order.
				Select row
					Case 0
						rowName = "ArmFG"
					Case 1
						rowName = "ArmBG"
					Case 2
						rowName = "LegFG"
					Case 3
						rowName = "LegBG"
				EndSelect

				For Local frame:Int = 0 To frameCount - 1
					Local leadingZeros:String = "00"
					Local fullFilename:String = filename + rowName + leadingZeros + frame
					If frame < 10 Then
						leadingZeros = "0"
					EndIf

					Local saveSuccess:Int = True
					If m_SaveAsIndexed = True Then
						saveSuccess = m_IndexedImageWriter.WriteIndexedBitmapFromPixmap(pixmapToSave[row, frame], fullFilename + ".bmp")
						'saveSuccess = m_IndexedImageWriter.WriteIndexedPNGFromPixmap(pixmapToSave[row, frame], fullFilename + ".png")
					Else
						saveSuccess = SavePixmapPNG(pixmapToSave[row, frame], fullFilename + ".png")
					EndIf

					If Not saveSuccess Then
						Notify("Failed to save file: " + fullFilename + "~nFurther saving aborted!")
						Return True
					EndIf
				Next
			Next
		EndIf
		Return True 'Return something to indicate function finished so workspace can be reverted
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method CheckValidExportFileName:Int(filenameToCheck:String)
		If filenameToCheck = m_ImportedFile Then
			Notify("Cannot overwrite source image!", True)
			Return False
		ElseIf filenameToCheck <> m_ImportedFile And filenameToCheck <> Null Then
			Return True
		Else
			Return False 'On RequestFile cancel
		EndIf
	EndMethod
EndType