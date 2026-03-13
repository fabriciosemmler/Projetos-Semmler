#Requires AutoHotkey v2.0
#SingleInstance Force
global pasta_cliente := ""
global GuiInstrucoes := ""

; ==========================================
; FASE 1: Preparação e Prompt (Atalho: F19)
; ==========================================
F19:: {
    global pasta_cliente, GuiInstrucoes
    
    ; 1. Lê a memória deixada pelo iniciar_projeto.py
    caminho_memoria := A_ScriptDir "\memoria_pasta.txt"
    
    if not FileExist(caminho_memoria) {
        MsgBox("O arquivo 'memoria_pasta.txt' não foi encontrado. Rode o iniciar_projeto.py primeiro.", "Aviso de Segurança", "Iconi")
        return
    }
    
    pasta_cliente := Trim(FileRead(caminho_memoria, "UTF-8"))
    
    if not DirExist(pasta_cliente) {
        MsgBox("A pasta registrada na memória não existe mais: " pasta_cliente, "Erro de Rota", "IconX")
        return
    }

    ; 2. Caça o arquivo INI curinga na pasta do cliente
    caminho_ini := ""
    Loop Files, pasta_cliente "\projeto*.ini" {
        caminho_ini := A_LoopFilePath
        break ; Pega o primeiro que encontrar
    }

    if (caminho_ini = "") {
        MsgBox("Nenhum arquivo 'projeto*.ini' foi encontrado na pasta do cliente.", "Erro de Inicialização", "IconX")
        return
    }

    ; Extrai o ramo de atuação diretamente do INI (sem pop-ups)
    ramo_cliente := IniRead(caminho_ini, "PROJETO", "ramo", "ERRO")
    
    if (ramo_cliente = "ERRO" or ramo_cliente = "") {
        MsgBox("O ramo não foi encontrado no arquivo INI.", "Erro de Leitura", "IconX")
        return
    }

    ; 3. Monta o prompt cirúrgico com a variável injetada
    prompt := "Meu cliente é uma " ramo_cliente ". Faça uma lista de concorrentes operacionais em São Paulo, SP (entre 25 a 30 concorrentes).`nRegra de ouro: Para que a automação encontre o local exato no Google Maps sem ambiguidade, você deve incluir obrigatoriamente o BAIRRO de cada unidade.`n`nO resultado deve ser apenas o texto, com um concorrente em cada linha, no seguinte formato:`n[Nome da Empresa] [Bairro] São Paulo SP`n`nExemplo:`nOMO Lavanderia Self-Service Vila Mariana São Paulo SP`nLavanderia 60 Minutos Pinheiros São Paulo SP`n`nEnvie a resposta obrigatoriamente dentro de um bloco de código."

    ; 4. Joga o prompt pronto para a memória (Área de Transferência)
    A_Clipboard := prompt
    
    ; 5. Verifica se a aba da conversa já está aberta
    SetTitleMatchMode(2)
    if WinExist("Google Gemini") {
        WinActivate("Google Gemini")
    } else {
        Run("https://gemini.google.com/app/2267c167a9509945")
    }
    
    ; Aguarda 1 segundo para o navegador abrir e puxar o foco
    Sleep(1000)
    
    ; 6. Aviso de instrução (Interface Própria Não-Bloqueante)
    if GuiInstrucoes {
        try GuiInstrucoes.Destroy()
    }
    
    GuiInstrucoes := Gui("+AlwaysOnTop -Caption +Border +ToolWindow")
    GuiInstrucoes.BackColor := "1f1f1f"
    GuiInstrucoes.SetFont("s12 cAqua bold", "Segoe UI")
    
    texto_instrucao := "Prompt copiado para a memória!`n`n1. Cole (Ctrl+V) no Gemini e dê Enter.`n2. Quando a IA terminar de escrever, clique em 'Copiar'.`n3. Pressione Ctrl + F19 para salvar."
    GuiInstrucoes.Add("Text", "Center w400", texto_instrucao)
    
    ; Calcula a posição para grudar na direita
    pos_x := A_ScreenWidth - 450
    GuiInstrucoes.Show("AutoSize NoActivate x" pos_x " y50")
}

; ==========================================
; FASE 2: Captura e Salvamento (Atalho: Ctrl + F19)
; ==========================================
^F19:: {
    global pasta_cliente, GuiInstrucoes
    
    ; Se o F19 não foi rodado, tenta ler a memória novamente como trava de segurança
    if (pasta_cliente = "") {
        caminho_memoria := A_ScriptDir "\memoria_pasta.txt"
        if FileExist(caminho_memoria) {
            pasta_cliente := Trim(FileRead(caminho_memoria, "UTF-8"))
        } else {
            MsgBox("Nenhuma pasta na memória. Use o F19 primeiro.", "Aviso de Segurança", "IconX")
            return
        }
    }

    ; 1. Pega o texto que você copiou do Gemini
    texto_limpo := A_Clipboard
    
    ; 2. Limpeza cirúrgica: Remove blocos de código markdown
    texto_limpo := StrReplace(texto_limpo, "``````text", "")
    texto_limpo := StrReplace(texto_limpo, "``````", "")
    texto_limpo := Trim(texto_limpo)

    ; 3. Monta o caminho exato do arquivo
    caminho_txt := pasta_cliente "\lista_concorrentes.txt"
    
    if FileExist(caminho_txt) {
        FileDelete(caminho_txt)
    }
        
    ; 4. Cria o arquivo
    FileAppend(texto_limpo, caminho_txt, "UTF-8")
    
    ; 5. Finalização
    if GuiInstrucoes {
        try GuiInstrucoes.Destroy()
        GuiInstrucoes := ""
    }
    
    SoundBeep(750, 500)
    MsgBox("Sucesso! 'lista_concorrentes.txt' salvo blindado na pasta do cliente.", "Passo 2 Concluído", "Iconi 262144")
    
    pasta_cliente := ""
}

!v::GuiInstrucoes.Destroy()

; ==========================================
; FASE 3: Injetor do Prompt de Análise (Atalho: Ctrl + F18)
; ==========================================
^F18:: {
    prompt_analise := "
    (
Atuo com automação e inteligência de mercado para pequenos empresários. Preciso que você analise o arquivo 'reviews_concorrentes.txt' para extrair os padrões de comportamento dos clientes.

Gere um rascunho de relatório focado em clareza e valor estratégico. Esse texto será enviado via WhatsApp para minha sócia fazer a redação humana e a aprovação final.

Diretrizes de formatação:

Seja direto, analítico e use linguagem simples.
Não use negrito ou formatações complexas (apenas texto puro).
Separe o conteúdo claramente nos três blocos abaixo para facilitar a revisão dela.
Siga exatamente esta estrutura de saída:

= INSIGHTS = [Escreva aqui 3 tópicos curtos apontando as maiores oportunidades e gargalos do mercado local]

= MAIS ELOGIADO = [Escreva aqui 1 parágrafo focado no que os clientes mais valorizam e elogiam nos concorrentes]

= MAIS CRITICADO = [Escreva aqui 1 parágrafo focado nas maiores falhas, frustrações e motivos de cancelamento nos concorrentes]

O texto deve ser bonito, simples e fácil de copiar e colar no whatsapp para editar. Coloque o texto dentro de um bloco de código.
    )"
    
    A_Clipboard := prompt_analise
    Sleep(100)
    Send("^v")
    SoundBeep(800, 150)
}