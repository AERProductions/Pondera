// ============================================================================
// FIRE OBJECT SHADOW INTEGRATION - MINIMAL CODE CHANGES
// ============================================================================
// This file shows EXACTLY what needs to be changed in Light.dm to add shadows
// Copy-paste the relevant sections directly into Light.dm
// ============================================================================

// ============================================================================
// CHANGE 1: Add light variable to Fire object definition
// ============================================================================
// LOCATION: Light.dm, in the "fire" object definition (around line XXX)
// ACTION: Add this line to the var section

fire
	// Existing vars:
	var
		// ... existing variables ...
		soundmob/fire_sound = null          // EXISTING: sound system
		
		light/fire_light = null             // NEW: for shadow casting
		
		// ... rest of fire variables ...

// ============================================================================
// CHANGE 2: Initialize lighting system (ONE TIME, in world/New)
// ============================================================================
// LOCATION: dm/Light.dm, in world/New() proc
// ACTION: Add these lines right after the world initialization completes

world
	var
		Lighting/lighting = null            // Global lighting manager
	
	proc
		New()
			// ... existing world initialization code ...
			
			// FIRE SHADOWS: Initialize dynamic lighting system
			// This runs once per world startup
			if(!lighting)
				var/lighting_initialized = 0
				for(var/light/l in world)
					if(l)
						lighting_initialized = 1
						break
				
				if(!lighting_initialized)
					// Initialize with Fire icon gradient and 5 brightness levels
					// Using copy from libs/dynamiclighting/lighting.dmi
					// Or generate your own via icon-generator.dm
					
					// Initialize for all z-levels (or specific ones)
					var/list/active_zlevels = list()
					for(var/z = 1 to world.maxz)
						active_zlevels += z
					
					// Set up lighting manager
					lighting = new /Lighting()
					lighting.init(icon='lighting.dmi', states=5, z_levels=active_zlevels)
					// Note: 'lighting.dmi' must exist in project root
					// OR 'dmi/lighting.dmi' in dmi folder
			
			// ... rest of world initialization ...

// ============================================================================
// CHANGE 3: Create fire light in Fire/New()
// ============================================================================
// LOCATION: Light.dm, in fire object's New() proc
// ACTION: Add the shadow initialization after sound initialization

fire/New(location)
	..(location)
	
	// EXISTING: Sound system initialization
	if(src.name != "Empty Fire")
		fire_sound = AttachObjectSound(src, "fire", 250, 40)
		
		// NEW: Fire shadow system
		// Only create light if lighting system is initialized
		if(lighting)
			fire_light = lighting.create_light(src, radius=3, intensity=1)
			// radius=3: ~28 affected turfs (3² × π)
			// intensity=1: Full brightness at center
			// Adjust these values to taste:
			//   radius 2: Small campfire
			//   radius 3: Normal fire (default)
			//   radius 4: Large bonfire
			//   radius 5: Beacon fire

// ============================================================================
// CHANGE 4: Clean up fire light in Fire/Del()
// ============================================================================
// LOCATION: Light.dm, in fire object's Del() proc
// ACTION: Add light cleanup before calling parent Del()

fire/Del()
	// EXISTING: Sound system cleanup
	if(fire_sound)
		StopObjectSound(fire_sound)
	
	// NEW: Fire shadow system cleanup
	if(fire_light)
		fire_light.Del()
		fire_light = null
	
	// Call parent Del()
	..()

// ============================================================================
// OPTIONAL CHANGE 5: Dynamic fire intensity (if you want varying shadows)
// ============================================================================
// LOCATION: Light.dm, in Fire verb that controls heat/intensity
// ACTION: Add these lines to any proc that changes fire state

fire/proc/increase_heat()
	// ... existing heat increase code ...
	
	// Sync shadow intensity with fire heat
	// (assuming you have an 'intensity' variable for fire heat 0-1)
	if(fire_light)
		fire_light.set_intensity(intensity)  // Shadow brightness matches fire heat

fire/proc/decrease_heat()
	// ... existing heat decrease code ...
	
	// Sync shadow intensity
	if(fire_light)
		fire_light.set_intensity(intensity)

// ============================================================================
// OPTIONAL CHANGE 6: Admin diagnostic commands
// ============================================================================
// LOCATION: _AdminCommands.dm
// ACTION: Add these debugging procs for monitoring

