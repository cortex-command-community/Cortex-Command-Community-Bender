Import MaxGUI.Drivers
Import BRL.GLMax2D
Import BRL.Vector
Import "Utility.bmx"

'//// USER INTERFACE ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type UserInterface
	Field m_MainWindow:TGadget = Null

	Field m_LeftColumn:TGadget = Null
	Field m_LeftColumnSize:SVec2I = New SVec2I(260, 480)

	'Canvas for graphics output
	Field m_CanvasGraphics:TGadget = Null
	Field m_CanvasGraphicsAnchor:SVec2I = New SVec2I(m_LeftColumnSize[0], 0)
	Field m_CanvasGraphicsSize:SVec2I = New SVec2I(768, 480)

	'Title bar buttons
	Field m_HelpMenu:TGadget = Null
	Field m_HelpMenuText:String = LoadText("Incbin::Assets/TextHelp")
	Const c_HelpMenuTag:Int = 100

	Field m_AboutMenu:TGadget = Null
	Field m_AboutMenuText:String = LoadText("Incbin::Assets/TextAbout")
	Const c_AboutMenuTag:Int = 101

	Field m_ButtonPanel:TGadget = Null
	Field m_ButtonPanelAnchor:SVec2I = New SVec2I(10, 5)
	Field m_ButtonPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 55)

	Field m_LoadButton:TGadget = Null
	Field m_SaveButton:TGadget = Null

	Field m_SettingsPanel:TGadget = Null
	Field m_SettingsPanelAnchor:SVec2I = New SVec2I(10, m_ButtonPanelSize[1] + 15)
	Field m_SettingsPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 180)

	Field m_SettingsInputZoomLabel:TGadget = Null
	Field m_SettingsInputZoomTextbox:TGadget = Null
	Field m_SettingsOutputZoomLabel:TGadget = Null
	Field m_SettingsOutputZoomTextbox:TGadget = Null

	Field m_SettingsFramesLabel:TGadget = Null
	Field m_SettingsFramesTextbox:TGadget = Null

	Field m_SettingsColorLabel:TGadget = Null
	Field m_SettingsColorRLabel:TGadget = Null
	Field m_SettingsColorRTextbox:TGadget = Null
	Field m_SettingsColorGLabel:TGadget = Null
	Field m_SettingsColorGTextbox:TGadget = Null
	Field m_SettingsColorBLabel:TGadget = Null
	Field m_SettingsColorBTextbox:TGadget = Null

	Field m_SettingsIndexedLabel:TGadget = Null
	Field m_SettingsIndexedCheckbox:TGadget = Null
	Field m_SettingsIndexedFileTypeComboBox:TGadget = Null

	Field m_SettingsSaveAsFramesLabel:TGadget = Null
	Field m_SettingsSaveAsFramesCheckbox:TGadget = Null

	Field m_LayeringPanel:TGadget = Null
	Field m_LayeringPanelAnchor:SVec2I = New SVec2I(10, m_ButtonPanelSize[1] + m_SettingsPanelSize[1] + 25)
	Field m_LayeringPanelSize:SVec2I = New SVec2I(m_CanvasGraphicsAnchor[0] - 20, 150)

	Field m_LayeringArmFGCheckbox:TGadget = Null
	Field m_LayeringArmBGCheckbox:TGadget = Null
	Field m_LayeringLegFGCheckbox:TGadget = Null
	Field m_LayeringLegBGCheckbox:TGadget = Null

	Field m_LogoImage:TPixmap = LoadPixmap("Incbin::Assets/Logo")
	Field m_LogoImagePanel:TGadget = Null
	Field m_LogoImagePanelAnchor:SVec2I = New SVec2I(0, m_LeftColumnSize[1] - m_LogoImage.Height)
	Field m_LogoImagePanelSize:SVec2I = New SVec2I(m_LogoImage.Width, m_LogoImage.Height)

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New(inputZoomValue:Int, outputZoomValue:Int, framesValue:Int, bgRedValue:Int, bgGreenValue:Int, bgBlueValue:Int)
		InitializeUserInterface(inputZoomValue, outputZoomValue, framesValue, bgRedValue, bgGreenValue, bgBlueValue)
		InitializeCanvasGraphics()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method InitializeUserInterface(inputZoomValue:Int, outputZoomValue:Int, framesValue:Int, bgRedValue:Int, bgGreenValue:Int, bgBlueValue:Int)
		m_MainWindow = CreateWindow(AppTitle, (DesktopWidth() / 2) - ((m_CanvasGraphicsAnchor[0] + m_CanvasGraphicsSize[0]) / 2), (DesktopHeight() / 2) - (m_CanvasGraphicsSize[1] / 2), m_CanvasGraphicsAnchor[0] + m_CanvasGraphicsSize[0], m_CanvasGraphicsSize[1], Null, WINDOW_TITLEBAR | WINDOW_MENU | WINDOW_RESIZABLE | WINDOW_CLIENTCOORDS | WINDOW_ACCEPTFILES)
		m_HelpMenu = CreateMenu("Help", c_HelpMenuTag, WindowMenu(m_MainWindow))
		m_AboutMenu = CreateMenu("About", c_AboutMenuTag, WindowMenu(m_MainWindow))
		UpdateWindowMenu(m_MainWindow)

		m_LeftColumn = CreatePanel(0, 0, m_LeftColumnSize[0], m_LeftColumnSize[1], m_MainWindow, Null)
		SetGadgetLayout(m_LeftColumn, 0, m_LeftColumnSize[0], 0, m_LeftColumnSize[1])
		SetGadgetSensitivity(m_LeftColumn, SENSITIZE_KEYS)

		Local horizMargin:Int = 5
		Local vertMargin:Int = 10
		Local labelHeight:Int = 20
		Local labelVertOffset:Int = vertMargin + labelHeight
		Local textboxVertOffset:Int = -3
		Local textboxSize:SVec2I = New SVec2I(30, 22)
		Local buttonSize:SVec2I = New SVec2I(105, 28)

		m_ButtonPanel = CreatePanel(m_ButtonPanelAnchor[0], m_ButtonPanelAnchor[1], m_ButtonPanelSize[0], m_ButtonPanelSize[1], m_LeftColumn, PANEL_GROUP)
		SetGadgetLayout(m_ButtonPanel, m_ButtonPanelAnchor[0], m_ButtonPanelSize[0], m_ButtonPanelAnchor[1], m_ButtonPanelSize[1])
		SetGadgetSensitivity(m_ButtonPanel, SENSITIZE_KEYS)

		m_LoadButton = CreateButton("Load", horizMargin, 0, buttonSize[0], buttonSize[1], m_ButtonPanel, BUTTON_PUSH)
		m_SaveButton = CreateButton("Save", horizMargin + buttonSize[0] + vertMargin, 0, buttonSize[0], buttonSize[1], m_ButtonPanel, BUTTON_PUSH)
		DisableGadget(m_SaveButton)

		m_SettingsPanel = CreatePanel(m_SettingsPanelAnchor[0], m_SettingsPanelAnchor[1], m_SettingsPanelSize[0], m_SettingsPanelSize[1], m_LeftColumn, PANEL_GROUP, "  Settings :  ")
		SetGadgetLayout(m_SettingsPanel, m_SettingsPanelAnchor[0], m_SettingsPanelSize[0], m_SettingsPanelAnchor[1], m_SettingsPanelSize[1])
		SetGadgetSensitivity(m_SettingsPanel, SENSITIZE_KEYS)

		m_SettingsColorLabel = CreateLabel("BG Color", horizMargin, vertMargin, 50, labelHeight, m_SettingsPanel, LABEL_LEFT)

		m_SettingsColorRLabel = CreateLabel("R", GadgetWidth(m_SettingsColorLabel) + 15, GadgetY(m_SettingsColorLabel), 10, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorRTextbox = CreateTextField(GadgetX(m_SettingsColorRLabel) + 15, GadgetY(m_SettingsColorRLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsColorRTextbox, bgRedValue)

		m_SettingsColorGLabel = CreateLabel("G", 122, GadgetY(m_SettingsColorLabel), 10, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorGTextbox = CreateTextField(137, GadgetY(m_SettingsColorGLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsColorGTextbox, bgGreenValue)

		m_SettingsColorBLabel = CreateLabel("B", 180, GadgetY(m_SettingsColorLabel), 10, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsColorBTextbox = CreateTextField(195, GadgetY(m_SettingsColorBLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsColorBTextbox, bgBlueValue)

		m_SettingsInputZoomLabel = CreateLabel("Input Zoom", horizMargin, GadgetY(m_SettingsColorLabel) + labelVertOffset, 70, labelHeight + 4, m_SettingsPanel, LABEL_LEFT)
		m_SettingsInputZoomTextbox = CreateTextField(vertMargin + GadgetWidth(m_SettingsInputZoomLabel), GadgetY(m_SettingsInputZoomLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsInputZoomTextbox, inputZoomValue)

		m_SettingsOutputZoomLabel = CreateLabel("Output Zoom", 117, GadgetY(m_SettingsInputZoomLabel), 75, labelHeight + 4, m_SettingsPanel, LABEL_LEFT)
		m_SettingsOutputZoomTextbox = CreateTextField(horizMargin + GadgetX(m_SettingsOutputZoomLabel) + GadgetWidth(m_SettingsOutputZoomLabel) - 2, GadgetY(m_SettingsOutputZoomLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsOutputZoomTextbox, outputZoomValue)

		m_SettingsFramesLabel = CreateLabel("Frame Count", horizMargin, GadgetY(m_SettingsInputZoomLabel) + labelVertOffset, 70, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsFramesTextbox = CreateTextField(vertMargin + GadgetWidth(m_SettingsFramesLabel), GadgetY(m_SettingsFramesLabel) + textboxVertOffset, textboxSize[0], textboxSize[1], m_SettingsPanel)
		SetGadgetText(m_SettingsFramesTextbox, framesValue)

		m_SettingsSaveAsFramesLabel = CreateLabel("Save as Frames", horizMargin, GadgetY(m_SettingsFramesLabel) + labelVertOffset, 87, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsSaveAsFramesCheckbox = CreateButton(Null, vertMargin + GadgetWidth(m_SettingsSaveAsFramesLabel), GadgetY(m_SettingsSaveAsFramesLabel), 20, 20, m_SettingsPanel, BUTTON_CHECKBOX)

		m_SettingsIndexedLabel = CreateLabel("Save as Indexed", horizMargin, GadgetY(m_SettingsSaveAsFramesLabel) + labelVertOffset, 87, labelHeight, m_SettingsPanel, LABEL_LEFT)
		m_SettingsIndexedCheckbox = CreateButton(Null, vertMargin + GadgetWidth(m_SettingsIndexedLabel), GadgetY(m_SettingsIndexedLabel), 20, 20, m_SettingsPanel, BUTTON_CHECKBOX)
		m_SettingsIndexedFileTypeComboBox = CreateComboBox(120, GadgetY(m_SettingsIndexedLabel) - 3, 50, 15, m_SettingsPanel)
		AddGadgetItem(m_SettingsIndexedFileTypeComboBox, "PNG", GADGETITEM_DEFAULT)
		AddGadgetItem(m_SettingsIndexedFileTypeComboBox, "BMP", GADGETITEM_NORMAL)
		HideGadget(m_SettingsIndexedFileTypeComboBox)

		m_LayeringPanel = CreatePanel(m_LayeringPanelAnchor[0], m_LayeringPanelAnchor[1], m_LayeringPanelSize[0], m_LayeringPanelSize[1], m_LeftColumn, PANEL_GROUP, "  Layering Controls :  ")
		SetGadgetLayout(m_LayeringPanel, m_LayeringPanelAnchor[0], m_LayeringPanelSize[0], m_LayeringPanelAnchor[1], m_LayeringPanelSize[1])
		SetGadgetSensitivity(m_LayeringPanel, SENSITIZE_KEYS)

		m_LayeringArmFGCheckbox = CreateButton(" Arm FG  —  Lower Arm on top", horizMargin, vertMargin, m_LayeringPanelSize[0] - 20, 20, m_LayeringPanel, BUTTON_CHECKBOX)
		m_LayeringArmBGCheckbox = CreateButton(" Arm BG  —  Lower Arm on top", horizMargin, GadgetY(m_LayeringArmFGCheckbox) + labelVertOffset, m_LayeringPanelSize[0] - 20, 20, m_LayeringPanel, BUTTON_CHECKBOX)
		m_LayeringLegFGCheckbox = CreateButton(" Leg FG  —  Lower Leg on top", horizMargin, GadgetY(m_LayeringArmBGCheckbox) + labelVertOffset, m_LayeringPanelSize[0] - 20, 20, m_LayeringPanel, BUTTON_CHECKBOX)
		m_LayeringLegBGCheckbox = CreateButton(" Leg BG  —  Lower Leg on top", horizMargin, GadgetY(m_LayeringLegFGCheckbox) + labelVertOffset, m_LayeringPanelSize[0] - 20, 20, m_LayeringPanel, BUTTON_CHECKBOX)

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

	Method GetInputZoomTextboxValue:Int()
		Return GadgetText(m_SettingsInputZoomTextbox).ToInt()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetInputZoomTextboxValue(newValue:Int)
		SetGadgetText(m_SettingsInputZoomTextbox, newValue)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetOutputZoomTextboxValue:Int()
		Return GadgetText(m_SettingsOutputZoomTextbox).ToInt()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetOutputZoomTextboxValue(newValue:Int)
		SetGadgetText(m_SettingsOutputZoomTextbox, newValue)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method GetLayerCheckboxValues:Int[,]()
		Local checkboxValues:Int[4, 1]
		checkboxValues[0, 0] = ButtonState(m_LayeringArmFGCheckbox)
		checkboxValues[1, 0] = ButtonState(m_LayeringArmBGCheckbox)
		checkboxValues[2, 0] = ButtonState(m_LayeringLegFGCheckbox)
		checkboxValues[3, 0] = ButtonState(m_LayeringLegBGCheckbox)
		Return checkboxValues
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetLayerCheckboxLabels:Int[,](checkboxValues:Int[,])
		If checkboxValues[0, 0] = False Then
			SetGadgetText(m_LayeringArmFGCheckbox, " Arm FG  —  Lower Arm on top")
		Else
			SetGadgetText(m_LayeringArmFGCheckbox, " Arm FG  —  Upper Arm on top")
		EndIf
		If checkboxValues[1, 0] = False Then
			SetGadgetText(m_LayeringArmBGCheckbox, " Arm BG  —  Lower Arm on top")
		Else
			SetGadgetText(m_LayeringArmBGCheckbox, " Arm BG  —  Upper Arm on top")
		EndIf
		If checkboxValues[2, 0] = False Then
			SetGadgetText(m_LayeringLegFGCheckbox, " Leg FG  —  Lower Leg on top")
		Else
			SetGadgetText(m_LayeringLegFGCheckbox, " Leg FG  —  Upper Leg on top")
		EndIf
		If checkboxValues[3, 0] = False Then
			SetGadgetText(m_LayeringLegBGCheckbox, " Leg BG  —  Lower Leg on top")
		Else
			SetGadgetText(m_LayeringLegBGCheckbox, " Leg BG  —  Upper Leg on top")
		EndIf
		Return checkboxValues
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

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method SetFileTypeComboBoxVisible(visibleOrNot:Int)
		If visibleOrNot Then
			ShowGadget(m_SettingsIndexedFileTypeComboBox)
		Else
			HideGadget(m_SettingsIndexedFileTypeComboBox)
		EndIf
	EndMethod
EndType