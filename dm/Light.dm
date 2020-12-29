#include "Mov.dm"
// File:    light-source.dm
// Library: Forum_account.DynamicLighting
// Author:  Forum_account
//
// Contents:
//   This file defines the light object which is used to
//   create light sources that are attached to objects.
//   The light can be attached to a stationary object
//   (ex: a turf) or a mobile object (ex: a player).

atom
	var/tmp
		light/light

light
	parent_type = /obj
	icon = 'start.dmi'
	//opacity = 1

	var/tmp
		// the atom the light source is attached to
		set popup_menu = 0
		set hidden = 1
		atom/owner

		// the radius, intensity, and ambient value control how large of
		// an area the light illuminates and how brightly it's illuminated.
		radius = 2
		intensity = 1
		ambient = 0

		radius_squared = 4

		// the coordinates of the light source - these can be decimal values
		__x = 0
		__y = 0
		__z = 2//initiate the light on this z level

		// whether the light is turned on or off.
		on = 1

		// this flag is set when a property of the light source (ex: radius)
		// has changed, this will trigger an update of its effect.
		changed = 1

		// this is used to determine if the light is attached to a mobile
		// atom or a stationary one.
		mobile = 0

		// This is the illumination effect of this light source. Storing this
		// makes it very easy to undo the light's exact effect.
		list/effect

	New(atom/a, radius = 3, intensity = 1)
		if(!a || !istype(a))
			CRASH("The first argument to the light object's constructor must be the atom that is the light source. Expected atom, received '[a]' instead.")

		owner = a

		if(istype(owner, /atom/movable))
			loc = center(owner.loc)//owner.loc
			mobile = 1
		else
			loc = owner
			mobile = 0

		src.radius = radius
		src.radius_squared = radius * radius
		src.intensity = intensity

		__x = owner.x
		__y = owner.y

		// the lighting object maintains a list of all light sources
		lighting.lights += src

	proc
		// this used to be called be an infinite loop that was local to
		// the light object, but now there is a single infinite loop in
		// the global lighting object that calls this proc.
		loop()

			// if the light is mobile (if it was attached to an atom of
			// type /atom/movable), check to see if the owner has moved
			if(mobile)

				// compute the owner's coordinates
				var/opx = owner.x
				var/opy = owner.y
				// if pixel movement is enabled we need to take step_x
				// and step_y into account
				if(lighting.pixel_movement)
					opx += owner:step_x / 64
					opy += owner:step_y / 64

				// see if the owner's coordinates match
				if(owner in world)
					locate(owner.x in world)
					locate(owner.y in world)
					if(opx != __x || opy != __y)
						__x = opx
						__y = opy
						changed = 1
				else if(owner.x && owner.y == null)
					return

			if(changed)
				//intensity = rand(1,3)
				apply()

		apply()

			changed = 0

			// before we apply the effect we remove the light's current effect.
			if(effect)

				// negate the effect of this light source
				for(var/shading/s in effect)
					s.lum(-effect[s])

				// clear the effect list
				effect.Cut()

			// only do this if the light is turned on and is on the map
			if(on && loc)

				// identify the effects of this light source
				effect = effect()

				// apply the effect
				for(var/shading/s in effect)
					s.lum(effect[s])

		// turn the light source on
		on()
			if(on) return

			on = 1
			changed = 1

		// turn the light source off
		off()
			if(!on) return

			on = 0
			changed = 1

		// toggle the light source's on/off status
		toggle()
			if(on)
				off()
			else
				on()

		radius(r)
			if(radius == r) return

			radius = r
			radius_squared = r * r
			changed = 1

		intensity(i)
			if(intensity == i) return

			intensity = i
			changed = 1

		ambient(a)
			if(ambient == a) return

			ambient = a
			changed = 1

		// compute the center of the light source, this is used
		// for light sources attached to mobs when you're using
		// pixel movement.
		center()
			if(istype(owner, /atom/movable))

				var/atom/movable/m = owner

				. = m.loc
				var/d = bounds_dist(m, .)//distance between owner and owners location

				for(var/turf/t in m.loc)//for turfs in owners location
					var/dt = radius(m, t)//distance between owner and turfs
					if(dt < d)//if the distance between owner/turf is lesser than the distance between owner and owner loc
						d = dt//owner/owner loc equals owner/turf
						. = t//owner equals turf
			else
				var/turf/t = owner
				while(!istype(t))
					t = t.loc

				return t

		// compute the total effect of this light source
		effect()

			var/list/L = list()

			for(var/shading/s in range(radius, owner))

				// we call this object's lum() proc to compute the illumination
				// value we contribute to each shading object, this way you can
				// override the lum() proc to change how lighting works but leave
				// this proc alone.
				var/lum = lum(s)

				if(lum > 0)
					L[s] = lum

			return L

		// compute the amount of illumination this light source
		// contributes to a single atom
		lum(atom/a)

			if(!radius)
				return 0

			// compute the distance to the tile, we use the __x and __y vars
			// so the light source's pixel offset is taken into account (provided
			// that's enabled)
			var/d = (__x - a.x) * (__x - a.x) + (__y - a.y) * (__y - a.y)

			// if the turf is outside the radius the light doesn't illuminate it
			if(d > radius_squared) return 0

			d = sqrt(d)

			// this creates a circle of light that non-linearly transitions between
			// the value of the intensity var and zero.
			return cos(90 * d / radius) * intensity + ambient

		/*light_dir(atom/a, atom/b)
			var/dx = b.x - a.x
			var/dy = b.y - a.y

			if(dy >= abs(dx))
				return NORTH
			if(dy <= -abs(dx))
				return SOUTH
			if(dx >= abs(dy))
				return EAST
			if(dx <= -abs(dy))
				return WEST

			return 0*/
	circle
		mouse_opacity = 0
		var
			set popup_menu = 0
			set hidden = 1
		lum(atom/a)
			var/d = (__x - a.x) * (__x - a.x) + (__y - a.y) * (__y - a.y)

			// if the turf is outside the radius the light doesn't illuminate it
			if(d > radius_squared) return 0

			d = sqrt(d)

			// this creates a circle of light that non-linearly transitions between
			// the value of the intensity var and zero.
			return cos(90 * d / radius) * intensity + ambient
		apply()
			var/mob/m = owner

				// only force an update of the entire view
				// for light sources attached to players
			if(istype(m) && m.client)
				for(var/shading/s in range(m.client.view + 1, m))

						// if we haven't updated this tile's ambient light
						// value, force an update
					if(s.ambient != ambient)
						s.lum(0)

			return ..()
	day_night
		apply()
			var/mob/m = owner

			// only force an update of the entire view
			// for light sources attached to players

			if(istype(m) && m.client)
				for(var/shading/s in range(m.client.view + 1, m))

						// if we haven't updated this tile's ambient light
						// value, force an update
					if(s.ambient != ambient)
						s.lum(0)
			else
				return

			return ..()

	square
		lum(atom/a)
			return radius - get_dist(src, a) + 1
		apply()
			var/mob/m = owner

				// only force an update of the entire view
				// for light sources attached to players
			if(istype(m) && m.client)
				for(var/shading/s in range(m.client.view + 1, m))

						// if we haven't updated this tile's ambient light
						// value, force an update
					if(s.ambient != ambient)
						s.lum(0)

			return ..()

	directional
		//dir =

		lum(atom/a)
			if(light_dir(src, a) == dir)
				return cos(30 / radius) * intensity
			else
				return 0

	proc
		// this is a helper proc we use to create directional lights
		light_dir(atom/a, atom/b)
			var/dx = b.x - a.x
			var/dy = b.y - a.y

			if(dy >= abs(dx))
				return NORTH
			if(dy <= -abs(dx))
				return SOUTH
			if(dx >= abs(dy))
				return EAST
			if(dx <= -abs(dy))
				return WEST

			return 0
	/*directional
		//move_dir

		lum(atom/movable/a)
			mobile=1
			dir = move_dir
			var/d = sqrt((__x + a.x) - (__x / a.x) / (__y + a.y) - (__y / a.y))
			//center(d, a)
			d = sqrt(d)
			// if the turf is outside the radius the light doesn't illuminate it
			if(d > radius) return dir
			//if(d <= radius) return dir
			if(light_dir(src, a) == dir)
				center(d, a)
				return ..()
				//apply()

		apply()
			var/mob/m = owner

				// only force an update of the entire view
				// for light sources attached to players
			if(istype(m) && m.client)
				for(var/shading/s in range(m.client.view, m))

						// if we haven't updated this tile's ambient light
						// value, force an update
					if(s.ambient != ambient)
						s.lum(0)

			return ..()
			if(move_dir==null)
				//src = /light/directional
				//src.light.on=0
				return
		//	else
				//src.light.on=1
				//return
				//return SOUTH
			if(move_dir==NORTH)
					//src = /light/directional
				dir=NORTH
				return
					//return NORTH
			if(move_dir==SOUTH)
					//src = /light/directional
				dir=SOUTH
				return
					//return SOUTH
			if(move_dir==EAST)
					//src = /light/directional
				dir=EAST
				return
					//return EAST
			if(move_dir==WEST)
					//src = /light/directional
				dir=WEST
				return
				//return WEST
			//dir = move_dir
			//if(light_dir2(src, a) == move_dir)
				//return ..()
*/
			//var/d = sqrt((__x - a.x) * (__x - a.x) + (__y - a.y) * (__y - a.y))
			//locate(a)//light.dir = a.move_dir
			/*if(istype(a,/atom/movable)) //if this is a movement between two turfs
				var/dx = a.x - x //get the distance delta
				var/dy = a.y - y
				if(z==a.z&&abs(dx)<=1&&abs(dy)<=1) //if only moving one tile on the same plane, mark the current move as a slide and figure out the move_dir
					move_dir = 0
					//move_flags = MOVE_SLIDE
					if(dx>0) move_dir |= EAST
					else if(dx<0) move_dir |= WEST
					if(dy>0) move_dir |= NORTH
					else if(dy<0) move_dir |= SOUTH
				//for(a)
				if(dy>0)
						//for(a)
					light = new/light/directional(src,3)
					dir = NORTH//stat("dir", "up")
					//return cos(30 / d / radius) * intensity
				if(dy<0)
					light = new/light/directional(src,3)//for(a)
					dir = SOUTH//stat("dir", "down")
					//return cos(30 / d / radius) * intensity
				if(dx>0)
					light = new/light/directional(src,3)//for(a)
					dir = EAST//stat("dir", "right")
					//return cos(30 / d / radius) * intensity
				if(dx<0)
					light = new/light/directional(src,3)//for(a)
					dir = WEST*/
					//return cos(30 / d / radius) * intensity
		//..()
					//stat("dir", "left")
					//stat("dir", dir)
			//else
				//return 0

