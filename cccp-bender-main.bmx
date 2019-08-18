Rem
	---------------------------------------------------------------
			CORTEX COMMAND COMMUNITY PROJECT BENDER v0.1 :
	---------------------------------------------------------------
		TBA
EndRem

Strict

Import MaxGUI.Drivers
Import BRL.FileSystem

'Version
Global appVersion:String = "0.1"

'File I/O
Global importedFile:String = Null
Global fileFilers:String = "Image Files:png,jpg,bmp"

'Output Settings
Global SCALE:Int = 1
Global FRAMES:Int = 7
Global BACKGROUND_RED:Int = 50
Global BACKGROUND_GREEN:Int = 170
Global BACKGROUND_BLUE:Int = 255
Global TILESIZE:Int = 32

'Bools
Global quitResult = False
Global mainToWork = False
Global doDraw = False

'Transition between windows
Function FAppUpdate()
	If mainToWork = False
		If importedFile <> Null Then
			FAppWork()
			TGraphicOutput.FGraphicBoot()
			mainToWork = True
		EndIf
	EndIf
EndFunction

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
EndType

'Output Window Title
AppTitle = "CCCP Bender v"+appVersion+" - Output"

'Output Window Elements
Type TGraphicOutput
	'Graphic Assets
	Global sourceImage:TImage
	Global boneImage:TImage[BONES]
	'sourceImage = LoadImage(importedFile,0)
	
	'Limb Parts
	Global JointX:Float[BONES]
	Global JointY:Float[BONES]
	Global BoneLength:Float[BONES]

	'Precalc for drawing
	Global Angle[BONES,FRAMES]
	Global XBone[BONES,FRAMES]
	Global YBone[BONES,FRAMES]
	
	'Constants
	Const BONES = 8 
	Const LIMBS = BONES/2
	Const UPPER_BONE = 0
	Const LOWER_BONE = 1
	Const REL_ANG = 180
	
	'Variables
	Global AngA:Float
	Global AngB:Float
	Global AngC:Float
	
	Function FLawOfCosines(ab,bc,ca)
		AngA = ACos((ca^2+ab^2-bc^2)/(2*ca*ab))
		AngB = ACos((bc^2+ab^2-ca^2)/(2*bc*ab))
		AngC = 180-(AngA+AngB)
	End Function	
		
	'Create output window and draw assets
	Function FGraphicBoot()
		SetGraphicsDriver GLMax2DDriver()
		Graphics(640,480,0,0,0)
		'SetScale(SCALE,SCALE)
		'Window background color
		SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
		SetMaskColor(255,0,255)
		DrawImage(sourceImage,0,0)
		
		For Local b = 0 To BONES-1 ' Because I can't (?) set handles on inidividial anim image frames, I must use my own frame sys.
			boneImage[b] = CreateImage(TILESIZE, TILESIZE, 1, MASKEDIMAGE)
			GrabImage boneImage[b], b*TILESIZE, 0
		Next
		
		' Bones should be centered on image by setting up a TILESIZE grid in photoshop with a subdiv of 2.
		' However, I rotate around the upper end of bone.
		
		For Local i = 0 To BONES-1		' Set up default bone sizes.
			JointX[i] = TILESIZE/2
			JointY[i] = TILESIZE/3.6
			boneLength[i] = (TILESIZE/2 -JointY[i])*2
			SetImageHandle(boneImage[i], JointX[i], JointY[i])
		Next
		
		FBend()
		FDraw()
		doDraw = True
		Flip(1)
		Cls
	EndFunction
	
	'Sprite rotation
	Function FBend()
		Local frm = 0
		Local MaxExtend:Float = 0.99		' 1.0 is not a triangle and might cause trouble?
		Local MinExtend:Float = 0.30		' Possibly make definable in GUI (slider)
		Local StepSize:Float = (MaxExtend-MinExtend)/(FRAMES-1) ' -1 to make inclusive of last value (full range)
		Local b, l, f, x, y, AirLen, UpperLen, LowerLen 
		For Local l = 0 To LIMBS-1
			For Local f = 0 To FRAMES-1 
				b = l*2
				x = f * TILESIZE + 96
				y = l * TILESIZE * 1.5 + 200
				UpperLen = BoneLength[b]	' e.g. upper leg
				LowerLen = BoneLength[b+1]	' e.g. lower leg
				AirLen = (StepSize*f + MinExtend) * (UpperLen + LowerLen)	' Sum of the two bones * step scaler for frame. (hip-ankle)
				FLawOfCosines(AirLen, UpperLen, LowerLen)
				Angle[b,f] = AngB					' Geez this was kinda tricky, angles upon angles. 
				XBone[b,f] = x
				YBone[b,f] = y
				x:-Sin(Angle[b,f])*UpperLen			' Position of knee.
				y:+Cos(Angle[b,f])*UpperLen			' Could just use another angle of the triangle though, but I didn't.
				Angle[b+1,f] = AngC + AngB + 180 	' It looks correct on screen so I'm just gonna leave it at that!
				XBone[b+1,f] = x
				YBone[b+1,f] = y
			Next
		Next
	EndFunction
	
	Function FSetSpot()
		Local xm = MouseX()
		Local ym = MouseY()
		If ym < (TILESIZE/2-2) And ym > 0 And xm > 0 And xm < TILESIZE*BONES ' Clicked in region? Possibly dupe points for rear limbs. 
			Local b = xm/TILESIZE
			JointX[b] = TILESIZE/2 		' X is always at center, so kinda pointless to even bother.
			JointY[b] = ym				' Determines length
			boneLength[b] = (TILESIZE/2 -ym)*2
			SetImageHandle(boneImage[b], JointX[b], JointY[b])	' Rotation handle.
		EndIf
	EndFunction
	
	'Draw bone marks
	Function FDrawMark(x,y)
		SetRotation(0)
		SetColor(0,0,80)
		x:+1 y:+1 'add a shade for clarity on bright colours
		DrawLine(x-2,y,x+2,y)
		DrawLine(x,y-2,x,y+2)
		x:-1 y:-1 'Cross
		SetColor(255,230,80)
		DrawLine(x-2,y,x+2,y)
		DrawLine(x,y-2,x,y+2)
	End Function
	
	Function FDraw()
		SetColor(255,255,255)
		DrawImage(sourceImage,0,0)
		SetColor(255,230,80)
		'Footer text
		DrawText("TBA",0,480-15)
		'Draw the + marks.
		For Local i = 0 To BONES-1
			FDrawMark(JointX[i]+i*TILESIZE,JointY[i])
			FDrawMark(JointX[i]+i*TILESIZE,JointY[i]+BoneLength[i])
		Next
		
		SetColor(255,255,255)
		For Local f = 0 To FRAMES-1	
			' These might be in a specific draw-order for joint overlapping purposes
			Local b
			b = 0 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 1 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 2 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 3 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 4 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 5 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 6 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
			b = 7 SetRotation(Angle[b,f]) DrawImage(boneImage[b],XBone[b,f],YBone[b,f])
		Next

		SetRotation(0)
	End Function
	
	Function FOutputUpdate()	
			If MouseDown(1)	Then' Left mouse to adjust bone spots.
				FSetSpot()
				FBend()
				doDraw = True
			EndIf
			If doDraw
				SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
				FDraw()
				Flip(1)
				Cls
				doDraw = False
			Else
				Delay(20)
			EndIf
	End Function
