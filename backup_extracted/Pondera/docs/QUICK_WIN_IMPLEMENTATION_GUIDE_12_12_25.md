# Quick-Win Implementation Checklist

## 🎯 AUDIO INTEGRATION (Start Here - 2-3 Days)

### Step 1: Wire Audio to Combat (2 hours)
**File**: `dm/CombatSystem.dm` line ~96
```dm
// CURRENT:
proc/Attack(var/mob/players/attacker, var/mob/Defender)
    // ... damage calculation ...
    Defender.hp -= damage

// ADD THIS:
proc/Attack(var/mob/players/attacker, var/mob/Defender)
    // ... damage calculation ...
    Defender.hp -= damage
    PlayCombatSound("slash", attacker.loc)  // NEW LINE
```

**Sounds to Add**:
- `snd/combat/slash.ogg` - Melee hit
- `snd/combat/block.ogg` - Damage blocked
- `snd/combat/miss.ogg` - Attack misses
- `snd/combat/death.ogg` - NPC death

### Step 2: Wire Audio to UI (1 hour)
**File**: `dm/BuildingMenuUI.dm`, `dm/MarketBoardUI.dm`, `dm/InventoryUI.dm`
```dm
// Add to all menu click handlers:
onclick(menu_item) {
    PlayUISound("click", usr.loc)  // NEW LINE
    // ... existing menu logic ...
}
```

**Sounds to Add**:
- `snd/ui/click.ogg` - Menu select
- `snd/ui/open.ogg` - Menu open
- `snd/ui/close.ogg` - Menu close

### Step 3: Create Placeholder Audio Files (30 min)
```powershell
# In snd/ directory, create silent placeholders
mkdir snd\combat
mkdir snd\ui
mkdir snd\ambient

# Use any .ogg encoder (Audacity, ffmpeg) to create 1-second silent tracks
# Or download from freesound.org and convert to .ogg
```

### Step 4: Test End-to-End (30 min)
```
1. Build: Run task "dm: build - Pondera.dme"
2. Boot game
3. Perform combat action → hear sound
4. Click menu → hear sound
5. No errors in world.log
```

**Expected**: ✅ Game has audio; can be improved with better sound files later

---

## 🔧 DEAD CODE CLEANUP (1-2 Hours, Low Risk)

### Files to Clean
- **lg.dm** (lines 197-2500): Commented resource generation
- **mining.dm** (lines 1203-1400): Commented overlay code
- **Light.dm** (lines 531-1000): Commented crafting

### Safe Removal Process
```dm
// Example: lg.dm line 197
// CURRENT:
/*proc/digsand(var/turf/Sand,amount)
    set waitfor = 0
    set popup_menu = 1
    var/mob/players/M
    M = usr
    M.UED=1
    M << "You Begin collecting some Sand in the Jar..."
    // ... 20 more lines ...
*/

// REMOVE ENTIRE BLOCK (in git, can restore if needed)

// Keep only:
- One example of old style (for reference)
- Comments explaining why it was removed
```

### Cleanup Command
```powershell
# Search for commented blocks in lg.dm
Select-String -Path "dm/lg.dm" -Pattern "^/\*|^\s*\*/" | head -20

# Review, then manually remove in VS Code
# Git history preserves original code
```

**Expected**: ~50 fewer lines, easier code navigation

---

## 🎭 NPC RECIPE TEACHING UI (2-3 Days)

### Step 1: Build HTML Menu Framework (4 hours)

**File**: Create new file `dm/NPCRecipeMenu.dm`

```dm
/datum/npc_recipe_menu
    var/npc_name = ""
    var/list/recipes = list()
    var/player = null

    proc/Display()
        var/html = "<table><tr><th>Recipe</th><th>Skill Req</th><th>Learn</th></tr>"
        for(var/recipe_name in recipes)
            var/recipe = RECIPES[recipe_name]
            html += "<tr><td>[recipe_name]</td><td>Level [recipe["skill_level"]]</td>"
            html += "<td><a href='?src=\ref[src];learn=[recipe_name]'>Learn</a></td></tr>"
        html += "</table>"
        player << browse(html, "window=npc_recipes")
```

### Step 2: Hook Up NPC Interaction (2 hours)

**File**: `dm/NPCDialogueSystem.dm` line 329 - Replace stub

```dm
// CURRENT:
if(action == "trade")
    player << "Opening trade interface... (stub)"

// CHANGE TO:
if(action == "trade")
    var/datum/npc_recipe_menu/menu = new(src.npc_name, src.recipes)
    menu.player = player
    menu.Display()
```

### Step 3: Implement Recipe Unlock Handler (1 hour)

