// This file is included in Audio Handler.dme only when not in use by other proects.
mob
	New()
		Audio.owner = src
		Audio.addSound(music(pick('Shell City Dead Ahead.ogg','Fantasy.ogg'),repeat=0),"123")
		Audio.setChannel("123",1)
		..()
	var/tmp/audiohandler/Audio=new
	verb
		playSound()
			Audio.playSound("123")
		pauseSound()
			Audio.pauseSound("123")
		muteSound()
			Audio.muteSound("123")
		resumeSound()
			Audio.resumeSound("123")
		setVolume(x as num)
			Audio.setVolume("123",x)