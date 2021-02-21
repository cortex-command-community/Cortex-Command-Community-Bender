'Import "Types/IndexedImageWriter.bmx"
Include "IndexedImageWriter.bmx"

'//// FILE IO ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type FileIO
	Global m_ImportedFile:String = Null
	Global m_FileFilters:String

	'Load Bools
	Global m_LoadingFirstTime:Int = True

	'Save Bools
	Global m_SaveAsIndexed:Int = False
	Global m_SaveAsFrames:Int = False
	Global m_PrepForSave:Int = False
	Global m_ReadyForSave:Int = False
	Global m_RunOnce:Int = False

	'Output copy for saving
	Global m_TempOutputImageCopy:TPixmap
	Global m_TempOutputFrameCopy:TPixmap[4, 20]

	Global m_IndexedImageWriter:IndexedImageWriter = New IndexedImageWriter

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Load Source Image
	Function LoadFile()
		Local oldImportedFile:String = m_ImportedFile
		m_ImportedFile = RequestFile("Select graphic file to open", "Image Files:png,bmp,jpg")
		'Foolproofing
		If m_ImportedFile = Null Then
			m_ImportedFile = oldImportedFile
			GraphicsOutput.m_SourceImage = GraphicsOutput.m_SourceImage
		Else
			GraphicsOutput.m_SourceImage = LoadImage(m_ImportedFile, 0)
			If m_LoadingFirstTime = True Then
				GraphicsOutput.LoadingFirstTime()
				m_LoadingFirstTime = False
			Else
				GraphicsOutput.m_RedoLimbTiles = True
			EndIf
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Prep Output For Saving
	Function PrepForSave()
		If m_PrepForSave Then
			If Not m_RunOnce Then
				m_RunOnce = True
				GraphicsOutput.OutputUpdate()
			Else
				If Not m_SaveAsFrames Then
					SaveFile()
				Else
					SaveFileAsFrames()
				EndIf
			EndIf
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function RevertPrep()
		m_PrepForSave = False
		m_ReadyForSave = False
		m_RunOnce = False
		GraphicsOutput.OutputUpdate()
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Save Output Content To File
	Function SaveFile()
		Local exportedFile:String = RequestFile("Save graphic output", m_FileFilters, True)
		'Foolproofing
		If exportedFile = m_ImportedFile Then
			Notify("Cannot overwrite source image!", True)
		ElseIf exportedFile <> m_ImportedFile And exportedFile <> Null Then
			'Writing new file
			If m_SaveAsIndexed = True
				If m_IndexedImageWriter.WriteIndexedBitmapFromPixmap(m_TempOutputImageCopy, exportedFile) = False Then
					RevertPrep()
				EndIf
			Else
	      		SavePixmapPNG(m_TempOutputImageCopy, exportedFile)
			EndIf
			RevertPrep()
		Else
			'On Cancel
			RevertPrep()
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	'Save Output Content As Frames
	Function SaveFileAsFrames()
		Local exportedFile:String = RequestFile("Save graphic output", "", True) 'No file extensions here, we add them later manually otherwise exported file name is messed up.
		'Foolproofing
		If exportedFile = m_ImportedFile Then
			Notify("Cannot overwrite source image!", True)
		ElseIf exportedFile <> m_ImportedFile And exportedFile <> Null Then
			'Writing new file
			Local row:Int, frame:Int
			For row = 0 To 3
				'Name the rows - by default: ArmFG, ArmBG, LegFG, LegBG in this order.
				Local rowName:String
				If row = 0 Then
					rowName = "ArmFG"
				ElseIf row = 1 Then
					rowName = "ArmBG"
				ElseIf row = 2 Then
					rowName = "LegFG"
				ElseIf row = 3 Then
					rowName = "LegBG"
				EndIf
				For frame = 0 To GraphicsOutput.m_Frames - 1
					Local exportedFileTempName:String
					If frame < 10 Then
						exportedFileTempName = exportedFile + rowName + "00" + frame
					Else
						exportedFileTempName = exportedFile + rowName + "0" + frame
					EndIf
					If m_SaveAsIndexed = True
						If m_IndexedImageWriter.WriteIndexedBitmapFromPixmap(m_TempOutputFrameCopy[row, frame], exportedFileTempName + ".bmp") = False Then
							RevertPrep()
						EndIf
					Else
			      		SavePixmapPNG(m_TempOutputFrameCopy[row, frame], exportedFileTempName + ".png")
					EndIf
				Next
			Next
			RevertPrep()
		Else
			'On Cancel
			RevertPrep()
		EndIf
	EndFunction
EndType