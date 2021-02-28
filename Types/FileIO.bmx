Import "SettingsManager.bmx"
Import "IndexedImageWriter.bmx"

'//// FILE IO ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type FileIO
	Field m_ImportedFile:String = Null

	Field m_SaveAsFrames:Int = False
	Field m_SaveAsIndexed:Int = False
	Field m_IndexedFileType:String = g_DefaultIndexedFileType
	Field m_FileFilters:String = "Image Files:" + m_IndexedFileType

	Field m_IndexedImageWriter:IndexedImageWriter = Null

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

	Method GetSaveAsFrames:Int()
		Return m_SaveAsFrames
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetSaveAsFrames:Int(framesOrNot:Int)
		m_SaveAsFrames = framesOrNot
		Return m_SaveAsFrames
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetSaveAsIndexed:Int(indexedOrNot:Int)
		m_SaveAsIndexed = indexedOrNot
		Return m_SaveAsIndexed
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetIndexedFileType(fileType:String)
		m_IndexedFileType = fileType.ToLower()
		m_FileFilters = "Image Files:" + m_IndexedFileType
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SaveFile:Int(pixmapToSave:TPixmap)
		Local filename:String = RequestFile("Save graphic output", m_FileFilters, True)
		If CheckValidExportFileName(filename) Then
			Local saveSuccess:Int = True
			If m_SaveAsIndexed Then
				Select m_IndexedFileType
					Case "png"
						saveSuccess = m_IndexedImageWriter.WriteIndexedPNGFromPixmap(pixmapToSave, filename)
					Case "bmp"
						saveSuccess = m_IndexedImageWriter.WriteIndexedBMPFromPixmap(pixmapToSave, filename)
					Default
						saveSuccess = False
				EndSelect
			Else
				saveSuccess = SavePixmapPNG(pixmapToSave, filename)
			EndIf
			If Not saveSuccess Then
				Notify("Failed to save file: " + filename)
			EndIf
		EndIf
		Return True 'Return something to indicate function finished so workspace can be reverted
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SaveFileAsFrames:Int(pixmapToSave:TPixmap[,], frameCount:Int)
		Local filename:String = RequestFile("Save graphic output", Null, True) 'No file extensions here, we add them later manually otherwise exported file name is messed up
		If CheckValidExportFileName(filename) Then
			For Local row:Int = 0 To 3
				Local rowName:String 'Name the rows - by default: ArmFG, ArmBG, LegFG, LegBG in this order
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
					If m_SaveAsIndexed Then
						Select m_IndexedFileType
							Case "png"
								saveSuccess = m_IndexedImageWriter.WriteIndexedPNGFromPixmap(pixmapToSave[row, frame], fullFilename + ".png")
							Case "bmp"
								saveSuccess = m_IndexedImageWriter.WriteIndexedBMPFromPixmap(pixmapToSave[row, frame], fullFilename + ".bmp")
							Default
								saveSuccess = False
						EndSelect
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