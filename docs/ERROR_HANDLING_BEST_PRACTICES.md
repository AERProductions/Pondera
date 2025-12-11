# Phase 8: Error Handling & Validation Best Practices

**Status**: Phase 8 Best Practices Guide  
**Purpose**: Standardize error handling across critical systems  
**Audience**: Development team, code reviewers  

---

## Error Handling Patterns Used in Pondera

### Pattern 1: Null/Type Validation (Most Common)

Used for: Function entry validation, player state checks

```dm
// Simple existence check (null check)
/proc/Example1(player)
	if(!player) return 0              // NULL GUARD
	// Safe to use player now

// Type validation + casting (Type Safety)
/proc/Example2(mob/attacker)
	if(!istype(attacker, /mob/players)) return 0  // TYPE GUARD
	var/mob/players/P = attacker      // EXPLICIT CAST
	// Safe to access mob/players-specific variables
	
// Null + property check (State Guard)
/proc/Example3(mob/players/player)
	if(!player || !player.character) return 0     // STATE GUARD
	// Safe to use player.character properties
```

**When to use**: Every function that accepts complex types or uses null-able properties

---

### Pattern 2: Pre-Condition Validation (Guards)

Used for: Preventing invalid operations

```dm
// Resource validation
/proc/ExecuteAction(mob/players/player, amount)
	if(!player || player.stamina < 50) return 0   // GUARD
	// Can proceed with action
	player.stamina -= amount

// State validation
/proc/EnterZone(mob/players/player, zone)
	if(!player.world_initialization_complete) return 0  // GATE
	if(!zone || zone.restricted) return 0               // ZONE CHECK
	// Safe to teleport
```

**When to use**: Before operations that modify state or have prerequisites

---

### Pattern 3: Silent Failure (Logging)

Used for: Non-critical errors that shouldn't crash the system

```dm
// Log but don't throw error
/proc/SavePlayerData(mob/players/player)
	if(!player) 
		world.log << "WARNING: SavePlayerData called with null player"
		return 0
	
	// Attempt save
	var/savefile/F = new("players/[player.ckey].sav")
	if(!F)
		world.log << "ERROR: Failed to create savefile for [player.ckey]"
		return 0
	
	// Save succeeded
	return 1
```

**When to use**: Error recovery is possible or failure is expected in edge cases

---

### Pattern 4: Cascading Validation (Chained Guards)

Used for: Complex prerequisites

```dm
// Multiple conditions in sequence
/proc/ProcessTransaction(mob/players/buyer, obj/stall, list/items)
	if(!buyer) return 0                        // GUARD 1: Player exists
	if(!istype(stall, /obj/market_stall)) 
		return 0                               // GUARD 2: Stall valid
	if(!items || !items.len) return 0          // GUARD 3: Items exist
	if(!buyer.character) return 0              // GUARD 4: Character data exists
	
	var/total_cost = CalculatePrice(items)
	if(buyer.character.lucre < total_cost) 
		return 0                               // GUARD 5: Sufficient funds
	
	// All validations passed - safe to process
	buyer.character.lucre -= total_cost
	return 1
```

**When to use**: Operations with multiple required preconditions

---

### Pattern 5: Initialization Validation (Phase Checks)

Used for: Dependency verification during startup

```dm
// Validate critical systems initialized
proc/FinalizeInitialization()
	var/critical_failures = 0
	
	if(!time_of_day || !(time_of_day in list(1, 2)))
		world.log << "CRITICAL: time_of_day invalid"
		critical_failures++
	
	if(world.maxx < 100)
		world.log << "CRITICAL: World too small"
		critical_failures++
	
	if(critical_failures > 0)
		world.log << "INITIALIZATION FAILED - Server restart required"
		world_initialization_complete = FALSE
	else
		world.log << "Initialization complete - Players can log in"
		world_initialization_complete = TRUE
```

**When to use**: System startup/initialization sequences

---

## Error Handling by System Tier

### Tier 1 & 2: Critical Infrastructure

**Error Strategy**: FAIL FAST + GATE PLAYERS
```dm
// Time system fails → Entire game broken
if(!time_of_day || !(time_of_day in list(1, 2)))
	world_initialization_complete = FALSE     // Block player login
	world.log << "CRITICAL: Time system failed"

// Map generation fails → No terrain
if(world.maxx < 100 || world.maxy < 100)
	world_initialization_complete = FALSE     // Block player login
	world.log << "CRITICAL: Map generation failed"
```

**Result**: No half-broken game states; either works completely or blocks entirely

---

### Tier 3 & 4: Features (Story/Sandbox/PvP)