mob/players/
	proc
		DIRL()
			if(istype(M,/atom/movable)) //if this is a movement between two turfs
				var/dx = M.x - x //get the distance delta
				var/dy = M.y - y
				if(z==M.z&&abs(dx)<=1&&abs(dy)<=1) //if only moving one tile on the same plane, mark the current move as a slide and figure out the move_dir
					move_dir = 0
					//move_flags = MOVE_SLIDE
					if(dx>0) move_dir |= EAST
					else if(dx<0) move_dir |= WEST
					if(dy>0) move_dir |= NORTH
					else if(dy<0) move_dir |= SOUTH
				//for(a)
				if(dy>0)
						//for(a)
					light = new/light/directional(src,3)
					light.dir = NORTH//stat("dir", "up")
					//return cos(30 / d / radius) * intensity
				if(dy<0)
					light = new/light/directional(src,3)//for(a)
					light.dir = SOUTH//stat("dir", "down")
					//return cos(30 / d / radius) * intensity
				if(dx>0)
					light = new/light/directional(src,3)//for(a)
					light.dir = EAST//stat("dir", "right")
					//return cos(30 / d / radius) * intensity
				if(dx<0)
					light = new/light/directional(src,3)//for(a)
					light.dir = WEST
		/*UDIR()
			if(M.dir == NORTH)
					//stat("dir", "up")
				else if(M.dir == SOUTH)
					//stat("dir", "down")
				else if(M.dir == EAST)
					//stat("dir", "right")
				else if(M.dir == WEST)
					//stat("dir", "left")
				else
					//stat("dir", dir)
					*/


obj
	var/Planted = 0
	var/Pname = ""
	var/Scount = 0
	var/Lit
	//proc