mob/admin
	proc
		/// List all active fire shadows
		fire_shadows_list()
			set category = "Debug"
			
			var/count = 0
			for(var/fire/f in world)
				if(f.fire_light)
					count++
					usr << "[f]: shadow radius=[f.fire_light.radius], on=[f.fire_light.on]"
			
			usr << "Total fires with shadows: [count]"
			usr << "Total active lights: [lighting.lights.len]"
		
		/// Toggle fire shadows on/off
		fire_shadows_toggle()
			set category = "Debug"
			
			var/count = 0
			for(var/fire/f in world)
				if(f.fire_light)
					f.fire_light.toggle()
					count++
			
			usr << "Toggled [count] fire shadows"
		
		/// Test shadow on single fire
		fire_shadows_test()
			set category = "Debug"
			
			var/fire/f = locate() in world
			if(!f)
				usr << "No fire found on this turf"
				return
			
			if(f.fire_light)
				usr << "[f]: radius=[f.fire_light.radius], intensity=[f.fire_light.intensity]"
				usr << "Effect list length: [f.fire_light.effect.len if f.fire_light.effect else 0]"
			else
				usr << "[f]: No shadow attached"

// ============================================================================
// PERFORMANCE TUNING GUIDE
// ============================================================================
// If you need to adjust performance after deployment:

/*
REDUCE CPU COST:
1. Decrease radius (3 → 2):
   fire_light = lighting.create_light(src, radius=2, intensity=1)
   - Affects fewer turfs (~12 instead of 28)
   - Shadows less dramatic but faster

2. Disable shadows for non-important fires:
   if(src.is_forge || src.is_anvil)
       fire_light = lighting.create_light(src, radius=3, intensity=1)
   // Skip shadow for regular campfires

3. Only enable on certain z-levels:
   if(src.z <= 1)  // Only surface fires
       fire_light = lighting.create_light(src, radius=3, intensity=1)

INCREASE CPU COST (for better visuals):
1. Increase radius (3 → 4):
   fire_light = lighting.create_light(src, radius=4, intensity=1)
   - More dramatic shadow gradient
   - ~44 affected turfs (~60% more CPU per fire)

2. Increase intensity (1.0 → 1.5):
   fire_light = lighting.create_light(src, radius=3, intensity=1.5)
   - Darker, more prominent shadows
   - Same CPU cost, just visual

MONITORING:
Check in-game during peak hours:
  /fire_shadows_list    # Shows all active shadows
  
Check memory:
  var/mem = memoryleft()
  usr << "Free memory: [mem] bytes"

Check performance:
  // (if frame time monitoring is available)
*/

// ============================================================================
// TROUBLESHOOTING QUICK REFERENCE
// ============================================================================

/*
PROBLEM: "No such var: light" error
FIX: Add "light/fire_light = null" to fire object var section

PROBLEM: "'lighting.dmi' file not found" error
FIX: 
  1. Check file exists: Pondera/lighting.dmi
  2. Or place in: Pondera/dmi/lighting.dmi
  3. Update path: lighting.init(icon='dmi/lighting.dmi', ...)

PROBLEM: Shadows not showing around fire
FIX:
  1. Check lighting.init() was called in world/New()
  2. Check fire_light variable was created: 
     if(f.fire_light) world << "Light created"
  3. Check light is on: f.fire_light.on
  4. Check icon file has 5 states, not corrupted

PROBLEM: Performance degrading with many fires
FIX: See "PERFORMANCE TUNING" section above
  1. Reduce radius to 2
  2. Disable for non-important fires
  3. Monitor light count: lighting.lights.len

PROBLEM: Compilation fails
FIX: Check Pondera.dme includes DynamicLighting_Refactored.dm
  // MUST be included BEFORE Light.dm in Pondera.dme
  // So that /light type is defined before Fire uses it

*/

// ============================================================================
// COPY-PASTE CHECKLIST
// ============================================================================

/*
To implement fire shadows, in order:

[ ] 1. Copy lighting.dmi to Pondera root (or dmi/ folder)
[ ] 2. Include DynamicLighting_Refactored.dm in Pondera.dme (before Light.dm!)
[ ] 3. Add "light/fire_light = null" to fire var section
[ ] 4. Add lighting.init() to world/New()
[ ] 5. Add light creation to fire/New()
[ ] 6. Add light cleanup to fire/Del()
[ ] 7. Build and test
[ ] 8. Monitor for 1 week in production
[ ] 9. Adjust radius/intensity if needed
[ ] 10. Add admin commands if desired

Estimated time: 2-3 hours (1 hour implementation + 1-2 hours testing)
*/
