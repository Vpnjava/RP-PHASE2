# 🚀 Step-by-Step Guide: Running Dictator Island RP Server

## 📋 Prerequisites

### 1. Required Software
- **Arma Reforger Server** (Steam or Bohemia launcher)
- **Enfusion Workbench** (for mod development)
- **Visual Studio Code** (recommended for scripting)
- **Python 3.x** (for validation scripts)

### 2. Server Requirements
- **Windows Server** or **Windows 10/11**
- **Minimum 8GB RAM** (16GB recommended)
- **50GB+ free disk space**
- **Stable internet connection**
- **Open ports**: 2001 (game), 17777 (RCON)

---

## 🔧 Step 1: Arma Reforger Server Installation

### Option A: Steam (Recommended)
```powershell
# 1. Install SteamCMD
# Download from: https://steamcdn-a.akamaihd.net/client/installer/steamcmd.zip

# 2. Create server directory
New-Item -ItemType Directory -Path "C:\ArmaReforgerServer"
cd C:\ArmaReforgerServer

# 3. Download Arma Reforger Server
.\steamcmd.exe +force_install_dir "C:\ArmaReforgerServer" +login anonymous +app_update 1874880 validate +quit
```

### Option B: Bohemia Launcher
1. Download **Bohemia Launcher**
2. Install **Arma Reforger Tools** 
3. Install **Arma Reforger Server**

---

## 🔧 Step 2: Configure Your Server

### 2.1 Update Server Configuration
Edit `c:\Users\MOAD\Server\dictator-rp\server.cfg`:

```cfg
// Update these critical settings:
hostname = "🇸🇦 Dictator Island RP [AR] - Phase 2";
passwordAdmin = "YOUR_SECURE_ADMIN_PASSWORD_HERE";
maxPlayers = 64;

// Network settings (adjust to your server)
ip = "0.0.0.0";           // Leave as 0.0.0.0 for all interfaces
port = 2001;
publicPort = 2001;

// Your server external IP (for player connections)
publicAddress = "YOUR_SERVER_IP_HERE";

// Game settings
scenario = "{ECC61978EDCC2B5A}Missions/23_Campaign.conf";  // Default Everon
mods[] = { "dictator-rp" };

// Performance for RP server
serverMaxViewDistance = 2000;  // Reduced for better performance
networkViewDistance = 1500;
serverMinGrassDistance = 50;
```

### 2.2 Update Security Configuration
Edit `config/security.json`:

```json
"AuthorizedServers": [
  {
    "ServerGUID": "YOUR_ACTUAL_SERVER_GUID_HERE",
    "IPOrCIDR": "YOUR_SERVER_IP/32",
    "Description": "Main RP server"
  }
]
```

### 2.3 Set Map Coordinates
Update these files with actual Everon coordinates:

**config/spawn.json:**
```json
"DefaultSpawn": {
  "coordinates": [6144, 100, 6144],  // Center of Everon map
  "name": "Safe Zone Central"
}
```

**config/police.roles.json:** (Example locations)
```json
"stations": {
  "north_hq": {
    "coordinates": [7200, 100, 7800]  // Northern city area
  },
  "central_hq": {
    "coordinates": [6144, 100, 6144]  // Central location  
  },
  "south_hq": {
    "coordinates": [5000, 100, 4500]  // Southern area
  }
}
```

---

## 🔧 Step 3: Create the Mod Structure

### 3.1 Mod Configuration File
Create `c:\Users\MOAD\Server\dictator-rp\mod.cpp`:

```cpp
name = "Dictator Island RP";
author = "Dictator RP Team";
authorID = "0";
version = "2.0.0";
versionAr = "نسخة ٢.٠.٠";
description = "Arabic Roleplay Server - Full RP Experience";
descriptionAr = "خادم الأدوار العربي - تجربة أدوار كاملة";

// Mod dependencies
dependencies[] = {};

// Game version compatibility  
gameVersion = "1.0";
modVersion = "2.0";

// Content info
picture = "data/logo.paa";
logo = "data/logo_small.paa";
logoOver = "data/logo_over.paa";
tooltip = "Dictator Island RP - Arabic Roleplay";

// Mod settings
serverOnly = false;
clientMod = false;
experimental = false;
```

### 3.2 Addon Configuration
Create `c:\Users\MOAD\Server\dictator-rp\config.cpp`:

```cpp
class CfgPatches
{
	class DictatorRP_Core
	{
		units[] = {};
		weapons[] = {};
		requiredVersion = 1.0;
		requiredAddons[] = {"ScriptedWidgetCore", "GameLib"};
		author = "Dictator RP Team";
		name = "Dictator Island RP - Core";
		url = "";
		version = "2.0.0";
	};
};

class CfgMods
{
	class DictatorRP
	{
		dir = "dictator-rp";
		name = "Dictator Island RP";
		author = "Dictator RP Team";
		version = "2.0.0";
		extra = 0;
		type = "Mod";
		
		dependencies[] = 
		{
			"Game",
			"Workbench"
		};
		
		class defs
		{
			class gameScriptModule
			{
				value = "";
				files[] = 
				{
					"dictator-rp/scripts/Game"
				};
			};
		};
	};
};
```