obj
	Buildable
		Fire
			density = 1
			plane = 4
			luminosity = 1
			icon = 'dmi/64/fire.dmi'
			icon_state = "emptyfire"
			name = "Empty Fire"
			buildingowner = ""
			var/sleeptime = 0
			var/soundmob/s
			var/sound = /obj/snd/sfx/fire3
			light = /light/circle
			New()
				..()
				//light = new /light/circle(src, 6)
				//light.on = 0
				//sound = /snd/sfx/fire3
					//soundmob(src, 30, 'snd/fire2a.ogg', TRUE, 0, 40)
				//else src << sound(null)
				//return
			//DblClick()
			verb/Bake_Jar()
				set waitfor = 0
				//set src in oview(1)
				set popup_menu = 1
				set category = null
				var/mob/players/M
				var/obj/items/tools/UnbakedJar/J
				//var/random/R = rand(1,5) //1 in 5 chance to smith
				M = usr
				if(usr.GVequipped==1)
					if(J in M.contents)
						input("Bake a Jar?","Bake") in list("Yes","No")
						if("No")
							return
						if("Yes")
							for(J in M.contents)
								if(J.name=="Unbaked Jar"&&usr.GVequipped==1)
									M<<"You start to bake the [J.name] on the [src.name]..."
									//sleep(5)
									var/dice = "1d8"
									var/R = roll(dice)
									if(R>=4)
										J.RemoveFromStack(1)
										src.overlays += image('dmi/64/inven.dmi',"UBJar")
										sleep(15)
										src.overlays -= image('dmi/64/inven.dmi',"UBJar")
										M<<"You finish baking the [J.name] and create a Jar."
										new /obj/items/tools/Jar(src.loc)
										//del src
										return
									if(R<=4)
										J.RemoveFromStack(1)
												//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at baking and are lost in the process."
										return
					else
						M << "You need an Unbaked Jar to continue..."
						return
				else
					M << "You'll need your Gloves on to handle this item after Baking."
					return
			verb
				Heat()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					var/mob/players/M
					M = usr
					for(var/obj/items/Ingots/J in M.contents)
						if((J in M.contents)&&(src.name=="Lit Fire"))
							//var/obj/items/Kindling/J = locate() in M.contents
							if(J.Tname!="Hot")
								M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J]."
								sleep(30)
								//J.RemoveFromStack(1)
								//src.overlays -= overlays
								//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
								//light.off()
								J:Tname="Hot"
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] is hot."
							//else
								//M<<"[J] is already Hot"
								//call(proc/Temp)(J)
								return
					for(var/obj/items/Ingots/Scraps/J in M.contents)
						if((J in M.contents)&&(src.name=="Lit Fire"))
							//var/obj/items/Kindling/J = locate() in M.contents
							if(J.Tname!="Hot")
								M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J]."
								sleep(15)
								//J.RemoveFromStack(1)
								//src.overlays -= overlays
								//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
								//light.off()
								J:Tname="Hot"
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] is hot."
							//else
							//	M<<"[J] is already Hot"
								return
				Cook()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					var/mob/players/M
					var/obj/items/Food/J = list("Giu Meat","Carp","Perch","Sunfish")
					M = usr
					if(M.cooking==1)
						M<<"Already cooking..."
						return
					if((src in oview(1))&&(src.name=="Lit Fire"))
						//switch(input("Cook?","Cook") in J)//list("Giu Meat")//,"Salmon","Trout","Bass","Catfish","Carp","Perch","Sunfish")
						if(J in M.contents)
							if(J.name=="Cooked Giu Meat")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Gou Meat")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Gow Meat")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Guwi Meat")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Gowu Meat")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							//fish
							if(J.name=="Cooked Salmon")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Trout")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Bass")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Catfish")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Carp")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Perch")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							if(J.name=="Cooked Sunfish")
								M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Already cooked."
								return 0
							else
								switch(input("Cook?","Cook") in J)//list("Giu Meat")//,"Salmon","Trout","Bass","Catfish","Carp","Perch","Sunfish")
									if("Giu Meat")
										var/random/R = rand(1,13)
										if(R!=7)
											M<<"You start to cook the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire..."
											//sleep(5)
											M.cooking = 1
											J.RemoveFromStack(1)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											sleep(35)
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
											new /obj/items/Food/GiuMeatC(M,1)
											M.cooking = 0
											return
										else
											M.cooking = 1
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											sleep(45)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											new /obj/items/Food/OCM(M,1)
											M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
											M.cooking = 0
											return
									if("Gou Meat")
										var/random/R = rand(1,12)
										if(R!=4)
											J.RemoveFromStack(1)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GouMeat")
											sleep(15)
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GouMeat")
											M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
											new /obj/items/Food/GouMeatC(locate(x,y,z))
											return
										else
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GouMeat")
											sleep(20)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GouMeat")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											new /obj/items/Food/OCM(locate(x,y,z))
											M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
											return
									if("Gow Meat")
										var/random/R = rand(1,10)
										if(R!=6)
											J.RemoveFromStack(1)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GowMeat")
											sleep(15)
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GowMeat")
											M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
											new /obj/items/Food/GowMeatC(locate(x,y,z))
											return
										else
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GowMeat")
											sleep(20)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GowMeat")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											new /obj/items/Food/OCM(locate(x,y,z))
											M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
											return
									if("Guwi Meat")
										var/random/R = rand(1,9)
										if(R!=2)
											J.RemoveFromStack(1)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GuwiMeat")
											sleep(15)
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GuwiMeat")
											M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
											new /obj/items/Food/GuwiMeatC(locate(x,y,z))
											return
										else
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GuwiMeat")
											sleep(20)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GuwiMeat")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											new /obj/items/Food/OCM(locate(x,y,z))
											M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
											return
									if("Gowu Meat")
										var/random/R = rand(1,7)
										if(R!=3)
											J.RemoveFromStack(1)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GowuMeat")
											sleep(15)
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GowuMeat")
											M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
											new /obj/items/Food/GowuMeatC(locate(x,y,z))
											return
										else
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GowuMeat")
											sleep(20)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GowuMeat")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
											new /obj/items/Food/OCM(locate(x,y,z))
											M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
											return
									//fish
									if("Salmon")
										var/random/R = rand(1,9)
										if(M.fishinglevel >= 5)
											if(R!=5)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/salmonC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R2 = rand(1,6)
											if(R2!=2)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/salmonC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="salmon")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Trout")
										if(M.fishinglevel >= 5)
											var/random/R = rand(1,11)
											if(R!=6)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="trout")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="trout")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/troutC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="trout")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="trout")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R2 = rand(1,7)
											if(R2!=4)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="trout")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="trout")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/troutC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="trout")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="trout")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Bass")
										if(M.fishinglevel >= 5)
											var/random/R = rand(1,12)
											if(R!=6)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="bass")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="bass")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/bassC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="bass")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="bass")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R = rand(1,8)
											if(R!=6)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="bass")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="bass")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/bassC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="bass")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="bass")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Catfish")
										if(M.fishinglevel >= 5)
											var/random/R = rand(1,13)
											if(R!=7)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/catfishC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R = rand(1,9)
											if(R!=7)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/catfishC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="catfish")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Carp")
										if(M.fishinglevel >= 5)
											var/random/R = rand(1,14)
											if(R!=4)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/carpC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R = rand(1,10)
											if(R!=4)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/carpC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Perch")
										if(M.fishinglevel >= 5)
											var/random/R = rand(1,15)
											if(R!=8)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="perch")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="perch")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/perchC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="perch")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="perch")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R = rand(1,12)
											if(R!=8)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="perch")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="perch")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/perchC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="perch")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="perch")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Sunfish")
										if(M.fishinglevel >= 5)
											var/random/R = rand(1,16)
											if(R!=9)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/sunfishC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/random/R = rand(1,13)
											if(R!=9)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] on the fire."
												new /obj/items/Food/sunfishC(locate(x,y,z))
												return
											else
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
					else if(src.name!="Lit Fire")
						M<<"\  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'> Fire needs to be lit."
						return
			/*Fuel(obj/items/J)
				set src in oview(1)
				set category = "Commands"
				var/mob/players/M
				M = usr
				var/list/L[1]
				var/C = 1
				for(J as obj in M.contents)
					var/Carbon = /obj/items/Carbon
					J = locate() in M.contents
					if(J.type==Carbon)
						J.RemoveFromStack(1)
						src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carbon")
						sleep(10)
						src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carbon")
						M<<"You finish burning in the fire."
						new /obj/items/Activated_Carbon(locate(x,y,z))*/
				Burn()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					//set hidden = 1
					var/mob/players/M
					M = usr
					//var/obj/items/Carbon/J = locate() in M.contents
					if((src in oview(1)) && (src.name=="Lit Fire") && (M.Doing==0))
						var/obj/items/Carbon/J = locate() in M.contents
						//var/obj/items/Carbon/C
						if(J.stack_amount>=2)
							for(J in M.contents)
								J.RemoveFromStack(2)
								M.Doing=1
								src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="Carbon")
								sleep(10)
								src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="Carbon")
								src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="charcoal")
								M<<"You finish burning and produce \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Activated Carbon."
								src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="charcoal")
								new /obj/items/Activated_Carbon(M, 1)
								M.Doing=0
								return
							//else return
						else
							M<<"You need Carbon to continue."
					else return
				Smelt_Iron()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set hidden = 1
					set category = null//"Commands"
					var/mob/players/M
					M = usr
					var/obj/items/Ore/iron/J = locate() in M.contents
					if((src in oview(1)) && (src.name=="Lit Fire") && (M.Doing==0))
						if(M.SHMequipped==1)
							var/IronOre = /obj/items/Ore/iron
							//J = locate() in M.contents
							if(J.stack_amount>=2)
								if(J.type==IronOre&&J in M.contents)
									J.RemoveFromStack(2)
									M.Doing=1
									src.overlays += icon(icon='dmi/64/build.dmi', icon_state="iron")
									sleep(30)
									src.overlays -= icon(icon='dmi/64/build.dmi', icon_state="iron")
									sleep(10)
									src.overlays += icon(icon='dmi/64/build.dmi', icon_state="ib")
									M<<"You finish smelting in the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>fire and produce two objects \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='HH'> <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CKB'>."
									sleep(10)
									src.overlays -= icon(icon='dmi/64/build.dmi', icon_state="ib")
									new /obj/items/Crafting/Created/HammerHead(M)
									new /obj/items/Crafting/Created/CKnifeblade(M)
									M.Doing=0
									return
								else return
							else
								M<<"You need \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>iron ore to continue."
						else
							M<<"You need to be holding \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'>Stone Hammer to continue."
					else return
				/*Snuff_Fire()
					set src in oview(1)
					set category = "Commands"
					var/mob/players/M
					M = usr
					if(src in oview(1))
						//var/obj/items/Kindling/J = locate() in M.contents
						if(src.name=="Lit Fire")
							M<<"You snuff the fire."
							sleep(5)
							//J.RemoveFromStack(1)
							Scount+=1
							src.overlays -= icon('dmi/64/fire.dmi',icon_state="LF")
							src.overlays += icon('dmi/64/fire.dmi',icon_state="unlitfire")
							light.off()
							src:name="Unlit Fire"*/
				Add_Kindling()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					var/mob/players/M
					M = usr

					if(src in oview(1))
						var/obj/items/Kindling/J = locate() in M.contents
						if((J in M.contents) && (src.name=="Empty Fire"))
							//set popup_menu = 1
							M<<"You add the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] onto the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='emptyfire'>empty fire."
							sleep(5)
							J.RemoveFromStack(1)
							src.sleeptime += 120
							src.overlays += icon('dmi/64/fire.dmi',icon_state="unlitfire")
							src:name="Unlit Fire"
							//else
								//M<<"Can only add kindling to an empty fire."
						//else
							//set popup_menu = 0
				Fuel_Fire()
					set waitfor = 0
					set src in oview(1)
					set category = "Commands"
					var/mob/players/M
					M = usr
					if(M.Doing==0)
						var/obj/items/Kindling/J = locate() in M.contents
						if(src.name=="Unlit Fire")
							M<<"You need to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire to fuel it."
							return 0
						if(src.name=="Empty Fire")
							M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>lit fire to fuel."
							return 0
						if(src.name=="Fueled Fire")
							M<<"\  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire already Fueled."
							return 0
						if(M.CKequipped==1&&M.FLequipped==1&&src.name=="Unfueled Fire")
							M<<"You start to fuel the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>fire."
							M.Doing=1
							sleep(5)
							J.RemoveFromStack(1)
							src:name="Fueled Fire"
							M<<"You fuel the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
							src.sleeptime += 1500
							//light.on()
							M.Doing=0
							//flick('fire.dmi',src)
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="LF")
							//light = new /light/circle(src, 9)
							//sleep(490)
							//src:name="Unfueled Fire"
							//new /light/circle(src, 9)
							//M<<"The Fire is starting to go out"
							//src:name="Unfueled Fire"
							//src.overlays -= icon('dmi/64/fire.dmi',icon_state="LF")
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="FF")
							//del(src.light)
							//light = new /light/circle(src, 6)
							//sleep(49)
							//light.off()
							//M<<"The Fire goes out"
							//src.overlays -= icon('dmi/64/fire.dmi',icon_state="FF")
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
							//src:name="Empty Fire"
						else
							usr << "You need to use the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife with the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint on an <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>Unlit Fire to Light it!"
					else
						usr << "You are already lighting the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire..."
				Light_Fire()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					//set hidden = 1
					var/mob/players/M
					var/Carbon = /obj/items/Carbon
					var/random/R = rand(1,9)
					//var/sound = /snd/sfx/fire3
					src.s = new/soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
					///S = soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
					M = usr
					if(src.Scount==5)
						M<<"The snuffed material turns to ash \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='outfire'>"
						src:Scount=0
						src:name="Empty Fire"
					if(M.Doing==0)
						//var/obj/items/tools/Flint/J = locate() in M.contents
					else
						usr << "Already lighting the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire..."
						return
					if(src.name=="Lit Fire")
						M<<"\  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire already Lit."
						return 0
					if(src.name=="Empty Fire")
						M<<"Add \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>kindling to light the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='emptyfire'>fire."
						//unlistenSoundmob(sound)
						return
					//else
					if(M.CKequipped==1&&M.FLequipped==1&&src.name=="Unlit Fire")
						//var/sound = soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						//var/sstop = sound(src, 0, 'snd/cleaned/fire2.ogg', FALSE, 7, 0)
						M<<"You start to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire."
						M.Doing=1
								//sleep(5)
								//J.RemoveFromStack(1)
						src:name="Lit Fire"
						M<<"You light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
						light = new /light/circle(src, 6)
						src:name="Unfueled Fire"
						//if(src.sleeptime > 120)
							//src:name="Fueled Fire"
						//if(src.name=="Feuled Fire")
						//if(src.name=="Lit Fire")
							//M << S
						//sound = soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						//new sound(src.loc)
						M.listenSoundmob(s)
					//	else
							//sound = soundmob(src, 15, 'snd/cleaned/fire2.ogg', FALSE, 0, 60, FALSE)
							//listenSoundmob(sound)
						//else
							//unlistenSoundmob(sound)
						//M<<sound
						//new /light/circle(src, 6)
						light.on()
								//if(src.name=="Lit Fire")
								//soundmob(src, 30, 'snd/fire2a.ogg', TRUE, 0, 40)
								//else src << sound(null)
						M.Doing=0
								//flick('fire.dmi',src)
						src.overlays += image('dmi/64/fire.dmi',icon_state="LF")
								//light = new /light/circle(src, 9)
						sleep(src.sleeptime)
								//new /light/circle(src, 9)
						//M<<"The Fire is dying"
						//src.overlays -= image('dmi/64/fire.dmi',icon_state="LF")
						//src.overlays += image('dmi/64/fire.dmi',icon_state="FF")
								//src:name="Unfueled Fire"
						sleep(src.sleeptime)
						//light.off()
						//Del(sound)
						//M<<sound(null)
						//Del(sound)
						//M<<sound
						M<<"The Fire dies \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='outfire'>"
						light.off()
						sleep(5)
						del(light)

						//call(/soundmob/proc/unsetListener)(usr)
						//_detachSoundmob(sound)
						//unlistenSoundmob(sound)
						//_listening_soundmobs -= src
						if(R>=4)	// make sure we haven't reached limit
							new Carbon(src.loc)
						//Del(sound)
						//new /obj/Buildable/Fire(src.loc)
						src.overlays -= image('dmi/64/fire.dmi',icon_state="LF")
						//src.overlays -= image('dmi/64/fire.dmi',icon_state="FF")
						src.overlays += image('dmi/64/fire.dmi',icon_state="outfire")
								//src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
						src:name="Empty Fire"
						//if(src.name=="Empty Fire")
						M.unlistenSoundmob(s)//sound for fire is finally fixed! wow...
						src.sleeptime = 0
							//del(sound)
							//for(sound in src)
								//_detachSoundmob()
							//for(sound in src.loc)
						//call(/soundmob/proc/unsetListeners)(sound)
									//call(/atom/proc/_updateAttachedSoundmobListeners)()
									//unlistenSoundmob()
									//_listening_soundmobs -= usr
								//Del()
									//_updateListeningSoundmobs(src)
						//call(/soundmob/Del)(sound)
								//call(/atom/Del)(sound)
								//call(/mob/Del)(sound)
								//call(/obj/Del)(sound)
						//Del(sound)
						//call(/atom/Del)(sound)
							//Del(sound)
						//del(s)
						//del(src)
						//sleep(1)
						//del(sound)
						//_detachSoundmob(sound)
						//Del(sound)
						//if(R>=4)	// make sure we haven't reached limit
							//new Carbon(src.loc)
						//call(/mob/proc/unlistenSoundmob)(M)
						//src.light.off()
						//M<<sstop
						//src.light.radius = 0
						//light = null
						//sleep(5)

						//return
						//del(src)
						//else return
					else
						usr << "You need to use the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife with the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint on an <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>Unlit Fire to Light it!"
						return

				Ignite_Novice_Fire()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					set hidden = 1
					var/mob/players/M
					//var/firesfx = /snd/sfx/fire2
					//var/soundmob/s = soundmob(src, 30, 'snd/cleaned/fire2.ogg', TRUE, 0, 150)
					//var/Carbon = /obj/items/Carbon
					//var/random/R = rand(1,9)
					M = usr
					if(src.Scount==5)
						M<<"The snuffed material turns to ash \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='outfire'>"
						src:Scount=0
						src:name="Empty Fire"
					if(M.Doing==0)
						//var/obj/items/tools/Flint/J = locate() in M.contents
						if(src.name=="Lit Fire")
							M<<"\  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire already Lit."
							return 0
						if(src.name=="Empty Fire")
							M<<"Add \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>kindling to light the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='emptyfire'>fire."
							return
						else
							if(M.PYequipped==1&&M.FLequipped==1&&src.name=="Unlit Fire")
								M<<"You start to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire."
								M.Doing=1
								sleep(5)
								//J.RemoveFromStack(1)
								src:name="Lit Fire"
								M<<"You light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
								//var/soundmob/s = new/soundmob(usr, 30, 'snd/cleaned/fire2.ogg', TRUE, 0, 150)
								//new firesfx
								world << soundmob(usr, 30, 'snd/cleaned/fire2.ogg', TRUE, 0, 150)
								light.on()
								M.Doing=0
								//flick('fire.dmi',src)
								src.overlays += icon('dmi/64/fire.dmi',icon_state="LF")
								//light = new /light/circle(src, 9)
								sleep(300)
								//new /light/circle(src, 9)
								M<<"The Fire is dying"
								//src.overlays -= icon('dmi/64/fire.dmi',icon_state="LF")
								//src.overlays += icon('dmi/64/fire.dmi',icon_state="FF")
								//src:name="Unfueled Fire"
								sleep(300)
								src.overlays += icon('dmi/64/fire.dmi',icon_state="FF")
								//soundmob(src, 0, 'snd/cleaned/fire2.ogg', TRUE, 0, 0)
								sleep(10)
								light.off()
								M<<"The Fire dies"
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="LF")
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="FF")
								src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
								//src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
								src:name="Empty Fire"
								//if(R==4)	// make sure we haven't reached limit
								//	new Carbon(src.loc)
								//else return
							else
								usr << "Need to use \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Pyrite'>Pyrite with the <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint on an <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>Unlit Fire to Light it!"
					else
						usr << "Already lighting the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire..."
	townlamp
		density = 0
		plane = 4
		layer = MOB_LAYER+1
		//luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "brasslamp"
		name = "Empty Torch"
		Pname = "Town Lamp"
		Lit = 1
		light = /light/circle
		disallow_in = NORTH
		disallow_out = SOUTH
		Cross(atom/movable/O)
			if(disallow_in)
				if(disallow_in & O.dir)
					return 0
				. = ..()

		Uncross(atom/movable/O)
			if(disallow_out)
				if(disallow_out & O.dir)
					return 0
				. = ..()
		New()
			..()

				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
			light = new /light/circle(loc, 4)
	Buildable
		lamps
			//can_stack=TRUE
			disallow_in = NORTH
			disallow_out = SOUTH
			Cross(atom/movable/O)
				if(disallow_in)
					if(disallow_in & O.dir)
						return 0
					. = ..()

			Uncross(atom/movable/O)
				if(disallow_out)
					if(disallow_out & O.dir)
						return 0
					. = ..()
			verb
				Ignite_Lamp()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					//set hidden = 1
					//set src in usr
					var/WoodenTorch=/obj/Buildable/lamps/woodentorch
					var/IronLamp=/obj/Buildable/lamps/ironlamp
					var/CopperLamp=/obj/Buildable/lamps/copperlamp
					var/BronzeLamp=/obj/Buildable/lamps/bronzelamp
					var/BrassLamp=/obj/Buildable/lamps/brasslamp
					var/SteelLamp=/obj/Buildable/lamps/steellamp
					var/mob/players/M
					M = usr
					if(M.Doing==0)
						var/obj/Buildable/lamps/J = locate() in oview(1)
						if(src.name=="Lit Lamp")
							M<<"You already lit the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]."
							return 0
						if(src.name=="Empty Lamp")
							M<<"You need to add \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to light the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]."
							return 0
						if(src.Scount==5)
							M<<"The snuffed material turns to ash"
							src:Scount=0
							src:name="Empty Lamp"
						if(M.CKequipped==1&&M.FLequipped==1&&src.name=="Unlit Lamp")
							M<<"You start to ignite the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
							M.Doing=1
							sleep(5)
							//lamps



							if(J.type==WoodenTorch)
								src:name="Lit Lamp"
								M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
								light = new /light/circle(src, 2)
								M.Doing=0
								src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
								sleep(390)
								if(src.name=="Unlit Lamp")
									return 0
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
								sleep(5)
								src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
								del light
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
								src:name="Empty Lamp"




							if(J.type==IronLamp)
								src:name="Lit Lamp"
								M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
								light = new /light/circle(src, 4)
								M.Doing=0
								src.overlays += icon('dmi/64/fire.dmi',icon_state="ll")
								sleep(490)
								if(src.name=="Unlit Lamp")
									return 0
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp is burning away"
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="ll")
								//sleep(49)
								del light
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp turns to ash"
								src:name="Empty Lamp"
							if(J.type==CopperLamp)
								src:name="Lit Lamp"
								M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
								light = new /light/circle(src, 5)
								M.Doing=0
								src.overlays += icon('dmi/64/fire.dmi',icon_state="ll")
								sleep(590)
								if(src.name=="Unlit Lamp")
									return 0
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp is burning away"
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="ll")
								//sleep(49)
								del light
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp turns to ash"
								src:name="Empty Lamp"
							if(J.type==BrassLamp)
								src:name="Lit Lamp"
								M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
								light = new /light/circle(src, 7)
								M.Doing=0
								src.overlays += icon('dmi/64/fire.dmi',icon_state="ll")
								sleep(720)
								if(src.name=="Unlit Lamp")
									return 0
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp is burning away"
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="ll")
								//sleep(49)
								del light
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp turns to ash"
								src:name="Empty Lamp"
							if(J.type==BronzeLamp)
								src:name="Lit Torch"
								M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
								light = new /light/circle(src, 6)
								M.Doing=0
								src.overlays += icon('dmi/64/fire.dmi',icon_state="ll")
								sleep(690)
								if(src.name=="Unlit Lamp")
									return 0
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp is burning away"
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="ll")
								//sleep(49)
								del light
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp turns to ash"
								src:name="Empty Lamp"
							if(J.type==SteelLamp)
								src:name="Lit Torch"
								M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
								light = new /light/circle(src, 10)
								M.Doing=0
								src.overlays += icon('dmi/64/fire.dmi',icon_state="ll")
								sleep(690)
								if(src.name=="Unlit Lamp")
									return 0
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp is burning away"
								src.overlays -= icon('dmi/64/fire.dmi',icon_state="ll")
								//sleep(49)
								del light
								M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp turns to ash"
								src:name="Empty Lamp"
						else
							usr<<"Need to use your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint to light the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp."
					else
						usr << "You are already lighting the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> [src]..."
				Snuff_Lamp()
					set waitfor = 0
					set popup_menu = 1
					set category = null
					if(src.name=="Lit Lamp")
						set src in oview(1)
					//set category = "Commands"
					//set hidden = 1
					var/mob/players/M
					M = usr
					if(src in oview(1))
						//var/obj/items/Kindling/J = locate() in M.contents
						if(src.name=="Lit Lamp")
							M<<"You snuff the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Lamp."
							sleep(5)
							//J.RemoveFromStack(1)
							src.overlays -= overlays
							src:Scount+=1
							light.off()
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="snuffedfire")
							src:name="Unlit Lamp"
						else
							return
				Fuel_Lamp()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
				//	set src in usr
					set category = null//"Commands"
					//set hidden = 1
					var/mob/players/M
					M = usr
					if(src in oview(1))
						var/obj/items/Tar/J = locate() in M.contents
						if((J in M.contents) && (src.name=="Empty Lamp"))
							M<<"You add the [J] into the empty \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Lamp."
							sleep(5)
							J.RemoveFromStack(1)
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="unlitfire")
							src:name="Unlit Lamp"
								//else
									//M<<"Can only add kindling to an empty fire."
				Plant()
					set waitfor = 0
					set popup_menu = 1
					set src = usr.contents
					set category = null//"Commands"
					var/obj/Buildable/lamps/woodentorch/WoodenTorch
					var/obj/Buildable/lamps/ironlamp/IronLamp
					var/obj/Buildable/lamps/copperlamp/CopperLamp
					var/obj/Buildable/lamps/bronzelamp/BronzeLamp
					var/obj/Buildable/lamps/brasslamp/BrassLamp
					var/obj/Buildable/lamps/steellamp/SteelLamp
					var/obj/Buildable/lamps/J = locate() in usr.contents
					var/mob/players/M
					M = usr
					if(M.Doing==0)
						if(usr.Wequipped==1 && usr.Sequipped==1 && usr.LSequipped==1 && usr.AXequipped==1 && usr.WHequipped==1 && usr.JRequipped==1 && usr.FPequipped==1 && usr.PXequipped==1 && usr.SHequipped==1 && usr.HMequipped==1 && usr.SKequipped==1 && usr.HOequipped==1 && usr.CKequipped==1 && usr.FLequipped==1 && usr.PYequipped==1 && usr.OKequipped==1 && usr.SHMequipped==1 && usr.UPKequipped==1)
							M<<"You need your hands free of tools to Plant [J]! (To Pull it, you will need \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>Gloves)"
							return	//M.Doing=1
									//sleep(3)
						else if(usr.GVequipped==1)
							if(J.Pname=="Wooden Torch"&&J.Planted==0)
								for(WoodenTorch in M.contents)
										//	set src in usr.contents
									M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
									M.Doing=1
									sleep(39)
											//src.Planted = 1
												//del J:light
												//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
									new /obj/Buildable/lamps/woodentorch(usr.loc)//Move(src.loc)
									for(var/obj/Buildable/lamps/woodentorch/J1 in oview(1))
										J1:Planted = 1
									M<<"You Finish Planting the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground"
									M.Doing=0
									del J
									return
							if(J.Pname=="Iron Lamp"&&J.Planted==0)
								for(IronLamp in M.contents)
										//	set src in usr.contents
									M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
									M.Doing=1
									sleep(39)
											//src.Planted = 1
												//del J:light
												//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
									new /obj/Buildable/lamps/ironlamp(usr.loc)//Move(src.loc)
									for(var/obj/Buildable/lamps/ironlamp/J1 in oview(1))
										J1:Planted = 1
										//del WoodenTorch
									M<<"You Finish Planting the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground"
									M.Doing=0
									del J
										return
							if(J.Pname=="Copper Lamp"&&J.Planted==0)
								for(CopperLamp in M.contents)
										//	set src in usr.contents
									M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
									M.Doing=1
									sleep(39)
											//src.Planted = 1
												//del J:light
												//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
									new /obj/Buildable/lamps/copperlamp(usr.loc)//Move(src.loc)
									for(var/obj/Buildable/lamps/copperlamp/J1 in oview(1))
										J1:Planted = 1
										//del WoodenTorch
									M<<"You Finish Planting the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground"
									M.Doing=0
									del J
										return
							if(J.Pname=="Brass Lamp"&&J.Planted==0)
								for(BrassLamp in M.contents)
										//	set src in usr.contents
									M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
									M.Doing=1
									sleep(39)
											//src.Planted = 1
												//del J:light
												//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
									new /obj/Buildable/lamps/brasslamp(usr.loc)//Move(src.loc)
									for(var/obj/Buildable/lamps/brasslamp/J1 in oview(1))
										J1:Planted = 1
										//del WoodenTorch
									M<<"You Finish Planting the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground"
									M.Doing=0
									del J
										return
							if(J.Pname=="Bronze Lamp"&&J.Planted==0)
								for(BronzeLamp in M.contents)
										//	set src in usr.contents
									M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
									M.Doing=1
									sleep(39)
											//src.Planted = 1
												//del J:light
												//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
									new /obj/Buildable/lamps/bronzelamp(M.loc)//Move(src.loc)
									for(var/obj/Buildable/lamps/bronzelamp/J1 in oview(1))
										J1:Planted = 1
									//del WoodenTorch
									M<<"You Finish Planting the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground"
									M.Doing=0
									del J
										return
							if(J.Pname=="Steel Lamp"&&J.Planted==0)
								for(SteelLamp in M.contents)
										//	set src in usr.contents
									M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
									M.Doing=1
									sleep(39)
											//src.Planted = 1
												//del J:light
												//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
									new /obj/Buildable/lamps/steellamp(M.loc)//Move(src.loc)
									for(var/obj/Buildable/lamps/steellamp/J1 in oview(1))
										J1:Planted = 1
									//del WoodenTorch
									M<<"You Finish Planting the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground"
									M.Doing=0
									del J
										return
						else
							M<<"You need to use \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>gloves to do that..."
					else
						M<<"You are already Planting [J]..."
				Pull()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					var/WoodenTorch=/obj/Buildable/lamps/woodentorch
					var/IronLamp=/obj/Buildable/lamps/ironlamp
					var/CopperLamp=/obj/Buildable/lamps/copperlamp
					var/BronzeLamp=/obj/Buildable/lamps/bronzelamp
					var/BrassLamp=/obj/Buildable/lamps/brasslamp
					var/SteelLamp=/obj/Buildable/lamps/steellamp
					var/obj/Buildable/lamps/J = locate() in oview(1)
					var/mob/players/M
					M = usr
					if(M.Doing==0)
						if(M.GVequipped==1&&J.name!="Lit Lamp")
							//M.Doing=1
							//sleep(3)
							if(J.type==WoodenTorch&&J.Planted==1)
								M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
								M.Doing=1
								sleep(39)
								J:Planted = 0
								M.Doing=0
								//del J:light
								//J.light.off()
								//J.overlays -= icon('dmi/64/build.dmi',icon_state="ll")
								Move(M)
								M.energy -= 5
								M.updateEN()
								M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
							if(J.type==IronLamp&&Planted==1)
								M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
								M.Doing=1
								sleep(39)
								J:Planted = 0
								M.Doing=0
								del J:light
								J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
								Move(M)
								M.energy -= 5
								M.updateEN()
								M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
							if(J.type==CopperLamp&&Planted==1)
								M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
								M.Doing=1
								sleep(39)
								J:Planted = 0
								M.Doing=0
								del J:light
								J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
								Move(M)
								M.energy -= 5
								M.updateEN()
								M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
							if(J.type==BrassLamp&&Planted==1)
								M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
								M.Doing=1
								sleep(39)
								J:Planted = 0
								M.Doing=0
								del J:light
								J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
								Move(M)
								M.energy -= 5
								M.updateEN()
								M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
							if(J.type==BronzeLamp&&Planted==1)
								M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
								M.Doing=1
								sleep(39)
								J:Planted = 0
								M.Doing=0
								del J:light
								J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
								Move(M)
								M.energy -= 5
								M.updateEN()
								M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
							if(J.type==SteelLamp&&Planted==1)
								M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
								M.Doing=1
								sleep(39)
								J:Planted = 0
								M.Doing=0
								del J:light
								J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
								Move(M)
								M.energy -= 5
								M.updateEN()
								M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
						else
							M<<"You need to use \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>gloves on an Empty or Unlit Lamp to do that..."
					else
						M<<"You are already Pulling [J]..."
				//buildable lamps \|/
			woodentorch
				density = 0
				plane = 6
				luminosity = 1
				icon = 'dmi/64/build.dmi'
				icon_state = "woodentorch"
				name = "Empty Lamp"
				Pname = "Wooden Torch"
				Planted = 0
				light = /light/circle
				//disallow_in = NORTH
				//disallow_out = SOUTH
				New()
					..()
					soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//light = new /light/circle(src, 2)
					//light.on = 0

			ironlamp
				density = 0
				plane = 6
				luminosity = 1
				icon = 'dmi/64/build.dmi'
				icon_state = "ironlamp"
				name = "Empty Lamp"
				Pname = "Iron Lamp"
				light = /light/circle
				//disallow_in = NORTH
				//disallow_out = SOUTH
				New()
					..()
					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//light = new /light/circle(src, 2)
					//light.on = 0
			copperlamp
				density = 0
				plane = MOB_LAYER+3
				luminosity = 1
				icon = 'dmi/64/build.dmi'
				icon_state = "copperlamp"
				name = "Empty Lamp"
				Pname = "Copper Lamp"
				light = /light/circle
				//disallow_in = NORTH
				//disallow_out = SOUTH
				New()
					..()
					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//light = new /light/circle(src, 3)
					//light.on = 0
			brasslamp
				density = 0
				plane = 6
				luminosity = 1
				icon = 'dmi/64/build.dmi'
				icon_state = "brasslamp"
				name = "Empty Lamp"
				Pname = "Brass Lamp"
				light = /light/circle
				//disallow_in = NORTH
				//disallow_out = SOUTH
				New()
					..()
					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//light = new /light/circle(src, 4)
					//light.on = 0
			steellamp
				density = 0
				plane = 6
				luminosity = 1
				icon = 'dmi/64/build.dmi'
				icon_state = "steellamp"
				name = "Empty Lamp"
				Pname = "Steel Lamp"
				light = /light/circle
				//disallow_in = NORTH
				//disallow_out = SOUTH
				New()
					..()

			bronzelamp
				density = 0
				plane = 6
				luminosity = 1
				icon = 'dmi/64/build.dmi'
				icon_state = "bronzelamp"
				name = "Empty Lamp"
				Pname = "Bronze Lamp"
				light = /light/circle
				//disallow_in = NORTH
				//disallow_out = SOUTH
				New()
					..()
					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//light = new /light/circle(src, 6)
					//light.on = 0

	TownTorches
		Lit = 1
		Torch
			density = 0
			plane = MOB_LAYER+1
			Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "tt1"
			New()
				..()
				soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
				light = new /light/directional(loc, 8)
				light.dir = SOUTH
				light = new /light/circle(loc, 3)
		Torcha
			density = 1
			plane = 6
			Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "Torcha1"
			New()
				..()
				soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
				light = new /light/directional(src, 8)
				light.dir = NORTH
				light = new /light/circle(src, 3)
		Torchb
			density = 1
			plane = 6
			Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "Torchb1"
			New()
				..()
				soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
				light = new /light/directional(src, 8)
				light.dir = EAST
				light = new /light/circle(src, 3)
		Torchc
			density = 1
			plane = 6
			Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "Torchc1"
			New()
				..()
				soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
				light = new /light/directional(src, 8)
				light.dir = WEST
				light = new /light/circle(src, 3)
	castlwll5a
		name = "castlwll5a"
		density = 0
		mouse_opacity = 0
		plane = 6
		luminosity = 1
		Lit = 1
		icon = 'dmi/64/Castl.dmi'
		icon_state = "5a"
		New()
			..()
			soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			light = new /light/directional(src, 9)
			light.dir = pick(SOUTH)
			light = new /light/circle(src, 4)
	introof6a
		name = "introof6a"
		density = 0
		plane = 6
		mouse_opacity = 0
		opacity = 0
		Lit = 1
		luminosity = 1
		icon = 'dmi/64/Castl.dmi'
		icon_state = "r6a"
		New()
			..()
			soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			light = new /light/directional(src, 9)
			light.dir = pick(SOUTH)
			light = new /light/circle(src, 4)
	btmwll1a
		name = "btmwll1a"
		density = 0
		plane = 6
		Lit = 1
		mouse_opacity = 0
		opacity = 0
		luminosity = 1
		icon = 'dmi/64/Castl.dmi'
		icon_state = "btmwll1a"
		New()
			..()
			soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			light = new /light/directional(src, 9)
			light.dir = pick(SOUTH)
			light = new /light/circle(src, 4)