**Error Strategy**: DEGRADE GRACEFULLY
```dm
// Lighting fails → Still playable without effects
if(!day_night_system_active)
	world.log << "WARNING: Day/night system failed - continuing without effects"
	// Game continues with default lighting

// Story world fails → Use other continents
if(!story_world_loaded)
	world.log << "WARNING: Story world unavailable - players redirected to Sandbox"
	// MultiWorld directs players to Sandbox instead
```

**Result**: Feature-specific failures don't break entire game

---

### Tier 5: Game Systems (Progression, Crafting)

**Error Strategy**: FALLBACK + LOG
```dm
// Recipe system fails → Use hardcoded fallback
if(!RECIPES || RECIPES.len == 0)
	world.log << "WARNING: Recipe registry empty - loading hardcoded recipes"
	InitializeHardcodedRecipes()  // Fallback

// Character data missing → Initialize defaults
if(!player.character)
	world.log << "WARNING: Character data missing for [player.ckey] - initializing"
	player.character = new /datum/character_data()
	player.character.Initialize()
```

**Result**: Players can still progress despite system issues

---

### Tier 6: Economic Systems

**Error Strategy**: LOG + CONTINUE
```dm
// Market pricing fails → Use fallback prices
if(!market_prices || market_prices.len == 0)
	world.log << "WARNING: Market pricing failed - using hardcoded prices"
	item_price = HARDCODED_PRICE[item_name]

// Currency system glitches → Audit trail for recovery
if(balance < 0)
	world.log << "ALERT: Player [player.ckey] has negative balance [balance]"
	LogAuditTrail(player.ckey, "negative_balance", balance)
	player.character.lucre = max(0, balance)  // Clamp to 0
```

**Result**: Economy stays functional; auditable failures for investigation

---

## Validation Functions & Their Uses

### NULL CHECKS (Tier 1: Must always do)

```dm
if(!variable) return 0              // Check if null/uninitialized
if(!istype(obj, /type)) return 0   // Check if correct type
if(!list || !list.len) return 0    // Check if empty list

// Prevents: Null reference crashes, type errors, index errors
// Cost: ~1 CPU instruction each
// Example failures caught: Deleted objects, freed memory, uninitialized variables
```

### STATE CHECKS (Tier 2: Always do for complex state)

```dm
if(!player.character) return 0     // Character not initialized
if(!player.loc) return 0           // Object deleted (no location)
if(player.health <= 0) return 0    // Player dead
if(!world_initialization_complete) return 0  // Game not ready

// Prevents: Cascading corruptions, halfway-initialized objects, state mismatches
// Cost: ~1-5 CPU instructions
// Example failures caught: Missing data structures, stale references, timing issues
```

### RANGE CHECKS (Tier 3: Do for numeric operations)

```dm
if(amount < 0 || amount > max_value) return 0  // Value out of range
if(x < 0 || x > world.maxx) return 0           // Out of bounds
if(level < 1 || level > MAX_LEVEL) return 0    // Invalid level

// Prevents: Numeric overflows, array out-of-bounds, invalid state
// Cost: ~2-4 CPU instructions
// Example failures caught: Negative HP, off-map coordinates, invalid skill levels
```

### DEPENDENCY CHECKS (Tier 4: Do for multi-system operations)

```dm
if(!IsInitComplete("infrastructure")) return 0  // Dep not ready
if(!AreSkillsGloballyShared()) return 0         // Config check
if(!HasDeedPermission(player_ckey, deed)) 
	return 0                                      // Permission denied

// Prevents: Race conditions, missing subsystems, permission violations
// Cost: ~5-20 CPU instructions (list lookups)
// Example failures caught: Initialization race conditions, config mismatches, unauthorized access
```

---

## Where Validation Matters Most

### Critical Path (High Validation Density)

These systems should have validation at EVERY entry point:

1. **Player Login/Logout** (`SavingChars.dm`, `DRCH.dm`)
   - Verify player object valid
   - Check character data initialized
   - Validate world state
   
2. **Currency Transactions** (`DualCurrencySystem.dm`, `MarketTransactionSystem.dm`)
   - Verify payer has sufficient funds
   - Verify receiver account exists
   - Log all transactions
   - Check for balance overflow/underflow
   
3. **Deed Permission Checks** (`DeedPermissionSystem.dm`, `DeedPermissionCache.dm`)
   - Every build, pickup, drop checks permission
   - Cache validation on movement
   - Zone ownership verification
   
