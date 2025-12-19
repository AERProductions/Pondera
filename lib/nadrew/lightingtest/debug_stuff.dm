// This is just stuff for the demo, verbs, randomly moving mob, stuff like that.

mob
	var/tmp/zonks=0
	Login()
		..()
		client.screen += new/obj/cpu_display()
		// To keep track of world.cpu.

	random_mover
		// Just a randomly moving mob with a randomly generated light variation.
		New()
			..()
			light = new(src.loc)
			light.alpha = rand(120,255)
			light.color = rgb(rand(120,255),rand(120,255),rand(120,255))
			var/matrix/m = new()
			m.Scale(rand(3,6))
			light.transform = m
			walk_rand(src,5)

	verb
		// Verbs for altering the light source's transform, alpha, and color stuffs.

		Light_translate(n as num)
			if(!light) return
			var/matrix/m = light.transform
			m.Translate(n)
			animate(light,transform=m,time=4)

		Light_invert()
			if(!light) return
			var/matrix/m = light.transform
			m.Invert()
			animate(light,transform=m,time=4)

		Light_reset()
			if(!light) return
			light.transform = null
			light.color = null

		Light_rotate(angle as num)
			if(!light) return
			var/matrix/m = light.transform
			m.Turn(angle)
			animate(light,transform=m,time=4)

		Light_state()
			if(!light) return
			var/state = input("What icon_state do you want to set your light to?")as null|anything in icon_states(light.icon)
			if(isnull(state)) return
			light.icon_state = "[state]"

		Light_scale(n as num)
			if(!light) return
			var/matrix/m = matrix()
			m.Scale(n)
			light.transform = m

		Light_alpha(n as num)
			if(light) light.alpha = n

		Light_color(c as color)
			if(light) light.color = c

		// For creating a lamp.
		New_Lamp()
			new/obj/lamp(src.loc)
			src << "Click the lamp to toggle it."

		// And changing the darkness level.
		Darkness_level(n as num)
			if(darkness) darkness.alpha = n

		// Cough...

		ZOINKS()
			animate(master_plane,transform = matrix()*rand(2,6),time=5,loop=5)
			animate(master_plane,transform = null,time=5,loop=5)

		ZONKS()
			zonks = !zonks
			while(zonks)
				var/matrix/m = master_plane.transform
				m.Turn(90)
				animate(master_plane,transform=m,time=10,loop=0)
				sleep(10)

obj
	cpu_display
		screen_loc = "1,1"
		plane = 3
		maptext_width = 256
		New()
			..()
			spawn(1)
				while(src)
					maptext = "<font color=white>CPU: [world.cpu]%</font>"
					sleep(10)
