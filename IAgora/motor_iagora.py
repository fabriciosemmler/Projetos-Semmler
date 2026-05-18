from google import genai
from PIL import ImageGrab
import os

# Módulo 1: Configuração com a nova biblioteca
# A google.genai busca a chave automaticamente, mas passamos explicitamente por segurança
chave_api = os.environ.get("GEMINI_API_KEY")
client = genai.Client(api_key=chave_api)

def invocar_iagora():
    # Módulo 2: Captura
    print("IAgora: Capturando a tela do emulador...")
    screenshot = ImageGrab.grab() 

    prompt = """
    Você é o 'IAgora', um assistente direto e objetivo para gamers.
    Olhe para esta imagem e aja como um micro-detonado:
    1. Diga o nome do jogo.
    2. Diga exatamente qual é o próximo passo ou objetivo que devo cumprir com base no que está na tela.
    Seja breve.
    """

    # Módulo 3: Geração de Conteúdo (Novo Formato)
    print("IAgora: Analisando o jogo...")
    response = client.models.generate_content(
        model='gemini-1.5-flash-8b',
        contents=[prompt, screenshot]
    )

    print("\n================ IAgora ================")
    print(response.text)
    print("========================================\n")

if __name__ == "__main__":
    invocar_iagora()