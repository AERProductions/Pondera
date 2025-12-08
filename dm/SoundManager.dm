// SoundManager.dm — Simplified, centralized sound management system
// Resolves conflicts between multiple sound sources and provides easy-to-use API

// ==================== SOUND REGISTRY ====================

var
	global/sound_manager/sound_mgr
	tmp/list/active_sounds = list()  // Track all active ambient sounds by type

sound_manager
	var
		// Ambient sound state tracking
		list/ambient_sounds = list()  // {"crickets": soundmob, "wind": soundmob, etc}
		list/sound_properties = list()  // {"type": {"radius": 200, "volume": 50}}
		active_sound_groups = list()  // Prevent overlapping similar sounds

	New()
		..()
		InitializeAmbientSounds()

	proc/InitializeAmbientSounds()
		// Define base ambient sound properties
		sound_properties["crickets"] = list(
			"file" = 'snd/nightcrickets.ogg',
			"radius" = 500,
			"volume" = 30,
			"category" = "nature"
		)
		sound_properties["birds"] = list(
			"file" = 'snd/cycadas.ogg',
			"radius" = 600,
			"volume" = 40,
			"category" = "nature"
		)
		sound_properties["wind"] = list(
			"file" = 'snd/wind.ogg',
			"radius" = 400,
			"volume" = 35,
			"category" = "weather"
		)
		sound_properties["rain"] = list(
			"file" = 'snd/lrain.ogg',
			"radius" = 450,
			"volume" = 45,
			"category" = "weather"
		)
		sound_properties["creek"] = list(
			"file" = 'snd/creek.ogg',
			"radius" = 300,
			"volume" = 40,
			"category" = "water"
		)
		sound_properties["waterfall"] = list(
			"file" = 'snd/waterfall.ogg',
			"radius" = 350,
			"volume" = 45,
			"category" = "water"
		)
		sound_properties["fire"] = list(
			"file" = 'snd/fire.ogg',
			"radius" = 250,
			"volume" = 40,
			"category" = "craft"
		)
		sound_properties["caves"] = list(
			"file" = 'snd/caves.ogg',
			"radius" = 400,
			"volume" = 30,
			"category" = "environment"
		)
		sound_properties["hammer"] = list(
			"file" = 'snd/fire2a.ogg',
			"radius" = 350,
			"volume" = 70,
			"category" = "craft",
			"loop" = FALSE
		)
		sound_properties["thunder"] = list(
			"file" = 'snd/wind.ogg',  // TODO: Replace with actual thunder sound when available
			"radius" = 1000,
			"volume" = 95,
			"category" = "weather",
			"loop" = FALSE
		)
		sound_properties["file_scrape"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual file scraping sound
			"radius" = 250,
			"volume" = 60,
			"category" = "craft",
			"loop" = FALSE
		)
		sound_properties["whetstone_scrape"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual whetstone sound
			"radius" = 250,
			"volume" = 60,
			"category" = "craft",
			"loop" = FALSE
		)
		sound_properties["polish_cloth"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual polishing sound
			"radius" = 250,
			"volume" = 50,
			"category" = "craft",
			"loop" = FALSE
		)
		sound_properties["fishing_cast"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual casting sound
			"radius" = 300,
			"volume" = 50,
			"category" = "fishing",
			"loop" = FALSE
		)
		sound_properties["fishing_bite"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual bite alert sound
			"radius" = 200,
			"volume" = 70,
			"category" = "fishing",
			"loop" = FALSE
		)
		sound_properties["fishing_reel"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual reeling sound
			"radius" = 250,
			"volume" = 60,
			"category" = "fishing",
			"loop" = FALSE
		)
		sound_properties["fishing_fail"] = list(
			"file" = 'snd/fire2a.ogg',  // TODO: Replace with actual failure sound
			"radius" = 200,
			"volume" = 50,
			"category" = "fishing",
			"loop" = FALSE
		)

	// ==================== SOUND ACTIVATION API ====================

	proc/PlayAmbientSound(sound_type, attached_atom, override_existing = FALSE)
		/**
		 * Play or update an ambient sound
		 * @param sound_type: Key from sound_properties (e.g., "crickets", "rain", "forge")
		 * @param attached_atom: Atom to attach sound to (usually world location)
		 * @param override_existing: If TRUE, stop existing sound of this category first
		 * @return: soundmob instance or null if failed
		 */
		
		if(!sound_properties[sound_type])
			world.log << "ERROR: Unknown sound type '[sound_type]' in PlayAmbientSound()"
			return null
		
		var/props = sound_properties[sound_type]
		var/category = props["category"]
		
		// Check for conflicting sounds in the same category
		if(!override_existing)
			for(var/sound_type_check in ambient_sounds)
				if(sound_properties[sound_type_check]["category"] == category)
					// Only allow one ambient sound per category at a time
					return ambient_sounds[sound_type_check]
		
		// Stop existing sound of this type
		StopAmbientSound(sound_type)
		
		// Create new soundmob
		var/soundmob/s = new/soundmob(
			attached_atom,
			props["radius"],
			props["file"],
			TRUE,  // autotune
			null,  // auto-allocate channel
			props["volume"],
			props["loop"] != FALSE  // repeat flag
		)
		
		ambient_sounds[sound_type] = s
		active_sounds += s
		
		return s

	proc/PlayEffectSound(sound_type, attached_atom)
		/**
		 * Play a one-shot effect sound (non-looping)
		 * @param sound_type: Key from sound_properties
		 * @param attached_atom: Atom to attach sound to
		 * @return: soundmob instance
		 */
		
		if(!sound_properties[sound_type])
			world.log << "ERROR: Unknown sound type '[sound_type]' in PlayEffectSound()"
			return null
		
		var/props = sound_properties[sound_type]
		
		// Create one-shot soundmob
		var/soundmob/s = new/soundmob(
			attached_atom,
			props["radius"],
			props["file"],
			TRUE,
			null,
			props["volume"],
			FALSE  // no loop for effects
		)
		
		// Auto-cleanup after duration (estimate ~5 seconds)
		spawn(50) if(s) del s
		
		return s

	proc/StopAmbientSound(sound_type)
		/**
		 * Stop an ambient sound and clean up
		 * @param sound_type: Sound to stop
		 */
		
		if(sound_type in ambient_sounds)
			var/soundmob/s = ambient_sounds[sound_type]
			if(s)
				del s
			ambient_sounds[sound_type] = null
			ambient_sounds -= sound_type
			active_sounds -= s

	proc/StopAllAmbientSounds()
		/**
		 * Stop all ambient sounds (useful for biome transitions)
		 */
		
		for(var/sound_type in ambient_sounds)
			StopAmbientSound(sound_type)

	proc/StopSoundCategory(category)
		/**
		 * Stop all sounds in a category (e.g., all "weather" sounds)
		 * @param category: Category name ("nature", "weather", "water", "craft")
		 */
		
		for(var/sound_type in ambient_sounds)
			if(sound_properties[sound_type]["category"] == category)
				StopAmbientSound(sound_type)

	proc/AddCustomSound(sound_type, file, radius = 400, volume = 50, category = "custom", loop = TRUE)
		/**
		 * Register a new custom sound type in the manager
		 * @param sound_type: Unique key for this sound
		 * @param file: Sound file path
		 * @param radius: Audible distance
		 * @param volume: Maximum volume (0-100)
		 * @param category: Sound category for conflict resolution
		 * @param loop: Whether sound loops
		 */
		
		sound_properties[sound_type] = list(
			"file" = file,
			"radius" = radius,
			"volume" = volume,
			"category" = category,
			"loop" = loop
		)

	proc/GetActiveSound(sound_type)
		/**
		 * Get currently active soundmob for a type
		 * @param sound_type: Sound type to check
		 * @return: soundmob instance or null
		 */
		
		return ambient_sounds[sound_type]

	proc/ListActiveSounds()
		/**
		 * Debug: List all active ambient sounds
		 * @return: List of active sound types
		 */
		
		return ambient_sounds.Copy()

