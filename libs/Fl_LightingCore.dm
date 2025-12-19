// ============================================================================
// FILE: libs/Fl_LightingCore.dm
// PURPOSE: Core unified lighting system - Registry, API, and global state
// ARCHITECTURE:
//   - Unified registry (ACTIVE_LIGHT_EMITTERS) for all active lights
//   - datum/light_emitter base class with expiration, pulsing, falloff
//   - Background update loop for cleanup and effects
//   - Global lighting state (day/night colors, ambient intensity)
// ============================================================================

// Light emission types (defined in !defines.dm)
// #define LIGHT_TYPE_POINT              1
// #define LIGHT_TYPE_DIRECTIONAL        2
// #define LIGHT_TYPE_CONE               3
// #define LIGHT_TYPE_OMNIDIRECTIONAL    4
// (Note: LIGHT_TYPE_SPELL=6 and LIGHT_TYPE_WEATHER=7 also defined globally)

// ============================================================================
// GLOBAL STATE & REGISTRY
// ============================================================================

var/global
	list/ACTIVE_LIGHT_EMITTERS = list()        // All active light emitters
	list/ACTIVE_SPELL_LIGHTS = list()          // Spell-specific lights
	list/ACTIVE_WEATHER_LIGHTS = list()        // Weather system lights
	list/ACTIVE_OBJECT_LIGHTS = list()         // Static object lights (torches, lamps)
	
	GLOBAL_LIGHT_INTENSITY = 1.0               // Multiplier for all lights (0.0-2.0)
	GLOBAL_LIGHT_COLOR = "#FFFFFF"             // Base light color
	GLOBAL_AMBIENT_DARKNESS = 0.0              // Darkness level (0.0-1.0)

// ============================================================================
// LIGHT EMITTER DATUM CLASS
// ============================================================================

datum/light_emitter
	var
		// Core properties
		atom/origin                             // Object emitting light
		light_id                                // Unique identifier
		light_type = LIGHT_TYPE_POINT           // Type of light
		
		// Visual properties
		color = "#FFFFFF"                       // Light color
		intensity = 1.0                         // Light brightness (0.0-2.0)
		range = 8                               // Light radius in tiles
		falloff = 1.0                           // Brightness decay (1.0=linear, >1=sharp)
		
		// Animation properties
		pulse_rate = 0                          // 0=steady, >0=cycles/minute
		pulse_amount = 0.5                      // 0.0-1.0 intensity swing
		
		// Pulsing animation (alternative to pulse_rate/pulse_amount)
		pulsing = 0                             // Enable pulsing animation?
		pulse_min = 0.5                         // Minimum intensity during pulse
		pulse_max = 1.5                         // Maximum intensity during pulse
		pulse_speed = 1                         // Pulse speed (cycles per tick)
		
		// Lifecycle
		duration = 0                            // Duration in ticks (0 = infinite)
		created_tick = 0                        // When light was created
		active = 1                              // Is light enabled?
		
		// Flags
		casts_shadow = 0                        // Does this emit shadow cones?
		affects_visibility = 0                  // Does this change player visibility?
		direction = SOUTH                       // Light direction (for directional lights)
		angle = 45                              // Light cone angle (for cone/spotlight)
	
	New(atom/owner_atom = null, light_id_str = null, type_const = LIGHT_TYPE_POINT, color_hex = "#FFFFFF", intensity_val = 1.0, range_tiles = 8, duration_ticks = 0)
		origin = owner_atom
		light_id = light_id_str
		light_type = type_const
		color = color_hex
		intensity = intensity_val
		range = range_tiles
		duration = duration_ticks
		created_tick = world.time
		active = 1

	proc/is_expired()
		if(duration <= 0) return 0              // Infinite duration
		return (world.time - created_tick) >= duration

	proc/get_current_intensity()
		if(!active) return 0
		if(is_expired()) return 0
		
		var/base_intensity = intensity * GLOBAL_LIGHT_INTENSITY
		if(pulse_rate <= 0) return base_intensity
		
		// Smooth pulse animation using sine wave
		var/pulse_cycle = ((world.time / pulse_rate) % 1.0)
		var/pulse_offset = sin(pulse_cycle * 2 * PI) * pulse_amount
		return base_intensity * (1.0 + pulse_offset)

	proc/get_current_color()
		if(!active) return GLOBAL_LIGHT_COLOR
		if(is_expired()) return GLOBAL_LIGHT_COLOR
		return color

	proc/update()
		if(!origin) return
		if(is_expired())
			cleanup()
			return
		
		// Position tracking handled by overlay system
		// Rotation for directional lights
		if(light_type == LIGHT_TYPE_DIRECTIONAL || light_type == LIGHT_TYPE_CONE)
			if(origin.dir)
				// Integration point for DirectionalLighting.update_direction()
				pass

	proc/cleanup()
		active = 0
		ACTIVE_LIGHT_EMITTERS -= src
		if(light_type == LIGHT_TYPE_CONE || light_type == 5)
			ACTIVE_SPELL_LIGHTS -= src
		if(light_type == LIGHT_TYPE_OMNIDIRECTIONAL)
			ACTIVE_WEATHER_LIGHTS -= src
		else if(light_type == LIGHT_TYPE_POINT)
			ACTIVE_OBJECT_LIGHTS -= src
		origin = null

