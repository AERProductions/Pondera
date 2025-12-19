// dm/FootstepSoundSystem.dm — Terrain-based footstep audio integration
// Date: 2025-12-18
// Purpose: Play footstep sounds based on terrain type when players move
//
// Features:
// ✅ Terrain-specific footstep sounds (grass, stone, sand, water, etc.)
// ✅ Speed-based volume modulation (sprinting = louder)
// ✅ Client-side spatialization via SoundEngine.dm
// ✅ Cooldown prevention (don't spam footsteps)
// ✅ Integration with elevation transitions
//
// Integration: MovementLoop() in dm/movement.dm calls PlayFootstep() after each step

// ============================================================================
// FOOTSTEP SOUND REGISTRY - Terrain Type to Audio Mapping
// ============================================================================

/**
 * FOOTSTEP_SOUNDS - Global sound registry by terrain type
 * Maps turf types to appropriate footstep audio files
 * Uses placeholder sound() objects - actual audio files optional for now
 */
var/global/list/FOOTSTEP_SOUNDS = list(
	// Grassland (temperate, rainforest)
	/turf/temperate = list(
		volume = 60,
		range = 3,
		description = "grass"
	),
	/turf/jungle = list(
		volume = 55,
		range = 3,
		description = "grass"
	),
	
	// Snow & Ice (arctic)
	/turf/snow = list(
		volume = 50,
		range = 2,
		description = "snow"
	),
	
	// Desert (sand)
	/turf/sand = list(
		volume = 65,
		range = 4,
		description = "sand"
	),
	
	// Water (shallow)
	/turf/water = list(
		volume = 45,
		range = 3,
		description = "water"
	),
	
	// Default fallback
	"default" = list(
		volume = 60,
		range = 3,
		description = "generic"
	)
)

// ============================================================================
// FOOTSTEP SYSTEM VARIABLES
// ============================================================================

mob/var
	last_footstep_time = 0       // Prevents spamming footsteps
	footstep_cooldown = 5        // Ticks between footstep sounds (25ms @ 40 TPS)

// ============================================================================
// CORE FOOTSTEP PROC
// ============================================================================

/**
 * PlayFootstep()
 * Trigger footstep sound based on current terrain
 * Called from: MovementLoop() after each successful step
 * Respects cooldown to prevent audio spam
 */
mob/proc/PlayFootstep()
	// Prevent spam: only play if enough time has passed
	if(world.time - src.last_footstep_time < src.footstep_cooldown)
		return
	
	src.last_footstep_time = world.time
	
	// Get current location
	var/turf/current_turf = isturf(src.loc) ? src.loc : null
	if(!current_turf)
		return
	
	// Player only (NPCs get default sounds)
	if(!istype(src, /mob/players))
		return
	
	var/mob/players/P = src
	
	// Look up footstep sound for this terrain type
	var/footstep_data = FOOTSTEP_SOUNDS[current_turf.type]
	if(!footstep_data)
		footstep_data = FOOTSTEP_SOUNDS["default"]
	
	if(!footstep_data)
		return
	
	// Extract sound parameters
	var/base_volume = footstep_data["volume"]
	var/audio_range = footstep_data["range"]          // Propagation distance for spatial audio
	var/sound_desc = footstep_data["description"]    // Sound type descriptor (grass, stone, water, etc.)
	
	// Modulate volume based on movement state
	var/adjusted_volume = base_volume
	
	if(P.Sprinting)
		adjusted_volume = base_volume * 1.15  // Sprinting = 15% louder
	else if(P.stamina && P.MAXstamina)
		// Low stamina = quieter (tired = careful footsteps)
		var/stamina_ratio = P.stamina / P.MAXstamina
		if(stamina_ratio < 0.25)
			adjusted_volume = base_volume * 0.7  // Critical stamina = 30% quieter
	
	// Clamp volume to 0-100 using arithmetic instead of proc
	if(adjusted_volume < 0) adjusted_volume = 0
	if(adjusted_volume > 100) adjusted_volume = 100
	
	// Prevent water sounds if on elevated terrain (no water interaction at that level)
	if(P.elevel && P.elevel > 1.0)
		if(findtext(current_turf.type, "water"))
			return  // Don't play water sounds when elevated
	
	// Build sound object for this footstep
	// Sound naming convention: footstep_[type]_[heavy/light].wav
	var/sound_file = "sound/footsteps/footstep_[sound_desc]_default.wav"
	var/sound/footstep_sound = new(sound_file)
	
	// Play the footstep sound with spatial audio
	// audio_range determines how far the sound propagates (audible distance)
	// sound_desc is embedded in the sound filename above
	if(footstep_sound && audio_range > 0)
		_SoundEngine(footstep_sound, current_turf, range=audio_range, volume=adjusted_volume)
	
	return  // Footstep processing complete

/**
 * GetFootstepSound(turf/T)
 * Look up footstep sound for a specific turf
 * Returns sound data list or null if not found
 */
proc/GetFootstepSound(turf/T)
	if(!T) return null
	
	var/footstep_data = FOOTSTEP_SOUNDS[T.type]
	if(!footstep_data)
		footstep_data = FOOTSTEP_SOUNDS["default"]
	
	return footstep_data

/**
 * RegisterFootstepSound(turf_type, volume, range, description)
 * Dynamically register a new terrain footstep sound
 * Useful for custom biomes or runtime modifications
 */
proc/RegisterFootstepSound(var/turf_type, var/volume=60, var/range=3, var/description="unknown")
	if(!FOOTSTEP_SOUNDS)
		FOOTSTEP_SOUNDS = list()
	
	FOOTSTEP_SOUNDS[turf_type] = list(
		volume = volume,
		range = range,
		description = description
	)

/**
 * UnregisterFootstepSound(turf_type)
 * Remove a footstep sound registration
 */
proc/UnregisterFootstepSound(var/turf_type)
	if(FOOTSTEP_SOUNDS && FOOTSTEP_SOUNDS[turf_type])
		FOOTSTEP_SOUNDS.Remove(turf_type)

