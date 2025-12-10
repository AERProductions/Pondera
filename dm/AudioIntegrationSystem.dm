/**
 * AUDIO INTEGRATION SYSTEM - Phase C.1 (Sound Restoration)
 * 
 * Purpose: Unified audio management connecting:
 * - Background music (MusicSystem.dm)
 * - Environmental sounds (SoundEngine.dm)
 * - Object ambient sounds (SoundmobIntegration.dm)
 * - Combat audio feedback (hit sounds, death audio)
 * - UI sound effects (clicks, level-ups, item pickups)
 * 
 * Architecture:
 * - AudioManager: Central coordinator for all audio systems
 * - Continent themes: Story/Sandbox/PvP unique music
 * - Combat sfx hooks: Integrated with combat systems
 * - Environmental sfx: Fire, anvil, water sounds
 * - UI feedback sounds: Status confirmations
 * 
 * Status: ACTIVE (Feb 10, 2025)
 * Build: 0 errors
 */

// ============================================================================
// AUDIO MANAGER - Centralized Audio Coordination
// ============================================================================

var/AudioManager/audio_manager = new()

AudioManager
	var
		// Master control
		master_enabled = TRUE
		master_volume = 100      // 0-100
		
		// System states
		current_continent = "story"
		player_in_combat = FALSE
		current_intensity = 0    // 0-100
		
		// Audio subsystems
		list/continent_themes = list()
		list/combat_sounds = list()
		list/ui_sounds = list()
		list/environmental_sounds = list()
		
		// Preload cache
		list/preloaded_sounds = list()
	
	New()
		// Initialize audio systems
		InitializeContientThemes()
		InitializeCombatSounds()
		InitializeUISounds()
		InitializeEnvironmentalSounds()
		world.log << "\[AUDIO\] AudioManager initialized - ready for playback"
	
	proc/InitializeContientThemes()
		/**
		 * Story Mode: Medieval tavern/quest atmosphere
		 * Peaceful: Calm exploration, village ambience
		 * Combat: Tense, dramatic boss battles
		 * 
		 * Note: Sound file paths are placeholders. Actual audio files should be added to snd/ directory.
		 * Format: .ogg files recommended (BYOND native, royalty-free, small file size)
		 * To enable audio: Replace placeholder paths with actual .ogg file references
		 */
		continent_themes["story_peaceful"] = list(
			name = "Tavern Rest",
			file = null,  // Placeholder: 'snd/music/story_peaceful.ogg'
			volume = 60,
			loop = TRUE
		)
		continent_themes["story_exploration"] = list(
			name = "Adventure Awaits",
			file = null,  // Placeholder: 'snd/music/story_exploration.ogg'
			volume = 70,
			loop = TRUE
		)
		continent_themes["story_combat"] = list(
			name = "Battle Drums",
			file = null,  // Placeholder: 'snd/music/story_combat.ogg'
			volume = 80,
			loop = TRUE
		)
		
		// Sandbox: Peaceful creative mode
		continent_themes["sandbox_peaceful"] = list(
			name = "Creative Calm",
			file = null,  // Placeholder: 'snd/music/sandbox_peaceful.ogg'
			volume = 50,
			loop = TRUE
		)
		continent_themes["sandbox_building"] = list(
			name = "Builder's Groove",
			file = null,  // Placeholder: 'snd/music/sandbox_building.ogg'
			volume = 60,
			loop = TRUE
		)
		
		// PvP: Tense competitive atmosphere
		continent_themes["pvp_exploration"] = list(
			name = "Danger Lurks",
			file = null,  // Placeholder: 'snd/music/pvp_exploration.ogg'
			volume = 70,
			loop = TRUE
		)
		continent_themes["pvp_combat"] = list(
			name = "Adrenaline Rush",
			file = null,  // Placeholder: 'snd/music/pvp_combat.ogg'
			volume = 85,
			loop = TRUE
		)
		continent_themes["pvp_boss"] = list(
			name = "The Final Confrontation",
			file = null,  // Placeholder: 'snd/music/pvp_boss.ogg'
			volume = 90,
			loop = TRUE
		)
	
	proc/InitializeCombatSounds()
		/**
		 * Combat audio feedback:
		 * - Hit sounds (melee contact noise)
		 * - Critical hits (enhanced impact)
		 * - Death audio (finality)
		 * - Dodge/miss (avoidance feedback)
		 * - Block/defend (protection feedback)
		 * 
		 * Note: Sound file paths are placeholders. Add actual .ogg files to snd/combat/ directory.
		 */
		combat_sounds["hit_light"] = list(
			name = "Light Hit",
			file = null,  // Placeholder: 'snd/combat/hit_light.ogg'
			volume = 70,
			loop = FALSE
		)
		combat_sounds["hit_medium"] = list(
			name = "Medium Hit",
			file = null,  // Placeholder: 'snd/combat/hit_medium.ogg'
			volume = 75,
			loop = FALSE
		)
		combat_sounds["hit_heavy"] = list(
			name = "Heavy Hit",
			file = null,  // Placeholder: 'snd/combat/hit_heavy.ogg'
			volume = 80,
			loop = FALSE
		)
		combat_sounds["critical_hit"] = list(
			name = "Critical Hit",
			file = null,  // Placeholder: 'snd/combat/critical_hit.ogg'
			volume = 85,
			loop = FALSE
		)
		combat_sounds["death"] = list(
			name = "Death",
			file = null,  // Placeholder: 'snd/combat/death.ogg'
			volume = 80,
			loop = FALSE
		)
		combat_sounds["dodge"] = list(
			name = "Dodge",
			file = null,  // Placeholder: 'snd/combat/dodge.ogg'
			volume = 60,
			loop = FALSE
		)
		combat_sounds["block"] = list(
			name = "Block",
			file = null,  // Placeholder: 'snd/combat/block.ogg'
			volume = 70,
			loop = FALSE
		)
	
	proc/InitializeUISounds()
		/**
		 * UI feedback sounds:
		 * - Menu click
		 * - Inventory open/close
		 * - Item pickup/drop
		 * - Level up
		 * - Recipe discovery
		 * - Quest completion
		 * 
		 * Note: Sound file paths are placeholders. Add actual .ogg files to snd/ui/ directory.
		 */
		ui_sounds["click"] = list(
			name = "Click",
			file = null,  // Placeholder: 'snd/ui/click.ogg'
			volume = 50,
			loop = FALSE
		)
		ui_sounds["inventory_open"] = list(
			name = "Inventory Open",
			file = null,  // Placeholder: 'snd/ui/inventory_open.ogg'
			volume = 60,
			loop = FALSE
		)
		ui_sounds["item_pickup"] = list(
			name = "Item Pickup",
			file = null,  // Placeholder: 'snd/ui/pickup.ogg'
			volume = 65,
			loop = FALSE
		)
		ui_sounds["item_drop"] = list(
			name = "Item Drop",
			file = null,  // Placeholder: 'snd/ui/drop.ogg'
			volume = 60,
			loop = FALSE
		)
		ui_sounds["levelup"] = list(
			name = "Level Up!",
			file = null,  // Placeholder: 'snd/ui/levelup.ogg'
			volume = 80,
			loop = FALSE
		)
		ui_sounds["recipe_discover"] = list(
			name = "Recipe Discovery",
			file = null,  // Placeholder: 'snd/ui/recipe_discover.ogg'
			volume = 75,
			loop = FALSE
		)
		ui_sounds["quest_complete"] = list(
			name = "Quest Complete",
			file = null,  // Placeholder: 'snd/ui/quest_complete.ogg'
			volume = 80,
			loop = FALSE
		)
	
	proc/InitializeEnvironmentalSounds()
		/**
		 * Environmental ambient sounds:
		 * - Fire crackle (Fire, Forge, Torches)
		 * - Anvil ambient (Smithing area)
		 * - Water sounds (Water troughs, waterfalls)
		 * - Wind/weather (Storm, rain, wind)
		 * - Forest ambience (Birds, insects)
		 * 
		 * Note: Sound file paths are placeholders. Add actual .ogg files to snd/ambient/ directory.
		 */
		environmental_sounds["fire_crackle"] = list(
			name = "Fire Crackle",
			file = null,  // Placeholder: 'snd/ambient/fire_crackle.ogg'
			volume = 60,
			radius = 250,
			loop = TRUE
		)
		environmental_sounds["anvil_ambient"] = list(
			name = "Anvil Ambient",
			file = null,  // Placeholder: 'snd/ambient/anvil_ambient.ogg'
			volume = 50,
			radius = 200,
			loop = TRUE
		)
		environmental_sounds["water_flow"] = list(
			name = "Water Flow",
			file = null,  // Placeholder: 'snd/ambient/water_flow.ogg'
			volume = 55,
			radius = 300,
			loop = TRUE
		)
		environmental_sounds["wind"] = list(
			name = "Wind",
			file = null,  // Placeholder: 'snd/ambient/wind.ogg'
			volume = 40,
			radius = 500,
			loop = TRUE
		)
		environmental_sounds["forest_birds"] = list(
			name = "Forest Birds",
			file = null,  // Placeholder: 'snd/ambient/forest_birds.ogg'
			volume = 45,
			radius = 400,
			loop = TRUE
		)
	
	/**
	 * Play audio from registered libraries
	 * Handles fallback if sound doesn't exist
	 */
	proc/PlaySound(library, sound_key, player_client = null, location = null)
		if(!master_enabled) return FALSE
		
		var/list/sound_data = null
		
		switch(library)
			if("combat")
				sound_data = combat_sounds[sound_key]
			if("ui")
				sound_data = ui_sounds[sound_key]
			if("environmental")
				sound_data = environmental_sounds[sound_key]
			if("music")
				sound_data = continent_themes[sound_key]
		
		if(!sound_data)
			world.log << "\[AUDIO\] WARNING: Sound not found - [library].[sound_key]"
			return FALSE
		
		var/sound/S = sound(sound_data["file"])
		if(!S)
			world.log << "\[AUDIO\] WARNING: Could not load sound file - [sound_data["file"]]"
			return FALSE
		
		// Adjust volume based on master + system volumes
		var/final_volume = sound_data["volume"]
		switch(library)
			if("music")
				final_volume = round(final_volume * master_volume / 100 * music_system.music_volume / 100)
			if("ui")
				final_volume = round(final_volume * master_volume / 100 * music_system.ui_volume / 100)
			if("combat", "environmental")
				final_volume = round(final_volume * master_volume / 100)
		
		// Play to specific player or broadcast
		if(player_client)
			player_client << S
		else
			world << S
		
		return TRUE
	
	/**
	 * Change continent theme
	 * Used when player logs in or changes continents
	 */
	proc/SetContinent(continent_name)
		current_continent = continent_name
		
		switch(continent_name)
			if("story")
				PlaySound("music", "story_peaceful")
			if("sandbox")
				PlaySound("music", "sandbox_peaceful")
			if("pvp")
				PlaySound("music", "pvp_exploration")
		
		world.log << "\[AUDIO\] Changed theme to [continent_name]"
	
	/**
	 * Notify audio system of combat state
	 * Used to trigger combat music transitions
	 */
	proc/SetCombatState(in_combat, intensity = 50)
		player_in_combat = in_combat
		current_intensity = intensity
		
		if(in_combat)
			// Transition to combat music
			var/music_key = current_continent + "_combat"
			PlaySound("music", music_key)
		else
			// Transition back to exploration
			var/music_key = current_continent + "_exploration"
			PlaySound("music", music_key)
		
		world.log << "\[AUDIO\] Combat state: [in_combat] (intensity=[intensity])"