// ============================================================================
// UNIFIED LIGHTING INITIALIZATION
// ============================================================================

proc/InitUnifiedLighting()
	if(!world_initialization_complete)
		world.log << "ERROR: InitUnifiedLighting called before world ready"
		return
	
	ACTIVE_LIGHT_EMITTERS = list()
	ACTIVE_SPELL_LIGHTS = list()
	ACTIVE_WEATHER_LIGHTS = list()
	ACTIVE_OBJECT_LIGHTS = list()
	GLOBAL_LIGHT_INTENSITY = 1.0
	GLOBAL_LIGHT_COLOR = "#FFFFFF"
	GLOBAL_AMBIENT_DARKNESS = 0.0

// ============================================================================
// LIGHT EMITTER FACTORY
// ============================================================================

// ============================================================================
// NOTE: Light emitter creation functions (create_light_emitter, create_spell_light,
// create_ability_light, create_weather_light) are in Fl_LightEmitters.dm
// This file provides registry management and terrain/time-of-day integration
// ============================================================================

// ============================================================================
// GLOBAL LIGHTING CONTROL
// ============================================================================

proc/set_global_lighting(intensity = 1.0, color_hex = "#FFFFFF", darkness = 0.0)
	GLOBAL_LIGHT_INTENSITY = clamp(intensity, 0.0, 2.0)
	GLOBAL_LIGHT_COLOR = color_hex
	GLOBAL_AMBIENT_DARKNESS = clamp(darkness, 0.0, 1.0)
	
	// Update all active emitters with new ambient
	for(var/datum/light_emitter/e in ACTIVE_LIGHT_EMITTERS)
		if(e && e.active) e.update()

proc/set_area_lighting(area/A, darkness_modifier = 0)
	// darkness_modifier: negative = brighter, positive = darker
	// Apply as zone-based override
	pass

proc/get_lighting_at(turf/T)
	// Returns: list("intensity" = X, "color" = Y, "sources" = [])
	var/list/result = list()
	result["intensity"] = GLOBAL_LIGHT_INTENSITY
	result["color"] = GLOBAL_LIGHT_COLOR
	result["sources"] = list()
	
	// Check all emitters affecting this turf
	for(var/datum/light_emitter/e in ACTIVE_LIGHT_EMITTERS)
		if(!e || !e.active) continue
		
		var/distance = get_dist(T, e.origin)
		if(distance <= e.range)
			var/falloff_intensity = e.get_current_intensity() / (1.0 + distance * e.falloff)
			if(falloff_intensity > 0.01)
				result["sources"] += e
	
	return result

proc/get_lights_on(atom/A)
	var/list/lights = list()
	for(var/datum/light_emitter/e in ACTIVE_LIGHT_EMITTERS)
		if(!e || !e.active) continue
		if(e.origin == A)
			lights += e
	return lights

proc/remove_light_emitter(datum/light_emitter/e)
	if(!e) return
	e.cleanup()

proc/cleanup_expired_lights()
	for(var/datum/light_emitter/E in ACTIVE_LIGHT_EMITTERS)
		if(E.is_expired())
			E.cleanup()

proc/cleanup_lights_at_turf(turf/T)
	for(var/datum/light_emitter/E in ACTIVE_LIGHT_EMITTERS)
		if(E.origin && E.origin.loc == T)
			E.cleanup()

proc/cleanup_lights_from_object(atom/obj)
	for(var/datum/light_emitter/E in ACTIVE_LIGHT_EMITTERS)
		if(E.origin == obj)
			E.cleanup()

proc/shutdown_unified_lighting()
	var/list/to_remove = list()
	for(var/datum/light_emitter/e in ACTIVE_LIGHT_EMITTERS)
		if(e) to_remove += e
	
	for(var/datum/light_emitter/e in to_remove)
		e.cleanup()
	
	ACTIVE_LIGHT_EMITTERS = list()
	ACTIVE_SPELL_LIGHTS = list()
	ACTIVE_WEATHER_LIGHTS = list()
	ACTIVE_OBJECT_LIGHTS = list()

// ============================================================================
// REGISTRY QUERIES
// ============================================================================

