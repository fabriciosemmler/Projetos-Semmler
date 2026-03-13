import os
import tkinter as tk
from tkinter import filedialog, messagebox
import configparser  # <-- ADICIONADO: Biblioteca nativa para arquivos .ini

def selecionar_pasta_base():
    # Pede para o usuário escolher o diretório raiz onde os clientes ficam
    pasta = filedialog.askdirectory(title="Selecione a pasta raiz dos seus clientes")
    if pasta:
        # --- AJUSTE CIRÚRGICO ---
        # normpath converte todas as barras para o padrão correto do Windows (\)
        pasta_limpa = os.path.normpath(pasta)
        var_pasta_base.set(pasta_limpa)
        # ------------------------

def salvar_e_iniciar():
    base = var_pasta_base.get().strip()
    cliente = var_cliente.get().strip()
    ramo = var_ramo.get().strip()
    cidade = var_cidade.get().strip()

    # Validação básica
    if not base or not cliente or not ramo or not cidade:
        messagebox.showwarning("Atenção", "Por favor, preencha todos os campos e selecione a pasta base.")
        return

    try:
        # 1. Escolher/criar a pasta do projeto (Base + Nome do Cliente)
        pasta_projeto = os.path.join(base, cliente)
        os.makedirs(pasta_projeto, exist_ok=True) # Cria a pasta se não existir

        # Salva o memoria_pasta.txt na pasta deste script (MANTIDO PARA NÃO QUEBRAR O FLUXO)
        diretorio_ferramentas = os.path.dirname(os.path.abspath(__file__))
        caminho_memoria = os.path.join(diretorio_ferramentas, "memoria_pasta.txt")
        with open(caminho_memoria, "w", encoding="utf-8") as f:
            f.write(pasta_projeto)

        # --- MUDANÇA CIRÚRGICA: Criação do Banco de Dados INI ---
        config = configparser.ConfigParser()
        config[f'PROJETO {cliente}'] = {
            'cliente': cliente,
            'ramo': ramo,
            'cidade': cidade
        }
        
        caminho_ini = os.path.join(pasta_projeto, f"projeto {cliente.lower()}.ini")
        with open(caminho_ini, 'w', encoding='utf-8') as configfile:
            config.write(configfile)
        # ---------------------------------------------------------

        # Sucesso e encerramento cirúrgico
        messagebox.showinfo("Semmler Automações", f"Projeto '{cliente}' inicializado com sucesso!\nO banco de dados 'projeto {cliente.lower()}.ini' foi criado.")
        root.destroy()

    except Exception as e:
        messagebox.showerror("Erro", f"Ocorreu um erro ao criar a estrutura: {str(e)}")

# ==============================================================================
# INTERFACE GRÁFICA (Elegante e Leve)
# ==============================================================================
root = tk.Tk()
root.title("Inicializador de Projetos - Semmler")

# --- AJUSTE CIRÚRGICO ---
# Aumentamos a largura de 450 para 550 para acomodar o botão lateral
root.geometry("600x300") 
# ------------------------

root.configure(padx=20, pady=20)
root.resizable(False, False) # Impede redimensionamento para manter o layout fixo

# Variáveis do Tkinter
var_pasta_base = tk.StringVar()
var_cliente = tk.StringVar()
var_ramo = tk.StringVar()
var_cidade = tk.StringVar()

# Fontes
fonte_label = ("Segoe UI", 10)
fonte_entry = ("Segoe UI", 10)

# Linha 1: Pasta Base
tk.Label(root, text="Pasta Raiz dos Clientes:", font=fonte_label).grid(row=0, column=0, sticky="w", pady=(0, 5))
entry_base = tk.Entry(root, textvariable=var_pasta_base, font=fonte_entry, width=30, state="readonly")
entry_base.grid(row=0, column=1, padx=(5, 5), pady=(0, 5))

# --- AJUSTE CIRÚRGICO ---
# Adicionada a formatação de fonte para parear com as Entrys
tk.Button(root, text="Procurar...", font=fonte_label, command=selecionar_pasta_base).grid(row=0, column=2, pady=(0, 5))
# ------------------------

# Linha 2: Nome do Cliente
tk.Label(root, text="Nome do Cliente:", font=fonte_label).grid(row=1, column=0, sticky="w", pady=5)
tk.Entry(root, textvariable=var_cliente, font=fonte_entry, width=40).grid(row=1, column=1, columnspan=2, sticky="w", padx=5, pady=5)

# Linha 3: Ramo de Atividade
tk.Label(root, text="Ramo de Atividade:", font=fonte_label).grid(row=2, column=0, sticky="w", pady=5)
tk.Entry(root, textvariable=var_ramo, font=fonte_entry, width=40).grid(row=2, column=1, columnspan=2, sticky="w", padx=5, pady=5)

# Linha 4: Cidade
tk.Label(root, text="Cidade/Estado (Ex: São Paulo SP):", font=fonte_label).grid(row=3, column=0, sticky="w", pady=5)
tk.Entry(root, textvariable=var_cidade, font=fonte_entry, width=40).grid(row=3, column=1, columnspan=2, sticky="w", padx=5, pady=5)

# Botão Iniciar
botao_iniciar = tk.Button(root, text="INICIAR PROJETO", font=("Segoe UI", 10, "bold"), bg="#4CAF50", fg="white", command=salvar_e_iniciar)
botao_iniciar.grid(row=4, column=0, columnspan=3, pady=25, ipadx=20, ipady=5)

# Mantém a janela aberta
root.mainloop()