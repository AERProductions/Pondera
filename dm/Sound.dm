/*
================================================================================
  Pondera Sound System - soundmob Library (by Koil)
================================================================================

This file implements the legacy 3D sound system for Pondera, allowing sounds to be
attached to movable atoms and played for players with dynamic volume and range.

Key Features:
- Attach sounds (soundmobs) to atoms; sound follows atom movement.
- Automatic or manual player listening (autotune).
- Volume and range attenuation based on distance.
- Channel management for up to 268 concurrent soundmobs (channels 756-1024).
- Reference management: soundmobs must be deleted to stop playback and free resources.

Usage Example:
    var/soundmob/s = new/soundmob(attached, radius, file, autotune, channel, volume)
    var/soundmob/s = soundmob(attached, radius, file, autotune, channel, volume)

Arguments:
    attached: Movable atom to attach sound to.
    radius: Max audible distance (affects volume falloff).
    file: Sound file to play.
    autotune: If TRUE, auto-manage listeners; else, use mob.listenSoundmob()/unlistenSoundmob().
    channel: Audio channel (default managed).
    volume: Max volume (default 100).

================================================================================
*/

// --- Channel Reservation Constants ---
var/const
	_channel_reserve_start = 756   // First reserved audio channel for soundmob system
	_channel_reserve_end = 1024    // Last reserved audio channel

// --- Global Variables ---
var/global/upd = 0 // Used for soundmob update ticks
var/tmp/list/_autotune_soundmobs = null // List of all autotuned soundmobs
var/r = rand(2,700) // Random seed for soundmob channel assignment
var/A = 0 // Miscellaneous counter

// --- Soundmob Management Procs ---
/**
 * Adds a soundmob to the autotune list and broadcasts it to all players.
 * Autotuned soundmobs automatically manage listeners based on proximity.
 * @param soundmob The soundmob object to register for autotune
 */
proc/_addAutotuneSoundmob(soundmob/soundmob)
	if(!(soundmob in _autotune_soundmobs))
		if(!_autotune_soundmobs) _autotune_soundmobs = list()
		_autotune_soundmobs += soundmob
		soundmob.broadcast(world)

/**
 * Removes a soundmob from the autotune system.
 * The soundmob must still be explicitly deleted to stop playback.
 * @param soundmob The soundmob object to remove from autotune
 */
proc/_removeAutotuneSoundmob(soundmob/soundmob)
	if(soundmob in _autotune_soundmobs)
		_autotune_soundmobs -= soundmob
		if(!length(_autotune_soundmobs)) _autotune_soundmobs = null

/**
 * Factory proc for creating a soundmob attached to an atom.
 * @param attached Atom to attach sound to
 * @param radius Audible radius
 * @param file Sound file
 * @param autotune Autotune flag
 * @param channel Audio channel
 * @param volume Max volume
 * @param repeat Repeat flag
 * @return soundmob instance
 */
proc/soundmob(atom/attached, radius = 0, file, autotune = TRUE, channel = null, volume = 100, repeat = FALSE)
	if(!attached) ASSERT(attached && file)
	return new/soundmob(attached, radius, file, autotune, channel, volume, repeat)

// --- Soundmob Object Definition ---
/**
 * soundmob: Represents a 3D positional sound attached to a movable atom.
 * Automatically manages listeners, volume attenuation, and playback lifecycle.
 */
