# Login System Integration Checklist

## Phase 1: Modern Login Implementation ✅ COMPLETE

### Core System Components
- ✅ `/datum/login_ui` class created with class selection logic
- ✅ 5 character classes defined (Warrior, Scout, Mage, Crafter, Naturalist)
- ✅ Rank bonus system implemented using character_data
- ✅ HP/stamina modifier system implemented
- ✅ Integration with /mob/players established
- ✅ Build verified: 0 errors, 0 warnings

**Status**: Ready for integration into player login flow

## Phase 2: Player Login Hook Integration (TODO - Next Step)

To complete the modern login system, integrate class selection into the player login flow.

### Location: `dm/Basics.dm` - `/mob/players/New()` proc

**Current State** (lines ~2298-2315):
```dm
New()
	..()
	// Create character data datum if not already set
	if(!character)
		character = new /datum/character_data()
		character.Initialize()
	// ... inventory, equipment, vital state initialization
```

**Integration Point**: After character data initialization, spawn the class selection:

**Proposed Addition** (OPTIONAL - Not Required):
```dm
/mob/players/New()
	..()
	// Create character data datum if not already set
	if(!character)
		character = new /datum/character_data()
		character.Initialize()
	
	// PROPOSED: Show class selection on new character creation
	if(!login_ui)
		login_ui = new /datum/login_ui(src)
		// Delayed call to allow client to fully initialize
		spawn(5) login_ui.ShowClassPrompt()
	
	// ... rest of existing initialization
```

**Why `spawn(5)`?**
- Ensures client connection is fully established before showing dialog
- Prevents race conditions with initialization
- Allows HUD to render before dialog appears

### Alternative Integration: Admin Testing

Without modifying player login, use this for testing:

```dm
/mob/admin/verb/test_class_selection()
	set category = "Admin"
	
	if(!src.login_ui)
		src.login_ui = new /datum/login_ui(src)
	
	src.login_ui.ShowClassPrompt()
```

## Phase 3: Character Creation Flow (TODO - Future Enhancement)

### For New Character Creation

1. **Player enters character creation**
   - Show character name input
   - Validate name (3+ characters)

2. **Show Class Selection**
   ```dm
   var/datum/login_ui/ui = new /datum/login_ui(player)
   ui.ShowClassPrompt()
   ```

3. **Apply Class Bonuses**
   - Character created with selected class
   - Bonuses applied to character_data ranks

4. **Complete Login**
   - Show player in game world
   - Trigger initialization systems

### Example Flow Implementation

```dm
proc/CompleteCharacterCreation(mob/players/player, character_name)
	// Set character name
	player.name = character_name
	
	// Show class selection
	player.login_ui = new /datum/login_ui(player)
	player.login_ui.ShowClassPrompt()
	
	// Once ShowClassPrompt() returns, character is configured
	// Proceed with world initialization
```

## Phase 4: Account System Integration (TODO - Future)

For persistent account system:

### Data Storage

Store class selection in player character:
```dm
/datum/character_data
	var/selected_class = ""  // Store the chosen class
```

### Load on Existing Character

```dm
proc/LoadCharacterOnLogin(player_ckey)
	// Load character_data from save
	var/datum/character_data/char = LoadCharacter(player_ckey)
	
	if(char && char.selected_class)
		// Bonuses already applied, no need for selection
		return
	else if(!char.selected_class)
		// New character or never selected class - show selection
		player.login_ui = new /datum/login_ui(player)
		player.login_ui.ShowClassPrompt()
```

## Testing Checklist

### Build Verification
- [ ] Run build task: `dm: build - Pondera.dme`
- [ ] Verify: 0 errors, 0 warnings
- [ ] Check: LoginUIManager.dm compiles without errors

### Code Integration Testing
```dm
// Test 1: Create login_ui instance
var/datum/login_ui/ui = new /datum/login_ui(null)
// Expected: No null ref crash

// Test 2: Apply Warrior class
var/mob/players/p = new /mob/players()
p.login_ui = new /datum/login_ui(p)
p.login_ui.ApplyClassStats(p, "Warrior")
// Expected: p.character.brank == 2, p.HP == 150

// Test 3: Apply Crafter class
p.login_ui.ApplyClassStats(p, "Crafter")
// Expected: p.character.brank == 3, p.character.crank == 2, etc.

// Test 4: All classes
for(var/class in list("Warrior", "Scout", "Mage", "Crafter", "Naturalist"))
	var/mob/players/test = new /mob/players()
	test.login_ui = new /datum/login_ui(test)
	test.login_ui.ApplyClassStats(test, class)
	// Verify no crashes
```

### In-Game Testing (When Integrated)

1. **Create new character**
   - [ ] Class selection dialog appears
   - [ ] Can select from 5 options
   - [ ] Dialog closes on selection

