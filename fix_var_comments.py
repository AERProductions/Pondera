#!/usr/bin/env python3
"""
Fix DM compiler errors caused by inline comments in var blocks
These comments prevent the DM compiler from properly parsing variable declarations
"""

import os
import re
from pathlib import Path

# Files with known comment issues
AFFECTED_FILES = [
    "dm/KingdomMaterialExchange.dm",
    "dm/SupplyDemandSystem.dm",
    "dm/MarketIntegrationLayer.dm",
    "dm/NPCMerchantSystem.dm",
    "dm/TreasuryUISystem.dm",
    "dm/MaterialRegistrySystem.dm",
    "dm/WeaponArmorScalingSystem.dm",
    "dm/DeedEconomySystem.dm",
    "dm/CrisisEventsSystem.dm",
    "dm/SpecialAttacksSystem.dm",
    "dm/TradingPostUI.dm",
    "dm/DynamicMarketPricingSystem.dm",
    "dm/ElevationTerrainRefactor.dm",
    "dm/PlayerEconomicEngagement.dm",
    "dm/EconomicGovernanceSystem.dm",
    "dm/MarketBoardUI.dm",
    "dm/RecipeDiscoveryRateBalancing.dm",
    "dm/LocationGatedCraftingSystem.dm",
    "dm/CombatProgressionLoop.dm",
    "dm/PvPRankingSystem.dm",
    "dm/ItemInspectionSystem.dm",
    "dm/TerritoryResourceAvailability.dm",
    "dm/CookingSystem.dm",
]

def fix_file(filepath):
    """Remove inline comments from var blocks"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        fixed_lines = []
        in_var_block = False
        indent_level = 0
        
        for i, line in enumerate(lines):
            # Detect var block start
            if re.match(r'\s*var\s*$', line):
                in_var_block = True
                indent_level = len(line) - len(line.lstrip())
                fixed_lines.append(line)
                continue
            
            # Detect var block end (dedent or closing brace)
            if in_var_block:
                current_indent = len(line) - len(line.lstrip())
                
                # End of var block if we dedent or hit a closing brace
                if line.strip() and current_indent <= indent_level and not line.strip().startswith('//'):
                    if not (line.strip().startswith('var') or '=' in line or line.strip() == ''):
                        in_var_block = False
            
            # If in var block, remove inline comments
            if in_var_block and '//' in line:
                # Split on // but preserve the var assignment
                match = re.match(r'(\s*[\w_]+\s*=\s*[^/]*?)\s*//.*$', line)
                if match:
                    line = match.group(1) + '\n'
            
            fixed_lines.append(line)
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(fixed_lines)
        
        print(f"✓ Fixed {filepath}")
        return True
    
    except Exception as e:
        print(f"✗ Error fixing {filepath}: {e}")
        return False

def main():
    base_path = Path("c:\\Users\\ABL\\Desktop\\Pondera")
    
    fixed_count = 0
    for file in AFFECTED_FILES:
        filepath = base_path / file
        if filepath.exists():
            if fix_file(str(filepath)):
                fixed_count += 1
        else:
            print(f"? File not found: {file}")
    
    print(f"\nFixed {fixed_count}/{len(AFFECTED_FILES)} files")

if __name__ == "__main__":
    main()
