::FFXIV Multi-mode (re)starter
::by Friendly

::Starts XIVLauncher (specify PROGRAM_PATH below)
::Kills launcher and the game if it's been running for more than 72 hours (and 18 min, just in case you're doing turnin or whatever)
::You need to tick the checkmark to log in automatically in the launcher and auto-enable multi mode in AR on startup
::Intended for a single account
::If it works, it works, if not, good luck. I'm not debugging this whatsoever. Written by AI but I've used it forever so it's reliable.

@echo off
setlocal enabledelayedexpansion
set "PROCESS_NAME=XIVLauncher.exe"
set "GAME_PROCESS=ffxiv_dx11.exe"
set "PROGRAM_PATH=C:\Users\Username\AppData\Local\XIVLauncher\XIVLauncher.exe"
set "CHECK_INTERVAL=20"
set "MAX_SECONDS=260280"
set "START_TIME_FILE=%TEMP%\xiv_start_time.txt"

:loop
tasklist /FI "IMAGENAME eq %PROCESS_NAME%" /FO CSV | find /I "%PROCESS_NAME%" >nul
if errorlevel 1 (
    echo [%TIME%] %PROCESS_NAME% is not running. Checking network connection...
    
    :: Clear the start time file since process is not running
    if exist "%START_TIME_FILE%" del "%START_TIME_FILE%" >nul 2>&1
    
    :: Quick network check
    ping -n 1 -w 1000 8.8.8.8 >nul 2>&1
    if errorlevel 1 (
        echo [%TIME%] No network connection detected. Skipping process start.
    ) else (
        echo [%TIME%] Network connection confirmed. Starting %PROCESS_NAME%...
        start "" "%PROGRAM_PATH%"
        
        :: Record start time as seconds since epoch (much faster)
        for /f %%i in ('powershell -Command "[int][double]::Parse((Get-Date -UFormat %%s))"') do set "START_EPOCH=%%i"
        echo !START_EPOCH! > "%START_TIME_FILE%"
    )
) else (
    echo [%TIME%] %PROCESS_NAME% is running.
    
    :: Check if we have a recorded start time
    if not exist "%START_TIME_FILE%" (
        echo [%TIME%] No start time recorded. Getting actual process start time...
        for /f %%i in ('powershell -Command "try { $proc = Get-Process -Name 'XIVLauncher' -ErrorAction Stop | Select-Object -First 1; [int][double]::Parse(($proc.StartTime.ToUniversalTime() - [datetime]'1970-01-01').TotalSeconds) } catch { [int][double]::Parse((Get-Date -UFormat %%s)) }"') do set "START_EPOCH=%%i"
        echo !START_EPOCH! > "%START_TIME_FILE%"
    ) else (
        :: Read start time and calculate runtime (avoid PowerShell entirely for this)
        set /p START_EPOCH=<"%START_TIME_FILE%"
        
        for /f %%i in ('powershell -Command "[int][double]::Parse((Get-Date -UFormat %%s))"') do set "CURRENT_EPOCH=%%i"
        set /a "RUNTIME_SECONDS=!CURRENT_EPOCH! - !START_EPOCH!"
        set /a "RUNTIME_HOURS=!RUNTIME_SECONDS! / 3600"
        set /a "RUNTIME_MINUTES=(!RUNTIME_SECONDS! %% 3600) / 60"
        
        :: Only show runtime every 10th check to reduce output spam
        set /a "CHECK_COUNT+=1"
        if !CHECK_COUNT! geq 10 (
            echo [%TIME%] Process runtime: !RUNTIME_HOURS! hours !RUNTIME_MINUTES! minutes
            set "CHECK_COUNT=0"
        )
        
        :: Check if we need to kill the process
        if !RUNTIME_SECONDS! geq %MAX_SECONDS% (
            echo [%TIME%] Process has been running for 72+ hours. Terminating...
            taskkill /F /IM "%PROCESS_NAME%" >nul 2>&1
            taskkill /F /IM "%GAME_PROCESS%" >nul 2>&1
            echo [%TIME%] Processes terminated.
            del "%START_TIME_FILE%" >nul 2>&1
        )
    )
)

timeout /t %CHECK_INTERVAL% /nobreak >nul
goto loop