4. **Combat/PvP Actions** (`PvPSystem.dm`, `UnifiedAttackSystem.dm`)
   - Verify attacker is valid mob/players (Phase 8 enhancement)
   - Check stamina availability (Phase 8 enhancement)
   - Verify target is attackable
   - Check cooldowns
   
5. **Recipe Discovery** (`ItemInspectionSystem.dm`, `CookingSystem.dm`)
   - Verify item is inspectable
   - Check player skill level
   - Validate recipe exists
   - Prevent duplicate discovery

---

## Phase 8 Enhancement: Type Safety Improvements

### Previous Pattern (Error-Prone)
```dm
/proc/GetAttackPower(mob/attacker)
	var/power = 10
	power += attacker.stamina / 30  // ERROR: undefined var for generic mob
	return power                      // Type mismatch not caught until compile
```

### New Pattern (Type-Safe)
```dm
/proc/GetAttackPower(mob/attacker)
	if(!istype(attacker, /mob/players)) return 0  // TYPE GUARD
	var/mob/players/P = attacker                  // EXPLICIT CAST
	var/power = 10
	power += P.stamina / 30                       // ✓ Valid variable access
	power += global.player_combat_level[P.ckey] * 5  // ✓ Safe global access
	return power
```

**Benefits**:
- Compile-time type checking via explicit casting
- Prevents null dereference errors
- Clear variable access patterns
- Self-documenting code

**Applied in Phase 8**:
- `PvPSystem.dm` CanRaid() function
- `PvPSystem.dm` GetAttackPower() function

---

## Common Anti-Patterns (Avoid These)

### Anti-Pattern 1: Unchecked Access
```dm
// AVOID:
/proc/Bad1(player)
	player.stamina -= 50  // What if player is null? Crashes!

// CORRECT:
/proc/Good1(mob/players/player)
	if(!player) return 0
	player.stamina -= 50
```

### Anti-Pattern 2: Silent Failures (Wrong Direction)
```dm
// AVOID:
/proc/Bad2(player, amount)
	if(player.lucre < amount) 
		return 0  // Player never knows why transaction failed

// CORRECT:
/proc/Good2(mob/players/player, amount)
	if(!player || player.character.lucre < amount)
		player << "Insufficient funds! Need [amount], have [player.character.lucre]"
		return 0
```

### Anti-Pattern 3: Incomplete Initialization
```dm
// AVOID:
mob/players/New()
	..()
	character = new /datum/character_data()
	// What if New() crashes after this point? Character partially initialized!

// CORRECT:
mob/players/New()
	..()
	character = new /datum/character_data()
	character.Initialize()  // Complete initialization atomically
	ValidateCharacterData(src)  // Verify it worked
```

### Anti-Pattern 4: Inconsistent Error Handling
```dm
// AVOID:
/proc/Bad4(player)
	if(!player) return 0
	if(!player.character) return FALSE  // Inconsistent return type!
	if(player.loc) return null          // Even more inconsistent!

// CORRECT:
/proc/Good4(mob/players/player)
	if(!player) return 0
	if(!player.character) return 0      // Always same return type
	if(!player.loc) return 0
	return 1  // Success
```

---

## Error Handling Checklist for Code Review

When reviewing PR/commit with code changes:

- [ ] All function parameters checked for null?
- [ ] All parameter types verified (istype checks)?
- [ ] All list operations check for empty?
- [ ] All numeric operations check ranges?
- [ ] All dependent systems checked for initialization?
- [ ] All error returns consistent type?
- [ ] All critical paths logged appropriately?
- [ ] All fallback/graceful degradation in place?
- [ ] Type casting explicit for complex types?
- [ ] No silent failures (always log or notify)?

---

## Performance Notes on Validation

```
Operation                      Cost      Notes
────────────────────────────────────────────────────
if(!x)                        ~1 CPU     Fastest - just null check
if(!istype(x, /type))         ~5 CPU     Fast - type check
if(!list || !list.len)        ~3 CPU     Fast - double check
if(!(x in list))              ~20 CPU    Slower - linear search
if(x < 0 || x > max)          ~2 CPU     Very fast - numeric compare
World loop: for(var/mob in world)  ~100+ CPU per mob  EXPENSIVE - avoid in hot loops

Guidelines:
- Validation cost acceptable for critical path (login, transactions, combat)
- Avoid `in world` loops in per-tick movement/gameplay code
- Cache validation results when used repeatedly
- Use indexed lookups instead of linear searches when possible
```

---

**Document Version**: 1.0 (Phase 8 Best Practices)  
**Last Updated**: 12/8/25 1:55 pm  
**Repository**: AERProductions/Pondera  
**Branch**: recomment-cleanup