mob/players
	proc
		LD()
			set waitfor = 0
			if(usr.light.on==1)
				var/obj/items/torches/J = locate() in M.contents
				usr.light.on=1
				sleep(3)
				usr.light.intensity=0.8
				sleep(5)
				usr.light.intensity=1
				sleep(3)
				usr.light.intensity=1.1
					//sleep(5)
				usr.light.on=1
				//goto reset
				sleep(J.spawntime)
				if(J.spawntime<=0)

					return
				..()

			//else
				//return
obj/items/torches
	var/spawntime
	var/soundmob/s
	//New()
		//..()
		//soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
	verb
		Fuel_Torch()
			set waitfor = 0
			set category=null
			set popup_menu = 1
			//set hidden = 1
			var/mob/players/M
			M = usr
			if(src in usr)
				var/obj/items/Tar/J = locate() in M.contents
				if((J in M.contents) && (src.name=="Empty Torch"))
					M<<"You add the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] onto the empty <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."
					sleep(5)
					J.RemoveFromStack(1)
					//src.overlays += icon('dmi/64/fire.dmi',icon_state="unlitfire")
					src:name="Unlit Torch"
					return
				else
					M<<"Can only add \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to an empty <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>torch."
		Light_Torch()
			//set hidden = 1
			set category = null
			set popup_menu = 1
			set waitfor = 0
			//set src in usr
			var/HandTorch=/obj/items/torches/Handtorch
			var/IronHandLamp=/obj/items/torches/ironhandlamp
			var/CopperHandLamp=/obj/items/torches/copperhandlamp
			var/BronzeHandLamp=/obj/items/torches/bronzehandlamp
			var/BrassHandLamp=/obj/items/torches/brasshandlamp
			var/SteelHandLamp=/obj/items/torches/steelhandlamp
			//var/soundmob/tmp/s = new/soundmob(M, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 40, FALSE)
			var/mob/players/M = usr

			s = new(M, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, TRUE)

			var/obj/items/torches/J = locate() in M.contents
			if(M.Doing==0)
				//var/obj/items/torches/J = locate() in M.contents
				if(src.name=="Lit Torch")
					M<<"You already lit the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch."
					return 0
				if(src.name=="Empty Torch")
					M<<"You need to add \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to light the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."
					return 0
				if(src.name=="Snuffed Torch")
					//M<<"You start to reignite the Tar in the Torch"
					//M.Doing=1
					src.name="Unlit Torch"
					//src.Scount+=1
					//del torch
				if(src.Scount>=5)
					M << "You discard the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>torch as it is no longer viable..."
					M.Doing=0
					sleep(5)
					del (src)
					return
				if(M.CKequipped==1&&M.FLequipped==1&&src.name=="Unlit Torch")
					//s = new/soundmob(M, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 40, FALSE)
					M<<"You start to ignite the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch"
					M.Doing=1
					sleep(5)
					//if(J.type==HandTorch)