**File**: `dm/NPCRecipeMenu.dm` - Add this proc

```dm
Topic(href, href_list)
    if(href_list["learn"])
        var/recipe_name = href_list["learn"]
        if(player.character.GetRankLevel(src.required_rank) >= recipes[recipe_name]["skill_req"])
            UnlockRecipeFromNPC(player, recipe_name)
            player << "You learned [recipe_name]!"
        else
            player << "You need higher skill to learn this."
```

### Step 4: Add Flavor Text (1 hour)

Each NPC teaches different recipes based on type:
```dm
/datum/npc
    var/npc_type = "blacksmith"  // or "scholar", "fisherman", etc
    var/recipes = list(
        "Iron Sword" = 3,      // skill level required
        "Iron Plate" = 4,
        "Damascus Steel" = 5
    )
```

**Expected**: ✅ NPCs can teach recipes; players see menu; progression works

---

## 📊 EQUIPMENT OVERLAY COMPLETION (2-3 Days)

### Current Status
- **Property checks commented out**: Lines 136, 146, 250, 298 in EquipmentTransmutationSystem.dm
- **Root cause**: `.is_cosmetic` property not defined on items

### Step 1: Define Cosmetic Property (1 hour)

**File**: `dm/Objects.dm` - Add to item `/obj/items` type definition

```dm
/obj/items
    var/is_cosmetic = 0         // 0 = equipment, 1 = cosmetic/fashion
    var/equipment_slot = ""     // "head", "chest", "hands", "feet", etc
    var/overlay_icon = null     // Icon to display when worn
```

### Step 2: Update All Items (3 hours - Bulk Edit)

Use global find/replace on 200+ item definitions:

```
Find existing items and add cosmetic/slot properties:

/obj/items/armor/iron_plate
    // ADD THESE LINES:
    is_cosmetic = 0
    equipment_slot = "chest"
    overlay_icon = 'dmi/64/armor.dmi'
```

### Step 3: Uncomment Property Checks (30 min)

**File**: `dm/EquipmentTransmutationSystem.dm`

```dm
// CURRENT (line 136):
// TODO: Check .is_cosmetic once property is defined on equipment items
if(E)  // Placeholder check

// CHANGE TO:
if(!E.is_cosmetic)  // Only transmute equipment, not cosmetics
    equipped_record[E] = E.equipment_slot
```

### Step 4: Test Overlay Rendering (1 hour)

```
1. Equip armor → see overlay on character sprite
2. Switch continents → equipment transmutes
3. Cosmetics stay in inventory (not transmuted)
```

**Expected**: ✅ Visual equipment on characters, cosmetics work

---

## 🎬 RECIPE EXPERIMENTATION UI (3-4 Days)

### Step 1: Design Ingredient Selection Interface (4 hours)

**File**: Create `dm/RecipeExperimentationUI.dm`

```dm
/datum/experimentation_interface
    var/player = null
    var/selected_ingredients = list()
    var/max_ingredients = 5

    proc/ShowMenu()
        var/html = "<center><h2>Recipe Experimentation</h2>"
        html += "<table>"
        
        // List available ingredients
        for(var/item in player.contents)
            if(IsValidIngredient(item))
                html += "<tr><td>[item.name]</td>"
                html += "<td><a href='?add=[item]'>Add</a></td></tr>"
        
        html += "</table>"
        html += "<a href='?experiment'>Experiment</a>"
        player << browse(html, "window=experimentation")
```

### Step 2: Implement Experimentation Logic (3 hours)

**File**: `dm/RecipeExperimentationSystem.dm` line 208 - Replace TODO

```dm
Topic(href, href_list)
    if(href_list["experiment"])
        var/result = AttemptExperimentation(selected_ingredients)
        if(result)
            player << "Success! You discovered [result]!"
            UnlockRecipeFromExperimentation(player, result)
        else
            player << "The experiment failed..."
            player.character.experimentation_attempts++
```

### Step 3: Wire Savefile Integration (1.5 hours)

**File**: `dm/SavingChars.dm` - Modify character save/load

```dm
// In Save_CharacterData():
F["character"]["experimentation_attempts"] = M.character.experimentation_attempts
F["character"]["discovered_via_experiment"] = M.character.discovered_via_experiment

// In Load_CharacterData():
M.character.experimentation_attempts = F["character"]["experimentation_attempts"] || 0
M.character.discovered_via_experiment = F["character"]["discovered_via_experiment"] || list()
```

### Step 4: Add Success/Failure Feedback (1.5 hours)