// ============================================================================
// COMBAT AUDIO HOOKS
// ============================================================================

/**
 * Play combat hit sound
 * Called from WeaponAnimationSystem.dm after damage is applied
 * 
 * @param attacker: mob/player performing the attack
 * @param damage: amount of damage dealt
 * @param is_critical: TRUE if this is a critical hit
 */
proc/PlayCombatHitSound(mob/attacker, damage = 0, is_critical = FALSE)
	if(!audio_manager || !attacker) return
	
	var/sound_key = "hit_light"
	
	if(is_critical)
		sound_key = "critical_hit"
	else if(damage >= 50)
		sound_key = "hit_heavy"
	else if(damage >= 20)
		sound_key = "hit_medium"
	
	audio_manager.PlaySound("combat", sound_key, attacker.client)

/**
 * Play death sound
 * Called when mob dies
 */
proc/PlayDeathSound(mob/dying_mob)
	if(!audio_manager || !dying_mob) return
	audio_manager.PlaySound("combat", "death", dying_mob.client, dying_mob.loc)

/**
 * Play dodge/evade sound
 * Called when attack misses
 */
proc/PlayDodgeSound(mob/defender)
	if(!audio_manager || !defender) return
	audio_manager.PlaySound("combat", "dodge", defender.client)

/**
 * Play block/defend sound
 * Called when shield/armor absorbs damage
 */
