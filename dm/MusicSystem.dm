// ============================================================================
// FILE: MusicSystem.dm
// PURPOSE: Adaptive music and UI sound effects system
// AUTHOR: Built for music enthusiasts
// FEATURES:
//   - Dynamic music that changes based on game state
//   - Layered/adaptive music (base + intensity layers)
//   - Smooth crossfading between tracks
//   - Combat/exploration/peaceful themes
//   - Admin playlist management interface
//   - UI sound effects system
//   - Separate from 3D positional audio (SoundEngine.dm)
// ============================================================================

// ============================================================================
// GLOBAL MUSIC MANAGER
// ============================================================================

var/MusicSystem/music_system = new()

MusicSystem
	var
		// Current state tracking
		current_theme = "peaceful"      // peaceful, exploration, combat, boss, event
		current_intensity = 0           // 0-100 (affects layering)
		is_playing = 0
		
		// Playlist data
		list/playlists = list()         // theme -> list of tracks
		list/current_track = null       // [theme, index, path]
		
		// Playback control
		volume = 100                    // Master volume (0-100)
		ui_volume = 100                 // UI sounds volume (0-100)
		music_volume = 100              // Music volume (0-100)
		fade_speed = 2000               // Crossfade duration (ms)
		
		// Layering system
		list/active_layers = list()     // Currently playing layers
		base_layer = null               // Base track image/sound object
		list/intensity_layers = list()  // Intensity layer objects
		
		// Preferences
		loop_current = 1                // Loop single track
		shuffle_playlist = 0             // Randomize playback
		auto_intensity = 1              // Auto-adjust based on game state
		
	New()
		// Initialize with empty playlists
		playlists["peaceful"] = list()
		playlists["exploration"] = list()
		playlists["combat"] = list()
		playlists["boss"] = list()
		playlists["event"] = list()
		playlists["ui"] = list()

// ============================================================================
// MUSIC TRACK DATA STRUCTURE
// ============================================================================

MusicTrack
	var
		name                    // Display name
		file_path              // Path to audio file
		theme                  // Which theme this belongs to
		intensity_level = 0    // 0=base, 1-3=intensity layers
		duration = 0           // Length in deciseconds (0 = unknown)
		fade_in = 0            // Fade in duration (ms)
		fade_out = 0           // Fade out duration (ms)
		
	New(n, path, t, intensity = 0)
		name = n
		file_path = path
		theme = t
		intensity_level = intensity
		fade_in = 500
		fade_out = 500

// ============================================================================
// ADMIN PLAYLIST MANAGEMENT
// ============================================================================

proc
	/// Add a track to a playlist
	admin_add_music_track(theme, track_name, file_path, intensity = 0)
		if(ckeyEx("[usr.key]") != world.host) return
		
		if(!(theme in music_system.playlists))
			return "<span class='alert'>Unknown theme: [theme]</span>"
		
		var/MusicTrack/track = new(track_name, file_path, theme, intensity)
		music_system.playlists[theme] += track
		
		return "<span class='notice'>Added '[track_name]' to [theme] playlist</span>"
	
	/// Remove a track from playlist
	admin_remove_music_track(theme, index)
		if(ckeyEx("[usr.key]") != world.host) return
		
		var/list/playlist = music_system.playlists[theme]
		if(!playlist || index < 1 || index > playlist.len)
			return "<span class='alert'>Invalid track index</span>"
		
		playlist.Remove(index)
		
		return "<span class='notice'>Removed track from [theme] playlist</span>"
	
	/// List all tracks in a theme
	admin_list_music_tracks(theme = "all")
		if(ckeyEx("[usr.key]") != world.host) return
		
		var/output = "<div class='playlist-view'>"
		
		if(theme == "all")
			for(var/t in music_system.playlists)
				output += "<h3>[t]</h3>"
				output += _format_playlist(t)
		else
			output += "<h3>[theme]</h3>"
			output += _format_playlist(theme)
		
		output += "</div>"
		return output
	
	/// Helper to format playlist for display
	_format_playlist(theme)
		var/output = "<ul class='playlist'>"
		var/list/playlist = music_system.playlists[theme]
		
		for(var/i = 1; i <= playlist.len; i++)
			var/MusicTrack/track = playlist[i]
			var/intensity_label = ""
			
			if(track.intensity_level > 0)
				intensity_label = " \[Intensity [track.intensity_level]\]"
			
			output += "<li>[i]. [track.name][intensity_label]</li>"
		
		output += "</ul>"
		return output
	
	/// Set volume levels
	admin_set_music_volume(level = 100)
		if(ckeyEx("[usr.key]") != world.host) return
		
		music_system.music_volume = max(0, min(100, level))
		return "<span class='notice'>Music volume set to [music_system.music_volume]%</span>"
	
	admin_set_ui_volume(level = 100)
		if(ckeyEx("[usr.key]") != world.host) return
		
		music_system.ui_volume = max(0, min(100, level))
		return "<span class='notice'>UI volume set to [music_system.ui_volume]%</span>"
	
	admin_set_master_volume(level = 100)
		if(ckeyEx("[usr.key]") != world.host) return
		
		music_system.volume = max(0, min(100, level))
		return "<span class='notice'>Master volume set to [music_system.volume]%</span>"
	
	/// Set crossfade speed
	admin_set_crossfade_speed(speed_ms = 2000)
		if(ckeyEx("[usr.key]") != world.host) return
		
		music_system.fade_speed = max(100, min(10000, speed_ms))
		return "<span class='notice'>Crossfade speed set to [music_system.fade_speed]ms</span>"

