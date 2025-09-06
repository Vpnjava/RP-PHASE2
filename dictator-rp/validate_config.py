# Dictator RP Configuration Validator
# Run this script to validate all JSON configuration files

import json
import os
from pathlib import Path

def validate_json_file(file_path):
    """Validate a JSON file and return any errors"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        # Check for required fields
        if 'SchemaVersion' not in data:
            return f"Missing SchemaVersion in {file_path}"
        if 'BuildID' not in data:
            return f"Missing BuildID in {file_path}"
            
        return None  # No errors
    except json.JSONDecodeError as e:
        return f"JSON syntax error in {file_path}: {e}"
    except Exception as e:
        return f"Error reading {file_path}: {e}"

def main():
    config_dir = Path("config")
    
    if not config_dir.exists():
        print("❌ Config directory not found!")
        return
    
    print("🔍 Validating Dictator RP Configuration Files...")
    print("-" * 50)
    
    errors = []
    validated = 0
    
    # List of expected config files
    expected_files = [
        "economy.json",
        "robbery.json", 
        "police.roles.json",
        "ems.json",
        "vehicle.trunk.json",
        "launder.json",
        "spawn.json",
        "security.json",
        "phone.json",
        "jail.json",
        "housing.json",
        "weapons.json"
    ]
    
    for filename in expected_files:
        file_path = config_dir / filename
        
        if not file_path.exists():
            errors.append(f"❌ Missing required file: {filename}")
            continue
            
        error = validate_json_file(file_path)
        if error:
            errors.append(f"❌ {error}")
        else:
            print(f"✅ {filename} - Valid")
            validated += 1
    
    print("-" * 50)
    print(f"📊 Validation Results:")
    print(f"   ✅ Valid files: {validated}")
    print(f"   ❌ Errors: {len(errors)}")
    
    if errors:
        print("\n🚨 Issues found:")
        for error in errors:
            print(f"   {error}")
        return False
    else:
        print("\n🎉 All configuration files are valid!")
        print("\n📋 Next steps:")
        print("   1. Update coordinates in spawn.json, police.roles.json, ems.json")
        print("   2. Update server GUID in security.json") 
        print("   3. Configure server.cfg with your settings")
        print("   4. Build PBO using Enfusion Workbench")
        print("   5. Sign with BIKey and deploy to server")
        return True

if __name__ == "__main__":
    main()
