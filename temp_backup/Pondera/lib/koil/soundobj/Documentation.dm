/*
soundmob, by Koil

See Demo.dm for an easy to understand example.

soundmob is a 3D sound library that allows you to attach sounds (called soundmobs)
to movable atoms. You can then output the sound to a player and the sound will
automatically update itself so that it sounds as if it is moving with the atom
it is attached to.

There are two ways to create a soundmob. You can use the soundmob() proc, which returns
a /soundmob object, or you can create a /soundmob object directly. Both are created
as follows:


	var/soundmob/s = new/soundmob(attached, radius, file, autotune, channel, volume)
	var/soundmob/s = soundmob(attached, radius, file, autotune, channel, volume)

	Required Arguments:
		* attached: This is the movable atom that the soundmob is attached to.
		* radius: This is the maximum distance that a player can be from the sound
				  before it is too far to be heard. This also determines the rate
				  at which the volume of the sound diminishes with distance.
		* file: This is the sound file that will be played.

	Optional Arguments:
		* autotune: See below.
		* channel: You probably should leave this at it's default value of 0, because
					the library automatically manages available channels.
		* volume: This is 100 by default. This is the maximum volume that the sound will
					be played. The volume will not exceed this amount even if you are right
					on top of the soundmob.

The autotune argument can be set to TRUE (1) if you want players to automatically hear
the soundmob without having to manually send it to them. If autotune is set to TRUE, even
when a new player logs in, they will automatically be sent the sound, and they will hear it
if they are within radius of the soundmob.

If autotune is not set to TRUE, you will have to manually call the proc mob.listenSoundmob() with
the argument as the /soundmob object. unlistenSoundmob(/soundmob) will stop the player from hearing
the soundmob.

You'll want to keep a reference to the /soundmob objects you create around, because they must be
deleted (using del()) in order to completely stop the sound from playing and so the garbage
collector can kick in.

A movable atom can have as many soundmobs attached to it as you'd like.

Although it shouldn't matter, the library "reserves" the last 268 audio channels available (channels
756 - 1024). You probably shouldn't need this many channels. The library "locks" channels that are
currently being used by a soundmob, and "unlocks" them when done, so new soundmobs can use them. You will
get an error if you output more than 268 soundmobs to a single player. If you absolutely need more
channels than this, you can set the range of channels for the library to use by setting _channel_reserve_start
and _channel_reserve_end.
*/