```dm
// Success animation:
PlayCombatSound("success", player.loc)
ShowParticleEffect("sparkles", player.loc)
player << "<font color=green><b>EXPERIMENTATION SUCCESSFUL!</b></font>"

// Failure animation:
PlayCombatSound("fizzle", player.loc)
player << "<font color=red>The experiment fizzled...</font>"
```

**Expected**: ✅ Players can discover recipes through experimentation

---

## ⚡ QUICK-WIN PRIORITY ORDER

### Day 1-2: Audio (Highest ROI)
- Adds sensory feedback
- 2-3 days of work
- Users notice immediately
- No blockers

### Day 3: Cleanup (Maintenance)
- Removes 500 lines of dead code
- 1-2 hours of work
- Improves code readability
- Zero risk

### Day 4-5: NPC Recipes (Feature Completion)
- Activates NPC system
- 2-3 days of work
- Integrates with existing progression
- Medium complexity

### Day 6-7: Equipment Overlay (Visual)
- Cosmetic improvement
- 2-3 days of work
- Requires property definition
- Some item definitions needed

---

## 🔍 HOW TO VERIFY EACH FEATURE

### Audio Check
```dm
// In world/New() after audio system boots:
if(!GetSoundManager())
    world.log << "ERROR: Audio system failed to boot!"
else
    world.log << "Audio system ready: [GetSoundManager()]"

// In combat:
DamagePlayer(attacker, defender, damage)
    defender.hp -= damage
    if(sound_system)
        sound_system.PlaySound("combat_hit", attacker.loc)  // Should hear sound
```

### NPC Recipe Check
```dm
// Verify NPC has recipe menu:
npc.DblClick()
    >> Check for HTML menu with recipe list
    >> Click "Learn" button
    >> Recipe should unlock in player.character.recipes

// Verify persistence:
Logout and log back in
    >> Recipe should still be unlocked
```

### Equipment Overlay Check
```dm
// Visual verification:
Equip armor item
    >> Should see overlay icon on character
    >> Should see `.equipment_slot` displayed

Switch continents
    >> Equipment should transmute (move or change)
    >> Cosmetics should stay in inventory
```

### Experimentation Check
```dm
// Access experimentation menu:
player.OpenExperimentationUI()
    >> See ingredient selection
    >> Click ingredients
    >> Click "Experiment"
    >> Get success/failure message
    
// Verify persistence:
Logout and log back in
    >> Discovered recipes should remain
    >> Experimentation count should be saved
```

---

## 🚨 COMMON PITFALLS & HOW TO AVOID

### Audio Integration
- ❌ Don't: Hardcode sound file paths without checking they exist
- ✅ Do: Create placeholder .ogg files first, wire audio calls, then replace with real sounds

### NPC Recipes
- ❌ Don't: Forget to check player skill level before unlocking
- ✅ Do: Add `if(player.GetRankLevel(RANK_COOKING) >= 3)` check

### Equipment Overlay
- ❌ Don't: Add properties to all items at once (easy to miss some)
- ✅ Do: Add properties to core items first (armor, weapons), then expand

### Experimentation
- ❌ Don't: Forget savefile version bump when adding new variables
- ✅ Do: Check SavefileVersioning.dm, increment version, add migration logic

---

## 📋 COMMIT MESSAGES READY TO USE

### Audio Integration
```
Phase 50: Wire audio to combat and UI systems

- Add PlayCombatSound() calls to attack/damage actions
- Add PlayUISound() calls to menu interactions
- Create snd/ directory structure with placeholder .ogg files
- All audio paths reference audio system library
- Build: 0 errors, 0 warnings
```

### Dead Code Cleanup
```
Cleanup: Remove 500+ lines of commented legacy code

- Remove commented resource generation from lg.dm
- Remove commented overlay code from mining.dm and Light.dm
- Keep minimal examples for reference
- Improves code readability and maintenance
- Build: 0 errors, 0 warnings
```

### NPC Recipe Teaching
```
Phase 51: Complete NPC recipe teaching system

- Build HTML menu interface for NPC dialogue
- Implement recipe unlock on player selection
- Wire recipe unlock event to progression system
- Add flavor text per NPC type
- Full integration with SkillRecipeUnlock.dm
- Build: 0 errors, 0 warnings
```

### Equipment Overlay
```
Phase 52: Complete equipment overlay system

- Define is_cosmetic and equipment_slot properties on all items
- Wire property checks in EquipmentTransmutationSystem
- Add overlay icons for all equipment
- Test visual rendering of worn items
- Build: 0 errors, 0 warnings
```

---

**Last Updated**: December 12, 2025  
**Status**: Ready to implement  
**Difficulty**: ⭐⭐ (intermediate)
