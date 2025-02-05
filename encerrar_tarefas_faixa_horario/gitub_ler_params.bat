@echo off
setlocal EnableDelayedExpansion

bitsadmin /reset /all
:: Deleta o arquivo params.txt, se ele existir
if exist "params.txt" (
    del "params.txt"
    echo Arquivo params.txt deletado.
)
timeout /t 2

:: Configurar as variáveis padrão locais
set "NOME=MeuAplicativo"
set "NUM_REPETICOES=5"


:: Verificar se o arquivo existe na pasta do projeto
if not exist "params.txt" (
    :: Baixar o arquivo externo (caso necessário)
    bitsadmin /transfer "JobName" /download /priority normal "https://raw.githubusercontent.com/s7Thiago/remote_win_scripts/refs/heads/main/encerrar_tarefas_faixa_horario/params.txt?now=xx" "%cd%\params.txt"
    if %errorlevel% neq 0 (
        echo Erro ao baixar o arquivo params.txt
        pause
        exit /b 1
    )
)

:: Ler o arquivo params.txt
for /f "tokens=1* delims==" %%a in (params.txt) do (
    set "%%a=%%b"
)

:: Mostrar os valores capturados no console
echo "NOME: !NOME!"
echo "NUM_REPETICOES: !NUM_REPETICOES!"

endlocal