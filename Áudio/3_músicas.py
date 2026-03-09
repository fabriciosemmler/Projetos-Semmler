import tkinter as tk
import threading
import asyncio
from winrt.windows.media.control import GlobalSystemMediaTransportControlsSessionManager

def exibir_aviso_grande(texto):
    def criar_gui():
        root = tk.Tk()
        root.overrideredirect(True) # Remove bordas (-Caption)
        root.attributes("-topmost", True) # Sempre no topo (+AlwaysOnTop)
        root.attributes("-toolwindow", True) # Oculta da barra de tarefas (+ToolWindow)
        root.configure(bg='#1f1f1f')
        
        # Geometria idêntica ao AHK: largura 600, altura 80, posição y50 centralizado
        largura, altura = 600, 80
        screen_w = root.winfo_screenwidth()
        root.geometry(f"{largura}x{altura}+{(screen_w - largura) // 2}+50")
        
        # Estilo: Segoe UI, tamanho 24, Negrito, cor Aqua (#00FFFF)
        label = tk.Label(root, text=texto, font=("Segoe UI", 24, "bold"), 
                         fg="#00FFFF", bg="#1f1f1f", wraplength=550)
        label.pack(expand=True)
        
        # Timer de 3 segundos para fechar
        root.after(3000, root.destroy)
        root.mainloop()
    
    # Roda em thread separada para não travar o monitoramento da música
    threading.Thread(target=criar_gui, daemon=True).start()

DEEZER_ID = "com.deezer.deezer-desktop"

async def obter_sessao():
    manager = await GlobalSystemMediaTransportControlsSessionManager.request_async()
    sessoes = manager.get_sessions()
    return next((s for s in sessoes if s.source_app_user_model_id == DEEZER_ID), None)

async def executar_contagem():
    sessao = await obter_sessao()
    if not sessao:
        return

    # 1ª Música: Detecta o que está tocando agora
    info = await sessao.try_get_media_properties_async()
    musica_atual = f"{info.artist} - {info.title}"
    exibir_aviso_grande(f"▶️ [1/3] {musica_atual}")

    # Monitora as próximas 2 trocas (totalizando 3 faixas)
    contador = 0
    while contador < 2:
        await asyncio.sleep(2)
        try:
            info = await sessao.try_get_media_properties_async()
            nova = f"{info.artist} - {info.title}"
            if nova != musica_atual:
                contador += 1
                musica_atual = nova
                exibir_aviso_grande(f"🔄 [{contador + 1}/3] {musica_atual}")
        except:
            continue

    # --- RETA FINAL: A 3ª MÚSICA ---
    print("⏳ Sincronizando pouso da 3ª música...")
    
    # Pega as propriedades da linha do tempo
    timeline = sessao.get_timeline_properties()
    
    # O Python converte automaticamente para timedelta, usamos total_seconds()
    total = timeline.end_time.total_seconds()
    atual = timeline.position.total_seconds()
    restante = total - atual

    if restante > 0:
        # Dorme o tempo restante com 0.5s de margem de segurança
        print(f"⏱️ Faltam {restante:.1f}s. Aguardando o fim...")
        await asyncio.sleep(restante - 0.5)
    
    # Comando de pausa cravado no final
    await sessao.try_toggle_play_pause_async()
    exibir_aviso_grande("⏸️ 3 Músicas! Pausado.")

if __name__ == "__main__":
    asyncio.run(executar_contagem())