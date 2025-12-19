/************************************************************************

Sound System Library

The primary function of this library is to allow fade in and out effects
for music as well as volume control for music and sound. For music, the
library reserves channels 1 and 2, so that it can fade back and forth
between channels. When you alternate musics, it will fade out one channel
while at the same time fading in the other, so you hear seamless music
playing at all times and avoid the harsh stops and starts.

Sound effects played through this library will be played at the current
volume setting for sound effects. Music volume can be changed at any time
and the music that is currently playing will reflect the changes. Sound
effects however, will not reflect volume changes while playing.


Instructions:

	This library automatically assigns a sound_system datum to each client
	as client.sound_system. You can work with the sound system through
	that variable. This is a list of functions that you can use:

	_________
	PlaySound

		Eg: client.sound_system.PlaySound('sound.wav', location, environment, frequency, altitude_layer)

		This will play the specified sound file for the client at the volume
		specified by the sound volume setting. You can also modify the way
		that the sound file sounds to the hearer through the other arguments:

		soundfile - The sound file to play.

		location - Assign this to a turf, obj or mob if you want the sound
			effect to sound as though its coming from that object.

		environment - If you want to include environment modifications (if
			you don't have a good sound card you probably won't notice the
			difference), you can assign a specific environment to the sound
			effect.

		frequency - Chance the playback rate of the sound file, from -100 to 100.

		altitude_layer - This is the 'layer' variable by default, but if you
			want to change the variable used to determine an object's altitude,
			you can change the name of the variable used with this argument.

	__________
	AlterMusic

				********************************************************
				***  NOTE: You'll probably want to be using this if  ***
				*** you'll be playing background music in your game! ***
				********************************************************

		Eg: client.sound_system.AlterMusic('music.mid', increments)

		Eg: client.sound_system.AlterMusic('music.mid', increments, time)

		This function alternates from one musical score to another seamlessly,
		by fading out the previous song while at the same time fading in the
		new song. Just specify which song you want to play next and it will
		happen automatically. You can specify the number of times that the
		volume will adjust during the transition using the 'increments' value,
		and you can change the speed at which the transition happens by
		changing the 'time' value (in 1/10th seconds). The default transition
		time is 2 seconds.

		If there is no music playing, it will only fade in the new song.

	_________
	PlayMusic

		Eg: client.sound_system.PlayMusic('music.mid')

		Immediately starts playing the specified music file for the client.
		The music volume will reflect the current music volume settings.

	________
	EndMusic

		Eg: client.sound_system.EndMusic()

		Immediately stops whatever music is currently playing.

	___________
	MusicFade

		Eg: client.sound_system.MusicFadeIn(start, end, increments, time)

		With this you can cause the music to fade from one volume to another
		with the number of increments and at the speed you specify. The
		first two arguments are the starting volume and the ending volume,
		the number of increments is how many volume changes there will be
		during the transition, and the time is the speed at which the change
		takes place (in 1/10th seconds)

		If you set the starting value to NULL, it will automatically insert
		the volume that the music is currently at. Note that this is the
		music's volume, not the volume setting. If the music is currently
		in a fade, the music's volume at this point in the fade will be used.

		If you set the ending value to NULL, it will insert the volume setting.

	______________
	SetMusicVolume

		Eg: client.sound_system.SetMusicVolume(new_volume, increments, time)

		Causes the music volume to fade from its current volume to the newly
		specified volume - after which any music played will play at this
		volume. The increments value allows you to adjust how many volume
		changes there will be during the transition, and the time value allows
		you to specify how quickly the volume changes.

		Specifying zero increments or time will cause an instant change.

	______________
	SetSoundVolume

		Eg: client.sound_system.SetSoundVolume(new_volume)

		Sets the volume for any sound effects that will be played after the
		setting changes. Any sound effects currently playing will NOT reflect
		the change in volume.


	______________
	GetMusicVolume

		Eg: client.sound_system.GetMusicVolume()

		Returns the current music volume setting.


	______________
	GetSoundVolume

		Eg: client.sound_system.GetSoundVolume()

		Returns the current sound volume setting.




************************************************************************/