Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "C:\caminho\para\seu\configurar_energia.bat" & Chr(34), 0
Set WshShell = Nothing
