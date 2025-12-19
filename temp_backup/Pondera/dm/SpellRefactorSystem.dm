/// ============================================================================
/// SPELL REFACTOR SYSTEM
/// Unified spell casting architecture with plane-based lighting integration.
/// All spells, projectiles, and animations emit static plane lights for
/// nighttime visibility (no dynamic lighting - using established plane system).
///
/// Created: 12-11-25 1:00AM
/// ============================================================================

#define SPELL_PLANE_LIGHTING  2
#define SPELL_LIGHT_INTENSITY 0.8

/// ============================================================================
/// SPELL DATUM FOUNDATION
/// ============================================================================

/datum/spell
	var
		name = "Unknown Spell"
		description = ""
		mana_cost = 0
		cooldown = 0
		cast_time = 0
		range = 7
		targeting_mode = "single"
		damage_type = "fire"
		light_color = "#ffff00"
		light_radius = 3
		light_intensity = SPELL_LIGHT_INTENSITY
		last_cast_time = 0
		casting_player = null

/datum/spell/proc/CanCast(mob/player)
	if(world.time - last_cast_time < cooldown)
		player << "<span style='color: #ffb74d;'>Spell still on cooldown</span>"
		return FALSE
	return TRUE

/datum/spell/proc/Cast(mob/player, target)
	if(!CanCast(player))
		return FALSE
	
	casting_player = player
	
	switch(targeting_mode)
		if("single")
			return CastSingle(player, target)
		if("area")
			return CastArea(player, target)
		if("cone")
			return CastCone(player, target)
		if("line")
			return CastLine(player, target)
		if("self")
			return CastSelf(player)
	
	last_cast_time = world.time
	return TRUE

/datum/spell/proc/CastSingle(mob/player, atom/target)
	return TRUE

/datum/spell/proc/CastArea(mob/player, turf/center)
	return TRUE

/datum/spell/proc/CastCone(mob/player, dir_angle)
	return TRUE

/datum/spell/proc/CastLine(mob/player, dir_angle)
	return TRUE

/datum/spell/proc/CastSelf(mob/player)
	EmitSpellLight(player.loc, light_color, light_radius, light_intensity)
	return TRUE

/// ============================================================================
/// PLANE LIGHTING FOR SPELLS & PROJECTILES
/// ============================================================================

/datum/spell_light
	var
		origin_loc = null
		color = "#ffff00"
		radius = 3
		intensity = 0.8
		parent_spell = null
		active = TRUE

/datum/spell_light/proc/Update(x, y)
	if(origin_loc)
		if(ismob(origin_loc))
			x = origin_loc:x
			y = origin_loc:y
		else if(isturf(origin_loc))
			x = origin_loc:x
			y = origin_loc:y
	
	if(active)
		RedrawLight(x, y)

/datum/spell_light/proc/RedrawLight(x, y)
	for(var/dx = -radius; dx <= radius; dx++)
		for(var/dy = -radius; dy <= radius; dy++)
			var/turf/T = locate(x + dx, y + dy, origin_loc:z)
			if(T)
				if(!("spell_lights" in T.vars))
					T.vars["spell_lights"] = list()
				T.vars["spell_lights"] += src

/datum/spell_light/proc/Deactivate()
	active = FALSE
	if(origin_loc && isturf(origin_loc))
		var/turf/T = origin_loc
		if("spell_lights" in T.vars)
			var/list/lights = T.vars["spell_lights"]
			lights -= src

/// ============================================================================
/// PROJECTILE DATUM WITH PLANE LIGHTING
/// ============================================================================

/datum/projectile
	var
		start_loc = null
		target_loc = null
		owner = null
		spell_ref = null
		has_light = TRUE
		light_color = "#ffff00"
		light_radius = 2
		light_intensity = 0.8
		speed = 1
		range = 10
		traveled_distance = 0

/datum/projectile/proc/Fire(mob/player, turf/target, path)
	owner = player
	start_loc = player.loc
	target_loc = target
	
	if(has_light)
		var/datum/spell_light/proj_light = new /datum/spell_light()
		proj_light.color = light_color
		proj_light.radius = light_radius
		proj_light.intensity = light_intensity
		proj_light.origin_loc = player.loc
		proj_light.RedrawLight(player.loc:x, player.loc:y)
	
	spawn()
		Travel(path)

