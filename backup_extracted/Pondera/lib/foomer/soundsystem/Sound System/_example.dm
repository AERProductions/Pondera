
world
	tick_lag = 0.3


// Create an associative list of songs for testing purposes.

var/list/music_list = list("None" = null,)
var/list/sound_list = list()
var/list/music_extensions = list(".it", ".xm", ".mid", ".mod")
var/list/sound_extensions = list(".wav", ".ogg")
var/list/music_dirs = list("music/", "sample_music/")
var/list/sound_dirs = list("sound/", "sample_sound/")

mob/proc/ListMusic()

	for(var/dir in music_dirs)
		for(var/file in flist(dir))
			var/format_ok = 0
			for(var/extension in music_extensions)
				if(findtext(file, extension))
					format_ok = 1
					break

			if(format_ok)
				var/dot = findtext(file, ".")
				var/name = copytext(file, 1, dot)
				music_list[name] = file("[dir][file]")

mob/proc/ListSound()

	for(var/dir in sound_dirs)
		for(var/file in flist(dir))
			var/format_ok = 0
			for(var/extension in sound_extensions)
				if(findtext(file, extension))
					format_ok = 1
					break

			if(format_ok)
				var/dot = findtext(file, ".")
				var/name = copytext(file, 1, dot)
				sound_list[name] = file("[dir][file]")


mob/Login()
	src.ListMusic()
	src.ListSound()

	if(sound_list.len)
		last_sound = sound_list[pick(sound_list)]

	src.loc = locate(5,5,1)

	world << "Use PlaySound to select a sound effect, then click on the \
		map to play the sound effect at that location. Use arrow keys to move \
		the ear around, and you can change sound environments with the \
		SetEnvironment option."



var/list/environments = list(
	"generic" = 0,
	"padded cell" = 1,
	"room" = 2,
	"bathroom" = 3,
	"livingroom" = 4,
	"stoneroom" = 5,
	"auditorium" = 6,
	"concert hall" = 7,
	"cave" = 8,
	"arena" = 9,
	"hangar" = 10,
	"carpetted hallway" = 11,
	"hallway" = 12,
	"stone corridor" = 13,
	"alley" = 14,
	"forest" = 15,
	"city" = 16,
	"mountains" = 17,
	"quarry" = 18,
	"plain" = 19,
	"parking lot" = 20,
	"sewer pipe" = 21,
	"underwater" = 22,
	"drugged" = 23,
	"dizzy" = 24,
	"psychotic" = 25,
		)


// SOUNDS CONTROLS

var/sound/last_sound = null
mob/verb/PlaySound(sound as anything in sound_list)
	if(!sound)
		return
	src.client.sound_system.PlaySound(sound_list[sound], null, sound_environment)
	last_sound = sound_list[sound]

var/sound_environment = 0
mob/verb/SetEnvironment(new_env as anything in environments)
	if(!new_env)
		return
	sound_environment = environments[new_env]

mob/verb/SetSoundVolume(new_volume as num)
	if(!new_volume)
		return
	src.client.sound_system.SetSoundVolume(min(max(new_volume, 0), 100))
	src << "Sound Volume: [src.client.sound_system.sound_volume]"



// MUSIC CONTROLS

mob/verb/PlayMusic(song as anything in music_list)
	src.client.sound_system.PlayMusic(music_list[song])

mob/verb/SetMusicVolume(new_volume as num)
	src.client.sound_system.SetMusicVolume(new_volume)
	src << "Music Volume: [src.client.sound_system.music_volume]"

mob/verb/FadeOut()
	src.client.sound_system.MusicFade(null, 0)

mob/verb/FadeIn()
	src.client.sound_system.MusicFade(0, null)

mob/verb/EndMusic()
	src.client.sound_system.EndMusic()

mob/verb/AlterMusic(song as anything in music_list)
	src.client.sound_system.AlterMusic(music_list[song])






// These are the objects displayed on the sound map.

atom
	icon = 'icon.dmi'

turf
	icon_state = "space"
	layer = TURF_LAYER

	bird
		icon_state = "bird"
		layer = FLY_LAYER+10

	Click()
		if(last_sound)
			ShowSound()
			usr.client.sound_system.PlaySound(last_sound, src, sound_environment)
		else
			world << "Please select a sound file using PlaySound."

	MouseDrag()
		src.Click()


	proc/ShowSound()
		flick("sound", src)

mob
	icon_state = "ear"






