Import "Utility.bmx"

'//// DEFAULT/USER EDITOR SETTINGS //////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Global g_DefaultMaximizeWindow:Int = False
Global g_DefaultOutputRefreshRate:Int = DesktopHertz()
Global g_DefaultBackgroundRed:Int = 50
Global g_DefaultBackgroundGreen:Int = 170
Global g_DefaultBackgroundBlue:Int = 255
Global g_DefaultInputZoom:Int = 4
Global g_DefaultOutputZoom:Int = 1
Global g_DefaultFrameCount:Int = 7
Global g_DefaultSaveAsFrames:Int = False
Global g_DefaultSaveAsIndexed:Int = False
Global g_DefaultIndexedFileType:String = "png"

'//// SETTINGS MANAGER //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Type SettingsManager

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method New()
		ReadSettingsFile()
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method ReadSettingsFile()
		Local inputStream:TStream = ReadStream("BenderUserSettings.ini")
		If Not inputStream Then
			'Notify("No settings file found, using default settings!")
			Return
		EndIf

		While Not inputStream.Eof()
			Local line:String = ReadLine(inputStream)

			'Skip whitespace and comment lines
			If line.Length = 0 Or line.Find("//") = 0 Then
				Continue
			EndIf

			Local propAndValue:String[] = line.Split("=")
			propAndValue[0] = propAndValue[0].Trim()
			propAndValue[1] = propAndValue[1].Trim()

			Select propAndValue[0]
				Case "StartMaximizedWindow"
					g_DefaultMaximizeWindow = Utility.Clamp(propAndValue[1].ToInt(), False, True)
				Case "OutputRefreshRate"
					g_DefaultOutputRefreshRate = Utility.Clamp(propAndValue[1].ToInt(), 1, DesktopHertz())
				Case "BackgroundRed"
					g_DefaultBackgroundRed = Utility.Clamp(propAndValue[1].ToInt(), 0, 255)
				Case "BackgroundGreen"
					g_DefaultBackgroundGreen = Utility.Clamp(propAndValue[1].ToInt(), 0, 255)
				Case "BackgroundBlue"
					g_DefaultBackgroundBlue = Utility.Clamp(propAndValue[1].ToInt(), 0, 255)
				Case "InputZoom"
					g_DefaultInputZoom = Utility.Clamp(propAndValue[1].ToInt(), 1, DesktopWidth() - 260)
				Case "OutputZoom"
					g_DefaultOutputZoom = Utility.Clamp(propAndValue[1].ToInt(), 1, 5)
				Case "FrameCount"
					g_DefaultFrameCount = Utility.Clamp(propAndValue[1].ToInt(), 1, 20)
				Case "SaveAsFrames"
					g_DefaultSaveAsFrames = Utility.Clamp(propAndValue[1].ToInt(), False, True)
				Case "SaveAsIndexed"
					g_DefaultSaveAsIndexed = Utility.Clamp(propAndValue[1].ToInt(), False, True)
				Case "IndexedFileType"
					propAndValue[1] = propAndValue[1].ToLower()
					If propAndValue[1] = "png" Or propAndValue[1] = "bmp" Then
						g_DefaultIndexedFileType = propAndValue[1]
					Else
						Notify("Invalid indexed file type set from settings, defaulting to PNG!")
					EndIf
			EndSelect
		EndWhile

		CloseStream(inputStream)
	EndMethod

'////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

	Method WriteSettingsFile(propertyValues:String[])
		Local outputString:TStringBuilder = New TStringBuilder("// User Settings~n~n")

		outputString.Append("StartMaximizedWindow = " + g_DefaultMaximizeWindow + "~n")
		outputString.Append("OutputRefreshRate = " + g_DefaultOutputRefreshRate + "~n")
		outputString.Append("BackgroundRed = " + propertyValues[0] + "~n")
		outputString.Append("BackgroundGreen = " + propertyValues[1] + "~n")
		outputString.Append("BackgroundBlue = " + propertyValues[2] + "~n")
		outputString.Append("InputZoom = " + propertyValues[3] + "~n")
		outputString.Append("OutputZoom = " + propertyValues[4] + "~n")
		outputString.Append("FrameCount = " + propertyValues[5] + "~n")
		outputString.Append("SaveAsFrames = " + propertyValues[6] + "~n")
		outputString.Append("SaveAsIndexed = " + propertyValues[7] + "~n")
		outputString.Append("IndexedFileType = " + propertyValues[8].ToLower())

		Local saveResult:Int = SaveText(outputString.ToString(), "BenderUserSettings.ini")
		If saveResult Then
			Notify("Settings file saved successfully!")
		Else
			Notify("Failed to save settings file!", True)
		EndIf
	EndMethod
EndType