soundmob
	/**
	 * BYOND savefile stub (unused - soundmobs are not persisted).
	 */
	Write()
		return

	/**
	 * BYOND savefile stub (unused - soundmobs are not persisted).
	 */
	Read()
		return

	var
		atom/attached        // Atom this soundmob is attached to
		list/listeners = new // List of players currently listening to this sound
		file = null          // Sound file
		autotune = TRUE      // Autotune flag (automatic listener management)
		channel = null       // Audio channel
		repeat = FALSE       // Repeat/looping flag
		radius = 0           // Audible radius
		volume = 100         // Maximum volume
		frequency = 0        // Sound frequency
		pan = 0              // Stereo pan
		priority = 0         // Sound priority
		environment = -1     // Sound environment effect
		list/echo = null

	New(atom/_attached, _radius = 0, _file, _autotune = TRUE, _channel = null, _volume = 100, _repeat = FALSE)
		if(_attached) ASSERT(_attached && _file)


		attached = _attached

		if(_file) file = _file
		if(_radius) radius = _radius
		if(_autotune) autotune = _autotune
		if(_channel) channel = _channel
		if(_volume) volume = _volume
		if(_repeat) repeat = _repeat

		if(_attached)
			_attached._attachSoundmob(src)

		if(_autotune) _addAutotuneSoundmob(src)
		..()

	Del()
		if(attached)
			attached._detachSoundmob(src)
		if(autotune) _removeAutotuneSoundmob(src)
		unsetListeners()
		//world << "Unsetlistener via Del"

	proc
		broadcast(target = world)

			var/mob/players/mob
			for(mob in target) if(mob.client) mob.listenSoundmob(src)

		unsetListeners()
			if(listeners)
				for(var/mob/players/mob in listeners)
					unsetListener(mob)
			//world << "UnsetListeners"

		updateListeners()
			if(listeners)
				for(var/mob/players/mob in listeners)
					if(src.attached)
						src.updateListener(mob)
			//world << "UpdateListeners"

		updateListener(mob/players/mob)

			//ASSERT(attached)
			//ASSERT(mob)
			//ASSERT(src)
			//ASSERT(mob.client)
			//ASSERT(src in mob._listening_soundmobs)
			var/sound/sound = mob._listening_soundmobs[src]
			var/distance = sqrt((mob.x - attached.x) * (mob.x - attached.x) + (mob.y - attached.y) * (mob.y - attached.y))
			var/update = volume - (distance / radius * volume)
			if(src&&sound)
				if(mob.x && mob.y && mob.z == attached.x && attached.y && attached.z) sound.pan = 0
				if(mob.x && mob.y && mob.z > attached.x && attached.y && attached.z) sound.pan = -75
				if(mob.x && mob.y && mob.z < attached.x && attached.y && attached.z) sound.pan = 75

				//if(mob in listeners && sound in mob._listening_soundmobs)
			sound:volume = update//volume - (distance / radius * volume)
			sound:frequency = frequency
			sound:channel = channel
			sound:priority = priority
			sound.repeat = repeat
			sound:environment = environment
			sound:echo = echo

			sound:status = SOUND_UPDATE
					//upd = 1
			//broadcast()

			src.listeners+=mob
			mob << sound
		/*updateListener(mob/mob/mob)
			ASSERT(attached)
			ASSERT(mob)
			ASSERT(src)
			ASSERT(mob.client)
			ASSERT(src in mob._listening_soundmobs)
			world << "updateListener"
			if(!mob._listening_soundmobs[src])
				var/tmp/sound/s = new(file)
				mob._listening_soundmobs[src] = s

			var/tmp/sound/sound = mob._listening_soundmobs[src]

			if(!sound.channel) sound.channel = mob._getAvailableChannel()
			if(!(sound.channel in mob._channels_taken)) mob._lockChannel(sound.channel)

			sound.repeat = repeat

			// I'm not using sound.x, y, and z because you aren't really able to set a maximum distance using those.
			// You're always able to hear the sound at least a little regardless of how far it is away.
			// This could probably be improved a bit.

			if(mob.x && mob.y && mob.z == attached.x && attached.y && attached.z) sound.pan = 0
			if(mob.x && mob.y && mob.z > attached.x && attached.y && attached.z) sound.pan = -75
			if(mob.x && mob.y && mob.z < attached.x && attached.y && attached.z) sound.pan = 75

			var/tmp/distance = sqrt((mob.x - attached.x) * (mob.x - attached.x) + (mob.y - attached.y) * (mob.y - attached.y))
			sound.volume = volume - (distance / radius * volume)

			sound.frequency = frequency

			sound.priority = priority
			//sound.repeat = repeat
			sound.environment = environment
			sound.echo = echo

			sound.status = SOUND_STREAM

			mob << sound*/

		setListener(mob/mob)
			//ASSERT(attached)
			//ASSERT(mob)
			//ASSERT(src)
			ASSERT(src)
			//ASSERT(src in mob._listening_soundmobs)
			//world << "setListener from [src] [usr]"
			if(!(mob:_listening_soundmobs[src]))
				var/sound/s = new(src.file)
				mob:_listening_soundmobs[src] = s
			else return

			var/sound/sound = mob:_listening_soundmobs[src]

			if(sound.channel==null) sound.channel = mob:_getAvailableChannel()
			if(!sound.channel) sound.channel = mob:_getAvailableChannel()
			if(!(sound.channel in mob:_channels_taken)) mob:_lockChannel(sound.channel)

			sound.repeat = repeat//keeps the sound going or it only plays once

			// I'm not using sound.x, y, and z because you aren't really able to set a maximum distance using those.
			// You're always able to hear the sound at least a little regardless of how far it is away.
			// This could probably be improved a bit.

			if(mob.x && mob.y && mob.z == attached.x && attached.y && attached.z) sound.pan = 0
			if(mob.x && mob.y && mob.z > attached.x && attached.y && attached.z) sound.pan = -75
			if(mob.x && mob.y && mob.z < attached.x && attached.y && attached.z) sound.pan = 75

			var/distance = sqrt((mob.x - attached.x) * (mob.x - attached.x) + (mob.y - attached.y) * (mob.y - attached.y))
			sound.volume = volume - (distance / radius * volume)

			sound.frequency = frequency
			sound.channel = channel
			sound.priority = priority
			sound.repeat = repeat
			sound.environment = environment
			sound.echo = echo

			sound.status = SOUND_STREAM
			src.listeners+=mob
			mob << sound

		unsetListener(mob/mob)

			if((mob in listeners) && (src in mob:_listening_soundmobs))
				var/sound/sound = mob:_listening_soundmobs[src]
				//world << "unsetListener"
				for(var/i = sound.volume, i >= 0, i --)
					sound.status = SOUND_UPDATE
					sound.volume = i
					sound.repeat = FALSE

					mob << sound

					sleep(1)

				mob << sound(null, 0, 0, sound.channel)
				mob:_unlockChannel(sound.channel)

				listeners -= mob
				if(!length(listeners)) listeners = null