proc/get_active_light_count()
	return ACTIVE_LIGHT_EMITTERS.len

proc/get_spell_light_count()
	return ACTIVE_SPELL_LIGHTS.len

proc/get_weather_light_count()
	return ACTIVE_WEATHER_LIGHTS.len

proc/get_object_light_count()
	return ACTIVE_OBJECT_LIGHTS.len

proc/get_all_active_lights()
	return ACTIVE_LIGHT_EMITTERS.Copy()

// ============================================================================
// PROCEDURAL TERRAIN INTEGRATION
// ============================================================================

proc/apply_terrain_lighting(var/turf/T, var/biome_type)
	/// Apply biome-specific lighting to terrain
	/// Biome types: "temperate", "arctic", "desert", "swamp", "volcanic"
	
	if(!T || !biome_type) return
	
	switch(biome_type)
		if("temperate")
			// Forest-like ambient: soft greens and shadows
			T.lighting_color = "#4a7c3b"  // Forest green
			T.lighting_intensity = 0.75
		
		if("arctic")
			// Bright, cold reflective lighting
			T.lighting_color = "#b0d5ff"  // Icy blue
			T.lighting_intensity = 0.9
		
		if("desert")
			// Hot, harsh lighting with golden tint
			T.lighting_color = "#ffcc66"  // Desert gold
			T.lighting_intensity = 0.85
		
		if("swamp")
			// Murky, dim lighting
			T.lighting_color = "#556633"  // Swamp brown
			T.lighting_intensity = 0.6
		
		if("volcanic")
			// Intense heat, reddish glow
			T.lighting_color = "#ff6633"  // Lava orange
			T.lighting_intensity = 0.8

proc/apply_time_of_day_lighting(var/time_percent)
	/// Adjust global lighting based on time of day (0-1 range)
	/// Used by time system during day/night cycle
	/// Note: Implementation delegated to lighting emitter updates
	return TRUE

// ============================================================================
// CLIENT LIGHTING SETUP
// ============================================================================

client
	var
		// Track which lights are visible to this player
		list/visible_lights = list()
	
	proc
		/// Initialize client lighting setup on login
		setup_lighting_plane()
			// Placeholder for client-side lighting plane initialization
			// Will be called when lighting system integrates with rendering
			return TRUE

// ============================================================================
// DEBUG & DIAGNOSTICS
// ============================================================================

proc/debug_lighting_state()
	var/msg = "=== LIGHTING SYSTEM STATE ===\n"
	msg += "Active Emitters: [ACTIVE_LIGHT_EMITTERS.len]\n"
	msg += "  - Spell Lights: [ACTIVE_SPELL_LIGHTS.len]\n"
	msg += "  - Weather Lights: [ACTIVE_WEATHER_LIGHTS.len]\n"
	msg += "  - Object Lights: [ACTIVE_OBJECT_LIGHTS.len]\n"
	msg += "Global Intensity: [GLOBAL_LIGHT_INTENSITY]\n"
	msg += "Global Color: [GLOBAL_LIGHT_COLOR]\n"
	msg += "Ambient Darkness: [GLOBAL_AMBIENT_DARKNESS]\n"
	return msg
// ============================================================================
// LIGHT EMITTER FACTORY
// ============================================================================

proc/create_light_emitter(atom/origin, light_type_const, intensity=1.0, color="#FFFFFF", range=8, duration=0)
	/// Factory proc to create and register a new light emitter
	/// Handles both legacy (8/SPELL/WEATHER = 1/2/3) and new (LIGHT_TYPE_* = 6/7/8) constants
	/// Args: origin (light source), light_type, intensity, color_hex, range_tiles, duration_ticks
	/// Returns: datum/light_emitter
	
	var/datum/light_emitter/E = new(origin, null, light_type_const, color, intensity, range, duration)
	
	// Add to global registry
	ACTIVE_LIGHT_EMITTERS += E
	
	// Add to type-specific registry based on light type
	// Support both legacy (1,2,3) and new (6,7,8) constants
	switch(light_type_const)
		if(LIGHT_TYPE_SPELL, 6, 6, 2)  // 6 legacy or new
			ACTIVE_SPELL_LIGHTS += E
		if(LIGHT_TYPE_WEATHER, 7, 7, 3)  // 7 legacy or new
			ACTIVE_WEATHER_LIGHTS += E
		if(LIGHT_TYPE_OBJECT, 8, 8, 1)  // 8 legacy or new
			ACTIVE_OBJECT_LIGHTS += E
	
	// Log creation for debug (disabled by default)
	// world.log << "LIGHT CREATED: type=[light_type_const] at [origin] intensity=[intensity] color=[color]"
	
	return E
