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
Import BRL.Vector

Include "EmbeddedAssets.bmx"

Include "Types/UserInterface.bmx"
Include "Types/GraphicsOutput.bmx"
Include "Types/FileIO.bmx"
Include "Types/BitmapIndexer.bmx"

Global g_AppVersion:String = "1.3.0"
AppTitle = "CCCP Bender " + g_AppVersion

Rem
------- BOOT ----------------------------------------------------------------------------------------------------------
EndRem

Local ui:UserInterface = New UserInterface
Local output:GraphicsOutput = New GraphicsOutput
Local io:FileIO = New FileIO
Local indexer:BitmapIndexer = New BitmapIndexer
ui.InitializeUserInterface(output.m_InputZoom, output.m_Frames, output.m_BackgroundRed, output.m_BackgroundGreen, output.m_BackgroundBlue)
output.OutputBoot()

Rem
------- EVENT HANDLING ------------------------------------------------------------------------------------------------
EndRem

While True
	output.OutputUpdate()
	
	If ButtonState(ui.m_SettingsIndexedCheckbox) = True Then
		g_FileFilters = "Image Files:bmp"
		io.m_SaveAsIndexed = True
	Else
		g_FileFilters = "Image Files:png"
		io.m_SaveAsIndexed = False
	EndIf
	
	If ButtonState(ui.m_SettingsSaveAsFramesCheckbox) = True Then
		io.m_SaveAsFrames = True
	Else
		io.m_SaveAsFrames = False
	EndIf

	'Debug stuff
	'Print "current event: " + CurrentEvent.ToString()
	'Print "allocated memory in bytes: " + GCMemAlloced() 'not sure how accurate this really is, numbers don't match with task manager
	'Print "mouse position in canvas: x = " + MouseX() + " y = " + MouseY()

	PollEvent
	'Event Responses
	Select EventID()
		Case EVENT_WINDOWSIZE
			ui.ProcessWindowResize()
			output.OutputUpdate()
		Case EVENT_APPRESUME
			ActivateWindow(ui.m_MainWindow)
			output.OutputUpdate()
		Case EVENT_WINDOWACTIVATE
			output.OutputUpdate()
		Case EVENT_GADGETLOSTFOCUS
			output.OutputUpdate()
		Case EVENT_MENUACTION
			Select EventData()
				Case ui.c_HelpMenuTag
					Notify(LoadText("Incbin::Assets/TextboxHelp"), False)
				Case ui.c_AboutMenuTag
					Notify(LoadText("Incbin::Assets/TextboxAbout"), False)
			EndSelect
		Case EVENT_GADGETACTION
			Select EventSource()
				'Loading
				Case ui.m_LoadButton
					io.LoadFile()
					output.OutputUpdate()
				'Saving
				Case ui.m_SaveButton
					If output.m_SourceImage <> Null Then
						io.m_PrepForSave = True
						output.OutputUpdate()
					Else
						Notify("Nothing to save!",False)
					EndIf
				'Settings textbox inputs
				'Scale
				Case ui.m_SettingsZoomTextbox
					Local userInputValue:Int = GadgetText(ui.m_SettingsZoomTextbox).ToInt()	
					'Foolproofing
					If userInputValue > 4 Then
						output.m_InputZoom = 4
					ElseIf userInputValue <= 0 Then
						output.m_InputZoom = 1
					Else
						output.m_InputZoom = userInputValue
					EndIf
					SetGadgetText(ui.m_SettingsZoomTextbox, output.m_InputZoom)
					output.m_TileSize = 24 * output.m_InputZoom
					output.m_RedoLimbTiles = True
					output.OutputUpdate()
				'Frames
				Case ui.m_SettingsFramesTextbox
					Local userInputValue:Int = GadgetText(ui.m_SettingsFramesTextbox).ToInt()
					'Foolproofing
					If userInputValue > 20 Then
						output.m_Frames = 20
					ElseIf userInputValue <= 0 Then
						output.m_Frames = 1
					Else
						output.m_Frames = userInputValue
					EndIf
					SetGadgetText(ui.m_SettingsFramesTextbox, output.m_Frames)
					output.OutputUpdate()
				'Bacground Color
				'Red
				Case ui.m_SettingsColorRTextbox
					Local userInputValue:Int = GadgetText(ui.m_SettingsColorRTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						output.m_BackgroundRed = 255
					ElseIf userInputValue < 0 Then
						output.m_BackgroundRed = 0
					Else
						output.m_BackgroundRed = userInputValue
					EndIf
					SetGadgetText(ui.m_SettingsColorRTextbox, output.m_BackgroundRed)
					output.OutputUpdate()
				'Green
				Case ui.m_SettingsColorGTextbox
					Local userInputValue:Int = GadgetText(ui.m_SettingsColorGTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						output.m_BackgroundGreen = 255
					ElseIf userInputValue < 0 Then
						output.m_BackgroundGreen = 0
					Else
						output.m_BackgroundGreen = userInputValue
					EndIf
					SetGadgetText(ui.m_SettingsColorGTextbox, output.m_BackgroundGreen)
					output.OutputUpdate()
				'Blue
				Case ui.m_SettingsColorBTextbox
					Local userInputValue:Int = GadgetText(ui.m_SettingsColorBTextbox).ToInt()
					'Foolproofing
					If userInputValue > 255 Then
						output.m_BackgroundBlue = 255
					ElseIf userInputValue < 0 Then
						output.m_BackgroundBlue = 0
					Else
						output.m_BackgroundBlue = userInputValue
					EndIf
					SetGadgetText(ui.m_SettingsColorBTextbox, output.m_BackgroundBlue)
					output.OutputUpdate()
			EndSelect
		'Quitting confirm
		Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
			g_QuitResult = Confirm("Quit program?")
	EndSelect
	'Quitting
	If g_QuitResult Then Exit
EndWhile