Rem
------- FILE IO -------------------------------------------------------------------------------------------------------
EndRem

'Filepaths
Global importedFile:String = Null
Global exportedFile:String = Null

'File Filters
Global fileFilters:String

Type FileIO
	'Load Bools
	Global loadingFirstTime:Int = True
		
	'Save Bools
	Global saveAsIndexed:Int = False
	Global saveAsFrames:Int = False
	Global prepForSave:Int = False
	Global rdyForSave:Int = False
	Global runOnce:Int = False
	
	'Output copy for saving
	Global tempOutputImage:TPixmap
	Global tempOutputFrame:TPixmap[4, 20]

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	'Load Source Image
	Function LoadFile()
		Local oldImportedFile:String = importedFile
		importedFile = RequestFile("Select graphic file to open","Image Files:png,bmp,jpg")
		'Foolproofing
		If importedFile = Null Then
			importedFile = oldImportedFile
			GraphicsOutput.sourceImage = GraphicsOutput.sourceImage
		Else
			GraphicsOutput.sourceImage = LoadImage(importedFile, 0)
			If loadingFirstTime = True Then
				GraphicsOutput.LoadingFirstTime()
				loadingFirstTime = False
			Else
				GraphicsOutput.redoLimbTiles = True
			EndIf
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	'Prep Output For Saving
	Function PrepForSave()
		If prepForSave Then
			If Not runOnce Then
				runOnce = True
				GraphicsOutput.OutputUpdate()
			Else
				If Not saveAsFrames Then
					SaveFile()
				Else
					SaveFileAsFrames()
				EndIf
			EndIf
		EndIf
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	Function RevertPrep()
		prepForSave = False
		rdyForSave = False
		runOnce = False
		GraphicsOutput.OutputUpdate()
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
	'Save Output Content To File
	Function SaveFile()
		exportedFile = RequestFile("Save graphic output", fileFilters, True)
		'Foolproofing
		If exportedFile = importedFile Then
			Notify("Cannot overwrite source image!", True)
		ElseIf exportedFile <> importedFile And exportedFile <> Null Then
			'Writing new file
			If saveAsIndexed = True
				BitmapIndexer.PixmapToIndexedBitmap(tempOutputImage, exportedFile)
			Else
	      		SavePixmapPNG(tempOutputImage, exportedFile)
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
		exportedFile = RequestFile("Save graphic output", "", True) 'No file extensions here, we add them later manually otherwise exported file name is messed up.
		'Foolproofing
		If exportedFile = importedFile Then
			Notify("Cannot overwrite source image!", True)
		ElseIf exportedFile <> importedFile And exportedFile <> Null Then
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
				For frame = 0 To GraphicsOutput.FRAMES - 1
					Local exportedFileTempName:String
					If frame < 10 Then
						exportedFileTempName = exportedFile+rowName + "00" + frame
					Else
						exportedFileTempName = exportedFile+rowName + "0" + frame
					EndIf
					If saveAsIndexed = True
						BitmapIndexer.PixmapToIndexedBitmap(tempOutputFrame[row, frame], exportedFileTempName + ".bmp")
					Else
			      		SavePixmapPNG(tempOutputFrame[row, frame], exportedFileTempName + ".png")
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