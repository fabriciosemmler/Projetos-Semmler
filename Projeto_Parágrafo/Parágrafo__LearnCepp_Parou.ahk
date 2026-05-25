#Requires AutoHotkey v2.0
#SingleInstance Force

AutoHide := "C:\Scripts\AutoHideMouseCursor_x64_p.exe"
; Define the save file location
saveFile := A_ScriptDir "\Progress.ini"

; --- SAVE PROGRESS ---
#HotIf WinActive("ahk_exe chrome.exe")
$^w:: {
    ; 1. Backup everything on the clipboard securely
    savedClip := ClipboardAll()
    A_Clipboard := ""
    
    ; 2. Highlight and copy the URL bar
    Send("^l")
    Sleep(50)
    Send("^c")
    
    ; 3. Wait for data, then check if it's the target site
    if ClipWait(0.5) {
        if InStr(A_Clipboard, "learncpp.com") {
            IniWrite(A_Clipboard, saveFile, "LearnCPP", "LastURL")
        }
    }
    
    ; 4. Restore exact previous clipboard state and close tab
    A_Clipboard := savedClip
    Send("^w")
}
#HotIf

; --- LOAD PROGRESS ---
^F11:: {
    ; Read the saved URL, defaulting to a blank string if not found
    savedURL := IniRead(saveFile, "LearnCPP", "LastURL", "")
    
    if (savedURL != "") {
        Run(savedURL)
        Run(AutoHide)
    } else {
        MsgBox("No LearnCPP progress saved yet!")
    }
}