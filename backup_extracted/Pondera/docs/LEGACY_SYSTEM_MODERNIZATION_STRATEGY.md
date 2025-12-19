# 🔄 LEGACY SYSTEM MODERNIZATION STRATEGY

**Date**: December 11, 2025  
**Scope**: Refactor + Unify Legacy Interactions  
**Goal**: Replace Click-based dialogues with HUD/Macro command system

---

## 📋 MODERNIZATION OVERVIEW

### Current Problem
- **NPC Interaction**: 14+ NPCs using `Click()` → `input()` dialogs
- **Scattered Systems**: Building, crafting, sharpening each with their own UI patterns
- **Legacy Patterns**: Right-click menus, inline input dialogs
- **HUD Underutilized**: New HUD system exists but not integrated with NPCs/interactions

### Vision
Replace ALL legacy click-based dialogue with unified **HUD command system**:
```
User clicks NPC → HUD shows available interactions → User selects via commands
```

**Benefits**:
- Consistent UX across all systems
- Keyboard/macro accessible (not just click-based)
- Scalable (easy to add new interactions)
- Mobile-friendly (no input dialogs)
- Better accessibility

---

## 🎯 PRIORITY REFACTORING ROADMAP

### Phase A: NPC Interaction Modernization (3-4 hours) **HIGH IMPACT**

**Problem**: 14+ NPCs with Click() → input() dialogs  
**Solution**: Unified HUD-based NPC interaction system

**Components**:
1. Create `NPCInteractionHUD.dm` - Standardized NPC interaction UI
2. Create `/datum/npc_dialogue_option` - Dialogue option data structure
3. Modify all NPCs to use new system instead of Click()
4. Add macro commands for dialogue selection

**Before**:
```dm
Click()
    set src in oview(1)
    var/K = input("Hello!", "Greeting") in list("Option1", "Option2")
    switch(K)
        if("Option1") alert("Response1")
```

**After**:
```dm
proc/ShowInteractionMenu(mob/players/M)
    // Shows HUD with interaction options
    var/datum/NPC_Interaction/menu = new(src, M)
    menu.Show()

// User selects via macro command: /npc_respond option_id
// Much cleaner, no input dialogs, HUD-driven
```

**Estimated Time**: 3-4 hours  
**Impact**: Massive (affects 14+ NPCs, improves UX significantly)  
**Difficulty**: Medium (refactoring, not new logic)

---

### Phase B: Building System Refactor (2-3 hours) **HIGH IMPACT**

**Problem**: 4,600-line monolithic file with 50+ near-identical building blocks  
**Solution**: Data-driven building template system

**Current**:
```dm
if("Table") switch(input(...))
    if("North")
        var/obj/items/Crafting/Created/UeikBoard/J = locate()
        var/obj/items/Crafting/Created/IronNails/J1 = locate()
        // [30 lines of identical logic]

if("Bed") switch(input(...))
    if("North")
        var/obj/items/Crafting/Created/UeikBoard/J = locate()
        var/obj/items/Crafting/Created/IronNails/J1 = locate()
        // [30 lines of identical logic repeated]
```

**After Refactor**:
```dm
datum/building_template
    var/name = "Table"
    var/materials = list(/obj/items/Crafting/Created/UeikBoard = 2, /obj/items/Crafting/Created/IronNails = 4)
    var/stamina_cost = 50
    var/directions = list(NORTH, SOUTH, EAST, WEST)

proc/PerformBuild(player, template)
    if(!CanBuild(player, template)) return
    CheckMaterials(player, template.materials)
    SpawnBuilding(player.loc, template)
```

**Savings**: 4,600 lines → 500 lines + 200-line building definitions  
**Estimated Time**: 2-3 hours  
**Impact**: Massive code cleanup, enables new buildings easily  
**Difficulty**: Medium (pattern extraction)

---

### Phase C: Sharpening System Refactor (1 hour) **MEDIUM IMPACT**

**Problem**: 100+ lines of weapon-type duplication (J8, J9, J10...J26)  
**Solution**: Unified weapon sharpening proc

**Current**:
```dm
if(J1)
    if(prob(50)) M<<"Sharpened!"
    else M<<"Failed!"
else if(J2)
    if(prob(50)) M<<"Sharpened!"
    else M<<"Failed!"
// ... repeat 24 times
```

