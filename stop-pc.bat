@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Получаем текущий час (0-23)
for /f "tokens=2 delims==" %%H in ('wmic os get localdatetime /value ^| find "LocalDateTime"') do (
    set "datetime=%%H"
)
set /a "currentHour=!datetime:~8,2!"

:: Проверяем, нужно ли блокировать (23:00 - 10:00)
if !currentHour! geq 22 (
    set "lock=1"
) else if !currentHour! lss 10 (
    set "lock=1"
) else (
    set "lock=0"
)

:: Если время блокировки, выводим сообщение и блокируем
if !lock! equ 1 (
    echo Set WshShell = CreateObject("WScript.Shell") > %temp%\popup.vbs
    echo WshShell.Popup "⚠️ Время работы истекло! ⏰ Сейчас %time%. Доступ разрешен с 10:00 до 23:00.", 60, "Блокировка", 48 >> %temp%\popup.vbs
    cscript //nologo %temp%\popup.vbs
    del %temp%\popup.vbs
  shutdown /s /f /t 60 /c "Acces locked from 10 am to 11pm vitek idi delay dela ."
)