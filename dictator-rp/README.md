# Dictator Island RP - Server Configuration Guide

## Overview
This is the complete Phase 2 configuration for Dictator Island RP server for Arma Reforger. The setup includes all necessary configuration files and folder structure as specified in the DICTATOR_RP-1 and RP documentation.

## Folder Structure Created
```
dictator-rp/
├── core/
│   ├── platform-service/
│   ├── license-guard/
│   ├── player-service/
│   └── config-service/
├── systems/
│   ├── police/
│   ├── ems/
│   ├── economy/
│   ├── crime/
│   ├── vehicles/
│   ├── housing/
│   └── phone/
├── config/           # All JSON configuration files
├── ui/
├── admin/
├── analytics/
├── anti-cheat/
├── mods/            # For built PBO files
└── server.cfg       # Server configuration
```

## Configuration Files Created

### Core Economy & Money System
- **economy.json** - White/Red money separation, jobs, taxes
- **launder.json** - Money laundering mechanics with daily caps
- **housing.json** - Real estate rental system

### Law Enforcement
- **police.roles.json** - Saudi-style rank ladder with permissions
- **jail.json** - Jail sentences (RP month = 1 real minute)
- **weapons.json** - Weapon licensing system

### Emergency Services  
- **ems.json** - Ambulance system, revive mechanics, hospital fees

### Crime & Security
- **robbery.json** - Bank/store robbery cooldowns and requirements
- **security.json** - LicenseGuard, admin levels, AFK policies

### Vehicles & Communication
- **vehicle.trunk.json** - Trunk sharing, capacities, repair kits
- **phone.json** - Phone v3 system with SMS, payments, SOS

### Spawn & World
- **spawn.json** - Single default spawn configuration

## Key Features Implemented

### 1. Economy System
- **White Money**: Legal currency, can be banked
- **Red Money**: Illicit currency, must be laundered
- Job system with configurable pay rates and taxes
- No auto-rebalancing (admin manual control)

### 2. Police System
- 9-rank Saudi-style hierarchy (Recruit to General)
- Permission-based system tied to ranks
- Evidence system with audit trails
- Fine system with configurable amounts

### 3. EMS System  
- 20-second revive with 5000 fee
- 10-minute decay timer
- Broadcast death alerts to EMS
- Hospital auto-deduction on decay

### 4. Crime Mechanics
- Major crimes require ≥10 police online (excluding AFK)
- Bank robbery: 60-min global cooldown
- Store robbery: 15-min per-store cooldown
- Jail sentences using RP month = 1 real minute

### 5. Vehicle System
- Trunk sharing with TTL (900 seconds default)
- Support for red items in trunks
- Repair kit system (light 60%, advanced 100%)
- Police impound capabilities

### 6. Phone v3 System
- Voice calls, SMS, contacts
- Mobile payments with 20k daily limit
- SOS with postal grid location
- Emergency dispatch integration

### 7. Security & Protection
- LicenseGuard server authorization
- HMAC-protected configs
- Admin level system (A1/A2/A2.RO/A3)
- AFK exclusion from police counts

## Server Setup Instructions

### 1. Server Configuration
- Edit `server.cfg` and update:
  - Admin password
  - Server name/description
  - Your Discord link
  - Network settings as needed

### 2. Security Setup
- Edit `config/security.json`:
  - Replace `EXAMPLE_GUID_CHANGE_THIS` with your actual server GUID
  - Update IP address from `127.0.0.1/32` to your server IP
  - Configure admin access levels

### 3. Mission Configuration
- The server uses default Everon mission (`23_Campaign.conf`)
- No custom world required - RP mechanics are overlay systems
- Mod loading: `mods[] = { "dictator-rp" };`

### 4. Coordinate Setup
Currently all coordinates are set to `[0, 0, 0]` placeholders. Update these in:
- `spawn.json` - Default spawn location
- `police.roles.json` - Police HQ locations  
- `ems.json` - EMS station locations
- `launder.json` - Laundry dealer location

## How It Works

### Runtime Flow
1. **ConfigService** loads all JSON files from `/config/` at server startup
2. **LicenseGuard** validates server authorization and config integrity
3. **Systems** (PoliceService, EMSService, EconomyService, etc.) read configs
4. **Player interactions** are governed by the loaded configuration rules
5. **Hot-reload** supported for config changes (with HMAC validation)

### No World Editing Required
- Uses existing Arma Reforger world (Everon)
- RP systems are overlaid via scripted interactions
- Interaction markers placed dynamically based on configs
- Police/EMS/job locations configurable without map changes

### Data Persistence  
- SQLite database for player data (configured in core/player-service)
- WAL mode enabled for performance
- Automatic backup strategy included

## Next Steps

1. **Build the PBO**: Use Enfusion Workbench to build the mod into a PBO file
2. **Sign with BIKey**: Create and sign the PBO with your BIKey
3. **Deploy**: Place PBO in server mods directory
4. **Test**: Verify all systems work with the provided configuration
5. **Customize**: Adjust coordinates, prices, and rules as needed

## Important Notes

- All configs use HMAC-SHA256 protection in production
- AFK players are automatically excluded from police count gates
- Money laundering has daily caps to prevent economy breaking
- Evidence system maintains full audit trails
- Phone payments limited to 20k per day (bank approval for larger)
- Vehicle trunk sharing expires automatically via TTL
- EMS revive always costs 5000 white money (even in training)

## Arabic Localization
- All in-game UI displays in Arabic (RTL)
- This documentation is English for developers
- Player-facing text uses Arabic names from configs

---

**Technical Stack:**
- Engine: Enfusion
- Language: Enforce Script (C#-like)
- Data: JSON configs + SQLite
- Protection: BIKey signing + HMAC
- Platform: PC, Xbox, PS5 cross-platform support
