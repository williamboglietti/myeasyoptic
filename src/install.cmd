@echo off
echo MsgBox "OK" > "%temp%\msgbox.vbs"
start /wait %windir%\system32\wscript.exe "%temp%\msgbox.vbs"
del "%temp%\msgbox.vbs"