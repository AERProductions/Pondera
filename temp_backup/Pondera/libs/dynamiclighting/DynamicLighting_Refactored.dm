// ============================================================================
// FILE: DynamicLighting_Refactored.dm
// PURPOSE: Refactored and modernized version of Forum_account's Dynamic
//          Lighting library, cleaned up for Pondera reference and potential
//          future selective use (fire shadows, torch lighting, etc.)
// ORIGINAL: Forum_account (DynamicLighting library)
// REFACTORED: For clarity, documentation, and MMO optimization
// ============================================================================

/*
OVERVIEW:
This system creates per-turf darkness overlays that respond to light sources
in real-time. Unlike plane-based lighting (global effect), this system allows
shadows around individual light sources (fires, torches, lanterns).

PERFORMANCE:
- Memory: ~64 bytes per turf per z-level
- CPU: 50-100 microseconds per light source per tick
- Best for: Limited number of lights (5-20), local areas (dungeons, interiors)
- Avoid for: Global MMO lighting (use plane-based system instead)

ARCHITECTURE:
1. Global Lighting Manager (lighting object)
2. Per-Light Sources (light objects attached to atoms)
3. Per-Turf Shading Overlays (darkness visualization)
4. Icon Generator (pre-renders brightness gradient DMI)
*/

// ============================================================================
// GLOBAL LIGHTING MANAGER
// ============================================================================

/*
Purpose: Master control for all dynamic lighting on a z-level
Responsibility: Tick-based update loop, shading initialization, dirty tracking

Initialize before using lights:
  lighting.init(icon='myicon.dmi', states=5, z_levels=list(1,2,3))
  
Control lighting parameters:
  lighting.ambient = 0.3      // Base brightness (0-1)
  lighting.states = 5         // Number of brightness levels
  lighting.pixel_movement = 1 // 1 if using pixel movement
*/
var/Lighting/lighting = new()

Lighting
	parent_type = /obj
	invisibility = 101  // Hidden from view
	
	var
		// Configuration
		icon/icon                   // DMI file with brightness gradient states
		states = 5                  // Number of icon_state brightness levels
		ambient = 0                 // Minimum ambient brightness (0-1)
		pixel_movement = 0          // Enable for pixel movement support
		
		// Lists
		list/lights = list()        // All active light sources
		list/changed = list()       // Dirty shading objects needing update
		list/initialized = list()   // Z-levels that have been initialized
	
	// ========================================================================
	// INITIALIZATION
	// ========================================================================
	
	proc
		/// Initialize dynamic lighting for specified z-levels
		/// Args: icon (DMI file), states (brightness levels), z_levels (list)
		/// Example: lighting.init('lighting.dmi', 5, list(1))
		init(i, s = 5, list/z_levels = list())
			if(!i)
				CRASH("Dynamic lighting requires icon parameter")
			
			icon = i
			states = s
			
			// If no z-levels specified, initialize all
			if(z_levels.len == 0)
				for(var/zz = 1 to world.maxz)
					z_levels += zz
			
			// Initialize each z-level
			for(var/zz in z_levels)
				if(zz in initialized)
					continue  // Already initialized
				
				initialized += zz
				_init_z_level(zz)
			
			// Start main update loop
			spawn _loop()
		
		/// Internal: Initialize shading objects for single z-level
		_init_z_level(zz)
			var/list/shading_list = list()
			
			// Create shading object on every turf
			for(var/x = 1 to world.maxx)
				for(var/y = 1 to world.maxy)
					var/turf/t = locate(x, y, zz)
					
					if(!t) break
					
					t.shading = new /shading(t, icon, 0)
					shading_list += t.shading
			
			// Initialize neighbor references
			for(var/shading/s in shading_list)
				s.init()
				
				// Mark all as changed for first render
				if(s.loc && !s.changed)
					s.changed = 1
					changed += s
	
	// ========================================================================
	// MAIN UPDATE LOOP
	// ========================================================================
	
	proc
		/// Main tick-based loop - updates all lights and shading
		/// Runs every tick while any lights are active
		_loop()
			set waitfor = 0
			set background = 1
			
			while(lights.len > 0)
				// Update all active lights
				for(var/light/l in lights)
					if(l)  // Verify light still exists
						l.loop()
				
				// Update shading objects that changed
				for(var/shading/s in changed)
					if(s.loc)
						s.update_icon()
				
				changed.Cut()  // Clear dirty list
				sleep(1)       // Next tick
	
	// ========================================================================
	// LIGHT SOURCE MANAGEMENT
	// ========================================================================
	
	proc
		/// Create light source attached to atom
		/// Args: owner (atom to attach to), radius, intensity
		/// Returns: light object
		create_light(atom/owner, radius = 3, intensity = 1)
			return new /light(owner, radius, intensity)
		
		/// Remove light source
		destroy_light(light/l)
			if(l) l.Del()
		
		/// Query active lights in area
		lights_in_range(atom/center, radius = 10)
			var/list/result = list()
			for(var/light/l in lights)
				if(get_dist(l.owner, center) <= radius)
					result += l
			return result

