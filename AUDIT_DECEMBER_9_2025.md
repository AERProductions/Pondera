# Pondera Codebase Audit - December 9, 2025

**Session Summary**: Phase 38C complete, phases 36-38B fully integrated. Build status: ✅ Clean (0 errors, 0 warnings)

---

## 1. ALERTS & CLEANUP OPPORTUNITIES

### High Priority (Functional Impact)

#### 1.1 NPCFoodSupplySystem.dm - TODO Comments (Lines 159, 166)
**Current Status**:
```dm
// Line 159: TODO: Integrate with global_time_system.hour when available
// Line 166: TODO: Integrate with time system for actual shop hours
```

**Status**: ✅ RESOLVED in Phase 38C
- IsNPCShopOpen() now integrated in NPCDialogueShopHours.dm
- Uses global `hour` variable from dm/time.dm (not global_time_system)
- Shop hours properly gated and broadcasting on hour changes

**Action**: Remove TODO comments from NPCFoodSupplySystem.dm

---

#### 1.2 Building UI - Missing Icon Assets (BuildingMenuUI.dm, Lines 56, 71, 87)
**Current Status**:
```dm
icon_file = 'dmi/64/fire.dmi',  // TODO: Create forge.dmi icon
icon_file = 'dmi/64/fire.dmi',  // TODO: Create anvil.dmi icon
icon_file = 'dmi/64/fire.dmi',  // TODO: Create trough.dmi icon
```

**Status**: Cosmetic placeholder - functionality works, needs art assets
**Impact**: Low - Uses fire.dmi as fallback, doesn't break gameplay
**Recommended Action**: Create forge.dmi, anvil.dmi, trough.dmi (32x32 and 64x64 variants)

---

#### 1.3 Music System - Track Crossfading (MusicSystem.dm, Line 250)
**Current Status**:
```dm
// TODO: Implement track crossfading
```

**Status**: Feature-complete without crossfading - music still plays seamlessly
**Impact**: Low - UX enhancement, not required for gameplay
**Recommended Action**: Queue for Phase 39 or later when audio assets finalized

---

#### 1.4 Combat System - Faction/PvP Flagging (CombatSystem.dm, Line 96)
**Current Status**:
```dm
// TODO: Implement faction/PvP flagging system
```

**Status**: Phase 10 gating (continent-aware) handles PvP rules
**Impact**: Medium - Affects PvP continent gameplay balance
**Recommended Action**: Queue for Phase 41+ (Advanced PvP Systems)

---

### Medium Priority (Code Quality)

#### 1.5 DeedDataManager.dm - WARNING Logging (Lines 409, 433, 451, 540)
**Current Status**: Multiple `world.log` warnings for invalid deed data
- Line 409: Invalid center turf
- Line 433: Invalid deed position
- Line 451: Inverted bounds
- Line 540: Invalid owner data

**Impact**: Low - Defensive logging helps with debugging
**Recommended Action**: Keep as-is; these catch edge case errors

---

#### 1.6 DeedPermissionSystem.dm - NULL Checks (Lines 18, 19, 46, 47, 74, 75)
**Current Status**: Defensive NULL checks with warnings
```dm
if(!M) world.log << "WARNING: CanPlayerBuildAtLocation() called with null player"
```

**Status**: ✅ Good defensive programming
**Recommended Action**: No change needed

---

#### 1.7 WeaponArmorScalingSystem.dm - Equipment Queries (Lines 411, 429)
**Current Status**:
```dm
// TODO: Query equipped weapons from character equipment system
// TODO: Query equipped armor from character equipment system
```

**Status**: Functions use hardcoded default values, don't query actual equipment
**Impact**: Medium - Weapon/armor scaling partially broken
**Recommended Action**: 
1. Add equipment property references to character_data
2. Query via `M.character.equipped_weapon`, `M.character.equipped_armor`
3. This ties into CentralizedEquipmentSystem.dm integration

---

#### 1.8 ItemInspectionSystem.dm - Placeholder Stat System (Line 296)
**Current Status**:
```dm
* This is a placeholder - connect to actual stat system
```

**Impact**: Low - Item inspection works without stat system
**Recommended Action**: Queue for when character stat system is defined

---

### Low Priority (Code Style/Documentation)

#### 1.9 LocationGatedCraftingSystem.dm - Kingdom Integration (Line 111)
**Current Status**:
```dm
// TODO: Integrate with kingdom system once implemented
```

