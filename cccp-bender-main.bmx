Rem
	---------------------------------------------------------------
			CORTEX COMMAND COMMUNITY PROJECT BENDER v0.1 :
	---------------------------------------------------------------
		TBA
EndRem

Strict

Import MaxGUI.Drivers
Import BRL.FileSystem

AppTitle = "CCCP Bender v0.1"

'App quitting bool
Global quitResult = False

'File I/O
Global importedFile:String = Null
Global fileFilers:String = "Image Files:png,jpg,bmp"

'Output Settings
Global SCALE:String = "1"
Global FRAMES:String = "7"
Global BACKGROUND_RED:String = "255"
Global BACKGROUND_GREEN:String = "200"
Global BACKGROUND_BLUE:String = "255"

'GUI Elements
Type TAppGUI
	'Main Window
	Global mainWindow:TGadget
	Global mainWindowButtonPanel:TGadget
	Global mainLoadButton:TGadget
	Global mainQuitButton:TGadget
	'Main Window About Panel
	Global mainAboutPanel:TGadget
	Global mainAboutTextbox:TGadget
	
	'Main Window Label
	'Global mainWindowLabel:TGadget
	
	'Workspace Window
	Global workWindow:TGadget
	Global workWindowButtonPanel:TGadget
	Global workLoadButton:TGadget
	Global workSaveButton:TGadget
	Global workQuitButton:TGadget
	'Workspace Window Settings Panel
	Global settingsPalel:TGadget
	Global settingsScaleTextbox:TGadget
	Global settingFramesTextbox:TGadget
	Global settingsColorRTextbox:TGadget
	Global settingsColorGTextbox:TGadget
	Global settingsColorBTextbox:TGadget	
	Global settingsScaleLabel:TGadget
	Global settingsFramesLabel:TGadget
	Global settingsColorLabel:TGadget
	Global settingsColorRLabel:TGadget
	Global settingsColorGLabel:TGadget
	Global settingsColorBLabel:TGadget
	'Workspace Window Instructions Panel
	Global workHelpPanel:TGadget
	Global workHelpTextbox:TGadget
	
	'Tansition between windows bool
	Global mainToWork = False
	
	'Transition between windows
	Function FAppUpdate()
		If mainToWork = False
			If importedFile <> Null Then
				FAppWork()
				mainToWork = True
			EndIf
		EndIf
	EndFunction
EndType

FAppMain()

