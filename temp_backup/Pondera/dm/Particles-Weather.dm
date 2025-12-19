
particles/snow
	width = 1500
	height = 1500
	count = 2500
	spawning = 12
	bound1 = list(-1000, -300, -1000)
	lifespan = 600
	fade = 50
	position = generator("box", list(-600,350,0), list(600,400,50))
	gravity = list(0, -1)
	friction = 0.3
	drift = generator("sphere", 0, 2)

particles/rain
	width = 1500
	height = 1500
	count = 7500
	spawning = 36
	bound1 = list(-1000, -300, -1000)
	lifespan = 600
	fade = 50
	color = "f0f8ff"
	position = generator("box", list(-600,350,0), list(600,400,50))
	gravity = list(0, -0.5)

particles/clear
	width = 0
	height = 0
	count = 0
	spawning = 0
	bound1 = list(-1000, -300, -1000)
	lifespan = 1
	fade = 0
	//color = "f0f8ff"
	position = generator("box", list(-600,350,0), list(600,400,50))
	gravity = list(0, 0)


obj/clear
	screen_loc = "CENTER"
	particles = new/particles/clear

obj/snow
	screen_loc = "CENTER"
	particles = new/particles/snow
	//plane				= LIGHTING_PLANE
	New()
		..()
		soundmob(src, 300, 'snd/wind.ogg', TRUE, null, 15, FALSE)
	//vis_flags = VIS_HIDE
	//layer = 999
	Del()
		//world << sound(src)
		..()

obj/rain
	screen_loc = "CENTER"
	particles = new/particles/rain
	New()
		..()
		//var/mob/players/M
		//if(/mob/players.client in world)
		soundmob(src, 300, 'snd/lrain.ogg', TRUE, null, 30, FALSE)
		//new S
		//else return
	//vis_flags = VIS_HIDE
	//layer = 999
	Del()//sound garbage collection needs cleaned up so you can stop single sounds and not all sounds
		//var/sound/S = /obj/soundmob/SFX/rain
		//for(S in world)
			//del S
			//S << sound(S)
		//rld << sound(src)
			//del S
		//del(src)
		//world << sound(src)//cuts all sound off, need a better way
		..()


mob/players/Special1
	verb
		Create1()
			CreateRain()
		Create2()
			CreateSnow()
		Cancel()
			CreateClear()
			//client?.screen += new/obj/clear
			//client?.screen = null
	proc/CreateClear()
		//particles.spawning = 0
		client?.screen -= /particles/snow
		client?.screen -= /particles/rain
		client?.screen += new/obj/clear
	proc/CreateSnow()
		client?.screen += new/obj/snow
	proc/CreateRain()
		client?.screen += new/obj/rain