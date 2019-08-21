Rem
	---------------------------------------------------------------
			CORTEX COMMAND COMMUNITY PROJECT BENDER v0.1 :
	---------------------------------------------------------------
		TBA
EndRem

SuperStrict

'Import dependencies into build
Import MaxGUI.Drivers
Import BRL.Max2D
Import BRL.Pixmap
Import BRL.PNGLoader

'Version
Global appVersion:String = "0.1"
Global appVersionDate:String = "17 Aug 2019"

'Output Window Title
AppTitle = "CCCP Bender v"+appVersion+" - Output"

'Bools
Global quitResult:Int = False

'Filepaths
Global importedFile:String = Null
Global exportedFile:String = Null

'File IO
Type TAppFileIO
	'Save Bools
	Global prepForSave:Int = False
	Global rdyForSave:Int = False
	Global runOnce:Int = False
	'File Filters
	Global fileFilers:String = "Image Files:png,jpg,bmp"
	
	'Load Source Image
	Function FLoadFile()
		Local oldImportedFile:String = importedFile
		importedFile = RequestFile("Select graphic file to open",fileFilers)
		'Foolproofing
		If importedFile = Null Then
			importedFile = oldImportedFile
			TAppOutput.sourceImage = TAppOutput.sourceImage
		Else
			TAppOutput.sourceImage = LoadImage(importedFile,0)
			TAppOutput.redoLimbTiles = True
		EndIf
	EndFunction
	
	'Prep Output For Saving
	Function FPrepForSave()
		If prepForSave Then
			If Not runOnce Then
				runOnce = True
				TAppOutput.FOutputUpdate()
			Else
				FSaveFile()
			EndIf
		EndIf
	EndFunction
	
	Function FRevertPrep()
		prepForSave = False
		rdyForSave = False
		runOnce = False
		TAppOutput.FOutputUpdate()
	EndFunction
	
	'Save Output Content To File
	Function FSaveFile()
		Local tempOutputImage:TPixmap = GrabPixmap(0,96,768,384)
		exportedFile = RequestFile("Save graphic file",fileFilers,True)
		'Foolproofing
		If exportedFile = importedFile Then
			Notify("Can't overwrite source image!",True)	
		ElseIf exportedFile <> importedFile Then
			'Writing new file
	      	SavePixmapPNG(tempOutputImage,exportedFile)
			FRevertPrep()	
		Else
			'On Cancel
			FRevertPrep()
		EndIf
	EndFunction
EndType

