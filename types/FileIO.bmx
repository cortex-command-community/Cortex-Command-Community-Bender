Rem
------- FILE IO -------------------------------------------------------------------------------------------------------
EndRem

'Filepaths
Global g_ImportedFile:String = Null
Global g_ExportedFile:String = Null

'File Filters
Global g_FileFilters:String

Type FileIO
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

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	'Load Source Image
	Function LoadFile()
		Local oldImportedFile:String = g_ImportedFile
		g_ImportedFile = RequestFile("Select graphic file to open","Image Files:png,bmp,jpg")
		'Foolproofing
		If g_ImportedFile = Null Then
			g_ImportedFile = oldImportedFile
			GraphicsOutput.m_SourceImage = GraphicsOutput.m_SourceImage
		Else
			GraphicsOutput.m_SourceImage = LoadImage(g_ImportedFile, 0)
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
		g_ExportedFile = RequestFile("Save graphic output", g_FileFilters, True)
		'Foolproofing
		If g_ExportedFile = g_ImportedFile Then
			Notify("Cannot overwrite source image!", True)
		ElseIf g_ExportedFile <> g_ImportedFile And g_ExportedFile <> Null Then
			'Writing new file
			If m_SaveAsIndexed = True
				BitmapIndexer.PixmapToIndexedBitmap(m_TempOutputImageCopy, g_ExportedFile)
			Else
	      		SavePixmapPNG(m_TempOutputImageCopy, g_ExportedFile)
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
		g_ExportedFile = RequestFile("Save graphic output", "", True) 'No file extensions here, we add them later manually otherwise exported file name is messed up.
		'Foolproofing
		If g_ExportedFile = g_ImportedFile Then
			Notify("Cannot overwrite source image!", True)
		ElseIf g_ExportedFile <> g_ImportedFile And g_ExportedFile <> Null Then
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
						exportedFileTempName = g_ExportedFile+rowName + "00" + frame
					Else
						exportedFileTempName = g_ExportedFile+rowName + "0" + frame
					EndIf
					If m_SaveAsIndexed = True
						BitmapIndexer.PixmapToIndexedBitmap(m_TempOutputFrameCopy[row, frame], exportedFileTempName + ".bmp")
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