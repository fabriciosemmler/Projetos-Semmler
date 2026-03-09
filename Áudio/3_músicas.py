import asyncio
from winrt.windows.media.control import GlobalSystemMediaTransportControlsSessionManager

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
    print(f"▶️ [1/3] {musica_atual}")

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
                print(f"🔄 [{contador + 1}/3] {musica_atual}")
        except:
            continue

    # Espera a 3ª música acabar para pausar
    print("⏳ Aguardando fim da 3ª música...")
    while True:
        await asyncio.sleep(2)
        info = await sessao.try_get_media_properties_async()
        if f"{info.artist} - {info.title}" != musica_atual:
            await sessao.try_toggle_play_pause_async()
            print("⏸️ Pausado!")
            break

if __name__ == "__main__":
    asyncio.run(executar_contagem())