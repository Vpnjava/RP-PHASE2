# Dictator Island RP - Server Setup Script
# PowerShell version with enhanced error handling

param(
    [string]$ServerPath = "",
    [switch]$AutoStart = $false
)

function Write-ColorText {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Test-AdminRights {
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

# Header
Clear-Host
Write-ColorText "========================================" "Cyan"
Write-ColorText "   Dictator Island RP - Server Setup" "Yellow" 
Write-ColorText "========================================" "Cyan"
Write-Host ""

# Check if running from correct directory
if (-not (Test-Path "config\economy.json")) {
    Write-ColorText "ERROR: Please run this script from the dictator-rp folder" "Red"
    Write-ColorText "Current directory: $PWD" "Red"
    Write-ColorText "Expected files not found!" "Red"
    Read-Host "Press Enter to exit"
    exit 1
}

Write-ColorText "✅ Running from correct directory" "Green"

# Step 1: Validate configuration
Write-ColorText "`nStep 1: Validating configuration files..." "Yellow"

if (Test-Path "validate_config.py") {
    try {
        $result = python validate_config.py
        if ($LASTEXITCODE -eq 0) {
            Write-ColorText "✅ Configuration validation passed" "Green"
        } else {
            Write-ColorText "❌ Configuration validation failed!" "Red"
            Write-ColorText "Please fix the issues above before continuing." "Red"
            Read-Host "Press Enter to exit"
            exit 1
        }
    } catch {
        Write-ColorText "⚠️ Python not found, skipping validation" "Yellow"
    }
} else {
    Write-ColorText "⚠️ validate_config.py not found, skipping validation" "Yellow"
}

# Step 2: Find Arma Reforger Server
Write-ColorText "`nStep 2: Locating Arma Reforger Server..." "Yellow"

$ServerPaths = @(
    "C:\Program Files (x86)\Steam\steamapps\common\Arma Reforger Server",
    "C:\ArmaReforgerServer", 
    "D:\ArmaReforgerServer",
    "C:\Program Files\Bohemia Interactive\Arma Reforger Server"
)

$FoundPath = $null

if ($ServerPath -and (Test-Path "$ServerPath\ArmaReforgerServer.exe")) {
    $FoundPath = $ServerPath
    Write-ColorText "✅ Using specified path: $FoundPath" "Green"
} else {
    foreach ($Path in $ServerPaths) {
        if (Test-Path "$Path\ArmaReforgerServer.exe") {
            $FoundPath = $Path
            Write-ColorText "✅ Found server at: $FoundPath" "Green"
            break
        }
    }
}

if (-not $FoundPath) {
    Write-ColorText "❌ Arma Reforger Server not found!" "Red"
    Write-Host ""
    Write-ColorText "Please install Arma Reforger Server first:" "Yellow"
    Write-ColorText "1. Via Steam: Search 'Arma Reforger Server' in Tools" "White"
    Write-ColorText "2. Via SteamCMD: app_update 1874880" "White"
    Write-ColorText "3. Via Bohemia Launcher" "White"
    Write-Host ""
    
    $ManualPath = Read-Host "Enter Arma Reforger Server path (or press Enter to exit)"
    if (-not $ManualPath -or -not (Test-Path "$ManualPath\ArmaReforgerServer.exe")) {
        Write-ColorText "❌ Invalid path or ArmaReforgerServer.exe not found!" "Red"
        Read-Host "Press Enter to exit"
        exit 1
    }
    $FoundPath = $ManualPath
}

# Step 3: Setup server profile
Write-ColorText "`nStep 3: Setting up server profile..." "Yellow"

$ProfilePath = "$FoundPath\ServerProfile"
$ModProfilePath = "$ProfilePath\dictator-rp"
$ConfigPath = "$ModProfilePath\config"

try {
    # Create directories
    if (-not (Test-Path $ProfilePath)) { New-Item -ItemType Directory -Path $ProfilePath -Force | Out-Null }
    if (-not (Test-Path $ModProfilePath)) { New-Item -ItemType Directory -Path $ModProfilePath -Force | Out-Null }
    if (-not (Test-Path $ConfigPath)) { New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null }
    
    Write-ColorText "✅ Created profile directories" "Green"
    
    # Copy configuration files
    Copy-Item "config\*" -Destination $ConfigPath -Force -Recurse
    Write-ColorText "✅ Copied configuration files" "Green"
    
    # Copy server.cfg
    Copy-Item "server.cfg" -Destination $FoundPath -Force
    Write-ColorText "✅ Copied server configuration" "Green"
    
} catch {
    Write-ColorText "❌ Failed to setup server profile: $($_.Exception.Message)" "Red"
    Read-Host "Press Enter to exit"
    exit 1
}

# Step 4: Create start script
Write-ColorText "`nStep 4: Creating server start script..." "Yellow"

$StartScript = @"
@echo off
title Dictator Island RP Server
color 0A

echo.
echo ========================================
echo    Dictator Island RP Server Starting
echo ========================================
echo.
echo Server Path: $FoundPath
echo Profile: ServerProfile
echo Config: server.cfg
echo.

cd /d "$FoundPath"

echo Starting server...
ArmaReforgerServer.exe -config server.cfg -profile ServerProfile -logStats -nothrow -maxFPS 60

echo.
echo Server stopped.
pause
"@

try {
    $StartScript | Out-File -FilePath "$FoundPath\start_dictator_rp.bat" -Encoding ASCII
    Write-ColorText "✅ Created start script" "Green"
} catch {
    Write-ColorText "❌ Failed to create start script: $($_.Exception.Message)" "Red"
}

# Step 5: Firewall configuration
Write-ColorText "`nStep 5: Configuring Windows Firewall..." "Yellow"

if (Test-AdminRights) {
    try {
        # Check if rules already exist
        $ExistingRule = Get-NetFirewallRule -DisplayName "Arma Reforger Server*" -ErrorAction SilentlyContinue
        
        if (-not $ExistingRule) {
            New-NetFirewallRule -DisplayName "Arma Reforger Server TCP" -Direction Inbound -Port 2001 -Protocol TCP -Action Allow | Out-Null
            New-NetFirewallRule -DisplayName "Arma Reforger Server UDP" -Direction Inbound -Port 2001 -Protocol UDP -Action Allow | Out-Null
            Write-ColorText "✅ Firewall rules created" "Green"
        } else {
            Write-ColorText "✅ Firewall rules already exist" "Green"
        }
    } catch {
        Write-ColorText "⚠️ Could not create firewall rules: $($_.Exception.Message)" "Yellow"
        Write-ColorText "   Please manually open port 2001 (TCP/UDP)" "Yellow"
    }
} else {
    Write-ColorText "⚠️ Not running as administrator - cannot configure firewall" "Yellow"
    Write-ColorText "   Please manually open port 2001 (TCP/UDP) or re-run as admin" "Yellow"
}

# Final setup summary
Write-Host ""
Write-ColorText "========================================" "Cyan"
Write-ColorText "         SETUP COMPLETE!" "Green"
Write-ColorText "========================================" "Cyan"
Write-Host ""

Write-ColorText "Server files configured at:" "White"
Write-ColorText "  $FoundPath" "Cyan"
Write-Host ""

Write-ColorText "⚠️  IMPORTANT - Before starting the server:" "Yellow"
Write-Host ""

Write-ColorText "1. Edit server.cfg and update:" "White"
Write-ColorText "   • passwordAdmin (set your admin password)" "Gray"
Write-ColorText "   • hostname (customize server name)" "Gray"
Write-ColorText "   • publicAddress (your external IP)" "Gray"
Write-Host ""

Write-ColorText "2. Edit ServerProfile\dictator-rp\config\security.json:" "White"
Write-ColorText "   • Replace EXAMPLE_GUID_CHANGE_THIS with your server GUID" "Gray"
Write-ColorText "   • Update IP from 127.0.0.1 to your server IP" "Gray"
Write-Host ""

Write-ColorText "3. Optional - Update coordinates in config files:" "White"
Write-ColorText "   • spawn.json (spawn location)" "Gray"
Write-ColorText "   • police.roles.json (police stations)" "Gray"
Write-ColorText "   • ems.json (EMS stations)" "Gray"
Write-Host ""

Write-ColorText "To start the server:" "White"
Write-ColorText "  Run: $FoundPath\start_dictator_rp.bat" "Cyan"
Write-Host ""

Write-ColorText "For detailed instructions, see: SERVER_SETUP_GUIDE.md" "Yellow"
Write-Host ""

# Ask if user wants to open directories or start server
Write-Host "What would you like to do next?"
Write-Host "1. Open server directory"
Write-Host "2. Edit server.cfg"
Write-Host "3. Start server now (if configured)"
Write-Host "4. Exit"
Write-Host ""

$Choice = Read-Host "Enter choice (1-4)"

switch ($Choice) {
    "1" { 
        Invoke-Item $FoundPath
        Write-ColorText "✅ Opened server directory" "Green"
    }
    "2" { 
        if (Get-Command notepad -ErrorAction SilentlyContinue) {
            Start-Process notepad "$FoundPath\server.cfg"
            Write-ColorText "✅ Opened server.cfg in notepad" "Green"
        } else {
            Invoke-Item "$FoundPath\server.cfg"
        }
    }
    "3" {
        if ($AutoStart) {
            Write-ColorText "🚀 Starting server..." "Green"
            Start-Process "$FoundPath\start_dictator_rp.bat"
        } else {
            Write-ColorText "⚠️ Please ensure you've configured server.cfg first!" "Yellow"
            $Confirm = Read-Host "Start anyway? (y/n)"
            if ($Confirm -eq "y" -or $Confirm -eq "Y") {
                Write-ColorText "🚀 Starting server..." "Green"
                Start-Process "$FoundPath\start_dictator_rp.bat"
            }
        }
    }
    default {
        Write-ColorText "✅ Setup complete! See SERVER_SETUP_GUIDE.md for next steps." "Green"
    }
}

Write-Host ""
Write-ColorText "Setup script completed successfully!" "Green"
Read-Host "Press Enter to exit"