//					M.listenSoundmob(s)

					//sleep(J.spawntime)
					J:name="Lit Torch"

					if(J.name=="Dead Torch")//fixed?
						M.unlistenSoundmob(s)




					if(J.name=="Lit Torch"&&istype(src,/obj/items/torches/Handtorch)&&J.type==HandTorch)

						var/image/torch
						torch = image('dmi/64/hto.dmi')
						//J:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch"
						M.light = new/light/circle (M, 3)
						M.light.on=1
						M.light.mobile=1
						//if(M.light.on==1)
							//M.light.dir = M:move_dir
							//..()
						//M.listenSoundmob(s)
//						usr << torch
						M.overlays += torch
						//M.overlays += image('64/fire.dmi',icon_state="hto")

						J.overlays += image('64/fire.dmi',icon_state="bht")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						//else
							//if(M.light.on==1&&J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
						sleep(J.spawntime)
						if(J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						//sleep(25)
								//if(J.name=="Snuffed Torch")
									//return
									//for(J in M.contents)
							J.overlays -= image('64/fire.dmi',icon_state="bht")
							M.overlays -= torch
								//M.overlays -= image('64/fire.dmi',icon_state="hto")

							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
									//del src.light
						//M.unlistenSoundmob(s)

//							M.unlistenSoundmob(s)
							s.unsetListeners(M)
								//M._listening_soundmobs -= s
							M.light.off()
								//del(s)
							J:name="Empty Torch"
								//M.LD()
							return
							//else
								//return M << "Torch is out."





					if(J.name=="Lit Torch"&&istype(src,/obj/items/torches/ironhandlamp)&&J.type==IronHandLamp)//ILO lt
						var/torch
						torch = image('dmi/64/ILO.dmi',M)
						//J:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
						M.light = new/light/circle (M, 3)
						M.light.on=1
						M.light.mobile=1
						//if(M.light.on==1)
							//M.light.dir = M:move_dir
							//..()
						//M.listenSoundmob(s)
						usr << torch
						//M.overlays += image('64/fire.dmi',icon_state="hto")
						J.overlays += image('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						//else
							//if(M.light.on==1&&J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
						sleep(J.spawntime)
								//if(J.name=="Snuffed Torch")
									//return
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						sleep(25)
								//if(J.name=="Snuffed Torch")
									//return
									//for(J in M.contents)
						J.overlays -= image('64/fire.dmi',icon_state="lt")
								//M.overlays -= image('64/fire.dmi',icon_state="hto")

						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
									//del src.light
						J:name="Dead Torch"
						//M.unlistenSoundmob(s)
						if(J.name=="Dead Torch") M.unlistenSoundmob(s)
								//M._listening_soundmobs -= s
						M.light.off()
						del torch
								//del(s)
						J:name="Empty Torch"
								//M.LD()
						return
						/*var/torch
						torch = image('dmi/64/ILO.dmi',M)
						J:name="Lit Torch"
						M<<"You ignite the Torch"
						M.light = new (M, 4)
						usr << torch
						J.overlays += icon('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						if(M.light.on==1&&J.name=="Lit Torch")
							if(J.name=="Snuffed Torch")
								return
							sleep(J.spawntime)
							if(J.name=="Snuffed Torch")
								return
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
							sleep(25)
							if(J.name=="Snuffed Torch")
								return
								//for(J in M.contents)
							J.overlays -= icon('64/fire.dmi',icon_state="lt")
							J:name="Empty Torch"
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
								//del src.light
							M.light.off()
							del torch
							//M.LD()
							return
						else
							return M << "Torch is out."*/
					if(J.name=="Lit Torch"&&istype(src,/obj/items/torches/copperhandlamp)&&J.type==CopperHandLamp)//CLO lt
						var/torch
						torch = image('dmi/64/CLO.dmi',M)
						//J:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
						M.light = new/light/circle (M, 3)
						M.light.on=1
						M.light.mobile=1
						//if(M.light.on==1)
							//M.light.dir = M:move_dir
							//..()
						//M.listenSoundmob(s)
						usr << torch
						//M.overlays += image('64/fire.dmi',icon_state="hto")
						J.overlays += image('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						//else
							//if(M.light.on==1&&J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
						sleep(J.spawntime)
								//if(J.name=="Snuffed Torch")
									//return
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						sleep(25)
								//if(J.name=="Snuffed Torch")
									//return
									//for(J in M.contents)
						J.overlays -= image('64/fire.dmi',icon_state="lt")
								//M.overlays -= image('64/fire.dmi',icon_state="hto")

						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
									//del src.light
						J:name="Dead Torch"
						//M.unlistenSoundmob(s)
						if(J.name=="Dead Torch") M.unlistenSoundmob(s)
								//M._listening_soundmobs -= s
						M.light.off()
						del torch
								//del(s)
						J:name="Empty Torch"
								//M.LD()
						return
						/*var/torch
						torch = image('dmi/64/CLO.dmi',M)
						J:name="Lit Torch"
						M<<"You ignite the Torch"
						M.light = new (M, 5)
						usr << torch
						J.overlays += icon('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						if(M.light.on==1&&J.name=="Lit Torch")
							if(J.name=="Snuffed Torch")
								return
							sleep(J.spawntime)
							if(J.name=="Snuffed Torch")
								return
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
							sleep(35)
							if(J.name=="Snuffed Torch")
								return
								//for(J in M.contents)
							J.overlays -= icon('64/fire.dmi',icon_state="lt")
							J:name="Empty Torch"
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
								//del src.light
							M.light.off()
							del torch
							//M.LD()
							return
						else
							return M << "Torch is out."*/
					if(J.name=="Lit Torch"&&istype(src,/obj/items/torches/brasshandlamp)&&J.type==BrassHandLamp)//BRLO lt
						var/torch
						torch = image('dmi/64/BRLO.dmi',M)
						//J:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
						M.light = new/light/circle (M, 3)
						M.light.on=1
						M.light.mobile=1
						//if(M.light.on==1)
							//M.light.dir = M:move_dir
							//..()
						//M.listenSoundmob(s)
						usr << torch
						//M.overlays += image('64/fire.dmi',icon_state="hto")
						J.overlays += image('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						//else
							//if(M.light.on==1&&J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
						sleep(J.spawntime)
								//if(J.name=="Snuffed Torch")
									//return
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						sleep(25)
								//if(J.name=="Snuffed Torch")
									//return
									//for(J in M.contents)
						J.overlays -= image('64/fire.dmi',icon_state="lt")
								//M.overlays -= image('64/fire.dmi',icon_state="hto")

						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
									//del src.light
						J:name="Dead Torch"
						//M.unlistenSoundmob(s)
						if(J.name=="Dead Torch") M.unlistenSoundmob(s)
								//M._listening_soundmobs -= s
						M.light.off()
						del torch
								//del(s)
						J:name="Empty Torch"
								//M.LD()
						return
						/*var/torch
						torch = image('dmi/64/BRLO.dmi',M)
						J:name="Lit Torch"
						M<<"You ignite the Torch"
						M.light = new (M, 7)
						usr << torch
						J.overlays += icon('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						if(M.light.on==1&&J.name=="Lit Torch")
							if(J.name=="Snuffed Torch")
								return
							sleep(J.spawntime)
							if(J.name=="Snuffed Torch")
								return
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
							sleep(55)
							if(J.name=="Snuffed Torch")
								return
								//for(J in M.contents)
							J.overlays -= icon('64/fire.dmi',icon_state="lt")
							J:name="Empty Torch"
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
								//del src.light
							M.light.off()
							del torch
							//M.LD()
							return
						else
							return M << "Torch is out."*/
					if(J.name=="Lit Torch"&&istype(src,/obj/items/torches/bronzehandlamp)&&J.type==BronzeHandLamp)//BLO lt
						var/torch
						torch = image('dmi/64/BLO.dmi',M)
						//J:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
						M.light = new/light/circle (M, 3)
						M.light.on=1
						M.light.mobile=1
						//if(M.light.on==1)
							//M.light.dir = M:move_dir
							//..()
						//M.listenSoundmob(s)
						usr << torch
						//M.overlays += image('64/fire.dmi',icon_state="hto")
						J.overlays += image('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						//else
							//if(M.light.on==1&&J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
						sleep(J.spawntime)
								//if(J.name=="Snuffed Torch")
									//return
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						sleep(25)
								//if(J.name=="Snuffed Torch")
									//return
									//for(J in M.contents)
						J.overlays -= image('64/fire.dmi',icon_state="lt")
								//M.overlays -= image('64/fire.dmi',icon_state="hto")

						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
									//del src.light
						J:name="Dead Torch"
						//M.unlistenSoundmob(s)
						if(J.name=="Dead Torch") M.unlistenSoundmob(s)
								//M._listening_soundmobs -= s
						M.light.off()
						del torch
								//del(s)
						J:name="Empty Torch"
								//M.LD()
						return
					if(J.name=="Lit Torch"&&istype(src,/obj/items/torches/steelhandlamp)&&J.type==SteelHandLamp)//BLO lt
						var/torch
						torch = image('dmi/64/SLO.dmi',M)
						//J:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]"
						M.light = new/light/circle (M, 3)
						M.light.on=1
						M.light.mobile=1
						//if(M.light.on==1)
							//M.light.dir = M:move_dir
							//..()
						//M.listenSoundmob(s)
						usr << torch
						//M.overlays += image('64/fire.dmi',icon_state="hto")
						J.overlays += image('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						//else
							//if(M.light.on==1&&J.name=="Lit Torch")
								//if(J.name=="Snuffed Torch")
									//return
						sleep(J.spawntime)
								//if(J.name=="Snuffed Torch")
									//return
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						sleep(25)
								//if(J.name=="Snuffed Torch")
									//return
									//for(J in M.contents)
						J.overlays -= image('64/fire.dmi',icon_state="lt")
								//M.overlays -= image('64/fire.dmi',icon_state="hto")

						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
									//del src.light
						J:name="Dead Torch"
						//M.unlistenSoundmob(s)
						if(J.name=="Dead Torch") M.unlistenSoundmob(s)
								//M._listening_soundmobs -= s
						M.light.off()
						del torch
								//del(s)
						J:name="Empty Torch"
								//M.LD()
						return
						/*
						var/torch
						torch = image('dmi/64/BLO.dmi',M)
						J:name="Lit Torch"
						M<<"You ignite the Torch"
						M.light = new (M, 7)
						usr << torch
						J.overlays += icon('64/fire.dmi',icon_state="lt")
						//if(M.light.on==1)
							//M.Doing=0
							//while(M.light.on==1)
								//M.LD()
								//J.overlays += icon('64/fire.dmi',icon_state="bht")
								//sleep(J.spawntime)
						M.Doing=0
						if(J.name=="Snuffed Torch")
							return
						if(M.light.on==1&&J.name=="Lit Torch")
							if(J.name=="Snuffed Torch")
								return
							sleep(J.spawntime)
							if(J.name=="Snuffed Torch")
								return
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
							sleep(45)
							if(J.name=="Snuffed Torch")
								return
								//for(J in M.contents)
							J.overlays -= icon('64/fire.dmi',icon_state="lt")
							J:name="Empty Torch"
							M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
								//del src.light
							M.light.off()
							del torch
							//M.LD()
							return
						else
							return M << "Torch is out."*/
				else
					usr<<"Need to use your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint to light the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>torch."
			else
				usr << "You are already lighting the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch..."
		Light_Novice_Torch()
			set waitfor = 0
			set popup_menu = 1
			set category = null
			//set hidden = 1
			var/HandTorch=/obj/items/torches/Handtorch
			var/mob/players/M
			M = usr
			if(M.Doing==0)
				//var/obj/items/torches/J = src
				if(src.name=="Lit Torch")
					M<<"You already lit the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch."
					return 0
				if(src.name=="Empty Torch")
					M<<"You need to add \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to light the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."
					return 0
				if(src.Scount==5)
					M<<"The snuffed material turns to ash"
					src:Scount=0
					src:name="Empty Torch"
				if(M.FLequipped==1&&M.PYequipped==1&&src.name=="Unlit Torch")
					M<<"You start to ignite the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch"
					M.Doing=1
					sleep(5)
					src:name="Lit Torch"
					M.listenSoundmob(s)
					if(src.name=="Dead Torch") M.unlistenSoundmob(s)
					if(src.name=="Lit Torch"&&src.type==HandTorch)
						//src:name="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch"
						//M.light = new /light/directional(usr, 6)
						//M.light.dir = M.dir
						M.light = new (M, 3)
						//light.loc = M
						//light.on = 1//new /light/circle(M, 3)
						M.Doing=0
						src.overlays += icon('dmi/64/fire.dmi',icon_state="bht")
						//M.overlays += icon('dmi/64/fire.dmi',icon_state="[get_step(M,dir]")
						sleep(1240)
						if(src.name=="Unlit Torch") return 0
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						//if(src.name=="Unlit Torch") return 0
						sleep(149)
						src.overlays -= icon('dmi/64/fire.dmi',icon_state="bht")
						src:name="Dead Torch"
						if(src.name=="Dead Torch") M.unlistenSoundmob(s)
						//M.overlays -= icon('dmi/64/fire.dmi',icon_state="[M.dir]")
						src:name="Empty Torch"
						M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar in the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch turns to ash"
						//del src.light
						M.light.off()
						return
		Snuff_Torch()
			set popup_menu = 1
			set category = null
			set waitfor = 0
			//set hidden = 1
			var/mob/players/M=usr
			var/HandTorch=/obj/items/torches/Handtorch
			if(src.name=="Snuffed Torch")
				M.overlays -= image('dmi/64/hto.dmi',M)
			var/obj/items/torches/J

			for(J in M.contents)
				//var/obj/items/Kindling/J = locate() in M.contents
				if(src.name=="Lit Torch")
					//var/torch
					M<<"You snuff the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."
					sleep(5)
					//J.RemoveFromStack(1)
					if(J.type==HandTorch)
						M.overlays -= image('dmi/64/hto.dmi')
					J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
					J.Scount+=1
					M.light.off()
//					M.unlistenSoundmob(s)
					s.unsetListeners()
					//src.overlays += icon('dmi/64/fire.dmi',icon_state="snuffedfire")
					src:name="Snuffed Torch"
					//del torch
					return
				else
					continue
	Handtorch
		density = 1
		plane = 6
		//luminosity = 1
		icon = 'dmi/64/fire.dmi'
		icon_state = "ht"
		name = "Empty Torch"
		light = /light/circle
		spawntime = 240//good timing for sound>visual connection(when the "fire" goes out, the sound of burning stops, as well) better to simply link the sound file length with the timing of the light, as it is harder to force a sound to stop. Go with the flow!
		var/sound = /obj/snd/sfx/fire3 //var/soundmob/s = new soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40, FALSE) //this goes on the action
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
	//	light = /light/directional(src, 8)
	//	light.dir = usr.dir
			//light = new /light/circle(usr, 4)
			//light.off()
			//light.mobile = 1
	ironhandlamp
		density = 1
		plane = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "ironhandlamp"
		name = "Empty Torch"
		light = /light/circle
		spawntime = 1240
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//light = new /light/circle(src, 2)
			//light.on = 0
	copperhandlamp
		density = 1
		plane = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "copperhandlamp"
		name = "Empty Torch"
		spawntime = 1420
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//light = new /light/circle(src, 3)
			//light.on = 0
	brasshandlamp
		density = 1
		plane = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "brasshandlamp"
		name = "Empty Torch"
		spawntime = 1840
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//light = new /light/circle(src, 4)
			//light.on = 0
	bronzehandlamp
		density = 1
		plane = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "bronzehandlamp"
		name = "Empty Torch"
		spawntime = 1840
		New()
			..()

	steelhandlamp
		density = 1
		plane = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "steelhandlamp"
		name = "Empty Torch"
		spawntime = 3680
		New()
			..()
			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//light = new /light/circle(src, 6)
		//	light.on = 0