/datum/projectile/proc/Travel(list/path)
	for(var/turf/step in path)
		if(traveled_distance >= range)
			break
		
		if(has_light)
			for(var/dx = -light_radius; dx <= light_radius; dx++)
				for(var/dy = -light_radius; dy <= light_radius; dy++)
					var/turf/T = locate(step:x + dx, step:y + dy, step:z)
					if(T)
						if(!("spell_lights" in T.vars))
							T.vars["spell_lights"] = list()
		
		traveled_distance++
		sleep(speed)
	
	ImpactAtLocation(target_loc)

/datum/projectile/proc/ImpactAtLocation(turf/impact_loc)
	if(has_light && impact_loc)
		var/datum/spell_light/impact = new /datum/spell_light()
		impact.color = light_color
		impact.radius = light_radius + 1
		impact.intensity = light_intensity
		impact.origin_loc = impact_loc
		impact.RedrawLight(impact_loc:x, impact_loc:y)
		
		spawn(30)
			impact.Deactivate()

/// ============================================================================
/// ANIMATION OVERLAY WITH PLANE LIGHTING
/// ============================================================================

/obj/spell_animation
	var
		animation_icon = null
		animation_states = list()
		animation_speed = 1
		total_frames = 0
		emits_light = TRUE
		light_color = "#ffff00"
		light_radius = 2
		light_intensity = 0.8

/obj/spell_animation/New(loc, icon, states, speed)
	..(loc)
	animation_icon = icon
	animation_states = states
	animation_speed = speed
	total_frames = length(states)
	
	if(length(animation_states) > 0)
		src.icon = animation_icon
		src.icon_state = animation_states[1]
	
	if(emits_light)
		EmitAnimationLight()
	
	spawn()
		PlayAnimation()

/obj/spell_animation/proc/PlayAnimation()
	for(var/i = 1; i <= total_frames; i++)
		if(i <= length(animation_states))
			src.icon_state = animation_states[i]
		sleep(animation_speed)
	
	del(src)

/obj/spell_animation/proc/EmitAnimationLight()
	var/turf/anim_loc = src.loc
	if(isturf(anim_loc))
		for(var/dx = -light_radius; dx <= light_radius; dx++)
			for(var/dy = -light_radius; dy <= light_radius; dy++)
				var/turf/T = locate(anim_loc:x + dx, anim_loc:y + dy, anim_loc:z)
				if(T)
					if(!("spell_lights" in T.vars))
						T.vars["spell_lights"] = list()

/// ============================================================================
/// UTILITY FUNCTIONS
/// ============================================================================

/proc/EmitSpellLight(loc, color, radius, intensity)
	if(!isturf(loc) && !ismob(loc))
		return
	
	var/datum/spell_light/light = new /datum/spell_light()
	light.color = color
	light.radius = radius
	light.intensity = intensity
	light.origin_loc = loc
	
	if(isturf(loc))
		light.RedrawLight(loc:x, loc:y)
	else if(ismob(loc))
		light.RedrawLight(loc:x, loc:y)
	
	spawn(50)
		light.Deactivate()

/proc/CreateSpellAnimation(loc, icon, states, speed, light_color, light_radius)
	var/obj/spell_animation/anim = new /obj/spell_animation(loc, icon, states, speed)
	anim.light_color = light_color
	anim.light_radius = light_radius
	return anim

/proc/FireSpellProjectile(mob/owner, turf/target, icon, icon_state, spell_ref, light_color)
	var/datum/projectile/proj = new /datum/projectile()
	proj.owner = owner
	proj.spell_ref = spell_ref
	proj.light_color = light_color
	proj.Fire(owner, target, GetProjectilePath(owner.loc, target))

/proc/GetProjectilePath(turf/start, turf/end)
	var/list/path = list()
	var/x1 = start:x
	var/y1 = start:y
	var/x2 = end:x
	var/y2 = end:y
	
	var/dx = abs(x2 - x1)
	var/dy = abs(y2 - y1)
	var/sx = (x1 < x2) ? 1 : -1
	var/sy = (y1 < y2) ? 1 : -1
	var/err = dx - dy
	
	while(TRUE)
		path += locate(x1, y1, start:z)
		
		if(x1 == x2 && y1 == y2)
			break
		
		var/e2 = 2 * err
		if(e2 > -dy)
			err -= dy
			x1 += sx
		if(e2 < dx)
			err += dx
			y1 += sy
	
	return path

/// ============================================================================
/// END SPELL REFACTOR SYSTEM
/// ============================================================================
