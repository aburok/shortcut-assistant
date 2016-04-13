#/::
    helpFileName := GetHelpFilePath()
    if (helpFileName){
	    helpFile := A_ScriptDir "\shortcuts\" helpFileName
        GoSub, READHELP
        GoSub, CREATEGUI
        GoSub, FILLLIST
    }
    else
    {
        MsgBox, No Shortcuts defined for this application.
    }
return

GetHelpFilePath(){
    WinGetClass, windowClass, A
    WinGetTitle , Title, A
    
	file:=""
    if ( windowClass == "rctrl_renwnd32" )
    {
        file := "outlook.help"
    }
    if ( windowClass == "Vim" )
    {
        file :=  "vim.help"
    }
    if (windowClass == "ConsoleWindowClass")
    {
        IfInString, Title, PowerShell
        {
            file :=  "powershell.help"
        }

        file :=  "cmd.help"
    }
    if (windowClass == "CabinetWClass"){
        file :=  "windows7.help"
    }
    if (windowClass == "XLMAIN"){
        file :=  "excel.help"
    }
    if(windowClass == "OpusApp"){
        file :=  "word.help"
    }
    IfInString, Title, Visual Studio
    {
        IfInString, windowClass, HwndWrapper
        {
            file := "vs.help"
        }
    }

    if (RegExMatch(windowClass, "Chrome.*") > 0 ){
        file :=  "Chrome.help"
    }

    if (windowClass == "TTOTAL_CMD") {
        file :=  "shortcuts\totalcmd.help"
    }
    return file
}

CREATEGUI:
    Gui, Font, s10, Verdana
    Gui, Add, Text, , Search :
    Gui, Add, Edit, vFilterText gFILLLIST W1000
    Gui, Add, ListView, grid r20 W1000, Shortcut|Description
    LV_ModifyCol(1, 200)
    Gui, Add, Text,, Working Dir . %A_WorkingDir%
	Gui, Add, Text,, ScriptDir . %A_ScriptDir%
    Gui, Show, , Shortcuts for Outlook from %helpFile%.
return

READHELP:
	Loop, READ, %helpFile%
    {
        Line%A_Index% := A_LoopReadLine
        Line0 = %A_Index%
    }
return

FILLLIST:
    LV_Delete()
    filter := GetFilterText()
    sc := ""
    def := ""
    counter := 1

    Loop, %Line0%
    {
        line := Line%A_Index%
        IF(IsLineForDisplay(line)) {
            if (IsShortCut(line)){
                line := RegExReplace(line, "^\[sc\]\s*")
                sc := sc ?  sc . ";" . line : line
            }
            else if (IsDefinition(line)){
                def := RegExReplace(line, "^\[def\]\s*")
	
                if(IsMatchingFilter(def, filter)){
                    counter := counter + 1
                    LV_Add("", sc, def, counter)
                }

                sc := ""
            }
        }
    }
return

GetFilterText(){
    GuiControlGet, FilterText
    StringReplace, filter, FilterText, %A_Space%, .*, All
    return filter ; if not empty
        ? "i)" . filter ; Add option to ignore case -> i)
        : filter
}

IsLineForDisplay(line)
{
    notEmpty := RegExMatch(line, "^$") == 0
    notComment := RegExMatch(line, "^\s*//") == 0

    return notEmpty && notComment
}

IsShortCut(line){
    return RegExMatch(line, "^\[sc\].*") > 0
}

IsDefinition(line){
    return RegExMatch(line, "^\[def\].*") > 0
}

IsMatchingFilter(line, filter){
    return RegExMatch(line, filter) > 0
}

GuiEscape:
; ExitApp - THIS WILL EXIT ALSO THE AHK PROGRAM, NOT ONLU GUI
IF ( filter )
    GuiControl,, FilterText
ELSE
    ; If the filter box is not empty it will clear it on first Esc
    Gui, Destroy
Return

OnExit:
    Gui, Destroy
return


~^s::
IfWinActive, %A_ScriptName%
{
    SplashTextOn,,,Updated script,
        Sleep, 200
            SplashTextOff
            Reload
}
return
