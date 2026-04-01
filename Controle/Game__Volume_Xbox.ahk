#Requires AutoHotkey v2.0
#SingleInstance Force

; ---------------------------------------------------------
; MÓDULO OSD (Exibição em tela leve e cirúrgica)
; ---------------------------------------------------------
MostrarVolume() {
    ; Captura o volume atual da placa de som e arredonda para um número inteiro limpo
    VolumeAtual := Round(SoundGetVolume())
    
    ; Exibe um balãozinho flutuante
    ToolTip("Volume: " VolumeAtual "%")
    
    ; O timer com valor negativo (-1500) apaga o balão automaticamente após 1.5 segundos
    SetTimer(EsconderToolTip, -1500)
}

EsconderToolTip() {
    ToolTip() ; Enviar o comando vazio destrói o balão da memória
}

; ---------------------------------------------------------
; MÓDULO XINPUT (Steam/Xbox - Ajuste exato de 1%)
; L2 (LT) = Eixo Z | R2 (RT) = Eixo R | Botão X (A do Xbox) = Joy1
; ---------------------------------------------------------

; O botão X é o disparador principal
Joy1:: 
{
    ; Lê a posição dos eixos analógicos
    EixoZ := GetKeyState("JoyZ")
    EixoR := GetKeyState("JoyR")
    
    ; TRAVA DE SEGURANÇA: Garante que os gatilhos estão enviando números válidos
    if IsNumber(EixoZ) and IsNumber(EixoR) {
        
        ; L2 puxado (Z > 70) + botão X apertado: Abaixa 1 ponto
        if (EixoZ > 70) {
            SoundSetVolume("-1")
            MostrarVolume() ; Invoca o feedback visual instantaneamente
            KeyWait("Joy1") ; Trava cirúrgica: obriga a soltar o botão X
        }
        
        ; R2 puxado (R > 70) + botão X apertado: Aumenta 1 ponto
        else if (EixoR > 70) {
            SoundSetVolume("+1")
            MostrarVolume() ; Invoca o feedback visual instantaneamente
            KeyWait("Joy1") 
        }
    }
}