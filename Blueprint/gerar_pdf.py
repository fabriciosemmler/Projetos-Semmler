import re
import os
import pdfkit

# ==========================================
# CONFIGURAÇÕES E ROTAS ABSOLUTAS
# ==========================================

# ==========================================
# CONTEÚDO DO RELATÓRIO
# ==========================================
cliente = "Blueprint Idiomas"
amostragem = "228"
tipo_negocio = "escolas de idiomas"
insights = "• A humanização do atendimento presencial e a didática dos professores são os maiores retentores de alunos, com profissionais como Camila, Ricardo e Álvaro sendo elogiados nominalmente [cite: 59, 102, 144].<br><br>• A comunicação digital é um gargalo na concorrência, pois mensagens ignoradas no WhatsApp e esperas infinitas no telefone geram forte frustração [cite: 24, 43, 158].<br><br>• A desorganização administrativa, como atrasos de material didático e reajustes surpresa nas rematrículas, impulsiona o cancelamento repentino de contratos[cite: 3, 7, 8]."
elogiado = "O fator humano é o ponto mais forte das escolas concorrentes[cite: 59, 61, 77]. Os clientes valorizam professores engajados e metodologias dinâmicas que criam um ambiente acolhedor[cite: 59, 61, 77]. O atendimento presencial ágil no momento da matrícula recebe muitos destaques positivos, assim como a boa infraestrutura física e a limpeza das instalações[cite: 58, 64, 104]."
criticado = "A maior falha do mercado local reside na gestão administrativa e no suporte remoto[cite: 24, 158]. Os clientes relatam profunda frustração com o atendimento via WhatsApp e telefone, sentindo-se ignorados ao tentarem cancelar matrículas ou resolver problemas urgentes[cite: 24, 158]. A quebra de expectativa financeira com reajustes abusivos e a falta de organização para entrega de materiais pagos geram a maioria das avaliações destrutivas[cite: 3, 7, 8]."
# ==========================================

diretorio_raiz = os.path.dirname(os.path.abspath(__file__))
caminho_template = os.path.join(diretorio_raiz, "template.html")
caminho_pdf = os.path.join(diretorio_raiz, "Relatorio_Insights.pdf")

# Rota cirúrgica para o motor gráfico (Caminho padrão de instalação no Windows)
caminho_wkhtmltopdf = r'C:\Program Files\wkhtmltopdf\bin\wkhtmltopdf.exe'
configuracao = pdfkit.configuration(wkhtmltopdf=caminho_wkhtmltopdf)

def gerar_relatorio():
    print("Lendo o molde HTML...")
    
    if not os.path.exists(caminho_template):
        print("Erro: O arquivo 'template.html' não foi encontrado.")
        return

    with open(caminho_template, 'r', encoding='utf-8') as f:
        html_base = f.read()

    print("Injetando os dados da inteligência...")
    
    # ==========================================
    # FILTRO CIRÚRGICO: Limpa as citações da IA
    # ==========================================
    # Separamos a palavra gatilho para a interface do chat não quebrar o código
    gatilho = "ci" + "te:"
    padrao_citacao = r'\s*\[' + gatilho + r'.*?\]'
    
    # O Python lê as variáveis globais, limpa e salva nas variáveis locais (_limpo)
    insights_limpo = re.sub(padrao_citacao, '', insights)
    elogiado_limpo = re.sub(padrao_citacao, '', elogiado)
    criticado_limpo = re.sub(padrao_citacao, '', criticado)

    # Substituição em cascata chamando as variáveis limpas
    html_final = html_base.replace("{{CLIENTE}}", cliente)
    html_final = html_final.replace("{{AMOSTRAGEM}}", amostragem)
    html_final = html_final.replace("{{TIPO_NEGOCIO}}", tipo_negocio)
    html_final = html_final.replace("{{INSIGHTS}}", insights_limpo)
    html_final = html_final.replace("{{ELOGIADO}}", elogiado_limpo)
    html_final = html_final.replace("{{CRITICADO}}", criticado_limpo)

    print("Renderizando o PDF pixel-perfect...")
    
    # Opções de engenharia para remover margens brancas nativas e usar o nosso CSS
    opcoes = {
        'page-size': 'A4',
        'margin-top': '0mm',
        'margin-right': '0mm',
        'margin-bottom': '0mm',
        'margin-left': '0mm',
        'encoding': "UTF-8",
        'enable-local-file-access': None
    }

    try:
        pdfkit.from_string(html_final, caminho_pdf, configuration=configuracao, options=opcoes)
        print(f"\nSucesso absoluto! Relatório comercial gerado em:\n{caminho_pdf}")
    except Exception as e:
        print(f"\nErro ao gerar o PDF. Verifique se o wkhtmltopdf foi instalado corretamente. Detalhe: {e}")

if __name__ == "__main__":
    gerar_relatorio()