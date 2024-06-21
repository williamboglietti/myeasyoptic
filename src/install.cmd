@echo off

REM Vérifier les droits administrateur en vérifiant l'accès au dossier système

mkdir "%systemdrive%\Temp\AdminCheck" >nul 2>&1
if %errorlevel% neq 0 (
    echo Set objShell = CreateObject("WScript.Shell") > "%temp%\admincheck.vbs"
    echo objShell.Popup "Vous n'avez pas les droits administrateur.", 0, "Droits administrateur", 0 + 48 > "%temp%\admincheck.vbs"
) else (
    echo Set objShell = CreateObject("WScript.Shell") > "%temp%\admincheck.vbs"
    echo objShell.Popup "Vous avez les droits administrateur.", 0, "Droits administrateur", 0 + 64 > "%temp%\admincheck.vbs"
)
rmdir "%systemdrive%\Temp\AdminCheck" >nul 2>&1
wscript.exe "%temp%\admincheck.vbs"
del "%temp%\admincheck.vbs"