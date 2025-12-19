/*
	PHASE 43: WEAPON ANIMATION SYSTEM
	
	Provides directional attack animations for melee and ranged weapons,
	with impact feedback and visual timing synchronization with combat damage.
	
	Features:
	- Directional swing animations (4 directions for melee)
	- Ranged weapon draw/fire sequences (bow, crossbow, throwing)
	- Impact animation sequences (slash, pierce, blunt)
	- Animation timing synchronized with damage application
	- Visual particle effects during attacks
	- Animation state tracking to prevent interrupt conflicts
	
	Architecture:
	- Animation state vars on mob (is_animating, anim_type, etc)
	- AnimationManager: Global animation system
	- DirectionalAnimations: Direction-aware animation selection
	- ImpactAnimations: Damage type-specific feedback
*/

#define ANIM_TYPE_MELEE 1
#define ANIM_TYPE_RANGED 2
#define ANIM_TYPE_IMPACT 3

#define MELEE_ANIM_DURATION 8		// 8 ticks = 200ms at 40 TPS
#define RANGED_ANIM_DURATION 5		// 5 ticks = 125ms draw/fire
#define IMPACT_ANIM_DURATION 4		// 4 ticks = 100ms impact flash

// Directional anim frame maps (icon_state format: "action_direction")
#define SWING_NORTH "melee_swing_north"
#define SWING_SOUTH "melee_swing_south"
#define SWING_EAST "melee_swing_east"
#define SWING_WEST "melee_swing_west"

#define DRAW_BOW "ranged_draw_bow"
#define FIRE_BOW "ranged_fire_bow"

#define DRAW_CROSSBOW "ranged_draw_crossbow"
#define FIRE_CROSSBOW "ranged_fire_crossbow"

#define DRAW_THROWING "ranged_ready_throw"
#define THROW "ranged_throw"

#define IMPACT_SLASH "impact_slash"
#define IMPACT_PIERCE "impact_pierce"
#define IMPACT_BLUNT "impact_blunt"

/*
	Animation State Manager (simplified - no datum)
	Tracks animation state per mob
*/

/proc/InitMobAnimationState(mob/M)
	if(!M)
		return
	
	// Create animation tracking vars on mob if not present
	if(!M.vars["anim_is_playing"])
		M.vars["anim_is_playing"] = 0
		M.vars["anim_type"] = 0
		M.vars["anim_start_time"] = 0
		M.vars["anim_duration"] = 0
		M.vars["anim_saved_icon"] = ""
		M.vars["anim_saved_layer"] = 0

/*
	Animation Manager
	Central coordinator for all animation playback
*/
/proc/AnimationManager()
	set background = 1
	set waitfor = 0
	
	while(1)
		sleep(1)  // Check every tick
		
		for(var/mob/M in world)
			if(M.vars["anim_is_playing"])
				var/elapsed = world.time - M.vars["anim_start_time"]
				
				// Animation finished?
				if(elapsed >= M.vars["anim_duration"])
					EndMobAnimation(M)

/*
	Start Attack Animation
	Initialize directional swing based on attack direction
*/
/proc/PlayAttackAnimation(mob/M, attack_dir, weapon_type="sword")
	
	if(!M)
		return FALSE
	
	// Initialize animation state if needed
	InitMobAnimationState(M)
	
	// Prevent animation stacking
	if(M.vars["anim_is_playing"])
		return FALSE
	
	var/anim_state = GetMeleeAnimationState(attack_dir, weapon_type)
	
	if(!anim_state)
		return FALSE
	
	// Begin animation sequence
	M.vars["anim_is_playing"] = 1
	M.vars["anim_type"] = ANIM_TYPE_MELEE
	M.vars["anim_start_time"] = world.time
	M.vars["anim_duration"] = MELEE_ANIM_DURATION
	M.vars["anim_saved_icon"] = M.icon_state
	M.vars["anim_saved_layer"] = M.layer
	
	// Apply animation frame
	M.icon_state = anim_state
	M.layer = MOB_LAYER + 0.1  // Slight raise for visibility
	
	// Schedule damage application mid-swing (after 4 ticks)
	spawn(4)
		if(M.vars["anim_is_playing"] && M.vars["anim_type"] == ANIM_TYPE_MELEE)
			ApplyAnimationDamage(M)
	
	return TRUE

/*
	Get Melee Animation State
	Determine correct icon_state based on direction and weapon
*/
/proc/GetMeleeAnimationState(dir, weapon_type)
	
	switch(dir)
		if(NORTH)
			return SWING_NORTH
		if(SOUTH)
			return SWING_SOUTH
		if(EAST)
			return SWING_EAST
		if(WEST)
			return SWING_WEST
	
	return null

