Rem
	---------------------------------------------------------------
			CORTEX COMMAND COMMUNITY PROJECT BENDER v0.1 :
	---------------------------------------------------------------
		TBA
EndRem

Strict

'Import dependencies into build
Import MaxGUI.Drivers
Import BRL.FileSystem

'Version
Global appVersion:String = "0.1"

'Output Window Title
AppTitle = "CCCP Bender v"+appVersion+" - Output"

'File IO
Global fileFilers:String = "Image Files:png,jpg,bmp"
Global importedFile:String = Null
Global exportedFile:String = Null

'Bools
Global quitResult:Int = False

'App Output Elements
Type TAppOutput
	'Draw Bools
	Global doDraw:Int = False
	Global redoBoneImage:Int = False
	'Constants
	Const BONES:Int = 8
	Const LIMBS:Int = BONES/2
	Const UPPER_BONE:Int = 0
	Const LOWER_BONE:Int = 1
	'Graphic Assets
	Global sourceImage:TImage
	Global boneImage:TImage[BONES]
	'Output Settings
	Global ZOOM:Int = 2
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
	Global angle:Int[BONES,FRAMES]
	Global xBone:Int[BONES,FRAMES]
	Global yBone:Int[BONES,FRAMES]
	'Variables
	Global angA:Float
	Global angB:Float
	Global angC:Float
	
	'Create bone tiles from source image
	Function FCreateBoneImage()
		Local b:Int, i:Int
		For b = 0 To BONES-1 'Because I (arne) can't set handles on inidividial anim image frames, I must use my own frame sys
			boneImage[b] = CreateImage(TILESIZE,TILESIZE,1,MASKEDIMAGE)
			GrabImage(boneImage[b],b*TILESIZE,0)
		Next
		'Set up default bone sizes.
		For i = 0 To BONES-1		
			jointX[i] = TILESIZE/2
			jointY[i] = TILESIZE/3.6
			boneLength[i] = ((TILESIZE/2-jointY[i])*2)
			SetImageHandle(boneImage[i],jointX[i],jointY[i])
		Next
	EndFunction
	
	'Create output window and draw assets
	Function FOutputBoot()
		'SetGraphicsDriver GLGraphicsDriver()
		Graphics(640,480,0,0,0)
		'Window background color
		SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
		SetMaskColor(255,0,255)
		'DrawImage(sourceImage,0,0)
		DrawImageRect(sourceImage,0,0,ImageWidth(sourceImage)*ZOOM,ImageHeight(sourceImage)*ZOOM)
		FCreateBoneImage()
		FLimbBend()
		Flip(1)
		'FOutputDraw()
		'Cls
		doDraw = True
	EndFunction
	
	'Sprite rotation
	Function FLawOfCosines(ab:Float,bc:Float,ca:Float)
		angA = ACos((ca^2+ab^2-bc^2)/(2*ca*ab))
		angB = ACos((bc^2+ab^2-ca^2)/(2*bc*ab))
		angC = (180-(angA+angB))
	EndFunction
	
	Function FLimbBend()
		Local maxExtend:Float = 0.99		'Possibly make definable in settings (slider)
		Local minExtend:Float = 0.30		'Possibly make definable in settings (slider)
		Local stepSize:Float = (maxExtend-minExtend)/(FRAMES-1) ' -1 to make inclusive of last value (full range)
		Local b:Int, f:Int, l:Float, x:Float, y:Float, airLength:Float, upperLength:Float, lowerLength:Float 
		For l = 0 To LIMBS-1
			For f = 0 To FRAMES-1 
				b = l*2
				x = f * TILESIZE + 96
				y = l * TILESIZE * 1.5 + 200
				upperLength = boneLength[b]		'e.g. upper leg
				lowerLength = boneLength[b+1]	'e.g. lower leg
				airLength = (stepSize * f + minExtend) * (upperLength + lowerLength)	'Sum of the two bones * step scaler for frame (hip-ankle)
				FLawOfCosines(airLength,upperLength,lowerLength)
				angle[b,f] = angB
				xBone[b,f] = x
				yBone[b,f] = y
				x:-Sin(angle[b,f])*upperLength		'Position of knee
				y:+Cos(angle[b,f])*upperLength		'Could just use another angle of the triangle though, but I (arne) didn't
				angle[b+1,f] = angC + angB + 180 	'It looks correct on screen so I'm just gonna leave it at that!
				xBone[b+1,f] = x
				yBone[b+1,f] = y
			Next
		Next
	EndFunction
	
	'Set Joint Marker
	Function FSetJointMarker()
		Local xm:Int = MouseX()
		Local ym:Int = MouseY()
		If ym < (TILESIZE/2-2) And ym > 0 And xm > 0 And xm < TILESIZE*BONES Then
			Local b:Int = xm/TILESIZE
			jointX[b] = TILESIZE/2 		'X is always at center, so kinda pointless to even bother - at the moment
			jointY[b] = ym					'Determines length
			boneLength[b] = (TILESIZE/2 -ym)*2
			SetImageHandle(boneImage[b],jointX[b],jointY[b])	'Rotation handle.
		EndIf
	EndFunction
	
	'Create Joint Markers
	Function FCreateJointMarker(x:Float,y:Float)
		SetRotation(0)
		SetColor(0,0,80)
		x:+1 y:+1 'Add a shade for clarity on bright colours
		DrawLine(x-2,y,x+2,y)
		DrawLine(x,y-2,x,y+2)
		x:-1 y:-1 'Cross
		SetColor(255,230,80)
		DrawLine(x-2,y,x+2,y)
		DrawLine(x,y-2,x,y+2)
	End Function

	'Update Output Window
	Function FOutputUpdate()
		'Left mouse to adjust bone spots, click or hold and drag
		If MouseDown(1) Then
			FSetJointMarker()
			doDraw = True
		EndIf
		If doDraw
			Cls
			SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
			SetColor(255,255,255)
			DrawImageRect(sourceImage,0,0,ImageWidth(sourceImage)*ZOOM,ImageHeight(sourceImage)*ZOOM)
			If redoBoneImage Then
				FCreateBoneImage()
				redoBoneImage = False
			EndIf
			FLimbBend()
			'Footer text
			SetColor(255,230,80)
			DrawText("TBA",0,480-15)
			'Draw the joint markers
			Local i:Int
			For i = 0 To BONES-1
				FCreateJointMarker(jointX[i]+i*TILESIZE,jointY[i])
				FCreateJointMarker(jointX[i]+i*TILESIZE,jointY[i]+boneLength[i])
			Next	
			'Draw bent limbs
			SetColor(255,255,255)
			Local f:Int, b:Int
			For f = 0 To FRAMES-1
				'These might be in a specific draw-order for joint overlapping purposes
				b = 0 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 1 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 2 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 3 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 4 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 5 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 6 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM)
				b = 7 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/ZOOM,ImageHeight(boneImage[b])/ZOOM) 'DrawImage(boneImage[b],xBone[b,f],yBone[b,f])
			Next
			SetRotation(0)
			Flip(1)	
			doDraw = False
		'Else
			'Delay(20)
		EndIf
	EndFunction