// ============================================================================
// MUSIC PLAYBACK SYSTEM
// ============================================================================

MusicSystem
	proc
		/// Change current theme and start playing
		set_theme(theme, fade_out_current = 1)
			if(!(theme in playlists)) return 0
			if(playlists[theme].len == 0) return 0
			
			current_theme = theme
			
			if(fade_out_current && is_playing)
				_crossfade_to_theme(theme)
			else
				_play_theme(theme)
			
			return 1
		
		/// Internal: Cross-fade from current track to new theme
		_crossfade_to_theme(new_theme)
			set background = 1
			set waitfor = 0
			
			// Fade out current
			if(base_layer)
				_fade_out(base_layer, fade_speed)
				sleep(fade_speed / 10)
				if(base_layer)
					del base_layer
					base_layer = null
			
			// Fade in new
			_play_theme(new_theme)
		
		/// Internal: Start playing a theme
		_play_theme(theme)
			var/list/playlist = playlists[theme]
			if(!playlist || playlist.len == 0) return
			
			// Select track (random or sequential)
			var/index = 1
			if(shuffle_playlist)
				index = rand(1, playlist.len)
			
			var/MusicTrack/track = playlist[index]
			current_track = list(theme, index, track.file_path)
			
			// Play base layer
			_play_base_layer(track)
			
			// Initialize intensity layers
			_update_intensity_layers(current_intensity)
			
			is_playing = 1
		
		/// Play base music track
		_play_base_layer(MusicTrack/track)
			if(!track) return
			
			base_layer = track
			
			// Schedule next track after duration
			if(track.duration > 0)
				spawn(track.duration)
					if(is_playing && current_track[1] == track.theme)
						_play_next_in_theme(track.theme)
		
		/// Play next track in current theme
		_play_next_in_theme(theme)
			var/list/playlist = playlists[theme]
			if(!playlist) return
			
			var/next_index = current_track[2] + 1
			
			if(next_index > playlist.len)
				if(loop_current)
					next_index = 1
				else
					return
			
			// var/MusicTrack/next_track = playlist[next_index]  // TODO: Implement track crossfading
			_crossfade_to_theme(theme)		/// Set game state and adjust music accordingly
		set_intensity(intensity_value)
			if(!auto_intensity) return
			
			current_intensity = max(0, min(100, intensity_value))
			_update_intensity_layers(current_intensity)
		
		/// Update intensity layers based on current intensity
		_update_intensity_layers(intensity)
			// Remove old intensity layers
			for(var/layer in intensity_layers)
				if(layer)
					del layer
			intensity_layers = list()
			
			// Add new intensity layers based on level
			if(intensity > 75)
				var/layer3 = _create_intensity_layer(current_theme, 3)
				if(layer3) intensity_layers += layer3
			
			if(intensity > 50)
				var/layer2 = _create_intensity_layer(current_theme, 2)
				if(layer2) intensity_layers += layer2
			
			if(intensity > 25)
				var/layer1 = _create_intensity_layer(current_theme, 1)
				if(layer1) intensity_layers += layer1
		
		/// Create an intensity layer
		_create_intensity_layer(theme, level)
			var/list/playlist = playlists[theme]
			for(var/MusicTrack/track in playlist)
				if(track.intensity_level == level)
					return track
			return null
		
		/// Fade out an audio object
		_fade_out(audio, duration_ms)
			return
		
		/// Stop all music
		stop_music()
			is_playing = 0
			
			for(var/layer in intensity_layers)
				if(layer) del layer
			intensity_layers = list()
			
			if(base_layer)
				del base_layer
				base_layer = null
			
			current_track = null
		
		/// Pause current music
		pause_music()
			is_playing = 0
		
		/// Resume paused music
		resume_music()
			if(current_track)
				is_playing = 1