proc/PlayBlockSound(mob/defender)
	if(!audio_manager || !defender) return
	audio_manager.PlaySound("combat", "block", defender.client)

// ============================================================================
// UI AUDIO HOOKS
// ============================================================================

/**
 * Play UI click sound
 * Called from inventory, menu interactions
 */
proc/PlayUIClickSound(client/player_client)
	if(!audio_manager || !player_client) return
	audio_manager.PlaySound("ui", "click", player_client)

/**
 * Play inventory open sound
 */
proc/PlayInventoryOpenSound(client/player_client)
	if(!audio_manager || !player_client) return
	audio_manager.PlaySound("ui", "inventory_open", player_client)

/**
 * Play item pickup sound
 * Called when item enters inventory
 */
proc/PlayItemPickupSound(mob/M, obj/item)
	if(!audio_manager || !M) return
	audio_manager.PlaySound("ui", "item_pickup", M.client, M.loc)

/**
 * Play item drop sound
 * Called when item exits inventory
 */
proc/PlayItemDropSound(mob/M, obj/item)
	if(!audio_manager || !M) return
	audio_manager.PlaySound("ui", "item_drop", M.client, M.loc)

/**
 * Play level up sound
 * Called when rank increases
 */
proc/PlayLevelUpSound(mob/M, rank_type)
	if(!audio_manager || !M) return
	audio_manager.PlaySound("ui", "levelup", M.client, M.loc)

