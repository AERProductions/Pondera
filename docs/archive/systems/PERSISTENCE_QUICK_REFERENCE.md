# Quick Reference: Player Persistence System

## Overview
Pondera's player persistence consists of 4 integrated datums that automatically serialize/deserialize through BYOND's savefile system.

---

## The 4 Phases

### 1. CharacterData (Progression)
**File**: `dm/CharacterData.dm`  
**What it saves**: 12 skill ranks + experience points  
**Access**: `player.character.frank`, `player.character.frankEXP`, etc.  
**Procs**: `Initialize()` (reset to defaults)

### 2. InventoryState (Items)
**File**: `dm/InventoryState.dm`  
**What it saves**: Item stacks in inventory (type + stack count + item variables)  
**Access**: Via `player.inventory_state.inventory` list  
**Procs**: `CaptureInventory(player)`, `RestoreInventory(player)`, `ValidateInventory()`

### 3. EquipmentState (Loadout)
**File**: `dm/EquipmentState.dm`  
**What it saves**: 20+ equipment slot flags (Wequipped, Aequipped, etc.)  
**Access**: Via `player.equipment_state.Wequipped`, etc.  
**Procs**: `CaptureEquipment(player)`, `RestoreEquipment(player)`, `ValidateEquipment()`

### 4. RecipeState (Recipes & Knowledge)
**File**: `dm/RecipeState.dm`  
**What it saves**: 25+ recipe discovery flags, 9 knowledge topics, skill levels, XP  
**Access**: Via `player.character.recipe_state.discovered_iron_hammer`, etc.  
**Procs**: 
- `DiscoverRecipe(recipe_name)` - Mark recipe learned
- `LearnTopic(topic_name)` - Mark knowledge learned
- `DiscoverBiome(biome_name)` - Mark location visited
- `IsRecipeDiscovered(recipe_name)` - Check if learned
- `IsTopicLearned(topic_name)` - Check if learned
- `AddExperience(type_name, amount)` - Award crafting XP
- `SetSkillLevel(skill_name, level)` - Update skill

---

## Common Tasks

### Award a Recipe Discovery
```dm
// In NPC dialogue or item interaction:
var/mob/players/M = usr
if(M.character && M.character.recipe_state)
  M.character.recipe_state.DiscoverRecipe("iron_hammer")
  M.character.recipe_state.AddExperience("smithing", 100)
  M << "<font color=lime>You learned to craft: Iron Hammer"
```

### Check if Recipe is Learned
```dm
// Before allowing crafting:
var/mob/players/M = usr
if(M.character && M.character.recipe_state)
  if(M.character.recipe_state.IsRecipeDiscovered("iron_hammer"))
    // Allow craft
  else
    M << "You haven't learned this recipe yet."
```

### Award Knowledge
```dm
// In tutorial NPC dialogue:
M.character.recipe_state.LearnTopic("mining")
M << "You learned about mining techniques!"
```

### Check Skill Level
```dm
// For gating dialogue options:
if(M.character.recipe_state.skill_smithing >= 3)
  // Show advanced smithing recipes
else
  // Show basic smithing only
```

### Track Biome Visits
```dm
// When player enters new biome:
M.character.recipe_state.DiscoverBiome("arctic")
```

---

## Data Structure

### RecipeState Variables

**Recipe Discovery (TRUE/FALSE)**:
```
discovered_stone_hammer, discovered_carving_knife, discovered_iron_hammer,
discovered_iron_shovel, discovered_iron_hoe, discovered_iron_sickle,
discovered_fishing_pole, discovered_iron_chisel,
discovered_steel_pickaxe, discovered_steel_hammer, discovered_steel_shovel,
discovered_steel_hoe, discovered_steel_axe, discovered_steel_sword,
discovered_bed, discovered_chest, discovered_forge, discovered_anvil,
discovered_wooden_haunch_carving,
discovered_iron_ingot_smelting, discovered_steel_ingot_creation,
discovered_tool_filing, discovered_tool_sharpening, discovered_tool_polishing
```

**Knowledge Topics (TRUE/FALSE)**:
```
tutorial_completed, learned_gathering, learned_mining, learned_crafting,
learned_smelting, learned_smithing, learned_refinement, learned_building,
learned_fishing
```

**Location Discoveries (TRUE/FALSE)**:
```
discovered_biome_temperate, discovered_biome_arctic,
discovered_biome_desert, discovered_biome_rainforest
```

**Skill Levels (0-10)**:
```
skill_mining_level, skill_smithing_level, skill_building_level,
skill_cooking_level, skill_refining_level
```

**Crafting Experience (0+)**:
```
experience_smithing, experience_building, experience_refining
```

---

## Persistence Flow

