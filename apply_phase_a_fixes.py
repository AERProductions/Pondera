#!/usr/bin/env python3
"""
Phase A Fix 3: Connect soil quality to plant harvests
Replaces hardcoded yield loops with soil-quality-aware yielding
"""

def fix_plant_harvests():
    with open('dm/plant.dm', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    result = []
    i = 0
    while i < len(lines):
        # Check for vegetable harvest pattern
        if 'src.name = "Harvested"' in lines[i] and i+1 < len(lines):
            if 'new vegetable(usr)' in lines[i+1]:
                # Add the soil quality code with proper indentation
                result.append(lines[i])  # src.name = "Harvested"
                result.append('\t\t\t\t\t// Get soil quality from turf and apply yield modifier\n')
                result.append('\t\t\t\t\tvar/soil_type = src.loc.soil_type || SOIL_BASIC\n')
                result.append('\t\t\t\t\tvar/yield_modifier = GetSoilYieldModifier(soil_type)\n')
                result.append('\t\t\t\t\tvar/yield_amount = round(yield_modifier)\n')
                result.append('\t\t\t\t\tfor(var/i = 1; i <= yield_amount; i++) new vegetable(usr)\n')
                i += 2  # Skip the old vegetable line
                continue
        
        # Check for grain harvest pattern
        if 'src.name = "Picked"' in lines[i] and i+1 < len(lines):
            if 'new grain(usr)' in lines[i+1]:
                # Add the soil quality code with proper indentation
                result.append(lines[i])  # src.name = "Picked"
                result.append('\t\t\t\t\t// Get soil quality from turf and apply yield modifier\n')
                result.append('\t\t\t\t\tvar/soil_type = src.loc.soil_type || SOIL_BASIC\n')
                result.append('\t\t\t\t\tvar/yield_modifier = GetSoilYieldModifier(soil_type)\n')
                result.append('\t\t\t\t\tvar/yield_amount = round(yield_modifier)\n')
                result.append('\t\t\t\t\tfor(var/i = 1; i <= yield_amount; i++) new grain(usr)\n')
                i += 2  # Skip the old grain line
                continue
        
        result.append(lines[i])
        i += 1
    
    with open('dm/plant.dm', 'w', encoding='utf-8') as f:
        f.writelines(result)
    
    print("✓ Fixed plant harvests with soil quality modifiers")

if __name__ == '__main__':
    fix_plant_harvests()
