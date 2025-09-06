@echo off
title Dictator Island RP - Server Setup Helper
color 0A

echo.
echo ========================================
echo   Dictator Island RP - Server Setup
echo ========================================
echo.

:: Check if we're in the right directory
if not exist "config\economy.json" (
    echo ERROR: Please run this script from the dictator-rp folder
    echo Current directory: %CD%
    echo Expected files not found!
    pause
    exit /b 1
)

echo Step 1: Validating configuration files...
if exist "validate_config.py" (
    python validate_config.py
    if errorlevel 1 (
        echo.
        echo ERROR: Configuration validation failed!
        echo Please fix the issues above before continuing.
        pause
        exit /b 1
    )
) else (
    echo Warning: validate_config.py not found, skipping validation
)

echo.
echo Step 2: Checking Arma Reforger Server installation...

:: Common server installation paths
set "SERVER_PATH_1=C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server"
set "SERVER_PATH_2=C:\ArmaReforgerServer"
set "SERVER_PATH_3=D:\ArmaReforgerServer"

set "SERVER_PATH="

if exist "%SERVER_PATH_1%\ArmaReforgerServer.exe" (
    set "SERVER_PATH=%SERVER_PATH_1%"
    echo Found server at: %SERVER_PATH%
) else if exist "%SERVER_PATH_2%\ArmaReforgerServer.exe" (
    set "SERVER_PATH=%SERVER_PATH_2%"
    echo Found server at: %SERVER_PATH%
) else if exist "%SERVER_PATH_3%\ArmaReforgerServer.exe" (
    set "SERVER_PATH=%SERVER_PATH_3%"
    echo Found server at: %SERVER_PATH%
) else (
    echo.
    echo ERROR: Arma Reforger Server not found!
    echo.
    echo Please install Arma Reforger Server first:
    echo 1. Via Steam: Search "Arma Reforger Server" in Tools
    echo 2. Via SteamCMD: app_update 1874880
    echo 3. Via Bohemia Launcher
    echo.
    echo Or manually specify the path when prompted.
    echo.
    set /p "SERVER_PATH=Enter Arma Reforger Server path (or press Enter to exit): "
    if "%SERVER_PATH%"=="" exit /b 1
    if not exist "%SERVER_PATH%\ArmaReforgerServer.exe" (
        echo ERROR: ArmaReforgerServer.exe not found at specified path!
        pause
        exit /b 1
    )
)

echo.
echo Step 3: Setting up server profile...

:: Create server profile directory
if not exist "%SERVER_PATH%\ServerProfile" mkdir "%SERVER_PATH%\ServerProfile"
if not exist "%SERVER_PATH%\ServerProfile\dictator-rp" mkdir "%SERVER_PATH%\ServerProfile\dictator-rp"
if not exist "%SERVER_PATH%\ServerProfile\dictator-rp\config" mkdir "%SERVER_PATH%\ServerProfile\dictator-rp\config"

:: Copy configuration files
echo Copying configuration files...
xcopy "config\*" "%SERVER_PATH%\ServerProfile\dictator-rp\config\" /E /Y > nul
if errorlevel 1 (
    echo ERROR: Failed to copy configuration files!
    pause
    exit /b 1
)

:: Copy server.cfg
echo Copying server configuration...
copy "server.cfg" "%SERVER_PATH%\" > nul
if errorlevel 1 (
    echo ERROR: Failed to copy server.cfg!
    pause
    exit /b 1
)

echo.
echo Step 4: Creating server start script...

:: Create start script
(
echo @echo off
echo title Dictator Island RP Server
echo.
echo echo Starting Dictator Island RP Server...
echo echo Server configuration: server.cfg
echo echo Profile directory: ServerProfile
echo echo.
echo.
echo cd /d "%SERVER_PATH%"
echo.
echo ArmaReforgerServer.exe -config server.cfg -profile ServerProfile -logStats -nothrow -maxFPS 60
echo.
echo pause
) > "%SERVER_PATH%\start_dictator_rp.bat"

echo.
echo ========================================
echo           SETUP COMPLETE!
echo ========================================
echo.
echo Server files have been set up at:
echo %SERVER_PATH%
echo.
echo IMPORTANT - Before starting the server:
echo.
echo 1. Edit server.cfg and update:
echo    - passwordAdmin (set your admin password)
echo    - hostname (customize server name)
echo    - publicAddress (your external IP)
echo.
echo 2. Edit ServerProfile\dictator-rp\config\security.json:
echo    - Replace EXAMPLE_GUID_CHANGE_THIS with your server GUID
echo    - Update IP address from 127.0.0.1 to your server IP
echo.
echo 3. Optional: Update coordinates in config files:
echo    - spawn.json (spawn location)
echo    - police.roles.json (police stations)
echo    - ems.json (EMS stations)
echo.
echo To start the server:
echo 1. Run: %SERVER_PATH%\start_dictator_rp.bat
echo 2. Or use Enfusion Workbench to build/load the mod first
echo.
echo For detailed instructions, see: SERVER_SETUP_GUIDE.md
echo.
pause

echo.
echo Would you like to open the server directory now? (y/n)
set /p "OPEN_DIR="
if /i "%OPEN_DIR%"=="y" (
    explorer "%SERVER_PATH%"
)

echo.
echo Setup complete! Check SERVER_SETUP_GUIDE.md for detailed instructions.
pause
