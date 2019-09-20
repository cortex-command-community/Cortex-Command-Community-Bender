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
- Zoom setting for easy joint adjustment.
- Frames number output setting.
- Background color setting.
- Automatic setting of background color to magenta on save.

## How To

1. Create an input file using the provided template.
2. Load your file in the app.
3. Bent limbs will auto generate with default settings.
4. Adjust joint positions by clicking on the upper joint marker and dragging it around.
	- Use **Zoom** setting to enlarge the input image for easier joint adjustment
		- **Warning:** When zooming the joint markers will reset to original positions. First zoom, then adjust.
5. Use **Frames** setting to set number of bend frames.
	- Bend angle will adjust automatically. First/Last frames will always be fully bent/unbent.
6. Hit save
	- Background color will automatically be set to magenta (255,0,255) when save is clicked and will revert back to previous color when finished.
7. Slice the saved image into frames and apply palette.
	- Manually touch-up the exported frames if needed.

## Current Issues

- Joint adjustment is only on Y axis and adjusts upper/lower marker equally.
- Works only with input files that are 24x24px tiled (for each limb part. Max input image size is 192x24px for 8 limb parts (4 limbs)).
- Does not save files in .bmp format.

## Changelog

https://github.com/cortex-command-community/Cortex-Command-Community-Project-Bender/wiki/Changelog

## Credits

Created by MaximDude using BlitzMax 0.105.3.35 and MaxIDE 1.52

Bender logo image by Arne Jansson - Edited by MaximDude

## Building

Buildable with BlitzMax 0.105.3.35 using MaxIDE 1.52

[BlitzMax.org](https://blitzmax.org)

