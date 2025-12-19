world
	hub = "Koil.soundobj"
	version = 2

var/const
	_channel_reserve_start = 756
	_channel_reserve_end = 1024

var/list/_autotune_soundobjs = null


proc
	_addAutotuneSoundobj(soundobj/soundobj)
		if(!(soundobj in _autotune_soundobjs))
			if(!_autotune_soundobjs) _autotune_soundobjs = list()
			_autotune_soundobjs += soundobj

			soundobj.broadcast(world)

	_removeAutotuneSoundobj(soundobj/soundobj)
		if(soundobj in _autotune_soundobjs)
			_autotune_soundobjs -= soundobj
			if(!length(_autotune_soundobjs)) _autotune_soundobjs = null

	soundobj(atom/movable/attached, radius = 0, file, autotune = TRUE, channel = 0, volume = 100)
		ASSERT(attached && file)

		return new/soundobj(attached, radius, file, autotune, channel, volume)

soundobj
	var
		atom/movable/attached = null
		list/listeners = null

		file = null
		autotune = TRUE
		channel = 0

		radius = 0

		volume = 100
		frequency = 0
		pan = 0

		priority = 0

		environment = -1
		list/echo = null

	New(atom/movable/_attached, _radius = 0, _file, _autotune = TRUE, _channel = 0, _volume = 100)
		ASSERT(_attached && _file && _radius)

	New(obj/_attached, _radius = 0, _file, _autotune = TRUE, _channel = 0, _volume = 100)
		ASSERT(_attached && _file && _radius)

		attached = _attached

		if(_file) file = _file
		if(_radius) radius = _radius
		if(_autotune) autotune = _autotune
		if(_channel) channel = _channel
		if(_volume) volume = _volume

		_attached._attachSoundobj(src)

		if(autotune) _addAutotuneSoundobj(src)

	Del()
		attached._detachSoundobj(src)
		if(autotune) _removeAutotuneSoundobj(src)
		unsetListeners()

	proc
		broadcast(target = world)
			for(var/obj/obj in target) if(src) obj.listenSoundobj(src)

		unsetListeners()
			if(listeners) for(var/obj/obj in listeners) unsetListener(obj)

		updateListeners()
			if(listeners) for(var/obj/obj in listeners) updateListener(obj)

		updateListener(obj/obj)
			ASSERT(attached)
			ASSERT(obj)
			ASSERT(src)
			ASSERT(src in obj._listening_soundobjs)

			if(!obj._listening_soundobjs[src])
				var/tmp/sound/s = new(file)
				obj._listening_soundobjs[src] = s

			var/tmp/sound/sound = obj._listening_soundobjs[src]

			if(!sound.channel) sound.channel = obj._getAvailableChannel()
			if(!(sound.channel in obj._channels_taken)) obj._lockChannel(sound.channel)

			sound.repeat = TRUE

			// I'm not using sound.x, y, and z because you aren't really able to set a maximum distance using those.
			// You're always able to hear the sound atleast a little regardless of how far it is away.
			// This could probably be improved a bit.

			if(obj.x == attached.x) sound.pan = 0
			if(obj.x > attached.x) sound.pan = -75
			if(obj.x < attached.x) sound.pan = 75

			var/tmp/distance = sqrt((obj.x - attached.x) * (obj.x - attached.x) + (obj.y - attached.y) * (obj.y - attached.y))
			sound.volume = volume - (distance / radius * volume)

			sound.frequency = frequency

			sound.priority = priority

			sound.environment = environment
			sound.echo = echo

			sound.status = SOUND_UPDATE

			obj << sound

		setListener(obj/obj)
			ASSERT(src)

			if(!(obj in listeners))
				if(!listeners) listeners = list()
				listeners += obj

				updateListener(obj)

		unsetListener(obj/obj)
			if(obj in listeners && src in obj._listening_soundobjs)
				var/tmp/sound/sound = obj._listening_soundobjs[src]

				for(var/i = sound.volume, i >= 0, i --)
					sound.status = SOUND_UPDATE
					sound.volume = i

					obj << sound

					sleep(1)

				obj << sound(null, 0, 0, sound.channel)
				obj._unlockChannel(sound.channel)

				listeners -= obj
				if(!length(listeners)) listeners = null

atom/movable
	var/list/_attached_soundobjs = null

	Del()
		if(_attached_soundobjs) for(var/soundobj/soundobj in _attached_soundobjs) del(soundobj)

		..()

	Move()
		..()

		_updateAttachedSoundobjListeners()

	proc
		_attachSoundobj(soundobj/soundobj)
			if(!(soundobj in _attached_soundobjs))
				if(!_attached_soundobjs) _attached_soundobjs = list()
				_attached_soundobjs += soundobj

		_detachSoundobj(soundobj/soundobj)
			if(soundobj in _attached_soundobjs)
				_attached_soundobjs -= soundobj
				if(!length(_attached_soundobjs)) _attached_soundobjs = null

		_updateAttachedSoundobjListeners()
			if(_attached_soundobjs) for(var/soundobj/soundobj in _attached_soundobjs) soundobj.updateListeners()

obj
	var
		list/_listening_soundobjs = null
		list/_channels_taken = null

	New()
		..()

		spawn() if(src && _autotune_soundobjs) for(var/soundobj/soundobj in _autotune_soundobjs) listenSoundobj(soundobj)

	Del()
		if(_listening_soundobjs) for(var/soundobj/soundobj in _listening_soundobjs) unlistenSoundobj(soundobj)

		..()

	Move()
		..()

		_updateListeningSoundobjs()

	proc
		_unlockChannel(channel)
			if(channel in _channels_taken)
				_channels_taken -= channel
				if(!length(_channels_taken)) _channels_taken = null

		_lockChannel(channel)
			if(!(channel in _channels_taken))
				if(!_channels_taken) _channels_taken = list()
				_channels_taken += channel

		_updateListeningSoundobjs()
			if(_listening_soundobjs)
				for(var/soundobj/soundobj in _listening_soundobjs)
					soundobj.updateListener(src)

		_getAvailableChannel()
			for(var/channel = _channel_reserve_start, channel <= _channel_reserve_end, channel ++)
				if(!(channel in _channels_taken)) return channel

			CRASH("You've managed to use a ridiculous number of channels. You're doing it wrong.")

		listenSoundobj(soundobj/soundobj)
			if(!(soundobj in _listening_soundobjs))
				if(!_listening_soundobjs) _listening_soundobjs = list()
				_listening_soundobjs += soundobj
				soundobj.setListener(src)

		unlistenSoundobj(soundobj/soundobj)
			if(soundobj in _listening_soundobjs)
				var/tmp/sound/sound = _listening_soundobjs[soundobj]
				_channels_taken -= sound.channel

				_listening_soundobjs -= soundobj
				if(!length(_listening_soundobjs)) _listening_soundobjs = null
				soundobj.unsetListener(src)