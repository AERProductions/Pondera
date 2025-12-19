// ============================================================================
// FILE: libs/Fl_LightEmitters.dm
// PURPOSE: Helper procedures for creating common light emitter effects
// INCLUDES:
//   - Spell lights (fireball, ice, lightning, heal, poison)
//   - Ability lights (buffs, shields)
//   - Weather lights (rain, snow, fog, lightning)
//   - Object lights (torches, forges, etc)
//   - Dynamic effects (explosions, portals, traps)
// ============================================================================

// ============================================================================
// STATIC OBJECT LIGHTS
// ============================================================================

proc/attach_torch_light(atom/obj, intensity=1.0)
	return create_light_emitter(obj, 8, intensity, "#FFAA66", 6, 0)

proc/attach_fire_light(atom/obj, intensity=1.2)
	return create_light_emitter(obj, 8, intensity, "#FF6633", 7, 0)

proc/attach_forge_light(atom/obj, intensity=1.5)
	return create_light_emitter(obj, 8, intensity, "#FFDD44", 8, 0)

proc/attach_lantern_light(atom/obj, intensity=1.1)
	return create_light_emitter(obj, 8, intensity, "#FFFFAA", 7, 0)

proc/attach_magical_light(atom/obj, color="#7777FF", intensity=1.0)
	return create_light_emitter(obj, 8, intensity, color, 6, 0)

// ============================================================================
// SPELL EFFECT LIGHTS
// ============================================================================

proc/emit_fireball_light(atom/caster, duration=30)
	var/datum/light_emitter/E = create_light_emitter(caster, 6, 1.5, "#FF4400", 10, duration)
	E.pulsing = 1
	E.pulse_min = 1.0
	E.pulse_max = 1.8
	E.pulse_speed = 2
	return E

proc/emit_ice_light(atom/caster, duration=25)
	var/datum/light_emitter/E = create_light_emitter(caster, 6, 1.2, "#4488FF", 8, duration)
	E.pulsing = 1
	E.pulse_min = 0.8
	E.pulse_max = 1.4
	E.pulse_speed = 3
	return E

proc/emit_lightning_light(atom/caster, duration=10)
	var/datum/light_emitter/E = create_light_emitter(caster, 6, 2.0, "#FFFF00", 12, duration)
	E.pulsing = 1
	E.pulse_min = 1.5
	E.pulse_max = 2.0
	E.pulse_speed = 1
	return E

proc/emit_heal_light(atom/caster, duration=20)
	var/datum/light_emitter/E = create_light_emitter(caster, 6, 1.0, "#00FF88", 8, duration)
	E.pulsing = 1
	E.pulse_min = 0.7
	E.pulse_max = 1.2
	E.pulse_speed = 4
	return E

proc/emit_poison_light(atom/caster, duration=35)
	var/datum/light_emitter/E = create_light_emitter(caster, 6, 0.9, "#66FF00", 7, duration)
	E.pulsing = 1
	E.pulse_min = 0.6
	E.pulse_max = 1.0
	E.pulse_speed = 5
	return E

proc/emit_shadow_light(atom/caster, duration=40)
	var/datum/light_emitter/E = create_light_emitter(caster, 6, 0.3, "#220000", 6, duration)
	E.intensity = -0.5  // Negative intensity = darkness
	return E

// ============================================================================
// ABILITY LIGHTS
// ============================================================================

proc/emit_buff_light(atom/target, color="#00FFFF", intensity=0.8, duration=50)
	var/datum/light_emitter/E = create_light_emitter(target, 6, intensity, color, 5, duration)
	E.pulsing = 1
	E.pulse_min = 0.6
	E.pulse_max = 1.0
	E.pulse_speed = 6
	return E

proc/emit_shield_light(atom/target, intensity=1.0, duration=60)
	return emit_buff_light(target, "#0088FF", intensity, duration)

proc/emit_stealth_light(atom/target, intensity=-0.3, duration=40)
	return create_light_emitter(target, 6, intensity, "#0000AA", 4, duration)

proc/create_ability_light(atom/source, color="#FFFFFF", intensity=1.0, range=8, duration=30)
	return create_light_emitter(source, 6, intensity, color, range, duration)

// ============================================================================
// WEATHER LIGHTS
// ============================================================================