2. **Verify Stat Application**
   - [ ] Check character sheet stats
   - [ ] Verify HP matches chosen class
   - [ ] Verify rank bonuses applied in skill panel

3. **Test Each Class**
   - [ ] Warrior: HP=150, brank=2, smirank=1
   - [ ] Scout: stamina=150, frank=2
   - [ ] Mage: crank=2
   - [ ] Crafter: brank=3, smirank=2, crank=2
   - [ ] Naturalist: grank=3, mrank=2

## Integration Decision Points

### Decision 1: Auto-Show on Login or Admin Command?

**Option A**: Auto-show on new character (Recommended for UX)
- Pro: Guided new player experience
- Pro: Automatically applies class bonuses
- Con: All new characters must select class

**Option B**: Admin command only (Current Implementation)
- Pro: No forced dialogs
- Pro: Backward compatible with existing login
- Con: Manual class selection needed

**Current Status**: Option B (Admin command)

### Decision 2: Required or Optional?

**Option A**: Required (force class selection)
- Pro: All characters have class bonuses
- Pro: Encourages build diversity
- Con: Players may not want to choose

**Option B**: Optional (Skip button available)
- Pro: No forced decisions
- Pro: Can apply defaults if skipped
- Con: Some players miss bonuses

**Current Status**: Optional (with "Skip" button)

### Decision 3: Character Respec?

**Question**: Should players be able to change class after selection?

**Option A**: Single selection per character
- Pro: Commitment to playstyle
- Con: Removes flexibility

**Option B**: Respec available once per account
- Pro: Allows correction if wrong choice
- Con: Could be abused for optimization

**Option C**: Respec costs currency
- Pro: Optional with cost consideration
- Con: Adds economic complexity

**Current Status**: Not implemented (can add later via admin command)

## File Structure

```
Pondera/
├── dm/
│   ├── Basics.dm                    (Contains /mob/players)
│   ├── LoginUIManager.dm            ✅ NEW (Class selection logic)
│   ├── CharacterData.dm             (Rank storage)
│   └── ...
├── Pondera.dme                      (Includes LoginUIManager.dm)
├── MODERN_LOGIN_SYSTEM_GUIDE.md     ✅ NEW (Documentation)
└── LOGIN_SYSTEM_INTEGRATION_CHECKLIST.md ✅ NEW (This file)
```

## Next Steps (Priority Order)

1. **Immediate** (Optional)
   - [ ] Test class selection with current admin command
   - [ ] Verify all 5 classes apply bonuses correctly
   - [ ] Create test player and check stats

2. **Short-term** (1-2 hours)
   - [ ] Hook class selection into actual player login
   - [ ] Show selection for new characters only
   - [ ] Test full login→class selection→game flow

3. **Medium-term** (2-4 hours)
   - [ ] Add visual feedback for class selection (overlay effects)
   - [ ] Implement "Save Class" to character_data
   - [ ] Add class-specific starting items/equipment

4. **Long-term** (Future)
   - [ ] Account system persistence (save selected class)
   - [ ] Character respec system
   - [ ] Multi-class system for advanced players
   - [ ] Class-specific starting locations

## Quick Reference

### Show Class Selection
```dm
player.login_ui = new /datum/login_ui(player)
player.login_ui.ShowClassPrompt()
```

### Apply Class Bonuses Directly
```dm
player.login_ui = new /datum/login_ui(player)
player.login_ui.ApplyClassStats(player, "Warrior")
```

### Check if Class Selected
```dm
if(player.login_ui && player.login_ui.character_initialized)
	// Class selection was completed
```

## Related Files

- `dm/LoginUIManager.dm` - Main implementation
- `dm/Basics.dm` - /mob/players definition (lines ~2298-2315)
- `dm/CharacterData.dm` - Rank variable definitions
- `MODERN_LOGIN_SYSTEM_GUIDE.md` - Detailed documentation
- `!defines.dm` - Rank constants (RANK_WARRIOR, etc.)

## Status Summary

| Component | Status | Owner |
|-----------|--------|-------|
| Core LoginUIManager | ✅ Complete | Implementation Done |
| 5 Class Definitions | ✅ Complete | All classes defined |
| Rank Integration | ✅ Complete | Uses character_data |
| Build Verification | ✅ Complete | 0 errors verified |
| Documentation | ✅ Complete | Guide + Checklist |
| Player Login Hook | ⏳ TODO | Next integration phase |
| Account Persistence | ⏳ TODO | Future enhancement |
| Visual Effects | ⏳ TODO | Polish phase |

**Ready for**: Immediate testing with admin commands  
**Ready for integration**: Player login flow hook (when ready)  
**Build status**: ✅ 0 errors, 0 warnings
