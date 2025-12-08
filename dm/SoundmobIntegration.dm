/*
================================================================================
  Object Sound Attachment System - Generalized Sound for Any Buildable
================================================================================

PURPOSE:
Provides a unified system for attaching persistent ambient sounds to ANY buildable
object (Fire, Forge, Anvil, WaterTrough, etc.). This system:

1. Integrates with the soundmob library (fixed for BYOND's updated sound system)
2. Provides easy attachment/detachment for objects
3. Supports dynamic volume/state changes
4. Works with autotune system for automatic player broadcasts
5. Handles cleanup and orphaned soundmob detection

THE CRITICAL FIX:
BUG: Sound plays twice and skips in BYOND's default soundmob implementation
  - Root cause: Library calls were made after BYOND updated its sound system
  - Update hook: Z._updateListeningSoundmobs() must be called on Move() to sync
  - Solution: Integrated into atom/movable/Move() via Mov.dm (line 65)
  - This ensures sounds follow objects correctly without doubling/skipping

USAGE PATTERNS:

1. AUTOTUNE AMBIENT SOUNDS (Fire, water features, etc.)
   - Created with autotune=TRUE (default)
   - Automatically broadcast to all players on creation
   - Players automatically listen based on proximity
   - Best for: persistent environmental sounds
   
   Example:
     var/soundmob/fire_sound = AttachObjectSound(src, "fire", 250)
     // Sound plays to all nearby players automatically

2. EFFECT SOUNDS (Hammer strikes, impacts, etc.)
   - One-shot sounds that don't loop
   - Created with autotune=TRUE but loop=FALSE
   - Best for: actions, impacts, temporary effects
   
   Example:
     PlayObjectEffectSound(anvil_location, "hammer", 300)
     // Sound plays once, auto-cleans up

3. MANUAL SOUNDS (personal, non-broadcast)
   - Created with autotune=FALSE
   - Useful for: player-specific audio that shouldn't broadcast
   - Rare for buildable objects (usually autotune is better)

================================================================================
*/

// ==================== OBJECT SOUND ATTACHMENT API ====================

/**
 * Attach an ambient sound to a buildable object
 * Creates a persistent, looping sound attached to the object
 * Sound automatically broadcasts to nearby players (autotune=TRUE)
 * 
 * @param attached_object: The object (Fire, Forge, Anvil, etc.)
 * @param sound_type: Sound key from sound_properties ("fire", "forge", "hammer")
 * @param radius: Audible distance (optional, uses sound_properties default if null)
 * @param volume: Volume override (optional, uses sound_properties default if null)
 * @return: soundmob instance or null if failed
 */
proc/AttachObjectSound(atom/attached_object, sound_type, radius = null, volume = null)
	if(!attached_object)
		world.log << "OBJECT_SOUND_ERROR: AttachObjectSound() requires attached object"
		return null
	
	if(!sound_mgr)
		world.log << "OBJECT_SOUND_ERROR: Sound manager not initialized"
		return null
	
	var/props = sound_mgr.sound_properties[sound_type]
	if(!props)
		world.log << "OBJECT_SOUND_ERROR: Unknown sound type [sound_type]"
		return null
	
	// Use provided values or defaults from sound_properties
	var/actual_radius = radius || props["radius"]
	var/actual_volume = volume || props["volume"]
	var/actual_file = props["file"]
	var/actual_loop = props["loop"] != FALSE
	
	// Create autotuned soundmob (broadcasts to all players)
	var/soundmob/s = new/soundmob(
		attached_object,
		actual_radius,
		actual_file,
		TRUE,              // autotune=TRUE - broadcast to all players
		null,              // auto-allocate channel
		actual_volume,
		actual_loop
	)
	
	if(!s)
		world.log << "OBJECT_SOUND_ERROR: Failed to create soundmob for [sound_type]"
		return null
	
	world.log << "OBJECT_SOUND: Attached [sound_type] to [attached_object] (radius=[actual_radius], volume=[actual_volume])"
	return s

/**
 * Play a one-shot effect sound at an object location
 * Sound does not loop, auto-cleans up after playback
 * Useful for: hammer strikes, impacts, action sounds
 * 
 * @param location: Location to play sound at
 * @param sound_type: Sound key ("hammer", "strike", "impact")
 * @param radius: Audible distance (optional)
 * @param volume: Volume override (optional)
 * @return: soundmob instance (temporary)
 */