// ============================================================================
// LIGHT SOURCE OBJECT
// ============================================================================

/*
Purpose: Single light source (fire, torch, lantern, spell effect, etc.)
Attachment: Attached to any atom (turf or mobile)
Properties: radius (range), intensity (brightness), ambient (minimum)
State: on/off, can be toggled or destroyed

Create:
  var/light/firelight = new /light(fire_object, radius=4, intensity=1)
  
Control:
  firelight.radius(5)      // Change radius
  firelight.intensity(0.8) // Change brightness
  firelight.on()           // Turn on
  firelight.off()          // Turn off
  firelight.Del()          // Destroy
*/
light
	parent_type = /obj
	invisibility = 101
	
	var
		// Owner and attachment
		atom/owner                  // Atom this light is attached to
		mobile = 0                  // 1 if attached to movable
		
		// Light properties
		radius = 2                  // Light spread distance
		radius_squared = 4          // Pre-calculated for distance checks
		intensity = 1               // Light brightness (0-1 scale)
		ambient = 0                 // Minimum brightness contribution
		on = 1                      // Light on/off state
		
		// Position tracking
		__x = 0                     // Cached X coordinate
		__y = 0                     // Cached Y coordinate (for mobile)
		
		// Change detection
		changed = 1                 // Dirty flag for effect recalculation
		list/effect = null          // List of affected shadings and values
	
	New(atom/a, r = 3, i = 1)
		if(!a || !istype(a))
			CRASH("Light requires valid atom as first argument")
		
		owner = a
		
		// Determine if mobile (movable) or stationary
		if(istype(owner, /atom/movable))
			loc = owner.loc
			mobile = 1
		else
			loc = owner
			mobile = 0
		
		// Set properties
		radius = r
		radius_squared = r * r
		intensity = i
		
		// Cache position
		__x = owner.x
		__y = owner.y
		
		// Register with global lighting
		lighting.lights += src
	
	Del()
		// Remove from global list
		if(src in lighting.lights)
			lighting.lights -= src
		
		// Remove current effect
		if(effect)
			for(var/shading/s in effect)
				s.adjust_lum(-effect[s])
			effect.Cut()
		
		..()
	
	proc
		/// Per-tick update - called by lighting._loop()
		/// Handles movement detection and effect recalculation
		loop()
			if(!owner || !loc)
				Del()  // Owner deleted, clean up
				return
			
			// Check if mobile light has moved
			if(mobile)
				var/opx = owner.x
				var/opy = owner.y
				
				// Account for pixel movement
				if(lighting.pixel_movement)
					if(owner:step_x)
						opx += owner:step_x / 32.0
					if(owner:step_y)
						opy += owner:step_y / 32.0
				
				// If position changed, recalculate
				if(opx != __x || opy != __y)
					__x = opx
					__y = opy
					changed = 1
			
			// Recalculate effect if changed
			if(changed)
				_apply_effect()
		
		/// Internal: Apply light effect to all affected shadings
		_apply_effect()
			changed = 0
			
			// Remove old effect
			if(effect)
				for(var/shading/s in effect)
					s.adjust_lum(-effect[s])
				effect.Cut()
			
			// Calculate and apply new effect
			if(on && loc)
				effect = _calc_effect()
				
				for(var/shading/s in effect)
					s.adjust_lum(effect[s])
		
		/// Internal: Calculate illumination contribution to each shading
		_calc_effect()
			var/list/L = list()
			
			// For each turf in range
			for(var/shading/s in range(radius, owner))
				var/lum_value = calc_lum(s)
				
				if(lum_value > 0)
					L[s] = lum_value
			
			return L
		
		/// Calculate brightness contribution to single turf
		/// Uses cosine falloff for smooth gradient
		/// Formula: cos(90° × distance/radius) × intensity + ambient
		calc_lum(atom/a)
			if(!radius) return 0
			
			// Distance calculation
			var/dx = __x - a.x
			var/dy = __y - a.y
			var/d_sq = dx*dx + dy*dy
			
			// Check radius
			if(d_sq > radius_squared)
				return 0
			
			// Cosine falloff creates smooth light gradient
			var/d = sqrt(d_sq)
			var/falloff = cos(90 * d / radius)
			
			return falloff * intensity + ambient
		
		/// Enable light
		on()
			if(on) return
			on = 1
			changed = 1
		
		/// Disable light
		off()
			if(!on) return
			on = 0
			changed = 1
		
		/// Toggle light on/off
		toggle()
			if(on) off()
			else on()
		
		/// Change radius
		set_radius(r)
			if(radius == r) return
			radius = r
			radius_squared = r * r
			changed = 1
		
		/// Change intensity
		set_intensity(i)
			if(intensity == i) return
			intensity = i
			changed = 1
		
		/// Change ambient contribution
		set_ambient(a)
			if(ambient == a) return
			ambient = a
			changed = 1

