Rem
------- GUI ELEMENTS --------------------------------------------------------------------------------------------------
EndRem

'Bool For Quitting
Global quitResult:Int = False

Type TAppGUI
	'Window Transition Bool
	Global mainToEdit:Int = False
	'Main Window
	Global mainWindow:TGadget
	'Main Window Footer Label
	Global mainWindowFooterLabel:TGadget
	'Main Window Buttons
	Global mainWindowButtonPanel:TGadget
	Global mainLoadButton:TGadget
	Global mainQuitButton:TGadget
	'Main Window About
	Global mainAboutPanel:TGadget
	Global mainAboutTextbox:TGadget
	'Editor Window
	Global editWindow:TGadget
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
	'Textboxes content
	Global aboutTextboxContent:String[7]
	Global helpTextboxContent:String[17]
	
	'Create Main App Window
	Function FAppMain()
		mainWindow = CreateWindow("CCCP Bender v"+appVersion,DesktopWidth()/2-150,DesktopHeight()/2-180,300,340,Null,WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
		mainWindowButtonPanel = CreatePanel(GadgetWidth(mainWindow)/2-80,5,150,97,mainWindow,PANEL_GROUP)
		mainLoadButton = CreateButton("Load Sprite",GadgetWidth(mainWindowButtonPanel)/2-69,0,130,30,mainWindowButtonPanel,BUTTON_PUSH)
		mainQuitButton = CreateButton("Quit",GadgetWidth(mainWindowButtonPanel)/2-69,40,130,30,mainWindowButtonPanel,BUTTON_PUSH)
		mainAboutPanel = CreatePanel(GadgetWidth(mainWindow)/2-140,GadgetHeight(mainWindowButtonPanel)+15,280,200,mainWindow,PANEL_GROUP,"  About :  ")
		mainAboutTextbox = CreateTextArea(7,3,GadgetWidth(mainAboutPanel)-21,GadgetHeight(mainAboutPanel)-30,mainAboutPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
		mainWindowFooterLabel = CreateLabel("CCCP Bender v"+appVersion+" - "+appVersionDate,10,GadgetHeight(mainWindow)-20,GadgetWidth(mainWindow),15,mainWindow,LABEL_LEFT)
		'About textbox Content
		aboutTextboxContent[0] = "Welcome to the CCCP Bender utility! ~n~n"
		aboutTextboxContent[1] = "It's purpose is to make the life of modders easier by automagically generating bent limb frames. ~n~n"
		aboutTextboxContent[2] = "The CC Bender was originally created by Arne Jansson (AndroidArts), the man behind all the Cortex Command artwork. ~n"
		aboutTextboxContent[3] = "The CCCommunityProject Bender, however, is a brand new tool that allows more control and convenience for the modder (hopefully). ~n~n"
		aboutTextboxContent[4] = "Arne's original bend code was used as base for this utility, and has been modified and improved to enable the new features. ~n~n"
		aboutTextboxContent[5] = "Created by MaximDude using BlitzMax 0.105.3.35 and MaxIDE 1.52 ~n"
		aboutTextboxContent[6] = "Bender logo image by Arne Jansson - Edited by MaximDude ~n"
		SetGadgetText(mainAboutTextbox,aboutTextboxContent[0]+aboutTextboxContent[1]+aboutTextboxContent[2]+aboutTextboxContent[3]+aboutTextboxContent[4]+aboutTextboxContent[5]+aboutTextboxContent[6])
	EndFunction
	
	'Create Editor Window
	Function FAppEditor()
		EnablePolledInput()
		editWindow = CreateWindow("CCCP Bender v"+appversion+" - Editor",DesktopWidth()/2-700,DesktopHeight()/2-240,300+768,430+50,Null,WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
		editCanvas = CreateCanvas(300,0,768,480,editWindow)
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
		SetGadgetText(editSettingsZoomTextbox,TAppOutput.INPUTZOOM)
		SetGadgetText(editSettingsFramesTextbox,TAppOutput.FRAMES)
		SetGadgetText(editSettingsColorRTextbox,TAppOutput.BACKGROUND_RED)
		SetGadgetText(editSettingsColorGTextbox,TAppOutput.BACKGROUND_GREEN)
		SetGadgetText(editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE)
		'Help textbox content
		helpTextboxContent[0] = "-------------------------- GUI -------------------------- ~n~n"
		helpTextboxContent[1] = "LOAD: ~nThis loads an image file and starts bending. Supported formats are bmp, png and jpg. ~n~n"
		helpTextboxContent[2] = "- Note: ~nThe loaded file is being cut to 24x24px tiles internally. For best results, use provided template to create correct input files. ~n~n"
		helpTextboxContent[3] = "SAVE: ~nThis saves the bended limbs into a file or creates a new file with specified name. ~n~n"
		helpTextboxContent[4] = "- Note: ~nFiles are saved in .png format, typing in the extension is not needed. Currently loaded file cannot be overwritten. ~n~n"
		helpTextboxContent[5] = "----------------- ADJUSTING JOINTS ---------------- ~n~n"
		helpTextboxContent[6] = "To adjust the joint positing on a limb part, click the upper joint marker on and drag it up/down, or click at desired point to set it there. Output will update automatically as you adjust the markers.~n~n"
		helpTextboxContent[7] = "- Note: Joint markers cannot be adjusted on the X axis, and will adjust equally on the Y axis. For best results, please position the limb parts as close to dead center as possible for each tile in the input file. ~n~n"
		helpTextboxContent[8] = "---------------------- SETTINGS ----------------------- ~n~n"
		helpTextboxContent[9] = "ZOOM : ~nThis magnifies the source image For easier placement of joint markers. Zooming does Not magnify the output. ~n~nAccepts values from 1 To 4. ~n~n"
		helpTextboxContent[10] = "- Warning : ~nChanging zoom level will reset the joint markers to initial positions. Zoom first, adjust markers later. ~n~n"		
		helpTextboxContent[11] = "FRAMES: ~nThis sets the amount of frames output will generate. ~n~nAccepts values from 1 to 20. ~n~n"
		helpTextboxContent[12] = "- Note : ~nLimb bending will automatically adjust to number of frames. ~n~n"
		helpTextboxContent[13] = "BG COLOR R,G,B: ~nThis changes the background color of the output. ~n~nAccepts values from 0 to 255. ~n~n"	
		helpTextboxContent[14] = "- Note : ~nWhen saving file, the output will automatically set background to magenta, so no manual setting before saving is needed. ~n~n"
		helpTextboxContent[15] = "SAVE AS INDEXED BITMAP : ~nWhen ticked the output will be saved as a BMP file indexed to the CC palette. ~nWhen not ticked, output will be saved as a non-indexed PNG. ~n~n"
		helpTextboxContent[16] = "- Warning : ~nTHE INDEXING PROCESS IS SLOW! ~nI've done my best to speed it up but it still isn't blazing fast like PNG saving. ~nWhen saving indexed, the app may hang and appear unresponsive but in fact it's doing what it's supposed to. ~nFor best results, DO NOT TOUCH ANYTHING until the background color reverts from magenta to whatever it was before!" 
		SetGadgetText(TAppGUI.editHelpTextbox,helpTextboxContent[0]+helpTextboxContent[1]+helpTextboxContent[2]+helpTextboxContent[3]+helpTextboxContent[4]+helpTextboxContent[5]+helpTextboxContent[6]+helpTextboxContent[7]+helpTextboxContent[8]+helpTextboxContent[9]+helpTextboxContent[10]+helpTextboxContent[11]+helpTextboxContent[12]+helpTextboxContent[13]+helpTextboxContent[14]+helpTextboxContent[15]+helpTextboxContent[16]);
		'Delete no longer used MainWindow
		FreeGadget(mainWindow)
	EndFunction
	
	'Transition between windows
	Function FAppUpdate()
		If Not mainToEdit And importedFile <> Null Then
			FAppEditor()
			TAppOutput.FOutputBoot()
			TBitmapIndex.FLoadPalette()
			mainToEdit = True
		EndIf
	EndFunction
EndType