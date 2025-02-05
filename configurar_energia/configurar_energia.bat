@echo off
set tempo=30

rem Define o tempo em minutos para desligar o monitor e suspender a atividade
set /a tempoSegundos=%tempo%*60

:ConfigurarEnergia
powercfg -change -monitor-timeout-ac %tempo%
powercfg -change -monitor-timeout-dc %tempo%
powercfg -change -standby-timeout-ac %tempo%
powercfg -change -standby-timeout-dc %tempo%

echo Configurações aplicadas para %tempo% minutos. Aguardando 15 minutos para reaplicar.
timeout /t 900

goto ConfigurarEnergia
