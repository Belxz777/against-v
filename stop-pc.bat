@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

:: Настройки
set "UNLOCK_CODE=1234"              :: Код для отмены выключения
set "LOCK_TIME_FROM=22"             :: Блокировать после 22:00
set "LOCK_TIME_TO=10"               :: Разблокировать после 10:00
set "SHUTDOWN_DELAY=60"             :: Задержка перед выключением (сек)

:: Получаем текущий час (0-23)
for /f "tokens=2 delims==" %%H in ('wmic os get localdatetime /value ^| find "LocalDateTime"') do (
    set "datetime=%%H"
)
set /a "currentHour=!datetime:~8,2!"

:: Проверяем, нужно ли блокировать (22:00 - 10:00)
if !currentHour! geq %LOCK_TIME_FROM% (
    set "lock=1"
) else if !currentHour! lss %LOCK_TIME_TO% (
    set "lock=1"
) else (
    set "lock=0"
)

:: Если время блокировки
if !lock! equ 1 (
    :: Создаем VBScript для отображения сообщения
    echo Set WshShell = CreateObject("WScript.Shell") > %temp%\popup.vbs
    echo message = "⚠️ Внимание! ⏰ Сейчас %time%. " &_ >> %temp%\popup.vbs
    echo "Доступ разрешен(access prohib) с 10:00 до 22:00. " &_ >> %temp%\popup.vbs
    echo "Компьютер выключится через %SHUTDOWN_DELAY% секунд. " &_ >> %temp%\popup.vbs
    echo "Введите код отмены в консоль." >> %temp%\popup.vbs
    echo WshShell.Popup message, %SHUTDOWN_DELAY%, "Блокировка", 48 >> %temp%\popup.vbs
    cscript //nologo %temp%\popup.vbs
    del %temp%\popup.vbs

    :: Запускаем обратный отсчет с возможностью отмены
    echo.
    echo Введите код отмены (%UNLOCK_CODE%) чтобы остановить выключение:
    timeout /t %SHUTDOWN_DELAY% /nobreak || (
        set /p "user_input=VVedi kod Витек : "
        if "!user_input!"=="%UNLOCK_CODE%" (
            echo Выключение отменено!
            timeout /t 3 >nul
            exit /b
        ) else (
            echo Неверный код! Выключение продолжается...
            timeout /t 2 >nul
        )
    )

    :: Если время вышло - выключаем
    shutdown /s /f /t 10 /c "Access locked from 10:00 to 22:00. Vitek, idi delay dela!"
)