Rem
 ██████  ██████  ██████  ████████ ███████ ██   ██      ██████  ██████  ███    ███ ███    ███  █████  ███    ██ ██████      ██████  ███████ ███    ██ ██████  ███████ ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ████  ████ ████  ████ ██   ██ ████   ██ ██   ██     ██   ██ ██      ████   ██ ██   ██ ██      ██   ██
██      ██    ██ ██████     ██    █████     ███       ██      ██    ██ ██ ████ ██ ██ ████ ██ ███████ ██ ██  ██ ██   ██     ██████  █████   ██ ██  ██ ██   ██ █████   ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ██  ██  ██ ██  ██  ██ ██   ██ ██  ██ ██ ██   ██     ██   ██ ██      ██  ██ ██ ██   ██ ██      ██   ██
 ██████  ██████  ██   ██    ██    ███████ ██   ██      ██████  ██████  ██      ██ ██      ██ ██   ██ ██   ████ ██████      ██████  ███████ ██   ████ ██████  ███████ ██   ██
EndRem

SuperStrict

Import MaxGUI.Drivers
Import BRL.Max2D
Import BRL.Pixmap
Import BRL.PNGLoader
Import BRL.Stream
Import BRL.EndianStream

Include "EmbeddedAssets.bmx"

Include "types/user-interface.bmx"
Include "types/editor-output.bmx"
Include "types/file-io.bmx"
Include "types/bitmap-index.bmx"

Global appVersion:String = "1.3.0"
AppTitle = "CCCP Bender " + appVersion

Rem
------- BOOT ----------------------------------------------------------------------------------------------------------
EndRem

Local ui:UserInterface = New UserInterface
Local output:GraphicsOutput = New GraphicsOutput
Local io:FileIO = New FileIO
Local indexer:BitmapIndexer = New BitmapIndexer
ui.InitializeWindow()
output.OutputBoot()

Rem
------- EVENT HANDLING ------------------------------------------------------------------------------------------------
EndRem

While True
	output.OutputUpdate()
	
	If ButtonState(ui.editSettingsIndexedCheckbox) = True Then
		fileFilters = "Image Files:bmp"
		io.saveAsIndexed = True
	Else
		fileFilters = "Image Files:png"
		io.saveAsIndexed = False
	EndIf
	
	If ButtonState(ui.editSettingsSaveAsFramesCheckbox) = True Then
		io.saveAsFrames = True
	Else
		io.saveAsFrames = False
	EndIf

	'Debug stuff
	'Print "current event: " + CurrentEvent.ToString()
	'Print "allocated memory in bytes: " + GCMemAlloced() 'not sure how accurate this really is, numbers don't match with task manager
	'Print "mouse position in canvas: x = " + MouseX() + " y = " + MouseY()

	PollEvent
	'Event Responses
	Select EventID()
		Case EVENT_APPRESUME
			ActivateWindow(ui.editWindow)
			output.OutputUpdate()
		Case EVENT_WINDOWACTIVATE
			output.OutputUpdate()
		Case EVENT_GADGETLOSTFOCUS
			output.OutputUpdate()
		Case EVENT_MENUACTION
			Select EventData()
				Case ui.ABOUT_MENU
					Notify(LoadText("Incbin::Assets/TextboxAbout"),False)
			EndSelect
		Case EVENT_GADGETACTION
			Select EventSource()
				'Quitting confirm
				Case ui.editQuitButton
					quitResult = Confirm("Quit program?")
				'Loading
				Case ui.editLoadButton
					io.LoadFile()
					output.OutputUpdate()
				'Saving
				Case ui.editSaveButton
					If output.sourceImage <> Null Then
						io.prepForSave = True
						output.OutputUpdate()
					Else
						Notify("Nothing to save!",False)
					EndIf
				'Settings textbox inputs
				'Scale
				Case ui.editSettingsZoomTextbox
					Local userInputValue:Int = GadgetText(ui.editSettingsZoomTextbox).ToInt()	
					'Foolproofing
					If userInputValue > 4 Then
						output.INPUTZOOM = 4
					ElseIf userInputValue <= 0 Then
						output.INPUTZOOM = 1
					Else
						output.INPUTZOOM = userInputValue
					EndIf
					SetGadgetText(ui.editSettingsZoomTextbox, output.INPUTZOOM)
					output.TILESIZE = 24 * output.INPUTZOOM
					output.redoLimbTiles = True
					output.OutputUpdate()
				'Frames
				Case ui.editSettingsFramesTextbox
					Local userInputValue:Int = GadgetText(ui.editSettingsFramesTextbox).ToInt()
					'Foolproofing
					If userInputValue > 20 Then
						output.FRAMES = 20
					ElseIf userInputValue <= 0 Then
						output.FRAMES = 1
					Else
						output.FRAMES = userInputValue
					EndIf
					SetGadgetText(ui.editSettingsFramesTextbox, output.FRAMES)
					output.OutputUpdate()
				'Bacground Color
				'Red
				Case ui.editSettingsColorRTextbox
					Local userInputValue:Int = GadgetText(ui.editSettingsColorRTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						output.BACKGROUND_RED = 255
					ElseIf userInputValue < 0 Then
						output.BACKGROUND_RED = 0
					Else
						output.BACKGROUND_RED = userInputValue
					EndIf
					SetGadgetText(ui.editSettingsColorRTextbox, output.BACKGROUND_RED)
					output.OutputUpdate()
				'Green
				Case ui.editSettingsColorGTextbox
					Local userInputValue:Int = GadgetText(ui.editSettingsColorGTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						output.BACKGROUND_GREEN = 255
					ElseIf userInputValue < 0 Then
						output.BACKGROUND_GREEN = 0
					Else
						output.BACKGROUND_GREEN = userInputValue
					EndIf
					SetGadgetText(ui.editSettingsColorGTextbox, output.BACKGROUND_GREEN)
					output.OutputUpdate()
				'Blue
				Case ui.editSettingsColorBTextbox
					Local userInputValue:Int = GadgetText(ui.editSettingsColorBTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						output.BACKGROUND_BLUE = 255
					ElseIf userInputValue < 0 Then
						output.BACKGROUND_BLUE = 0
					Else
						output.BACKGROUND_BLUE = userInputValue
					EndIf
					SetGadgetText(ui.editSettingsColorBTextbox, output.BACKGROUND_BLUE)
					output.OutputUpdate()
			EndSelect
		'Quitting confirm
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			quitResult = Confirm("Quit program?")
	EndSelect
	'Quitting
	If quitResult Then Exit
EndWhile