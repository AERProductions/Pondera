audiohandler
	New(mob/P)
		owner = P
	var
		sound/sounds[0]
		tmp/mob/owner
		volume = 100
		musicVolume = 100 // Used by sounds with music if (audioFlags & SEPERATE_MUSIC_VOLUME) == TRUE
		audioFlags = 0
		muted = FALSE
	proc
		toggleSeperateVolume()
			audioFlags ^= SEPERATE_MUSIC_VOLUME
		toggleMute()
			if(!(audioFlags & GLOBAL_MUTE))
				audioFlags |= GLOBAL_MUTE
				for(var/X in sounds)
					muteSound(X)
			else
				audioFlags &= ~GLOBAL_MUTE
				for(var/X in sounds)
					var sound/S = sounds[X]
					if(ismusic(S))
						if(S.active_music)
							resumeSound(X)
					else
						S.status = SOUND_UPDATE
		setGlobalVolume(volume)
			volume = min(max(volume,0),100)
			src.volume = volume
			for(var/X in sounds)
				var sound/S = sounds[X]
				if((!ismusic(S)) || (!(audioFlags & SEPERATE_MUSIC_VOLUME)))
					S.volume = volume
				if(ismusic(S) && (!(audioFlags & SEPERATE_MUSIC_VOLUME)))
					if(S.active_music)
						resumeSound(X)
		setMusicVolume(volume)
			if(!(audioFlags & SEPERATE_MUSIC_VOLUME))
				setGlobalVolume(volume)
				return
			src.musicVolume = volume
			for(var/X in sounds)
				var sound/S = sounds[X]
				if(ismusic(S))
					S.volume = volume
					if(S.active_music)
						resumeSound(X)
		setRepeat(id)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id]
			S.repeat = S.repeat==FALSE ? TRUE : FALSE
			if(ismusic(S))
				resumeSound(id)

		setChannel(id,channel)
			if(!istext(id) || (!(id in sounds)) || !isnum(channel))return
			var/sound/S = sounds[id]
			S.channel = channel
			if(ismusic(S))
				resumeSound(id)

		setVolume(id,volume)
			if(!istext(id) || (!(id in sounds)) || !isnum(volume))return
			if(volume > 100)volume = 100
			else if(volume < 0)volume = 0
			var/sound/S = sounds[id]
			S.volume = volume
			if(ismusic(S))
				resumeSound(id)

		setPos(id,x=0,y=0,z=0)
			if(!istext(id) || (!(id in sounds)) || !isnum(x) || !isnum(y) || !isnum(z))return
			var/sound/S = sounds[id]
			S.x = x
			S.y = y
			S.z = z
			if(ismusic(S))
				resumeSound(id)

		setFrequency(id,frequency)
			if(!istext(id) || (!(id in sounds)) || !isnum(frequency))return
			var/sound/S = sounds[id]
			S.frequency = frequency
			resumeSound(id)

		setEnviroment(id,environment)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id]
			S.environment = environment
			if(ismusic(S))
				resumeSound(id)

		setEcho(id,echo)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id]
			S.echo = echo
			if(ismusic(S))
				resumeSound(id)

		setPriority(id,priority)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id]
			S.priority = priority
			if(ismusic(S))
				resumeSound(id)

		setPan(id,pan)
			if(!istext(id) || (!(id in sounds)) || !isnum(pan))return
			if(pan > 100)pan = 100
			else if(pan < -100)pan = -100
			var/sound/S = sounds[id]
			S.pan = pan
			if(ismusic(S))
				resumeSound(id)

		addSound(sound/S,id,autoplay=FALSE)
			if(!istext(id) || !issound(S) )return
			S.volume = src.volume
			sounds[id] = S
			if(src.muted==TRUE)
				muteSound(id)
			if(autoplay==TRUE)
				playSound(id)

		removeSound(id)
			if(!istext(id) || (!(id in sounds)))return
			muteSound(id)

			sounds -= id
		playSound(id)
			if(!istext(id) || (!(id in sounds)))return
			if(src.muted==TRUE)return
			var sound/S = sounds[id]
			if(ismusic(S))
				for(var/ids in sounds)
					var sound/SO = sounds[ids]
					if(SO.active_music)SO.active_music = FALSE
				S.active_music = TRUE
			owner << S

		pauseSound(id)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id] // use a reference that can be assigned to.
			S.status = SOUND_PAUSED | SOUND_UPDATE
			playSound(id)

		muteSound(id)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id] // use a reference that can be assigned to
			S.status = SOUND_MUTE | SOUND_UPDATE
			playSound(id)

		resumeSound(id)
			if(!istext(id) || (!(id in sounds)))return
			var/sound/S = sounds[id] // use a reference that can be assigned to
			S.status = SOUND_UPDATE
			playSound(id)