proc/PlayObjectEffectSound(atom/location, sound_type, radius = null, volume = null)
	if(!location)
		world.log << "OBJECT_SOUND_ERROR: PlayObjectEffectSound() requires valid location"
		return null
	
	if(!sound_mgr)
		world.log << "OBJECT_SOUND_ERROR: Sound manager not initialized"
		return null
	
	var/props = sound_mgr.sound_properties[sound_type]
	if(!props)
		world.log << "OBJECT_SOUND_ERROR: Unknown sound type [sound_type]"
		return null
	
	var/actual_radius = radius || props["radius"]
	var/actual_volume = volume || props["volume"]
	var/actual_file = props["file"]
	
	// Create temporary soundmob (one-shot, no loop)
	var/soundmob/s = new/soundmob(
		location,
		actual_radius,
		actual_file,
		TRUE,              // autotune=TRUE for broadcast
		null,
		actual_volume,
		FALSE              // NO LOOP - one-shot effect
	)
	
	if(!s)
		world.log << "OBJECT_SOUND_ERROR: Failed to create effect sound for [sound_type]"
		return null
	
	world.log << "OBJECT_SOUND: Playing effect [sound_type] at [location]"
	
	// Auto-cleanup after ~5 seconds (estimate for effect duration)
	spawn(50) if(s) del s
	
	return s

/**
 * Stop an object sound and clean up
 * @param sound: soundmob to stop
 */
proc/StopObjectSound(soundmob/sound)
	if(!sound) return
	
	if(sound.attached)
		sound.attached._detachSoundmob(sound)
	
	if(sound.autotune)
		_removeAutotuneSoundmob(sound)
	
	sound.unsetListeners()
	del sound

/**
 * Update volume of an attached sound
 * Useful for dynamic volume changes (fire burning hotter, forge cooling, etc.)
 * 
 * @param sound: soundmob to update
 * @param new_volume: New volume level (0-100)
 */
proc/UpdateObjectSoundVolume(soundmob/sound, new_volume = 50)
	if(!sound) return
	
	sound.volume = new_volume
	// Update all listeners with new volume
	if(sound.listeners)
		for(var/mob/players/mob in sound.listeners)
			if(mob:_listening_soundmobs[sound])
				var/tmp/s = mob:_listening_soundmobs[sound]
				s:volume = new_volume

/**
 * Change the state/intensity of an attached sound
 * Useful for: fire state changes (Lit → Fueled), forge temperature changes
 * 
 * @param sound: soundmob to update
 * @param state: State descriptor ("low", "medium", "high", "intense")
 * @param sound_type: The original sound type (to look up properties)
 */
proc/UpdateObjectSoundState(soundmob/sound, state, sound_type = null)
	if(!sound) return
	
	// Map states to volume levels
	var/new_volume = 50  // default
	switch(state)
		if("off", "idle", "empty")
			new_volume = 0
		if("low", "cold", "weak")
			new_volume = 30
		if("medium", "warm", "active")
			new_volume = 50
		if("high", "hot", "intense")
			new_volume = 70
		if("max", "blazing", "peak")
			new_volume = 100
	
	UpdateObjectSoundVolume(sound, new_volume)

/**
 * Check if an object has attached sounds
 * @param attached_object: Object to check
 * @return: Number of attached soundmobs
 */
proc/CountObjectSounds(atom/attached_object)
	if(!attached_object || !attached_object._attached_soundmobs)
		return 0
	return attached_object._attached_soundmobs.len

/**
 * Get all soundmobs attached to an object
 * @param attached_object: Object to search
 * @return: List of soundmob instances
 */
proc/GetObjectSounds(atom/attached_object)
	if(!attached_object || !attached_object._attached_soundmobs)
		return list()
	return attached_object._attached_soundmobs.Copy()

/**
 * Stop all sounds attached to an object
 * Useful for cleanup, state changes, or object deletion
 * @param attached_object: Object to clear sounds from
 */
proc/StopAllObjectSounds(atom/attached_object)
	if(!attached_object || !attached_object._attached_soundmobs)
		return
	
	var/list/sounds = GetObjectSounds(attached_object)
	for(var/soundmob/s in sounds)
		StopObjectSound(s)

// ==================== DEBUGGING & DIAGNOSTICS ====================

/**
 * List all autotuned soundmobs currently active
 * Shows sound file, radius, listeners for each
 */
proc/ListActiveObjectSounds()
	if(!_autotune_soundmobs || !_autotune_soundmobs.len)
		world.log << "OBJECT_SOUND: No active object sounds"
		return
	
	world.log << "OBJECT_SOUND: Active Object Sounds Report"
	for(var/soundmob/s in _autotune_soundmobs)
		if(s.attached)  // Only show attached sounds (not world ambient)
			var/listener_count = s.listeners ? s.listeners.len : 0
			world.log << "  - [s.file] attached to [s.attached.type] (radius=[s.radius], vol=[s.volume], listeners=[listener_count])"

