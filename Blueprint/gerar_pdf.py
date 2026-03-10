import os
import pdfkit

# ==========================================
# CONFIGURAÇÕES E ROTAS ABSOLUTAS
# ==========================================
diretorio_raiz = os.path.dirname(os.path.abspath(__file__))
caminho_template = os.path.join(diretorio_raiz, "template.html")
caminho_pdf = os.path.join(diretorio_raiz, "Relatorio_Blueprint.pdf")

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
    
    # Textos do nosso piloto (Blueprint Idiomas)
    insights = (
        "• A personalização é o maior ativo: O mercado valoriza intensamente o atendimento humanizado, com alunos citando nomes de professores e atendentes.\n<br><br>"
        "• O gargalo digital é uma oportunidade: As grandes redes locais possuem uma falha sistêmica no atendimento online (esperas longas, WhatsApp ignorado).\n<br><br>"
        "• Transparência retém alunos: Processos burocráticos mal geridos são os maiores geradores de evasão."
    )
    elogiado = "O ponto mais forte dos concorrentes reside nas salas de aula e no balcão físico. Os clientes elogiam repetidamente a competência, a didática e o acolhimento dos professores. Aulas descritas como divertidas e dinâmicas são o padrão ouro de satisfação. A infraestrutura e a limpeza dos ambientes também são diferenciais."
    criticado = "A maior dor dos clientes na região é a sensação de abandono logo após a assinatura do contrato. O atendimento online e telefônico é descrito com forte indignação. Clientes se sentem ignorados ao tentar resolver problemas como cancelamentos, atrasos na entrega de material didático já pago e reajustes surpresa."

    # Substituição exata das etiquetas
    html_final = html_base.replace("{{CLIENTE}}", "Blueprint Idiomas")
    html_final = html_base.replace("{{AMOSTRAGEM}}", "228")
    html_final = html_base.replace("{{TIPO_NEGOCIO}}", "escolas de idiomas")
    html_final = html_base.replace("{{INSIGHTS}}", insights)
    html_final = html_base.replace("{{ELOGIADO}}", elogiado)
    html_final = html_base.replace("{{CRITICADO}}", criticado)

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