EndType

'GUI Elements
Type TAppGUI
	'Window Transition Bool
	Global mainToEdit:Int = False
	'Main Window
	Global mainWindow:TGadget
	'Main Window Label
	'Global mainWindowLabel:TGadget
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
	
	'Create Main App Window
	Function FAppMain()
		mainWindow = CreateWindow("CCCP Bender v"+appVersion,DesktopWidth()/2-150,DesktopHeight()/2-180,300,360,Null,WINDOW_TITLEBAR)
		'mainWindowLabel = CreateLabel("",0,0,GadgetWidth(mainWindow),100,TAppGUI.mainWindow,LABEL_LEFT)
		mainWindowButtonPanel = CreatePanel(GadgetWidth(mainWindow)/2-80,10,150,97,mainWindow,PANEL_GROUP)
		mainLoadButton = CreateButton("Load Sprite",GadgetWidth(mainWindowButtonPanel)/2-70,0,130,30,mainWindowButtonPanel,BUTTON_PUSH)
		mainQuitButton = CreateButton("Quit",GadgetWidth(mainWindowButtonPanel)/2-70,40,130,30,mainWindowButtonPanel,BUTTON_PUSH)
		mainAboutPanel = CreatePanel(GadgetWidth(mainWindow)/2-143,125,280,200,mainWindow,PANEL_GROUP,"  About :  ")
		mainAboutTextbox = CreateTextArea(5,5,GadgetWidth(mainAboutPanel)-20,GadgetHeight(mainAboutPanel)-30,mainAboutPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
		SetGadgetText(mainAboutTextbox,"Welcome to the CCCP Bender utility!~n~nIt's purpose is to make the life of modders easier by automagically generating bent limb frames.~n~nThe CC Bender was originally created by Arne Jansson (AndroidArts), the man behind all the Cortex Command artwork.~nThe CCCommunityProject Bender, however, is a brand new tool that allows more control and convenience For the modder (hopefully).~n~nThis tool utilizes Arne's original limb bend code, but also allows loading and saving sprites, along with other settings.~n~nCreated by MaximDude using BlitzMax MaxIDE 1.52~nCCCP Bender version 0.1 - 17 Aug 2019")
	EndFunction	
	
	'Create Editor Window
	Function FAppEditor()
		editWindow = CreateWindow("CCCP Bender v"+appversion+" - Editor",DesktopWidth()/2-640,DesktopHeight()/2-240,305,455,Null,WINDOW_TITLEBAR)
		editWindowButtonPanel = CreatePanel(10,7,280,57,editWindow,PANEL_GROUP)	
		editLoadButton = CreateButton("Load",5,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editSaveButton = CreateButton("Save",95,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
		editQuitButton = CreateButton("Quit",185,0,80,30,editWindowButtonPanel,BUTTON_PUSH)
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
		editHelpPanel = CreatePanel(10,170,280,247,editWindow,PANEL_GROUP,"  Instructions :  ")
		editHelpTextbox = CreateTextArea(5,5,GadgetWidth(editHelpPanel)-20,GadgetHeight(editHelpPanel)-30,editHelpPanel,TEXTAREA_WORDWRAP|TEXTAREA_READONLY)
		SetGadgetText(editSettingsZoomTextbox,TAppOutput.ZOOM)
		SetGadgetText(editSettingsFramesTextbox,TAppOutput.FRAMES)
		SetGadgetText(editSettingsColorRTextbox,TAppOutput.BACKGROUND_RED)
		SetGadgetText(editSettingsColorGTextbox,TAppOutput.BACKGROUND_GREEN)
		SetGadgetText(editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE)
		SetGadgetText(TAppGUI.editHelpTextbox,"TBA");
		'Delete no longer used MainWindow
		FreeGadget(mainWindow)
	EndFunction
EndType

'Transition between windows
Function FAppUpdate()
	If Not TAppGUI.mainToEdit And importedFile <> Null Then
		TAppGUI.FAppEditor()
		TAppOutput.FOutputBoot()
		TAppGUI.mainToEdit = True
	EndIf
EndFunction

'Everything set up, run app
New TAppGUI
New TAppOutput
TAppGUI.FAppMain()

While True
	If Not TAppGUI.mainToEdit Then
		FAppUpdate()
	Else
		TAppOutput.FOutputUpdate()
	EndIf

	WaitEvent
	Print CurrentEvent.ToString()

	'Event Responses	
	'In Main Window
	If Not TAppGUI.mainToEdit Then
		Select EventID()
			'Quitting
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				End
			Case EVENT_GADGETACTION
				Select EventSource()
					'Quitting
					Case TAppGUI.mainQuitButton
						Exit
					'Loading
					Case TAppGUI.mainLoadButton
						importedFile = RequestFile("Select graphic file to open",fileFilers)
						TAppOutput.sourceImage = LoadImage(importedFile,0)
						'Print (importedFile)
				EndSelect
		EndSelect
	'In Editor Window	
	ElseIf TAppGUI.mainToEdit Then
		Select EventID()
			'Quitting confirm
			Case EVENT_WINDOWCLOSE, EVENT_APPTERMINATE
				quitResult = Confirm("Quit program?")
				
			Case EVENT_GADGETACTION
				Select EventSource()
					'Quitting confirm
					Case TAppGUI.editQuitButton
						quitResult = Confirm("Quit program?")
					'Loading
					Case TAppGUI.editLoadButton
						importedFile = RequestFile("Select graphic file to open",fileFilers)
						'Foolproofing
						If importedFile = Null Then
							TAppOutput.sourceImage = TAppOutput.sourceImage
						Else
							TAppOutput.sourceImage = LoadImage(importedFile,0)
							TAppOutput.redoBoneImage = True
							TAppOutput.doDraw = True
						EndIf
					'Saving
					Case TAppGUI.editSaveButton
						exportedFile = RequestFile("Save graphic file",fileFilers,True)
			
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
						TAppOutput.redoBoneImage = True
						TAppOutput.doDraw = True
					'Frames		
					Case TAppGUI.editSettingsFramesTextbox
						Local userInputValue:Int = GadgetText(TAppGUI.editSettingsFramesTextbox).ToInt()
						'Foolproofing
						If userInputValue > 7 Then
							TAppOutput.FRAMES = 7
						ElseIf userInputValue <= 0 Then
							TAppOutput.FRAMES = 1
						Else
							TAppOutput.FRAMES = userInputValue
						EndIf
						SetGadgetText(TAppGUI.editSettingsFramesTextbox,TAppOutput.FRAMES)
						TAppOutput.doDraw = True
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
						TAppOutput.doDraw = True
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
						TAppOutput.doDraw = True
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
						SetGadgetText(TAppGUI.editSettingsColorBTextbox,TAppOutput.BACKGROUND_BLUE )
						TAppOutput.doDraw = True
				EndSelect
		EndSelect
		'Quitting
		If quitResult Then Exit
	EndIf
EndWhile