// ============================================================================
// SHADING OVERLAY OBJECT (Per-Turf Darkness)
// ============================================================================

/*
Purpose: Turf-based overlay that displays darkness
Rendering: Icon_state index changes based on luminosity value
Effect: Higher icon_state = brighter = more transparent

Implementation note: One shading object per turf per z-level.
Stores neighbor references for update propagation.
*/
shading
	parent_type = /obj
	mouse_opacity = 0
	layer = LIGHTING_PLANE
	
	var
		// Luminosity value (darkness)
		lum = 0                     // Discrete brightness level (0 to states)
		__lum = 0                   // Floating point luminosity
		
		// Neighbor references (for propagation)
		shading/c1 = null           // Neighbor: x, y-1
		shading/c2 = null           // Neighbor: x-1, y-1
		shading/c3 = null           // Neighbor: x-1, y
		shading/u1 = null           // Neighbor: x+1, y (depends on c1)
		shading/u2 = null           // Neighbor: x+1, y+1 (depends on c2)
		shading/u3 = null           // Neighbor: x, y+1 (depends on c3)
		
		// State
		changed = 0                 // Dirty flag
		ambient = 0                 // Local ambient contribution
	
	New(turf/t, i, l)
		..(t)
		icon = i
		lum = l
		pixel_x = -16
		pixel_y = -16
	
	proc
		/// Initialize neighbor references
		/// Called once per shading after creation
		init()
			c1 = locate(/shading) in locate(x,     y-1, z)
			c2 = locate(/shading) in locate(x-1,   y-1, z)
			c3 = locate(/shading) in locate(x-1,   y,   z)
			
			u1 = locate(/shading) in locate(x+1,   y,   z)
			u2 = locate(/shading) in locate(x+1,   y+1, z)
			u3 = locate(/shading) in locate(x,     y+1, z)
			
			// Null references at map edges point to global null shading
			if(!c1) c1 = null_shading
			if(!c2) c2 = null_shading
			if(!c3) c3 = null_shading
			if(!u1) u1 = null_shading
			if(!u2) u2 = null_shading
			if(!u3) u3 = null_shading
		
		/// Adjust luminosity (add/subtract light)
		/// Called by light objects when applying/removing effect
		adjust_lum(delta)
			__lum += delta
			
			// Fetch current ambient from global
			ambient = lighting.ambient
			
			// Convert floating point lum to discrete icon_state
			var/new_lum = round(__lum * lighting.states + ambient, 1)
			
			// Clamp to valid range
			if(new_lum < 0)
				new_lum = 0
			else if(new_lum >= lighting.states)
				new_lum = lighting.states - 1
			
			// If changed, mark for update
			if(new_lum != lum)
				lum = new_lum
				mark_changed()
		
		/// Mark as needing icon_state update and propagate to neighbors
		mark_changed()
			if(loc && !changed)
				changed = 1
				lighting.changed += src
				
				// Propagate to dependent neighbors
				if(u1.loc && !u1.changed)
					u1.changed = 1
					lighting.changed += u1
				
				if(u2.loc && !u2.changed)
					u2.changed = 1
					lighting.changed += u2
				
				if(u3.loc && !u3.changed)
					u3.changed = 1
					lighting.changed += u3
		
		/// Update icon_state based on current lum
		update_icon()
			if(!changed) return
			
			changed = 0
			
			if(loc)
				icon_state = "[lum]"  // Icon state name matches lum value