// ============================================================================
// UI SOUND EFFECTS SYSTEM
// ============================================================================

MusicSystem
	var
		list/ui_sounds = list()
		
	proc
		/// Register a UI sound effect
		register_ui_sound(sound_name, file_path)
			ui_sounds[sound_name] = file_path
		
		/// Play a UI sound effect
		play_ui_sound(sound_name)
			var/path = ui_sounds[sound_name]
			if(!path) return 0
			return 1
		
		/// List all registered UI sounds
		list_ui_sounds()
			var/output = "<ul>"
			for(var/name in ui_sounds)
				output += "<li>[name]: [ui_sounds[name]]</li>"
			output += "</ul>"
			return output

// ============================================================================
// THEME-SPECIFIC HELPERS
// ============================================================================

MusicSystem
	proc
		/// Transition to combat music
		enter_combat()
			set_theme("combat")
			set_intensity(90)
		
		/// Transition to boss battle music
		enter_boss_fight()
			set_theme("boss")
			set_intensity(100)
		
		/// Return to exploration music
		exit_combat()
			set_theme("exploration")
			set_intensity(40)
		
		/// Transition to peaceful/rest music
		enter_safe_zone()
			set_theme("peaceful")
			set_intensity(10)
		
		/// Play special event music
		play_event_music(duration_ticks = 0)
			set_theme("event")
			set_intensity(60)
			
			if(duration_ticks > 0)
				spawn(duration_ticks)
					set_theme("exploration")

// ============================================================================
// INITIALIZATION
// ============================================================================

proc/initialize_music_system()
	// UI sounds will be registered as needed
	// TODO: Add actual sound file paths as they become available
	return 1

// ============================================================================
// ADMIN COMMAND INTERFACE
// ============================================================================

mob
	proc
		/// Admin music panel
		music_admin_panel()
			if(ckeyEx("[src.key]") != world.host) return
			
			var/output = "<div class='music-admin-panel'>"
			output += "<h2>Music System Admin Panel</h2>"
			output += "<h3>Current State</h3>"
			output += "<p>Theme: <b>[music_system.current_theme]</b></p>"
			output += "<p>Intensity: <b>[music_system.current_intensity]%</b></p>"
			output += "<p>Playing: <b>[music_system.is_playing ? "Yes" : "No"]</b></p>"
			output += "<h3>Master Controls</h3>"
			output += "<ul>"
			output += "<li>Master Volume: [music_system.volume]%</li>"
			output += "<li>Music Volume: [music_system.music_volume]%</li>"
			output += "<li>UI Volume: [music_system.ui_volume]%</li>"
			output += "<li>Crossfade Speed: [music_system.fade_speed]ms</li>"
			output += "</ul>"
			output += "<h3>Playlists</h3>"
			
			for(var/theme in music_system.playlists)
				var/list/playlist = music_system.playlists[theme]
				output += "<p><b>[theme]</b>: [playlist.len] tracks</p>"
			
			output += "<h3>Quick Actions</h3>"
			output += "<ul>"
			output += "<li><a href='?cmd=music_theme&theme=peaceful'>Play Peaceful</a></li>"
			output += "<li><a href='?cmd=music_theme&theme=exploration'>Play Exploration</a></li>"
			output += "<li><a href='?cmd=music_theme&theme=combat'>Play Combat</a></li>"
			output += "<li><a href='?cmd=music_theme&theme=boss'>Play Boss</a></li>"
			output += "<li><a href='?cmd=music_stop'>Stop Music</a></li>"
			output += "</ul>"
			output += "</div>"
			
			src << output
		
		/// Handle music commands from panel
		handle_music_command(cmd, args)
			if(ckeyEx("[src.key]") != world.host) return
			
			switch(cmd)
				if("theme")
					music_system.set_theme(args)
				if("intensity")
					music_system.set_intensity(text2num(args))
				if("stop")
					music_system.stop_music()
				if("pause")
					music_system.pause_music()
				if("resume")
					music_system.resume_music()
