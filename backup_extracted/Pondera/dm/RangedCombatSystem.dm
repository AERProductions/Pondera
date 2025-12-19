// RangedCombatSystem.dm - Phase 39: Ranged Combat with Ballistic Projectiles
// Implements projectile system with parabolic flight, skill-based accuracy, and weapon types

// =============================================================================
// PROJECTILE BASE CLASS
// =============================================================================

/obj/projectile
	name = "projectile"
	var
		// Identity
		projectile_type = "arrow"  // arrow, bolt, knife, javelin, stone
		mob/source_mob = null          // Who fired it
		
		// Target tracking
		mob/target_mob = null          // Intended target (can be null for ground shots)
		target_loc = null          // Location target
		
		// Flight path
		turf/start_loc = null           // Where fired from
		turf/end_loc = null             // Where landing
		
		// Physics
		flight_start_time = 0
		flight_duration = 0        // ticks (30 for arrow, 25 for bolt, etc.)
		arc_height = 8             // pixels above path
		
		// Damage
		damage_base = 10
		accuracy = 1.0             // 0.0-1.0 (1.0 = guaranteed hit)
		
		// State
		projectile_state = "flying"  // flying, stuck, expired
	
	// Visual properties (outside var block to avoid conflicts)
	icon = 'dmi/64/blank.dmi'
	icon_state = "arrow"
	layer = EFFECTS_LAYER

/obj/projectile/proc/FireAtTarget(source, target, skill_level)
	var/mob/source_mob_arg = source
	var/mob/target_mob_arg = target
	source_mob = source_mob_arg
	target_mob = target_mob_arg
	start_loc = source_mob_arg.loc
	end_loc = target_mob_arg.loc
	
	// Calculate flight time based on distance and projectile speed
	flight_duration = CalculateFlightTime(start_loc, end_loc)
	
	// Calculate accuracy based on skill and distance
	accuracy = CalculateAccuracy(source_mob_arg, target_mob_arg, skill_level)
	
	// Calculate damage based on skill and weapon type
	damage_base = CalculateDamage(source_mob_arg, skill_level)
	
	// Position and start animation
	loc = start_loc
	spawn() AnimateFlight()

/obj/projectile/proc/CalculateFlightTime(from, to_loc)
	var/turf/start_turf = from
	var/turf/end_turf = to_loc
	// Distance in tiles
	var/distance = get_dist(start_turf, end_turf)
	var/speed = GetProjectileSpeed()  // tiles per tick
	
	if(speed <= 0) speed = 0.15  // Fallback
	return max(5, distance / speed)  // Minimum 5 ticks flight time

/obj/projectile/proc/GetProjectileSpeed()
	switch(projectile_type)
		if("arrow") return 0.15      // 4.5 tiles/sec
		if("bolt") return 0.25       // 7.5 tiles/sec (faster)
		if("knife") return 0.12      // 3.6 tiles/sec (slower)
		if("javelin") return 0.18    // 5.4 tiles/sec
		if("stone") return 0.20      // 6 tiles/sec
	return 0.15  // Default

/obj/projectile/proc/GetArcHeight()
	switch(projectile_type)
		if("arrow") return 6        // Low arc
		if("bolt") return 3         // Very flat
		if("knife") return 2        // Almost no arc
		if("javelin") return 8      // Medium arc
		if("stone") return 12       // High arc
	return 8

/obj/projectile/proc/CalculateAccuracy(source, target, skill_level)
	var/mob/src_mob = source
	var/mob/tgt_mob = target
	// Base accuracy from skill level
	var/base_accuracy = (50 + skill_level * 8) / 100  // 58% at level 1, 90% at level 5
	
	// Distance penalty
	var/distance = get_dist(src_mob, tgt_mob)
	var/max_range = GetMaxRange(skill_level)
	
	if(distance > max_range)
		return 0  // Out of range = automatic miss
	
	// Closer is more accurate
	var/distance_penalty = 1 - (distance / (max_range * 1.5))
	
	// Weather modifiers can be added here if needed
	// For now, basic distance-based accuracy
	
	return base_accuracy * distance_penalty

/obj/projectile/proc/CalculateDamage(source, skill_level)
	// Base damage from weapon
	var/base_dmg = 8 + (skill_level * 2)  // 10 at level 1, 18 at level 5
	
	// Weapon modifier
	switch(projectile_type)
		if("arrow") base_dmg *= 1.0
		if("bolt") base_dmg *= 1.2      // Crossbow does more damage
		if("knife") base_dmg *= 0.8     // Throwing knife does less
		if("javelin") base_dmg *= 1.4   // Javelin does most damage
		if("stone") base_dmg *= 0.9
	
	return base_dmg

