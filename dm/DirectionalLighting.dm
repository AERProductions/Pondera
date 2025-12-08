// ============================================================================
// FILE: DirectionalLighting.dm
// PURPOSE: Plane-based directional lighting system with rotation support
// FEATURES:
//   - Directional light cones (forward, 120°, 180°, omnidirectional)
//   - Real-time rotation with player facing direction
//   - Per-frame position tracking (follows movement)
//   - Integration with lanterns, forges, spells, and effects
//   - Shadow support via dynamic lighting overlays
//   - Modular, easy to attach to any object
// ============================================================================

// ============================================================================
// DIRECTIONAL LIGHT MANAGER (Global)
// ============================================================================

var/DirectionalLighting/directional_lighting = new()

DirectionalLighting
	var
		list/active_lights = list()  // All active directional lights
		list/spell_lights = list()   // Spell-specific lights (for cleanup)
	
	proc
		/// Register active directional light
		register_light(obj/directional_cone/light)
			active_lights[light] = 1
		
		/// Unregister light (cleanup)
		unregister_light(obj/directional_cone/light)
			active_lights -= light
		
		/// Get all active lights on an atom
		get_lights_for(atom/a)
			var/list/result = list()
			for(var/obj/directional_cone/l in active_lights)
				if(l.owner == a)
					result += l
			return result
		
		/// Cleanup all spell lights
		cleanup_spell_lights()
			var/list/to_remove = list()
			for(var/obj/spell_light/l in spell_lights)
				if(l)
					l.cleanup()
					to_remove += l
			spell_lights -= to_remove
		
		/// Complete shutdown of all lights
		cleanup_all()
			// Remove all active lights
			var/list/lights_to_clean = list()
			for(var/obj/directional_cone/l in active_lights)
				if(l)
					lights_to_clean += l
			
			for(var/obj/directional_cone/l in lights_to_clean)
				if(l)
					l.cleanup()
			
			active_lights = list()
			
			// Cleanup spell lights
			cleanup_spell_lights()
			spell_lights = list()

// ============================================================================
// DIRECTIONAL CONE OBJECT (Plane-based, rotatable)
// ============================================================================

/*
Usage:
  var/obj/directional_cone/light = new(owner=src, type="forward", color="#FFAA00", intensity=0.8)
  light.start_tracking()  // Begins following owner
  light.stop_tracking()   // Stops following owner
  light.update_direction() // Manually update based on owner.dir
  light.cleanup()         // Removes light
*/

