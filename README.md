# Cortex Command Bender

## About

The purpose of this tool is to make the life of modders easier by automagically generating bent limb sprites from limb parts.  
The CC Bender was originally created by Arne Jansson ([**AndroidArts**](https://twitter.com/AndroidArts)), the man behind all the Cortex Command artwork.  
This version however is a brand new tool that allows more control and convenience for the modder (hopefully).  
Arne's original bend code was used as base and has been modified and improved to enable new features.  

**Do note that the generated output from this tool is not ideal and will most likely require some manual touching up for best results.**

## Feature Info

1. **Input Files:**  
	- This tool is not a miracle maker and can only do it's job when fed a properly set up input file:  
		- Input files **must** be **exactly** 192x24px for everything to work as intended. Wrong dimensions will be rejected.  
		- Input files **must** use Magenta (255,0,255) for anything that needs to be transparent/masked.  
		- The order of limb parts in the input file **is important!** Order should be as specified, going left to right:  
			*Upper Arm FG*, *Lower Arm FG*, *Upper Arm BG*, *Lower Arm BG*, *Upper Leg FG*, *Lower Leg FG*, *Upper Leg BG*, *Lower Leg BG*.  
		- Arm parts should be facing **right** for correct bending!  
		- Leg parts should be facing **left** for correct bending!  
		- See included *"TestImage.png"* to understand how your input file should look like.  
	- Supports loading BMP and PNG input files.

2. **Background Color:**  
	- Set values in the **RGB** textboxes to change the color of the background for easier inspection/personal preference.  
	- Background color will be set to Magenta (255,0,255) automatically when save is clicked so setting it manually beforehand is not required.

3. **Input Zoom:**  
	- Set value in the **Input Zoom** textbox to magnify the input image for easier joint adjustment.  
	- The maximum zoom value is calculated from the desktop width. 5 for 1366px, 11 for 2560px, etc.  
	- When zooming, the joint markers will reset to original positions. First zoom, then adjust.
	
4. **Output Zoom:**  
	- Set value in the **Output Zoom** textbox to magnify the output for easier inspection. Maximum zoom value is 5.  
	- When the output is zoomed, the workspace can be panned by clicking and dragging so everything that doesn't fit into the visible area can also be inspected.  
	- The output zoom setting does not affect saved files. Those will be saved with no magnification.
	
5. **Frame Count:**  
	- Set value in the **Frame Count** textbox to change the number of bent limb frames. Maximum frame count is 20.  
	- Bend angle will adjust automatically to the number of frames. First/Last frames will always be fully bent/unbent.
	
6. **Indexed Color:**  
	- Supports saving as RGB332 (8bpp) BMP and PNG formats. The desired format can be selected from a combo box when the **Save as Indexed** checkbox is ticked.  
	- Saved files will be indexed to the *Cortex Command* palette.
	
7. **Output Files:**  
	- Output can be saved as either one file containing all the frames or individual frames.  
	- Saved files are RGB888 (24bpp) PNG unless specified otherwise by **Save as Indexed**.  
	- File extension will be added automatically so there is no need to add it manually. Avoid doing so.  
	- When **Save as Frames** is ticked:  
		- A visual aid will be shown around each frame to help the user stay within bounds.  
		- Exported frames will be flipped (legs only), rotated and cropped automatically so no extra manual labor is required.  
		- Limb names and frame numbers will be added automatically. **Doing so manually will result in horrible exported file names!**
		
8. **Joint Adjustment:**  
	- Joints can be adjusted individually on both axis.  
	- Clicking or clicking and dragging in the limb tile area will set the joint marker.  
	- The top joint marker adjusts the length and offset (and in turn rotation) of the limb part, while the bottom marker only adjusts length.

9. **Layering Controls:**  
	- Draw order of limb parts in each limb can be adjusted by ticking the limb checkbox in the layering controls panel.

10. **Defaults and User Settings:**  
	- A file with the current editor settings can be exported using the **Save Settings** button in the title bar.  
	- If a settings file exists, it will be loaded and applied automatically on startup. Invalid property values will be overridden.  
	- Settings file properties are self explanatory.  
	- Properties that cannot be set through the GUI:  
		- `StartMaximizedWindow = 0/1` - If set true will start the editor maximized.  
		- `OutputRefreshRate = #` - Used to limit the graphics refresh rate to reduce GPU load (fairly high for whatever reason).  
		Only really relevant for high resolution (above 1080p) and high refresh rate (above 60hz) displays.

## How To

1. Create an input file using the provided template.  
2. Load your input file using the **Load** button or by dragging and dropping it into the main window.  
3. Bent limbs will auto generate with default settings.  
4. Adjust joint positions by clicking a joint marker and dragging it around.  
5. Use **Frame Count** setting to set number of bent frames.  
6. Decide whether you want to save as individual named frames or not - if yes, tick the **Save as Frames** checkbox.  
	6.1. Make sure each frame is within the displayed bounds.  
7. Decide whether you want to save the file with indexed color - if yes, tick the **Save as Indexed** checkbox.  
	7.1. Select the desired indexed file type from the combobox.  
8. Save the output with the **Save** button.  
9. Manually touchup saved files if necessary.  
10. Make great mods.
		
## Current Issues

- Works only with input files that are 24x24px tiled (for each limb part. Input image size is locked to 192x24px for 8 limb parts (4 limbs)).  
- Builds but doesn't run on Linux due to some issue with MaxGUI not being able to instantiate the main window.

## Changelog

https://github.com/cortex-command-community/Cortex-Command-Community-Project-Bender/wiki/Changelog

## Building

Buildable with BlitzMax NG 0.129 (and possibly earlier versions) using MaxIDE.  
Uses only modules that are provided with the release.  
[BlitzMax.org](https://blitzmax.org)

## Credits

Bender logo image by Arne Jansson.