/*
	Play Ranged Attack Animation
	Draw-fire sequence for bow/crossbow/throwing
*/
/proc/PlayRangedAnimation(mob/M, skill_type, damage=0)
	
	if(!M)
		return FALSE
	
	InitMobAnimationState(M)
	
	if(M.vars["anim_is_playing"])
		return FALSE
	
	var/draw_state = ""
	var/fire_state = ""
	
	switch(skill_type)
		if("archery")
			draw_state = DRAW_BOW
			fire_state = FIRE_BOW
		if("crossbow")
			draw_state = DRAW_CROSSBOW
			fire_state = FIRE_CROSSBOW
		if("throwing")
			draw_state = DRAW_THROWING
			fire_state = THROW
		else
			return FALSE
	
	// Begin draw sequence
	M.vars["anim_is_playing"] = 1
	M.vars["anim_type"] = ANIM_TYPE_RANGED
	M.vars["anim_start_time"] = world.time
	M.vars["anim_duration"] = RANGED_ANIM_DURATION
	M.vars["anim_saved_icon"] = M.icon_state
	M.vars["anim_saved_layer"] = M.layer
	
	M.icon_state = draw_state
	M.layer = MOB_LAYER + 0.1
	
	// Transition to fire state mid-animation (3 ticks)
	spawn(3)
		if(M.vars["anim_is_playing"] && M.vars["anim_type"] == ANIM_TYPE_RANGED)
			M.icon_state = fire_state
	
	// Apply projectile/damage at fire point (4 ticks)
	spawn(4)
		if(M.vars["anim_is_playing"] && M.vars["anim_type"] == ANIM_TYPE_RANGED)
			ApplyRangedDamage(M, damage, skill_type)
	
	return TRUE

/*
	Play Impact Animation
	Damage type-specific impact feedback at target location
*/
/proc/PlayImpactAnimation(turf/T, damage_type="blunt", severity=1)
	
	if(!T)
		return
	
	var/impact_color = "#ffffff"
	
	switch(damage_type)
		if("slash")
			impact_color = "#ff6666"  // Red for bleeding
		if("pierce")
			impact_color = "#ffaa00"  // Orange for pierce
		if("blunt")
			impact_color = "#aaaaaa"  // Gray for blunt
	
	// Create impact effect
	var/obj/effect/impact/I = new(T)
	I.color = impact_color
	I.layer = EFFECTS_LAYER
	
	// Fade out over duration
	animate(I, alpha=0, time=IMPACT_ANIM_DURATION)
	
	spawn(IMPACT_ANIM_DURATION)
		del(I)

/*
	Apply Animation Damage (internal)
	Called during melee swing sequence at correct timing
*/
/proc/ApplyAnimationDamage(mob/M)
	
	if(!M || !M.vars["anim_is_playing"])
		return
	
	// Get target in front of M
	var/target_dir = M.dir
	var/turf/T = get_step(M, target_dir)
	
	if(!T)
		return
	
	// Find living target
	var/mob/target = null
	for(var/mob/potential in T.contents)
		if(potential != M && potential:HP > 0)
			target = potential
			break
	
	if(!target)
		return
	
	// Apply existing melee damage system
	// This calls the environmental modifiers system from Phase 42
	PerformMeleeAttackWithEnvironment(M, target)
	
	// Play combat audio feedback (Phase C.1 Audio Integration)
	PlayCombatHitSound(M, 50, FALSE)  // Default hit sound

/*
	Apply Ranged Damage (internal)
	Called during ranged fire sequence at correct timing
*/
/proc/ApplyRangedDamage(mob/M, damage, skill_type)
	
	if(!M || !M.vars["anim_is_playing"])
		return
	
	// Call existing ranged damage system
	PerformRangedAttackWithEnvironment(M, null, skill_type)

/*
	End Mob Animation
	Restore mob to normal state after animation completes
*/
/proc/EndMobAnimation(mob/M)
	
	if(!M)
		return
	
	InitMobAnimationState(M)
	
	M.vars["anim_is_playing"] = 0
	M.icon_state = M.vars["anim_saved_icon"]
	M.layer = M.vars["anim_saved_layer"]

/*
	Impact Effect Object
	Visual effect for damage feedback at impact location
	Uses color and alpha effects instead of custom icons
*/
/obj/effect/impact
	layer = EFFECTS_LAYER
	density = 0
	opacity = 0
	mouse_opacity = 0
	pixel_x = 0
	pixel_y = 0

/*
	Damage Flash Effect
	Quick flash at damage location for visual feedback
*/
/proc/PlayDamageFlash(turf/T, severity=1)
	
	if(!T)
		return
	
	// Create flash effect object - reuse existing effect types
	var/obj/effect/impact/I = new(T)
	I.alpha = 200
	I.color = rgb(255, 100 * severity, 100 * severity)
	
	animate(I, alpha=0, time=3)
	
	spawn(3)
		del(I)

/obj/effect/flash
	layer = EFFECTS_LAYER - 0.1
	density = 0
	opacity = 0
	mouse_opacity = 0
	alpha = 200

