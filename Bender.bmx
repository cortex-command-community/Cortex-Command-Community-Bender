Rem
 ██████  ██████  ██████  ████████ ███████ ██   ██      ██████  ██████  ███    ███ ███    ███  █████  ███    ██ ██████      ██████  ███████ ███    ██ ██████  ███████ ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ████  ████ ████  ████ ██   ██ ████   ██ ██   ██     ██   ██ ██      ████   ██ ██   ██ ██      ██   ██
██      ██    ██ ██████     ██    █████     ███       ██      ██    ██ ██ ████ ██ ██ ████ ██ ███████ ██ ██  ██ ██   ██     ██████  █████   ██ ██  ██ ██   ██ █████   ██████
██      ██    ██ ██   ██    ██    ██       ██ ██      ██      ██    ██ ██  ██  ██ ██  ██  ██ ██   ██ ██  ██ ██ ██   ██     ██   ██ ██      ██  ██ ██ ██   ██ ██      ██   ██
 ██████  ██████  ██   ██    ██    ███████ ██   ██      ██████  ██████  ██      ██ ██      ██ ██   ██ ██   ████ ██████      ██████  ███████ ██   ████ ██████  ███████ ██   ██
EndRem

SuperStrict

Import "EmbeddedAssets.bmx"
Import "Types/UserInterface.bmx"
Import "Types/FileIO.bmx"
Import "Types/GraphicsOutput.bmx"

'//// MAIN LOOP AND EVENT HANDLING //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

AppTitle = "CCCP Bender 1.3.0"

Global g_UserInterface:UserInterface
Global g_FileIO:FileIO
Global g_GraphicsOutput:GraphicsOutput

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Repeat
	g_UserInterface = New UserInterface(g_DefaultInputZoom, g_DefaultFrameCount, g_DefaultBackgroundRed, g_DefaultBackgroundGreen, g_DefaultBackgroundBlue)
	g_FileIO = New FileIO()
	g_GraphicsOutput = New GraphicsOutput()

	Repeat
		PollEvent()

		Select EventID()
			'Case EVENT_WINDOWACTIVATE
			'Case EVENT_GADGETLOSTFOCUS

			Case EVENT_APPRESUME
				ActivateWindow(g_UserInterface.m_MainWindow)
			Case EVENT_WINDOWSIZE
				g_UserInterface.ProcessWindowResize()
			Case EVENT_WINDOWACCEPT
				g_GraphicsOutput.LoadFile(g_FileIO.SetFileToLoad(EventExtra().ToString()))
			Case EVENT_MENUACTION
				Select EventData()
					Case g_UserInterface.c_HelpMenuTag
						Notify(g_UserInterface.m_HelpMenuText, False)
					Case g_UserInterface.c_AboutMenuTag
						Notify(g_UserInterface.m_AboutMenuText, False)
				EndSelect
			Case EVENT_GADGETACTION
				Select EventSource()
					'Loading
					Case g_UserInterface.m_LoadButton
						g_GraphicsOutput.LoadFile(g_FileIO.SetFileToLoad())
					'Saving
					Case g_UserInterface.m_SaveButton
						If g_FileIO.GetSaveAsFrames() Then
							g_GraphicsOutput.RevertBackgroundColorAfterSave(g_FileIO.SaveFileAsFrames(g_GraphicsOutput.GrabOutputFramesForSaving(), g_GraphicsOutput.GetFrameCount()))
						Else
							g_GraphicsOutput.RevertBackgroundColorAfterSave(g_FileIO.SaveFile(g_GraphicsOutput.GrabOutputForSaving()))
						EndIf
						Continue
					'Scale
					Case g_UserInterface.m_SettingsZoomTextbox
						g_UserInterface.SetZoomTextboxValue(g_GraphicsOutput.SetInputZoom(g_UserInterface.GetZoomTextboxValue()))
					'Frames
					Case g_UserInterface.m_SettingsFramesTextbox
						g_UserInterface.SetFramesTextboxValue(g_GraphicsOutput.SetFrameCount(g_UserInterface.GetFramesTextboxValue()))
					'BG Color
					Case g_UserInterface.m_SettingsColorRTextbox, g_UserInterface.m_SettingsColorGTextbox, g_UserInterface.m_SettingsColorBTextbox
						g_UserInterface.SetColorTextboxValues(g_GraphicsOutput.SetBackgroundColor(g_UserInterface.GetColorTextboxValues()))
					'Save as Frames
					Case g_UserInterface.m_SettingsSaveAsFramesCheckbox
						g_GraphicsOutput.SetDrawOutputFrameBounds(g_FileIO.SetSaveAsFrames(ButtonState(g_UserInterface.m_SettingsSaveAsFramesCheckbox)))
					'Save as Indexed
					Case g_UserInterface.m_SettingsIndexedCheckbox
						g_FileIO.SetSaveAsIndexed(ButtonState(g_UserInterface.m_SettingsIndexedCheckbox))
				EndSelect
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				If Confirm("Quit program?") Then End
		EndSelect

	g_GraphicsOutput.Update()
	g_GraphicsOutput.Draw()
	Forever
Forever