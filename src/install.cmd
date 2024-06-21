@echo off

REM Vérifier les droits administrateur en vérifiant l'accès au dossier système

mkdir "%systemdrive%\Temp\AdminCheck" >nul 2>&1
if %errorlevel% neq 0 (
    echo Vous n'avez pas les droits administrateur.
    echo.
    pause
) else (
    echo Vous avez les droits administrateur.
    echo.
    pause
)
rmdir "%systemdrive%\Temp\AdminCheck" >nul 2>&1