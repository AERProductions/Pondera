# Ranged Attack System - Flight Mechanics Design Guide

## Overview

This document compares three flight style approaches for ranged weapons in Pondera and provides architectural recommendations for implementation.

---

## Flight Style Comparison

### Style 1: Ballistic Arc (Parabolic Flight)

**Description**: Projectile follows a realistic parabolic path from attacker to target. Visual path traces an arc with apex in middle, then descends to target.

**Visual Effect**:
```
                    *  ← Peak (arc_height)
                   * *
                  *   *
                 *     *
               Archer  * Target
```

**Math**:
```
Arc height varies by projectile type:
- Arrow: 6-10 pixels (low arc)
- Javelin: 8-15 pixels (medium arc)
- Sling: 10-20 pixels (high arc)

x(t) = start_x + (end_x - start_x) * t
y(t) = start_y + (end_y - start_y) * t

z(t) = arc_height * sin(t * PI)  ← Vertical "bounce"
```

**Advantages**:
✅ Visually satisfying and realistic
✅ Can see projectile arc and adjust aim
✅ Wind/weather naturally affects trajectory
✅ Obstacles can block mid-flight
✅ Arrow can stick in surfaces
✅ High skill ceiling (players learn to predict arc)
✅ Different weapon types have distinct feels

**Disadvantages**:
❌ More complex implementation (extra loop for animation)
❌ Network traffic (position updates per tick)
❌ CPU overhead (smooth animation requires many frames)
❌ Harder to balance (long-range shots look "faster" than short-range)

**Use Cases**:
- PvP combat (skill-based aiming)
- Environmental storytelling ("see the arrow arc over the hill")
- Archery mini-games

**Flight Time Examples** (assuming 2 tiles/second):
- 4 tile throw: ~2 seconds
- 8 tile bow: ~4 seconds
- 15 tile crossbow: ~7.5 seconds

---

### Style 2: Instant Hit with Cast Time

**Description**: Attacker channels for X ticks (cast time), then projectile instantly appears at target and damage resolves.

**Visual Effect**:
```
Attacker channels... ⏳ (1-3 seconds)
TWANG! → ✓ Hit Target instantly
```

**Implementation**:
```dm
mob/proc/RangedAttack(target, weapon_type)
	var/cast_time = weapon_type:cast_time  // 10-30 ticks
	src << "Drawing [weapon_type]..."
	
	for(var/i = 0 to cast_time)
		sleep(1)
		if(src.Moving || target.Moving)  // Cancel if interrupted
			src << "Attack cancelled."
			return
	
	// Instant resolution
	var/hit = ResolveRangedHit(src, target, weapon_type)
	if(hit) target.TakeDamage(...)
```

**Advantages**:
✅ Simple implementation
✅ Low network traffic (just damage packet)
✅ Easy to balance (linear range = linear damage)
✅ Works with existing combat system without changes
✅ Can't be dodged by moving away
✅ Low CPU overhead

**Disadvantages**:
❌ Doesn't feel like projectiles are flying
❌ Can't create "near miss" stories
❌ No environmental interaction (arrows vanish)
❌ Feels like instant teleport damage
❌ Less skill expression (just aim/wait)
❌ Hard to implement spell-like special effects

**Use Cases**:
- Fast-paced combat where players don't think about flight time
- Mobile/console ports (less server load)
- Casual gameplay

**Balance Notes**:
- Short range: 5-10 ticks cast time, high accuracy
- Medium range: 10-15 ticks cast time, medium accuracy
- Long range: 15-25 ticks cast time, low accuracy

---

### Style 3: Hybrid (Visual Flight + Instant Damage)

**Description**: Projectile visually travels from attacker to target over X ticks. Damage calculated at START of flight (not arrival). Projectile disappears when reaching target.

**Visual Effect**:
```
Attacker fires → Arrow travels... → Hits instantly when reaching target
(damage was calculated at fire, so outcome known)
```

