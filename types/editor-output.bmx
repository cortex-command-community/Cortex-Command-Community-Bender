Rem
------- OUTPUT ELEMENTS -----------------------------------------------------------------------------------------------
EndRem

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
	Global logoImage:TImage = LoadImage("Incbin::assets/logo-image",MASKEDIMAGE) '
	Global sourceImage:TImage
	Global boneImage:TImage[BONES]
	'Output Settings
	Global INPUTZOOM:Int = 1
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
			SetImageHandle(boneImage[i],jointX[i]/INPUTZOOM,jointY[i]/INPUTZOOM)
		Next
	EndFunction
	
	'Set Joint Marker
	Function FSetJointMarker()
		Local xm:Int = MouseX()
		Local ym:Int = MouseY()
		If ym < (TILESIZE/2-2) And ym > 0 And xm > 0 And xm < TILESIZE*BONES Then
			Local b:Int = xm/TILESIZE
			jointX[b] = TILESIZE/2 		'X is always at center, so kinda pointless to even bother - at the moment
			jointY[b] = ym				'Determines length
			boneLength[b] = (TILESIZE/2 -ym)*2
			SetImageHandle(boneImage[b],jointX[b]/INPUTZOOM,jointY[b]/INPUTZOOM) 'Rotation handle.
		EndIf
	EndFunction
	
	'Bending
	Function FLimbBend()
		Local maxExtend:Float = 0.99		'Possibly make definable in settings (slider)
		Local minExtend:Float = 0.30		'Possibly make definable in settings (slider)
		Local stepSize:Float = (maxExtend-minExtend)/(FRAMES-1) ' -1 to make inclusive of last value (full range)
		Local b:Int, f:Int, l:Float, x:Float, y:Float, airLength:Float, upperLength:Float, lowerLength:Float 
		For l = 0 To LIMBS-1
			For f = 0 To FRAMES-1 
				b = l*2
				x = (f * 32) + 80 						'Drawing position X
				y = ((l * 32) * 1.5 ) + 144				'Drawing position Y
				upperLength = boneLength[b]/INPUTZOOM
				lowerLength = boneLength[b+1]/INPUTZOOM
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
		DrawLine(x-1-INPUTZOOM,y,x+1+INPUTZOOM,y)
		DrawLine(x,y-1-INPUTZOOM,x,y+1+INPUTZOOM)
		x:-1 y:-1 'Cross
		SetColor(255,230,80)
		DrawLine(x-1-INPUTZOOM,y,x+1+INPUTZOOM,y)
		DrawLine(x,y-1-INPUTZOOM,x,y+1+INPUTZOOM)
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
		DrawImageRect(sourceImage,0,0,ImageWidth(sourceImage)*INPUTZOOM,ImageHeight(sourceImage)*INPUTZOOM)
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
		'SetColor(255,230,80)
		'DrawText("TBA",ImageWidth(logoImage)+7,480-18)
		'Draw bent limbs
		FLimbBend()
		SetColor(255,255,255)
		For f = 0 To FRAMES-1
			'These might be in a specific draw-order for joint overlapping purposes
			b = 0 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 1 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 2 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 3 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 4 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 5 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 6 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
			b = 7 SetRotation(angle[b,f]) DrawImageRect(boneImage[b],xBone[b,f],yBone[b,f],ImageWidth(boneImage[b])/INPUTZOOM,ImageHeight(boneImage[b])/INPUTZOOM)
		Next
		SetRotation(0)
		'Output copy for saving
		If TAppFileIO.saveAsIndexed = True Then
			'If saving indexed grab a smaller pixmap to speed up indexing
			TAppFileIO.tempOutputImage = GrabPixmap(55,120,34*FRAMES,210)
		Else
			TAppFileIO.tempOutputImage = GrabPixmap(0,96,768,384)
		EndIf
		Flip(1)
		If TAppFileIO.prepForSave
			TAppFileIO.FPrepForSave()
		EndIf
	EndFunction
	
	'Create output window and draw assets
	Function FOutputBoot()
		SetGraphicsDriver GLMax2DDriver()
		SetGraphics CanvasGraphics(TAppGUI.editCanvas)
		'Window background color
		SetClsColor(BACKGROUND_RED,BACKGROUND_GREEN,BACKGROUND_BLUE)
		SetMaskColor(255,0,255)
		DrawImage(logoImage,0,480-ImageHeight(logoImage))
		DrawImageRect(sourceImage,0,0,ImageWidth(sourceImage)*INPUTZOOM,ImageHeight(sourceImage)*INPUTZOOM)
		FCreateLimbTiles()
		'Have to do all this to start editor window with source image zoomed in otherwise markers and tiles don't scale properly.
		INPUTZOOM = 4
		SetGadgetText(TAppGUI.editSettingsZoomTextbox,TAppOutput.INPUTZOOM)
		TILESIZE = 24 * TAppOutput.INPUTZOOM
		redoLimbTiles = True
		FLimbBend()
		FOutputUpdate()
	EndFunction
EndType