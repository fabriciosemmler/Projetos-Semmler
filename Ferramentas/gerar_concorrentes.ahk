#Requires AutoHotkey v2.0
#SingleInstance Force
global pasta_cliente := ""
global GuiInstrucoes := "" ; Novo objeto global para a interface
global ultima_pasta := "" ; NOVO: Memória persistente do último diretório acessado

; ==========================================
; FASE 1: Preparação e Prompt (Atalho: F19)
; ==========================================
F19:: {
    global pasta_cliente, GuiInstrucoes, ultima_pasta ; NOVO: Injetada a nova global aqui
    
    ; 1. Abre a janela nativa para selecionar a PASTA do cliente
; O asterisco (*) destrava o Windows, permitindo subir de nível e ver pastas "irmãs"
    caminho_inicial := (ultima_pasta = "") ? "" : "*" ultima_pasta
    pasta_cliente := DirSelect(caminho_inicial, 0, "Selecione a pasta do cliente para salvar a lista")
    
    if (pasta_cliente = "") {
        return ; Aborta silenciosamente
    }

    ultima_pasta := pasta_cliente ; NOVO: Grava a escolha com sucesso na memória para a próxima rodada

    ; 2. Pede o ramo de atuação
    tela_ramo := InputBox("Qual o ramo do cliente? (Ex: Lavanderia automatizada)", "Gerador de Prompt", "w450 h130")
    
    if (tela_ramo.Result = "Cancel" or tela_ramo.Value = "") {
        return 
    }
    
    ramo_cliente := tela_ramo.Value

    ; 3. Monta o prompt cirúrgico com a variável injetada
    prompt := "Meu cliente é uma " ramo_cliente ". Faça uma lista de concorrentes operacionais em São Paulo, SP (mais de 10 concorrentes).`nRegra de ouro: Para que a automação encontre o local exato no Google Maps sem ambiguidade, você deve incluir obrigatoriamente o BAIRRO de cada unidade.`n`nO resultado deve ser apenas o texto, com um concorrente em cada linha, no seguinte formato:`n[Nome da Empresa] [Bairro] São Paulo SP`n`nExemplo:`nOMO Lavanderia Self-Service Vila Mariana São Paulo SP`nLavanderia 60 Minutos Pinheiros São Paulo SP`n`nEnvie a resposta obrigatoriamente dentro de um bloco de código."

    ; 4. Joga o prompt pronto para a memória (Área de Transferência)
    A_Clipboard := prompt
    
    ; 5. Verifica se a aba da conversa já está aberta (pelo título parcial da janela)
    SetTitleMatchMode(2) ; Permite encontrar a janela por qualquer parte do título
    if WinExist("Google Gemini") {
        WinActivate("Google Gemini") ; Puxa a janela existente para a frente
    } else {
        Run("https://gemini.google.com/app/2267c167a9509945") ; Abre uma aba nova
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
    
    ; Calcula a posição para grudar na direita (largura da tela menos 450 pixels da caixinha)
    pos_x := A_ScreenWidth - 450
    
    ; Mostra a janela no canto superior direito matematicamente, sem roubar o foco (NoActivate)
    GuiInstrucoes.Show("AutoSize NoActivate x" pos_x " y50")
}

; ==========================================
; FASE 2: Captura e Salvamento (Atalho: Ctrl + F19)
; ==========================================
^F19:: {
    global pasta_cliente, GuiInstrucoes
    
    ; Trava de segurança: Verifica se o F19 foi usado antes
    if (pasta_cliente = "") {
        MsgBox("Nenhuma pasta selecionada. Use o F19 primeiro para iniciar o processo.", "Aviso de Segurança", "IconX 262144")
        return
    }

    ; 1. Pega o texto que você copiou do Gemini
    texto_limpo := A_Clipboard
    
    ; 2. Limpeza cirúrgica: Remove blocos de código markdown se a IA os gerar
    ; Como a crase é caractere de escape no AHK, precisamos dobrá-las (6 crases geram 3 reais)
    texto_limpo := StrReplace(texto_limpo, "``````text", "")
    texto_limpo := StrReplace(texto_limpo, "``````", "")
    texto_limpo := Trim(texto_limpo) ; Tira espaços em branco sobrando nas pontas

    ; 3. Monta o caminho exato do arquivo
    caminho_txt := pasta_cliente "\lista_concorrentes.txt"
    
    ; Prevenção: Se já existir uma lista velha, deleta
    if FileExist(caminho_txt) {
        FileDelete(caminho_txt)
    }
        
    ; 4. Cria o arquivo injetando o texto limpo (em UTF-8 para não quebrar acentos)
    FileAppend(texto_limpo, caminho_txt, "UTF-8")
    
    ; 5. Finalização e Destruição da GUI de instruções
    if GuiInstrucoes {
        try GuiInstrucoes.Destroy()
        GuiInstrucoes := ""
    }
    
    SoundBeep(750, 500)
    MsgBox("Sucesso! 'lista_concorrentes.txt' salvo blindado na pasta do cliente.", "Passo 2 Concluído", "Iconi 262144")
    
    ; Limpa a memória da pasta para o próximo uso
    pasta_cliente := ""
}

!v::GuiInstrucoes.Destroy()