**After**:
```dm
proc/SharpenWeapon(weapon)
    if(prob(50))
        weapon.needssharpening = 0
        return "Sharpened successfully!"
    return "Sharpening failed - needs more work"
```

**Savings**: 100 lines → 10 lines  
**Estimated Time**: 1 hour  
**Impact**: Code maintainability, enables new weapons easily  
**Difficulty**: Low (simple refactoring)

---

### Phase D: Crafting System Unification (2 hours) **MEDIUM IMPACT**

**Problem**: Scattered crafting mechanics (cooking, blacksmithing, carpentry each separate)  
**Solution**: Unified crafting interface with HUD integration

**Components**:
1. Centralize all crafting rules
2. Create `/datum/crafting_interface` for HUD display
3. Unified progress bars, quality system
4. Macro-based interaction

**Estimated Time**: 2 hours  
**Impact**: Better UX, easier to add new crafts  
**Difficulty**: Medium (integration task)

---

### Phase E: Error Handling Audit (45 minutes) **FOUNDATION**

**Problem**: 12+ locations without null checks or error handling  
**Solution**: Add defensive checks throughout

**Locations to audit**:
- dm/mining.dm (ingot spawning)
- dm/WC.dm (woodcutting)
- dm/QFEP.dm (sharpening)
- dm/movement.dm (speed calculations)

**Estimated Time**: 45 minutes  
**Impact**: Crash prevention, stability  
**Difficulty**: Low (mechanical fixes)

---

### Phase F: Code Style Standardization (2 hours) **POLISH**

**Problem**: Inconsistent naming (someVar vs some_var, mixed comment styles)  
**Solution**: Standardize to BYOND conventions

**Standardization**:
- Variable names: snake_case (BYOND convention)
- Comment format: `// Single-line` or `/* Multi-line */`
- Type declarations: Always specify types explicitly
- Proc signatures: Consistent formatting

**Estimated Time**: 2 hours  
**Impact**: Code consistency, readability  
**Difficulty**: Low (mechanical replacement)

---

### Phase G: Global Variable Consolidation (1 hour) **POLISH**

**Problem**: Global vars scattered across files (Busy, offset, etc.)  
**Solution**: Centralized `/datum/global_state` object

**Estimated Time**: 1 hour  
**Impact**: Namespace management, debugging  
**Difficulty**: Low (refactoring)

---

## 🚀 RECOMMENDED EXECUTION ORDER

**Day 1 (Today): Foundation + High Impact**
1. ✅ Critical Fixes (COMPLETE)
2. Error Handling Audit (45 min)
3. NPC Interaction Modernization (3-4 hours)
4. Building System Refactor (2-3 hours)

**Day 2: Medium Impact + Polish**
5. Sharpening System Refactor (1 hour)
6. Crafting System Unification (2 hours)
7. Code Style Standardization (2 hours)
8. Global Variable Consolidation (1 hour)

**Total**: ~13-15 hours for comprehensive modernization

---

## 💡 NPC INTERACTION MODERNIZATION - DETAILED DESIGN

This is the most impactful change. Here's the full design:

### Current System (Legacy)
```
User clicks NPC
→ Dialog box appears (input() function)
→ User selects from list
→ Response alert() box shown
→ Done
```

**Problems**:
- Requires clicking NPC twice (in range + click)
- Input dialog blocks other UI
- Unmappable to keyboard
- Not accessible on mobile
- Can't display rich formatting

### New System (Modernized)
```
User clicks NPC
→ HUD panel shows available interactions
→ User presses macro key (e.g., /npc_talk 1, /npc_learn 2)
→ Interaction occurs
→ HUD updates with response
→ User can continue interaction or close HUD
```

**Benefits**:
- Single interaction pattern across all NPCs
- Keyboard accessible via macros
- Richer UI using HUD system
- Scalable (easy to add new interaction types)
- Non-blocking (can do other things while HUD open)

### Implementation

**File**: `dm/NPCInteractionHUD.dm`

