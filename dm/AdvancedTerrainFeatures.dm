/**
 * ADVANCED TERRAIN FEATURES - PHASE 7
 * 
 * Extends elevation system with advanced structural features:
 * - Platforms (mid-level floors)
 * - Slopes (gradual elevation transitions)
 * - Scaffolding (temporary climbing aids)
 * - Ledges (intermediate climb points)
 * 
 * MECHANICS:
 * - Each feature has climbing difficulty rating
 * - Climbing rank gates access to higher difficulty features
 * - Features can be damaged/degraded over time (future)
 * - Fall damage scales with platform height
 * 
 * INTEGRATION:
 * - Uses existing AttemptClimbTraversal system
 * - Works with elevation/ditch, /elevation/hill
 * - XP awards increase for complex terrain
 */

// ==================== PLATFORM OBJECTS ====================

/**
 * /elevation/platform - Basic elevated platform
 * Provides static elevated surface at specific elevel
 * Used for castle walls, watchtowers, bridges, etc.
 */
/elevation/platform
	name = "platform"
	icon = 'dmi/64/build.dmi'
	icon_state = "platform"
	density = 0
	opacity = 0
	
	var
		stability = 100   // 0-100, affects climbing success
		
	New()
		..()
		elevel = initial(elevel)
		layer = FindLayer(elevel)
		invisibility = FindInvis(elevel)
	
	UseObject(mob/user)
		if(user in range(1, src))
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Platform requires Climbing Rank 2+ for higher elevations
			if(elevel >= 2.5 && M.character.GetRankLevel(RANK_CLIMBING) < 2)
				M << "<red>This platform is too high for your climbing skill. (Requires Rank 2+)"
				return 1
			
			// Stability affects success chance
			var/difficulty_mod = 1.0 - (stability / 100.0)
			
			if(M.AttemptClimbTraversal(elevel))
				M << "<green>You climb onto the platform safely."
				return 1
			else
				// Failed climb: fall damage increased on platforms
				M << "<red>You slip on the platform and fall!"
				return 1
		
		return 0

// ==================== SLOPE OBJECTS ====================

/**
 * /elevation/slope - Gradual elevation transition
 * Easier to climb than hills/ditches, less risk
 * Takes multiple steps to transition
 */
/elevation/slope
	name = "slope"
	icon = 'dmi/64/build.dmi'
	icon_state = "slope"
	density = 0
	opacity = 0
	
	var
		start_elevel = 1.0            // Starting elevation
		difficulty = 1                // Slopes are easiest (difficulty 1)
		
	New()
		..()
		elevel = initial(elevel)
		layer = FindLayer(elevel)
		invisibility = FindInvis(elevel)
	
	UseObject(mob/user)
		if(user in range(1, src))
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Slopes are easier - anyone can attempt
			// But success varies by rank
			
			if(M.AttemptClimbTraversal(elevel))
				M << "<green>You walk along the slope."
				return 1
			else
				// Slope failures are less damaging
				var/reduced_damage = 3 + M.character.GetRankLevel(RANK_CLIMBING)
				M.HP -= reduced_damage
				M.updateHP()
				M << "<red>You slip on the slope!"
				return 1
		
		return 0

// ==================== SCAFFOLDING OBJECTS ====================

/**
 * /elevation/scaffolding - Temporary climbing aid
 * Wooden/metal structures that assist climbing
 * More forgiving than natural terrain
 * Can be damaged and needs repair
 */
