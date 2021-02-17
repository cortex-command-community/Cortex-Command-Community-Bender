Rem
 ██████  ██████  ██████  ████████ ███████ ██   ██      ██████  ██████  ███    ███ ███    ███  █████  ███    ██ ██████      ██████  ███████ ███    ██ ██████  ███████ ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ████  ████ ████  ████ ██   ██ ████   ██ ██   ██     ██   ██ ██      ████   ██ ██   ██ ██      ██   ██
██      ██    ██ ██████     ██    █████     ███       ██      ██    ██ ██ ████ ██ ██ ████ ██ ███████ ██ ██  ██ ██   ██     ██████  █████   ██ ██  ██ ██   ██ █████   ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ██  ██  ██ ██  ██  ██ ██   ██ ██  ██ ██ ██   ██     ██   ██ ██      ██  ██ ██ ██   ██ ██      ██   ██
 ██████  ██████  ██   ██    ██    ███████ ██   ██      ██████  ██████  ██      ██ ██      ██ ██   ██ ██   ████ ██████      ██████  ███████ ██   ████ ██████  ███████ ██   ██
EndRem

SuperStrict

Import BRL.Basic
Import BRL.GLMax2D
Import MaxGUI.Drivers
Import BRL.EventQueue
Import BRL.Vector
Import BRL.PNGLoader

Include "EmbeddedAssets.bmx"
Include "Types/Utility.bmx"
Include "Types/UserInterface.bmx"
Include "Types/GraphicsOutput.bmx"
Include "Types/FileIO.bmx"
Include "Types/BitmapIndexer.bmx"

'//// GLOBAL VARIABLES //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global g_AppVersion:String = "1.3.0"
AppTitle = "CCCP Bender " + g_AppVersion

Global g_ImportedFile:String = Null
Global g_ExportedFile:String = Null
Global g_FileFilters:String

'//// BOOT //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global g_UserInterface:UserInterface = New UserInterface
Global g_GraphicsOutput:GraphicsOutput = New GraphicsOutput
Global g_FileIO:FileIO = New FileIO
Global g_BitmapIndexer:BitmapIndexer = New BitmapIndexer
g_UserInterface.InitializeUserInterface(g_GraphicsOutput.m_InputZoom, g_GraphicsOutput.m_Frames, g_GraphicsOutput.m_BackgroundRed, g_GraphicsOutput.m_BackgroundGreen, g_GraphicsOutput.m_BackgroundBlue)
g_GraphicsOutput.OutputBoot()
g_BitmapIndexer.LoadPalette()

'//// MAIN LOOP AND EVENT HANDLING //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

While True
	'Debug stuff
	'Print "current event: " + CurrentEvent.ToString()
	'Print "allocated memory in bytes: " + GCMemAlloced() 'not sure how accurate this really is, numbers don't match with task manager
	'Print "mouse position in canvas: x = " + MouseX() + " y = " + MouseY()

	PollEvent
	Local eventID:Int = EventID()

	g_UserInterface.HandleEvents(eventID)

	Select eventID
		'Case EVENT_WINDOWACTIVATE
		'Case EVENT_GADGETLOSTFOCUS
		Case EVENT_GADGETACTION
			Select EventSource()
				'Loading
				Case g_UserInterface.m_LoadButton
					g_FileIO.LoadFile()
				'Saving
				Case g_UserInterface.m_SaveButton
					If g_GraphicsOutput.m_SourceImage <> Null Then
						g_FileIO.m_PrepForSave = True
					Else
						Notify("Nothing to save!",False)
					EndIf
				'Scale
				Case g_UserInterface.m_SettingsZoomTextbox
					g_GraphicsOutput.m_InputZoom = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsZoomTextbox).ToInt(), g_GraphicsOutput.c_MinZoom, g_GraphicsOutput.c_MaxZoom)

					SetGadgetText(g_UserInterface.m_SettingsZoomTextbox, g_GraphicsOutput.m_InputZoom)
					g_GraphicsOutput.m_TileSize = 24 * g_GraphicsOutput.m_InputZoom
					g_GraphicsOutput.m_RedoLimbTiles = True
				'Frames
				Case g_UserInterface.m_SettingsFramesTextbox
					g_GraphicsOutput.m_Frames = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsFramesTextbox).ToInt(), g_GraphicsOutput.c_MinFrameCount, g_GraphicsOutput.c_MaxFrameCount)

					SetGadgetText(g_UserInterface.m_SettingsFramesTextbox, g_GraphicsOutput.m_Frames)
				'Red
				Case g_UserInterface.m_SettingsColorRTextbox
					g_GraphicsOutput.m_BackgroundRed = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsColorRTextbox).ToInt(), g_GraphicsOutput.c_MinBGColorValue, g_GraphicsOutput.c_MaxBGColorValue)

					SetGadgetText(g_UserInterface.m_SettingsColorRTextbox, g_GraphicsOutput.m_BackgroundRed)
				'Green
				Case g_UserInterface.m_SettingsColorGTextbox
					g_GraphicsOutput.m_BackgroundGreen = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsColorGTextbox).ToInt(), g_GraphicsOutput.c_MinBGColorValue, g_GraphicsOutput.c_MaxBGColorValue)

					SetGadgetText(g_UserInterface.m_SettingsColorGTextbox, g_GraphicsOutput.m_BackgroundGreen)
				'Blue
				Case g_UserInterface.m_SettingsColorBTextbox
					g_GraphicsOutput.m_BackgroundBlue = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsColorBTextbox).ToInt(), g_GraphicsOutput.c_MinBGColorValue, g_GraphicsOutput.c_MaxBGColorValue)

					SetGadgetText(g_UserInterface.m_SettingsColorBTextbox, g_GraphicsOutput.m_BackgroundBlue)
				'Save as Frames
				Case g_UserInterface.m_SettingsSaveAsFramesCheckbox
					If ButtonState(g_UserInterface.m_SettingsSaveAsFramesCheckbox) = True Then
						g_FileIO.m_SaveAsFrames = True
					Else
						g_FileIO.m_SaveAsFrames = False
					EndIf
				'Save as Indexed
				Case g_UserInterface.m_SettingsIndexedCheckbox
					If ButtonState(g_UserInterface.m_SettingsIndexedCheckbox) = True Then
						g_FileFilters = "Image Files:bmp"
						g_FileIO.m_SaveAsIndexed = True
					Else
						g_FileFilters = "Image Files:png"
						g_FileIO.m_SaveAsIndexed = False
					EndIf
			EndSelect
	EndSelect

	g_GraphicsOutput.OutputUpdate()
EndWhile