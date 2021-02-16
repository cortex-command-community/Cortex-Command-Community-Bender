'//// USER INTERFACE ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type UserInterface
	Global m_MainWindow:TGadget

	Global m_LeftColumn:TGadget
	Global m_LeftColumnSize:SVec2I = New SVec2I(260, 480)

	'Canvas for graphics output
	Global m_CanvasGraphics:TGadget
	Global m_CanvasGraphicsAnchor:SVec2I = New SVec2I(m_LeftColumnSize[0], 0)
	Global m_CanvasGraphicsSize:SVec2I = New SVec2I(768, 480)

	'Title bar buttons
	Global m_HelpMenu:TGadget
	Global m_HelpMenuText:String = LoadText("Incbin::Assets/TextHelp")
	Const c_HelpMenuTag:Int = 100

	Global m_AboutMenu:TGadget
	Global m_AboutMenuText:String = LoadText("Incbin::Assets/TextAbout")
	Const c_AboutMenuTag:Int = 101

	Global m_ButtonPanel:TGadget
	Global m_ButtonPanelAnchor:SVec2I = New SVec2I(10, 5)
	Global m_ButtonPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 55)

	Global m_LoadButton:TGadget
	Global m_SaveButton:TGadget

	Global m_SettingsPanel:TGadget
	Global m_SettingsPanelAnchor:SVec2I = New SVec2I(10, m_ButtonPanelSize[1] + 15)
	Global m_SettingsPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 175)

	Global m_SettingsZoomLabel:TGadget
	Global m_SettingsZoomTextbox:TGadget

	Global m_SettingsFramesLabel:TGadget
	Global m_SettingsFramesTextbox:TGadget

	Global m_SettingsColorLabel:TGadget
	Global m_SettingsColorRLabel:TGadget
	Global m_SettingsColorRTextbox:TGadget
	Global m_SettingsColorGLabel:TGadget
	Global m_SettingsColorGTextbox:TGadget
	Global m_SettingsColorBLabel:TGadget
	Global m_SettingsColorBTextbox:TGadget

	Global m_SettingsIndexedLabel:TGadget
	Global m_SettingsIndexedCheckbox:TGadget

	Global m_SettingsSaveAsFramesLabel:TGadget
	Global m_SettingsSaveAsFramesCheckbox:TGadget

	'Bool For Quitting
	Global m_QuitResult:Int = False

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method MoveGadget(gadgetToMove:TGadget, newPosX:Int, newPosY:Int)
		SetGadgetShape(gadgetToMove, newPosX, newPosY, GadgetWidth(gadgetToMove), GadgetHeight(gadgetToMove))
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method ResizeGadget(gadgetToResize:TGadget, newWidth:Int, newHeight:Int)
		SetGadgetShape(gadgetToResize, GadgetX(gadgetToResize), GadgetY(gadgetToResize), newWidth, newHeight)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function InitializeUserInterface(zoomValue:Int, framesValue:Int, bgRedValue:Int, bgGreenValue:Int, bgBlueValue:Int)
		m_MainWindow = CreateWindow(AppTitle, (DesktopWidth() / 2) - ((m_CanvasGraphicsAnchor[0] + m_CanvasGraphicsSize[0]) / 2), (DesktopHeight() / 2) - (m_CanvasGraphicsSize[1] / 2), m_CanvasGraphicsAnchor[0] + m_CanvasGraphicsSize[0], m_CanvasGraphicsSize[1], Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_CLIENTCOORDS)
		m_HelpMenu = CreateMenu("Help", c_HelpMenuTag, WindowMenu(m_MainWindow))
		m_AboutMenu = CreateMenu("About", c_AboutMenuTag, WindowMenu(m_MainWindow))

		m_LeftColumn = CreatePanel(0, 0, m_LeftColumnSize[0], m_LeftColumnSize[1], m_MainWindow, Null)
		SetGadgetLayout(m_LeftColumn, 0, m_LeftColumnSize[0], 0, m_LeftColumnSize[1])

		Local horizMargin:Int = 5
		Local vertMargin:Int = 10
		Local labelHeight:Int = 20
		Local labelVertOffset:Int = vertMargin + labelHeight
		Local textboxVertOffset:Int = -3
		Local textboxSize:SVec2I = New SVec2I(30, 22)
		Local buttonSize:SVec2I = New SVec2I(105, 28)

		m_ButtonPanel = CreatePanel(m_ButtonPanelAnchor[0], m_ButtonPanelAnchor[1], m_ButtonPanelSize[0], m_ButtonPanelSize[1], m_LeftColumn, PANEL_GROUP)
		SetGadgetLayout(m_ButtonPanel, m_ButtonPanelAnchor[0], m_ButtonPanelSize[0], m_ButtonPanelAnchor[1], m_ButtonPanelSize[1])

		m_LoadButton = CreateButton("Load", horizMargin, 0, buttonSize[0], buttonSize[1], m_ButtonPanel, BUTTON_PUSH)
		m_SaveButton = CreateButton("Save", horizMargin + buttonSize[0] + vertMargin, 0, buttonSize[0], buttonSize[1], m_ButtonPanel, BUTTON_PUSH)

		m_SettingsPanel = CreatePanel(m_SettingsPanelAnchor[0], m_SettingsPanelAnchor[1], m_SettingsPanelSize[0], m_SettingsPanelSize[1], m_LeftColumn, PANEL_GROUP, "  Settings :  ")
		SetGadgetLayout(m_SettingsPanel, m_SettingsPanelAnchor[0], m_SettingsPanelSize[0], m_SettingsPanelAnchor[1], m_SettingsPanelSize[1])

		m_SettingsColorLabel = CreateLabel("BG Color", horizMargin, vertMargin, 50, labelHeight, m_SettingsPanel, LABEL_LEFT)

		m_SettingsColorRLabel = CreateLabel("R", GadgetWidth(m_SettingsColorLabel) + 15, GadgetY(m_SettingsColorLabel), 10, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorRTextbox = CreateTextField(GadgetX(m_SettingsColorRLabel) + 15, GadgetY(m_SettingsColorRLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsColorRTextbox, bgRedValue)

		m_SettingsColorGLabel = CreateLabel("G", 120, GadgetY(m_SettingsColorLabel), 10, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorGTextbox = CreateTextField(135, GadgetY(m_SettingsColorGLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsColorGTextbox, bgGreenValue)

		m_SettingsColorBLabel = CreateLabel("B", 175, GadgetY(m_SettingsColorLabel), 10, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorBTextbox = CreateTextField(190, GadgetY(m_SettingsColorBLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsColorBTextbox, bgBlueValue)

		m_SettingsZoomLabel = CreateLabel("Input Zoom", horizMargin, GadgetY(m_SettingsColorLabel) + labelVertOffset, 70, labelHeight + 4, m_SettingsPanel, LABEL_LEFT)
		m_SettingsZoomTextbox = CreateTextField(vertMargin + GadgetWidth(m_SettingsZoomLabel), GadgetY(m_SettingsZoomLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsZoomTextbox, zoomValue)

		m_SettingsFramesLabel = CreateLabel("Frame Count", horizMargin, GadgetY(m_SettingsZoomLabel) + labelVertOffset, 70, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsFramesTextbox = CreateTextField(vertMargin + GadgetWidth(m_SettingsFramesLabel), GadgetY(m_SettingsFramesLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsFramesTextbox, framesValue)

		m_SettingsSaveAsFramesLabel = CreateLabel("Save as Frames", horizMargin, GadgetY(m_SettingsFramesLabel) + labelVertOffset, 87, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsSaveAsFramesCheckbox = CreateButton(Null, vertMargin + GadgetWidth(m_SettingsSaveAsFramesLabel), GadgetY(m_SettingsSaveAsFramesLabel), 20, 20, m_SettingsPanel, BUTTON_CHECKBOX)

		m_SettingsIndexedLabel = CreateLabel("Save as Indexed", horizMargin, GadgetY(m_SettingsSaveAsFramesLabel) + labelVertOffset, 87, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsIndexedCheckbox = CreateButton(Null, vertMargin + GadgetWidth(m_SettingsIndexedLabel), GadgetY(m_SettingsIndexedLabel), 20, 20, m_SettingsPanel, BUTTON_CHECKBOX)

		'Initialize canvas graphics
		m_CanvasGraphics = CreateCanvas(m_CanvasGraphicsAnchor[0], m_CanvasGraphicsAnchor[1], m_CanvasGraphicsSize[0], m_CanvasGraphicsSize[1], m_MainWindow)
		SetGadgetLayout(m_CanvasGraphics, m_CanvasGraphicsAnchor[0], m_CanvasGraphicsSize[0], m_CanvasGraphicsAnchor[1], m_CanvasGraphicsSize[1])
		SetGraphicsDriver GLMax2DDriver()
		SetGraphics CanvasGraphics(m_CanvasGraphics)

		UpdateWindowMenu(m_MainWindow)
		EnablePolledInput()
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function ProcessWindowResize()
		FreeGadget(m_CanvasGraphics)
		m_CanvasGraphics = CreateCanvas(m_CanvasGraphicsAnchor[0], m_CanvasGraphicsAnchor[1], GadgetWidth(m_MainWindow) - m_CanvasGraphicsAnchor[0], GadgetHeight(m_MainWindow) - m_CanvasGraphicsAnchor[1], m_MainWindow)
		SetGadgetLayout(m_CanvasGraphics, m_CanvasGraphicsAnchor[0], GadgetWidth(m_MainWindow), m_CanvasGraphicsAnchor[1], GadgetHeight(m_MainWindow))
		SetGraphicsDriver GLMax2DDriver()
		SetGraphics CanvasGraphics(m_CanvasGraphics)
	EndFunction

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Function HandleEvents(eventID:Int)
		Select eventID
			Case EVENT_APPRESUME
				ActivateWindow(m_MainWindow)
			Case EVENT_WINDOWSIZE
				ProcessWindowResize()
			Case EVENT_MENUACTION
				Select EventData()
					Case c_HelpMenuTag
						Notify(m_HelpMenuText, False)
					Case c_AboutMenuTag
						Notify(m_AboutMenuText, False)
				EndSelect
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				m_QuitResult = Confirm("Quit program?")
		EndSelect

		If m_QuitResult Then End
	EndFunction
EndType