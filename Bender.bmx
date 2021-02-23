Rem
 ██████  ██████  ██████  ████████ ███████ ██   ██      ██████  ██████  ███    ███ ███    ███  █████  ███    ██ ██████      ██████  ███████ ███    ██ ██████  ███████ ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ████  ████ ████  ████ ██   ██ ████   ██ ██   ██     ██   ██ ██      ████   ██ ██   ██ ██      ██   ██
██      ██    ██ ██████     ██    █████     ███       ██      ██    ██ ██ ████ ██ ██ ████ ██ ███████ ██ ██  ██ ██   ██     ██████  █████   ██ ██  ██ ██   ██ █████   ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ██  ██  ██ ██  ██  ██ ██   ██ ██  ██ ██ ██   ██     ██   ██ ██      ██  ██ ██ ██   ██ ██      ██   ██
 ██████  ██████  ██   ██    ██    ███████ ██   ██      ██████  ██████  ██      ██ ██      ██ ██   ██ ██   ████ ██████      ██████  ███████ ██   ████ ██████  ███████ ██   ██
EndRem

SuperStrict

Import BRL.Basic
Import BRL.EventQueue
'Import BRL.Vector
Import BRL.PNGLoader

Import "EmbeddedAssets.bmx"
Import "Types/Utility.bmx"
Import "Types/UserInterface.bmx"
Import "Types/FileIO.bmx"

Include "Types/SettingsManager.bmx"
Include "Types/GraphicsOutput.bmx"


'//// GLOBAL VARIABLES //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Const g_AppVersion:String = "1.3.0"
AppTitle = "CCCP Bender " + g_AppVersion

'//// BOOT //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global g_UserInterface:UserInterface = New UserInterface(g_DefaultInputZoom, g_DefaultFrameCount, g_DefaultBackgroundRed, g_DefaultBackgroundGreen, g_DefaultBackgroundBlue)
Global g_FileIO:FileIO = New FileIO()
Global g_GraphicsOutput:GraphicsOutput = New GraphicsOutput()

'//// MAIN LOOP AND EVENT HANDLING //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

While True
	g_GraphicsOutput.InitializeGraphicsOutput()

	Repeat
		PollEvent()
		Select EventID()
			Case EVENT_APPRESUME
				ActivateWindow(g_UserInterface.m_MainWindow)
			Case EVENT_WINDOWSIZE
				g_UserInterface.ProcessWindowResize()
			Case EVENT_MENUACTION
				Select EventData()
					Case g_UserInterface.c_HelpMenuTag
						Notify(g_UserInterface.m_HelpMenuText, False)
					Case g_UserInterface.c_AboutMenuTag
						Notify(g_UserInterface.m_AboutMenuText, False)
				EndSelect
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				If Confirm("Quit program?") Then End


			'Case EVENT_WINDOWACTIVATE
			'Case EVENT_GADGETLOSTFOCUS
			Case EVENT_GADGETACTION
				Select EventSource()
					'Loading
					Case g_UserInterface.m_LoadButton
						g_GraphicsOutput.LoadFile(g_FileIO.SetFileToLoad())
					'Saving
					Case g_UserInterface.m_SaveButton
						g_GraphicsOutput.GrabOutputForSaving()
					'Scale
					Case g_UserInterface.m_SettingsZoomTextbox
						g_GraphicsOutput.m_InputZoom = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsZoomTextbox).ToInt(), 1, g_GraphicsOutput.c_MaxZoom)

						SetGadgetText(g_UserInterface.m_SettingsZoomTextbox, g_GraphicsOutput.m_InputZoom)
						g_GraphicsOutput.m_TileSize = 24 * g_GraphicsOutput.m_InputZoom
						g_GraphicsOutput.m_RedoLimbTiles = True
					'Frames
					Case g_UserInterface.m_SettingsFramesTextbox
						g_GraphicsOutput.m_FrameCount = Utility.Clamp(GadgetText(g_UserInterface.m_SettingsFramesTextbox).ToInt(), 1, g_GraphicsOutput.c_MaxFrameCount)

						SetGadgetText(g_UserInterface.m_SettingsFramesTextbox, g_GraphicsOutput.m_FrameCount)
					'BG Color
					Case g_UserInterface.m_SettingsColorRTextbox, g_UserInterface.m_SettingsColorGTextbox, g_UserInterface.m_SettingsColorBTextbox
						Local newColorValues:Int[] = [	.. 'Line continuation
							Utility.Clamp(GadgetText(g_UserInterface.m_SettingsColorRTextbox).ToInt(), 0, 255),	..
							Utility.Clamp(GadgetText(g_UserInterface.m_SettingsColorGTextbox).ToInt(), 0, 255),	..
							Utility.Clamp(GadgetText(g_UserInterface.m_SettingsColorBTextbox).ToInt(), 0, 255)	..
						]
						g_GraphicsOutput.SetBackgroundColor(newColorValues)
						g_UserInterface.SetColorTextboxValues(newColorValues)
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
							g_FileIO.m_FileFilters = "Image Files:bmp"
							g_FileIO.m_SaveAsIndexed = True
						Else
							g_FileIO.m_FileFilters = "Image Files:png"
							g_FileIO.m_SaveAsIndexed = False
						EndIf
				EndSelect
		EndSelect

	g_GraphicsOutput.OutputUpdate()
	Forever
EndWhile