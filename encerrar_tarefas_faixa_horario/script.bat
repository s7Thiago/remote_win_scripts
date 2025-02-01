@echo off
:: Configurar as variáveis padrão locais
set "NOME=MeuAplicativo"
set "NUM_REPETICOES=5"

:: Verificar se o arquivo existe na pasta do projeto
if exist "params.txt" (
    :: Baixar o arquivo externo (caso necessário)
    bitsadmin /download "https://raw.githubusercontent.com/SeuUsuario/branch/main/params.txt" params.txt
) else (
    :: Caso não esteja disponível, usar os valores padrão
)

:: Ler o arquivo params.txt
for /f "tokens=*" in ("params.txt") do (
    @echo off
    set "LINE=%%"
    set "VAR=..."
    for /s /d "delim=," %%LINE %%
    if defined VAR (
        %VAR% = %%VALUE%%
    )
)

:: Mostrar os valores capturados no console
echo "NOME: %NOME%"
echo "NUM_REPETICOES: %NUM_REPETICOES%