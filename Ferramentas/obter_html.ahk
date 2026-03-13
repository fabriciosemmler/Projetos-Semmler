#Requires AutoHotkey v2.0
#SingleInstance Force

F11:: {
    ; ==========================================
    ; NOVIDADE 9: Seleção Dinâmica (Via Memória do Sistema)
    ; ==========================================
    ; Lê o caminho da pasta salvo pelo processo anterior
    caminho_memoria := A_ScriptDir "\memoria_pasta.txt"
    
    if not FileExist(caminho_memoria) {
        MsgBox("O arquivo 'memoria_pasta.txt' não foi encontrado. Rode as etapas anteriores primeiro.", "Aviso de Segurança", "Iconi")
        return
    }
    
    pasta_cliente := Trim(FileRead(caminho_memoria, "UTF-8"))
    
    if not DirExist(pasta_cliente) {
        MsgBox("A pasta registrada na memória não existe mais: " pasta_cliente, "Erro de Rota", "IconX")
        return
    }
    
    ; Monta o caminho exato do arquivo de texto
    caminho_txt := pasta_cliente "\lista_concorrentes.txt"
    
    ; Trava de Segurança 1: O arquivo existe na pasta?
    if not FileExist(caminho_txt) {
        MsgBox("O arquivo 'lista_concorrentes.txt' não foi encontrado na pasta do cliente.", "Aviso de Segurança", "Iconi")
        return
    }
    
    ; Trava de Segurança 2: Lê o arquivo e verifica se tem texto dentro
    texto_completo := FileRead(caminho_txt, "UTF-8")
    if (Trim(texto_completo) = "") {
        MsgBox("O arquivo 'lista_concorrentes.txt' está vazio. Adicione os concorrentes antes de iniciar.", "Aviso de Segurança", "Iconi")
        return
    }
    
    ; Fatia as linhas aqui no início para o loop usar mais tarde
    linhas := StrSplit(texto_completo, "`n", "`r")

    ; ==========================================
    ; NOVIDADE 8: Parametrização Dinâmica (Lendo palavras_chave.txt)
    ; ==========================================
    caminho_palavras := pasta_cliente "\palavras_chave.txt"
    
    if not FileExist(caminho_palavras) {
        MsgBox("O arquivo 'palavras_chave.txt' não foi encontrado. Rode a extração de keywords primeiro.", "Aviso de Segurança", "Iconi")
        return
    }
    
    texto_palavras := FileRead(caminho_palavras, "UTF-8")
    
    if (Trim(texto_palavras) = "") {
        MsgBox("O arquivo 'palavras_chave.txt' está vazio.", "Aviso de Segurança", "Iconi")
        return 
    }
    
    ; Fila de palavras: Separa o conteúdo do arquivo pelas vírgulas
    lista_palavras := StrSplit(texto_palavras, ",")

    ; Trava as coordenadas do mouse e do buscador de pixels para a área útil do navegador (Client)
    CoordMode("Mouse", "Client")
    CoordMode("Pixel", "Client") 

    ; 1. Abre o Google Maps
    Run("https://www.google.com.br/maps")
    Sleep(5000)
    
    ; ==========================================
    ; NOVIDADE 5: Criação da Subpasta no Cliente Certo
    ; ==========================================
    pasta_destino := pasta_cliente "\paginas_html"
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
        
        ; ==========================================
        ; Cola o texto e pega do AUTOCOMPLETAR
        ; ==========================================
        SendText(escola)
        
        ; Aguarda o Google abrir o menu suspenso de sugestões
        Sleep(1500) 
        
        ; Aperta para baixo para selecionar a primeira sugestão (o local exato, sem anúncios)
        Send("{Down}")
        Sleep(300)
        
        ; Aperta Enter para entrar direto na página do local
        Send("{Enter}")
        
        ; Aguarda 5 segundos carregando o local
        Sleep(5000)

        ; ==========================================
        ; NOVIDADE 7: Validação de Nicho (Radar Anti-Ruído Blindado)
        ; ==========================================
        A_Clipboard := "" ; Limpa a memória
        
        Send("^a") ; Seleciona todo o texto da tela
        Sleep(300)
        Send("^c") ; Copia para a memória
        Sleep(300)
        Send("{Esc}") ; Tira a marcação azul da tela
        Sleep(300)
        
        passou_no_teste := false ; Começa assumindo que é o local errado
        
        ; Força todo o texto copiado da tela para letras minúsculas
        texto_copiado := StrLower(A_Clipboard)
        
        ; Verifica palavra por palavra da sua lista gerada pelo Python
        For idx, palavra in lista_palavras {
            ; Tira espaços nas pontas e força a palavra-chave para minúscula também
            palavra_limpa := StrLower(Trim(palavra)) 
            
            ; Se encontrar qualquer uma das palavras, aprova o local e para de procurar
            if InStr(texto_copiado, palavra_limpa) {
                passou_no_teste := true
                break 
            }
        }

        ; Se rodou toda a lista e não achou NENHUMA palavra, é lixo. Pula pro próximo.
        if not passou_no_teste {
            continue 
        }

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
            
            ; ==========================================
            ; NOVIDADE 5: Espera Dinâmica (Teste da Porta Trancada)
            ; ==========================================
            Loop {
                Sleep(500) ; Intervalo de meio segundo entre as checagens
                
                ; 1. Confirma se o Chrome já criou o arquivo na pasta
                if FileExist(caminho_salvamento) {
                    try {
                        ; 2. Tenta "abrir a porta" exigindo permissão de escrita ("a" de append)
                        arquivo := FileOpen(caminho_salvamento, "a")
                        
                        ; 3. Se conseguiu abrir, a porta estava destrancada!
                        if (arquivo) {
                            arquivo.Close() ; Fecha a porta imediatamente
                            break ; O download acabou, sai do loop e vai para a próxima escola
                        }
                    }
                }
                
                ; Trava de segurança: Se a internet cair ou o Chrome travar, aborta após 30 segundos
                if (A_Index > 60) {
                    break
                }
            }

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
        AvisoGui := Gui("+AlwaysOnTop -Caption +Border +ToolWindow")
        AvisoGui.BackColor := "1f1f1f"
        AvisoGui.SetFont("s24 cAqua bold", "Segoe UI")
        
        ; Adicionamos uma quebra de linha com a instrução de clique
        ElementoTexto := AvisoGui.Add("Text", "Center w500", texto "`n`n(Clique para fechar)")
        
        ; O gatilho: destrói a interface apenas quando o mouse clicar no texto
        ElementoTexto.OnEvent("Click", (*) => AvisoGui.Destroy())
        
        ; Centraliza perfeitamente na tela (Center) em vez de ficar no topo (y50)
        AvisoGui.Show("AutoSize NoActivate Center")
    }
}

; ==========================================
; NOVIDADE 6: Botão de Pânico (Interrompe o Script)
; Atalho: Esc + F11
; ==========================================
Esc & F11:: {
    SoundBeep(400, 300) ; Toca um bipe grave
    Sleep(100)
    SoundBeep(400, 300) ; Toca o bipe grave de novo (sirene de parada)
    ExitApp ; Mata o processo do script imediatamente
}