**Implementation**:
```dm
mob/proc/RangedAttack(target, weapon_type)
	// Calculate hit/miss NOW
	var/will_hit = ResolveRangedAccuracy(src, target, weapon_type)
	var/damage = will_hit ? CalcRangedDamage(...) : 0
	
	// Create projectile
	var/obj/projectile/P = new(src.loc)
	P.target_mob = target
	P.damage = damage
	P.flight_time = CalculateFlightTime(src, target)
	
	// Animate flight
	spawn() P.AnimateFlight()

/obj/projectile/proc/AnimateFlight()
	var/start_time = world.time
	
	while(world.time < start_time + flight_time)
		// Update position toward target
		// Check visibility along path
		sleep(1)
	
	// Damage was pre-determined, apply it now
	if(damage > 0)
		target_mob.TakeDamage(damage)
	
	del(src)
```

**Advantages**:
✅ Visually engaging (see projectile travel)
✅ Simple damage calculation (one-time, at fire)
✅ Can't dodge by moving away (damage set when fired)
✅ Prevents "rocket tag" exploits
✅ Medium implementation complexity
✅ Works with skill/accuracy system

**Disadvantages**:
❌ Outcome seems predetermined (less dramatic)
❌ Can't do mid-flight interactions (arrow stops at shield)
❌ Projectiles can't "miss visibly" (damage 0 but arrows still arrive)
❌ Wind/weather can't realistically affect trajectory
❌ Stuck arrows look weird (arrow arrived but didn't "exist" mid-flight)

**Use Cases**:
- PvP combat (prevents exploit dodging)
- Skill-based but not prediction-based
- Games where "hitscan" feels too instant

**Flight Time Calculation**:
```dm
flight_time = distance / speed
// Bows: 15 tiles / 5 tiles-per-sec = 3 seconds (30 ticks)
// Crossbow: 20 tiles / 8 tiles-per-sec = 2.5 seconds (25 ticks)
// Throwing: 8 tiles / 4 tiles-per-sec = 2 seconds (20 ticks)
```

---

## Recommendation for Pondera

### **Best Choice: Ballistic Arc (Style 1)**

**Rationale**:
1. **Matches world design**: Pondera has elevation system, weather, seasons
   - Wind could push arrows (weather integration)
   - Arrows could stick in trees/terrain (immersion)
   - Elevation affects arc angle (↑ higher = flatter shot needed)

2. **Supports skill progression**: 
   - Archery rank increases accuracy range (tighter arc at long distances)
   - Visual feedback for improving (arrows flying more stable)
   - High skill ceiling (players learn to predict arcs)

3. **Rich interactions**:
   - Obstacles could block arrows mid-flight
   - Particles could show wind affecting arrows
   - Arrows could lodge in NPCs/terrain for story beats

4. **Integrates existing systems**:
   - WeatherCombatIntegration.dm could add wind modifier
   - Season changes affect arrow speed/arc (humidity)
   - Elevation system affects initial launch angle

5. **Not expensive to implement**:
   - Simple loop: ~50 lines per projectile type
   - One extra task per active projectile
   - Network-friendly (position updates are small packets)

---

## Detailed Ballistic Implementation Plan

### Phase 1: Core Projectile System

```dm
// Core projectile base class
/obj/projectile
	var
		// Identity
		projectile_type = "arrow"  // arrow, bolt, knife, javelin, stone
		source_mob = null          // Who fired it
		
		// Target tracking
		target_mob = null          // Intended target
		target_loc = null          // Location target
		
		// Flight path
		start_loc = null           // Where fired from
		end_loc = null             // Where landing
		
		// Physics
		flight_start_time = 0
		flight_duration = 0        // ticks (30 for arrow, 25 for bolt, etc.)
		arc_height = 8             // pixels above path
		
		// Damage
		damage_base = 10
		accuracy = 1.0             // 0.0-1.0 (1.0 = guaranteed hit)
		
		// State
		projectile_state = "flying"  // flying, stuck, expired
		
		// Visual
		icon = 'dmi/32/projectiles.dmi'
		icon_state = "arrow"
		layer = EFFECTS_LAYER

/obj/projectile/proc/FireAtTarget(mob/source, mob/target, skill_level)
	source_mob = source
	target_mob = target
	start_loc = get_turf(source)
	end_loc = get_turf(target)
	
	flight_duration = CalculateFlightTime(start_loc, end_loc)
	accuracy = CalculateAccuracy(source, target, skill_level)
	damage_base = CalculateDamage(source, skill_level)
	
	loc = start_loc
	spawn() AnimateFlight()

/obj/projectile/proc/CalculateFlightTime(turf/from, turf/to)
	// Distance in tiles = sqrt((x2-x1)^2 + (y2-y1)^2)
	var/distance = get_dist(from, to)
	var/speed = projectile_speed()  // tiles per tick
	return distance / speed

/obj/projectile/proc/projectile_speed()
	switch(projectile_type)
		if("arrow") return 0.15      // 4.5 tiles/sec
		if("bolt") return 0.25       // 7.5 tiles/sec
		if("knife") return 0.12      // 3.6 tiles/sec
		if("javelin") return 0.18    // 5.4 tiles/sec
		if("stone") return 0.20      // 6 tiles/sec
	return 0.15

/obj/projectile/proc/AnimateFlight()
	set background = 1
	set waitfor = 0
	
	var/start_time = world.time
	var/start_x = start_loc.x
	var/start_y = start_loc.y
	var/start_z = start_loc.z
	var/end_x = end_loc.x
	var/end_y = end_loc.y
	var/end_z = end_loc.z
	
	while(world.time < start_time + flight_duration)
		var/progress = (world.time - start_time) / flight_duration  // 0.0 to 1.0
		
		// Linear interpolation for X,Y
		var/new_x = start_x + (end_x - start_x) * progress
		var/new_y = start_y + (end_y - start_y) * progress
		
		// Parabolic arc for Z (height)
		var/arc_z = arc_height * sin(progress * PI)  // sin(0) = 0, sin(0.5π) = 1, sin(π) = 0
		
		// Move projectile
		x = new_x
		y = new_y
		z = start_z + arc_z  // Above ground during flight
		
		// Check for obstacles mid-flight
		CheckFlightCollision()
		
		// Visual update (rotation toward direction)
		UpdateFlightRotation(new_x, new_y)
		
		sleep(1)
	
	// Impact!
	OnImpact()

/obj/projectile/proc/UpdateFlightRotation(new_x, new_y)
	// Point arrow toward direction of travel
	var/dx = new_x - x
	var/dy = new_y - y
	var/angle = atan2(dy, dx)  // BYOND angle (radians)
	
	// Update icon_state or visual rotation based on angle
	// For 8-direction game: N, NE, E, SE, S, SW, W, NW

/obj/projectile/proc/CheckFlightCollision()
	// Check if projectile hit obstacle during flight
	if(!target_mob) return  // No collision if aimed at ground
	
	var/turf/T = locate(x, y, z)
	if(!T) return
	
	// Check for walls/obstacles
	for(var/atom/obstacle in T.contents)
		if(obstacle == source_mob) continue
		if(!obstacle.density) continue
		
		// Hit obstacle mid-flight
		ProjectileCollision(obstacle)
		return

/obj/projectile/proc/OnImpact()
	projectile_state = "impacting"
	
	// Check if hit
	if(accuracy < rand())
		// MISS - projectile lands on ground, disappears
		loc = end_loc
		sleep(30)  // Show projectile for 3 seconds
		del(src)
		return
	
	// HIT
	if(target_mob)
		var/final_damage = damage_base
		
		// Apply weather modifiers
		if(global_seasonal_weather)
			final_damage *= global_seasonal_weather.GetWeatherDamageModifier()
		
		// Apply accuracy bonus
		final_damage *= (0.5 + accuracy * 0.5)  // 50% to 100% of base
		
		// Target takes damage
		target_mob.TakeDamage(final_damage)
		
		// Create impact effect
		new /obj/effect/impact_marker(end_loc)
		
		// Remove projectile
		del(src)
	else
		// No target, land at location
		loc = end_loc
		projectile_state = "stuck"
		sleep(60)  // Stuck in ground for 6 seconds
		del(src)

/obj/projectile/proc/ProjectileCollision(atom/obstacle)
	// Projectile hit something mid-flight
	projectile_state = "stuck"
	loc = get_turf(obstacle)
	
	// Damage to obstacle? (future feature)
	// Delete projectile after delay
	sleep(30)
	del(src)
```

### Phase 2: Weapon Integration

```dm
// Bow weapon class
/obj/item/weapon/bow
	name = "shortbow"
	damage = 8
	icon = 'dmi/32/weapons.dmi'
	icon_state = "shortbow"
	
	var/projectile_type = "arrow"
	var/max_range = 10
	var/base_accuracy = 0.75
	var/cast_time = 10  // ticks to draw

/obj/item/weapon/bow/proc/Fire(mob/user, mob/target)
	if(!(projectile_type in user.ammunition))
		user << "Out of [projectile_type]s!"
		return 0
	
	// Draw bow
	user << "Drawing [src]..."
	sleep(cast_time)
	
	// Fire
	var/obj/projectile/P = new projectile_type(user.loc)
	P.FireAtTarget(user, target, user.GetRankLevel(RANK_ARCHERY))
	
	// Consume ammo
	user.ammunition[projectile_type]--
	
	return 1
```

### Phase 3: Skill Integration

```dm
#define RANK_ARCHERY "archery"

// Archery skill progression
var/list/ARCHERY_PROGRESSION = list(
	1 = list(
		"weapon" = /obj/item/weapon/bow,
		"max_range" = 8,
		"accuracy" = 0.65,
		"description" = "Basic archery. Steady aim helps."
	),
	2 = list(
		"weapon" = /obj/item/weapon/bow/composite,
		"max_range" = 10,
		"accuracy" = 0.75,
		"description" = "Improved bows available."
	),
	3 = list(
		"weapon" = /obj/item/weapon/bow/longbow,
		"max_range" = 14,
		"accuracy" = 0.80,
		"description" = "Master the longbow. Greater range."
	),
	4 = list(
		"weapon" = /obj/item/weapon/bow/masterwork,
		"max_range" = 16,
		"accuracy" = 0.85,
		"special" = "rapid_fire",
		"description" = "Rapid fire technique unlocked."
	),
	5 = list(
		"weapon" = /obj/item/weapon/bow/legendary,
		"max_range" = 18,
		"accuracy" = 0.90,
		"special" = list("rapid_fire", "piercing_shot"),
		"description" = "Legendary archer. Never miss."
	)
)

/mob/proc/FireRangedAttack(target, weapon_type)
	if(!CanEnterCombat(src, target))
		src << "Cannot attack [target]!"
		return 0
	
	var/skill_level = GetRankLevel(RANK_ARCHERY)
	if(skill_level < 1)
		src << "You need to learn archery first!"
		return 0
	
	var/progression = ARCHERY_PROGRESSION[skill_level]
	var/max_range = progression["max_range"]
	var/accuracy = progression["accuracy"]
	
	if(get_dist(src, target) > max_range)
		src << "Target too far away!"
		return 0
	
	// Fire projectile
	var/obj/projectile/P = new /obj/projectile/arrow(src.loc)
	P.FireAtTarget(src, target, skill_level)
	
	// Award experience
	UpdateRankExp(RANK_ARCHERY, 5)
	
	return 1
```

---

## Comparison Chart: Flight Styles in Pondera Context

| Feature | Ballistic | Instant | Hybrid |
|---------|-----------|---------|--------|
| **Visual appeal** | 9/10 | 4/10 | 7/10 |
| **Skill expression** | 9/10 | 5/10 | 6/10 |
| **Implementation complexity** | 7/10 | 3/10 | 5/10 |
| **System integration** | 8/10 | 6/10 | 7/10 |
| **World immersion** | 9/10 | 5/10 | 7/10 |
| **Elevation compatibility** | 9/10 | 6/10 | 7/10 |
| **Weather integration** | 9/10 | 4/10 | 5/10 |
| **Combat feel** | Tactical | Fast | Balanced |
| **PvP suitability** | High | Medium | High |

---

## Summary

For Pondera's survival/sandbox/PvP focus:

**Recommendation: Ballistic Arc (Style 1)**
- Matches the world's tactical, environmental design
- Integrates naturally with elevation/weather/seasons
- Provides skill progression through visual mastery
- Creates rich emergent gameplay moments
- Only marginally more complex than alternatives

**Next Steps**:
1. Implement core projectile system (Phase 39)
2. Add bow/crossbow/throwing weapons
3. Integrate with existing combat system
4. Balance via skill levels and range limits
5. Expand to environmental interactions (Phase 40)

---

**Prepared**: December 9, 2025
**For**: Pondera AI Development
**Status**: Ready for implementation