```dm
/datum/NPC_Interaction
    var/npc
    var/player
    var/options = list()  // List of /datum/npc_interaction_option
    
    New(npc, player)
        src.npc = npc
        src.player = player
        InitializeOptions()
    
    proc/InitializeOptions()
        // Each NPC defines its own interaction options
        // e.g., {"Talk": "talk_response", "Learn": "learn_recipe"}
        options = npc.GetInteractionOptions()
    
    proc/Show()
        // Display HUD with options
        player.hud_npc_interaction = src
        UpdateHUD()
    
    proc/SelectOption(option_id)
        var/datum/npc_interaction_option/opt = options[option_id]
        if(!opt) return
        
        // Execute interaction
        opt.Execute(player, npc)
        
        // Update HUD or close
        if(opt.stay_open)
            UpdateHUD()
        else
            Close()
    
    proc/Close()
        player.hud_npc_interaction = null
        player.UpdateHUD()

/datum/npc_interaction_option
    var/title = ""  // "Talk", "Learn", "Trade"
    var/action = ""  // Internal action ID
    var/stay_open = 1  // Keep HUD open after interaction
    var/response = ""  // What to show after interaction
    
    proc/Execute(mob/players/player, mob/npc)
        // Executed when player selects this option
        // Handled by NPC-specific code
```

**NPC Definition** (Simplified Example):

```dm
/mob/npc/Adventurer
    proc/GetInteractionOptions()
        return list(
            new /datum/npc_interaction_option("Talk", "talk"),
            new /datum/npc_interaction_option("Learn Recipe", "learn")
        )
    
    proc/Interact_talk(mob/players/M)
        M.hud_npc_interaction.response = "I've been far and wide..."
        // Or show multi-choice dialogue
    
    proc/Interact_learn(mob/players/M)
        TravelerRecipeDialogUnified(M, src)

Click()
    set hidden = 1
    set src in oview(1)
    if(!(src in range(1, usr)))
        usr << "You're too far away!"
        return
    
    // NEW: Show interaction HUD
    var/datum/NPC_Interaction/menu = new(src, usr)
    menu.Show()
```

**Macro Commands** (In HUD or Player procs):

```dm
// /npc_respond <option_number>
// e.g., /npc_respond 1 = Select first option

mob/players/verb/npc_respond(num as num)
    set hidden = 1
    if(!hud_npc_interaction) return
    hud_npc_interaction.SelectOption(num)
```

---

## 📊 EXPECTED OUTCOMES

### Code Quality Improvements
- **Lines Removed**: 5,000+ (dead code, duplication)
- **Lines Added**: 1,000 (new systems, documentation)
- **Net**: -4,000 lines (20% code reduction)

### Maintainability Improvements
- **Building System**: 30 min → 5 min to add new building
- **New Weapons**: 10 min → 1 min to add sharpening support
- **New NPCs**: 30 min → 10 min (with standardized dialogue)
- **Bug Fix Time**: 50% reduction (less duplicate code)

### Feature Improvements
- **NPC Interaction**: Now keyboard-accessible
- **Building**: Data-driven (easier to design)
- **Crafting**: Unified interface (better UX)
- **Accessibility**: Better for all user types

---

## ⚠️ RISK MITIGATION

**Risk**: Breaking existing NPC functionality
**Mitigation**: Comprehensive backup before changes, test each NPC type

**Risk**: Performance issues with new HUD system
**Mitigation**: HUD already built, just adding integration

**Risk**: Player confusion with new system
**Mitigation**: Clear macro documentation, HUD is intuitive

---

## ✅ SUCCESS CRITERIA

- [ ] All 14+ NPCs using HUD-based interaction
- [ ] Building system 4,600 → 500 lines
- [ ] Sharpening system 100 → 10 lines
- [ ] All systems have error handling
- [ ] Code style standardized
- [ ] Build: 0 errors, <4 warnings
- [ ] No functionality lost (all features preserved)
- [ ] Performance maintained or improved

---

## 📅 TIMELINE

**Immediate** (Next 4-6 hours):
1. Error handling audit (45 min)
2. NPC interaction modernization (3-4 hours)
3. Building system refactor (2-3 hours)

**Tomorrow** (4-6 hours):
4. Sharpening system refactor (1 hour)
5. Crafting system unification (2 hours)
6. Code style standardization (2 hours)
7. Global variable consolidation (1 hour)

**Total Modernization**: ~13-15 hours for complete legacy system overhaul

---

## 🎯 NEXT ACTION

Shall I proceed with:
1. **Error Handling Audit** (45 min) - Foundation for safety
2. **NPC Interaction Modernization** (3-4 hours) - Biggest UX improvement
3. **Building System Refactor** (2-3 hours) - Massive code cleanup

Or would you like to start with a different phase?

**Ready to transform the codebase!** ✨