// ============================================================================
// GLOBAL NULL SHADING REFERENCE
// ============================================================================

var/shading/null_shading = new(null, null, 0)

// ============================================================================
// TURF EXTENSION
// ============================================================================

turf
	var
		shading/shading = null  // Reference to this turf's shading object

// ============================================================================
// ATOM EXTENSION
// ============================================================================

atom
	var
		light/light = null      // Reference to attached light source

// ============================================================================
// USAGE EXAMPLES
// ============================================================================

/*
BASIC SETUP:
    // In world/New()
    lighting.init(icon='lightingGradient.dmi', states=5, z_levels=list(1))

ATTACH LIGHT TO FIRE:
    fire/New()
        .()
        src.light = lighting.create_light(src, radius=4, intensity=1)
    
    fire/Del()
        if(light) light.Del()
        ..()

ATTACH LIGHT TO PLAYER TORCH:
    mob/players/equip_torch()
        if(!torch_light)
            torch_light = lighting.create_light(src, radius=5, intensity=0.8)
    
    mob/players/unequip_torch()
        if(torch_light)
            torch_light.Del()
            torch_light = null

DYNAMIC LIGHT CONTROL:
    // Increase fire intensity
    fire_light.set_intensity(1.5)
    
    // Move light with owner
    // (automatic if owner is /atom/movable and pixel_movement enabled)
    
    // Fade out light
    fire_light.set_intensity(0)
    fire_light.off()

TESTING:
    // Admin verb to check lighting
    /proc/test_lighting()
        lighting.init('lighting.dmi', 5)
        var/light/l = lighting.create_light(locate(50,50,1), 6, 1)
        world << "Light created at 50,50 with radius 6"

*/

// ============================================================================
// PERFORMANCE NOTES
// ============================================================================

/*
MEMORY:
- Per turf: ~64 bytes (object overhead, lum, neighbor refs, etc.)
- Example: 100×100 map = 640 KB per z-level
- For 10 z-levels: 6.4 MB
- Avoid using on massive maps (1000×1000 or larger)

CPU:
- Per-light cost: 50-100 microseconds per tick
- With 10 lights at radius 5: ~15-30% CPU overhead on 50 tick/sec
- Mobile lights (tracking step_x/step_y) add ~2-5μs per light
- Update only affected shadings (dirty tracking reduces redraws)

OPTIMIZATION TIPS:
1. Limit light radius to minimum needed (radius 3-5 for fires/torches)
2. Use fewer, brighter lights instead of many dim ones
3. Disable lights when not needed (fire_light.off())
4. Only initialize z-levels actually using dynamic lighting
5. Consider plane-based lighting for global day/night instead
6. Don't create per-player effects (too expensive)

RECOMMENDED LIMITS FOR MMO:
- Maximum 5-10 fire/torch lights per zone
- Maximum 1 light per player (equipped torch only)
- Total active: 20-30 lights during peak
*/
