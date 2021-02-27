Import MaxGUI.Drivers
Import BRL.GLMax2D
Import BRL.Vector
Import "Utility.bmx"

'//// USER INTERFACE ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type UserInterface
	Field m_MainWindow:TGadget

	Field m_LeftColumn:TGadget
	Field m_LeftColumnSize:SVec2I = New SVec2I(260, 480)

	'Canvas for graphics output
	Field m_CanvasGraphics:TGadget
	Field m_CanvasGraphicsAnchor:SVec2I = New SVec2I(m_LeftColumnSize[0], 0)
	Field m_CanvasGraphicsSize:SVec2I = New SVec2I(768, 480)

	'Title bar buttons
	Field m_HelpMenu:TGadget
	Field m_HelpMenuText:String = LoadText("Incbin::Assets/TextHelp")
	Const c_HelpMenuTag:Int = 100

	Field m_AboutMenu:TGadget
	Field m_AboutMenuText:String = LoadText("Incbin::Assets/TextAbout")
	Const c_AboutMenuTag:Int = 101

	Field m_ButtonPanel:TGadget
	Field m_ButtonPanelAnchor:SVec2I = New SVec2I(10, 5)
	Field m_ButtonPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 55)

	Field m_LoadButton:TGadget
	Field m_SaveButton:TGadget

	Field m_SettingsPanel:TGadget
	Field m_SettingsPanelAnchor:SVec2I = New SVec2I(10, m_ButtonPanelSize[1] + 15)
	Field m_SettingsPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 175)

	Field m_SettingsZoomLabel:TGadget
	Field m_SettingsZoomTextbox:TGadget

	Field m_SettingsFramesLabel:TGadget
	Field m_SettingsFramesTextbox:TGadget

	Field m_SettingsColorLabel:TGadget
	Field m_SettingsColorRLabel:TGadget
	Field m_SettingsColorRTextbox:TGadget
	Field m_SettingsColorGLabel:TGadget
	Field m_SettingsColorGTextbox:TGadget
	Field m_SettingsColorBLabel:TGadget
	Field m_SettingsColorBTextbox:TGadget

	Field m_SettingsIndexedLabel:TGadget
	Field m_SettingsIndexedCheckbox:TGadget

	Field m_SettingsSaveAsFramesLabel:TGadget
	Field m_SettingsSaveAsFramesCheckbox:TGadget

	Field m_LogoImage:TPixmap = LoadPixmap("Incbin::Assets/Logo")
	Field m_LogoImagePanel:TGadget
	Field m_LogoImagePanelAnchor:SVec2I = New SVec2I(0, m_LeftColumnSize[1] - m_LogoImage.Height)
	Field m_LogoImagePanelSize:SVec2I = New SVec2I(m_LogoImage.Width, m_LogoImage.Height)

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New(zoomValue:Int, framesValue:Int, bgRedValue:Int, bgGreenValue:Int, bgBlueValue:Int)
		InitializeUserInterface(zoomValue, framesValue, bgRedValue, bgGreenValue, bgBlueValue)
		InitializeCanvasGraphics()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method InitializeUserInterface(zoomValue:Int, framesValue:Int, bgRedValue:Int, bgGreenValue:Int, bgBlueValue:Int)
		m_MainWindow = CreateWindow(AppTitle, (DesktopWidth() / 2) - ((m_CanvasGraphicsAnchor[0] + m_CanvasGraphicsSize[0]) / 2), (DesktopHeight() / 2) - (m_CanvasGraphicsSize[1] / 2), m_CanvasGraphicsAnchor[0] + m_CanvasGraphicsSize[0], m_CanvasGraphicsSize[1], Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_CLIENTCOORDS | WINDOW_ACCEPTFILES)
		m_HelpMenu = CreateMenu("Help", c_HelpMenuTag, WindowMenu(m_MainWindow))
		m_AboutMenu = CreateMenu("About", c_AboutMenuTag, WindowMenu(m_MainWindow))
		UpdateWindowMenu(m_MainWindow)

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
		DisableGadget(m_SaveButton)

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

		m_LogoImagePanel = CreatePanel(m_LogoImagePanelAnchor[0], m_LogoImagePanelAnchor[1], m_LogoImagePanelSize[0], m_LogoImagePanelSize[1], m_LeftColumn, Null)
		SetPanelPixmap(m_LogoImagePanel, m_LogoImage, PANELPIXMAP_CENTER)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method InitializeCanvasGraphics()
		m_CanvasGraphics = CreateCanvas(m_CanvasGraphicsAnchor[0], m_CanvasGraphicsAnchor[1], GadgetWidth(m_MainWindow) - m_CanvasGraphicsAnchor[0], GadgetHeight(m_MainWindow) - m_CanvasGraphicsAnchor[1], m_MainWindow)
		SetGadgetLayout(m_CanvasGraphics, m_CanvasGraphicsAnchor[0], m_CanvasGraphicsSize[0], m_CanvasGraphicsAnchor[1], m_CanvasGraphicsSize[1])
		SetGraphicsDriver(GLMax2DDriver())
		SetGraphics(CanvasGraphics(m_CanvasGraphics))
		SetClsColor(GadgetText(m_SettingsColorRTextbox).ToInt(), GadgetText(m_SettingsColorGTextbox).ToInt(), GadgetText(m_SettingsColorBTextbox).ToInt())
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method ProcessWindowResize()
		ResizeGadget(m_LeftColumn, GadgetWidth(m_LeftColumn), GadgetHeight(m_MainWindow))
		MoveGadget(m_LogoImagePanel, 0, GadgetHeight(m_MainWindow) - m_LogoImagePanelSize[1])

		'Have to recreate the canvas because resizing vertically shifts the origin point and no obvious way to reset it
		FreeGadget(m_CanvasGraphics)
		InitializeCanvasGraphics()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetColorTextboxValues:Int[]()
		Return [	.. 'Line continuation
			Utility.Clamp(GadgetText(m_SettingsColorRTextbox).ToInt(), 0, 255),	..
			Utility.Clamp(GadgetText(m_SettingsColorGTextbox).ToInt(), 0, 255),	..
			Utility.Clamp(GadgetText(m_SettingsColorBTextbox).ToInt(), 0, 255)	..
		]
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetColorTextboxValues(newTextValues:Int[])
		SetGadgetText(m_SettingsColorRTextbox, newTextValues[0])
		SetGadgetText(m_SettingsColorGTextbox, newTextValues[1])
		SetGadgetText(m_SettingsColorBTextbox, newTextValues[2])
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetFramesTextboxValue:Int()
		Return GadgetText(m_SettingsFramesTextbox).ToInt()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetFramesTextboxValue(newValue:Int)
		SetGadgetText(m_SettingsFramesTextbox, newValue)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetZoomTextboxValue:Int()
		Return GadgetText(m_SettingsZoomTextbox).ToInt()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetZoomTextboxValue(newValue:Int)
		SetGadgetText(m_SettingsZoomTextbox, newValue)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method MoveGadget(gadgetToMove:TGadget, newPosX:Int, newPosY:Int)
		SetGadgetShape(gadgetToMove, newPosX, newPosY, GadgetWidth(gadgetToMove), GadgetHeight(gadgetToMove))
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method ResizeGadget(gadgetToResize:TGadget, newWidth:Int, newHeight:Int)
		SetGadgetShape(gadgetToResize, GadgetX(gadgetToResize), GadgetY(gadgetToResize), newWidth, newHeight)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetMaxWorkspaceWidth:Int()
		Return DesktopWidth() - m_LeftColumnSize[0]
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetSaveButtonEnabled(enabledOrNot:Int)
		If enabledOrNot Then
			EnableGadget(m_SaveButton)
		Else
			DisableGadget(m_SaveButton)
		EndIf
	EndMethod
EndType