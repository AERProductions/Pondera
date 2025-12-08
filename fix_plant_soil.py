#!/usr/bin/env python3
"""Fix plant.dm soil quality integration"""

with open('dm/plant.dm', 'r') as f:
    content = f.read()

# Fix vegetable harvest (around line 809)
old_vege = '''src.name = "Harvested"
						var/soil_type = SOIL_BASIC  // Soil quality integration
						for(var/i = 1; i <= (soil_type == SOIL_RICH ? 2 : 1); i++) new vegetable(usr)
						new seed(usr)'''

new_vege = '''src.name = "Harvested"
						// Get soil quality from turf and apply yield modifier
						var/soil_type = src.loc.soil_type || SOIL_BASIC
						var/yield_modifier = GetSoilYieldModifier(soil_type)
						var/yield_amount = round(yield_modifier)
						for(var/i = 1; i <= yield_amount; i++) new vegetable(usr)
						new seed(usr)'''

content = content.replace(old_vege, new_vege)

# Fix grain harvest (around line 1162)
old_grain = '''src.name = "Picked"
						var/soil_type = SOIL_BASIC  // Soil quality integration
						for(var/i = 1; i <= (soil_type == SOIL_RICH ? 2 : 1); i++) new grain(usr)
						new seed(usr)'''

new_grain = '''src.name = "Picked"
						// Get soil quality from turf and apply yield modifier
						var/soil_type = src.loc.soil_type || SOIL_BASIC
						var/yield_modifier = GetSoilYieldModifier(soil_type)
						var/yield_amount = round(yield_modifier)
						for(var/i = 1; i <= yield_amount; i++) new grain(usr)
						new seed(usr)'''

content = content.replace(old_grain, new_grain)

with open('dm/plant.dm', 'w') as f:
    f.write(content)

print("✓ Fixed plant.dm soil quality integration")