'App Output Elements
Type TAppOutput
	'Output Window
	Global outputWindow:TGraphics
	'Draw Bools
	Global redoLimbTiles:Int = False
	'Constants
	Const BONES:Int = 8
	Const LIMBS:Int = BONES/2
	Const UPPER_BONE:Int = 0
	Const LOWER_BONE:Int = 1
	'Graphic Assets
	Global logoImage:TImage = LoadImage("assets/logo-image.png",MASKEDIMAGE)
	Global sourceImage:TImage
	Global boneImage:TImage[BONES]
	'Output Settings
	Global ZOOM:Int = 1
	Global FRAMES:Int = 7
	Global BACKGROUND_RED:Int = 50
	Global BACKGROUND_GREEN:Int = 170
	Global BACKGROUND_BLUE:Int = 255
	'Limb Parts
	Global jointX:Float[BONES]
	Global jointY:Float[BONES]
	Global boneLength:Float[BONES]
	'Precalc for drawing
	Global TILESIZE:Int = 24
	Global angle:Int[BONES,20]
	Global xBone:Int[BONES,20]
	Global yBone:Int[BONES,20]
	'Variables
	Global angA:Float
	Global angB:Float
	Global angC:Float
	
	'Rotation Calc
	Function FLawOfCosines(ab:Float,bc:Float,ca:Float)
		angA = ACos((ca^2+ab^2-bc^2)/(2*ca*ab))
		angB = ACos((bc^2+ab^2-ca^2)/(2*bc*ab))
		angC = (180-(angA+angB))
	EndFunction
	
	'Create limb part tiles from source image
	Function FCreateLimbTiles()
		Local b:Int, i:Int
		For b = 0 To BONES-1 'Because I (arne) can't set handles on inidividial anim image frames, I must use my own frame sys
			boneImage[b] = CreateImage(TILESIZE,TILESIZE,1,DYNAMICIMAGE|MASKEDIMAGE)
			GrabImage(boneImage[b],b*TILESIZE,0)
			SetColor(120,0,120)
			DrawLine(i*TILESIZE,0,i*TILESIZE,TILESIZE-1,True)
		Next
		'Set up default bone sizes
		For i = 0 To BONES-1
			jointX[i] = TILESIZE/2
			jointY[i] = TILESIZE/3.3 '3.6
			boneLength[i] = (TILESIZE/2-jointY[i])*2
			SetImageHandle(boneImage[i],jointX[i]/ZOOM,jointY[i]/ZOOM)
		Next
	EndFunction
	
	'Set Joint Marker
	Function FSetJointMarker()
		Local xm:Int = MouseX()
		Local ym:Int = MouseY()
		If ym < (TILESIZE/2-2) And ym > 0 And xm > 0 And xm < TILESIZE*BONES Then
			Local b:Int = xm/TILESIZE
			jointX[b] = TILESIZE/2 		'X is always at center, so kinda pointless to even bother - at the moment
			jointY[b] = ym			'Determines length
			boneLength[b] = (TILESIZE/2 -ym)*2
			SetImageHandle(boneImage[b],jointX[b]/ZOOM,jointY[b]/ZOOM) 'Rotation handle.
		EndIf
	EndFunction
	
	'Bending
	Function FLimbBend()
		Local maxExtend:Float = 0.99		'Possibly make definable in settings (slider) -- maybe not, because large number of frames can be rendered and you can just take the ones you need
		Local minExtend:Float = 0.30		'Possibly make definable in settings (slider) -- maybe not, because large number of frames can be rendered and you can just take the ones you need
		Local stepSize:Float = (maxExtend-minExtend)/(FRAMES-1) ' -1 to make inclusive of last value (full range)
		Local b:Int, f:Int, l:Float, x:Float, y:Float, airLength:Float, upperLength:Float, lowerLength:Float 
		For l = 0 To LIMBS-1
			For f = 0 To FRAMES-1 
				b = l*2
				x = (f * 32) + 80 						'Drawing position X
				y = ((l * 32) * 1.5 ) + 144				'Drawing position Y
				upperLength = boneLength[b]/ZOOM		'e.g. upper leg
				lowerLength = boneLength[b+1]/ZOOM		'e.g. lower leg
				airLength = (stepSize * f + minExtend) * (upperLength + lowerLength)	'Sum of the two bones * step scaler for frame (hip-ankle)
				FLawOfCosines(airLength,upperLength,lowerLength)
				angle[b,f] = angB
				xBone[b,f] = x
				yBone[b,f] = y
				x:-Sin(angle[b,f])*upperLength		'Position of knee
				y:+Cos(angle[b,f])*upperLength		'Could just use another angle of the triangle though, but I (arne) didn't
				angle[b+1,f] = angC + angB + 180	'It looks correct on screen so i'm (arne) just gonna leave it at that!
				xBone[b+1,f] = x
				yBone[b+1,f] = y
			Next
		Next
	EndFunction

	'Create Joint Markers
	Function FCreateJointMarker(x:Float,y:Float)
		SetRotation(0)
		SetColor(0,0,80)
		x:+1 y:+1 'Add a shade for clarity on bright colours
		DrawLine(x-1-ZOOM,y,x+1+ZOOM,y)
		DrawLine(x,y-1-ZOOM,x,y+1+ZOOM)
		x:-1 y:-1 'Cross
		SetColor(255,230,80)
		DrawLine(x-1-ZOOM,y,x+1+ZOOM,y)
		DrawLine(x,y-1-ZOOM,x,y+1+ZOOM)
		SetColor(255,255,255)
	End Function

	'Update Output Window
	Function FOutputUpdate()
		Local i:Int, f:Int, b:Int
		Cls
		'Left mouse to adjust joint markers, click or hold and drag
		If MouseDown(1) Then
			FSetJointMarker()
		EndIf
		'Drawing Output	
		'Set background color
		If TAppFileIO.prepForSave
			SetClsColor(255,0,255)
		Else
			SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
		EndIf
		'Draw source image
		SetColor(255,255,255)
		DrawImageRect(sourceImage,0,0,ImageWidth(sourceImage)*ZOOM,ImageHeight(sourceImage)*ZOOM)
		If redoLimbTiles Then
			FCreateLimbTiles()
			redoLimbTiles = False
		EndIf
		For i = 0 To BONES-1
			'Draw limb tile dividers
			SetColor(120,0,120)
			DrawLine(i*TILESIZE,0,i*TILESIZE,TILESIZE-1,True)
			'Draw the joint markers
			FCreateJointMarker(jointX[i]+i*TILESIZE,jointY[i])
			FCreateJointMarker(jointX[i]+i*TILESIZE,jointY[i]+boneLength[i])
		Next	
		'Draw footer image and text
		DrawImage(logoImage,0,480-ImageHeight(logoImage))
		SetColor(255,230,80)
		DrawText("TBA",ImageWidth(logoImage)+7,480-18)
		'Draw bent limbs
		FLimbBend()
		SetColor(255,255,255)
		For f = 0 To FRAMES-1
			'These might be in a specific draw-order for joint overlapping purposes
			b = 0 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 1 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 2 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 3 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 4 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 5 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 6 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
			b = 7 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
		Next
		SetRotation(0)
		Flip(1)
		If TAppFileIO.prepForSave
			TAppFileIO.FPrepForSave()
		EndIf
	EndFunction
	
	'Create output window and draw assets
	Function FOutputBoot()
		SetGraphicsDriver GLMax2DDriver()
		outputWindow = Graphics(768,480,0,0,0)
		'Window background color
		SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
		SetMaskColor(255,0,255)
		DrawImage(logoImage,0,480-ImageHeight(logoImage))
		DrawImageRect(sourceImage,0,0,ImageWidth(sourceImage)*ZOOM,ImageHeight(sourceImage)*ZOOM)
		FCreateLimbTiles()
		FLimbBend()
		FOutputUpdate()
	EndFunction