/**
 * Play recipe discovery sound
 * Called when new recipe unlocked
 */
proc/PlayRecipeDiscoverSound(mob/M)
	if(!audio_manager || !M) return
	audio_manager.PlaySound("ui", "recipe_discover", M.client, M.loc)

/**
 * Play quest completion sound
 */
proc/PlayQuestCompleteSound(mob/M)
	if(!audio_manager || !M) return
	audio_manager.PlaySound("ui", "quest_complete", M.client, M.loc)

// ============================================================================
// ENVIRONMENTAL AUDIO HELPERS
// ============================================================================

/**
 * Attach fire sound to object
 * Used by Fire, Forge, Torches, etc.
 */
proc/AttachFireSound(atom/buildable)
	if(!audio_manager || !buildable) return
	audio_manager.PlaySound("environmental", "fire_crackle", null, buildable.loc)

/**
 * Attach anvil sound to object
 * Used by Forge, Anvil, Smithing stations
 */
proc/AttachAnvilSound(atom/buildable)
	if(!audio_manager || !buildable) return
	audio_manager.PlaySound("environmental", "anvil_ambient", null, buildable.loc)

/**
 * Attach water sound to location
 * Used by Water Troughs, Waterfalls, Water sources
 */
proc/AttachWaterSound(atom/location)
	if(!audio_manager || !location) return
	audio_manager.PlaySound("environmental", "water_flow", null, location.loc)

// ============================================================================
// INITIALIZATION
// ============================================================================

/**
 * Initialize Audio System on world creation
 * Called from InitializationManager.dm
 */
/proc/InitializeAudioSystem()
	if(!audio_manager)
		audio_manager = new()
		world.log << "\[INIT\] Audio System: Initializing..."
		
		// Preload common sounds to reduce runtime delays
		PreloadCommonSounds()
		
		world.log << "\[INIT\] Audio System: Ready for playback"
		return TRUE
	
	return FALSE

/**
 * Anvil hammer sound effect when smithing
 * Plays metallic hammer strike audio at anvil location
 */
proc/PlayAnvilHammerSound(obj/anvil)
	if(!audio_manager || !anvil) return
	
	// Play metallic hammer strike sound (using hit_heavy as fallback)
	var/list/data = audio_manager.combat_sounds["hit_heavy"]
	if(data)
		var/S = sound(data["file"], volume = 60)
		anvil.loc << S

/**
 * Preload frequently-used sounds into cache
 */
proc/PreloadCommonSounds()
	if(!audio_manager) return
	
	// Preload combat sounds
	var/list/combat_keys = list("hit_light", "hit_medium", "hit_heavy", "critical_hit", "death")
	for(var/key in combat_keys)
		var/list/data = audio_manager.combat_sounds[key]
		if(data)
			audio_manager.preloaded_sounds[key] = sound(data["file"])
	
	// Preload UI sounds
	var/list/ui_keys = list("click", "levelup", "item_pickup", "recipe_discover", "quest_complete")
	for(var/key in ui_keys)
		var/list/data = audio_manager.ui_sounds[key]
		if(data)
			audio_manager.preloaded_sounds[key] = sound(data["file"])
	
	world.log << "\[AUDIO\] Preloaded [audio_manager.preloaded_sounds.len] sounds"
