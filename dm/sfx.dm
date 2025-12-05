/*
================================================================================
  Pondera Sound Effect System - Ambient & Environmental Sounds
================================================================================

This file defines all sound effect objects that provide ambient environmental
audio throughout Pondera. Each sound object creates a soundmob instance attached
to the object's location, which automatically manages player listening based on
proximity and audio range.

Sound Effect Categories:
- obj/soundmob/SFX/: Specialized sound effect objects (fire, river, rain)
- obj/snd/sfx/: Ambient environmental sounds (crickets, fire, wind, water, etc.)
- obj/snd/sfx/apof/: Ambient-point-of-focus sounds (waterfalls, forest ambience)
- obj/snd/sfx/bpob/: Biome-point-of-focus sounds (desert, oasis ambience)
- obj/snd/sfx/cpop/: Cold-point-of-focus sounds (snow, wind through trees)
- obj/snd/sfx/dpoh/: Desolate-point-of-focus sounds (wasteland ambience)
- obj/snd/sfx/epog/: Exotic-point-of-focus sounds (alien/otherworldly ambience)

Sound Soundmob Parameters:
- soundmob(src, range, file, autotune=TRUE, channel=null, volume, repeat=TRUE)
  - range: Audible distance in tiles
  - file: Sound file path
  - autotune: Automatically manage listeners
  - volume: Maximum volume (0-100)
  - repeat: Loop continuously

Note: Legacy commented soundmob turf variables removed (caused save file conflicts).
      Use sound effect objects instead of direct soundmob instances for persistence.

================================================================================
*/

/*  === LEGACY SOUNDMOB VARIABLE DECLARATIONS (Deprecated - Use Sound Effect Objects) ===

var/global/tmp/forestbirds1 = locate(598,309,2)
var/global/tmp/forestbirds2 = locate(122,433,2)
var/global/tmp/forestbirds3 = locate(314,582,2)
var/global/tmp/forestbirds4 = locate(612,617,2)
var/tmp/forestwind = locate(336,233,2)
var/tmp/forestwind1 = locate(344,258,2)
var/tmp/forestwind2 = locate(577,348,2)
var/tmp/forestwind3 = locate(339,359,2)
var/tmp/forestwind4 = locate(143,423,2)
var/tmp/forestwind5 = locate(382,602,2)
var/tmp/waves = locate(352,70,2)
var/tmp/waves2 = locate(564,196,2)
var/tmp/waves3 = locate(101,219,2)
var/tmp/waves4 = locate(425,311,2)
var/tmp/waves5 = locate(192,354,2)
var/tmp/waves6 = locate(540,421,2)
var/tmp/waves7 = locate(339,476,2)
var/tmp/waves8 = locate(58,531,2)
var/tmp/waves9 = locate(420,698,2)
var/tmp/oasis = locate(157,56,2)
var/tmp/desert = locate(92,101,2)
var/tmp/beach = locate(102,214,2)
var/tmp/snowwind = locate(64,624,2)
var/tmp/river = locate(397,620,2)
var/tmp/river2 = locate(595,623,2)
var/global/tmp/ref/soundmob/fb = soundmob(forestbirds, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
var/global/tmp/ref/soundmob/fb1 = soundmob(forestbirds1, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
var/global/tmp/ref/soundmob/fb2 = soundmob(forestbirds2, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
var/global/tmp/ref/soundmob/fb3 = soundmob(forestbirds3, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
var/global/tmp/ref/soundmob/fb4 = soundmob(forestbirds4, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/fw = soundmob(forestwind, 30, 'snd/hollowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/fw1 = soundmob(forestwind1, 30, 'snd/hollowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/fw2 = soundmob(forestwind2, 30, 'snd/hollowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/fw3 = soundmob(forestwind3, 30, 'snd/hollowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/fw4 = soundmob(forestwind4, 30, 'snd/hollowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/fw5 = soundmob(forestwind5, 30, 'snd/hollowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv = soundmob(waves, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv2 = soundmob(waves2, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv3 = soundmob(waves3, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv4 = soundmob(waves4, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv5 = soundmob(waves5, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv6 = soundmob(waves6, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv7 = soundmob(waves7, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv8 = soundmob(waves8, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wv9 = soundmob(waves9, 60, 'snd/waterfall.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/wf = soundmob(waterfall, 30, 'snd/waterfalldeep.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/oa = soundmob(oasis, 50, 'snd/creek.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/de = soundmob(desert, 150, 'snd/blowwind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/be = soundmob(beach, 30, 'snd/waves.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/sw = soundmob(snowwind, 149, 'snd/dizzywind.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/rv = soundmob(river, 160, 'snd/creek.ogg', FALSE, 0, 40, TRUE)
var/tmp/ref/soundmob/rv2 = soundmob(river2, 160, 'snd/creek.ogg', FALSE, 0, 40, TRUE)

*/  // End legacy variables