// ==================== BIOME-INTEGRATED AMBIENT SOUNDS ====================

// Called from DynamicZoneManager when zone terrain generates
proc/ApplyBiomeAmbientSounds(terrain_type, biome_location)
	/**
	 * Apply appropriate ambient sounds based on biome type
	 * @param terrain_type: Biome type ("water", "temperate", "arctic", "desert")
	 * @param biome_location: Location to attach sounds to
	 */
	
	if(!sound_mgr) return
	
	// Stop conflicting category sounds first
	sound_mgr.StopSoundCategory("nature")
	sound_mgr.StopSoundCategory("water")
	
	switch(terrain_type)
		if("water")
			// Water biomes: creek + birds
			sound_mgr.PlayAmbientSound("creek", biome_location)
			sound_mgr.PlayAmbientSound("birds", biome_location)
			
		if("temperate")
			// Temperate: crickets + birds + occasional wind
			sound_mgr.PlayAmbientSound("crickets", biome_location)
			sound_mgr.PlayAmbientSound("birds", biome_location)
			
		if("desert")
			// Desert: wind + minimal life
			sound_mgr.PlayAmbientSound("wind", biome_location)
			
		if("arctic")
			// Arctic: wind only
			sound_mgr.PlayAmbientSound("wind", biome_location)

