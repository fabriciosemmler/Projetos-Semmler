#Requires AutoHotkey v2.0
#SingleInstance Force

; ==========================================
; FASE 4: Injetor do Prompt de Análise (Atalho: Ctrl + F18)
; ==========================================
^F18:: {
    prompt_analise := "
    (
Atuo com automação e inteligência de mercado para pequenos empresários. Preciso que você analise o arquivo 'reviews_concorrentes.txt' para extrair os padrões de comportamento dos clientes.

Gere um relatório focado em clareza e valor estratégico. Esse texto será enviado diretamente para o cliente final.

Diretrizes de formatação:
- Seja direto e use linguagem simples e analítica.
- Não use negrito ou formatações complexas (apenas texto puro).
- REGRA DE OURO: É estritamente proibido incluir citações de fontes. Não insira números de referência, colchetes, [source] ou [cite] no meio do texto. O texto deve ser 100% limpo.
- Separe o conteúdo claramente nos três blocos abaixo para facilitar a revisão dela.
- Siga exatamente esta estrutura de saída:

= INSIGHTS = [Escreva aqui 3 tópicos curtos apontando as maiores oportunidades e gargalos do mercado local]

= MAIS ELOGIADO = [Escreva aqui 1 parágrafo focado no que os clientes mais valorizam e elogiam nos concorrentes]

= MAIS CRITICADO = [Escreva aqui 1 parágrafo focado nas maiores falhas, frustrações e motivos de cancelamento nos concorrentes]

O texto deve ser bonito, simples e fácil de copiar e colar no whatsapp para editar. Coloque a resposta inteira dentro de um bloco de código. Use formatação UTF-8.
    )"
    
    A_Clipboard := prompt_analise
    Sleep(100)
    Send("^v")
    SoundBeep(800, 150)
}

; ==========================================
; FASE 4: Faxineiro de Citações para WhatsApp
; ==========================================
F20:: {
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

    ; 5. Criar redacao_final.txt com o texto limpo direto na pasta do cliente
    caminho_memoria := A_ScriptDir "\memoria_pasta.txt"
    
    if FileExist(caminho_memoria) {
        pasta_cliente := Trim(FileRead(caminho_memoria, "UTF-8"))
        
        if DirExist(pasta_cliente) {
            caminho_redacao := pasta_cliente "\redacao_final.txt"
            
            ; Deleta o arquivo antigo (se houver) para o texto novo entrar limpo
            if FileExist(caminho_redacao)
                FileDelete(caminho_redacao)
                
            ; Injeta o texto cristalino direto no arquivo
            FileAppend(texto_limpo, caminho_redacao, "UTF-8")
            
            ; Feedback sonoro de sucesso triplo (Missão Cumprida)
            SoundBeep(500, 150)
            SoundBeep(700, 150)
            SoundBeep(900, 150)
        } else {
            MsgBox("Erro: A pasta do cliente registrada na memória não existe mais.", "Falha de Rota", "IconX")
        }
    } else {
        MsgBox("Erro: memoria_pasta.txt não encontrado. Impossível salvar o texto.", "Falha de Rota", "IconX")
    }
}