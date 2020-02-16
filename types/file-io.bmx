Rem
------- FILE IO -------------------------------------------------------------------------------------------------------
EndRem

'Filepaths
Global importedFile:String = Null
Global exportedFile:String = Null

'File Filters
Global fileFilters:String

Type TAppFileIO
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
	Global tempOutputFrame:TPixmap[4,20] 'noice
	
	'Load Source Image
	Function FLoadFile()
		Local oldImportedFile:String = importedFile
		importedFile = RequestFile("Select graphic file to open","Image Files:png,bmp,jpg")
		'Foolproofing
		If importedFile = Null Then
			importedFile = oldImportedFile
			TAppOutput.sourceImage = TAppOutput.sourceImage
		Else
			TAppOutput.sourceImage = LoadImage(importedFile,0)
			If loadingFirstTime = True Then
				TAppOutput.FLoadingFirstTime()
				loadingFirstTime = False
			Else
				TAppOutput.redoLimbTiles = True
			EndIf
		EndIf
	EndFunction
	
	'Prep Output For Saving
	Function FPrepForSave()
		If prepForSave Then
			If Not runOnce Then
				runOnce = True
				TAppOutput.FOutputUpdate()
			Else
				If Not saveAsFrames Then
					FSaveFile()
				Else
					FSaveFileAsFrames()
				EndIf
			EndIf
		EndIf
	EndFunction
	
	Function FRevertPrep()
		prepForSave = False
		rdyForSave = False
		runOnce = False
		TAppOutput.FOutputUpdate()
	EndFunction
	
	'Save Output Content To File
	Function FSaveFile()
		exportedFile = RequestFile("Save graphic output",fileFilters,True)
		'Foolproofing
		If exportedFile = importedFile Then
			Notify("Cannot overwrite source image!",True)
		ElseIf exportedFile <> importedFile And exportedFile <> Null Then
			'Writing new file
			If saveAsIndexed = True
				TBitmapIndex.FPixmapToIndexedBitmap(tempOutputImage,exportedFile)
			Else
	      		SavePixmapPNG(tempOutputImage,exportedFile)
			EndIf
			FRevertPrep()
		Else
			'On Cancel
			FRevertPrep()
		EndIf
	EndFunction
	
	'Save Output Content As Frames
	Function FSaveFileAsFrames()
		exportedFile = RequestFile("Save graphic output","",True) 'No file extensions here, we add them later manually otherwise exported file name is messed up.
		'Foolproofing
		If exportedFile = importedFile Then
			Notify("Cannot overwrite source image!",True)
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
				For frame = 0 To TAppOutput.FRAMES-1
					Local exportedFileTempName:String
					If frame < 10 Then
						exportedFileTempName = exportedFile+rowName+"00"+frame
					Else
						exportedFileTempName = exportedFile+rowName+"0"+frame
					EndIf
					If saveAsIndexed = True
						TBitmapIndex.FPixmapToIndexedBitmap(tempOutputFrame[row,frame],exportedFileTempName+".bmp")
					Else
			      		SavePixmapPNG(tempOutputFrame[row,frame],exportedFileTempName+".png")
					EndIf
				Next
			Next
			FRevertPrep()
		Else
			'On Cancel
			FRevertPrep()
		EndIf	
	EndFunction
EndType