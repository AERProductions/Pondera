// ============================================================================
// FILE: dm/Fl_LightEmitters.dm
// PURPOSE: Specific light emitter implementations for common sources
// INCLUDES:
//   - Static emitters (torches, lanterns, forges, fires)
//   - Spell/ability lights (combat casting, special effects)
//   - Particle lights (weather, magical auras)
//   - Dynamic lights (lightning, explosions, environmental effects)
// ============================================================================

// ============================================================================
// STATIC EMITTER HELPERS (Objects that emit light)
// ============================================================================

proc
	/// Attach light to a torch/lantern/fire object
	proc/attach_torch_light(obj/torch, brightness = 1.2, range = 6, color = "#FFB347")
		if(!torch) return null
		
		var/datum/light_emitter/e = create_light_emitter(
			torch,
			"torch_[torch]",
			LIGHT_TYPE_OMNIDIRECTIONAL,
			color,
			brightness,
			range,
			0  // Infinite duration
		)
		return e
	
	/// Attach light to a forge/smith workspace
	proc/attach_forge_light(obj/forge, brightness = 1.8, range = 7, color = "#FF8C00")
		if(!forge) return null
		
		// Forge has pulsing effect (glowing embers)
		var/datum/light_emitter/e = create_light_emitter(
			forge,
			"forge_[forge]",
			LIGHT_TYPE_OMNIDIRECTIONAL,
			color,
			brightness,
			range,
			0  // Infinite
		)
		// e.pulse_rate = 0.5   // Pulse every ~0.5 seconds
		// e.pulse_amount = 0.3 // 30% brightness swing
		return e
	
	/// Attach light to fire/lava effects
	proc/attach_fire_light(atom/fire_object, brightness = 1.5, range = 5, color = "#FF4500")
		if(!fire_object) return null
		
		var/datum/light_emitter/e = create_light_emitter(
			fire_object,
			"fire_[fire_object]",
			LIGHT_TYPE_OMNIDIRECTIONAL,
			color,
			brightness,
			range,
			0  // Infinite
		)
		// e.pulse_rate = 0.3
		// e.pulse_amount = 0.4
		return e
	
	/// Attach light to luminous/magical object
	proc/attach_glow_light(atom/glowing_obj, color = "#87CEEB", brightness = 0.8, range = 3)
		if(!glowing_obj) return null
		
		return create_light_emitter(
			glowing_obj,
			"glow_[glowing_obj]",
			LIGHT_TYPE_OMNIDIRECTIONAL,
			color,
			brightness,
			range,
			0  // Infinite
		)

// ============================================================================
// SPELL/ABILITY LIGHT HELPERS
// ============================================================================

proc
	/// Create light for fire spell cast
	proc/emit_fireball_light(mob/caster, turf/impact_location, brightness = 1.8, range = 6, duration = 15)
		// Fire spells: warm orange/red
		create_spell_light(impact_location, "fireball", "#FF6B35", brightness, range, duration)
		// Also emit from caster during cast
		create_spell_light(caster, "fireball_cast", "#FF8C00", 0.8, 3, 5)
	
	/// Create light for ice spell cast
	proc/emit_ice_light(mob/caster, turf/target_location, brightness = 1.2, range = 5, duration = 10)
		// Ice spells: cool blue/cyan
		create_spell_light(target_location, "ice_burst", "#00BFFF", brightness, range, duration)
		create_spell_light(caster, "ice_cast", "#87CEEB", 0.6, 2, 3)
	
	/// Create light for lightning spell
	proc/emit_lightning_light(mob/caster, turf/impact_location, brightness = 2.0, range = 7, duration = 5)
		// Lightning: bright white/yellow
		create_spell_light(impact_location, "lightning", "#FFD700", brightness, range, duration)
		create_spell_light(caster, "lightning_cast", "#FFFF00", 1.2, 3, 3)
	
	/// Create light for healing spell
	proc/emit_heal_light(mob/caster, mob/target, brightness = 1.0, range = 4, duration = 8)
		// Healing: green/golden glow
		create_spell_light(target, "heal", "#90EE90", brightness, range, duration)
		create_spell_light(caster, "heal_cast", "#FFD700", 0.8, 2, 4)
	
	/// Create light for poison/acid spell
	proc/emit_poison_light(mob/caster, turf/target_location, brightness = 0.9, range = 4, duration = 12)
		// Poison: sickly purple/green
		create_spell_light(target_location, "poison", "#8B008B", brightness, range, duration)
		create_spell_light(caster, "poison_cast", "#9932CC", 0.6, 2, 4)
	
	/// Create light for generic damage spell
	proc/emit_damage_light(atom/source, turf/target_location, color = "#FF4500", brightness = 1.0, range = 4, duration = 6)
		create_spell_light(target_location, "damage", color, brightness, range, duration)
	
	/// Create light for utility ability (buff, shield, etc)
	proc/emit_buff_light(mob/user, brightness = 0.8, range = 3, duration = 10, color = "#FFD700")
		create_ability_light(user, "buff_aura", color, brightness, range, duration)

// ============================================================================
// PARTICLE/WEATHER LIGHT HELPERS
// ============================================================================

