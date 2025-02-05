import os
import psutil
import json
from datetime import datetime
import requests

# Variáveis globais
HORARIO_LIVRE_INICIO = None
HORARIO_LIVRE_LIMITE = None
SEGUNDOS_REPETIR = None

# Função para ler o arquivo JSON do GitHub e carregar os parâmetros
def FETCH_PARAMS():
    global HORARIO_LIVRE_INICIO, HORARIO_LIVRE_LIMITE, SEGUNDOS_REPETIR
    
    url = "https://raw.githubusercontent.com/s7Thiago/remote_win_scripts/refs/heads/main/encerrar_tarefas_faixa_horario/params.json"
    response = requests.get(url)
    params = response.json()
    
    HORARIO_LIVRE_INICIO = params["HORARIO_LIVRE_INICIO"]
    HORARIO_LIVRE_LIMITE = params["HORARIO_LIVRE_LIMITE"]
    SEGUNDOS_REPETIR = params["SEGUNDOS_REPETIR"]
    
    print("Parâmetros carregados com sucesso!")

# Função para matar os processos do usuário, exceto os permitidos
def KILL_USER_PROCESSES():
    for proc in psutil.process_iter(['pid', 'name', 'username']):
        try:
            if proc.info['username'] == os.getlogin() and proc.info['name'] not in ['explorer.exe', 'code', 'chrome', 'python.exe']:
                proc.terminate()
                print(f"Processo {proc.info['name']} com PID {proc.info['pid']} encerrado.")
        except (psutil.NoSuchProcess, psutil.AccessDenied, psutil.ZombieProcess):
            pass

# Função principal
def main():
    # Carregar parâmetros do JSON
    FETCH_PARAMS()
    
    # Obter o horário atual
    now = datetime.now()
    current_hour = now.strftime("%H:%M")

    # Verificar se o horário atual está fora do intervalo livre
    if current_hour < HORARIO_LIVRE_INICIO or current_hour > HORARIO_LIVRE_LIMITE:
        KILL_USER_PROCESSES()

if __name__ == "__main__":
    main()