// --- Sound Effect Object Definitions ---
obj
	soundmob
		SFX
			no_save = TRUE
			fire3
				icon = 'dmi/64/blank.dmi'
				New()
					..()
					//soundmob(src, 30, 'snd/fire2a.ogg', TRUE, 0, 40)
					soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, null, 30, TRUE)
			river
				icon = 'dmi/64/blank.dmi'
				New()
					..()  
					soundmob(src, 15, 'snd/creek.ogg', TRUE, null, 15, TRUE)
			rain
				icon = 'dmi/64/blank.dmi'
				New()
					..()
					soundmob(src, 300, 'snd/lrain.ogg', TRUE, null, 20, TRUE)


obj

	snd
		no_save = TRUE
		sfx
			Del()
				world << sound(src)
				..()  
			density = 0
			crickets
				icon = 'dmi/64/blank.dmi'
				New()
					..()
//radius = 0, file, autotune = TRUE, channel = null, volume = 100, repeat = FALSE) Sound settings
					soundmob(src, 30, 'snd/nightcrickets.ogg', TRUE, null, 40, TRUE)
				Del()
					world << sound(src)
					..()

			waves
				icon = 'dmi/64/blank.dmi'
				New()
					..()
					soundmob(src, 40, 'snd/waterfall.ogg', TRUE, null, 30, TRUE)

			fire
				icon = 'dmi/64/blank.dmi'
				New()
					..()
					soundmob(src, 30, 'snd/fire.ogg', TRUE, null, 40, TRUE)
			fire2
				icon = 'dmi/64/blank.dmi'
				New()
					..()
					soundmob(src, 30, 'snd/fire2a.ogg', TRUE, null, 40, TRUE)
			fire3
				icon = 'dmi/64/blank.dmi'
				New()
					..()  
					soundmob(src, 15, 'snd/cleaned/fire2.ogg', FALSE, null, 40, TRUE)
			river
				icon = 'dmi/64/blank.dmi'
				New()
					..()  
					soundmob(src, 15, 'snd/creek.ogg', TRUE, null, 40, TRUE)
			beach
				icon = 'dmi/64/watr.dmi'
				icon_state = "bbd1"
				New()
					..()
					soundmob(src, 30, 'snd/wave.ogg', TRUE, null, 40, TRUE)
			apof
				waterfall
					icon = 'dmi/64/blank.dmi'

					New()
						..()
						soundmob(src, 30, 'snd/waterfalldeep.ogg', TRUE, null, 30, TRUE)
				forestwind
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 60, 'snd/hollowwind.ogg', TRUE, null, 30, TRUE)
				forestbirds
					icon = 'dmi/64/blank.dmi'
					//var/mob/players/M

					New()
						..()
						//if(client in world)
						//if(client in range(100,src))
								//var/waterfall = locate(510,645,2)
						soundmob(src, 100, 'snd/cycadas.ogg', TRUE, null, 40, TRUE)
						//var/soundmob/s = soundmob(src, 100, 'snd/cycadas.ogg', TRUE, 0, 40, TRUE)
						//if(src in range(100,/client))
						//	listenSoundmob(s)
							//for(usr)
								//_listening_soundmobs += usr
						//else
						//	if(usr in !range(100,src))
						//		unlistenSoundmob(s)
							//for(client in range(100,src))
						//client in range(100,src) << fb
								//M.listenSoundmob(fb)
						//for(client in range(src,700))
						//if(M.location=="Aldoryn")
						//var/tmp/mob/players/M
						//var/mob/players/M
						//M = usr
						//if(client in range(400,src))
						//soundmob(src, 100, 'snd/cycadas.ogg', TRUE, 0, 40, TRUE)
						/*if(M.client in world)
							var/soundmob/fb = new/soundmob(src.loc, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
							//var/mob/players/M
							//M = usr
							if(M.client in range(150,src))
							//var/soundmob/fb = new/soundmob(src, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
								M.listenSoundmob(fb)
							if(M.client in !range(src))
								M.unlistenSoundmob(fb)
								return*/
							//else if(M.location!="Aldoryn")
						//soundmob(src, 150, 'snd/cycadas.ogg', FALSE, 0, 40, TRUE)
			bpob
				desertamb
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 150, 'snd/blowwind.ogg', TRUE, null, 40, TRUE)
				oasisamb
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 50, 'snd/creek.ogg', TRUE, null, 40, TRUE)
			cpop
				snowwind
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 30, 'snd/dizzywind.ogg', TRUE, null, 40, TRUE)
				windthrutrees
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 150, 'snd/wind.ogg', TRUE, null, 40, TRUE)
			dpoh
				desolate
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 30, 'snd/wastewind.ogg', TRUE, null, 40, TRUE)
			epog
				dryair
					icon = 'dmi/64/blank.dmi'
					New()
						..()
						soundmob(src, 150, 'snd/alienwind.ogg', TRUE, null, 40, TRUE)