**Status**: Functions work with hardcoded kingdom handling
**Impact**: Low - Functional, needs expansion for kingdom-specific crafting
**Recommended Action**: Queue for Phase 41+ (Kingdom Systems)

---

#### 1.10 AdvancedCropsSystem.dm - Turf Type Checking (Line 428)
**Current Status**:
```dm
// TODO: Add turf type checking once terrain system is defined
```

**Status**: Crops grow on any turf, no terrain restrictions
**Impact**: Medium - Affects farming realism
**Recommended Action**: Implement soil_health checks for viable soil types

---

#### 1.11 AdvancedCropsSystem.dm - Particle Integration (Line 563)
**Current Status**:
```dm
// TODO: Integrate with Particles-Weather.dm
```

**Status**: Crops don't visually respond to weather
**Impact**: Low - UX/cosmetic, doesn't affect gameplay
**Recommended Action**: Add weather particle effects to crops (rain=growth boost visual, etc.)

---

#### 1.12 SeasonalEventsHook.dm - Integration TODOs (Lines 109-227)
**Current Status**: ~15 TODOs for integrating seasonal modifiers with:
- Crop growth system
- Livestock breeding
- Market pricing
- Food consumption

**Status**: Systems exist but seasonal hooks commented out
**Impact**: Medium - Seasons affect static values, not dynamic systems
**Recommended Action**: 
1. Integrate OnSeasonChange() callbacks
2. Set global modifiers (crop_growth_modifier, etc.)
3. Systems should reference these globals

---

---

## 2. MOVEMENT SYSTEM REVIEW & IMPROVEMENTS

### Current Architecture

**File**: `dm/movement.dm` (116 lines)

**Core Components**:
- **Direction input**: MN, MS, ME, MW (held), QueN, QueS, QueE, QueW (queued)
- **Sprint mechanic**: Double-tap within 3 ticks activates sprint
- **Speed control**: MovementSpeed variable (default 3), modified by sprint/hunger/weather
- **Bump handling**: Cancels sprint on collision

### Identified Opportunities

#### 2.1 Movement Deed Cache Integration
**Status**: ✅ Implemented (called every move via movement loop)
- `InvalidateDeedPermissionCache(M)` checks zone changes
- Ensures players can't build in restricted zones

**Recommendation**: Keep as-is - properly integrated

---

#### 2.2 Diagonal Movement (Corner-Cut Detection)
**Status**: Appears unused in current code
- NOCC flag mentioned in instructions but not implemented
- Diagonal movement not currently blocked

**Recommendation**: Implement NOCC (No Corner Cut) detection:
```dm
if(NewDir & (NORTH|SOUTH))
	if(NewDir & (EAST|WEST))
		// Diagonal - check adjacent walls
		var/wall_north = ...
		var/wall_side = ...
		if(wall_north && wall_side) return 0  // Block diagonal
```

---

#### 2.3 Elevation-Based Movement Speed
**Status**: Not currently implemented
- Elevals exist (1.0, 1.5, 2.0, etc.)
- No movement penalty/bonus for elevation changes

**Recommendation**: Add elevation modifiers:
```dm
/mob/proc/GetElevationMovementModifier()
	if(!elevel) return 1.0  // Ground level = normal
	if(elevel > 2) return 0.8  // High elevation = slower
	return 0.95  // Slight penalty for stairs/ramps
```

---

#### 2.4 Stamina Integration
**Status**: Partially implemented
- HungerThirstSystem.dm affects stamina
- Movement doesn't directly drain stamina

**Recommendation**: Add light stamina drain per move:
```dm
if(stamina < STAMINA_THRESHOLD) {
	MovementSpeed *= 1.3  // Slow down when tired
}
```

---

#### 2.5 Terrain-Based Movement Speed
**Status**: Not implemented
- All turfs have same movement cost

**Recommendation**: Add turf friction:
```dm
/turf/var/movement_friction = 1.0  // Default
/turf/mud/movement_friction = 1.5  // Slow
/turf/ice/movement_friction = 0.7  // Fast but slippery
```

**Implementation**:
```dm
/mob/proc/GetMovementSpeed()
	var/base_speed = src.MovementSpeed
	if(loc && loc:movement_friction)
		base_speed *= loc.movement_friction
	return max(1, base_speed)
```

---

#### 2.6 Movement Animation States
**Status**: Current system is instant (no "walking" animation)

