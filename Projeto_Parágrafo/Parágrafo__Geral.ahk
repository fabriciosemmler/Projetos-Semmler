#Requires AutoHotkey v2.0
#SingleInstance Force

global ModoParagrafo := false
global AbaSalva := ""

^F12:: {
    global ModoParagrafo := true
    global AbaSalva := WinGetTitle("A")
    SetTimer(VerificaAbaChrome, 250)

    ; Passo 1: Descobre a pasta exata onde ESTE script (.ahk) está salvo
    SplitPath(A_LineFile, , &PastaAtual)
    
    ; Passo 2: Lê o JS garantindo que ele o procure na mesma pasta
    jsCode := RegExReplace(FileRead(PastaAtual "\modo_paragrafo.js"), "\R", " ")

    SavedClip := A_Clipboard
    A_Clipboard := jsCode
    ClipWait(1)
    Send("^l")              
    Sleep(100)
    SendText("javascript:") 
    Send("^v")              
    Sleep(100)
    Send("{Enter}")         

    Sleep(100)
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    A_Clipboard := SavedClip 
}

^F13:: {
    global ModoParagrafo := false
    SetTimer(VerificaAbaChrome, 0)
    global AbaSalva := ""
    Send("{F5}") ; Recarrega a página para sair do Modo Parágrafo
}

; =======================================================
; MODO PARÁGRAFO GEMINI (Injeção via Console) - Shift+F2
; =======================================================
!F12:: {
    global ModoParagrafo := true
    global AbaSalva := WinGetTitle("A")
    SetTimer(VerificaAbaChrome, 250)

    SplitPath(A_LineFile, , &PastaAtual)
    jsCode := FileRead(PastaAtual "\modo_paragrafo_gemini.js") 

    SavedClip := ClipboardAll() 
    A_Clipboard := "" 
    A_Clipboard := jsCode
    ClipWait(1)
    
    Send("^+j")             ; Abre o Console (Ctrl+Shift+J)
    Sleep(1000)             ; Aguarda o painel abrir
    Send("^v")              ; Cola o código limpo
    Sleep(200)              
    Send("{Enter}")         ; Executa
    Sleep(200)
    Send("^+j")             ; Fecha o Console

    Sleep(200)              
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    A_Clipboard := SavedClip 
}

!F13:: {
    global ModoParagrafo := false
    SetTimer(VerificaAbaChrome, 0)
    global AbaSalva := ""
    Send("{F5}") 
}

VerificaAbaChrome() {
    global ModoParagrafo, AbaSalva
    if WinActive("ahk_exe chrome.exe") {
        if (WinGetTitle("A") == AbaSalva) {
            ModoParagrafo := true
        } else {
            ModoParagrafo := false
        }
    }
}

; --- NAVEGAÇÃO ERGONÔMICA (SÓ FUNCIONA COM MODO PARÁGRAFO ATIVO) ---
#HotIf WinActive("ahk_exe chrome.exe") && ModoParagrafo
$Capslock::
$a::
{
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    Send("{Blind}a")
}
$Space::
{
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    Send("{Blind}{Space}")
}

; --- ANOTAÇÃO RÁPIDA PARA O OBSIDIAN E CRIAÇÃO DE ARQUIVO NO VS CODE ---
NumpadAdd::
RButton::
{
    janelaOriginal := WinGetID("A")
    
    A_Clipboard := ""
    Sleep(50)
    Send "^c"
    
    if !ClipWait(1) {
        return 
    }
    
    ; --- INÍCIO DO TRATAMENTO DE TEXTO ---
    textoTratado := Trim(A_Clipboard, " `t`r`n")
    
    textoTratado := StrUpper(SubStr(textoTratado, 1, 1)) . SubStr(textoTratado, 2)
    
    if (SubStr(textoTratado, -1) != ".") {
        textoTratado .= "."
    }
    
    A_Clipboard := textoTratado
    ; --- FIM DO TRATAMENTO DE TEXTO ---
    
if WinExist("ahk_exe Obsidian.exe") {
        WinActivate "ahk_exe Obsidian.exe"
        
        ; Aguarda até 2 segundos para garantir que o Obsidian está realmente focado e pronto
        if WinWaitActive("ahk_exe Obsidian.exe", , 2) {
            Sleep 100 ; Pequena pausa de segurança para o buffer do teclado do Windows
            Send "^v"
            Sleep 100
            Send "{Enter}" ; Envia os dois Enters de forma limpa e econômica
            Sleep 100
            
            WinActivate "ahk_id " janelaOriginal
        }
    
    } else {
        MsgBox "O Obsidian não parece estar aberto.", "Aviso de Anotação"
    }
}

NumpadSub:: {
    A_Clipboard := ""
    Send "^c"
    
    if !ClipWait(1) {
        return 
    }
    
    Sleep(100)
    
    if WinExist("ahk_exe Code.exe") {
        WinActivate "ahk_exe Code.exe"
    } else {
        Run "code"
    }
    
    ; Aguarda até 3 segundos para garantir que o VS Code abriu/está em foco
    if WinWaitActive("ahk_exe Code.exe", , 3) {
        Sleep(100)
        Send "^1"
        Sleep(100)
        Send "^n"
        Sleep(100)
        Send "^v"
        Sleep(100)
        Send "^s"
        Sleep(300)
        SendText("*.cpp")
        Sleep(100)
        Send("{Tab 3}")
        Sleep(100)
        Send "{Enter}"
    }
}

#HotIf