/obj/projectile/proc/GetMaxRange(skill_level)
	switch(projectile_type)
		if("arrow")
			switch(skill_level)
				if(1) return 8
				if(2) return 10
				if(3) return 14
				if(4) return 16
				if(5) return 18
		if("bolt")
			switch(skill_level)
				if(1) return 12
				if(2) return 14
				if(3) return 16
				if(4) return 18
				if(5) return 20
		if("knife")
			switch(skill_level)
				if(1) return 4
				if(2) return 5
				if(3) return 7
				if(4) return 8
				if(5) return 10
		if("javelin")
			switch(skill_level)
				if(1) return 8
				if(2) return 10
				if(3) return 12
				if(4) return 14
				if(5) return 15
		if("stone")
			switch(skill_level)
				if(1) return 6
				if(2) return 8
				if(3) return 10
				if(4) return 12
				if(5) return 14
	
	return 8  // Default fallback

/obj/projectile/proc/AnimateFlight()
	set background = 1
	set waitfor = 0
	
	arc_height = GetArcHeight()
	
	var/start_time = world.time
	var/start_x = start_loc.x
	var/start_y = start_loc.y
	var/start_z = start_loc.z
	var/end_x = end_loc.x
	var/end_y = end_loc.y
	
	// Flight animation loop
	while(world.time < start_time + flight_duration)
		var/progress = (world.time - start_time) / flight_duration  // 0.0 to 1.0
		
		// Linear interpolation for X,Y (horizontal movement)
		var/new_x = start_x + (end_x - start_x) * progress
		var/new_y = start_y + (end_y - start_y) * progress
		
		// Parabolic arc for Z (height)
		// sin(0) = 0, sin(π/2) = 1, sin(π) = 0
		// This creates a smooth arc that rises and falls
		var/arc_z = arc_height * sin(progress * 3.14159)
		
		// Update projectile position
		x = new_x
		y = new_y
		z = start_z + arc_z
		
		// Check for obstacles mid-flight
		CheckFlightCollision()
		
		// Update visual rotation toward direction
		UpdateFlightRotation(new_x, new_y, progress)
		
		sleep(1)
	
	// Impact!
	OnImpact()

/obj/projectile/proc/UpdateFlightRotation(new_x, new_y, progress)
	// Point projectile toward direction of travel
	var/dx = end_loc.x - new_x
	var/dy = end_loc.y - new_y
	
	// Only update rotation if moving
	if(dx != 0 || dy != 0)
		// Determine direction (8 directions)
		if(dy > abs(dx))
			dir = NORTH
		else if(dy < -abs(dx))
			dir = SOUTH
		else if(dx > abs(dy))
			dir = EAST
		else if(dx < -abs(dy))
			dir = WEST
		else if(dx > 0 && dy > 0)
			dir = NORTHEAST
		else if(dx > 0 && dy < 0)
			dir = SOUTHEAST
		else if(dx < 0 && dy > 0)
			dir = NORTHWEST
		else if(dx < 0 && dy < 0)
			dir = SOUTHWEST

/obj/projectile/proc/CheckFlightCollision()
	// Check if projectile hit obstacle during flight
	if(!target_mob) return  // No collision check if aimed at ground
	
	var/turf/T = src.loc
	if(!T) return
	
	// Check for dense objects in the way
	for(var/atom/obstacle in T.contents)
		if(obstacle == source_mob) continue       // Don't collide with self
		if(!obstacle.density) continue            // Ignore non-solid objects
		if(obstacle == target_mob) return         // Don't stop on target
		
		// Hit obstacle mid-flight - projectile stops here
		ProjectileCollision(obstacle)
		return

/obj/projectile/proc/ProjectileCollision(obstacle)
	var/atom/obs = obstacle
	// Projectile hit something mid-flight
	projectile_state = "stuck"
	loc = obs.loc
	
	// Delete projectile after a delay (show stuck for 3 seconds)
	spawn(30) del(src)

/obj/projectile/proc/OnImpact()
	projectile_state = "impacting"
	
	var/did_hit = 0
	
	// Check if projectile actually hit target
	if(target_mob && prob(accuracy * 100))
		did_hit = 1
		var/final_damage = damage_base
		
		// Weather modifiers can be added here if needed
		// final_damage *= GetWeatherModifier()
		
		// Apply elevation modifier if needed
		if(Chk_LevelRange(source_mob, target_mob))
			// Targets are within elevation range
			final_damage *= 1.0
		else
			// Out of elevation range, reduced damage
			final_damage *= 0.5
		
		// Target takes damage
		if(istype(target_mob, /mob/players))
			var/mob/players/PD = target_mob
			PD.HP = max(0, PD.HP - final_damage)
			PD.updateHP()
		else if(istype(target_mob, /mob/enemies))
			var/mob/enemies/ED = target_mob
			ED.HP = max(0, ED.HP - final_damage)
		
		// Create impact effect
		var/obj/effect/impact_marker/IM = new()
		IM.loc = target_mob.loc
		
		// Log the hit
		var/source_name = source_mob ? source_mob.name : "unknown"
		var/target_name = target_mob ? target_mob.name : "unknown"
		world.log << "[source_name] hit [target_name] with [projectile_type] for [final_damage] damage"
	else if(target_mob)
		// MISS
		var/source_name = source_mob ? source_mob.name : "unknown"
		var/target_name = target_mob ? target_mob.name : "unknown"
		world.log << "[source_name] missed [target_name] with [projectile_type]"
		loc = end_loc
		spawn(30)  // Show projectile for 3 seconds
			del(src)
		return
	
	// Delete projectile
	if(did_hit)
		del(src)

