Rem
------- GUI ELEMENTS --------------------------------------------------------------------------------------------------
EndRem

'Bool For Quitting
Global g_QuitResult:Int = False

Type UserInterface

	'About menu event tag
	Const c_AboutMenuTag:Int = 100

	'Editor Window
	Global m_Window:TGadget
	'Editor Window about menu
	Global m_AboutMenu:TGadget
	'Editor Window Canvas Graphics
	Global m_Canvas:TGadget
	'Editor Window Buttons
	Global m_WindowButtonPanel:TGadget
	Global m_LoadButton:TGadget
	Global m_SaveButton:TGadget
	Global m_QuitButton:TGadget
	'Editor Window Settings
	Global m_SettingsPanel:TGadget
	Global m_SettingsZoomTextbox:TGadget
	Global m_SettingsFramesTextbox:TGadget
	Global m_SettingsColorRTextbox:TGadget
	Global m_SettingsColorGTextbox:TGadget
	Global m_SettingsColorBTextbox:TGadget
	Global m_SettingsZoomLabel:TGadget
	Global m_SettingsFramesLabel:TGadget
	Global m_SettingsColorLabel:TGadget
	Global m_SettingsColorRLabel:TGadget
	Global m_SettingsColorGLabel:TGadget
	Global m_SettingsColorBLabel:TGadget
	Global m_SettingsIndexedLabel:TGadget
	Global m_SettingsIndexedCheckbox:TGadget
	Global m_SettingsSaveAsFramesLabel:TGadget
	Global m_SettingsSaveAsFramesCheckbox:TGadget
	'Editor Window Help
	Global m_HelpPanel:TGadget
	Global m_HelpTextbox:TGadget

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////	
	
	'Create Editor Window
	Function InitializeWindow()
		EnablePolledInput()
		m_Window = CreateWindow("CCCP Bender " + g_AppVersion + " - Editor", DesktopWidth() / 2 - 700, DesktopHeight() / 2 - 240, 300 + 768, 430 + 50, Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_CLIENTCOORDS)
		m_Canvas = CreateCanvas(300, 0, 768, 480, m_Window)
		m_AboutMenu = CreateMenu("About", c_AboutMenuTag, WindowMenu(m_Window))
		UpdateWindowMenu(m_Window)
		m_WindowButtonPanel = CreatePanel(10, 7, 280, 57, m_Window, PANEL_GROUP)	
		m_LoadButton = CreateButton("Load", 6, 0, 80, 30, m_WindowButtonPanel, BUTTON_PUSH)
		m_SaveButton = CreateButton("Save", 96, 0, 80, 30, m_WindowButtonPanel, BUTTON_PUSH)
		m_QuitButton = CreateButton("Quit", 186, 0, 80, 30, m_WindowButtonPanel, BUTTON_PUSH)
		m_SettingsPanel = CreatePanel(10, 73, 280, 120, m_Window, PANEL_GROUP, "  Settings :  ")
		m_SettingsZoomTextbox = CreateTextField(80, 12, 30, 20, m_SettingsPanel)
		m_SettingsFramesTextbox = CreateTextField(190, 12, 30, 20, m_SettingsPanel)
		m_SettingsColorRTextbox = CreateTextField(80, 42, 30, 20, m_SettingsPanel)
		m_SettingsColorGTextbox = CreateTextField(135, 42, 30, 20, m_SettingsPanel)
		m_SettingsColorBTextbox = CreateTextField(190, 42, 30, 20, m_SettingsPanel)
		m_SettingsZoomLabel = CreateLabel("Zoom:", 10, 15, 50, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsFramesLabel = CreateLabel("Frames:", 120, 15, 50, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorLabel = CreateLabel("BG Color:", 10, 45, 50, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorRLabel = CreateLabel("R:", 65, 45, 50, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorGLabel = CreateLabel("G:", 120, 45, 50, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorBLabel = CreateLabel("B:", 175, 45, 50, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsIndexedLabel = CreateLabel("Save as Indexed Bitmap:", 10, 75, 130, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsIndexedCheckbox = CreateButton("", 140, 75, 15, 15, m_SettingsPanel, BUTTON_CHECKBOX)
		m_SettingsSaveAsFramesLabel = CreateLabel("Save as Frames:", 160, 75, 80, 20, m_SettingsPanel, LABEL_LEFT)
		m_SettingsSaveAsFramesCheckbox = CreateButton("", 250, 75, 15, 15, m_SettingsPanel, BUTTON_CHECKBOX)
		m_HelpPanel = CreatePanel(10, 203, 280, 250, m_Window, PANEL_GROUP, "  Help :  ")
		m_HelpTextbox = CreateTextArea(7, 5, GadgetWidth(m_HelpPanel) - 21, GadgetHeight(m_HelpPanel) - 32, m_HelpPanel, TEXTAREA_WORDWRAP | TEXTAREA_READONLY)
		'Populate textboxes
		SetGadgetText(m_SettingsZoomTextbox, GraphicsOutput.m_InputZoom)
		SetGadgetText(m_SettingsFramesTextbox, GraphicsOutput.m_Frames)
		SetGadgetText(m_SettingsColorRTextbox, GraphicsOutput.m_BackgroundRed)
		SetGadgetText(m_SettingsColorGTextbox, GraphicsOutput.m_BackgroundGreen)
		SetGadgetText(m_SettingsColorBTextbox, GraphicsOutput.m_BackgroundBlue)
		SetGadgetText(m_HelpTextbox, LoadText("Incbin::Assets/TextboxHelp"))
	EndFunction
EndType