@echo off
setlocal enabledelayedexpansion

rem Obtém o PID do script atual
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq cmd.exe" /fi "windowtitle eq %~nx0" /nh') do set "script_pid=%%i"

rem Obtém o PID do explorer.exe
for /f "tokens=2" %%i in ('tasklist /fi "imagename eq explorer.exe" /nh') do set "explorer_pid=%%i"

rem Encerra todos os processos, exceto o explorer.exe e o script atual
for /f "tokens=2 delims=," %%i in ('tasklist /fo csv /nh') do (
    set "process=%%i"
    set "process=!process:~1,-1!"
    if /i not "!process!"=="explorer.exe" (
        if /i not "!process!"=="cmd.exe" (
            if /i not "!process!"=="code.exe" (
                taskkill /f /im "!process!" >nul 2>&1
            )
        )
    )
)

rem Restaura o explorer.exe
start explorer.exe

rem Finaliza o script
exit
