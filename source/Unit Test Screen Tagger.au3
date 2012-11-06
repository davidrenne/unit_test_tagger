#NoTrayIcon
#include <ScreenCapture.au3>
#include <ButtonConstants.au3>
#include <ComboConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <Misc.au3>
#include <mySQL.au3>
#include <Autoit_RichEditCtrl.au3>
#include <ClipBoard.au3>
#include <GDIPlus.au3>
Opt("WinTitleMatchMode", 1)

$configurationWizard = IniRead("Unit Test Screen Tagger.ini","Install","Configured","False")
If Not FileExists("Unit Test Screen Tagger.ini") Or $configurationWizard = "False" Then
	#Region ### START Koda GUI section ### Form=FormCode\Welcome.kxf
	Global $Radio = 0
	$FormWelcome   = GUICreate("Welcome", 441, 321, 193, 125)
	GuiCtrlSetState(-1, $GUI_CHECKED)
	$Label1  =  GUICtrlCreateLabel("Welcome to the Unit Test Screen Tagger.", 8, 16, 351, 28)
	GUICtrlSetFont(-1, 14, 400, 0, "MS Sans Serif")
	$Label2  = GUICtrlCreateLabel("How would you like this program to behave?", 8, 64, 213, 17)
	$Label3  = GUICtrlCreateLabel("Local Files ONLY (Rich Text Edit Information)", 24, 104, 217, 17)
	$Radio2  = GUICtrlCreateRadio("LOCAL", 312, 104, 113, 17)
	$Label4  = GUICtrlCreateLabel("A Web Based mySQL and FTP with direct connections?", 24, 152, 269, 17)
	$Radio1  = GUICtrlCreateRadio("DATABASEDIRECT", 312, 152, 113, 17)
	$Label5  = GUICtrlCreateLabel("A Web Based mySQL and FTP without direct connections?", 16, 200, 284, 17)
	$Radio3  = GUICtrlCreateRadio("WEBDATABASE", 312, 200, 113, 17)
	$Label6 = GUICtrlCreateLabel("(People using this INI file, will need to install mySQL ODBC)", 48, 168, 281, 17)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$msg = GuiGetMsg()
		Switch $msg
			Case $Radio3
				IniWrite("Unit Test Screen Tagger.ini","Install","Type","WEBDATABASE")
				IniWrite("Unit Test Screen Tagger.ini","WEBDATABASE","IntegrationHandler","add_documents.php")
				IniWrite("Unit Test Screen Tagger.ini","Paths","AlsoCopyToWebServer","C:\wamp\www\unit_test_tagger\www\screenshots\")
				ExitLoop
			Case $Radio2
				IniWrite("Unit Test Screen Tagger.ini","Install","Type","LOCAL")
				ExitLoop
			Case $Radio1
				IniWrite("Unit Test Screen Tagger.ini","Install","Type","DATABASEDIRECT")
				ExitLoop
		EndSwitch
	WEnd
	IniWrite("Unit Test Screen Tagger.ini","Paths","SharedInstallPath","")
	IniWrite("Unit Test Screen Tagger.ini","Paths","MainScreenshotDir","C:\UnitTests\")
	GUISetState(@SW_HIDE)
	IniWrite("Unit Test Screen Tagger.ini","Install","Configured","True")
	;SET THIS VARIABLE TO EITHER CREATE UNIT TESTS LOCALLY BY CONCATENATING TO AN RTF OR TO A MYSQL DATABASE
	Global $localOrDatabaseDriven = IniRead("Unit Test Screen Tagger.ini","Install","Type","LOCAL")

	If $localOrDatabaseDriven = "LOCAL" Then
		_PreferencesLocal()
	Else
		IniWrite("Unit Test Screen Tagger.ini", "DATABASE", "WebProjectsLoadOnStartUpOrEveryTimeScreenIsTaken", "STARTUP")
		IniWrite("Unit Test Screen Tagger.ini", "DATABASE", "WebProjectLocation","fetch_projects.php")

		$response = MsgBox(4, "FTP Server configuration is highly recommended to sync the images", "Would you like to sync the screenshots to FTP as they are taken?  This is the best as your web documents will not have broken links until you manually FTP")
		If $response = 6 Then
			IniWrite("Unit Test Screen Tagger.ini","DATABASE","UseFTP","Yes")
			_PreferencesFTP()
		Else
			IniWrite("Unit Test Screen Tagger.ini","DATABASE","UseFTP","No")
		EndIf

		If $localOrDatabaseDriven = "DATABASEDIRECT" Or $localOrDatabaseDriven = "WEBDATABASE" Then
			_PreferencesMYSQL()
		EndIf
		_PreferencesURL()
	EndIf
Else
	Global $localOrDatabaseDriven = IniRead("Unit Test Screen Tagger.ini","Install","Type","LOCAL")
EndIf
Opt("TrayMenuMode", 1)
Opt("TrayOnEventMode", 1)

If WinExists("Autoit Screener tool hidden window") Then ProcessClose(WinGetProcess("Autoit Screener tool hidden window"))
AutoItWinSetTitle("Autoit Screener tool hidden window")

HotKeySet("^!x", "ExitScreen")
HotKeySet("^!t", "_InsertFileLink")
HotKeySet("^!o", "_OpenTempFile")
HotKeySet("^!z", "_CopyLastFileToClip")
HotKeySet("^!c", "_Capt")


If _Singleton("UnitTest", 1) = 0 Then
	;ONE INSTANCE OF PROGRAM RUNNING ONLY!
	GUISetState(@SW_SHOW)
	Exit
EndIf

; SETTINGS

;AUTO-LOGIN WITH PROGRAM RUNNING
If Not StringInStr(@ScriptName, "au3") Then
	FileCreateShortcut(@ScriptDir & "\" & @ScriptName, @StartupCommonDir & "\" & @ScriptName & ".lnk", @ScriptDir)
EndIf

;SET TO BLANK IF YOU DONT WANT TO SHARE THE PROGRAM WITH OTHERS ON A NETWORK DRIVE
$pathToNetworkSharedInstaller = IniRead("Unit Test Screen Tagger.ini","Paths","SharedInstallPath","")

If $pathToNetworkSharedInstaller <> "" And Not StringInStr(@ScriptName, "au3") Then
	$localTime = FileGetTime(@ScriptDir & "\" & @ScriptName, 0, 1)
	$programTime = FileGetTime($pathToNetworkSharedInstaller & @ScriptName, 0, 1)
	If Not FileExists("Unit Test Screen Tagger.ini") And FileExists($pathToNetworkSharedInstaller & "Unit Test Screen Tagger.ini") Then
		FileCopy($pathToNetworkSharedInstaller & "Unit Test Screen Tagger.ini","Unit Test Screen Tagger.ini")
	EndIf
	If StringLeft($localTime, 8) <> StringLeft($programTime, 8) And $programTime <> "" And $localTime <> "" Then
		MsgBox(0, "New Version", "There is a new version of " & @ScriptName & ", please copy and overwrite your old version")
		ShellExecute($pathToNetworkSharedInstaller)
		Exit
	EndIf
EndIf

Global $hWnd
Global $hasAnyCustomProjects
Global $sDailyWordDoc
Global $sFile
Global $taskItems
Global $nClick = 10

;SET TO WHERE YOU WANT THE UNIT TEST FILES DOWNLOADED
Global $sMainDataDump =  IniRead("Unit Test Screen Tagger.ini","Paths","MainScreenshotDir","C:\UnitTests\")


If Not FileExists($sMainDataDump) Then
	$res = DirCreate($sMainDataDump)
	If $res <> 1 Then
		$sMainDataDump = @ScriptDir & "\UnitTests\"
	EndIf

	$res = DirCreate($sMainDataDump)
	If $res <> 1 Then
		MsgBox(0, "Error", "We could not create C:\UnitTests\ or a relative UnitTests directory.")
		Exit
	EndIf
EndIf

If Not FileExists("C:\WINDOWS\TASKMAN.EXE") Then
	;WINTERM LOGIC
	$sMainDataDump = @ScriptDir & "\UnitTests\"
	$res = DirCreate($sMainDataDump)
	If $res <> 1 Then
		MsgBox(0, "Error", "We could not create C:\UnitTests\ or a relative UnitTests directory.")
		Exit
	EndIf
EndIf

If $localOrDatabaseDriven = "DATABASEDIRECT" Or $localOrDatabaseDriven = "WEBDATABASE" Then
	Global $pathToMain = IniRead("Unit Test Screen Tagger.ini","DATABASE","WebLocation","")
	Global $pathToWebTaskList = $pathToMain & IniRead("Unit Test Screen Tagger.ini","DATABASE","WebProjectLocation","")
EndIf

If $localOrDatabaseDriven = "DATABASEDIRECT" Then
	;IF DATABASE CONFIGURE BELOW
	Global $mySQL
	Global $mySQLServer = IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLServer","")
	Global $mySQLUser = IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLUser","")
	Global $mySQLPass = IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLPass","")
	Global $mySQLDatabase = IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLDatabase","")
	Global $mySQLUnitTestScreenTable = IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLTable1","")
	Global $mySQLUnitTestTaskTable = IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLTable2","")

	$mySQL = _MySQLConnect($mySQLUser, $mySQLPass, $mySQLDatabase, $mySQLServer)
	If $mySQL = 0 Then
		$everConnected = IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLEverConnected","False")
		If $everConnected = "False" Then
			$extra = @CRLF & @CRLF & "Would you like to redirect to mySQL.com to download and install this package?"
		Else
			$extra = @CRLF & @CRLF & "Would you like to edit your existing mySQL changes to ensure the settings are correct?"
		EndIf
		$response = MsgBox(4, "MySQL ODBC", "We could not connect to your mysql and either need to install mySQL for ODBC or check to ensure the credentials still work." & $extra)
		If $everConnected = "False" Then
			If $response = 6 Then
				ShellExecute("http://dev.mysql.com/downloads/connector/odbc/")
				Exit
			Else
				Exit
			EndIf
		Else
			_PreferencesMYSQL()
		EndIf
	Else
		IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLEverConnected","True")
	EndIf
	_MySQLEnd($mySQL)
Elseif $localOrDatabaseDriven = "WEBDATABASE" Then
	Global $webUnitTestsAlternativeDataIntegration =  $pathToMain & IniRead("Unit Test Screen Tagger.ini","WEBDATABASE","IntegrationHandler","") & "?user=" & @UserName
Else
	If Not FileExists("Autoit_RichEditCtrl.dll") Then
		MsgBox(0, "Error", "You are missing Autoit_RichEditCtrl.dll in the same directory as this program.  Please click download link on the next web page.")
		ShellExecute("http://unittesttagger.svn.sourceforge.net/viewvc/unittesttagger/Autoit_RichEditCtrl.dll?view=log")
		Exit
	EndIf
EndIf

If $localOrDatabaseDriven = "DATABASEDIRECT" Or $localOrDatabaseDriven = "WEBDATABASE" Then
	Global $webUnitTestsInstallation = $pathToMain & '?user=' & @UserName ; index.php will handle these requests
	Global $ftpServer = IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPServer","")
	Global $ftpUsername = IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPUser","")
	Global $ftpPass = IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPPass","")
	Global $ftpPutDirectory = IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPPutDirectory","")
EndIf

Global $currentScreenshotTitle = ""
Global $sDataDump = $sMainDataDump & @YEAR & "-" & @MON & "-" & @MDAY & "\"
Global $sLog = $sMainDataDump & "UnitTestsScreenCaptures.ini"
Global $TXT = "{\rtf1\fbidis\ansi\ansicpg1256\deff0\deflang8193{\fonttbl{\f0\froman\fcharset0 Times New Roman;}{\f1\fswiss\fcharset0 Arial;}}{\prcolbl}{\*\generator Msftedit 5.41.15.1515;}\viewkind4\uc1\pard\ltrpar\sb100\sa100\cf1\lang1033\f3\"


Global $hUser32 = DllOpen("User32.dll")
Global $hGUI = GUICreate("", @DesktopWidth, @DesktopHeight, 0, 0, -2147483648, 136)
Global $sTempDailyDir = $sMainDataDump & "Temp\"
If Not FileExists($sTempDailyDir) Then DirCreate($sTempDailyDir)
Global $sTempRichText = $sTempDailyDir & "Unit Test Screen TMP " & @MON & "-" & @MDAY & "-" & @YEAR & ".RTF"


If $localOrDatabaseDriven = "LOCAL" Then
;~  INSTALL DLL VERSION COMPATIBLE WITH EMBEDDING WITH THIS CODE
;~ 	$val = IniRead("Unit Test Screen Tagger.ini", "LOCAL", "ReplacedDLL", "None")
;~ 	If $val = "None" Then
;~ 		If FileExists ( @ScriptDir & "\inuse.exe") Then
;~ 			$inUseExeLocation = @ScriptDir & "\inuse.exe"
;~ 		ElseIf FileExists ( @ScriptDir & "\source\inuse.exe" ) Then
;~ 			$inUseExeLocation = @ScriptDir & "\source\inuse.exe"
;~ 		Else
;~ 			$inUseExeLocation = ""
;~ 		EndIf
;~ 		If $inUseExeLocation <> "" Then
;~ 			;there is a certain version of the DLL that is required
;~ 			IniWrite("Unit Test Screen Tagger.ini", "LOCAL", "ReplacedDLL", "True")
;~ 			FileCopy(@SystemDir & "\riched20.dll", @SystemDir & "\riched20.unittestbackup.dll")
;~ 			RunWait(@ComSpec & " /c " & $inUseExeLocation & " riched20.dll " & @SystemDir & "\riched20.dll /y", @ScriptDir)
;~ 		EndIf
;~ 	EndIf
	;SETUP DEFAULTS FOR INITIAL INI FILE
	$val = IniRead("Unit Test Screen Tagger.ini", "LOCAL", "AutoEmbedPics", "None")
	If $val = "None" Then
		IniWrite("Unit Test Screen Tagger.ini", "LOCAL", "AutoEmbedPics", "False")
	Else
		IniWrite("Unit Test Screen Tagger.ini", "LOCAL", "AutoEmbedPics", "True")
	EndIf

	$val = IniRead("Unit Test Screen Tagger.ini", "LOCAL", "GenericText", "None")
	If $val = "None" Then
		IniWrite("Unit Test Screen Tagger.ini", "LOCAL", "GenericText", " Unit Test 1.")
	EndIf

EndIf

TraySetIcon("C:\WINDOWS\system32\SHELL32.dll", 23)
TraySetState()
TraySetToolTip("Unit Test Screen Capture")
TraySetClick(9)

If $localOrDatabaseDriven = "LOCAL" Then
	TrayCreateItem("Open Daily Unit Test Document Buffer In Shell (CTRL+ALT+O)")
	TrayItemSetOnEvent(-1, "_OpenTempFile")
	TrayCreateItem("Show Daily Unit Test Document Buffer")
	TrayItemSetOnEvent(-1, "_ShowUnitTest")
	TrayCreateItem("Preferences")
	TrayItemSetOnEvent(-1, "_PreferencesLocal")
Else
	;@ToDo
	TrayCreateItem("View My Unit Test Documents")
	TrayItemSetOnEvent(-1, "_View")
	TrayCreateItem("Preferences")
	TrayItemSetOnEvent(-1, "_PreferencesAll")
	TrayCreateItem("Embed a file (CTRL+ALT+T)")
	TrayItemSetOnEvent(-1, "_InsertFileLink")
EndIf
TrayCreateItem("View Todays Screenshots")
TrayItemSetOnEvent(-1,"_ViewTodays")
TrayCreateItem("Copy Last File To Clipboard (CTRL+ALT+Z)")
TrayItemSetOnEvent(-1, "_CopyLastFileToClip")
TrayCreateItem("Capture Entire Screen")
TrayItemSetOnEvent(-1, "_Capt")
TrayCreateItem("Capture Partial Screen (HOLD CTRL AND MIDDLE CLICK)")
TrayItemSetOnEvent(-1, "_CaptWnd")
TrayCreateItem("")
TrayCreateItem("Exit (CTRL+ALT+X)")
TrayItemSetOnEvent(-1, "_Exit")
TrayTip("Screen Capture Daemon Running....", "HOLD CTRL and HOLD the middle Mouse click to set your dimensions for a screenshot", 2)
GUICtrlSetResizing(-1, 802)
WinSetTrans($hGUI, "", 1000)



;FORMS
$hWndRichText = GUICreate("Save Daily Unit Test Document", 670, 447, 193, 125)
$Button1 = GUICtrlCreateButton("Load File", 40, 380, 113, 33, 0)
$Button2 = GUICtrlCreateButton("Save File", 168, 380, 113, 33, 0)
$Button3 = GUICtrlCreateButton("Continue Working", 295, 380, 113, 33, 0)
;$Button4 = GUICtrlCreateButton("Copy To Clipboard", 422, 380, 113, 33, 0)
$Button5 = GUICtrlCreateButton("Insert Object", 549, 380, 113, 33, 0)
If $localOrDatabaseDriven = "LOCAL" Then
	$EditSafeHwnd = RichEditCreate(0, 8, 16, 650, 353, $hWndRichText, 0)
EndIf

$hWndRichText2 = GUICreate("Daily Unit Test Temporary Document Buffer", 670, 447, 193, 125)
If $localOrDatabaseDriven = "LOCAL" Then
	$EditSafeHwnd2 = RichEditCreate(0, 8, 16, 650, 353, $hWndRichText2, 0)
EndIf
$Form2 = GUICreate("Load Previous Unit Tests", 577, 70, 193, 125)
$Combo1 = GUICtrlCreateCombo("", 16, 16, 529, 25)
$Button12345 = GUICtrlCreateButton("Prepend", 456, 40, 75, 25, 0)

$Form1 = GUICreate("Functionality/Unit Test", 750, 550, 400, 15)
$task = GUICtrlCreateCombo("", 167, 5, 249, 25)
GUICtrlSetData(-1, $taskItems)
$task_label = GUICtrlCreateLabel("Project/Task", 24, 5, 126, 17)
$functionality = GUICtrlCreateCombo("", 167, 40, 249, 25)
$function_desc_label = GUICtrlCreateLabel("Functionality Section", 24, 40, 126, 17)
$unit_test_desc = GUICtrlCreateEdit("", 168, 70, 249, 129)
$unit_test_label = GUICtrlCreateLabel("Expected Result", 24, 70, 140, 17)
$unit_test_actual = GUICtrlCreateEdit("Results Were As Expected", 168, 202, 249, 129)
$unit_test_actual_label = GUICtrlCreateLabel("Actual Result", 24, 200, 140, 17)
$unit_test_data_input = GUICtrlCreateEdit("Typical Input For Screen", 168, 335, 249, 70)
$unit_test_data_input_label = GUICtrlCreateLabel("Inputs and Data", 24, 335, 140, 17)
$unit_test_remarks = GUICtrlCreateEdit("", 168, 407, 249, 70)
$unit_test_remarks_label = GUICtrlCreateLabel("Remarks", 24, 407, 140, 17)
$unit_test_pass_fail_desc = GUICtrlCreateCombo("Pass", 167, 480, 249, 25)
GUICtrlSetData(-1, "Pass|Fail|In Work|Future Task")
$unit_test_pass_fail_desc_label = GUICtrlCreateLabel("Pass/Fail", 24, 480, 126, 17)
$Pic1 = GUICtrlCreatePic("", 430, 8, 321, 241, BitOR($SS_NOTIFY,$WS_GROUP,$WS_CLIPSIBLINGS))
$copy_to_clip_close = GUICtrlCreateButton("Copy To Clip and Close", 600, 264, 123, 25, 0)
;$copy_to_clip = GUICtrlCreateButton("Copy To Clip", 450, 264, 121, 25, 0)
$copy_to_clip_hopper = GUICtrlCreateButton("Hopper Paste", 450, 264, 121, 25, 0) ;overwrite the old clip with hopper

If $localOrDatabaseDriven = "LOCAL" Then
	$btnText = "Add To Daily Document"
Else
	$btnText = "Add To Database"
EndIf

$add_button = GUICtrlCreateButton($btnText, 256, 515, 155, 25, 0)

If FileExists($sTempRichText) And $localOrDatabaseDriven = "LOCAL" Then
	$response = MsgBox(3, "Temporary RichText Document", "An existing temporary RichText Document was found from today." & @CRLF & @CRLF & "Would you like to load it into your temporary buffer?")
	If $response = 6 Then
		$file = FileOpen($sTempRichText, 0)
		If $file = -1 Then
			MsgBox(0, "Error", "Unable to open file.")
			Exit
		EndIf
		$chars = ""
		While 1
			$chars &= FileRead($file, 1)
			If @error = -1 Then ExitLoop
		WEnd
		FileClose($file)
		SetString($EditSafeHwnd, $chars)
	Else
		FileDelete($sTempRichText)
	EndIf
EndIf

;Load Tasks
$val = IniRead("Unit Test Screen Tagger.ini", "DATABASE", "WebProjectsLoadOnStartUpOrEveryTimeScreenIsTaken", "EMPTY")
If ($val = "STARTUP" And $localOrDatabaseDriven <> "LOCAL" ) Or $val = "EMPTY" Then
	GUICtrlSetData($task, '')
	If $val <> "EMPTY" Or $localOrDatabaseDriven <> "LOCAL"  Then
		FileDelete($sMainDataDump & "tasks.txt")
		$ret = InetGet($pathToWebTaskList, $sMainDataDump & "tasks.txt",1)
		If $ret <> 0 Then
			$hTestInput = FileOpen($sMainDataDump & "tasks.txt", 0)
			If $hTestInput = -1 Then
				MsgBox(8192, "Error", "Unable to open tasks file.")
				Exit
			EndIf
			While 1
				$line = FileReadLine($hTestInput)
				If @error = -1 Then ExitLoop
				$taskItems = $taskItems & $line & "|"
			WEnd
			FileClose($hTestInput)
		Else
			MsgBox(8192, "Error", "Error downloading web task list. Please check your internet connection.")
		EndIf
	EndIf
	$var = IniReadSection($sLog, "Custom Projects")
	If @error Then
		$hasAnyCustomProjects = False
	Else
		$hasAnyCustomProjects = True
		For $i = 1 To $var[0][0]
			$taskItems = $taskItems & "My Projects:" & $var[$i][0] & "|"
		Next
	EndIf
	GUICtrlSetData($task, $taskItems)
EndIf

While 1
	If (_Pressed("Ctrl") And _Pressed("Middle")) Then
		_GrabDimensions()
	ElseIf (_Pressed("alt") And _Pressed("Middle")) Then
		_GrabDimensions()
	ElseIf (_Pressed("shift") And _Pressed("Middle")) Then
		_GrabDimensions()
	ElseIf (_Pressed("win") And _Pressed("Middle")) Then
		_GrabDimensions()
	ElseIf (_Pressed("Ctrl") And _Pressed("print")) Then
		_GrabDimensions()
	ElseIf (_Pressed("shift") And _Pressed("print")) Then
		_GrabDimensions()
	ElseIf (_Pressed("win") And _Pressed("print")) Then
		_GrabDimensions()
	EndIf
	Sleep(10)
WEnd

Func _SetRadioSelect()
    ConsoleWrite(@GUI_CtrlId & @LF)
    $Radio = @GUI_CtrlId
    ConsoleWrite(GUICtrlRead($Radio) & @LF)
EndFunc


Func _PreferencesMYSQL()
	#Region ### START Koda GUI section ### Form=c:\users\dave\desktop\unittesttagger\source\formcode\mysql.kxf
	$mySQL = GUICreate("mySQL Settings", 335, 183, -1, -1)
	$PasswordEdit = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLPass","xxxxPassxxxx"), 96, 80, 233, 21, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
	$ButtonOk = GUICtrlCreateButton("&OK", 254, 152, 75, 25, 0)
	$EnterPassLabel = GUICtrlCreateLabel("Enter password", 8, 84, 77, 17)
	$Label1 = GUICtrlCreateLabel("Enter Username", 8, 48, 80, 17)
	$UserName = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLUser","xxxxUserxxxx"), 96, 48, 233, 21)
	$Label2 = GUICtrlCreateLabel("Enter ServerName", 8, 16, 91, 17)
	$ServerName = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLServer","xxxx.mysqlserver.xxx"), 96, 16, 233, 21)
	$Label3 = GUICtrlCreateLabel("Enter Database", 8, 112, 78, 17)
	$databasename = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLDatabase","xxxxxscreenshotsxxxxx"), 96, 112, 233, 21)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###


	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg

			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE)
				ExitLoop
			Case $ButtonOk

			IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLServer",GUICtrlRead($ServerName))
			IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLUser",GUICtrlRead($UserName))
			IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLPass",GUICtrlRead($PasswordEdit))
			IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLDatabase",GUICtrlRead($databasename))
			IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLTable1","unit_test_screenshots")
			IniWrite("Unit Test Screen Tagger.ini","DATABASEDIRECT","mySQLTable2","unit_test_screenshots_tasks")


			If $localOrDatabaseDriven <> "" Then ; And FileExists("www\settings.php")
				;write out the new connection php file
				msgbox(0,0,0)

				;if attempt direct mysql connection, if connection then add tables


				;attempt to create tables and default data
			EndIf
			$mySQL = _MySQLConnect(GUICtrlRead($UserName), GUICtrlRead($PasswordEdit), GUICtrlRead($databasename), GUICtrlRead($ServerName))
			If $mySQL = 0 And $localOrDatabaseDriven = "DATABASEDIRECT" Then
				msgbox(0,"Could not connect", "We still could not connect, please try again")
			Else
				GUISetState(@SW_HIDE)
				ExitLoop
			EndIf
		EndSwitch
	WEnd

EndFunc

Func _PreferencesFTP()
	IniWrite("Unit Test Screen Tagger.ini","DATABASE","UseFTP","Yes")
	#Region ### START Koda GUI section ### Form=FormCode\FTP.kxf
	$Form1FTP = GUICreate("FTP Settings", 338, 217, -1, -1)
	$PasswordEditFTP = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPPass",""), 96, 80, 233, 21, BitOR($ES_PASSWORD,$ES_AUTOHSCROLL))
	$ButtonOk = GUICtrlCreateButton("&OK", 118, 184, 75, 25, 0)
	$EnterPassLabel = GUICtrlCreateLabel("Enter password", 8, 84, 77, 17)
	$Label1 = GUICtrlCreateLabel("Enter Username", 8, 48, 80, 17)
	$UserNameFTP = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPUser","xxxxFTPUserxxx"), 96, 48, 233, 21)
	$Label2 = GUICtrlCreateLabel("Enter ServerName", 8, 16, 91, 17)
	$ServerNameFTP = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPServer","xxxxxxxxx.com"), 96, 16, 233, 21)
	$Label3 = GUICtrlCreateLabel("Enter the Screenshot PUT directory", 8, 112, 172, 17)
	$ftpdirectory = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASE","FTPPutDirectory","xxxxx.com/html/www/screenshots"), 8, 136, 321, 21)
	$Label4 = GUICtrlCreateLabel("(This directory should be ""screenshots"" relative from WWW)", 24, 168, 288, 17)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $ButtonOk
			IniWrite("Unit Test Screen Tagger.ini","DATABASE","FTPServer",GUICtrlRead($ServerNameFTP))
			IniWrite("Unit Test Screen Tagger.ini","DATABASE","FTPUser",GUICtrlRead($UserNameFTP))
			IniWrite("Unit Test Screen Tagger.ini","DATABASE","FTPPass",GUICtrlRead($PasswordEditFTP))
			IniWrite("Unit Test Screen Tagger.ini","DATABASE","FTPPutDirectory",GUICtrlRead($ftpdirectory))
			GUISetState(@SW_HIDE)
			ExitLoop
		EndSwitch
	WEnd

EndFunc

Func _PreferencesAll()

	#Region ### START Koda GUI section ### Form=FormCode\DatabasePrefs.kxf
	$DatabasePrefs = GUICreate("Database Preferences", 234, 134, 304, 219)
	$Label1 = GUICtrlCreateLabel("mySQL", 40, 24, 38, 17)
	$Button1 = GUICtrlCreateButton("Configure", 112, 16, 75, 25, 0)
	$Label2 = GUICtrlCreateLabel("Document Root", 24, 64, 79, 17)
	$Configure = GUICtrlCreateButton("Configure", 112, 56, 75, 25, 0)
	$Label3 = GUICtrlCreateLabel("FTP Settings", 32, 104, 65, 17)
	$Configuree = GUICtrlCreateButton("Configuree", 112, 96, 75, 25, 0)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg2 = GUIGetMsg()
		Switch $nMsg2
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE)
			Case $Button1
				_PreferencesMYSQL()
				GUISwitch($DatabasePrefs)
				ExitLoop
			Case $Configure
				_PreferencesURL()
				GUISwitch($DatabasePrefs)
				ExitLoop
			Case $Configuree
				_PreferencesFTP()
				GUISwitch($DatabasePrefs)
				ExitLoop
		EndSwitch
	WEnd
	GUISetState(@SW_HIDE)
	GUISwitch($Form1)

EndFunc

Func _PreferencesURL()
	#Region ### START Koda GUI section ### Form=FormCode\ScreenShotURL.kxf
	$ScreenShotURL = GUICreate("Main URL ", 357, 200, 313, 231)
	$GroupBox1 = GUICtrlCreateGroup("", 8, 8, 257, 185)
	$Label1  = GUICtrlCreateLabel("Please now upload the files in WWW folder to your", 16, 32, 244, 17)
	$Label2  = GUICtrlCreateLabel("Apache Web Server.  Go to settings.php also and", 16, 56, 239, 17)
	$Label3  = GUICtrlCreateLabel("Run the table create scripts into your mySQL DB", 16, 80, 232, 17)
	$Label4  = GUICtrlCreateLabel("Now enter the URL of where index.php is found", 16, 136, 229, 17)
	$URL     = GUICtrlCreateInput(IniRead("Unit Test Screen Tagger.ini","DATABASE","WebLocation","http://unittests.xxxxxxxxx.com/"), 16, 160, 233, 21)
	GUICtrlCreateGroup("", -99, -99, 1, 1)
	$Button1 = GUICtrlCreateButton("&OK", 272, 16, 75, 25, 0)
	GUISetState(@SW_SHOW)
	#EndRegion ### END Koda GUI section ###

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $Button1
				IniWrite("Unit Test Screen Tagger.ini","DATABASE","WebLocation",GUICtrlRead($URL))
				GUISetState(@SW_HIDE)
				ExitLoop
		EndSwitch
	WEnd

EndFunc

Func _CopyLastFileToClip()
	if $sFile <> "" Then
		_ImageToClip($sFile)
		TrayTip("Copied to Clipboard", $sFile & @CRLF & @CRLF & "Has been copied to your clipboard.", 4)
	EndIf
EndFunc

Func _GrabDimensions()
	Global $time
	$time = @MON & "-" & @MDAY & "-" & @YEAR & " " & @HOUR & "-" & @MIN & "-" & @SEC
	$sDataDump = $sMainDataDump & @YEAR & "-" & @MON & "-" & @MDAY & "\"
	If Not FileExists($sDataDump) Then
		$res = DirCreate($sDataDump)
	EndIf
	$val = IniRead("Unit Test Screen Tagger.ini", "DATABASE", "WebProjectsLoadOnStartUpOrEveryTimeScreenIsTaken", "EMPTY")
	If ($val <> "STARTUP" And $val <> "EMPTY" ) Then
		GUICtrlSetData($task, '')
		If $val <> "EMPTY" Or $localOrDatabaseDriven <> "LOCAL"  Then
			FileDelete($sMainDataDump & "tasks.txt")
			$ret = InetGet($pathToWebTaskList, $sMainDataDump & "tasks.txt",1)
			If $ret <> 0 Then
				$hTestInput = FileOpen($sMainDataDump & "tasks.txt", 0)
				If $hTestInput = -1 Then
					MsgBox(8192, "Error", "Unable to open tasks file.")
					Exit
				EndIf
				While 1
					$line = FileReadLine($hTestInput)
					If @error = -1 Then ExitLoop
					$taskItems = $taskItems & $line & "|"
				WEnd
				FileClose($hTestInput)
			Else
				MsgBox(8192, "Error", "Error downloading web task list. Please check your internet connection.")
			EndIf
		EndIf
		$var = IniReadSection($sLog, "Custom Projects")
		If @error Then
			$hasAnyCustomProjects = False
		Else
			$hasAnyCustomProjects = True
			For $i = 1 To $var[0][0]
				$taskItems = $taskItems & "My Projects:" & $var[$i][0] & "|"
			Next
		EndIf
		GUICtrlSetData($task, $taskItems)
	EndIf

	$hWnd = WinGetHandle("[active]", "")
	$currentScreenshotTitle = WinGetTitle("[active]")
	WinSetState($hWnd, "", @SW_DISABLE)
	WinSetOnTop("[active]", "", 1)

	$aPos = _GetArea()
	If ($aPos[2] - $aPos[0] < $nClick) Or ($aPos[3] - $aPos[1] < $nClick) Then
		$aPos = WinGetPos($hWnd, "")
		$aPos[2] += $aPos[0]
		$aPos[3] += $aPos[1]
	EndIf
	$sFile = _GetFile()
	_ScreenCapture_Capture($sFile, $aPos[0], $aPos[1], $aPos[2], $aPos[3], False)

	$moveToFile = StringReplace($sFile, ".png", " " & $time & ".png")
	FileMove($sFile, $moveToFile)
	$alsoCopy = IniRead("Unit Test Screen Tagger.ini","Paths","AlsoCopyToWebServer","")
	If $alsoCopy <> "" Then
		FileCopy($moveToFile, $alsoCopy)
	EndIf
	$sFile = $moveToFile
	_WriteLog($sFile, 1)
	Sleep(1000)
	WinSetOnTop($currentScreenshotTitle, "", 0)
	_handleInputs()

EndFunc   ;==>_GrabDimensions

Func _View()
	ShellExecute($webUnitTestsInstallation)
EndFunc   ;==>_View

Func _ViewTodays()
	ShellExecute($sMainDataDump & @YEAR & "-" & @MON & "-" & @MDAY)
EndFunc

Func _ShowUnitTest()
	If FileExists($sTempRichText) Then
		GUISwitch($hWndRichText2)
		LoadFile($EditSafeHwnd2, $sTempRichText, 2)
		GUISetState(@SW_SHOW)
		While 1
			$nMsg = GUIGetMsg()
			Switch $nMsg
				Case $GUI_EVENT_CLOSE
					GUISetState(@SW_HIDE)
					TrayTip("Unit Test Screen Capture", "Continue to take more screenshots to add more to the buffer", 2)
					ExitLoop
			EndSwitch
		WEnd
	EndIf
EndFunc   ;==>_ShowUnitTest

Func _PreferencesLocal()
	$FormPreferences = GUICreate("UnitTest Preferences", 310, 350, -1, -1)
	$Button1 = GUICtrlCreateButton("Update", 120, 300, 100, 40)
	$Label2 = GUICtrlCreateLabel("Generic Unit Text:", 20, 24, 100, 20)
	$autoEmbedPics = GUICtrlCreateCheckbox("", 155, 100, 100, 20)
	$Label5 = GUICtrlCreateLabel("Auto-Embed Pics", 20, 100, 120, 20)
	$genericText = GUICtrlCreateInput("", 120, 20, 150, 20)

	GUISwitch($FormPreferences)
	$val = IniRead("Unit Test Screen Tagger.ini", "LOCAL", "AutoEmbedPics", "False")
	If $val = "True" Then
		GUICtrlSetState($autoEmbedPics, 1)
	Else
		GUICtrlSetState($autoEmbedPics, 0)
	EndIf

	$val = IniRead("Unit Test Screen Tagger.ini", "LOCAL", "GenericText", "Unit Test 1.")
	GUICtrlSetData($genericText, $val)
	GUISetState(@SW_SHOW)

	While 1
		$Msg4 = GUIGetMsg()
		Switch $Msg4
			Case $GUI_EVENT_CLOSE
				GUISetState(@SW_HIDE)
				ExitLoop
			Case $Button1
				IniWrite("Unit Test Screen Tagger.ini", "LOCAL", "GenericText", GUICtrlRead($genericText))
				GUISetState(@SW_HIDE)
				ExitLoop
			Case $autoEmbedPics
				If GUICtrlRead($autoEmbedPics) = 4 Then
					$AutoEmbedPics1 = "False"
				Else
					$AutoEmbedPics1 = "True"
				EndIf
				IniWrite("Unit Test Screen Tagger.ini", "LOCAL", "AutoEmbedPics", $AutoEmbedPics1)
				GUISetState(@SW_HIDE)
				TrayTip("AutoEmbedPics Set to", $AutoEmbedPics1,3)
				ExitLoop
		EndSwitch
	WEnd

EndFunc   ;==>_PreferencesLocal

Func _ReEnableScreen()
	WinSetState($hWnd, "", @SW_ENABLE)
	WinSetOnTop($currentScreenshotTitle, "", 0)
EndFunc

Func ExitScreen()
	_ReEnableScreen()
	$saved = False
	If $localOrDatabaseDriven <> "DATABASEDIRECT" And $localOrDatabaseDriven <> "WEBDATABASE" Then
		$response = MsgBox(3, "Would you like to save off a daily document?", "You are now exiting Unit Test ScreenShots...." & @CRLF & @CRLF & "Would you like to save off a daily document?")
		If $response = 7 Then
			;clicked no... do nothing
			FileDelete($sTempRichText)
			Exit
		ElseIf $response = 6 Then
			;save off document
			GUISwitch($hWndRichText)
			GUISetState(@SW_SHOW)
			While 1
				$nMsg = GUIGetMsg()
				Switch $nMsg
					Case $GUI_EVENT_CLOSE
						If $saved = False Then
							$response = MsgBox(3, "Are you sure you want to close without saving the file?", "Are you sure you want to close without saving the file?")
							If $response = 6 Then
								Exit
							EndIf
						Else
							FileDelete($sTempRichText)
							Exit
						EndIf
					Case $Button1
						#Region ### START Koda GUI section ### Form=
						MsgBox(0, 0, "This code still has some work todo")
						$allFunctionalities = ""
						$var = IniReadSection($sLog, "SavedFiles")
						If @error Then

						Else
							For $i = 1 To $var[0][0]
								$allFunctionalities = $allFunctionalities & $var[$i][1] & "|"
							Next
						EndIf
						GUICtrlSetData($Combo1, $allFunctionalities)
						GUISwitch($Form2)
						GUISetState(@SW_SHOW)
						#EndRegion ### END Koda GUI section ###

						While 1
							$nMsg = GUIGetMsg()
							Switch $nMsg
								Case $GUI_EVENT_CLOSE
									GUISetState(@SW_HIDE)
									GUISwitch($Form1)
									ExitLoop
								Case $Button12345
									If FileExists(GUICtrlRead($Combo1)) Then
										$file = FileOpen(GUICtrlRead($Combo1), 0)
										If $file = -1 Then
											MsgBox(0, "Error", "Unable to open file.")
											Exit
										EndIf
										$chars = ""
										While 1
											$chars &= FileRead($file, 1)
											If @error = -1 Then ExitLoop
										WEnd
										FileClose($file)
										$file = FileOpen($sTempRichText, 0)
										If $file = -1 Then
											MsgBox(0, "Error", "Unable to open file.")
											Exit
										EndIf
										While 1
											$chars &= FileRead($file, 1)
											If @error = -1 Then ExitLoop
										WEnd
										FileClose($file)
										SetString($EditSafeHwnd, $chars)
										LoadFile($EditSafeHwnd, GUICtrlRead($Combo1), 2)
									EndIf
									GUISetState(@SW_HIDE)
									GUISwitch($Form1)
									ExitLoop
							EndSwitch
						WEnd

					Case $Button2
						$var = FileSaveDialog("Choose a name.", @ScriptDir, "File (*.RTF;)", 2)
						If StringInStr(StringUpper($var), "RTF") = 0 Then
							$varFile = $var & ".rtf"
						Else
							$varFile = $var
						EndIf
						If @error Then ContinueLoop
						SaveFile($EditSafeHwnd, $varFile, 2)
						$saved = True
						IniWrite($sLog, "SavedFiles", @MON & "-" & @MDAY & "-" & @YEAR & " " & @HOUR & "-" & @MIN, $varFile)
						FileDelete($sTempRichText)
						Exit

					Case $Button5
						$message = "choose a file."
						$var = FileOpenDialog($message, @ScriptDir & "\", "File All (*.*)", 1)
						If @error Then ContinueLoop

						If FileExists($sFile) Then
							InsertObject($EditSafeHwnd, $var)
						Else
							MsgBox(0, 0, "Error, could not attach inline file into document")
						EndIf
					Case $Button3
						GUISetState(@SW_HIDE)
						ExitLoop
				EndSwitch
			WEnd

			;Exit
		ElseIf $response = 2 Then
			;canceled
		Else
			Exit
		EndIf
	Else
		Exit
	EndIf
EndFunc   ;==>ExitScreen

Func _populateFunctionalitiesList($loadFlag)
	$allFunctionalities = ""
	If $loadFlag = False Then
		; recreate the select box as the user has changed the task
		GUICtrlSetData($functionality, "")
	EndIf
	If GUICtrlRead($task) <> "" Then
		$sFunctionalityINIPointer = StringRegExpReplace(StringStripWS(StringReplace(GUICtrlRead($task),"My Projects:",""), 3), ".*\\", "") & " Functionalities"
		$var = IniReadSection($sLog, $sFunctionalityINIPointer)
		If @error Then

		Else
			For $i = 1 To $var[0][0]
				$allFunctionalities = $allFunctionalities & $var[$i][0] & "|"
			Next
		EndIf
		GUICtrlSetData($functionality, $allFunctionalities)
	EndIf

EndFunc   ;==>_populateFunctionalitiesList

Func _handleInputs($screenShot = 1)
	GUISwitch($Form1)
	_populateFunctionalitiesList(True)
	GUISetState(@SW_SHOW)
	_ImageResize($sFile, $sTempDailyDir & "temp.jpg", 321, 241)
	$ret = GUICtrlSetImage($Pic1,$sTempDailyDir & "temp.jpg")
	If $screenShot = 1 Then
		$lineItemDescription = IniRead($sLog, "Settings", "GenericText", " Unit Test 1.")
	Else
		$lineItemDescription = " Related File 1."
	EndIf

	While 1
		$nMsg = GUIGetMsg()
		Switch $nMsg
			Case $GUI_EVENT_CLOSE
				$val = GUICtrlRead($unit_test_desc)
				if $val <> "" Then
					$response = MsgBox(4, "Close Window", "Are you sure you want to close this window after changing the value of the Expected Results?")
					If $response = 6 Then
						_ReEnableScreen()
						GUISetState(@SW_HIDE)
						ExitLoop
					EndIf
				Else
					_ReEnableScreen()
					GUISetState(@SW_HIDE)
					ExitLoop
				EndIf
			;Case $copy_to_clip
			;	_CopyLastFileToClip()
			Case $copy_to_clip_close
				_CopyLastFileToClip()
				_ReEnableScreen()
				GUISetState(@SW_HIDE)
				ExitLoop
			Case $copy_to_clip_hopper
				_CopyLastFileToClip()
				_ReEnableScreen()
				GUISetState(@SW_HIDE)
				ShellExecute("https://gethopper.com/you")
				WinWait("Hopper")
				Sleep(500)
				Send("{CTRLDOWN}v{CTRLUP}")
				MsgBox(0, "Pasted To Hopper!", "Pasted To Hopper!")
				ExitLoop
			Case $task
				;USER CHANGED TASK OPTION DYNAMICALLY SELECT THEIR FUNCTIONALITIES
				_populateFunctionalitiesList(False)
			Case $add_button
				GUISetState(@SW_HIDE)
				TrayTip("Unit Test Screen Capture", "Saving...dont take another screenshot", 3)
				$sTask = StringReplace(GUICtrlRead($task),"My Projects:","")
				$sFullScreenDescriptionValue = GUICtrlRead($unit_test_desc)
				$sFunctionalitySectionValue = GUICtrlRead($functionality) & " "
				$sFunctionalityINIPointer = StringRegExpReplace(StringStripWS($sTask, 3), ".*\\", "") & " Functionalities"
				If $sFullScreenDescriptionValue <> "" And $sFunctionalitySectionValue <> "" Then
					$var = IniReadSection($sLog, $sFunctionalityINIPointer)
					$sectionNumber = ""
					If @error Then
						$sectionNumber = 1
					Else
						For $i = 1 To $var[0][0]
							If StringStripWS($sFunctionalitySectionValue, 3) = $var[$i][0] Then
								$revision = Int($var[$i][1]) + 1
								$sectionNumber = $revision
							EndIf
						Next
					EndIf
					If $sectionNumber = "" Then
						$sectionNumber = 1
					EndIf

					If $screenShot = 1 Then
						$moveToFile = StringReplace(StringReplace($sFile, " " & @MON & "-" & @MDAY & "-" & @YEAR & " " & @HOUR & "-" & @MIN & "-", " - " & $sFunctionalitySectionValue & " - " & @UserName & " - 1." & $sectionNumber & " " & @MON & "-" & @MDAY & "-" & @YEAR & " " & @HOUR & "-" & @MIN), " ", "_")
						FileMove($sFile, $moveToFile)
						$sFile = $moveToFile
					EndIf
					$sFullScreenDescriptionValue = StringReplace($sFullScreenDescriptionValue, @CRLF, @CRLF & "\par \tab ")

					If $localOrDatabaseDriven = "LOCAL" Then

						$unitTestDesc = "\fs24 \tab " & $sFunctionalitySectionValue & $lineItemDescription & $sectionNumber & " - {\i " & $sFullScreenDescriptionValue & "}"

						$shouldInsert = IniRead($sLog, "Settings", "AutoEmbedPics", "True")
						If FileExists($sTempRichText) Then
							$file = FileOpen($sTempRichText, 0)
							; Check if file opened for reading OK
							If $file = -1 Then
								MsgBox(0, "Error", "Unable to open file.")
								Exit
							EndIf
							$chars = ""
							; Read in 1 character at a time until the EOF is reached
							While 1
								$chars &= FileRead($file, 1)
								If @error = -1 Then ExitLoop
							WEnd
							FileClose($file)

							;now search for the section we are writing
							$hasSection = StringInStr($chars, "\fs40 " & $sFunctionalitySectionValue)
							If $hasSection = 0 Then
								;no match found new section to bottom of file
								If $shouldInsert = "False" Then
									$unitTestDesc &= " - {\i " & $sFullScreenDescriptionValue & "}\par" & "\fs24 \tab {\b Remarks:}         {\i " & GUICtrlRead($unit_test_remarks) & "}\par" & "\fs24 \tab {\b Actual Results:}{\i " & GUICtrlRead($unit_test_actual) & "}\par" & "\fs24 \tab {\b Inputs/Outputs}:{\i " & GUICtrlRead($unit_test_data_input) & "}\par" & "\fs24 \tab {\b Pass/Fail:}         {\i " & GUICtrlRead($unit_test_pass_fail_desc) & "}\par" &"\par " & StringReplace($sFile, "\", "\\") & "\par ________________________________________________________________________\par"
								EndIf
								$newWordDoc = StringReplace($chars, "\par }", "\par\par\fs40 " & $sFunctionalitySectionValue & "\par" & $unitTestDesc & "\par }")
							Else
								$sectionTXT = $sectionNumber
								If $shouldInsert = "False" Then
									$sectionTXT &= " - {\i " & $sFullScreenDescriptionValue & "}\par" & "\fs24 \tab {\b Remarks:}         {\i " & GUICtrlRead($unit_test_remarks) & "}\par" & "\fs24 \tab {\b Actual Results:}{\i " & GUICtrlRead($unit_test_actual) & "}\par" & "\fs24 \tab {\b Inputs/Outputs}:{\i " & GUICtrlRead($unit_test_data_input) & "}\par" & "\fs24 \tab {\b Pass/Fail:}         {\i " & GUICtrlRead($unit_test_pass_fail_desc) & "}\par" & "\par " & StringReplace($sFile, "\", "\\") & "\par ________________________________________________________________________\par"
								EndIf
								$newWordDoc = StringReplace($chars, "\fs40 " & $sFunctionalitySectionValue, "\fs40 " & $sFunctionalitySectionValue & "\par\fs24 \tab " & $sFunctionalitySectionValue & $lineItemDescription & $sectionTXT)
							EndIf



							SetString($EditSafeHwnd, $newWordDoc)

							If FileExists($sFile) Then
								If $shouldInsert = "True" Then
									InsertObject($EditSafeHwnd, $sFile)
								EndIf
							Else
								MsgBox(0, 0, "Error, could not attach inline file into document")
							EndIf
							SaveFile($EditSafeHwnd, $sTempRichText, 2)

							If $hasSection <> 0 Then
								If $shouldInsert = "True" Then
									$file = FileOpen($sTempRichText, 0)
									; Check if file opened for reading OK
									If $file = -1 Then
										MsgBox(0, "Error", "Unable to open file.")
										Exit
									EndIf
									$chars = ""
									; Read in 1 character at a time until the EOF is reached
									While 1
										$chars &= FileRead($file, 1)
										If @error = -1 Then ExitLoop
									WEnd
									FileClose($file)
									$array = StringSplit($chars, "}}}", 1)
									$newFile = ""
									$newEmbedToMoveAround = $array[$array[0] - 1] & "}}}"
									For $i = 1 To $array[0]
										If $i <> $array[0] - 1 And $i <> $array[0] Then
											$newFile &= StringReplace($array[$i], $sFunctionalitySectionValue & $lineItemDescription & $sectionNumber, $sFunctionalitySectionValue & $lineItemDescription & $sectionNumber & " - {\i " & $sFullScreenDescriptionValue & "}\par ________________________________________________________________________\par" & $newEmbedToMoveAround) & "}}}"
										EndIf
									Next
									$newFile &= $array[$array[0]]
									SetString($EditSafeHwnd, $newFile)
									SaveFile($EditSafeHwnd, $sTempRichText, 2)
								EndIf
							EndIf
						Else
							$TXT &= "{\rtf1\ansi{\fonttbl\f0\fcharset0 Times New Roman;}\f0\pard" & @CRLF
							$TXT &= "\fs40 " & $sFunctionalitySectionValue & "\par"
							$TXT &= $unitTestDesc & "\par" & "\fs24 \tab {\b Remarks:}         {\i " & GUICtrlRead($unit_test_remarks) & "}\par" & "\fs24 \tab {\b Actual Results:}{\i " & GUICtrlRead($unit_test_actual) & "}\par" & "\fs24 \tab {\b Inputs/Outputs}:{\i " & GUICtrlRead($unit_test_data_input) & "}\par" & "\fs24 \tab {\b Pass/Fail:}         {\i " & GUICtrlRead($unit_test_pass_fail_desc) & "}\par"
							If $shouldInsert = "False" Then
								$TXT &= " " & StringReplace($sFile, "\", "\\") & "\par "
							EndIf
							$TXT &= "}"
							SetString($EditSafeHwnd, $TXT)
							If FileExists($sFile) Then
								If $shouldInsert = "True" Then
									InsertObject($EditSafeHwnd, $sFile)
								EndIf
							Else
								MsgBox(0, 0, "Error, could not attach inline file into document")
							EndIf
							SaveFile($EditSafeHwnd, $sTempRichText, 2)
						EndIf
					EndIf
					$project = GUICtrlRead($task)

					$foundMatchOfProjects = False
					If $localOrDatabaseDriven <> "LOCAL" Then
						$hTestInput = FileOpen($sMainDataDump & "tasks.txt", 0)
						If $hTestInput = -1 Then
							MsgBox(8192, "Error", "Unable to open tasks file.")
							Exit
						EndIf
						While 1
							$line = FileReadLine($hTestInput)
							If @error = -1 Then ExitLoop
							If $line = $project Then
								$foundMatchOfProjects = True
								ExitLoop
							EndIf
						WEnd
						FileClose($hTestInput)
					Else
						$foundMatchOfProjects = False
					EndIf

					If $foundMatchOfProjects = False Then
						$project = StringReplace($project,"My Projects:","")
						IniWrite($sLog, "Custom Projects", StringRegExpReplace(StringStripWS($project, 3), ".*\\", ""), StringRegExpReplace(StringStripWS($project, 3), ".*\\", ""))
					EndIf

					IniWrite($sLog, $sFunctionalityINIPointer, StringRegExpReplace(StringStripWS(GUICtrlRead($functionality), 3), ".*\\", ""), $sectionNumber)
					If $screenShot = 1 Or $localOrDatabaseDriven = "DATABASEDIRECT" Or $localOrDatabaseDriven = "WEBDATABASE" Then
						$fileName = StringRight($sFile, StringLen($sFile) - StringInStr($sFile, "\", 0, -1))

						$useFTP = IniRead("Unit Test Screen Tagger.ini","DATABASE","UseFTP","")

						If $localOrDatabaseDriven = "DATABASEDIRECT" Then
							$mySQL = _MySQLConnect($mySQLUser, $mySQLPass, $mySQLDatabase, $mySQLServer)
							If $mySQL = 0 Then
								$response = MsgBox(0, "MySQL ODBC", "We could not connect to mysql.  Exiting....")
								Exit
							EndIf
							$totalTasksInMysql = _CountRecords($mySQL, $mySQLUnitTestTaskTable, "task_desc", _mySQLRealEscapeString($sTask))
							If $totalTasksInMysql = 0 Then
								$theQuery = "INSERT INTO `" & $mySQLUnitTestTaskTable & "` (`task_desc`) VALUES ('" & _mySQLRealEscapeString($sTask) & "')"
								$retMySQL = _Query($mySQL, $theQuery)
							EndIf
							$theQuery = "SELECT task_pk FROM `" & $mySQLUnitTestTaskTable & "` WHERE `task_desc` = '" & _mySQLRealEscapeString($sTask) & "'"
							$retMySQL = _Query($mySQL, $theQuery)
							$taskPK = 1
							With $retMySQL
								While Not .EOF
									$taskPK = $retMySQL.Fields('task_pk' ).Value
									.MoveNext
								WEnd
							EndWith
							$theQuery = "INSERT INTO `" & $mySQLUnitTestScreenTable & "` (`task_pk`,`developer`,`functionality`,`unit_test_expected_result`,`unit_test_remarks`,`unit_test_actual_result`,`unit_test_inputs`,`unit_test_pass_fail`,`revision`,`file_name`,`unit_test_time`) VALUES ('" & _mySQLRealEscapeString($taskPK) & "','" & _mySQLRealEscapeString(@UserName) & "','" & _mySQLRealEscapeString(GUICtrlRead($functionality)) & "','" & _mySQLRealEscapeString(GUICtrlRead($unit_test_desc)) & "','" & _mySQLRealEscapeString(GUICtrlRead($unit_test_remarks)) & "','" & _mySQLRealEscapeString(GUICtrlRead($unit_test_actual)) & "','" & _mySQLRealEscapeString(GUICtrlRead($unit_test_data_input)) & "','" & _mySQLRealEscapeString(GUICtrlRead($unit_test_pass_fail_desc)) & "'," & _mySQLRealEscapeString($sectionNumber) & ",'" & _mySQLRealEscapeString($fileName) & "',NOW())"
							$retMySQL = _Query($mySQL, $theQuery)
							_MySQLEnd($mySQL)
						ElseIf $localOrDatabaseDriven = "WEBDATABASE" Then
							If $useFTP = "No" Then
								$fileName = "ScreenShot " & $time & ".png"
							EndIf
							$url = $webUnitTestsAlternativeDataIntegration & "&functionality=" & GUICtrlRead($functionality) & "&project=" & GUICtrlRead($task) & "&unit_test_expected_result=" & StringReplace(GUICtrlRead($unit_test_desc),@CRLF,"{LINE}") & "&unit_test_remarks=" & GUICtrlRead($unit_test_remarks) & "&unit_test_actual_result=" & GUICtrlRead($unit_test_actual) & "&unit_test_inputs=" & GUICtrlRead($unit_test_data_input) & "&unit_test_pass_fail=" & GUICtrlRead($unit_test_pass_fail_desc) & "&revision=" & $sectionNumber & "&file_name=" & $fileName
							InetGet($url,$sTempDailyDir & $fileName & ".webtransaction.txt",1,0)
						EndIf

						If $useFTP = "Yes" Then
							$file = FileOpen($sTempDailyDir & "ftp.txt", 1)
							; Check if file opened for writing OK
							If $file = -1 Then
								MsgBox(0, "Error", "Unable to open file.")
								Exit
							EndIf
							FileWriteLine($file, $ftpUsername & @CRLF)
							FileWriteLine($file, $ftpPass & @CRLF)
							$usePassive = IniRead("Unit Test Screen Tagger.ini","DATABASE","UsePassive","No") ; FYI this is a hidden feature from the preferences... I am lazy
							If $usePassive = "Yes" Then
								FileWriteLine($file, "quote pasv" & @CRLF)
							EndIf
							FileWriteLine($file, "cd """ & $ftpPutDirectory & """" & @CRLF)
							FileWriteLine($file, "binary" & @CRLF)
							FileWriteLine($file, "put """ & $sFile & """" & @CRLF)
							FileWriteLine($file, "quit" & @CRLF)
							FileClose($file)
							RunWait("ftp -s:ftp.txt " & $ftpServer, $sTempDailyDir, @SW_HIDE)
							FileDelete($sTempDailyDir & "ftp.txt")
						EndIf

						GUICtrlSetData($unit_test_desc, "")
						GUICtrlSetData($unit_test_actual, "Results Were As Expected")
						GUICtrlSetData($unit_test_data_input, "Typical Input For Screen")
						GUICtrlSetData($unit_test_remarks, "")

						If $screenShot = 1 Then
							If $useFTP = "Yes" Then
								$txt = @CRLF & @CRLF & " and uploaded to webserver here: " & $ftpPutDirectory & $fileName
							Else
								$txt = ""
							EndIf
							TrayTip("Unit Test Screen Capture", "Image Captured to: " & $sFile & $txt, 5, 1)
						Else
							If $useFTP <> "Yes" Then
								;copy file to todays directory because the person doesnt want to FTP
								FileCopy($sFile,$sMainDataDump & @YEAR & "-" & @MON & "-" & @MDAY)
							EndIf
							TrayTip("External Embedded File", "Your File and descriptions have been added to the unit test database....", 4)
						EndIf
					Else
						TrayTip("External Embedded File", "Your File and descriptions have been added to the daily rich text buffer....", 4)
					EndIf
					WinSetState($hWnd, "", @SW_ENABLE)
					ExitLoop
				Else
					GUISetState(@SW_SHOW)
					MsgBox(0, "Error", "Please make a selection for both the functionality drop down and the expected results.")
				EndIf
			EndSwitch
	WEnd
EndFunc   ;==>_handleInputs

Func _GetFile()
	Return $sDataDump & "ScreenShot.png"
EndFunc   ;==>_GetFile

Func _Pressed($key)
	Switch StringLower($key)
		Case "left"
			$iHex = "01"
		Case "right"
			$iHex = "02"
		Case "middle"
			$iHex = "04"
		Case "ctrl"
			$iHex = "11"
		Case "print"
			$iHex = "2C"
		Case "shift"
			$iHex = "10"
		Case "alt"
			$iHex = "12"
		Case "win"
			$iHex = "5B"
		Case Else
			Return -1
	EndSwitch
	$aIsPressed = DllCall($hUser32, "int", "GetAsyncKeyState", "int", "0x" & $iHex)
	If @error Or (BitAND($aIsPressed[0], 0x8000) <> 0x8000) Then Return 0
	Return 1
EndFunc   ;==>_Pressed

Func _GetArea()
	Local $aPos = MouseGetPos(), $aLast[2] = [-1, -1], $aPosFirst = MouseGetPos(), $aRet[4]
	WinMove($hGUI, "", $aPosFirst[0], $aPosFirst[1], 1, 1)
	GUISetState(@SW_SHOW, $hGUI)

	If _Pressed("Middle") Then
		While _Pressed("Middle")
			$aPos = MouseGetPos()
			If ($aPos[0] <> $aLast[0]) Or ($aPos[1] <> $aLast[1]) Then
				$aRet[0] = $aPosFirst[0]
				$aRet[1] = $aPosFirst[1]

				$aRet[2] = $aPos[0]
				$aRet[3] = $aPos[1]

				If $aRet[0] > $aRet[2] Then
					$tmp = $aRet[0]
					$aRet[0] = $aRet[2]
					$aRet[2] = $tmp
				EndIf
				If $aRet[1] > $aRet[3] Then
					$tmp = $aRet[1]
					$aRet[1] = $aRet[2]
					$aRet[2] = $tmp
				EndIf

				WinMove($hGUI, "", $aRet[0], $aRet[1], $aRet[2] - $aRet[0], $aRet[3] - $aRet[1])
				$aLast = $aPos
			EndIf
			ToolTip("Unit Test Screenshot" & @CRLF & @CRLF & $aRet[2] - $aRet[0] & " x " & $aRet[3] - $aRet[1])
			Sleep(10)
		WEnd
	EndIf
	ToolTip("")
	GUISetState(@SW_HIDE, $hGUI)
	Return $aRet
EndFunc   ;==>_GetArea

Func _WriteLog($sFile, $nType)
	IniWrite($sLog, @MDAY & "." & @MON & "." & @YEAR, @MIN & ":" & @HOUR & "_" & $nType, StringRegExpReplace($sFile, ".*\\", ""))
EndFunc   ;==>_WriteLog

Func _InsertFileLink()
	$clipBoard = ClipGet()
	If StringInStr($clipBoard, ":\") Then
		$response = MsgBox(3, "File In ClipBoard", $clipBoard & @CRLF & @CRLF & "Do you want this file to be embedded into the document?")
		If $response = 6 Then
			$sFile = $clipBoard
		Else
			_handleFileLinks()
		EndIf
	Else
		_handleFileLinks()
	EndIf
	_handleInputs(False)
EndFunc   ;==>_InsertFileLink

Func _handleFileLinks()
	;Send("{CTRLDOWN}{ENTER}{CTRLUP}")
	;$title = WinGetTitle("[active]")
	$message = "Choose a File To Embed."
	While 1
		$sFile = FileOpenDialog($message, @ScriptDir & "\", "File All (*.*)", 1)
		If $sFile = "" Then
			$sFile = FileOpenDialog($message, @ScriptDir & "\", "File All (*.*)", 1)
		Else
			ExitLoop
		EndIf
	WEnd
EndFunc   ;==>_handleFileLinks

Func _Capt()
	$sFile = _GetFile()
	_ScreenCapture_Capture($sFile, 0, 0, @DesktopWidth, @DesktopHeight, False)
	$moveToFile = StringReplace($sFile, ".png", " " & $time & ".png")
	FileMove($sFile, $moveToFile)
	$alsoCopy = IniRead("Unit Test Screen Tagger.ini","Paths","AlsoCopyToWebServer","")
	If $alsoCopy <> "" Then
		FileCopy($moveToFile, $alsoCopy )
	EndIf
	$sFile = $moveToFile
	_WriteLog($sFile, 3)
	_handleInputs()
EndFunc   ;==>_Capt

Func _CaptWnd()
	MsgBox(0, "Info", "To capture a unit test, please hold either CTRL, SHIFT, WINDOWS or ALT plus hold the MIDDLE or RIGHT clicker down while dragging your dimensions across." & @CRLF & @CRLF & "Once you let go a popup will tag your unit test and your thoughts as to what your unit test encompasses.")
	Return
	WinSetTrans($hGUI, "", 20)
	WinMove($hGUI, "", 0, 0, @DesktopWidth, @DesktopHeight)
	GUISetCursor(3, 1, $hGUI)
	GUISetState(@SW_SHOW, $hGUI)
	While Not _Pressed("Left")
	WEnd
	GUISetState(@SW_HIDE, $hGUI)
	GUISetCursor(1, 1, $hGUI)
	MouseClick("")
	$aPos = WinGetPos("[active]")
	WinSetTrans($hGUI, "", 100)
	$aPos[2] += $aPos[0]
	$aPos[3] += $aPos[1]
	$sFile = _GetFile()
	_ScreenCapture_Capture($sFile, $aPos[0], $aPos[1], $aPos[2], $aPos[3], False)

	$moveToFile = StringReplace($sFile, ".png", " " & @MON & "-" & @MDAY & "-" & @YEAR & " " & @HOUR & "-" & @MIN & "-" & @SEC & ".png")
	FileMove($sFile, $moveToFile)
	$alsoCopy = IniRead("Unit Test Screen Tagger.ini","Paths","AlsoCopyToWebServer","")
	If $alsoCopy <> "" Then
		FileCopy($moveToFile, $alsoCopy)
	EndIf
	$sFile = $moveToFile
	_WriteLog($sFile, 4)
	_handleInputs()
EndFunc   ;==>_CaptWnd

Func _OpenLog()
	ShellExecute($sLog)
EndFunc   ;==>_OpenLog

Func _ClearLog()
	FileDelete($sLog)
EndFunc   ;==>_ClearLog

Func _OpenTempFile()
	ShellExecute($sTempRichText)
EndFunc   ;==>_OpenTempFile

Func _Open()
	ShellExecute($sDataDump)
EndFunc   ;==>_Open

Func _Exit()
	ExitScreen()
EndFunc   ;==>_Exit

Func _mySQLRealEscapeString($string)
	$string = StringReplace($string, "'", "''")
	$string = StringReplace($string, "%", "\%")
	$string = StringReplace($string, "\", "\\")
	Return $string
EndFunc   ;==>_mySQLRealEscapeString




;===============================================================================
;
; Function Name:   _ImageToClip
; Description::    Copies all Image Files to ClipBoard
; Parameter(s):    $Path -> Path of image
; Requirement(s):  GDIPlus.au3
; Return Value(s): Success: 1
;                  Error: 0 and @error:
;                          1 -> Error in FileOpen
;                          2 -> Error when setting to Clipboard
; Author(s):
;
;===============================================================================
;
Func _ImageToClip($Path)
    _GDIPlus_Startup()
    Local $hImg = _GDIPlus_ImageLoadFromFile($Path)
    If $hImg = 0 Then Return SetError(1,0,0)
    Global $hBitmap = _GDIPlus_ImageCreateGDICompatibleHBITMAP($hImg)
    _GDIPlus_ImageDispose($hImg)
    _GDIPlus_Shutdown()
    Local $ret = _ClipBoard_SetHBITMAP($hBitmap)
    Return 1
EndFunc

;===============================================================================
;
; Function Name:   _ClipBoard_SetHBITMAP
; Description::    Sets a HBITAMP as ClipBoardData
; Parameter(s):    $hBitmap -> Handle to HBITAMP from GDI32, NOT GDIPlus
; Requirement(s):  ClipBoard.au3
; Return Value(s): Success: 1 ; Error: 0 And @error = 1
; Author(s):       Prog@ndy
; Notes:           To use Images from GDIplus, convert them with _GDIPlus_ImageCreateGDICompatibleHBITMAP
;
;===============================================================================
;
Func _ClipBoard_SetHBITMAP($hBitmap,$Empty = 1)
    _ClipBoard_Open(_AutoItWinGetHandle())
    If $Empty Then _ClipBoard_Empty()
    _ClipBoard_SetDataEx( $hBitmap, $CF_BITMAP)
    _ClipBoard_Close()
    If Not _ClipBoard_IsFormatAvailable($CF_BITMAP)  Then
        Return SetError(1,0,0)
    EndIf
EndFunc

;===============================================================================
;
; Function Name:   _GDIPlus_ImageCreateGDICompatibleHBITMAP
; Description::    Converts a GDIPlus-Image to GDI-combatible HBITMAP
; Parameter(s):    $hImg -> GDIplus Image object
; Requirement(s):  GDIPlus.au3
; Return Value(s): HBITMAP, compatible with ClipBoard
; Author(s):       Prog@ndy
;
;===============================================================================
;

Func _GDIPlus_ImageCreateGDICompatibleHBITMAP($hImg)
    Local $hBitmap2 = _GDIPlus_BitmapCreateHBITMAPFromBitmap($hImg)
    Local $hBitmap = _WinAPI_CopyImage($hBitmap2)
    _WinAPI_DeleteObject($hBitmap2)
    Return $hBitmap
EndFunc

;===============================================================================
;
; Function Name:   _WinAPI_CopyImage
; Description::    Copies an image, also makes GDIPlus-HBITMAP to GDI32-BITMAP
; Parameter(s):    $hImg -> HBITMAP Object, GDI or GDIPlus
; Requirement(s):  WinAPI.au3
; Return Value(s): Succes: Handle to new Bitmap, Error: 0
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _WinAPI_CopyImage($hImg,$uType=0,$x=0,$y=0,$flags=0)
    Local $aResult

    $aResult = DllCall("User32.dll", "hwnd", "CopyImage", "hwnd", $hImg,"UINT",$uType,"int",$x,"int",$y,"UINT",$flags)
    _WinAPI_Check("_WinAPI_CopyImage", ($aResult[0] = 0), 0, True)
    Return $aResult[0]
EndFunc   ;==>_WinAPI_CopyIcon

;===============================================================================
;
; Function Name:   _AutoItWinGetHandle
; Description::    Returns the Windowhandle of AutoIT-Window
; Parameter(s):    --
; Requirement(s):  --
; Return Value(s): Autoitwindow Handle
; Author(s):       Prog@ndy
;
;===============================================================================
;
Func _AutoItWinGetHandle()
    Local $oldTitle = AutoItWinGetTitle()
    Local $x = Random(1248578,1249780)
    AutoItWinSetTitle("qwrzu"&$x)
    Local $x = WinGetHandle("qwrzu"&$x)
    AutoItWinSetTitle($oldTitle)
    Return $x
EndFunc


Func _ImageResize($sInImage, $sOutImage, $iW, $iH)
    Local $hWnd, $hDC, $hBMP, $hImage1, $hImage2, $hGraphic, $CLSID, $i = 0

    ;OutFile path, to use later on.
    Local $sOP = StringLeft($sOutImage, StringInStr($sOutImage, "\", 0, -1))

    ;OutFile name, to use later on.
    Local $sOF = StringMid($sOutImage, StringInStr($sOutImage, "\", 0, -1) + 1)

    ;OutFile extension , to use for the encoder later on.
    Local $Ext = StringUpper(StringMid($sOutImage, StringInStr($sOutImage, ".", 0, -1) + 1))

    ; Win api to create blank bitmap at the width and height to put your resized image on.
    $hWnd = _WinAPI_GetDesktopWindow()
    $hDC = _WinAPI_GetDC($hWnd)
    $hBMP = _WinAPI_CreateCompatibleBitmap($hDC, $iW, $iH)
    _WinAPI_ReleaseDC($hWnd, $hDC)

    ;Start GDIPlus
    _GDIPlus_Startup()

    ;Get the handle of blank bitmap you created above as an image
    $hImage1 = _GDIPlus_BitmapCreateFromHBITMAP ($hBMP)

    ;Load the image you want to resize.
    $hImage2 = _GDIPlus_ImageLoadFromFile($sInImage)

    ;Get the graphic context of the blank bitmap
    $hGraphic = _GDIPlus_ImageGetGraphicsContext ($hImage1)

    ;Draw the loaded image onto the blank bitmap at the size you want
    _GDIPLus_GraphicsDrawImageRect($hGraphic, $hImage2, 0, 0, $iW, $iW)

    ;Get the encoder of to save the resized image in the format you want.
    $CLSID = _GDIPlus_EncodersGetCLSID($Ext)

    ;Generate a number for out file that doesn't already exist, so you don't overwrite an existing image.
    Do
        $i += 1
    Until (Not FileExists($sOP & $i & "_" & $sOF))

    ;Prefix the number to the begining of the output filename
    $sOutImage = $sOP & $sOF

    ;Save the new resized image.
    _GDIPlus_ImageSaveToFileEx($hImage1, $sOutImage, $CLSID)

    ;Clean up and shutdown GDIPlus.
    _GDIPlus_ImageDispose($hImage1)
    _GDIPlus_ImageDispose($hImage2)
    _GDIPlus_GraphicsDispose ($hGraphic)
    _WinAPI_DeleteObject($hBMP)
    _GDIPlus_Shutdown()
EndFunc