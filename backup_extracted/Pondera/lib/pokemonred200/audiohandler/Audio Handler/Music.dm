sound
	var
		music = FALSE
		active_music = FALSE

proc
	music(file,repeat=1,wait,channel,volume=100)
		var sound/S = sound(file,repeat,wait,channel,volume)
		S.music = 1
		S.status = SOUND_STREAM
		return S