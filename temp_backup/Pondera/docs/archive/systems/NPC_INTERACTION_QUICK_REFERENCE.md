# NPC Interaction System - Quick Reference

## For Players

### How to Interact with NPCs

1. **Target an NPC**
   - Left-click on any NPC
   - See message: "You have targeted [NPC Name]"

2. **Greet the NPC**
   - Press K (or bind to `npc_greet_verb`)
   - NPC will respond with greeting

3. **Learn Recipes**
   - Press L (or bind to `npc_learn_verb`)
   - See list of recipes NPC can teach
   - Select recipe to learn it

4. **Clear Target**
   - Press Shift+K (or bind to `npc_untarget_verb`)
   - See message: "Target cleared"

### Binding Keys

**In BYOND, use `/bind` command**:
```
/bind K "npc_greet_verb"
/bind L "npc_learn_verb"
/bind Shift+K "npc_untarget_verb"
```

Or use DMF macro system in client configuration.

---

## For Developers

### Core Files
- `dm/NPCTargetingSystem.dm` - Targeting logic
- `dm/NPCInteractionMacroKeys.dm` - Macro key verbs
- `dm/NPCCharacterIntegration.dm` - NPC greeting + recipe teaching

### Key Functions

#### Player Functions
```dm
// Set NPC as target (validates range ≤2 tiles)
player.SetTargetNPC(npc)          → TRUE/FALSE

// Get current valid target
player.GetTargetNPC()             → mob/npcs or null

// Clear target
player.ClearTargetNPC()           → void

// Validate target (call in tick loop)
player.ValidateNPCTarget()        → void
```

#### NPC Functions
```dm
// Greet player
npc.GreetPlayer(player)           → void

// Show recipe teaching interface
npc.ShowRecipeTeachingHUD(player) → void

// Teach specific recipe
npc.TeachRecipeToPlayer(player, recipe_name) → TRUE/FALSE
```

#### Utility Functions
```dm
// Check if object is valid NPC target
IsValidNPCTarget(atom/obj)        → TRUE/FALSE
```

### Adding New NPC Interactions

**Example: NPC Trading**

```dm
// 1. Create verb in /mob/players
/mob/players/verb/npc_trade()
    set name = "NPC Trade"
    set hidden = 1
    
    var/mob/npcs/target = GetTargetNPC()
    if(!target)
        src << "<span class='warning'>No NPC targeted.</span>"
        return
    
    target.TradeWithPlayer(src)

// 2. Create handler in /mob/npcs
/mob/npcs/proc/TradeWithPlayer(mob/players/player)
    // Implement trading logic
    player << "<span class='good'>[src.name]: Let's make a trade!</span>"
    // ...
```

### Variable Reference

| Variable | Type | Location | Purpose |
|----------|------|----------|---------|
| `targeted_npc` | mob/npcs | /mob/players | Current NPC target |
| `targeted_npc_ckey` | text | /mob/players | NPC ckey (for persistence) |
| `character` | datum/character_data | /mob/npcs | NPC's unified character data |
| `npc_type` | text | character_data | NPC type (Traveler, Blacksmith, etc.) |

---

## Architecture Overview

```
Player Click on NPC
    ↓
SetTargetNPC(npc)
    ├─ Check istype(npc, /mob/npcs)
    ├─ Check distance ≤2 tiles
    └─ Store in targeted_npc
    ↓
Player Presses K
    ↓
npc_greet_verb()
    └─ GetTargetNPC()
        ├─ Validate range
        └─ Call GreetPlayer(player)
    ↓
NPC Responds with greeting

---

Player Presses L
    ↓
npc_learn_verb()
    └─ GetTargetNPC()
        ├─ Validate range
        └─ Call ShowRecipeTeachingHUD(player)
    ↓
Player Selects Recipe
    └─ TeachRecipeToPlayer(player, recipe)
    ↓
Recipe Added to Player's Knowledge
```

---

## Error Messages

| Message | Cause | Solution |
|---------|-------|----------|
| "Invalid NPC target" | Clicked non-NPC object | Click on valid NPC |
| "[NPC] is too far away" | Distance >2 tiles | Move closer (within 2 tiles) |
| "No NPC targeted" | Pressed K/L without target | Click NPC first, then press key |
| "out of range" | Moved away from target | Move back within 2 tiles |
| "Target cleared" | Pressed Shift+K | Click on NPC to target again |

---

## Performance Considerations

- **SetTargetNPC()**: O(1) - just stores reference
- **GetTargetNPC()**: O(1) + distance check via get_dist()
- **ValidateNPCTarget()**: O(1) + distance check
- **IsValidNPCTarget()**: O(1) + istype() check

**Overhead**: Negligible - can safely call every tick

---

## Future Enhancements

### Planned (Phase 2+)
- [ ] NPC HUD display with targeting info
- [ ] Visual indicator for targeted NPC
- [ ] Recipe selection HUD (replace input() dialog)
- [ ] Distance/range feedback
- [ ] NPC trading interface
- [ ] NPC quest system
- [ ] NPC reputation tracking

### Possible Improvements
- [ ] NPC dialogue branching
- [ ] Multi-step dialogue sequences
- [ ] Dynamic NPC availability based on time/season
- [ ] NPC skill progression feedback
- [ ] NPC relationship memory
- [ ] Localized language support

---

## Testing Checklist

### Manual Testing
- [ ] Click NPC → targeted
- [ ] Press K → greeting appears
- [ ] Press L → recipe list appears
- [ ] Select recipe → recipe taught
- [ ] Press Shift+K → target cleared
- [ ] Move >2 tiles → "out of range" message
- [ ] Click different NPC → switches target
- [ ] Log out with target → persists/clears appropriately

### Regression Testing
- [ ] All existing NPC procs still work
- [ ] Crash recovery doesn't affect NPCs
- [ ] Zone changes don't crash NPC system
- [ ] NPC despawn handles target cleanup
- [ ] Multiple NPCs don't interfere

---

## Macro Key Bindings (Recommended Defaults)

| Key | Function | Fallback |
|-----|----------|----------|
| K | Greet NPC | /npc_greet_verb |
| L | Learn Recipe | /npc_learn_verb |
| Shift+K | Untarget NPC | /npc_untarget_verb |

---

**Last Updated**: December 11, 2025  
**Status**: Production Ready  
**Build**: Pondera.dmb (0 errors, 5 warnings)
