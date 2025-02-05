@echo off
setlocal enabledelayedexpansion

set tempo=30

echo Configurações aplicadas para %tempo% minutos. Aguardando 15 minutos para reaplicar.

goto CENTRALIZE_PARAMETROS

:CENTRALIZE_PARAMETROS
for /f "tokens=1-2 delims=:" %%H in ('time /t') do set /a "HORA=%%H"
if %HORA% LSS 7 (call :TERMINATE_PROCESSES)
if %HORA% GEQ 22 (call :TERMINATE_PROCESSES)

echo Aguardando 15 minutos para reaplicar...
timeout /t 900

goto CENTRALIZE_PARAMETROS

:TERMINATE_PROCESSES
echo Encerrando todos os processos, exceto explorer.exe, este script, Code e Chrome...

:: Obtém o PID do script em execução
for /f "tokens=2 delims==" %%I in ('wmic process where "name='cmd.exe' and commandline like '%%%~nx0%%'" get processid /value') do set "SCRIPT_PID=%%I"

    echo Chegou aquiiiiii @@@@@@@@
:: Percorre todos os processos
for /f "tokens=1,2 delims=," %%A in ('tasklist /FI "STATUS eq RUNNING" /FO CSV /NH 2^>nul') do (
    echo Chegou aquiiiiii 2222 @@@@@@@@
    set "PID=%%~B"
    set "PROCESS_NAME=%%~nA"

    :: Remover parênteses do nome do processo
    set "PROCESS_NAME=!PROCESS_NAME:(=! "
    set "PROCESS_NAME=!PROCESS_NAME:)=! "

    :: Lista de processos a serem ignorados
    set "IGNORE_PROCESS=0"
    if /i "!PROCESS_NAME!"=="explorer" set "IGNORE_PROCESS=1"
    if /i "!PROCESS_NAME!"=="Code" set "IGNORE_PROCESS=1"
    if /i "!PROCESS_NAME!"=="chrome" set "IGNORE_PROCESS=1"
    if "!PID!"=="%SCRIPT_PID%" set "IGNORE_PROCESS=1"

    :: Encerra o processo se não estiver na lista de ignorados
    if "!IGNORE_PROCESS!"=="0" (
        echo Encerrando: !PROCESS_NAME! (PID: !PID!)
        ::taskkill /PID !PID! /F
    )
)

echo Finalizacao concluida!
exit /b