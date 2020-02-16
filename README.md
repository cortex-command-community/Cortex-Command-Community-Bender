# Cortex Command Community Project Bender

## About

The purpose of this tool is to make the life of modders easier by automagically generating bent limb sprites from limb parts.

The CC Bender was originally created by Arne Jansson ([**AndroidArts**](https://twitter.com/AndroidArts)), the man behind all the Cortex Command artwork.

The CCCommunityProject Bender, however, is a brand new tool that allows more control and convenience for the modder (hopefully).

Arne's original bend code was used as base and has been modified and improved to enable new features.

**Do note that the generated output from this tool is not ideal and will most likely require some manual touching up for best results.**

### Features

- GUI
- Loading/saving files.
- Adjusting joint position.
- Zoom setting on input image for easy joint adjustment.
- Frames number output setting.
- Background color setting.
- Automatic setting of background color to magenta on save.
- Saving as PNG or Indexed BMP (CC Palette).
- Saving as individual named frames.

## How To

1. Create an input file using the provided template.
	- **Warning:** The order of limb parts in the input file **is important!**  
		- Order should be as specified, going left to right:  
	Upper Arm FG, Lower Arm FG, Upper Arm BG, Lower Arm BG, Upper Leg FG, Lower Leg FG, Upper Leg BG, Lower Leg BG.
    - **Double Warning:** 
    	- Arm parts should be facing **right** for correct bending!  
    	- Leg parts should be facing **left** for correct bending!  
    	
    - See included "test-image.bmp" to understand how your input file should look like.
    
2. Load your input file using the "**Load**" button.

3. Bent limbs will auto generate with default settings.

4. Adjust joint positions by clicking on the upper joint marker and dragging it around.
	- ~~Use **Zoom** setting to enlarge the input image for easier joint adjustment~~
	- Input image will be automatically zoomed to x4 on first load.
		- **Warning:** When zooming the joint markers will reset to original positions. First zoom, then adjust.

5. Use **Frames** setting to set number of bend frames.
	- Bend angle will adjust automatically. First/Last frames will always be fully bent/unbent.

6. Decide whether you want to save as Indexed BMP or not - if yes, tick the "**Save as Indexed Bitmap**" checkbox.

7. Decide whether you want to save as individual named frames or not - if yes, tick the "**Save as Frames**" checkbox.
	- Exported frame size is fixed to 24x24px.
	- If enabled, a visual aid will be shown around each frame to help the user stay within bounds.
		- Pixels outside bounds will be cropped.
	- Exported leg frames will be automatically flipped horizontally to face right.  

**Note:** "Save as Indexed Bitmap" and "Save as Frames" do not conflict and can be used together to export indexed individual frames.  

8. Hit save  
	- Background color will automatically be set to magenta (255,0,255) when save is clicked and will revert back to previous color when finished.  

	- **Warning:**
		- File extension will be added automatically depending on selected "**Save as Indexed Bitmap**" setting so there is no need to add it manually.  
		Doing so will resolve in a double extension (for example: "MyFile.png.png").
        
	- **Quadruple Warning:**
	
    	- When saving with "**Save as Frames**" enabled, only input the name of the actor these limbs belong to (for example: "Robot").  
    	Limb names and frame numbers will be added automatically.  
    	**Adding the limb name and frame number manually will result in horrible exported file names.**
    

## Current Issues

- Joint adjustment is only on Y axis and adjusts upper/lower marker equally.
- Works only with input files that are 24x24px tiled (for each limb part. Max input image size is 192x24px for 8 limb parts (4 limbs)).

## Changelog

https://github.com/cortex-command-community/Cortex-Command-Community-Project-Bender/wiki/Changelog

## Credits

Created by MaximDude using BlitzMax 0.105.3.35 and MaxIDE 1.52

Bender logo image by Arne Jansson - Edited by MaximDude

## Building

Buildable with BlitzMax 0.105.3.35 using MaxIDE 1.52

[BlitzMax.org](https://blitzmax.org)