atom
	var/tmp/list/_attached_soundmobs
	var/tmp/list/listeners = null

	proc/unsetListener(mob/mob)
		set waitfor=0

		if(mob in listeners && src in mob:_listening_soundmobs)
			var/tmp/sound/sound = mob:_listening_soundmobs[src]
			//world << "unsetListener"
			for(var/i = sound.volume, i >= 0, i --)
				sound.status = SOUND_UPDATE
				sound.volume = i
				sound.repeat = FALSE

				mob << sound

				sleep(1)

			mob << sound(null, 0, 0, sound.channel)
			mob:_unlockChannel(sound.channel)

			listeners -= mob
			if(!length(listeners)) listeners = null
	Del()
		if(_attached_soundmobs) for(var/soundmob/soundmob in _attached_soundmobs) del(soundmob)
		//else return
		//world << "atom Del"
		..()

	//Move()
		//..()

		//_updateAttachedSoundmobListeners()

	proc
		_attachSoundmob(soundmob/soundmob)
			if(!(soundmob in _attached_soundmobs))
				if(!_attached_soundmobs) _attached_soundmobs = list()
				_attached_soundmobs += soundmob
				//world<<"atom attachSoundmob"
		_detachSoundmob(soundmob/soundmob)
			if(soundmob in _attached_soundmobs)
				_attached_soundmobs -= soundmob
				if(!length(_attached_soundmobs)) _attached_soundmobs = null
				//world<<"atom detachSoundmob"
		_updateAttachedSoundmobListeners()
			if(_attached_soundmobs)
				for(var/soundmob/soundmob in _attached_soundmobs)
					if(soundmob.attached)
						soundmob.updateListener()
			else return
			//world << "atom updateAttachedSoundmobListeners"

obj
	var/tmp
		list/_listening_soundmobs = null
		list/_channels_taken = null

	New()
		..()

		spawn() if(src in world && _autotune_soundmobs) for(var/soundmob/soundmob in _autotune_soundmobs) listenSoundmob(soundmob)

	Del()
		if(_listening_soundmobs) for(var/soundmob/soundmob in _listening_soundmobs) unlistenSoundmob(soundmob)
		//else return
		//world << "obj Del"
		..()

	//Move()
		//..()

		//_updateListeningSoundmobs()

	proc
		_unlockChannel(channel)
			if(channel in _channels_taken)
				_channels_taken -= channel
				if(!length(_channels_taken)) _channels_taken = null

		_lockChannel(channel)
			if(!(channel in _channels_taken))
				if(!_channels_taken) _channels_taken = list()
				_channels_taken += channel

		_updateListeningSoundmobs()
			if(_listening_soundmobs)
				for(var/soundmob/soundmob in _listening_soundmobs)
					soundmob.setListener(src)

		_getAvailableChannel()
			for(var/channel = _channel_reserve_start, channel <= _channel_reserve_end, channel++)
				if(!(channel in _channels_taken)) return channel

			CRASH("You've managed to use a ridiculous number of channels. You're doing it wrong.")

		listenSoundmob(soundmob/soundmob)
			if(!(soundmob in _listening_soundmobs))
				if(!_listening_soundmobs) _listening_soundmobs = list()
				_listening_soundmobs += soundmob
				if(soundmob.attached)
					soundmob.updateListener(src)

		unlistenSoundmob(soundmob/soundmob)
			if(soundmob in _listening_soundmobs)
				var/sound/sound = _listening_soundmobs[soundmob]
				_channels_taken -= sound.channel

				_listening_soundmobs -= soundmob
				if(!length(_listening_soundmobs)) _listening_soundmobs = null
				soundmob.unsetListener(src)