/*
	Slash Trail Effect
	Visual particle for sword/blade animations
*/
/proc/PlaySlashTrail(mob/M, attack_dir)
	
	if(!M)
		return
	
	// Determine trail direction based on attack
	var/offset_x = 0
	var/offset_y = 0
	
	switch(attack_dir)
		if(NORTH)
			offset_y = 16
		if(SOUTH)
			offset_y = -16
		if(EAST)
			offset_x = 16
		if(WEST)
			offset_x = -16
	
	var/obj/effect/slash_trail/S = new(M)
	S.pixel_x = offset_x
	S.pixel_y = offset_y
	S.color = rgb(200, 200, 200)
	
	animate(S, pixel_x=offset_x/2, pixel_y=offset_y/2, alpha=0, time=6)
	
	spawn(6)
		del(S)

/obj/effect/slash_trail
	layer = EFFECTS_LAYER - 0.5
	density = 0
	opacity = 0
	mouse_opacity = 0
	alpha = 200

/*
	Integration: Hook into Macro Combat System
	Called from Phase 41 keyboard verbs
*/
/proc/PerformAnimatedMeleeAttack(mob/attacker, mob/target)
	
	if(!attacker || !target)
		return FALSE
	
	// Play attack animation
	if(!PlayAttackAnimation(attacker, attacker.dir, attacker.Wequipped ? "sword" : "fist"))
		return FALSE
	
	// Play slash trail
	PlaySlashTrail(attacker, attacker.dir)
	
	// Damage applied during animation sequence
	return TRUE

/*
	Integration: Hook into Ranged Combat
	Called from Phase 41 V-key ranged attack
*/
/proc/PerformAnimatedRangedAttack(mob/attacker, skill_type)
	
	if(!attacker)
		return FALSE
	
	// Calculate base damage (reuse from RangedCombatSystem)
	var/base_damage = CalculateRangedDamage(attacker, skill_type)
	
	// Play ranged animation sequence
	if(!PlayRangedAnimation(attacker, skill_type, base_damage))
		return FALSE
	
	return TRUE

/*
	Animation System Initialization
	Called from InitializationManager
*/
/proc/InitializeAnimationSystem()
	
	// Start animation manager loop
	spawn(0)
		AnimationManager()
	
	// Register completion
	RegisterInitComplete("AnimationSystem")

/*
	Debug Verbs for Testing Animations
*/
/mob/players/verb/test_melee_anim()
	set name = "Test Melee Animation"
	set category = "Debug"
	
	PlayAttackAnimation(src, NORTH, "sword")
	PlayDamageFlash(get_step(src, NORTH), 1)
	world.log << "[src.name] played melee animation (NORTH)"

/mob/players/verb/test_ranged_anim()
	set name = "Test Ranged Animation"
	set category = "Debug"
	
	PerformAnimatedRangedAttack(src, "archery")
	world.log << "[src.name] played ranged animation (archery)"

/mob/players/verb/test_impact_anim()
	set name = "Test Impact Animation"
	set category = "Debug"
	
	var/turf/T = get_step(src, src.dir)
	PlayImpactAnimation(T, "slash", 1)
	PlayDamageFlash(T, 2)
	world.log << "[src.name] triggered impact animation"

/*
	Helper: Get Equipped Weapon Type
	Returns weapon type from current equipped weapon
*/
/proc/GetEquippedWeaponType(mob/M)
	
	if(!M)
		return "fist"
	
	// Check for equipped weapon
	if(M.Wequipped)
		// Determine weapon type from equipped item
		var/obj/item = M.Wequipped
		
		if(item.icon_state)
			if(findtext(item.icon_state, "sword"))
				return "sword"
			if(findtext(item.icon_state, "axe"))
				return "axe"
			if(findtext(item.icon_state, "hammer"))
				return "hammer"
			if(findtext(item.icon_state, "dagger"))
				return "dagger"
	
	return "fist"

/*
	Helper: Calculate Ranged Damage
	Reuses calculation from RangedCombatSystem.dm
	Returns base damage before environmental modifiers
*/
/proc/CalculateRangedDamage(mob/M, skill_type)
	
	if(!M)
		return 0
	
	// Base damage by skill type
	var/base = 0
	switch(skill_type)
		if("archery")
			base = 25
		if("crossbow")
			base = 30
		if("throwing")
			base = 20
	
	// Skill scaling: +2% damage per rank level
	if(!istype(M, /mob/players))
		return base
	
	var/mob/players/P = M
	var/rank_level = P.GetRankLevel(skill_type)
	var/skill_bonus = base * (rank_level * 0.02)
	
	return base + skill_bonus

// CONSOLIDATED: InitializeAnimationSystem() now called from InitializeWorld() in InitializationManager.dm
// Do NOT define world/New() here - it will override the primary one!
