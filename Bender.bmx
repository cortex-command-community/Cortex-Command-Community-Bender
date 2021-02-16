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
Include "Types/Utility.bmx"
Include "Types/UserInterface.bmx"
Include "Types/GraphicsOutput.bmx"
Include "Types/FileIO.bmx"
Include "Types/BitmapIndexer.bmx"

Global g_AppVersion:String = "1.3.0"
AppTitle = "CCCP Bender " + g_AppVersion

'//// BOOT //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Local ui:UserInterface = New UserInterface
Local output:GraphicsOutput = New GraphicsOutput
Local io:FileIO = New FileIO
Local indexer:BitmapIndexer = New BitmapIndexer
ui.InitializeUserInterface(output.m_InputZoom, output.m_Frames, output.m_BackgroundRed, output.m_BackgroundGreen, output.m_BackgroundBlue)
output.OutputBoot()
indexer.LoadPalette()

'//// EVENT HANDLING ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

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
	Local eventID:Int = EventID()

	'Event Responses
	ui.HandleEvents(eventID)

	Select eventID
		Case EVENT_WINDOWACTIVATE
			output.OutputUpdate()
		Case EVENT_GADGETLOSTFOCUS
			output.OutputUpdate()
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
					output.m_InputZoom = Utility.Clamp(GadgetText(ui.m_SettingsZoomTextbox).ToInt(), output.c_MinZoom, output.c_MaxZoom)

					SetGadgetText(ui.m_SettingsZoomTextbox, output.m_InputZoom)
					output.m_TileSize = 24 * output.m_InputZoom
					output.m_RedoLimbTiles = True
					output.OutputUpdate()
				'Frames
				Case ui.m_SettingsFramesTextbox
					output.m_Frames = Utility.Clamp(GadgetText(ui.m_SettingsFramesTextbox).ToInt(), output.c_MinFrameCount, output.c_MaxFrameCount)

					SetGadgetText(ui.m_SettingsFramesTextbox, output.m_Frames)
					output.OutputUpdate()
				'Bacground Color
				'Red
				Case ui.m_SettingsColorRTextbox
					output.m_BackgroundRed = Utility.Clamp(GadgetText(ui.m_SettingsColorRTextbox).ToInt(), output.c_MinBGColorValue, output.c_MaxBGColorValue)

					SetGadgetText(ui.m_SettingsColorRTextbox, output.m_BackgroundRed)
					output.OutputUpdate()
				'Green
				Case ui.m_SettingsColorGTextbox
					output.m_BackgroundGreen = Utility.Clamp(GadgetText(ui.m_SettingsColorGTextbox).ToInt(), output.c_MinBGColorValue, output.c_MaxBGColorValue)

					SetGadgetText(ui.m_SettingsColorGTextbox, output.m_BackgroundGreen)
					output.OutputUpdate()
				'Blue
				Case ui.m_SettingsColorBTextbox
					output.m_BackgroundBlue = Utility.Clamp(GadgetText(ui.m_SettingsColorBTextbox).ToInt(), output.c_MinBGColorValue, output.c_MaxBGColorValue)

					SetGadgetText(ui.m_SettingsColorBTextbox, output.m_BackgroundBlue)
					output.OutputUpdate()
			EndSelect
	EndSelect
EndWhile