/**
 * Verify object sound system health
 * Checks for memory leaks, orphaned sounds
 * @return: TRUE if healthy, FALSE if issues found
 */
proc/VerifyObjectSoundHealth()
	var/orphaned = 0
	var/total_attached = 0
	
	if(!_autotune_soundmobs || !_autotune_soundmobs.len)
		world.log << "OBJECT_SOUND_HEALTH: Clean - no sounds active"
		return TRUE
	
	for(var/soundmob/s in _autotune_soundmobs)
		if(s.attached)
			total_attached++
			if(!s.file || s.file == "")
				orphaned++
	
	if(orphaned > 0)
		world.log << "OBJECT_SOUND_HEALTH: WARNING: [orphaned] orphaned sounds detected"
		return FALSE
	
	world.log << "OBJECT_SOUND_HEALTH: Healthy - [total_attached] attached object sounds"
	return TRUE

/**
 * Generate detailed object sound report
 * Admin diagnostic tool
 * @return: Report string
 */
proc/GetObjectSoundReport()
	var/report = "\n════════════════════════════════════════\n"
	report += "<b>OBJECT SOUND ATTACHMENT REPORT</b>\n"
	report += "════════════════════════════════════════\n"
	
	var/object_count = 0
	var/sound_count = 0
	var/total_listeners = 0
	
	// Count fires with sounds
	for(var/obj/Buildable/Fire/F in world)
		if(F.fire_sound)
			object_count++
			sound_count++
			if(F.fire_sound.listeners)
				total_listeners += F.fire_sound.listeners.len
			report += "[F.name] at ([F.x],[F.y]): 1 sound ([F.fire_sound.listeners.len] listening)\n"
	
	// Forges - TODO: implement forge_sound variable
	/*
	for(var/obj/Buildable/Smithing/Forge/FG in world)
		if(FG.forge_sound)
			object_count++
			sound_count++
			if(FG.forge_sound.listeners)
				total_listeners += FG.forge_sound.listeners.len
			report += "[FG.name] at ([FG.x],[FG.y]): 1 sound ([FG.forge_sound.listeners.len] listening)\n"
	*/
	
	report += "\nSummary: [object_count] objects with sounds, [sound_count] total sounds, [total_listeners] total listeners"
	report += "\n════════════════════════════════════════\n"
	
	return report

// ==================== INTEGRATION CHECKLIST ====================

/*
When adding sound to a buildable object:

□ Add soundmob variable to object definition:
  var/soundmob/[sound_name] = null

□ Initialize sound in New() if object should have it:
  [sound_name] = AttachObjectSound(src, "sound_type", radius_override, volume_override)

□ Clean up in Del():
  if([sound_name])
    StopObjectSound([sound_name])

□ For state changes, update volume:
  if([sound_name])
    UpdateObjectSoundState([sound_name], "new_state", "sound_type")

□ Register custom sounds in SoundManager if needed:
  sound_mgr.AddCustomSound("my_sound", 'snd/file.ogg', radius, volume, category, loop)

□ Test with admin command:
  /reportobjectsounds  — Shows all active sounds
  /verifyobjectsounds  — Checks system health

EXAMPLE: Adding fire sound to Fire object

In Light.dm, obj/Buildable/Fire:

  var/soundmob/fire_sound = null
  
  New(location)
    ..()
    if(src.name != "Empty Fire")
      fire_sound = AttachObjectSound(src, "fire", 250, 40)
  
  Del()
    if(fire_sound)
      StopObjectSound(fire_sound)
    ..()
  
  // When fire is lit:
  src.icon_state = "litfire"
  UpdateObjectSoundState(fire_sound, "high", "fire")
  
  // When fire is extinguished:
  src.icon_state = "emptyfire"
  UpdateObjectSoundState(fire_sound, "off", "fire")

See SoundManager.dm for available sound types and properties.
*/

// ==================== KNOWN LIMITATIONS ====================

/*
1. Soundmob audio does not persist across saves
   - Sounds are re-created at world startup
   - Design: Intentional (sounds are ambience, not critical state)

2. Maximum 268 concurrent soundmobs (channels 756-1024)
   - Each soundmob uses one audio channel
   - Design: Prevents resource exhaustion

3. Autotune distance is linear, not true radius-based
   - A sound at max range might still be barely audible at range+1
   - Design: Audio channel limitations

4. No volume interpolation during distance changes
   - Volume updates are discrete, not smoothly animated
   - Design: BYOND sound system limitation

5. Multiple sounds on same object may conflict
   - Only use multiple sounds if they're in different categories
   - Example: Don't mix "fire crackle" + "fire roar" (both craft category)
   - Use AddCustomSound() with different category if needed
*/