Function FAppMain()
	'Create main app window
	TAppGUI.mainWindow = CreateWindow("CCCP Bender v0.1",DesktopWidth()/2-150,DesktopHeight()/2-180,300,360,Null,WINDOW_TITLEBAR)
	
	'TAppGUI.mainWindowLabel = CreateLabel("",0,0,GadgetWidth(TAppGUI.mainWindow),100,TAppGUI.mainWindow,LABEL_LEFT)
	
	TAppGUI.mainWindowButtonPanel = CreatePanel(GadgetWidth(TAppGUI.mainWindow)/2-80,10,150,97,TAppGUI.mainWindow,PANEL_GROUP)
	TAppGUI.mainLoadButton = CreateButton("Load Sprite",GadgetWidth(TAppGUI.mainWindowButtonPanel)/2-70,0,130,30,TAppGUI.mainWindowButtonPanel,BUTTON_PUSH)
	TAppGUI.mainQuitButton = CreateButton("Quit",GadgetWidth(TAppGUI.mainWindowButtonPanel)/2-70,40,130,30,TAppGUI.mainWindowButtonPanel,BUTTON_PUSH)
	TAppGUI.mainAboutPanel = CreatePanel(GadgetWidth(TAppGUI.mainWindow)/2-143,125,280,200,TAppGUI.mainWindow,PANEL_GROUP,"  About :  ")
	TAppGUI.mainAboutTextbox = CreateTextArea(5,5,GadgetWidth(TAppGUI.mainAboutPanel)-20,GadgetHeight(TAppGUI.mainAboutPanel)-30,TAppGUI.mainAboutPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
	'About textbox content
	SetGadgetText(TAppGUI.mainAboutTextbox,"Welcome to the CCCP Bender utility!~n~nIt's purpose is to make the life of modders easier by automagically generating bent limb frames.~n~nThe CC Bender was originally created by Arne Jansson (AndroidArts), the man behind all the Cortex Command artwork.~nThe CCCommunityProject Bender, however, is a brand new tool that allows more control and convenience For the modder (hopefully).~n~nThis tool utilizes Arne's original limb bend code, but also allows loading and saving sprites, along with other settings.~n~nCreated by MaximDude using BlitzMax MaxIDE 1.52~nCCCP Bender version 0.1 - 17 Aug 2019")
EndFunction	
	
Function FAppWork()
	'Create workspace window
	TAppGUI.workWindow = CreateWindow("CCCP Bender v0.1 - Editor",DesktopWidth()/2-152,DesktopHeight()/2-222,305,455,Null,WINDOW_TITLEBAR)	
	TAppGUI.workWindowButtonPanel = CreatePanel(10,7,280,57,TAppGUI.workWindow,PANEL_GROUP)	
	TAppGUI.workLoadButton = CreateButton("Load",5,0,80,30,TAppGUI.workWindowButtonPanel,BUTTON_PUSH)
	TAppGUI.workSaveButton = CreateButton("Save",95,0,80,30,TAppGUI.workWindowButtonPanel,BUTTON_PUSH)
	TAppGUI.workQuitButton = CreateButton("Quit",185,0,80,30,TAppGUI.workWindowButtonPanel,BUTTON_PUSH)
	'Create workspace settings panel
	TAppGUI.settingsPalel = CreatePanel(10,73,280,87,TAppGUI.workWindow,PANEL_GROUP,"  Settings :  ")
	TAppGUI.settingsScaleTextbox = CreateTextField(80,12,30,20,TAppGUI.settingsPalel)
	TAppGUI.settingFramesTextbox = CreateTextField(190,12,30,20,TAppGUI.settingsPalel)
	TAppGUI.settingsColorRTextbox = CreateTextField(80,42,30,20,TAppGUI.settingsPalel)
	TAppGUI.settingsColorGTextbox = CreateTextField(135,42,30,20,TAppGUI.settingsPalel)
	TAppGUI.settingsColorBTextbox = CreateTextField(190,42,30,20,TAppGUI.settingsPalel)
	'Create workspace settings labels
	TAppGUI.settingsScaleLabel = CreateLabel("Scale:",10,15,50,20,TAppGUI.settingsPalel,LABEL_LEFT)
	TAppGUI.settingsFramesLabel = CreateLabel("Frames:",120,15,50,20,TAppGUI.settingsPalel,LABEL_LEFT)
	TAppGUI.settingsColorLabel = CreateLabel("BG Color:",10,45,50,20,TAppGUI.settingsPalel,LABEL_LEFT)
	TAppGUI.settingsColorRLabel = CreateLabel("R:",65,45,50,20,TAppGUI.settingsPalel,LABEL_LEFT)
	TAppGUI.settingsColorGLabel = CreateLabel("G:",120,45,50,20,TAppGUI.settingsPalel,LABEL_LEFT)
	TAppGUI.settingsColorBLabel = CreateLabel("B:",175,45,50,20,TAppGUI.settingsPalel,LABEL_LEFT)
	'Settings textboxes default values
	SetGadgetText(TAppGUI.settingsScaleTextbox,SCALE)	
	SetGadgetText(TAppGUI.settingFramesTextbox,FRAMES)
	SetGadgetText(TAppGUI.settingsColorRTextbox,BACKGROUND_RED)
	SetGadgetText(TAppGUI.settingsColorGTextbox,BACKGROUND_GREEN)
	SetGadgetText(TAppGUI.settingsColorBTextbox,BACKGROUND_BLUE)
	
	'Create instructions panel
	TAppGUI.workHelpPanel = CreatePanel(10,170,280,247,TAppGUI.workWindow,PANEL_GROUP,"  Instructions :  ")
	TAppGUI.workHelpTextbox = CreateTextArea(5,5,GadgetWidth(TAppGUI.workHelpPanel)-20,GadgetHeight(TAppGUI.workHelpPanel)-30,TAppGUI.workHelpPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
	'Instructions textbox content
	SetGadgetText(TAppGUI.workHelpTextbox,"TBA");

	'Delete no longer used MainWindow
	FreeGadget(TAppGUI.mainWindow)
EndFunction

While True
	TAppGUI.FAppUpdate()
	
	'Print appState
	'Print SCALE
	'Print FRAMES
	'Print importedFile	
	
	WaitEvent
	'Print CurrentEvent.ToString()

	'Event responses

	If TAppGUI.mainToWork = False Then
		Select EventID()
			'Quitting
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				End
			Case EVENT_GADGETACTION
				Select EventSource()
					'Quitting
					Case TAppGUI.mainQuitButton
						End
					'Loading
					Case TAppGUI.mainLoadButton
						importedFile = RequestFile("Select graphic file to open",fileFilers)	
				EndSelect
		EndSelect
	ElseIf TAppGUI.mainToWork = True Then
	
		'Quitting
		If quitResult Then
			End
		EndIf
		
		Select EventID()
			'Quitting confirm
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				quitResult = Confirm("Quit program?")
				
			Case EVENT_GADGETACTION
				Select EventSource()
					'Quitting confirm
					Case TAppGUI.workQuitButton
						quitResult = Confirm("Quit program?")
					'Loading
					Case TAppGUI.workLoadButton
						importedFile = RequestFile("Select graphic file to open",fileFilers)
	
					'Saving
					Case TAppGUI.workSaveButton
						RequestFile("Save graphic file",fileFilers,True)
			
					'Settings textbox input
					Case TAppGUI.settingsScaleTextbox
						SCALE = GadgetText(TAppGUI.settingsScaleTextbox).ToInt()
					Case TAppGUI.settingFramesTextbox
						FRAMES = GadgetText(TAppGUI.settingFramesTextbox).ToInt()
					Case TAppGUI.settingsColorRTextbox
						BACKGROUND_RED = GadgetText(TAppGUI.settingsColorRTextbox).ToInt()
					Case TAppGUI.settingsColorGTextbox
						BACKGROUND_GREEN = GadgetText(TAppGUI.settingsColorGTextbox).ToInt()
					Case TAppGUI.settingsColorBTextbox
						BACKGROUND_BLUE = GadgetText(TAppGUI.settingsColorBTextbox).ToInt()
				EndSelect
		EndSelect
	EndIf
Wend