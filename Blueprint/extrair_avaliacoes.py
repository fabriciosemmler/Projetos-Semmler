import os
from bs4 import BeautifulSoup

import os
from bs4 import BeautifulSoup

# ==========================================
# CONFIGURAÇÕES (Rotas Absolutas)
# ==========================================
# Descobre a pasta exata onde este script extrair_avaliacoes.py está salvo
diretorio_raiz = os.path.dirname(os.path.abspath(__file__))

# Constrói os caminhos blindados
pasta_html = os.path.join(diretorio_raiz, "paginas_html")
arquivo_saida = os.path.join(diretorio_raiz, "reviews_concorrentes.txt")

def extrair_dados():
    print("Iniciando a extração cirúrgica de avaliações...\n")
    
    if not os.path.exists(pasta_html):
        print(f"Erro: A pasta '{pasta_html}' não foi encontrada.")
        return

    arquivos = [f for f in os.listdir(pasta_html) if f.endswith('.html')]
    total_avaliacoes = 0

    # Abre o arquivo de saída em modo de escrita ('w' limpa o arquivo antigo)
    with open(arquivo_saida, 'w', encoding='utf-8') as f_out:
        
        for arquivo in arquivos:
            caminho_completo = os.path.join(pasta_html, arquivo)
            print(f"Processando: {arquivo}", end="... ")
            
            # Lê o código-fonte do HTML salvo
            with open(caminho_completo, 'r', encoding='utf-8') as f_in:
                sopa = BeautifulSoup(f_in, 'html.parser')
                
                # Busca exata por todas as tags com a classe que mapeamos
                avaliacoes = sopa.find_all('span', class_='wiI7pd')
                
                contador_local = 0
                for avaliacao in avaliacoes:
                    # Extrai apenas o texto, ignorando outras tags internas (como emojis ou links)
                    texto = avaliacao.get_text(separator=" ", strip=True)
                    
                    # Achata o texto para garantir que fique em uma única linha no .txt final
                    texto_limpo = texto.replace('\n', ' ').replace('\r', '')
                    
                    # Salva no arquivo de texto apenas se não for uma string vazia
                    if texto_limpo:
                        f_out.write(f"{texto_limpo}\n")
                        contador_local += 1
                        total_avaliacoes += 1
                        
            print(f"[{contador_local} extraídas]")
            
    print(f"\nFinalizado! {total_avaliacoes} avaliações consolidadas em '{arquivo_saida}'.")

# Executa a função
if __name__ == "__main__":
    extrair_dados()