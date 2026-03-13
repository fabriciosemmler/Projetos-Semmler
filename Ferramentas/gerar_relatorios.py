import re
import os
import glob
import configparser
import pdfkit
from pypdf import PdfReader

# ==========================================
# CONFIGURAÇÕES E ROTAS ABSOLUTAS
# ==========================================

# Variáveis de sistema (preenchidas automaticamente)
cliente = ""
amostragem = ""
tipo_negocio = ""

diretorio_raiz = os.path.dirname(os.path.abspath(__file__))
# O template fica na pasta do script (sua pasta de Ferramentas)
caminho_template = os.path.join(diretorio_raiz, "template.html")

# Rota cirúrgica para o motor gráfico (Caminho padrão de instalação no Windows)
caminho_wkhtmltopdf = r'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
configuracao = pdfkit.configuration(wkhtmltopdf=caminho_wkhtmltopdf)

def gerar_relatorio(pasta_alvo):
    global cliente, amostragem, tipo_negocio 

    # ==========================================
    # NOVIDADE: Leitura Dinâmica do INI
    # ==========================================
    print("Lendo as diretrizes do projeto...")
    arquivos_ini = glob.glob(os.path.join(pasta_alvo, "projeto*.ini"))
    if arquivos_ini:
        config = configparser.ConfigParser()
        config.read(arquivos_ini[0], encoding='utf-8')
        if config.has_section("PROJETO"):
            # A função .get() com fallback garante que o script não quebre se a chave mudar
            cliente = config.get("PROJETO", "nome", fallback=config.get("PROJETO", "cliente", fallback="Cliente_Sem_Nome"))
            tipo_negocio = config.get("PROJETO", "ramo", fallback=config.get("PROJETO", "tipo_negocio", fallback="ramo não informado"))
    else:
        print("Aviso: 'projeto*.ini' não encontrado na pasta do cliente.")
        cliente = "Cliente_Desconhecido"
        tipo_negocio = "ramo não informado"

    # ==========================================
    # ROTAS DIRECIONADAS PARA A PASTA DO CLIENTE
    # ==========================================
    caminho_pdf = os.path.join(pasta_alvo, f"Relatorio_{cliente}.pdf")
    caminho_txt = os.path.join(pasta_alvo, "reviews_concorrentes.txt")
    
    # NOVIDADE: A rota do texto humano final
    caminho_redacao = os.path.join(pasta_alvo, "redacao_final.txt")

    print("Lendo o arquivo de avaliações...")
    if os.path.exists(caminho_txt):
        with open(caminho_txt, 'r', encoding='utf-8') as f:
            amostragem = str(len(f.readlines()))
    else:
        amostragem = "0"
        print("Aviso: 'reviews_concorrentes.txt' não encontrado na pasta do cliente.")

    # Força tudo para minúsculo e remove espaços em branco nas pontas
    tipo_negocio = tipo_negocio.lower().strip()

    # ==========================================
    # NOVIDADE: Extração Dinâmica da Redação Final
    # ==========================================
    print("Lendo o texto final da redatora...")
    if not os.path.exists(caminho_redacao):
        print(f"\nErro: O arquivo 'redacao_final.txt' não foi encontrado.")
        print("Crie este arquivo na pasta do cliente, cole o texto revisado pela sua sócia e rode novamente.")
        return

    with open(caminho_redacao, 'r', encoding='utf-8') as f:
        texto_redacao = f.read()

    # Pescadores RegEx (Extraem cirurgicamente o que está entre os títulos)
    match_insights = re.search(r'= INSIGHTS =(.*?)(?== MAIS ELOGIADO =|$)', texto_redacao, re.DOTALL)
    match_elogiado = re.search(r'= MAIS ELOGIADO =(.*?)(?== MAIS CRITICADO =|$)', texto_redacao, re.DOTALL)
    match_criticado = re.search(r'= MAIS CRITICADO =(.*?)(?=$)', texto_redacao, re.DOTALL)

    # Limpa espaços em branco nas pontas e converte as quebras de linha para HTML (<br>)
    insights_html = match_insights.group(1).strip().replace('\n', '<br>') if match_insights else "Dados de Insights ausentes."
    elogiado_html = match_elogiado.group(1).strip().replace('\n', '<br>') if match_elogiado else "Dados de Elogios ausentes."
    criticado_html = match_criticado.group(1).strip().replace('\n', '<br>') if match_criticado else "Dados de Críticas ausentes."

    print("Lendo o molde HTML...")
    
    if not os.path.exists(caminho_template):
        print("Erro: O arquivo 'template.html' não foi encontrado na pasta de ferramentas.")
        return

    with open(caminho_template, 'r', encoding='utf-8') as f:
        html_base = f.read()

    print("Injetando os dados no PDF...")

    # Opções de engenharia para o PDF
    opcoes = {
        'page-size': 'A4',
        'margin-top': '0mm',
        'margin-right': '0mm',
        'margin-bottom': '0mm',
        'margin-left': '0mm',
        'encoding': "UTF-8",
        'enable-local-file-access': None
    }

    # ==========================================
    # MOTOR ADAPTATIVO: Testa os tamanhos de fonte
    # ==========================================
    tamanhos_teste = [22, 21, 20, 19, 18, 17, 16, 15, 14]
    
    for tamanho in tamanhos_teste:
        print(f"Testando renderização com fonte de {tamanho}px...")
        
        # Substituição em cascata a cada nova tentativa
        html_final = html_base.replace("{{CLIENTE}}", cliente)
        html_final = html_final.replace("{{AMOSTRAGEM}}", amostragem)
        html_final = html_final.replace("{{TIPO_NEGOCIO}}", tipo_negocio)
        html_final = html_final.replace("{{INSIGHTS}}", insights_html)
        html_final = html_final.replace("{{ELOGIADO}}", elogiado_html)
        html_final = html_final.replace("{{CRITICADO}}", criticado_html)
        
        # Substitui apenas a linha que tem a assinatura alvo-dinamico
        html_final = html_final.replace("font-size: 18px; /* alvo-dinamico */", f"font-size: {tamanho}px; /* alvo-dinamico */")

        try:
            # Gera o PDF (vai sobrescrever se já existir)
            pdfkit.from_string(html_final, caminho_pdf, configuration=configuracao, options=opcoes)
            
            # Lê o arquivo que acabou de ser criado para conferir as páginas
            leitor = PdfReader(caminho_pdf)
            numero_paginas = len(leitor.pages)
            
            if numero_paginas == 1:
                print(f"\nSucesso absoluto! Relatório de 1 página gerado com fonte {tamanho}px em '{pasta_alvo}'.")
                break # Interrompe o loop, pois o objetivo foi alcançado
            else:
                print(f"O relatório gerou {numero_paginas} páginas. Reduzindo para o próximo tamanho...")
                
        except Exception as e:
            print(f"\nErro ao gerar o PDF: {e}")
            break # Se der erro no motor wkhtmltopdf, para tudo para não ficar travado

# ==========================================
# GATILHO DE EXECUÇÃO AUTOMÁTICO
# ==========================================
if __name__ == "__main__":
    caminho_memoria = os.path.join(diretorio_raiz, "memoria_pasta.txt")
    
    try:
        # Lê o caminho da pasta do cliente salvo na memória
        with open(caminho_memoria, "r", encoding="utf-8") as f:
            pasta_selecionada = f.read().strip()
        
        # Se a pasta existir no disco, dispara o motor
        if os.path.exists(pasta_selecionada):
            print(f"Iniciando a geração do relatório para a pasta:\n{pasta_selecionada}\n")
            gerar_relatorio(pasta_selecionada)
        else:
            print(f"Erro: A pasta do cliente registrada não existe no computador: {pasta_selecionada}")
            
    except FileNotFoundError:
        print("Erro: Arquivo 'memoria_pasta.txt' não encontrado. Você precisa rodar as etapas anteriores primeiro.")