// =============================================================================
// RANGED ATTACK SYSTEM
// =============================================================================

/proc/FireRangedAttack(source, target, projectile_type, skill_type)
	var/mob/src_mob = source
	var/mob/tgt_mob = target
	// Main entry point for ranged attacks
	
	// Validate source
	if(!src_mob || !ismob(src_mob))
		return 0
	
	// Validate target
	if(!tgt_mob || !ismob(tgt_mob))
		src_mob << "Invalid target!"
		return 0
	
	// Check combat eligibility
	if(!CanEnterCombat(src_mob, tgt_mob))
		src_mob << "Cannot attack [tgt_mob]!"
		return 0
	
	// Get skill level (only players can use ranged attacks with skills)
	if(!istype(src_mob, /mob/players))
		src_mob << "Only players can use ranged attacks!"
		return 0
	
	var/mob/players/player = src_mob
	var/skill_level = 1
	if(skill_type == RANK_ARCHERY)
		skill_level = player.GetRankLevel(RANK_ARCHERY)
	else if(skill_type == RANK_CROSSBOW)
		skill_level = player.GetRankLevel(RANK_CROSSBOW)
	else if(skill_type == RANK_THROWING)
		skill_level = player.GetRankLevel(RANK_THROWING)
	
	if(skill_level < 1)
		player << "You need training in [skill_type] first!"
		return 0
	
	// Check range
	var/distance = get_dist(src_mob, tgt_mob)
	var/max_range = GetMaxRangeForSkill(skill_level, projectile_type)
	
	if(distance > max_range)
		src_mob << "[tgt_mob] is too far away! (Max range: [max_range] tiles)"
		return 0
	
	// Create and fire projectile
	var/obj/projectile/P = new projectile_type(src_mob.loc)
	P.FireAtTarget(src_mob, tgt_mob, skill_level)
	
	// Award experience (only if source is a player)
	player.UpdateRankExp(skill_type, 5)
	
	return 1

/proc/GetMaxRangeForSkill(skill_level, projectile_type)
	switch(projectile_type)
		if("arrow")
			return 8 + (skill_level * 2)   // 10-18
		if("bolt")
			return 12 + (skill_level * 2)  // 14-20
		if("knife")
			return 4 + (skill_level - 1)   // 4-8
		if("javelin")
			return 8 + (skill_level)       // 9-13
		if("stone")
			return 6 + (skill_level)       // 7-11
	return 8

// =============================================================================
// WEAPON CLASSES
// =============================================================================

/obj/item/weapon/bow
	name = "bow"
	desc = "A simple wooden bow for ranged combat."
	icon = 'dmi/64/weaps.dmi'
	icon_state = "bow"
	var/damage = 8
	var/projectile_type = "arrow"
	var/skill_type = RANK_ARCHERY
	var/cast_time = 6

/obj/item/weapon/bow/longbow
	name = "longbow"
	desc = "A tall bow with greater range and power."
	damage = 10
	icon_state = "longbow"

/obj/item/weapon/bow/crossbow
	name = "crossbow"
	desc = "A mechanical bow that's quick to fire."
	damage = 12
	icon_state = "crossbow"
	projectile_type = "bolt"
	skill_type = RANK_CROSSBOW
	cast_time = 10

/obj/item/weapon/throwing
	name = "throwing weapon"
	desc = "A weapon designed for throwing."
	icon = 'dmi/64/weaps.dmi'
	var/projectile_type = "stone"
	var/skill_type = RANK_THROWING
	var/damage = 7
	var/cast_time = 8

/obj/item/weapon/throwing/knife
	name = "throwing knife"
	desc = "A balanced blade designed for throwing."
	damage = 6
	icon_state = "throwing_knife"
	projectile_type = "knife"
	cast_time = 8

/obj/item/weapon/throwing/javelin
	name = "javelin"
	desc = "A heavy spear designed for throwing."
	damage = 14
	icon_state = "javelin"
	projectile_type = "javelin"
	cast_time = 20