EndType

'GUI Elements
Type TAppGUI
	'Window Transition Bool
	Global mainToEdit:Int = False
	'Main Window
	Global mainWindow:TGadget
	'Footer Label
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
	'Editor Window Buttons
	Global editWindowButtonPanel:TGadget
	Global editLoadButton:TGadget
	Global editSaveButton:TGadget
	Global editQuitButton:TGadget
	'Editor Window Settings
	Global editSettingsPalel:TGadget
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
	'Workspace Window Instructions
	Global editHelpPanel:TGadget
	Global editHelpTextbox:TGadget
	'Textboxes content
	Global aboutTextboxContent:String[8]
	Global helpTextboxContent:String[]
	
	'Create Main App Window
	Function FAppMain()
		mainWindow = CreateWindow("CCCP Bender v"+appVersion,DesktopWidth()/2-150,DesktopHeight()/2-180,300,340,Null,WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
		mainWindowButtonPanel = CreatePanel(GadgetWidth(mainWindow)/2-80,5,150,97,mainWindow,PANEL_GROUP)
		mainLoadButton = CreateButton("Load Sprite",GadgetWidth(mainWindowButtonPanel)/2-69,0,130,30,mainWindowButtonPanel,BUTTON_PUSH)
		mainQuitButton = CreateButton("Quit",GadgetWidth(mainWindowButtonPanel)/2-69,40,130,30,mainWindowButtonPanel,BUTTON_PUSH)
		mainAboutPanel = CreatePanel(GadgetWidth(mainWindow)/2-140,GadgetHeight(mainWindowButtonPanel)+15,280,200,mainWindow,PANEL_GROUP,"  About :  ")
		mainAboutTextbox = CreateTextArea(7,3,GadgetWidth(mainAboutPanel)-21,GadgetHeight(mainAboutPanel)-30,mainAboutPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
		mainWindowFooterLabel = CreateLabel("CCCP Bender v"+appVersion+" by MaximDude",10,GadgetHeight(mainWindow)-20,GadgetWidth(mainWindow),15,mainWindow,LABEL_LEFT)
		'About textbox Content
		aboutTextboxContent[0] = "Welcome to the CCCP Bender utility!~n~n"
		aboutTextboxContent[1] = "It's purpose is to make the life of modders easier by automagically generating bent limb frames.~n~n"
		aboutTextboxContent[2] = "The CC Bender was originally created by Arne Jansson (AndroidArts), the man behind all the Cortex Command artwork.~n"
		aboutTextboxContent[3] = "The CCCommunityProject Bender, however, is a brand new tool that allows more control and convenience for the modder (hopefully).~n~n"
		aboutTextboxContent[4] = "Arne's original bend code was used as base for this utility, and has been modified and improved to enable the new features.~n~n"
		aboutTextboxContent[5] = "Created by MaximDude using BlitzMax MaxIDE 1.52~n"
		aboutTextboxContent[6] = "Bender logo image by Arne Jansson - Edited by MaximDude"
		aboutTextboxContent[7] = "CCCP Bender version "+appVersion+" - "+appVersionDate
		SetGadgetText(mainAboutTextbox,aboutTextboxContent[0]+aboutTextboxContent[1]+aboutTextboxContent[2]+aboutTextboxContent[3]+aboutTextboxContent[4]+aboutTextboxContent[5]+aboutTextboxContent[6]+aboutTextboxContent[7])
	EndFunction
	
	'Create Editor Window
	Function FAppEditor()
		editWindow = CreateWindow("CCCP Bender v"+appversion+" - Editor",DesktopWidth()/2-700,DesktopHeight()/2-240,300,430,Null,WINDOW_TITLEBAR|WINDOW_CLIENTCOORDS)
		editWindowButtonPanel = CreatePanel(10,7,280,57,editWindow,PANEL_GROUP)	
		editLoadButton = CreateButton("Load",6,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editSaveButton = CreateButton("Save",96,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editQuitButton = CreateButton("Quit",186,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editSettingsPalel = CreatePanel(10,73,280,87,editWindow,PANEL_GROUP,"  Settings :  ")
		editSettingsZoomTextbox = CreateTextField(80,12,30,20,editSettingsPalel)
		editSettingsFramesTextbox = CreateTextField(190,12,30,20,editSettingsPalel)
		editSettingsColorRTextbox = CreateTextField(80,42,30,20,editSettingsPalel)
		editSettingsColorGTextbox = CreateTextField(135,42,30,20,editSettingsPalel)
		editSettingsColorBTextbox = CreateTextField(190,42,30,20,editSettingsPalel)
		editSettingsZoomLabel = CreateLabel("Zoom:",10,15,50,20,editSettingsPalel,LABEL_LEFT)
		editSettingsFramesLabel = CreateLabel("Frames:",120,15,50,20,editSettingsPalel,LABEL_LEFT)
		editSettingsColorLabel = CreateLabel("BG Color:",10,45,50,20,editSettingsPalel,LABEL_LEFT)
		editSettingsColorRLabel = CreateLabel("R:",65,45,50,20,editSettingsPalel,LABEL_LEFT)
		editSettingsColorGLabel = CreateLabel("G:",120,45,50,20,editSettingsPalel,LABEL_LEFT)
		editSettingsColorBLabel = CreateLabel("B:",175,45,50,20,editSettingsPalel,LABEL_LEFT)
		editHelpPanel = CreatePanel(10,170,280,250,editWindow,PANEL_GROUP,"  Instructions :  ")
		editHelpTextbox = CreateTextArea(7,5,GadgetWidth(editHelpPanel)-21,GadgetHeight(editHelpPanel)-32,editHelpPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
		SetGadgetText(editSettingsZoomTextbox,TAppOutput.ZOOM)
		SetGadgetText(editSettingsFramesTextbox,TAppOutput.FRAMES)
		SetGadgetText(editSettingsColorRTextbox,TAppOutput.BACKGROUND_RED)
		SetGadgetText(editSettingsColorGTextbox,TAppOutput.BACKGROUND_GREEN)
		SetGadgetText(editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE)
		'Instructions textbox content
		SetGadgetText(TAppGUI.editHelpTextbox,"TBA");
		'Delete no longer used MainWindow
		FreeGadget(mainWindow)
	EndFunction
	
	'Transition between windows
	Function FAppUpdate()
		If Not mainToEdit And importedFile <> Null Then
			FAppEditor()
			TAppOutput.FOutputBoot()
			mainToEdit = True
		EndIf
	EndFunction
EndType

'Everything set up, run app
New TAppGUI
New TAppOutput
New TAppFileIO
TAppGUI.FAppMain()

While True
	If Not TAppGUI.mainToEdit Then
		TAppGUI.FAppUpdate()
	Else
		TAppOutput.FOutputUpdate()
	EndIf

	WaitEvent
	Print CurrentEvent.ToString()

	'Event Responses	
	'In Main Window
	If Not TAppGUI.mainToEdit Then
		Select EventID()
			Case EVENT_GADGETACTION
				Select EventSource()
					'Quitting
					Case TAppGUI.mainQuitButton
						Exit
					'Loading
					Case TAppGUI.mainLoadButton
						TAppFileIO.FLoadFile()
				EndSelect
			'Quitting
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				Exit	
		EndSelect
	'In Editor Window	
	ElseIf TAppGUI.mainToEdit Then
		Select EventID()
			Case EVENT_APPRESUME
				ActivateWindow(TAppGUI.editWindow)
				TAppOutput.FOutputUpdate()
			Case EVENT_WINDOWACTIVATE
				TAppOutput.FOutputUpdate()
			Case EVENT_GADGETLOSTFOCUS
				TAppOutput.FOutputUpdate()	
			Case EVENT_GADGETACTION
				Select EventSource()
					'Quitting confirm
					Case TAppGUI.editQuitButton
						quitResult = Confirm("Quit program?")
					'Loading
					Case TAppGUI.editLoadButton
						TAppFileIO.FLoadFile()
						TAppOutput.FOutputUpdate()
					'Saving
					Case TAppGUI.editSaveButton
						TAppFileIO.prepForSave = True
						TAppOutput.FOutputUpdate()
					'Settings textbox inputs
					'Scale
					Case TAppGUI.editSettingsZoomTextbox
						Local userInputValue:Int = GadgetText(TAppGUI.editSettingsZoomTextbox).ToInt()	
						'Foolproofing
						If userInputValue > 4 Then
							TAppOutput.ZOOM = 4
						ElseIf userInputValue <= 0 Then
							TAppOutput.ZOOM = 1
						Else
							TAppOutput.ZOOM = userInputValue
						EndIf
						SetGadgetText(TAppGUI.editSettingsZoomTextbox,TAppOutput.ZOOM)
						TAppOutput.TILESIZE = 24 * TAppOutput.ZOOM
						TAppOutput.redoLimbTiles = True
						TAppOutput.FOutputUpdate()
					'Frames
					Case TAppGUI.editSettingsFramesTextbox
						Local userInputValue:Int = GadgetText(TAppGUI.editSettingsFramesTextbox).ToInt()
						'Foolproofing
						If userInputValue > 20 Then
							TAppOutput.FRAMES = 20
						ElseIf userInputValue <= 0 Then
							TAppOutput.FRAMES = 1
						Else
							TAppOutput.FRAMES = userInputValue
						EndIf
						SetGadgetText(TAppGUI.editSettingsFramesTextbox,TAppOutput.FRAMES)
						TAppOutput.FOutputUpdate()
					'Bacground Color
					'Red
					Case TAppGUI.editSettingsColorRTextbox
						Local userInputValue:Int = GadgetText(TAppGUI.editSettingsColorRTextbox).ToInt()
						'Foolproofing
						If userInputValue > 255 Then
							TAppOutput.BACKGROUND_RED = 255
						ElseIf userInputValue < 0 Then
							TAppOutput.BACKGROUND_RED = 0
						Else
							TAppOutput.BACKGROUND_RED = userInputValue
						EndIf
						SetGadgetText(TAppGUI.editSettingsColorRTextbox,TAppOutput.BACKGROUND_RED)
						TAppOutput.FOutputUpdate()
					'Green
					Case TAppGUI.editSettingsColorGTextbox
						Local userInputValue:Int = GadgetText(TAppGUI.editSettingsColorGTextbox).ToInt()
						'Foolproofing
						If userInputValue > 255 Then
							TAppOutput.BACKGROUND_GREEN = 255
						ElseIf userInputValue < 0 Then
							TAppOutput.BACKGROUND_GREEN = 0
						Else
							TAppOutput.BACKGROUND_GREEN = userInputValue
						EndIf
						SetGadgetText(TAppGUI.editSettingsColorGTextbox,TAppOutput.BACKGROUND_GREEN)
						TAppOutput.FOutputUpdate()
					'Blue
					Case TAppGUI.editSettingsColorBTextbox
						Local userInputValue:Int = GadgetText(TAppGUI.editSettingsColorBTextbox).ToInt()
						'Foolproofing
						If userInputValue > 255 Then
							TAppOutput.BACKGROUND_BLUE = 255
						ElseIf userInputValue < 0 Then
							TAppOutput.BACKGROUND_BLUE = 0
						Else
							TAppOutput.BACKGROUND_BLUE = userInputValue
						EndIf
						SetGadgetText(TAppGUI.editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE)
						TAppOutput.FOutputUpdate()
				EndSelect
			'Quitting confirm
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				quitResult = Confirm("Quit program?")
		EndSelect
		'Quitting
		If quitResult Then Exit
	EndIf
EndWhile