---

## 🔧 Step 4: Basic Script Structure

Create the main script entry points:

### 4.1 Main Game Module
Create `scripts/Game/DictatorRP_GameMode.c`:

```cpp
[BaseGameModeComponent()]
class DictatorRP_GameModeComponent : BaseGameModeComponent
{
	// Core services
	protected DictatorRP_ConfigService m_ConfigService;
	protected DictatorRP_PoliceService m_PoliceService;
	protected DictatorRP_EMSService m_EMSService;
	protected DictatorRP_EconomyService m_EconomyService;
	
	override void OnGameStart()
	{
		super.OnGameStart();
		
		// Initialize configuration service first
		m_ConfigService = new DictatorRP_ConfigService();
		m_ConfigService.LoadAllConfigs();
		
		// Initialize other services
		m_PoliceService = new DictatorRP_PoliceService(m_ConfigService);
		m_EMSService = new DictatorRP_EMSService(m_ConfigService);
		m_EconomyService = new DictatorRP_EconomyService(m_ConfigService);
		
		Print("[DictatorRP] Game mode initialized successfully");
	}
	
	override void OnPlayerConnected(int playerId, string name)
	{
		super.OnPlayerConnected(playerId, name);
		
		// Initialize player data
		m_EconomyService.InitializePlayer(playerId);
		
		Print(string.Format("[DictatorRP] Player connected: %1 (ID: %2)", name, playerId));
	}
}
```

### 4.2 Configuration Service
Create `scripts/Game/Services/DictatorRP_ConfigService.c`:

```cpp
class DictatorRP_ConfigService
{
	protected ref map<string, ref JsonObject> m_Configs;
	
	void DictatorRP_ConfigService()
	{
		m_Configs = new map<string, ref JsonObject>();
	}
	
	void LoadAllConfigs()
	{
		LoadConfig("economy");
		LoadConfig("police.roles");
		LoadConfig("ems");
		LoadConfig("robbery");
		LoadConfig("security");
		LoadConfig("spawn");
		LoadConfig("phone");
		LoadConfig("housing");
		LoadConfig("weapons");
		LoadConfig("launder");
		LoadConfig("jail");
		
		Print("[DictatorRP] All configurations loaded successfully");
	}
	
	protected void LoadConfig(string configName)
	{
		string configPath = string.Format("$profile:ServerProfile/dictator-rp/config/%1.json", configName);
		
		FileHandle file = FileSystem.OpenFile(configPath, FileMode.READ);
		if (!file)
		{
			Print(string.Format("[DictatorRP] ERROR: Could not load config: %1", configName));
			return;
		}
		
		string jsonContent;
		string line;
		while (file.ReadLine(line) != -1)
		{
			jsonContent += line;
		}
		file.Close();
		
		JsonObject config = new JsonObject();
		if (config.FromString(jsonContent))
		{
			m_Configs.Insert(configName, config);
			Print(string.Format("[DictatorRP] Loaded config: %1", configName));
		}
		else
		{
			Print(string.Format("[DictatorRP] ERROR: Invalid JSON in config: %1", configName));
		}
	}
	
	JsonObject GetConfig(string configName)
	{
		JsonObject config;
		if (m_Configs.Find(configName, config))
			return config;
		
		return null;
	}
}
```

---

## 🔧 Step 5: Building and Deployment

### 5.1 Validate Configuration
Run the validation script:

```powershell
cd "c:\Users\MOAD\Server\dictator-rp"
python validate_config.py
```

Expected output:
```
🔍 Validating Dictator RP Configuration Files...
✅ economy.json - Valid
✅ robbery.json - Valid
✅ police.roles.json - Valid
[... all files ...]
🎉 All configuration files are valid!
```

### 5.2 Build with Enfusion Workbench

1. **Open Enfusion Workbench**
2. **Open your mod folder**: `c:\Users\MOAD\Server\dictator-rp`
3. **Build the addon**:
   - Go to **Build** → **Build Addon**
   - Select your dictator-rp folder
   - Choose output location: `C:\ArmaReforgerServer\addons\`
   - Click **Build**

### 5.3 Create Server Profile
Create server profile directory:

```powershell
# Create server profile
New-Item -ItemType Directory -Path "C:\ArmaReforgerServer\ServerProfile" -Force
New-Item -ItemType Directory -Path "C:\ArmaReforgerServer\ServerProfile\dictator-rp" -Force