/obj/item/weapon/throwing/sling_stone
	name = "sling stone"
	desc = "A smooth stone fitted to a sling."
	damage = 7
	icon_state = "sling_stone"
	projectile_type = "stone"
	cast_time = 12

// =============================================================================
// IMPACT EFFECT
// =============================================================================

/obj/effect/impact_marker
	name = "impact"
	desc = "The impact of a projectile."
	icon = 'dmi/64/blank.dmi'
	icon_state = "impact"
	var/duration = 10  // Show for 1 second

/obj/effect/impact_marker/New()
	..()
	spawn(duration)
		del(src)

// =============================================================================
// SKILL PROGRESSION TABLES
// =============================================================================

// SKILL PROGRESSION TABLES
// =============================================================================

var/list/ARCHERY_PROGRESSION = list(
	"1" = list(
		"name" = "Novice Archer",
		"max_range" = 10,
		"accuracy" = 0.60,
		"description" = "Basic archery training. Steady hands help."
	),
	"2" = list(
		"name" = "Apprentice Archer",
		"max_range" = 12,
		"accuracy" = 0.70,
		"description" = "Improved aim and technique."
	),
	"3" = list(
		"name" = "Skilled Archer",
		"max_range" = 14,
		"accuracy" = 0.80,
		"description" = "Master the longbow. Greater range and accuracy."
	),
	"4" = list(
		"name" = "Expert Archer",
		"max_range" = 16,
		"accuracy" = 0.85,
		"description" = "Advanced techniques. Quick shots possible."
	),
	"5" = list(
		"name" = "Master Archer",
		"max_range" = 18,
		"accuracy" = 0.90,
		"description" = "Legendary archer. Shots rarely miss."
	)
)

var/list/CROSSBOW_PROGRESSION = list(
	"1" = list(
		"name" = "Novice Crossbowman",
		"max_range" = 14,
		"accuracy" = 0.65,
		"description" = "Basic crossbow training."
	),
	"2" = list(
		"name" = "Apprentice Crossbowman",
		"max_range" = 16,
		"accuracy" = 0.75,
		"description" = "Improved reload speed and accuracy."
	),
	"3" = list(
		"name" = "Skilled Crossbowman",
		"max_range" = 18,
		"accuracy" = 0.80,
		"description" = "Master the heavy crossbow."
	),
	"4" = list(
		"name" = "Expert Crossbowman",
		"max_range" = 20,
		"accuracy" = 0.85,
		"description" = "Rapid reload technique unlocked."
	),
	"5" = list(
		"name" = "Master Crossbowman",
		"max_range" = 22,
		"accuracy" = 0.90,
		"description" = "Automatic reload. Devastating accuracy."
	)
)

var/list/THROWING_PROGRESSION = list(
	"1" = list(
		"name" = "Novice Thrower",
		"max_range" = 4,
		"accuracy" = 0.65,
		"description" = "Basic throwing technique."
	),
	"2" = list(
		"name" = "Apprentice Thrower",
		"max_range" = 5,
		"accuracy" = 0.72,
		"description" = "Better distance and accuracy."
	),
	"3" = list(
		"name" = "Skilled Thrower",
		"max_range" = 7,
		"accuracy" = 0.80,
		"description" = "Javelin mastery unlocked."
	),
	"4" = list(
		"name" = "Expert Thrower",
		"max_range" = 8,
		"accuracy" = 0.85,
		"description" = "Multi-throw technique available."
	),
	"5" = list(
		"name" = "Master Thrower",
		"max_range" = 10,
		"accuracy" = 0.90,
		"description" = "Legendary accuracy. Perfect control."
	)
)

// =============================================================================
// DEBUG VERBS
// =============================================================================

/mob/verb/TestRangedAttack()
	set category = "Debug"
	set name = "Test Ranged Attack"
	
	var/target_name = input(src, "Enter target name:", "Target")
	
	if(!target_name)
		src << "Cancelled."
		return
	
	var/mob/target = null
	for(var/mob/M in world)
		if(M.name == target_name)
			target = M
			break
	
	if(!target)
		src << "Target '[target_name]' not found!"
		return
	
	FireRangedAttack(src, target, "arrow", RANK_ARCHERY)
	src << "Fired arrow at [target.name]!"

/mob/verb/ViewRangedSkills()
	set category = "Debug"
	set name = "View Ranged Skills"
	
	src << "\n=== RANGED SKILLS ===\n"
	src << "Archery Level: [GetRankLevel(RANK_ARCHERY)]"
	src << "Crossbow Level: [GetRankLevel(RANK_CROSSBOW)]"
	src << "Throwing Level: [GetRankLevel(RANK_THROWING)]"
	src << "\n"