### On Player Save (Logout)
1. `Write(savefile/F)` called in _DRCH2.dm
2. For each datum:
   - Capture current state: `CaptureInventory()`, etc.
   - Validate: `ValidateInventory()`, etc.
   - Serialize: `F["inventory_state"] << player.inventory_state`
3. BYOND auto-serializes all datum variables
4. Savefile written to `players/{ckey}.sav`

### On Player Load (Login)
1. `Read(savefile/F)` called in _DRCH2.dm
2. For each datum:
   - Deserialize: `F["inventory_state"] >> player.inventory_state`
   - Check for corruption: if null, create new default
   - Restore state: `RestoreInventory()`, etc.
3. Player is now fully restored with all previous state
4. Can immediately craft, equip, interact with NPCs

---

## Recipe Categories Reference

### Tool Crafting (14)
- **Iron**: stone_hammer, carving_knife, iron_hammer, iron_shovel, iron_hoe, iron_sickle, fishing_pole, iron_chisel
- **Steel**: steel_pickaxe, steel_hammer, steel_shovel, steel_hoe, steel_axe, steel_sword

### Building (4)
- bed, chest, forge, anvil

### Smelting (5)
- iron_ingot_smelting, steel_ingot_creation, tool_filing, tool_sharpening, tool_polishing

### Miscellaneous (2)
- wooden_haunch_carving

---

## Skill Levels & XP Awards

### Typical XP Values
- Basic recipe (stone hammer): 25-50 XP
- Intermediate recipe (iron tool): 75-100 XP
- Advanced recipe (steel tool): 150-200 XP
- Structure build (forge/anvil): 200-250 XP

### Level Progression
- Rank 0→1: 100 XP
- Rank 1→2: 200 XP
- Rank 2→3: 300 XP
- (Scales with skill type)

---

## Debugging

### Check Player Recipe State
```dm
verb/debug_recipes()
  var/mob/players/M = usr
  if(M.character && M.character.recipe_state)
    var/rs = M.character.recipe_state
    M << "Recipes discovered: [rs.GetDiscoveredRecipeCount()]"
    M << "Topics learned: [rs.GetLearnedTopicCount()]"
    M << "Smithing level: [rs.skill_smithing_level], XP: [rs.experience_smithing]"
```

### Force Recipe Discovery (Dev Only)
```dm
// For testing:
M.character.recipe_state.DiscoverRecipe("iron_hammer")
M.character.recipe_state.SetSkillLevel("smithing", 5)
```

### Validate All States
```dm
// Before deployment:
M.character.ValidateCharacterData()
M.inventory_state.ValidateInventory()
M.equipment_state.ValidateEquipment()
M.vital_state.ValidateVitals()
M.character.recipe_state.ValidateRecipeState()
```

---

## Integration Points

### NPC Dialogue
```dm
// When NPC teaches recipe:
if(player.character.recipe_state.skill_smithing >= 2)
  player.character.recipe_state.DiscoverRecipe("iron_hammer")
```

### Crafting System
```dm
// Before allowing craft:
if(!player.character.recipe_state.IsRecipeDiscovered("iron_hammer"))
  return "You haven't learned this recipe"
```

### Tutorial System
```dm
// Award knowledge progression:
player.character.recipe_state.LearnTopic("smithing")
```

### UI/Display
```dm
// Count for player profile:
discovered = player.character.recipe_state.GetDiscoveredRecipeCount()
```

---

## Error Handling

### Missing recipe_state
```dm
// Handled automatically in Read() proc:
if(!player.character.recipe_state)
  player.character.recipe_state = new /datum/recipe_state()
  player.character.recipe_state.SetRecipeDefaults()
```

### Invalid Skill Level
```dm
// Handled by validation:
recipe_state.skill_smithing = clamp(skill_smithing, 0, 10)
```

### Corrupted Boolean
```dm
// Handled by validation:
discovered_iron_hammer = (discovered_iron_hammer == TRUE)
```

---

## Files Changed
- Created: `dm/RecipeState.dm`
- Modified: `dm/CharacterData.dm` (added recipe_state var)
- Modified: `dm/_DRCH2.dm` (added recipe_state Write/Read)
- Modified: `Pondera.dme` (added include)

---

## Testing Checklist
- [ ] Create new player, verify no recipes discovered
- [ ] Discover recipe, save, reload, verify recipe persists
- [ ] Award 5 recipes, verify count = 5
- [ ] Set skill level, reload, verify skill persists
- [ ] Add crafting XP, reload, verify XP persists
- [ ] Delete save file, reload, verify fallback creation
- [ ] Corrupt save file, reload, verify validation recovers

---

## Performance Notes
- Recipe checks O(1) - direct flag access
- Discovery O(1) - single flag set
- Serialization O(n) - only at save time (negligible n)
- No performance impact on frame rate
