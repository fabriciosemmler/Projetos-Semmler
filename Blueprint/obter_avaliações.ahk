#Requires AutoHotkey v2.0
#SingleInstance Force

F11:: {
    ; Trava as coordenadas do mouse e do buscador de pixels para a área útil do navegador (Client)
    CoordMode("Mouse", "Client")
    CoordMode("Pixel", "Client") 

    ; 1. Abre o Google Maps
    Run("https://www.google.com.br/maps")
    Sleep(5000)
    
    ; 2. Lê o arquivo e fatia as linhas
    texto_completo := FileRead("lista_concorrentes.txt", "UTF-8")
    linhas := StrSplit(texto_completo, "`n", "`r")

    ; ==========================================
    ; NOVIDADE 5: Criação da Subpasta
    ; ==========================================
    pasta_destino := A_ScriptDir "\paginas_html"
    if not DirExist(pasta_destino)
        DirCreate(pasta_destino)
    
    ; 3. O Motor de Repetição (Loop)
    For indice, escola in linhas {
        ; Ignora linhas vazias
        if (escola = "")
            continue

        ; Retoma o foco clicando fisicamente dentro da barra de pesquisa
        MouseClick("Left", 620, 210)
        Sleep(300)

        ; Seleciona o que estiver na barra e deleta
        Send("^a")
        Sleep(200)
        Send("{Delete}")
        Sleep(200)
        
        ; Cola o texto da linha atual e aperta Enter
        SendText(escola)
        Sleep(500)
        Send("{Enter}")
        
        ; Aguarda 5 segundos carregando o local
        Sleep(5000)

        ; ==========================================
        ; O Rastreador de Cor (Ctrl+F)
        ; ==========================================
        Send("^f")
        Sleep(500)
        SendText("Avaliações")
        Sleep(1000) 
        
        if PixelSearch(&achouX, &achouY, 0, 0, A_ScreenWidth, A_ScreenHeight, 0xFF9632) {
            Send("{Esc}")
            Sleep(300)
            
            ; Clica exatamente na aba Avaliações
            MouseClick("Left", achouX, achouY)
            Sleep(2500) ; Espera 3 segundos para a lista de avaliações carregar na tela

            ; ==========================================
            ; NOVIDADE 3: Motor de Rolagem Dinâmico (Com Validação)
            ; ==========================================
            contador_fundo := 0 ; Inicia o contador zerado para cada novo local

            Loop {
                Send("{WheelDown 10}") 
                Sleep(800) ; Aguarda a rolagem

                ; Lê a cor na coordenada de controle do fundo
                cor_atual := PixelGetColor(835, 1024)
                
                ; Se a cor for o cinza escuro, soma 1 no contador de confirmação
                if (cor_atual = 0x5E5E5E) {
                    contador_fundo++ 
                } else {
                    ; Se qualquer outra cor aparecer (ex: carregou mais avaliações), zera a contagem
                    contador_fundo := 0 
                }
                
                ; Se o cinza escuro se mantiver por 5 ciclos seguidos, a página realmente acabou
                if (contador_fundo >= 5) {
                    break
                }
                
                ; Trava de segurança limite máximo de 300 rolagens totais
                if (A_Index > 300) {
                    break
                }
            }

            ; ==========================================
            ; NOVIDADE 4: Salvar Página (Ctrl + S)
            ; ==========================================
            ; Prepara o nome do arquivo direcionando para a nova subpasta
            caminho_salvamento := pasta_destino "\local " indice ".html"
            
            ; Prevenção: Se o arquivo já existir de um teste anterior, deleta para não travar na tela de "Substituir?"
            if FileExist(caminho_salvamento)
                FileDelete(caminho_salvamento)

            ; Chama o Salvar Como
            Send("^s")
            Sleep(1500) ; Aguarda a janela do Windows abrir
            
            ; Digita o caminho completo para garantir que caia na pasta certa
            SendText(caminho_salvamento)
            Sleep(500)
            Send("{Enter}")
            
            ; Aguarda 3 segundos para o navegador terminar de baixar o arquivo HTML
            Sleep(3000)

        } else {
            Send("{Esc}")
            Sleep(300)
        }
        
        ; Aguarda 5 segundos antes de ir para a próxima escola do txt
        Sleep(5000)
    }
    
    ; 4. Finalização: Alerta visual e sonoro de conclusão
    SoundBeep(750, 500) ; Toca um bipe de 750Hz por meio segundo
    ExibirAvisoGrande("Extração Concluída!")
}


; ==========================================
; FUNÇÕES AUXILIARES
; ==========================================
ExibirAvisoGrande(texto) {
    try {
        AvisoGui := Gui("+AlwaysOnTop -Caption +ToolWindow")
        AvisoGui.BackColor := "1f1f1f"
        AvisoGui.SetFont("s24 cAqua bold", "Segoe UI")
        AvisoGui.Add("Text", "Center w500", texto)
        AvisoGui.Show("AutoSize NoActivate y50")
        SetTimer () => AvisoGui.Destroy(), -3000
    }
}