proc/emit_rain_light(atom/weather_obj, intensity=0.2)
	var/datum/light_emitter/E = create_light_emitter(weather_obj, 7, intensity, "#AAAACC", 15, 0)
	E.pulsing = 1
	E.pulse_min = 0.15
	E.pulse_max = 0.3
	E.pulse_speed = 8
	return E

proc/emit_snow_light(atom/weather_obj, intensity=0.3)
	var/datum/light_emitter/E = create_light_emitter(weather_obj, 7, intensity, "#FFFFFF", 12, 0)
	E.pulsing = 1
	E.pulse_min = 0.2
	E.pulse_max = 0.4
	E.pulse_speed = 10
	return E

proc/emit_fog_light(atom/weather_obj, intensity=0.15)
	var/datum/light_emitter/E = create_light_emitter(weather_obj, 7, intensity, "#CCCCCC", 10, 0)
	E.pulsing = 1
	E.pulse_min = 0.1
	E.pulse_max = 0.2
	E.pulse_speed = 12
	return E

proc/emit_storm_light(atom/weather_obj, intensity=0.4)
	var/datum/light_emitter/E = create_light_emitter(weather_obj, 7, intensity, "#888899", 18, 0)
	E.pulsing = 1
	E.pulse_min = 0.3
	E.pulse_max = 0.6
	E.pulse_speed = 4
	return E

proc/emit_weather_lightning(atom/strike_point, intensity=1.8, duration=5)
	var/datum/light_emitter/E = create_light_emitter(strike_point, 7, intensity, "#FFFF00", 20, duration)
	E.pulsing = 0
	return E

// ============================================================================
// DYNAMIC EFFECT LIGHTS
// ============================================================================

proc/emit_explosion_light(turf/T, intensity=2.0, range=15, duration=15)
	var/datum/light_emitter/E = create_light_emitter(T, 6, intensity, "#FF8800", range, duration)
	E.pulsing = 1
	E.pulse_min = 1.5
	E.pulse_max = 2.0
	E.pulse_speed = 2
	return E

proc/emit_portal_light(atom/portal, color="#FF00FF", intensity=1.3, duration=0)
	var/datum/light_emitter/E = create_light_emitter(portal, 6, intensity, color, 8, duration)
	E.pulsing = 1
	E.pulse_min = 1.0
	E.pulse_max = 1.5
	E.pulse_speed = 3
	return E

proc/emit_trap_light(atom/trap, color="#FF0000", intensity=0.7, duration=0)
	var/datum/light_emitter/E = create_light_emitter(trap, 6, intensity, color, 5, duration)
	E.pulsing = 1
	E.pulse_min = 0.5
	E.pulse_max = 0.8
	E.pulse_speed = 2
	return E

proc/emit_ritual_light(atom/ritual_site, color="#FFAA00", intensity=1.2, duration=0)
	var/datum/light_emitter/E = create_light_emitter(ritual_site, 6, intensity, color, 9, duration)
	E.pulsing = 1
	E.pulse_min = 0.8
	E.pulse_max = 1.4
	E.pulse_speed = 5
	return E

// ============================================================================
// CLEANUP HELPERS
// ============================================================================

proc/cleanup_spell_lights_from_caster(atom/caster)
	for(var/datum/light_emitter/E in ACTIVE_SPELL_LIGHTS)
		if(E.origin == caster)
			E.cleanup()

proc/cleanup_spell_lights_at_location(turf/T)
	for(var/datum/light_emitter/E in ACTIVE_SPELL_LIGHTS)
		if(E.origin && E.origin.loc == T)
			E.cleanup()

proc/cleanup_weather_lights()
	for(var/datum/light_emitter/E in ACTIVE_WEATHER_LIGHTS)
		E.cleanup()

// ============================================================================
// BATCH OPERATIONS
// ============================================================================

proc/create_ambient_lighting_field(list/turfs, color="#FFFFFF", intensity=0.5, duration=100)
	var/list/emitters = list()
	for(var/turf/T in turfs)
		var/datum/light_emitter/E = create_light_emitter(T, 6, intensity, color, 4, duration)
		emitters += E
	return emitters

proc/update_all_spell_light_intensity(multiplier)
	for(var/datum/light_emitter/E in ACTIVE_SPELL_LIGHTS)
		E.intensity *= multiplier

proc/update_all_weather_light_intensity(multiplier)
	for(var/datum/light_emitter/E in ACTIVE_WEATHER_LIGHTS)
		E.intensity *= multiplier