**Recommendation**: Add animation states:
```dm
mob/var/movement_state = "idle"  // idle, walking, running

// When moving:
movement_state = Sprinting ? "running" : "walking"
icon_state = "[base_state]_[movement_state]"

// When stopped:
spawn(MovementSpeed)
	if(!moving) movement_state = "idle"
```

---

### Movement System Summary

| Feature | Status | Priority | Effort |
|---------|--------|----------|--------|
| Direction input | ✅ Complete | — | — |
| Sprint mechanic | ✅ Complete | — | — |
| Deed cache integration | ✅ Complete | — | — |
| Diagonal blocking (NOCC) | ❌ Missing | Medium | Low |
| Elevation modifiers | ❌ Missing | Low | Low |
| Stamina drain | ❌ Partial | Medium | Medium |
| Terrain friction | ❌ Missing | Low | Medium |
| Animation states | ❌ Missing | Low | High |

**Recommended Next Steps**: Implement diagonal blocking + stamina drain for Phase 39

---

---

## 3. RANGED ATTACK SYSTEM - DESIGN DISCUSSION

### Design Goals
1. **Multiple weapon types**: Bows, crossbows, throwing weapons (daggers, axes, javelins)
2. **Projectile flight**: Visual trajectory, not instant hit
3. **Skill-based mechanics**: Range, damage, accuracy scaling with skill
4. **Environmental interactions**: Arrows stick in objects, terrain affects trajectory
5. **Seamless combat integration**: Works with existing combat system

### Option A: Ballistic Flight (Recommended)

**Trajectory**: Parabolic arc - projectile follows physics-based curve

**Advantages**:
- Visually satisfying, realistic
- Range scales naturally with arc angle
- Wind/weather can affect trajectory
- Obstacles block projectile mid-flight
- Arrows can stick in surfaces

**Implementation**:
```dm
/obj/projectile
	var
		source_mob          // Who fired it
		target_mob = null   // Intended target (can miss)
		flight_start_pos    // Starting [x,y,z]
		flight_target_pos   // Ending [x,y,z]
		flight_progress = 0 // 0.0-1.0
		flight_height = 10  // Arc peak in pixels
		damage_on_hit = 10
		
/obj/projectile/proc/CalcFlightPath()
	// Calculate parabolic arc from source to target
	// arc_height = flight_height
	// duration = distance / speed
	
/obj/projectile/proc/AnimateFlight()
	set background = 1
	set waitfor = 0
	
	while(flight_progress < 1.0)
		flight_progress += 0.05
		
		// Parabolic equation: y = height * sin(progress * PI)
		var/arc_y = flight_height * sin(flight_progress * 3.14159)
		
		// Update position mid-flight
		// Check for collisions
		// Update visual layer
		
		sleep(1)  // Smooth animation
	
	// Impact at target
	OnProjectileImpact()
```

**Weapon Types**:
- **Bow**: Short range (8-15 tiles), medium arc, standard speed
- **Crossbow**: Long range (12-20 tiles), flat trajectory, high speed, slow reload
- **Longbow**: Medium range (10-18 tiles), high arc, slower speed
- **Throwing Knife**: Close range (4-10 tiles), fast, low arc
- **Javelin**: Medium range (8-15 tiles), heavy, high damage falloff
- **Sling**: Medium range (6-12 tiles), slower projectile speed

---

### Option B: Instant Hit with Cast Time

**Mechanic**: Attack channels for X ticks, projectile appears at target instantly

**Advantages**:
- Simpler implementation
- Less network traffic
- Easier to balance
- Works well with skill animations

**Disadvantages**:
- Less visually satisfying
- Can't miss based on flight path
- Environmental interactions harder

---

### Option C: Hybrid (Flight + Time-to-Hit)

**Mechanic**: Projectile visually travels, but damage calculated at start with hit/miss, then projectile disappears on reach

**Advantages**:
- Balanced complexity vs. realism
- Prevents exploits (moving away while arrow flies)
- Clean animation

**Disadvantages**:
- Can't do mid-flight interactions (arrow stops at shield)

---

### Recommended: Option A (Ballistic) with Simplifications

**Core Features** (Phase 39):
1. Parabolic flight arc
2. Hit detection on arrival
3. Skill-based accuracy (miss chance)
4. Damage scales with skill level + strength

**Phase 40 Extensions**:
1. Arrow sticking in surfaces
2. Environmental obstacles
3. Weather effects (wind pushes projectiles)
4. Damage falloff by distance