obj/directional_cone
	plane = LIGHTING_PLANE
	blend_mode = BLEND_ADD
	mouse_opacity = 0
	layer = EFFECTS_LAYER + 10
	appearance_flags = RESET_COLOR
	
	var
		atom/owner                    // Object this light is attached to
		image/cone_image = null       // The actual rendered cone
		
		// Light properties
		cone_type = "forward"         // "forward", "wide120", "wide180", "omnidirectional"
		light_color = "#FFFFFF"       // Light color (hex)
		intensity = 1.0               // Alpha (0.0-1.0)
		radius = 3                    // Size modifier
		
		// Position tracking
		tracking = 0                  // Whether we're updating each frame
		last_x = 0
		last_y = 0
		last_dir = NORTH
		
		// Shadow system
		shadow_enabled = 0            // Whether to cast shadows
		shadow_objects = list()       // List of shadow overlays
	
	New(atom/a, cone_type_param = "forward", hex = "#FFFFFF", intens = 1.0, rad = 3, shadows = 0)
		owner = a
		cone_type = cone_type_param
		light_color = hex
		intensity = intens
		radius = rad
		shadow_enabled = shadows
		shadow_objects = list()  // Initialize list
		
		if(!owner)
			CRASH("DirectionalCone requires owner atom")
		
		// Register with global manager
		directional_lighting.register_light(src)
		
		// Create initial cone
		_create_cone()
	
	Del()
		stop_tracking()
		cleanup()
	
	proc
		/// Internal: Create the cone image based on type
		_create_cone()
			// Determine icon state based on cone type
			var/icon_state = "cone_forward"
			
			switch(cone_type)
				if("forward")
					icon_state = "cone_forward"
				if("wide120")
					icon_state = "cone_120"
				if("wide180")
					icon_state = "cone_180"
				if("omnidirectional")
					icon_state = "cone_omni"
			
			// Create image with properties
			cone_image = image(icon='l256.dmi', icon_state=icon_state)
			cone_image.color = light_color
			cone_image.alpha = round(intensity * 255)
			cone_image.transform = matrix() * radius
			cone_image.plane = LIGHTING_PLANE
			cone_image.blend_mode = BLEND_ADD
			cone_image.appearance_flags = RESET_COLOR
			
			// Add to owner's overlays
			if(owner)
				owner.overlays += cone_image
		
		/// Start real-time tracking (updates every frame)
		start_tracking()
			if(tracking) return
			tracking = 1
			
			spawn _tracking_loop()
		
		/// Stop tracking
		stop_tracking()
			tracking = 0
		
		/// Internal: Main tracking loop
		_tracking_loop()
			set background = 1
			set waitfor = 0
			
			while(tracking && owner)
				// Verify owner still exists
				if(!owner || !owner.loc) 
					stop_tracking()
					return
				
				// Update position if moved
				if(owner.x != last_x || owner.y != last_y)
					last_x = owner.x
					last_y = owner.y
					_update_position()
				
				// Update direction if rotated
				if(owner.dir != last_dir)
					last_dir = owner.dir
					update_direction()
				
				sleep(1)  // Every tick
		
		/// Update cone position (follows owner)
		_update_position()
			if(!owner || !cone_image) return
			
			cone_image.loc = owner.loc
		
		/// Update cone rotation based on owner.dir
		update_direction()
			if(!owner || !cone_image) return
			
			// Apply rotation matrix based on direction
			var/rotation = 0
			
			switch(owner.dir)
				if(NORTH)
					rotation = 0
				if(SOUTH)
					rotation = 180
				if(EAST)
					rotation = 270
				if(WEST)
					rotation = 90
				if(NORTHEAST)
					rotation = 315
				if(NORTHWEST)
					rotation = 45
				if(SOUTHEAST)
					rotation = 225
				if(SOUTHWEST)
					rotation = 135
			
			// Update transform with rotation
			var/matrix/m = matrix()
			m = m.Translate(cone_image.pixel_x, cone_image.pixel_y)
			m = m.Scale(radius, radius)
			// Apply rotation in degrees using matrix multiplication
			var/rad = rotation * 0.0174533  // Convert degrees to radians
			var/cos_r = cos(rad)
			var/sin_r = sin(rad)
			var/matrix/rot = matrix(cos_r, sin_r, 0, -sin_r, cos_r, 0)
			m = m * rot
			m = m.Translate(-cone_image.pixel_x, -cone_image.pixel_y)
			
			cone_image.transform = m
		
		/// Change light intensity (0.0-1.0)
		set_intensity(new_intensity)
			intensity = new_intensity
			if(cone_image)
				cone_image.alpha = round(intensity * 255)
		
		/// Change light color
		set_color(hex_color)
			light_color = hex_color
			if(cone_image)
				cone_image.color = light_color
		
		/// Change cone type (requires refresh)
		set_cone_type(new_type)
			cone_type = new_type
			if(cone_image && owner)
				owner.overlays -= cone_image
				_create_cone()
				update_direction()
		
		/// Enable/disable shadow casting
		enable_shadows(enabled = 1)
			shadow_enabled = enabled
			if(enabled)
				_create_shadows()
			else
				_remove_shadows()
		
		/// Internal: Create shadow overlays around cone
		_create_shadows()
			if(!owner) return
			
			// Shadow system integration would go here
			// For now, placeholder for future shadow cone implementation
			// This would create darkened overlays in the cone direction
			// See ShadowLighting.dm for full implementation
		
		/// Remove shadow overlays
		_remove_shadows()
			for(var/shadow in shadow_objects)
				if(shadow)
					del shadow
			shadow_objects = list()
		
		/// Complete cleanup
		cleanup()
			stop_tracking()
			_remove_shadows()
			
			if(cone_image && owner)
				owner.overlays -= cone_image
				cone_image = null
			
			directional_lighting.unregister_light(src)

// ============================================================================
// LANTERN LIGHT SYSTEM (Equippable directional lighting)
// ============================================================================

/*
Integration with lanterns:
  In lantern item type:
    var/obj/directional_cone/light = null
    
    proc/light_lantern()
      if(!light)
        light = new /obj/directional_cone(usr, type="forward", color="#FFAA00", intensity=0.9, radius=3)
        light.start_tracking()
    
    proc/snuff_lantern()
      if(light)
        light.cleanup()
        light = null
*/

atom/movable
	var
		obj/directional_cone/equipped_light = null  // Current equipped light source
	
	proc
		/// Attach directional light (for lanterns, torches, etc.)
		attach_directional_light(cone_type = "forward", hex_color = "#FFFFFF", intens = 1.0, rad = 3, shadows = 0)
			// Remove existing light
			if(equipped_light)
				equipped_light.cleanup()
				equipped_light = null
			
			// Validate parameters
			if(rad < 1) rad = 1
			if(intens < 0) intens = 0
			if(intens > 1) intens = 1
			
			// Create new light
			equipped_light = new /obj/directional_cone(owner=src, cone_type=cone_type, hex=hex_color, intens=intens, rad=rad, shadows=shadows)
			if(equipped_light)
				equipped_light.start_tracking()
			
			return equipped_light
		
		/// Detach and cleanup directional light
		remove_directional_light()
			if(equipped_light)
				if(equipped_light.owner == src)  // Ensure it's ours
					equipped_light.cleanup()
				equipped_light = null
		
		/// Update equipped light color/intensity (for effects)
		update_equipped_light(new_color = null, new_intensity = null)
			if(!equipped_light) return
			
			if(new_color)
				equipped_light.set_color(new_color)
			if(new_intensity)
				equipped_light.set_intensity(new_intensity)