// ==================== WEATHER SOUND INTEGRATION ====================

// Called from WeatherParticles when weather changes
proc/ApplyWeatherSounds(weather_type, attached_location)
	/**
	 * Apply weather-appropriate sounds
	 * @param weather_type: Weather type ("fog", "mist", "rain", "hail", "dust_storm", "clear")
	 * @param attached_location: Location to attach sounds to
	 */
	
	if(!sound_mgr) return
	
	// Stop conflicting weather sounds
	sound_mgr.StopSoundCategory("weather")
	
	switch(weather_type)
		if("rain", "drizzle")
			sound_mgr.PlayAmbientSound("rain", attached_location)
		if("dust_storm")
			sound_mgr.PlayAmbientSound("wind", attached_location)
		if("hail", "mist", "fog")
			// Subtle wind during mist/hail
			sound_mgr.PlayAmbientSound("wind", attached_location, TRUE)

// ==================== CRAFTING SOUND EFFECTS ====================

// Anvil/Forge hammer strike sound
proc/PlayHammerStrike(crafting_location)
	/**
	 * Play hammer strike sound at crafting location
	 * @param crafting_location: Location of anvil/forge
	 */
	
	if(!sound_mgr) return
	sound_mgr.PlayEffectSound("hammer", crafting_location)

// Forge ambient sound when active
proc/PlayForgeAmbient(forge_location, active = TRUE)
	/**
	 * Play/stop forge ambient sound
	 * @param forge_location: Location of forge
	 * @param active: If TRUE play, if FALSE stop
	 */
	
	if(!sound_mgr) return
	
	if(active)
		sound_mgr.PlayAmbientSound("forge", forge_location)
	else
		sound_mgr.StopAmbientSound("forge")

// ==================== PLAYER INTEGRATION ====================

mob/players
	var/current_biome_sounds = null
	var/current_weather_sounds = null

	proc/UpdateBiomeSounds(terrain_type)
		/**
		 * Update ambient sounds for current biome
		 * @param terrain_type: New biome type
		 */
		
		if(terrain_type == current_biome_sounds) return
		current_biome_sounds = terrain_type
		ApplyBiomeAmbientSounds(terrain_type, src.loc)

	proc/UpdateWeatherSounds(weather_type)
		/**
		 * Update ambient sounds for current weather
		 * @param weather_type: New weather type
		 */
		
		if(weather_type == current_weather_sounds) return
		current_weather_sounds = weather_type
		ApplyWeatherSounds(weather_type, src.loc)

	proc/ClearAllSounds()
		/**
		 * Stop all ambient sounds (useful on logout)
		 */
		
		if(!sound_mgr) return
		sound_mgr.StopAllAmbientSounds()

// ==================== INITIALIZATION ====================

proc/InitSoundManager()
	/**
	 * Initialize the global sound manager
	 * Call this during world startup
	 */
	
	if(!sound_mgr)
		sound_mgr = new /sound_manager()
		world.log << "Sound Manager initialized"

// Hook into world initialization
world/New()
	..()
	InitSoundManager()
