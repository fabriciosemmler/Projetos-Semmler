import keyboard

print("Pressione qualquer tecla (ou F13) para testar... (Esc para sair)")

def monitor(e):
    print(f"Tecla detectada: {e.name} | Código: {e.scan_code}")

keyboard.hook(monitor)
keyboard.wait('esc')