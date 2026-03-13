import os
import sys
import subprocess
import tkinter as tk
from tkinter import messagebox
import webbrowser

# ==========================================
# CONFIGURAÇÕES DE ROTA
# ==========================================
diretorio_ferramentas = os.path.dirname(os.path.abspath(__file__))
caminho_memoria = os.path.join(diretorio_ferramentas, "memoria_pasta.txt")

# ==========================================
# FUNÇÕES DA INTERFACE (Fios Conectados)
# ==========================================
def atualizar_status():
    """Lê a memória para saber quem é o cliente atual e atualiza o painel"""
    try:
        with open(caminho_memoria, "r", encoding="utf-8") as f:
            pasta_atual = f.read().strip()
            # Extrai apenas o nome final da pasta para ficar bonito na tela
            nome_cliente = os.path.basename(pasta_atual)
            if nome_cliente:
                var_status.set(f"Alvo Atual: {nome_cliente}")
            else:
                var_status.set("Alvo Atual: Nenhum projeto ativo")
    except FileNotFoundError:
        var_status.set("Alvo Atual: Nenhum projeto ativo")

def acao_iniciar():
    # Dispara o script de inicialização sem travar o painel
    caminho_script = os.path.join(diretorio_ferramentas, "iniciar_projeto.py")
    if os.path.exists(caminho_script):
        subprocess.Popen([sys.executable, caminho_script])
    else:
        messagebox.showerror("Erro de Rota", "O arquivo 'iniciar_projeto.py' não foi encontrado.")

def acao_abrir_pasta():
    # Lê a memória e manda o Windows abrir a pasta
    try:
        with open(caminho_memoria, "r", encoding="utf-8") as f:
            pasta_atual = f.read().strip()
        
        if os.path.exists(pasta_atual):
            os.startfile(pasta_atual)
        else:
            messagebox.showwarning("Aviso", "A pasta do cliente não existe mais ou foi movida.")
    except FileNotFoundError:
        messagebox.showwarning("Aviso", "Nenhum projeto ativo na memória.")

def acao_ligar_ahk():
    # Dá um "clique duplo" no script AHK para armar os atalhos F11 e os faxineiros
    caminho_script = os.path.join(diretorio_ferramentas, "obter_html.ahk")
    if os.path.exists(caminho_script):
        os.startfile(caminho_script)
        # Bipe curto apenas para confirmar que ligou
        import winsound
        winsound.Beep(1000, 200) 
    else:
        messagebox.showerror("Erro de Rota", "O arquivo 'obter_html.ahk' não foi encontrado.")

def acao_abrir_gemini():
    # 1. Arma os atalhos do Gemini silenciosamente no Windows
    caminho_script = os.path.join(diretorio_ferramentas, "assistente_gemini.ahk")
    if os.path.exists(caminho_script):
        os.startfile(caminho_script)
    else:
        messagebox.showwarning("Aviso", "O script 'assistente_gemini.ahk' não foi encontrado. Os atalhos podem não funcionar.")

    # 2. Abre o navegador na sua conta
    webbrowser.open("https://gemini.google.com/app/2267c167a9509945")

def acao_gerar_pdf():
    # Dispara o motor de relatório
    caminho_script = os.path.join(diretorio_ferramentas, "gerar_relatorios.py")
    if os.path.exists(caminho_script):
        subprocess.Popen([sys.executable, caminho_script])
    else:
        messagebox.showerror("Erro de Rota", "O arquivo 'gerar_relatorios.py' não foi encontrado.")

# ==========================================
# CONSTRUÇÃO DO PAINEL (Interface minimalista)
# ==========================================
root = tk.Tk()
root.title("Semmler Automações - Painel Mestre")

# --- Centralização Cirúrgica da Janela ---
largura_janela = 480
altura_janela = 580
largura_tela = root.winfo_screenwidth()
altura_tela = root.winfo_screenheight()

pos_x = int((largura_tela / 2) - (largura_janela / 2))
pos_y = int((altura_tela / 2) - (altura_janela / 2))

root.geometry(f"{largura_janela}x{altura_janela}+{pos_x}+{pos_y}")
# -----------------------------------------

root.resizable(False, False)
root.configure(padx=20, pady=15, bg="#f0f0f0")

# Título Principal
tk.Label(root, text="Auditoria de Avaliações", font=("Segoe UI", 16, "bold"), bg="#f0f0f0").pack(pady=(0, 5))

# Status do Cliente (Painel Inteligente)
var_status = tk.StringVar()
atualizar_status()
label_status = tk.Label(root, textvariable=var_status, font=("Segoe UI", 10, "italic"), fg="#0052cc", bg="#f0f0f0")
label_status.pack(pady=(0, 15))

# ==========================================
# BOTÕES E INSTRUÇÕES
# ==========================================
largura_botao = 40
fonte_instrucao = ("Segoe UI", 8, "italic")
cor_instrucao = "#555555"

# Passo 1
tk.Button(root, text="1. Iniciar Novo Projeto", font=("Segoe UI", 10), width=largura_botao, command=acao_iniciar).pack(pady=(5, 5))

# Passo 2 + Instrução
tk.Button(root, text="2. Abrir Pasta do Cliente", font=("Segoe UI", 10), width=largura_botao, command=acao_abrir_pasta).pack(pady=(15, 0))
tk.Label(root, text="↳ Copiar URLs do Google Maps para o lista_concorrentes.txt", font=fonte_instrucao, fg=cor_instrucao, bg="#f0f0f0").pack(pady=(0, 5))

# Passo 3
tk.Button(root, text="3. Armar Motor de Coleta (AHK)", font=("Segoe UI", 10), width=largura_botao, command=acao_ligar_ahk).pack(pady=(15, 5))

# --- AJUSTE CIRÚRGICO: Passo 4 Simplificado ---
tk.Button(root, text="4. Extração de Inteligência (Gemini)", font=("Segoe UI", 10), width=largura_botao, command=acao_abrir_gemini).pack(pady=(15, 0))
tk.Label(root, text="↳ Enviar arquivo reviews_concorrentes.txt e apertar Ctrl + F18", font=fonte_instrucao, fg=cor_instrucao, bg="#f0f0f0").pack(pady=(0, 0))
tk.Label(root, text="↳ Copiar o rascunho da IA e apertar F20 (Salva automático)", font=fonte_instrucao, fg=cor_instrucao, bg="#f0f0f0").pack(pady=(0, 5))
# ----------------------------------------------

# Passo 5
tk.Button(root, text="5. Emitir Relatório (PDF e Whatsapp)", font=("Segoe UI", 10, "bold"), width=largura_botao, bg="#4CAF50", fg="white", command=acao_gerar_pdf).pack(pady=(20, 5))

# Botão para atualizar a memória manualmente
tk.Button(root, text="↻ Atualizar Status", font=("Segoe UI", 8), bd=0, bg="#f0f0f0", fg="gray", command=atualizar_status).pack(side="bottom")

root.mainloop()