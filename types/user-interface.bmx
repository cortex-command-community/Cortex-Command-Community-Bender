Rem
------- GUI ELEMENTS --------------------------------------------------------------------------------------------------
EndRem

'Bool For Quitting
Global quitResult:Int = False

Type TAppGUI

	'About menu event tag
	Const ABOUT_MENU:Int = 100

	'Editor Window
	Global editWindow:TGadget
	'Editor Window about menu
	Global editAboutMenu:TGadget
	'Editor Window Canvas Graphics
	Global editCanvas:TGadget
	'Editor Window Buttons
	Global editWindowButtonPanel:TGadget
	Global editLoadButton:TGadget
	Global editSaveButton:TGadget
	Global editQuitButton:TGadget
	'Editor Window Settings
	Global editSettingsPanel:TGadget
	Global editSettingsZoomTextbox:TGadget
	Global editSettingsFramesTextbox:TGadget
	Global editSettingsColorRTextbox:TGadget
	Global editSettingsColorGTextbox:TGadget
	Global editSettingsColorBTextbox:TGadget
	Global editSettingsZoomLabel:TGadget
	Global editSettingsFramesLabel:TGadget
	Global editSettingsColorLabel:TGadget
	Global editSettingsColorRLabel:TGadget
	Global editSettingsColorGLabel:TGadget
	Global editSettingsColorBLabel:TGadget
	Global editSettingsIndexedLabel:TGadget
	Global editSettingsIndexedCheckbox:TGadget
	'Editor Window Help
	Global editHelpPanel:TGadget
	Global editHelpTextbox:TGadget
	
	'Create Editor Window
	Function FAppEditor()
		EnablePolledInput()
		editWindow = CreateWindow("CCCP Bender v"+appversion+" - Editor",DesktopWidth()/2-700,DesktopHeight()/2-240,300+768,430+50,Null,WINDOW_TITLEBAR|WINDOW_MENU|WINDOW_CLIENTCOORDS)
		editCanvas = CreateCanvas(300,0,768,480,editWindow)
		editAboutMenu = CreateMenu("About",ABOUT_MENU,WindowMenu(editWindow))
		UpdateWindowMenu(editWindow)
		editWindowButtonPanel = CreatePanel(10,7,280,57,editWindow,PANEL_GROUP)	
		editLoadButton = CreateButton("Load",6,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editSaveButton = CreateButton("Save",96,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editQuitButton = CreateButton("Quit",186,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editSettingsPanel = CreatePanel(10,73,280,120,editWindow,PANEL_GROUP,"  Settings :  ")
		editSettingsZoomTextbox = CreateTextField(80,12,30,20,editSettingsPanel)
		editSettingsFramesTextbox = CreateTextField(190,12,30,20,editSettingsPanel)
		editSettingsColorRTextbox = CreateTextField(80,42,30,20,editSettingsPanel)
		editSettingsColorGTextbox = CreateTextField(135,42,30,20,editSettingsPanel)
		editSettingsColorBTextbox = CreateTextField(190,42,30,20,editSettingsPanel)
		editSettingsZoomLabel = CreateLabel("Zoom:",10,15,50,20,editSettingsPanel,LABEL_LEFT)
		editSettingsFramesLabel = CreateLabel("Frames:",120,15,50,20,editSettingsPanel,LABEL_LEFT)
		editSettingsColorLabel = CreateLabel("BG Color:",10,45,50,20,editSettingsPanel,LABEL_LEFT)
		editSettingsColorRLabel = CreateLabel("R:",65,45,50,20,editSettingsPanel,LABEL_LEFT)
		editSettingsColorGLabel = CreateLabel("G:",120,45,50,20,editSettingsPanel,LABEL_LEFT)
		editSettingsColorBLabel = CreateLabel("B:",175,45,50,20,editSettingsPanel,LABEL_LEFT)
		editSettingsIndexedLabel = CreateLabel("Save as Indexed Bitmap:",10,75,130,20,editSettingsPanel,LABEL_LEFT)
		editSettingsIndexedCheckbox = CreateButton("",140,73,20,20,editSettingsPanel,BUTTON_CHECKBOX)
		editHelpPanel = CreatePanel(10,203,280,250,editWindow,PANEL_GROUP,"  Help :  ")
		editHelpTextbox = CreateTextArea(7,5,GadgetWidth(editHelpPanel)-21,GadgetHeight(editHelpPanel)-32,editHelpPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
		'Populate textboxes
		SetGadgetText(editSettingsZoomTextbox,TAppOutput.INPUTZOOM)
		SetGadgetText(editSettingsFramesTextbox,TAppOutput.FRAMES)
		SetGadgetText(editSettingsColorRTextbox,TAppOutput.BACKGROUND_RED)
		SetGadgetText(editSettingsColorGTextbox,TAppOutput.BACKGROUND_GREEN)
		SetGadgetText(editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE)
		SetGadgetText(editHelpTextbox,LoadText("Incbin::assets/help-textbox-content"))
	EndFunction
EndType