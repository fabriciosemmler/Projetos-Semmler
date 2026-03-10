#Requires AutoHotkey v2.0
#SingleInstance Force

F11:: {
    ; Trava as coordenadas do mouse para a área útil do navegador (Client)
    CoordMode("Mouse", "Client")

    ; 1. Abre o Google Maps
    Run("https://www.google.com.br/maps")
    Sleep(5000)
    
    ; 2. Lê o arquivo e fatia as linhas
    texto_completo := FileRead("lista_concorrentes.txt", "UTF-8")
    linhas := StrSplit(texto_completo, "`n", "`r")
    
    ; 3. O Motor de Repetição (Loop)
    For indice, escola in linhas {
        ; Ignora linhas vazias (evita erro se houver um "Enter" sobrando no final do txt)
        if (escola = "")
            continue

        ; Retoma o foco clicando fisicamente dentro da barra de pesquisa
        ; 150 (X) e 120 (Y) costumam acertar a barra no canto superior esquerdo.
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
        
        ; Aguarda 5 segundos carregando o local antes de ir para a próxima linha
        Sleep(5000)
    }
    
    ; 4. Finalização: Fecha a aba atual do navegador (Ctrl + W)
    Send("^w")
}