@echo off
rem script fait par CH v2024.02.05

%~d0
cd %~dp0

echo.
echo  ****** Préparation de l'installation AreaFse pour MEO ******
echo.

SETLOCAL enabledelayedexpansion
echo. >>log.txt
echo %date% %time% >>log.txt

echo.
echo -- Arrˆt des processus existant 

taskkill /IM galsvw* /T /F >>log.txt 2>&1
taskkill /IM ccm* /T /F >>log.txt 2>&1
taskkill /IM javaw* /T /F >>log.txt 2>&1
taskkill /IM myeasylocalservice* /F >>log.txt 2>&1
echo - OK -
echo.

echo -- Suppression des anciens galss et crypto (peu prendre un peu de temps)

IF EXIST !ProgramW6432!\santesocial\galss (wmic product where "name like 'GALSS%%'" call uninstall /nointeractive >>log.txt 2>&1)
IF EXIST !ProgramW6432!\santesocial\cps (wmic product where "name like '%%Crypto%%'" call uninstall /nointeractive >>log.txt 2>&1)

FOR /F "tokens=*" %%f in ('type liste_fichiers.txt') DO (
	IF EXIST %%f (echo %%f >>log.txt && DEL "%%f" >>log.txt 2>&1)
)

FOR /F "tokens=*" %%d in ('type liste_dossiers.txt') DO (
	IF EXIST %%d (echo %%d >>log.txt && RD "%%d" /S /Q >>log.txt 2>&1)
)

DEL /F /S /Q %userprofile%\appdata\local\temp\* >nul 2>&1
DEL /F /S /Q %windir%\temp\* >nul 2>&1

echo - OK -
echo.

echo -- Suppression ancienne version AreaFse et WI --

SC STOP PostgreSQL_Area >>log.txt 2>&1
SC DELETE PostgreSQL_Area >>log.txt 2>&1

IF EXIST c:\areafse\ (
	RD /S /Q c:\areafse\ >>log.txt 2>&1
	IF EXIST c:\areafse\ (		
		ECHO.
		ECHO. Impossible de supprimer le repertoire c:\areafse\.
		ECHO. Veuillez le supprimer manuellement avant de continuer. 
		ECHO.		
		PAUSE
	)
)

net stop mysql$medicawin >>log.txt 2>&1
sc delete mysql$medicawin >>log.txt 2>&1
DEL /F /Q %userprofile%\desktop\webintellio.lnk >>log.txt 2>&1
echo - OK -
echo.

echo -- Configuration pare-feu --
netsh firewall set portopening TCP 9012 AreaFse_MEO >>log.txt
netsh advfirewall firewall add rule name="AreaFSE_MEO" dir=in action=allow protocol=TCP localport=9012 >>log.txt
echo - OK -
echo.


echo -- D‚sactivation des veilles --

wmic ComputerSystem Get Model /value | find /i "surface" && goto suite
powershell -Command "Get-WmiObject -Namespace root\wmi -Class MSPower_DeviceEnable | where {$_.InstanceName -match 'PCI'} | Set-WmiInstance -Arguments @{Enable = 'False'}" >>log.txt 2>&1
powershell -Command "Get-WmiObject -Namespace root\wmi -Class MSPower_DeviceEnable | where {$_.InstanceName -match 'USB'} | Set-WmiInstance -Arguments @{Enable = 'False'}" >>log.txt 2>&1
powershell -Command "powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0" >>log.txt 2>&1
powershell -Command "powercfg -x -monitor-timeout-ac 0" >>log.txt 2>&1
powershell -Command "powercfg -x -standby-timeout-ac 0" >>log.txt 2>&1
powershell -Command "powercfg -x -disk-timeout-ac 0" >>log.txt 2>&1
powershell -Command "powercfg -x -hibernate-timeout-ac 0" >>log.txt 2>&1
powershell -Command "powercfg /hibernate off" >>log.txt 2>&1
powershell -Command "powercfg /setACvalueIndex scheme_current sub_buttons lidAction 0" >>log.txt 2>&1
powershell -Command "powercfg /setDCvalueIndex scheme_current sub_buttons lidAction 0" >>log.txt 2>&1
echo - OK -
echo.

:suite
echo -- Activation d'AreaFse dans le MELS --
TYPE %userprofile%\.MyEasyLocalService\config.properties | find /V "svLecteurConnected" >config.properties
COPY /Y config.properties %userprofile%\.MyEasyLocalService\ >>log.txt
echo svLecteurConnected=true>>%userprofile%\.MyEasyLocalService\config.properties
cd "%Programfiles(x86)%\MyEasyLocalService\bin\"
start MyEasyLocalService.exe
echo - OK -
echo.

timeout 5
ENDLOCAL
EXIT