#Requires AutoHotkey v2.0
#SingleInstance Force

global ModoParagrafo := false
global AbaSalva := ""

^F12:: {
    global ModoParagrafo := true
    global AbaSalva := WinGetTitle("A")
    SetTimer(VerificaAbaChrome, 250)

    SplitPath(A_LineFile, , &PastaAtual)
    jsCode := FileRead(PastaAtual "\modo_paragrafo_git.js") 

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
    Send("^+j")
    Sleep(200)             ; Fecha o Console
    
    ; A LINHA 'Send("{Home}")' FOI REMOVIDA DAQUI PARA NÃO RESETAR A PÁGINA

    Sleep(200)              
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
    Send("^+j")
    Sleep(200)             ; Fecha o Console
    Send("{Home}")

    Sleep(200)              
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    A_Clipboard := SavedClip 
}

!F13:: {
    global ModoParagrafo := false
    SetTimer(VerificaAbaChrome, 0)
    global AbaSalva := ""
    Send("{F5}") 
    Sleep(500)
    
    ; Move o mouse para onde a caixa de texto do Gemini vai aparecer
    MouseMove(580, 830)
    
    ; Move o mouse e espera até o cursor virar o seletor de texto ("IBeam")
    while (A_Cursor != "IBeam")
    {
        MouseMove(600, 830)
        Sleep(100)
        MouseMove(580, 830)
    }

    ; Página carregada! Retoma o seu script original
    MouseMove(A_ScreenWidth - 150, A_ScreenHeight / 2)
    Sleep(200)
    MouseClick("left")
    Sleep(200)
    Send("{End}")
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

; A ALTERAÇÃO FOI FEITA NA LINHA ABAIXO:
#HotIf (WinActive("ahk_exe chrome.exe") && ModoParagrafo) || WinActive("Microsoft Learn")

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
            Sleep (100) ; Pequena pausa de segurança para o buffer do teclado do Windows
            Send "^v"
            Sleep (100)
            Send "{Enter}" ; Envia os dois Enters de forma limpa e econômica
            Sleep (100)
            
            WinActivate "ahk_id " janelaOriginal
        }
    
    } else {
        MsgBox "O Obsidian não parece estar aberto.", "Aviso de Anotação"
    }
}

NumpadSub:: {

    janelaOriginalCode := WinGetID("A")
    
    A_Clipboard := ""
    Send "^c"
    
    if !ClipWait(1) {
        return 
    }
    
    Sleep(100)
    
    ; Remove espaços e quebras de linha extras das pontas
    textoTratado := Trim(A_Clipboard, " `t`r`n")
    
    ; Usa Chr(96) para gerar as 3 crases (```) de forma segura e evitar o erro de sintaxe
    crases := Chr(96) Chr(96) Chr(96)
    A_Clipboard := crases . "shell" . "`n" . textoTratado . "`n" . crases
    
    ; Targets Obsidian
    if WinExist("ahk_exe Obsidian.exe") {
        WinActivate "ahk_exe Obsidian.exe"
    } else {
        MsgBox 'O Obsidian não parece estar aberto.'
        return
    }
    
    ; Waits up to 3 seconds for Obsidian to be in focus, pastes, and presses Enter
    if WinWaitActive("ahk_exe Obsidian.exe", , 3) {
        Sleep(100)
        Send "^v"
        Sleep(100)
        Send "{Enter}"
        Sleep(100)

        WinActivate "ahk_id " janelaOriginalCode
    }
}
#HotIf
