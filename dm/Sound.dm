#include "Basics.dm"
world



var/const
	_channel_reserve_start = 756
	_channel_reserve_end = 1024
var/global/upd = 0
var/tmp/list/_autotune_soundmobs = null
var/r = rand(1,700)
var/A = 0
proc
	_addAutotuneSoundmob(soundmob/soundmob)
		if(!(soundmob in _autotune_soundmobs))
			if(!_autotune_soundmobs) _autotune_soundmobs = list()
			_autotune_soundmobs += soundmob
			soundmob.broadcast(world)

	_removeAutotuneSoundmob(soundmob/soundmob)
		if(soundmob in _autotune_soundmobs)
			_autotune_soundmobs -= soundmob
			if(!length(_autotune_soundmobs)) _autotune_soundmobs = null

	soundmob(atom/attached, radius = 0, file, autotune = TRUE, channel = null, volume = 100, repeat = FALSE)
		if(!attached) ASSERT(attached && file) new/soundmob(attached, radius, file, autotune, channel, volume, repeat)

soundmob
	Write()
		return
	Read()
		return
	var
		atom/attached
		list/listeners = new

		file = null
		autotune = TRUE
		channel = 0
		repeat = FALSE
		radius = 0
		volume = 100
		frequency = 0
		pan = 0

		priority = 0

		environment = -1
		list/echo = null

	New(atom/_attached, _radius = 0, _file, _autotune = TRUE, _channel = 0, _volume = 100, _repeat = FALSE)
		//if(_attached) ASSERT(_attached && _file)


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
			var/tmp/update = volume - (distance / radius * volume)
			for(src&&sound)
				if(mob.x && mob.y && mob.z == attached.x && attached.y && attached.z) sound.pan = 0
				if(mob.x && mob.y && mob.z > attached.x && attached.y && attached.z) sound.pan = -75
				if(mob.x && mob.y && mob.z < attached.x && attached.y && attached.z) sound.pan = 75

				//if(mob in listeners && sound in mob._listening_soundmobs)
			sound:volume = update//volume - (distance / radius * volume)
			sound:frequency = frequency
			//sound:channel = channel
			sound:priority = priority
					//sound.repeat = repeat
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
				var/tmp/sound/s = new(src.file)
				mob:_listening_soundmobs[src] = s
			else return

			var/sound/sound = mob:_listening_soundmobs[src]

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
			//sound.channel = channel
			sound.priority = priority
			//sound.repeat = repeat
			sound.environment = environment
			sound.echo = echo

			sound.status = SOUND_STREAM
			src.listeners+=mob
			mob << sound

		unsetListener(mob/mob)

			if((mob in listeners) && (src in mob:_listening_soundmobs))
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

atom
	var/tmp/list/_attached_soundmobs
	var/tmp/list/listeners = null
/*
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
			if(!length(listeners)) listeners = null*/
	//Del()
		//if(_attached_soundmobs) for(var/soundmob/soundmob in _attached_soundmobs) del(soundmob)
		//else return
		//world << "atom Del"
		//..()

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

		//spawn() if(src in world && _autotune_soundmobs) for(var/soundmob/soundmob in _autotune_soundmobs) listenSoundmob(soundmob)

	//Del()
		//if(_listening_soundmobs) for(var/soundmob/soundmob in _listening_soundmobs) unlistenSoundmob(soundmob)
		//else return
		//world << "obj Del"
		//..()

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

		//_updateListeningSoundmobs()
			//if(_listening_soundmobs)
				//for(var/soundmob/soundmob in _listening_soundmobs)
					//soundmob.setListener(src)

		_getAvailableChannel()
			for(var/channel = _channel_reserve_start, channel <= _channel_reserve_end, channel ++)
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
				var/tmp/sound/sound = _listening_soundmobs[soundmob]
				_channels_taken -= sound.channel

				_listening_soundmobs -= soundmob
				if(!length(_listening_soundmobs)) _listening_soundmobs = null
				soundmob.unsetListener(src)