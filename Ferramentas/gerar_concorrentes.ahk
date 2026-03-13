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

    ; ==========================================
    ; AJUSTE CIRÚRGICO: Leitura do INI (Ramo e Cidade blindados em UTF-8)
    ; ==========================================
    ; Lê o arquivo inteiro forçando a lente correta (UTF-8)
    conteudo_ini := FileRead(caminho_ini, "UTF-8")
    
    ; Pescador RegEx 1: Procura a linha "ramo = " e captura
    if RegExMatch(conteudo_ini, "im)^ramo\s*=\s*(.*)", &captura_ramo) {
        ramo_cliente := Trim(captura_ramo[1])
    } else {
        MsgBox("O ramo não foi encontrado no arquivo INI.", "Erro de Leitura", "IconX")
        return
    }

    ; Pescador RegEx 2: Procura a linha "cidade = " e captura
    if RegExMatch(conteudo_ini, "im)^cidade\s*=\s*(.*)", &captura_cidade) {
        cidade_cliente := Trim(captura_cidade[1])
    } else {
        cidade_cliente := "São Paulo SP" ; Fallback de segurança caso a chave não exista
    }

    ; 3. Monta o prompt cirúrgico com as variáveis injetadas
    prompt := "Meu cliente é do ramo de " ramo_cliente " em " cidade_cliente ". Faça uma lista de concorrentes operacionais (entre 25 a 30 concorrentes).`nRegra de ouro: Mescle entre grandes marcas e pequenos negócios locais.`n`nO resultado deve ser apenas o texto, com um concorrente em cada linha, no seguinte formato:`n[Nome da Empresa] " cidade_cliente "`n`nExemplo:`nMarca Famosa " cidade_cliente "`nNegócio Local " cidade_cliente "`n`nEnvie a resposta obrigatoriamente dentro de um bloco de código."

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
    
    ; ==========================================
    ; MÓDULO DE INTEGRAÇÃO: Dispara o extrator de palavras-chave
    ; ==========================================
    caminho_python := A_ScriptDir "\extrair_keywords.py"
    if FileExist(caminho_python) {
        ; Executa o Python de forma invisível e aguarda ele terminar
        RunWait("python `"" caminho_python "`"", A_ScriptDir, "Hide")
    } else {
        MsgBox("Aviso: 'extrair_keywords.py' não encontrado na pasta de Ferramentas.", "Alerta de Integração", "Icon!")
    }

    ; 5. Finalização
    if GuiInstrucoes {
        try GuiInstrucoes.Destroy()
        GuiInstrucoes := ""
    }
    
    SoundBeep(750, 500)
    MsgBox("Sucesso Absoluto!`n`n1. 'lista_concorrentes.txt' salvo.`n2. 'palavras_chave.txt' extraído com sucesso.", "Passo 2 Concluído", "Iconi 262144")
    
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