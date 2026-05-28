#Requires AutoHotkey v2.0
#SingleInstance Force

; Define the save file location
saveFile := A_ScriptDir "\Progress.ini"

; --- SAVE PROGRESS ---
#HotIf WinActive("ahk_exe chrome.exe")
$^w::
^+w:: {
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
    
    ; 4. Restore exact previous clipboard state
    A_Clipboard := savedClip
    
    ; 5. Only close the tab if Ctrl+W was used
    Send("{Escape 2}")
    if (A_ThisHotkey = "$^w") {
        Send("^w")
        ProcessClose("AutoHideMouseCursor_x64_p.exe")
    }
}
#HotIf

; --- LOAD PROGRESS ---
^F11:: {
    ; Read the saved URL, defaulting to a blank string if not found
    savedURL := IniRead(saveFile, "LearnCPP", "LastURL", "")
    
    if (savedURL != "") {
        Run(savedURL)
        
        ; --- NOVO: Automação do Modo Parágrafo ---
        ; Aguarda até 3 segundos para o Chrome ficar ativo
        if WinWaitActive("ahk_exe chrome.exe", , 3) {
            Sleep(2000)      ; Espera 2 segundos para o site carregar
            Send("^{F12}")   ; Dispara o seu atalho do Modo Parágrafo automaticamente
        }

    } else {
        MsgBox("No LearnCPP progress saved yet!")
    }
}