# Copy configuration files
Copy-Item "c:\Users\MOAD\Server\dictator-rp\config\*" -Destination "C:\ArmaReforgerServer\ServerProfile\dictator-rp\config\" -Recurse

# Copy server.cfg to server root
Copy-Item "c:\Users\MOAD\Server\dictator-rp\server.cfg" -Destination "C:\ArmaReforgerServer\"
```

---

## 🔧 Step 6: Start the Server

### 6.1 Create Start Script
Create `C:\ArmaReforgerServer\start_server.bat`:

```batch
@echo off
title Dictator Island RP Server

echo Starting Dictator Island RP Server...
echo Server IP: %COMPUTERNAME%
echo Port: 2001
echo.

cd /d "C:\ArmaReforgerServer"

ArmaReforgerServer.exe ^
  -config server.cfg ^
  -profile ServerProfile ^
  -logStats ^
  -nothrow ^
  -maxFPS 60

pause
```

### 6.2 Start the Server
```powershell
# Navigate to server directory
cd C:\ArmaReforgerServer

# Run the start script
.\start_server.bat
```

### 6.3 Alternative: PowerShell Start
```powershell
cd C:\ArmaReforgerServer

.\ArmaReforgerServer.exe -config server.cfg -profile ServerProfile -logStats -nothrow -maxFPS 60
```

---

## 🔧 Step 7: Verify Server is Running

### 7.1 Check Server Console
Look for these messages:
```
[DictatorRP] All configurations loaded successfully
[DictatorRP] Game mode initialized successfully
Game started.
Server is running on port 2001
```

### 7.2 Test Connection
1. **Open Arma Reforger client**
2. **Go to Server Browser** 
3. **Search for your server name**: "Dictator Island RP"
4. **Connect and test basic functionality**

### 7.3 Admin Access
- Connect to server
- Open chat and type: `/admin YOUR_ADMIN_PASSWORD`
- Access admin panel via phone (secret code)

---

## 🔧 Step 8: Firewall and Network Configuration

### 8.1 Windows Firewall
```powershell
# Open required ports
New-NetFirewallRule -DisplayName "Arma Reforger Server" -Direction Inbound -Port 2001 -Protocol TCP -Action Allow
New-NetFirewallRule -DisplayName "Arma Reforger Server UDP" -Direction Inbound -Port 2001 -Protocol UDP -Action Allow
New-NetFirewallRule -DisplayName "Arma Reforger RCON" -Direction Inbound -Port 17777 -Protocol TCP -Action Allow
```

### 8.2 Router Port Forwarding
Forward these ports to your server:
- **2001** (TCP/UDP) - Game traffic
- **17777** (TCP) - RCON (optional)

---

## 🔧 Step 9: Monitoring and Maintenance

### 9.1 Log Files
Monitor these files:
- `C:\ArmaReforgerServer\ServerProfile\server.log`
- `C:\ArmaReforgerServer\ServerProfile\dictator-rp\logs\`

### 9.2 Performance Monitoring
```powershell
# Check server performance
Get-Process ArmaReforgerServer | Select-Object CPU, WorkingSet, ProcessName
```

### 9.3 Backup Script
Create automated backup:

```powershell
# backup_server.ps1
$BackupPath = "C:\Backups\DictatorRP"
$ServerProfile = "C:\ArmaReforgerServer\ServerProfile"

New-Item -ItemType Directory -Path $BackupPath -Force
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$BackupFolder = "$BackupPath\Backup_$Timestamp"

Copy-Item $ServerProfile -Destination $BackupFolder -Recurse
Write-Host "Backup completed: $BackupFolder"
```

---

## 🚨 Troubleshooting

### Common Issues:

**1. Server won't start:**
- Check `server.cfg` syntax
- Verify mod files exist in addons folder
- Check Windows Event Viewer for errors

**2. Players can't connect:**
- Verify firewall settings
- Check port forwarding
- Confirm server IP in `server.cfg`

**3. Mod not loading:**
- Verify mod build completed successfully
- Check addon signature (BIKey)
- Review server logs for mod errors

**4. Configuration errors:**
- Run `validate_config.py` to check JSON syntax
- Verify all required config files exist
- Check file permissions

### Getting Help:
- Check server console for error messages
- Review log files in ServerProfile folder
- Verify all configuration files are valid JSON
- Test with minimal configuration first

---

## 🎉 Success! Your Server Should Now Be Running

**Final Checklist:**
- ✅ Server starts without errors
- ✅ Players can connect and join
- ✅ Basic RP systems are loading
- ✅ Configuration files are valid
- ✅ Admin access works
- ✅ Server appears in browser

**Next Steps:**
1. **Test all RP systems** (Police, EMS, Economy)
2. **Add more detailed scripts** for advanced features
3. **Configure coordinates** for actual map locations
4. **Set up automated backups**
5. **Invite players to test**

Your Dictator Island RP server is now ready for Phase 2 operation! 🚀