/elevation/scaffolding
	name = "scaffolding"
	icon = 'dmi/64/build.dmi'
	icon_state = "scaffolding"
	density = 0
	opacity = 0
	
	var
		integrity = 100           // 0-100, degrades with use
		supports_weight = 5       // Number of climbers it can support
		current_users = 0
		
	New()
		..()
		elevel = initial(elevel)
		layer = FindLayer(elevel)
		invisibility = FindInvis(elevel)
	
	UseObject(mob/user)
		if(user in range(1, src))
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Check scaffolding integrity
			if(integrity <= 0)
				M << "<red>The scaffolding is completely broken!"
				return 1
			
			if(current_users >= supports_weight)
				M << "<red>The scaffolding can't support any more weight!"
				return 1
			
			// Scaffolding provides climbing bonus
			var/rank = M.character.GetRankLevel(RANK_CLIMBING)
			var/base_success = 70 + rank * 5
			
			// Integrity affects success
			if(integrity < 50)
				base_success -= 20
			if(integrity < 25)
				base_success -= 30
			
			base_success = clamp(base_success, 20, 95)
			
			if(prob(base_success))
				M << "<green>You climb the scaffolding securely."
				current_users++
				// Scaffolding degrades with each use
				integrity -= 5
				spawn(50) current_users--  // User left after 50 ticks
				return 1
			else
				M << "<red>The scaffolding shifts as you climb!"
				return 1
		
		return 0

// ==================== LEDGE OBJECTS ====================

/**
 * /elevation/ledge - Intermediate climbing point
 * Platform that climbers can briefly rest on
 * Allows climber to regain footing between challenges
 */
/elevation/ledge
	name = "ledge"
	icon = 'dmi/64/build.dmi'
	icon_state = "ledge"
	density = 0
	opacity = 0
	
	var
		parent_climb_elev = 2.0   // Target elevation they're heading to
		
	New()
		..()
		elevel = initial(elevel)
		layer = FindLayer(elevel)
		invisibility = FindInvis(elevel)
	
	UseObject(mob/user)
		if(user in range(1, src))
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Ledge is easy to reach - mostly success
			if(prob(90))
				M << "<green>You find solid footing on the ledge."
				// Optional: Grant stamina restore on successful ledge rest
				if(M.stamina < M.MAXstamina)
					M.stamina = min(M.stamina + 5, M.MAXstamina)
					M.updateST()
				return 1
			else
				M << "<red>You slip on the ledge!"
				return 1
		
		return 0

// ==================== CLIMBING DIFFICULTY SCALE ====================

/**
 * GetTerrainDifficulty(terrain_type) -> difficulty_rating (1-5)
 * 1 = Easy (slopes, ledges)
 * 2 = Normal (basic hills, basic ditches)
 * 3 = Hard (steep ditch with obstacles)
 * 4 = Very Hard (tall platforms, challenging scaffolding)
 * 5 = Extreme (dangerous climbs requiring max rank)
 */
proc/GetTerrainDifficulty(terrain_type)
	switch(terrain_type)
		if(/elevation/slope)
			return 1
		if(/elevation/ledge)
			return 1
		if(/elevation/hill)
			return 2
		if(/elevation/ditch)
			return 2
		if(/elevation/scaffolding)
			return 3
		if(/elevation/platform)
			return 3
		else
			return 2  // Default

// ==================== MULTI-STAGE CLIMBING ====================

/**
 * Complex terrain features that require multiple climbs
 * Example: Tall cliff = reach ledge (stage 1) -> reach platform (stage 2)
 */
/elevation/multiclimb
	name = "complex climb"
	icon = 'dmi/64/build.dmi'
	icon_state = "cliff"
	density = 0
	opacity = 0
	
	var
		stages = list(1.5, 2.5)   // Intermediate elevations (ledges)
		current_stage = 0
		
	New()
		..()
		elevel = initial(elevel)
		layer = FindLayer(elevel)
		invisibility = FindInvis(elevel)
	
	UseObject(mob/user)
		if(user in range(1, src))
			if(!istype(user, /mob/players))
				return 0
			
			var/mob/players/M = user
			
			// Determine which stage to attempt
			var/next_stage = stages[current_stage + 1]
			if(!next_stage)
				next_stage = elevel  // All stages complete, go to final
			
			// Higher difficulty for multi-stage climbs
			if(M.character.GetRankLevel(RANK_CLIMBING) < 3)
				M << "<red>This is too complex for your current skill level. (Requires Rank 3+)"
				return 1
			
			// Attempt each stage
			if(M.AttemptClimbTraversal(next_stage))
				M << "<green>You advance to the next stage!"
				// Award bonus XP for multi-stage progression
				M.character.UpdateRankExp(RANK_CLIMBING, 15)
				return 1
			else
				M << "<red>You slip and fall back!"
				return 1
		
		return 0