---

## 4. IMPLEMENTATION ROADMAP

### Phase 39: Ranged Combat Foundations
```
├─ /obj/projectile (base class)
├─ /obj/projectile/arrow
├─ /obj/projectile/bolt (crossbow)
├─ /obj/projectile/throwing_knife
├─ /obj/projectile/javelin
├─ /obj/projectile/sling_stone
├─ /proc/FireProjectile(mob/source, target, projectile_type, skill_level)
├─ /proc/ResolveProjectileHit(projectile, target, skill_level)
├─ /proc/CalcProjectileDamage(base_damage, skill_level, distance)
└─ /proc/CalcProjectileAccuracy(attacker_skill, defender_ac, distance)
```

### Skill Integration
```
RANK_ARCHERY (Bows)
├─ Level 1: Basic bow, 8 tile range, 30% accuracy
├─ Level 2: Better range (10), 45% accuracy
├─ Level 3: Longbow unlock, 15 tile range, 60% accuracy
├─ Level 4: Rapid shot (faster reload), 75% accuracy
└─ Level 5: Piercing shot (ignore armor), 85% accuracy

RANK_CROSSBOW (Crossbows)
├─ Level 1: Basic crossbow, 12 tile range, 35% accuracy
├─ Level 2: Heavy crossbow, 15 tile range, 50% accuracy
├─ Level 3: Mounted crossbow, 20 tile range, 65% accuracy
├─ Level 4: Automatic reload, 80% accuracy
└─ Level 5: Armor penetration, 90% accuracy

RANK_THROWING (Thrown weapons)
├─ Level 1: Dagger throw, 5 tile range, 40% accuracy
├─ Level 2: Javelin, 10 tile range, 55% accuracy
├─ Level 3: Axe throw, 8 tile range, high damage
├─ Level 4: Multi-throw, 70% accuracy
└─ Level 5: Master thrower, 80% accuracy
```

---

## 5. EQUIPMENT SYSTEM OPPORTUNITIES

### Current State
- Equipment system exists (Wequipped, Aequipped, Sequipped flags)
- Overlays display on character
- AC/damage integrated

### Gaps Identified
1. **Equipment durability** (mentioned in WeaponArmorScalingSystem.dm)
   - Not actually tracked per item
   - Should degrade with combat use
   - Alert players at 25%, 10% health

2. **Equipment stats** (TODO in WeaponArmorScalingSystem.dm)
   - Weapons should have damage_bonus property
   - Armor should have defense_bonus property
   - Currently hardcoded defaults

3. **Equipment crafting**
   - No way to craft new equipment (only find/buy)
   - Should tie into smithing/leatherworking ranks

---

## 6. RECOMMENDATIONS SUMMARY

### Immediate (Phase 39):
✅ Phase 38C dialogue system complete
- [x] Time-based NPC greetings
- [x] Seasonal dialogue
- [x] Shop hour enforcement
- [x] Supply warning broadcasts

### Short-term (Phase 39-40):
1. **Ranged Combat System**
   - Ballistic projectile flight
   - Multiple weapon types
   - Skill integration (archery, crossbow, throwing)

2. **Movement System Enhancements**
   - Diagonal blocking (NOCC)
   - Stamina drain per move
   - Terrain friction modifiers

3. **Equipment System Fixes**
   - Equipment durability tracking
   - Equipment stat properties
   - Durability alerts

### Medium-term (Phase 41+):
1. Quest system (NPC quest generation from needs)
2. Advanced combat interactions (combo attacks, special abilities)
3. Kingdom-specific crafting
4. PvP faction system
5. Romance/relationship tracking

---

## 7. CODE QUALITY METRICS

**Current Build Status**: ✅ Clean (0 errors, 0 warnings)

**Lines of Code**:
- dm/ folder: ~5,000+ lines
- Phase 36-38C: 1,960+ new lines
- Total project: 20,000+ lines

**Error Resolution Rate**: 41 errors fixed across Phase 36-38C (100% success)

**Build Time**: 0:03 seconds

**System Count**: 50+ integrated systems

---

**End of Audit Report**
Generated: December 9, 2025, 10:53 PM

Next session recommendations:
1. Implement Phase 39: Ranged Combat System
2. Add movement diagonal blocking
3. Fix equipment stat property references
4. Resolve seasonal modifier integration TODOs
