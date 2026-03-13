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

        ; ==========================================
        ; TRAVA DE SEGURANÇA MÁXIMA (O "Faxineiro")
        ; ==========================================
        ; Se por algum erro bizarro a janela "Salvar como" do ciclo anterior ficou aberta, extermina ela.
        ; ahk_class #32770 é o código universal do Windows para caixas de diálogo (Salvar/Abrir).
        if WinExist("ahk_class #32770") {
            WinClose("ahk_class #32770")
            Sleep(500)
        }

        ; ==========================================
        ; NAVEGAÇÃO DIRETA (VIA URL)
        ; ==========================================
        ; Foca na barra de endereços do navegador (Ctrl+L)
        Send("^l")
        Sleep(300)
        
        ; Digita a URL exata do concorrente
        SendText(escola)
        Sleep(300)
        
        ; Aperta Enter para ir direto para o local sem passar pela pesquisa
        Send("{Enter}")
        
        ; Aguarda o local carregar completamente
        Sleep(4000)

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
            ; NOVIDADE 4: Salvar Página (Ctrl + S) COM BLINDAGEM
            ; ==========================================
            ; Prepara o nome do arquivo direcionando para a nova subpasta
            caminho_salvamento := pasta_destino "\local " indice ".html"
            
            ; Prevenção: Se o arquivo já existir de um teste anterior, deleta para não travar na tela de "Substituir?"
            if FileExist(caminho_salvamento)
                FileDelete(caminho_salvamento)

            ; Chama o Salvar Como
            Send("^s")
            
            ; AJUSTE CIRÚRGICO: Fim da "Espera Cega" (Substitui o antigo Sleep(1500))
            ; O script aguarda até 15 segundos pela janela de salvamento e SÓ AVANÇA quando ela estiver ativa
            if WinWaitActive("ahk_class #32770", , 15) {
                Sleep(800) ; Respiro de segurança para o Windows focar na caixa de texto
                
                ; Digita o caminho completo para garantir que caia na pasta certa
                SendText(caminho_salvamento)
                Sleep(500)
                Send("{Enter}")
                
                ; A SEGUNDA TRAVA: Cruza os braços e SÓ AVANÇA quando a janela fechar de verdade
                WinWaitClose("ahk_class #32770", , 15)
            } else {
                ; Se a internet ou o Chrome travarem e a janela não abrir, aperta Esc para desbugar e pula
                Send("{Esc}")
                Sleep(300)
            }
            
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
    
    ; ==========================================
    ; MÓDULO DE INTEGRAÇÃO: Dispara o extrator de avaliações (Python)
    ; ==========================================
    caminho_python := A_ScriptDir "\extrair_avaliacoes.py"
    if FileExist(caminho_python) {
        ; Executa o Python de forma invisível e aguarda ele terminar
        RunWait("py `"" caminho_python "`"", A_ScriptDir, "Hide")
    } else {
        MsgBox("Aviso: 'extrair_avaliacoes.py' não encontrado na pasta de Ferramentas.", "Alerta de Integração", "Icon!")
    }

    ; 4. Finalização: Alerta visual e sonoro de conclusão
    SoundBeep(750, 500) ; Toca um bipe de 750Hz por meio segundo
    ExibirAvisoGrande("Processo 100% Concluído!`nO AutoHotkey baixou as páginas e o Python extraiu as avaliações.")
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

; ==========================================
; FASE 3: Injetor do Prompt de Análise (Atalho: Ctrl + F18)
; ==========================================
^F18:: {
    prompt_analise := "
    (
Atuo com automação e inteligência de mercado para pequenos empresários. Preciso que você analise o arquivo 'reviews_concorrentes.txt' para extrair os padrões de comportamento dos clientes.

Gere um rascunho de relatório focado em clareza e valor estratégico. Esse texto será enviado via WhatsApp para minha sócia fazer a redação humana e a aprovação final.

Diretrizes de formatação:
- Seja direto, analítico e use linguagem simples.
- Não use negrito ou formatações complexas (apenas texto puro).
- REGRA DE OURO: É estritamente proibido incluir citações de fontes. Não insira números de referência, colchetes, [source] ou [cite] no meio do texto. O texto deve ser 100% limpo.
- Separe o conteúdo claramente nos três blocos abaixo para facilitar a revisão dela.
- Siga exatamente esta estrutura de saída:

= INSIGHTS = [Escreva aqui 3 tópicos curtos apontando as maiores oportunidades e gargalos do mercado local]

= MAIS ELOGIADO = [Escreva aqui 1 parágrafo focado no que os clientes mais valorizam e elogiam nos concorrentes]

= MAIS CRITICADO = [Escreva aqui 1 parágrafo focado nas maiores falhas, frustrações e motivos de cancelamento nos concorrentes]

O texto deve ser bonito, simples e fácil de copiar e colar no whatsapp para editar. Coloque a resposta inteira dentro de um bloco de código.
    )"
    
    A_Clipboard := prompt_analise
    Sleep(100)
    Send("^v")
    SoundBeep(800, 150)
}

; ==========================================
; FASE 4: Faxineiro de Citações para WhatsApp
; ==========================================
^!l:: {
    texto_sujo := A_Clipboard
    
    ; 1. Varredura RegEx: O '.*?' captura absolutamente tudo (números, vírgulas, espaços) até fechar o colchete
    texto_limpo := RegExReplace(texto_sujo, "\[" "source:.*?\]", "")
    texto_limpo := RegExReplace(texto_limpo, "\[" "cite:.*?\]", "")
    
    ; Pega também os casos onde a IA joga só os números com vírgula, tipo [1, 2, 3]
    texto_limpo := RegExReplace(texto_limpo, "\[[0-9,\s]+\]", "")
    
    ; 2. Limpeza de resíduos: Remove espaços duplos que ficaram no lugar das citações
    texto_limpo := RegExReplace(texto_limpo, " {2,}", " ")
    
    ; 3. Devolve o texto cristalino para a memória
    A_Clipboard := Trim(texto_limpo)
    
    ; 4. Feedback sonoro duplo (Aviso de que a limpeza terminou)
    SoundBeep(900, 150)
    Sleep(50)
    SoundBeep(1200, 150)
}

