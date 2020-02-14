Rem
------- FILE IO -------------------------------------------------------------------------------------------------------
EndRem

'Filepaths
Global importedFile:String = Null
Global exportedFile:String = Null

'File Filters
Global fileFilters:String

Type TAppFileIO
	'Save Bools
	Global saveAsIndexed:Int = False
	Global prepForSave:Int = False
	Global rdyForSave:Int = False
	Global runOnce:Int = False
	
	'Output copy for saving
	Global tempOutputImage:TPixmap
	
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
			TAppOutput.redoLimbTiles = True
		EndIf
	EndFunction
	
	'Prep Output For Saving
	Function FPrepForSave()
		If prepForSave Then
			If Not runOnce Then
				runOnce = True
				TAppOutput.FOutputUpdate()
			Else
				FSaveFile()
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
		ElseIf exportedFile <> importedFile Then
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
EndType