proc
	/// Add light to rain effect
	proc/emit_rain_light(duration = 600)
		// Rain: soft blue shimmer
		create_weather_light(locate(world.maxx/2, world.maxy/2, 1), "rain_glow", "#B0C4DE", 0.3, duration)
	
	/// Add light to snow effect
	proc/emit_snow_light(duration = 600)
		// Snow: cool white, slightly dimmer
		create_weather_light(locate(world.maxx/2, world.maxy/2, 1), "snow_shimmer", "#F0F8FF", 0.2, duration)
	
	/// Add light to fog effect
	proc/emit_fog_light(turf/center, radius = 10, brightness = 0.4, duration = 300)
		// Fog: very soft white/gray
		create_weather_light(center, "fog_mist", "#DCDCDC", brightness, duration)
	
	/// Add light to magical aura effect
	proc/emit_aura_light(atom/owner, aura_color, brightness = 0.9, radius = 5, duration = 0)
		// Persistent aura (spell effects, buffs)
		create_ability_light(owner, "aura", aura_color, brightness, radius, duration)

// ============================================================================
// DYNAMIC EFFECT LIGHT HELPERS
// ============================================================================

proc
	/// Lightning strike visibility light
	proc/emit_lightning_strike(turf/strike_location, brightness = 2.5, flash_duration = 2)
		// Very bright white flash
		create_weather_light(strike_location, "lightning_strike", "#FFFFFF", brightness, flash_duration)
	
	/// Explosion light flash
	proc/emit_explosion_light(turf/epicenter, color = "#FF6347", brightness = 2.0, radius = 8, duration = 3)
		create_weather_light(epicenter, "explosion", color, brightness, duration)
	
	/// Magical portal/gate light
	proc/emit_portal_light(atom/portal, color = "#9370DB", brightness = 1.3, radius = 4)
		create_ability_light(portal, "portal", color, brightness, radius, 0)  // Infinite
	
	/// Trap activation light (warning effect)
	proc/emit_trap_light(turf/trap_location, color = "#FF0000", brightness = 1.5, radius = 3, duration = 10)
		create_weather_light(trap_location, "trap_alert", color, brightness, duration)

// ============================================================================
// LIGHT EMITTER CLEANUP HELPERS
// ============================================================================

proc
	/// Remove all spell lights cast by a specific caster
	proc/cleanup_caster_lights(mob/caster)
		var/list/to_remove = list()
		for(var/datum/light_emitter/e in ACTIVE_SPELL_LIGHTS)
			if(e && e.owner == caster)
				to_remove += e
		
		for(var/datum/light_emitter/e in to_remove)
			e.cleanup()
	
	/// Remove all lights affecting a location
	proc/cleanup_location_lights(turf/T)
		var/list/to_remove = list()
		for(var/datum/light_emitter/e in ACTIVE_SPELL_LIGHTS)
			if(e && e.owner == T)
				to_remove += e
		
		for(var/datum/light_emitter/e in to_remove)
			e.cleanup()

// ============================================================================
// MISSILE/PROJECTILE LIGHT INTEGRATION
// ============================================================================

/* When missiles (spell projectiles) are created, they can now emit light:
   
   Example in Spells.dm:
   
   proc/FireballSpell()
       // ... existing spell code ...
       emit_fireball_light(usr, target_mob)
       missile(/obj/spells/fireball, usr, target_mob)
   
   Or for lingering AOE effects:
   
   var/duration = 15  // 15 ticks
   var/datum/light_emitter/explosion = emit_explosion_light(impact_turf, "#FF6347", 2.0, 8, duration)
*/

// ============================================================================
// DIRECTIONAL LIGHT (Integration with existing DirectionalLighting.dm)
// ============================================================================

proc
	/// Create directional light (cone, follows owner.dir)
	proc/create_directional_light(atom/owner, direction_type = "forward", color = "#FFAA00", brightness = 1.0, range = 5)
		// direction_type: "forward", "wide120", "wide180", "omnidirectional"
		// This integrates with existing DirectionalLighting.dm
		// The light emitter datum stores type info; rendering handled separately
		
		var/datum/light_emitter/e = create_light_emitter(
			owner,
			"directional_[owner]",
			LIGHT_TYPE_DIRECTIONAL,
			color,
			brightness,
			range,
			0  // Infinite
		)
		e.casts_shadow = 1  // Enable shadow casting
		return e
	
	/// Create shadow light (inverse of light - darkness cone)
	proc/create_shadow_light(atom/owner, shadow_type = "forward", darkness = 0.7, range = 4)
		// Integrate with ShadowLighting.dm
		// Darkness: 0.0 (no shadow) - 1.0 (full black)
		pass

// ============================================================================
// VISIBILITY MODIFIER HELPERS (Integration with elevation system)
// ============================================================================

proc
	/// Light affecting visibility (e.g., light revealing hidden enemies)
	proc/create_revelation_light(atom/source, reveal_range = 6, duration = 0)
		// Used for spells that pierce fog/darkness or grant sight
		var/datum/light_emitter/e = create_light_emitter(
			source,
			"reveal_[source]",
			LIGHT_TYPE_OMNIDIRECTIONAL,
			"#FFFFFF",
			0.5,
			reveal_range,
			duration
		)
		e.affects_visibility = 1
		return e
