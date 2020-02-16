Rem
------- CORTEX COMMAND COMMUNITY PROJECT BENDER -----------------------------------------------------------------------
EndRem

SuperStrict

'Import dependencies into build
Import MaxGUI.Drivers
Import BRL.Max2D
Import BRL.Pixmap
Import BRL.PNGLoader
Import BRL.Stream
Import BRL.EndianStream

'Load assets
Include "assets.bmx"

'Include individual types
Include "types/user-interface.bmx"
Include "types/editor-output.bmx"
Include "types/file-io.bmx"
Include "types/bitmap-index.bmx"

'Version
Global appVersion:String = "1.2.2"
Global appVersionDate:String = "14 Feb 2020"

Rem
------- BOOT ----------------------------------------------------------------------------------------------------------
EndRem

New TAppGUI
New TAppOutput
New TAppFileIO
New TBitmapIndex
TAppGUI.FAppEditor()
TAppOutput.FOutputBoot()

Rem
------- EVENT HANDLING ------------------------------------------------------------------------------------------------
EndRem

While True	
	TAppOutput.FOutputUpdate()
	
	If ButtonState(TAppGUI.editSettingsIndexedCheckbox) = True Then
		fileFilters = "Image Files:bmp"
		TAppFileIO.saveAsIndexed = True
	Else
		fileFilters = "Image Files:png"
		TAppFileIO.saveAsIndexed = False
	EndIf

	'Debug stuff
	'Print "current event: " + CurrentEvent.ToString()
	'Print "allocated memory in bytes: " + GCMemAlloced() 'not sure how accurate this really is, numbers don't match with task manager
	'Print "mouse position in canvas: x = " + MouseX() + " y = " + MouseY()

	PollEvent
	'Event Responses
	Select EventID()
		Case EVENT_APPRESUME
			ActivateWindow(TAppGUI.editWindow)
			TAppOutput.FOutputUpdate()
		Case EVENT_WINDOWACTIVATE
			TAppOutput.FOutputUpdate()
		Case EVENT_GADGETLOSTFOCUS
			TAppOutput.FOutputUpdate()
		Case EVENT_MENUACTION
			Select EventData()
				Case TAppGUI.ABOUT_MENU
					AppTitle = "CCCP Bender v"+appversion
					Notify(LoadText("Incbin::assets/about-textbox-content"),False)
			EndSelect
		Case EVENT_GADGETACTION
			Select EventSource()
				'Quitting confirm
				Case TAppGUI.editQuitButton
					quitResult = Confirm("Quit program?")
				'Loading
				Case TAppGUI.editLoadButton
					TAppFileIO.FLoadFile()
					TAppOutput.FOutputUpdate()
				'Saving
				Case TAppGUI.editSaveButton
					TAppFileIO.prepForSave = True
					TAppOutput.FOutputUpdate()
				'Settings textbox inputs
				'Scale
				Case TAppGUI.editSettingsZoomTextbox
					Local userInputValue:Int = GadgetText(TAppGUI.editSettingsZoomTextbox).ToInt()	
					'Foolproofing
					If userInputValue > 4 Then
						TAppOutput.INPUTZOOM = 4
					ElseIf userInputValue <= 0 Then
						TAppOutput.INPUTZOOM = 1
					Else
						TAppOutput.INPUTZOOM = userInputValue
					EndIf
					SetGadgetText(TAppGUI.editSettingsZoomTextbox,TAppOutput.INPUTZOOM)
					TAppOutput.TILESIZE = 24 * TAppOutput.INPUTZOOM
					TAppOutput.redoLimbTiles = True
					TAppOutput.FOutputUpdate()
				'Frames
				Case TAppGUI.editSettingsFramesTextbox
					Local userInputValue:Int = GadgetText(TAppGUI.editSettingsFramesTextbox).ToInt()
					'Foolproofing
					If userInputValue > 20 Then
						TAppOutput.FRAMES = 20
					ElseIf userInputValue <= 0 Then
						TAppOutput.FRAMES = 1
					Else
						TAppOutput.FRAMES = userInputValue
					EndIf
					SetGadgetText(TAppGUI.editSettingsFramesTextbox,TAppOutput.FRAMES)
					TAppOutput.FOutputUpdate()
				'Bacground Color
				'Red
				Case TAppGUI.editSettingsColorRTextbox
					Local userInputValue:Int = GadgetText(TAppGUI.editSettingsColorRTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						TAppOutput.BACKGROUND_RED = 255
					ElseIf userInputValue < 0 Then
						TAppOutput.BACKGROUND_RED = 0
					Else
						TAppOutput.BACKGROUND_RED = userInputValue
					EndIf
					SetGadgetText(TAppGUI.editSettingsColorRTextbox,TAppOutput.BACKGROUND_RED)
					TAppOutput.FOutputUpdate()
				'Green
				Case TAppGUI.editSettingsColorGTextbox
					Local userInputValue:Int = GadgetText(TAppGUI.editSettingsColorGTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						TAppOutput.BACKGROUND_GREEN = 255
					ElseIf userInputValue < 0 Then
						TAppOutput.BACKGROUND_GREEN = 0
					Else
						TAppOutput.BACKGROUND_GREEN = userInputValue
					EndIf
					SetGadgetText(TAppGUI.editSettingsColorGTextbox,TAppOutput.BACKGROUND_GREEN)
					TAppOutput.FOutputUpdate()
				'Blue
				Case TAppGUI.editSettingsColorBTextbox
					Local userInputValue:Int = GadgetText(TAppGUI.editSettingsColorBTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						TAppOutput.BACKGROUND_BLUE = 255
					ElseIf userInputValue < 0 Then
						TAppOutput.BACKGROUND_BLUE = 0
					Else
						TAppOutput.BACKGROUND_BLUE = userInputValue
					EndIf
					SetGadgetText(TAppGUI.editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE)
					TAppOutput.FOutputUpdate()
			EndSelect
		'Quitting confirm
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			quitResult = Confirm("Quit program?")
	EndSelect
	'Quitting
	If quitResult Then Exit
EndWhile