// ============================================================================
// SPELL LIGHTING SYSTEM (Temporary lights for spell effects)
// ============================================================================

obj/spell_light
	var
		obj/directional_cone/light = null
		duration = 0  // How long light lasts (0 = until cleanup)
		atom/source   // Spell or effect that created this
	
	New(atom/spell_source, cone_type = "omnidirectional", hex = "#FFFFFF", intens = 0.8, duration_ticks = 100)
		source = spell_source
		duration = duration_ticks
		
		// Create light at spell location
		light = new /obj/directional_cone(owner=spell_source, cone_type=cone_type, hex=hex, intens=intens, rad=2)
		
		// Register as spell light for cleanup
		directional_lighting.spell_lights += src
		
		// Auto-cleanup after duration
		if(duration > 0)
			spawn(duration)
				cleanup()
	
	proc
		cleanup()
			if(light)
				light.cleanup()
				light = null
			
			directional_lighting.spell_lights -= src
			del src

// ============================================================================
// INTEGRATION HELPERS (Copy-paste ready)
// ============================================================================

/*
HOW TO ADD DIRECTIONAL LIGHTING TO LANTERNS:
============================================

// In your lantern type definition:
obj/items/lanterns/brass_lantern
	var/obj/directional_cone/light = null
	
	proc/light_up()
		if(light) return  // Already lit
		
		// Attach forward-facing warm light
		light = new /obj/directional_cone(usr, type="forward", hex="#FFAA00", intens=0.9, rad=3.5, shadows=0)
		light.start_tracking()
		usr << "The lantern glows brightly!"
	
	proc/snuff()
		if(!light) return  // Not lit
		
		light.cleanup()
		light = null
		usr << "The lantern's light fades."


HOW TO ADD DIRECTIONAL LIGHTING TO SPELLS:
==========================================

// In your spell cast proc:
mob/players/proc/cast_spell(spell_name)
	var/spell_effect = new /obj/spells/heat(src.loc)
	
	// Add light effect if cast at night
	if(time_of_day == NIGHT)
		var/spell_light = new /obj/spell_light(spell_effect, cone_type="omnidirectional", hex="#FF6600", intens=0.8, duration_ticks=30)
		// Light lasts 30 ticks then auto-cleanup


HOW TO ADD DIRECTIONAL LIGHTING TO FORGES/OVENS:
================================================

// In forge New():
obj/forge/New(location)
	..()
	
	// Create omnidirectional light when burning
	if(burning)
		light = new /obj/directional_cone(owner=src, cone_type="omnidirectional", hex="#FF4400", intens=0.85, rad=4, shadows=0)


HOW TO USE IN PLAYER MOVEMENT:
==============================

// The light automatically rotates with player.dir
// Just call start_tracking() and it updates every frame:

mob/players/equip_lantern()
	var/obj/items/lantern/L = locate() in src.contents
	if(L)
		attach_directional_light(cone_type="forward", hex_color="#FFAA00", intens=0.9)
		src << "You light the lantern, casting forward light"

mob/players/unequip_lantern()
	remove_directional_light()
	src << "The lantern is now dark"
*/

// ============================================================================
// CONE ICON STATES
// ============================================================================

/*
The following icon states are expected in 'l256.dmi':

cone_forward:     256×256 forward-facing cone (0-90 degree cone)
cone_120:         256×256 wider cone (120 degree spread)
cone_180:         256×256 half-circle cone (180 degree spread)
cone_omni:        256×256 omnidirectional circle

If using different icon file, update icon path in _create_cone() proc.

Icon positioning: Center the light source at center of image (128,128)
                 Light extends outward from center

Blend mode: BLEND_ADD (additive blending creates natural light appearance)
*/

// ============================================================================
// SHADOW INTEGRATION (Optional)
// ============================================================================

/*
To add shadows to directional lights, uncomment and use ShadowLighting.dm:

In _create_shadows() proc:
  var/shadow = new /obj/shadow_cone(owner, type, intensity)
  shadow_objects += shadow

See ShadowLighting.dm for full shadow cone implementation
with per-turf darkness tracking and gradient falloff.
*/
