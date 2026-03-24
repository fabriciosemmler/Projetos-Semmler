import time
import tkinter as tk
import threading
import asyncio
from winrt.windows.media.control import GlobalSystemMediaTransportControlsSessionManager

def exibir_aviso_grande(texto):
    def criar_gui():
        root = tk.Tk()
        root.overrideredirect(True) # -Caption
        root.attributes("-topmost", True) # +AlwaysOnTop
        root.attributes("-toolwindow", True) # +ToolWindow
        root.configure(bg='#1f1f1f')
        
        largura, altura = 600, 80
        screen_w = root.winfo_screenwidth()
        root.geometry(f"{largura}x{altura}+{(screen_w - largura) // 2}+50")
        
        label = tk.Label(root, text=texto, font=("Segoe UI", 24, "bold"), 
                         fg="#00FFFF", bg="#1f1f1f", wraplength=550)
        label.pack(expand=True)
        
        root.after(3000, root.destroy)
        root.mainloop()
    
    threading.Thread(target=criar_gui, daemon=True).start()

async def obter_sessao():
    manager = await GlobalSystemMediaTransportControlsSessionManager.request_async()
    sessoes = manager.get_sessions()
    # Abordagem cirúrgica: localiza qualquer processo de mídia que contenha "spotify" no nome
    for s in sessoes:
        if s.source_app_user_model_id and "spotify" in s.source_app_user_model_id.lower():
            return s
    return None

async def executar_contagem():
    # --- AJUSTE CIRÚRGICO: AGUARDANDO A PRIMEIRA MÚSICA ---
    print("⏳ Aguardando Spotify e início da música...")
    sessao = None
    while True:
        sessao = await obter_sessao()
        if sessao:
            try:
                info = await sessao.try_get_media_properties_async()
                if info.title: 
                    break
            except:
                pass
        await asyncio.sleep(2)

    # --- FASE 1: MONITORAMENTO DAS TROCAS ---
    info = await sessao.try_get_media_properties_async()
    musica_atual = f"{info.artist} - {info.title}"
    exibir_aviso_grande(f"▶️ [1/3] {musica_atual}")

    contador = 0
    while contador < 2:
        await asyncio.sleep(2)
        try:
            info = await sessao.try_get_media_properties_async()
            
            # FILTRO DE INTEGRIDADE: Ignora se o título estiver vazio (transição)
            if not info.title or info.title.strip() == "":
                continue

            nova = f"{info.artist} - {info.title}"
            if nova != musica_atual:
                contador += 1
                musica_atual = nova
                exibir_aviso_grande(f"🔄 [{contador + 1}/3] {musica_atual}")
        except:
            continue

# --- VIGÍLIA ATIVA (Faltando 1 segundo) ---
    ultima_pos = -1
    tempo_leitura = time.time()

    while True:
        await asyncio.sleep(0.5) # Ciclo rápido para não perder o timing
        try:
            timeline = sessao.get_timeline_properties()
            total = timeline.end_time.total_seconds()
            pos_oficial = timeline.position.total_seconds()
            
            # Sincroniza o relógio apenas quando o Spotify decide atualizar a posição real
            if pos_oficial != ultima_pos:
                ultima_pos = pos_oficial
                tempo_leitura = time.time()

            # Compensamos a preguiça do Spotify somando o tempo do sistema:
            playback = sessao.get_playback_info()
            if playback and playback.playback_status == 4: # 4 = Playing
                atual = pos_oficial + (time.time() - tempo_leitura)
            else:
                atual = pos_oficial
                tempo_leitura = time.time() # Congela o relógio se estiver pausado

            restante = total - atual

            if total > 0 and restante <= 4.0:
                if restante > 1.0:
                    await asyncio.sleep(restante - 1.0)
                
                await sessao.try_toggle_play_pause_async()
                exibir_aviso_grande("⏸️ Pausado!")
                await asyncio.sleep(3.5)
                break
        except:
            continue

if __name__ == "__main__":
    asyncio.run(executar_contagem())