EndType

FAppMain()

Function FAppMain()
	'Create main app window
	TAppGUI.mainWindow = CreateWindow("CCCP Bender v"+appVersion,DesktopWidth()/2-150,DesktopHeight()/2-180,300,360,Null,WINDOW_TITLEBAR)
	
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
	'TAppGUI.workWindow = CreateWindow("CCCP Bender v0.1 - Editor",DesktopWidth()/2-152,DesktopHeight()/2-222,305,455,Null,WINDOW_TITLEBAR)
	TAppGUI.workWindow = CreateWindow("CCCP Bender v"+appversion+" - Editor",DesktopWidth()/2-640,DesktopHeight()/2-240,305,455,Null,WINDOW_TITLEBAR)

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
	FAppUpdate()
	TGraphicOutput.FOutputUpdate()
	
	'Print appState
	'Print SCALE
	'Print FRAMES
	'Print importedFile	
	
	WaitEvent
	'Print CurrentEvent.ToString()

	'Event responses

	If mainToWork = False Then
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
						TGraphicOutput.sourceImage = LoadImage(importedFile,0)	
				EndSelect
		EndSelect
	ElseIf mainToWork = True Then
	
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
							If importedFile = Null Then
								TGraphicOutput.sourceImage = LoadImage("no-input.png",0)
							Else
								TGraphicOutput.sourceImage = LoadImage(importedFile,0)
							EndIf
					'Saving
					Case TAppGUI.workSaveButton
						RequestFile("Save graphic file",fileFilers,True)
			
					'Settings textbox input
					Case TAppGUI.settingsScaleTextbox
						SCALE = GadgetText(TAppGUI.settingsScaleTextbox).ToInt()
						SetScale(SCALE,SCALE)
						TILESIZE = 32 * SCALE
						doDraw = True
					Case TAppGUI.settingFramesTextbox
						FRAMES = GadgetText(TAppGUI.settingFramesTextbox).ToInt()
						doDraw = True
					Case TAppGUI.settingsColorRTextbox
						BACKGROUND_RED = GadgetText(TAppGUI.settingsColorRTextbox).ToInt()
						doDraw = True
					Case TAppGUI.settingsColorGTextbox
						BACKGROUND_GREEN = GadgetText(TAppGUI.settingsColorGTextbox).ToInt()
						doDraw = True
					Case TAppGUI.settingsColorBTextbox
						BACKGROUND_BLUE = GadgetText(TAppGUI.settingsColorBTextbox).ToInt()
						doDraw = True
				EndSelect
		EndSelect
	EndIf
Wend