// File:    light-source.dm
// Library: Forum_account.DynamicLighting
// Author:  Forum_account
//
// Contents:
//   This file defines the light object which is used to
//   create light sources that are attached to objects.
//   The light can be attached to a stationary object
//   (ex: a turf) or a mobile object (ex: a player).
/*
atom
	var/tmp
		light/light

light
	parent_type = /obj
	icon = 'dmi/start.dmi'
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
					locate(owner.x) in world
					locate(owner.y) in world
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
			density = 0
			//plane = 3
			layer = 9
			//luminosity = 1
			icon = 'dmi/64/fire.dmi'
			icon_state = "emptyfire"
			name = "Empty Fire"
			buildingowner = ""
			var/sleeptime = 400//fire needs to be setup so that it can store variables -- Right now the overlays don't load so it needs to be changed to icon states and this sleep time var does store the sleeptime so fires are instant
			var/soundmob/fire_sound = null  // Crackling fire ambient sound
			//var/soundmob/s
			//var/f3
			//var/s = /obj/snd/sfx/fire3
			//var/sound = /obj/snd/sfx/fire3
			////light = /light/circle
			//proc/QF()
				//if(s == 1)
					//s = /obj/snd/sfx/fire3
			proc/FindI()
				for(var/obj/items/Ingots/J)// Ingot
					locate(J)
					if(J:Tname=="Cool")
						return J
			proc/FindS()
				for(var/obj/items/Ingots/Scraps/J)// Scraps
					locate(J)
					if(J:Tname=="Cool")
						return J
			
			/**
			 * Fire initialization - called when fire is created
			 * Initializes fire sound using generalized object sound system
			 * Sound will automatically broadcast to nearby players
			 */
			New(location)
				..()
				// Initialize fire sound (non-empty fires get ambient crackling)
				if(src.name != "Empty Fire")
					fire_sound = AttachObjectSound(src, "fire", 250, 40)
			
			/**
			 * Fire cleanup - called when fire is deleted
			 * Stops ambient sound and removes all listeners
			 */
			Del()
				if(fire_sound)
					StopObjectSound(fire_sound)
				..()
			
			verb/Bake_Jar()
				set waitfor = 0
				set src in oview(1)
				set popup_menu = 1
				set category = null
				var/mob/players/M
				M = usr
				var/obj/items/tools/Containers/UnbakedJar/J = locate() in M.contents
				//var/R = rand(1,5) //1 in 5 chance to smith

				if(usr.GVequipped==1)
					if(J)
						var/BK = input("Bake a Jar?","Bake") in list("Yes","No")
						if(BK=="No")
							return
						if(BK=="Yes")
							//for(J in M.contents)
							if(J.name=="Unbaked Jar"&&usr.GVequipped==1)
								M<<"You start to bake the Clay on the Fire..."
								//sleep(5)
								var/dice = "1d8"
								var/R = roll(dice)
								if(R>=4)

									src.overlays += image('dmi/64/inven.dmi',"UBJar")
									sleep(15)
									src.overlays -= image('dmi/64/inven.dmi',"UBJar")
									M<<"You finish baking the Clay and create a Jar."
									new /obj/items/tools/Containers/Jar(src.loc)
									J.RemoveFromStack(1)
									//del src
									return
								if(R<=4)

											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									sleep(15)
									//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									M<<"The materials fail at baking and are lost in the process."
									J.RemoveFromStack(1)
									return
					else
						M << "You need an Unbaked Clay Jar to continue..."
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
					var/mob/players/M = usr
					
					// Check if fire is lit
					if(src.name != "Lit Fire")
						M << "This fire isn't lit."
						return
					
					// Get craftable items
					var/list/tool_parts = list()
					var/list/ingots = list()
					
					for(var/obj/items/Crafting/Created/item in M.contents)
						var/type_str = "[item.type]"
						if(findtext(type_str, "Handle") || findtext(type_str, "Blade") || findtext(type_str, "Head"))
							if(item:Tname != "Hot")
								tool_parts += item
					
					for(var/obj/items/Ingots/item in M.contents)
						if(item:Tname != "Hot")
							ingots += item
					
					var/list/choices = list()
					if(tool_parts.len) choices += "Tool Parts"
					if(ingots.len) choices += "Ingots"
					
					if(!choices.len)
						M << "You have nothing to heat."
						return
					
					choices += "Cancel"
					var/choice = input("What would you like to heat?", "Heat") in choices
					
					if(choice == "Cancel")
						return
					
					if(choice == "Tool Parts")
						var/selected = input(M, "Which tool part?", "Heat") as null|anything in tool_parts
						if(selected)
							var/obj/to_heat = selected
							if(to_heat in M.contents)
								M << "You begin to heat [to_heat]."
								sleep(30)
								to_heat:Tname = "Hot"
								M << "[to_heat] is now hot!"
								return
					
					if(choice == "Ingots")
						var/selected = input(M, "Which ingot?", "Heat") as null|anything in ingots
						if(selected)
							var/obj/to_heat = selected
							if(to_heat in M.contents)
								M << "You begin to heat [to_heat]."
								sleep(30)
								to_heat:Tname = "Hot"
								if(to_heat:ingot_type)
									to_heat:name = "[to_heat:ingot_type] Ingot (Hot)"
								M << "[to_heat] is now hot!"
								return
				Cook()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					var/mob/players/M
					M = usr
					var/obj/items/Food/J = locate() in M.contents
					var/list/F = new/list("")

					if(M.cooking==1)
						M<<"Already cooking..."
						return
					//M << "test"
					//locate(J in M.contents)
					if(src.name=="Lit Fire"||src.name=="Fueled Fire"||src.name=="Unfueled Fire")
						//switch(input("Cook?","Cook") in J)//list("Giu Meat")//,"Salmon","Trout","Bass","Catfish","Carp","Perch","Sunfish")
						//M << "test 2"
						if(!J)
							M << "You need some meat to toss on the fire if you want to cook."
						else for(J)//needs to be tested
							if(J.name=="Carp")//need to finish this verb up by doing the same that I did for these for the rest of the food
								F.Add("Carp")
							if(J.name=="Perch")
								F.Add("Perch")
							if(J.name=="Sunfish")
								F.Add("Sunfish")
							if(J.name=="Carp")
								F.Add("Carp")
							if(J.name=="Giu Meat")
								F.Add("Giu Meat")

							else
								/*if(J.name=="Cooked Giu Meat")
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
									return 0*/
								switch(input("Cook?","Cook") in F)//list("Giu Meat")//,"Salmon","Trout","Bass","Catfish","Carp","Perch","Sunfish")
									if("Giu Meat")
										var/R = rand(1,13)
										M << "You start to cook the Giu Meat on the fire..."
										if(R!=7)
											M<<"You start to cook the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Giu Meat on the fire..."
											//sleep(5)
											M.cooking = 1
											J.RemoveFromStack(1)
											src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											sleep(35)
											src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
											M<<"You finish cooking the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> Giu Meat on the fire."
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
										var/R = rand(1,12)
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
										var/R = rand(1,10)
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
										var/R = rand(1,9)
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
										var/R = rand(1,7)
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
										var/R = rand(1,9)
										if(M.character.frank >= 5)
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
											var/R2 = rand(1,6)
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
										if(M.character.frank >= 5)
											var/R = rand(1,11)
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
											var/R2 = rand(1,7)
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
										if(M.character.frank >= 5)
											var/R = rand(1,12)
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
											var/R = rand(1,8)
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
										if(M.character.frank >= 5)
											var/R = rand(1,13)
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
											var/R = rand(1,9)
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
										if(M.character.frank >= 5)
											var/R = rand(1,14)
											M << "You start to cook the Carp on the fire..."
											if(R!=4)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												M<<"You finish cooking the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='carp'> Carp on the fire."
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
												M<<"The fire overcooks the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'> Meat..."
												return
										else
											var/R = rand(1,10)
											M << "You start to cook the Carp on the fire..."
											if(R!=4)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												M<<"You finish cooking the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='carp'> Carp on the fire."
												new /obj/items/Food/carpC(locate(x,y,z))
												return
											else
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="carp")
												sleep(20)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="carp")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="fl")
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="OCM")
												new /obj/items/Food/OCM(locate(x,y,z))
												M<<"The fire overcooks the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'> Meat..."
												return
									if("Perch")
										if(M.character.frank >= 5)
											var/R = rand(1,15)
											M << "You start to cook the Perch on the fire..."
											if(R!=8)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="perch")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="perch")
												M<<"You finish cooking the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='perch'> Perch on the fire."
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
												M<<"The fire overcooks the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/R = rand(1,12)
											M << "You start to cook the Perch on the fire..."
											if(R!=8)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="perch")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="perch")
												M<<"You finish cooking the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='perch'> Perch on the fire."
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
												M<<"The fire overcooks the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
									if("Sunfish")
										if(M.character.frank >= 5)
											var/R = rand(1,16)
											M << "You start to cook the Sunfish on the fire..."
											if(R!=9)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												M<<"You finish cooking the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='sunfish'> Sunfish on the fire."
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
												M<<"The fire overcooks the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
										else
											var/R = rand(1,13)
											M << "You start to cook the Sunfish on the fire..."
											if(R!=9)
												J.RemoveFromStack(1)
												src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												sleep(15)
												src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="sunfish")
												M<<"You finish cooking the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='sunfish'> Sunfish on the fire."
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
												M<<"The fire overcooks the \  <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='OCM'>Meat..."
												return
					else//if(src.name=="Unlit Fire"||src.name=="Empty Fire")
						M<<"\  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'> Fire needs to be lit."
						return
			/*Fuel(obj/items/J)
				set src in oview(1)
				//set category = "Commands"
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
					if((src in oview(1)) && (src.name=="Lit Fire"||src.name=="Unfueled Fire"||src.name=="Fueled Fire") && (M.Doing==0))
						var/obj/items/Carbon/J = locate() in M.contents
						//var/obj/items/Carbon/C
						if(J)
							if(J.stack_amount>=2)
								for(J in M.contents)
									J.RemoveFromStack(2)
									M.Doing=1
									src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="Carbon")
									sleep(10)
									src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="Carbon")
									src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="charcoal")
									M<<"You finish burning and produce \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='charcoal'> Activated Carbon."
									src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="charcoal")
									new /obj/items/Activated_Carbon(M, 1)
									M.Doing=0
									return
							//else return
						else
							M<<"You need Carbon to continue."
							return
					else
						M << "You need something to burn to proceed."
						return
				Smelt_Iron()//for smelting iron ore collected from stone rocks via ueik pickaxe for use with stone hammer to create iron hammer and carving knife parts
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set hidden = 1
					set category = null//"Commands"
					var/mob/players/M
					M = usr
					var/obj/items/Ore/iron/J = locate() in M.contents
					if((src in oview(1)) && (src.name=="Lit Fire"||src.name=="Fueled Fire"||src.name=="Unfueled Fire") && (M.Doing==0))
						if(M.SHMequipped==1)
							var/IronOre = /obj/items/Ore/iron
							//J = locate() in M.contents
							if(J.stack_amount>=1)
								if(J.type==IronOre&&J in M.contents)
									J.RemoveFromStack(1)
									M.Doing=1
									src.overlays += icon(icon='dmi/64/build.dmi', icon_state="iron")
									sleep(30)
									src.overlays -= icon(icon='dmi/64/build.dmi', icon_state="iron")
									sleep(10)
									src.overlays += icon(icon='dmi/64/build.dmi', icon_state="ib")
									M<<"You finish hammering the smelting ore in the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'> fire and produce a Hammer Head \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='HH'> ." //<IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CKB'>."
									sleep(10)
									src.overlays -= icon(icon='dmi/64/build.dmi', icon_state="ib")
									new /obj/items/Crafting/Created/HammerHead(M)
									//new /obj/items/Crafting/Created/CKnifeblade(M)
									M.Doing=0
									return
								else return
							else
								M<<"You need \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'> iron ore to continue."
						else
							M<<"You need to be holding \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'> Stone Hammer to continue."
					else return
				/*Snuff_Fire()
					set src in oview(1)
					//set category = "Commands"
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
				Prepare_Fire()
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
							M<<"You add the \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'> Kindling onto the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='emptyfire'> empty fire."
							sleep(5)
							J.RemoveFromStack(1)
							src:sleeptime += 720
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="unlitfire")
							src:icon_state="unlitfire"
							src:name="Unlit Fire"
							//else
								//M<<"Can only add kindling to an empty fire."
						//else
							//set popup_menu = 0
				Fuel_Fire()
					set waitfor = 0
					set src in oview(1)
					//set category = "Commands"
					var/mob/players/M
					M = usr
					if(M.Doing==0)
						var/obj/items/Logs/UeikLog/J = locate() in M
						var/obj/items/Kindling/ueikkindling/J1 = locate() in M
						var/UeikLog = /obj/items/Logs/UeikLog
						var/ueikkindling = /obj/items/Kindling/ueikkindling
						if(src.name=="Unlit Fire")
							M<<"You need to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>Fire to fuel it."
							return 0
						if(src.name=="Empty Fire")
							M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Lit Fire to fuel it."
							return 0
						if(src.name=="Fueled Fire")
							M<<"\  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire already Fueled."
							return 0
						locate(J)
						if(J.type==UeikLog&&J&&src.name=="Unfueled Fire")
						//if(J&&src.name=="Unfueled Fire")
							M<<"You start to fuel the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
							M.Doing=1
							sleep(5)
							J.RemoveFromStack(1)
							//src:name="Lit Fire"
							M<<"You fuel the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
							src.sleeptime += 1500

							//light.on()
							M.Doing=0
							return
							//flick('fire.dmi',src)
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="LF")
							//new /light/circle(src, 9)
							//sleep(490)
							//src:name="Unfueled Fire"
							//new /light/circle(src, 9)
							//M<<"The Fire is starting to go out"
							//src:name="Unfueled Fire"
							//src.overlays -= icon('dmi/64/fire.dmi',icon_state="LF")
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="FF")
							//del(src.light)
							//new /light/circle(src, 6)
							//sleep(49)
							//light.off()
							//M<<"The Fire goes out"
							//src.overlays -= icon('dmi/64/fire.dmi',icon_state="FF")
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
							//src:name="Empty Fire"
						else if(J1.type==ueikkindling&&J&&src.name=="Unfueled Fire")
							M<<"You start to fuel the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
							M.Doing=1
							sleep(5)
							J1.RemoveFromStack(1)
							//src:name="Lit Fire"
							M<<"You fuel the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
							src.sleeptime += 500

							//light.on()
							M.Doing=0
							return
						else if (!J||!J1)
							usr << "You need to use a \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'> Log or \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'> Ueik Kindling on a \ <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='litfire'> Lit Fire to Fuel it!"
							return
					else
						usr << "You are already doing something..."
						return
				Light_Fire()//works
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					set category = null//"Commands"
					//set hidden = 1
					var/mob/players/M
					var/Carbon = /obj/items/Carbon
					//var/R = dice(roll)
					var/dice = "1d4"
					var/R = roll(dice)

					//var/sound = /obj/snd/sfx/fire3
					//src.s = new/soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
					///S = soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
					M = usr
					if(src.Scount==5)
						M<<"The snuffed material turns to ash \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='outfire'>"
						src:Scount=0
						src:name="Empty Fire"
						return
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
					if(M.CKequipped==1&&M.FLequipped==1&&src.name=="Unlit Fire"||M.PYequipped==1&&M.FLequipped==1&&src.name=="Unlit Fire")
						//var/sound = soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						//var/sstop = sound(src, 0, 'snd/cleaned/fire2.ogg', FALSE, 7, 0)
						//f3 = new/soundmob(src, 10, 'snd/cleaned/fire2.ogg', FALSE, 0, 30, FALSE)//still don't know how to loop soundmobs and unlisten to them...it will just have to play once until it gets figure it out.
						var/sound/fire = soundmob(src, 20, 'snd/cleaned/fire2.ogg', TRUE, 11, 60, TRUE)
						//var/sound/fire = _SoundEngine('snd/cleaned/fire2.ogg', src, range = 4, repeat = 1, volume = 60, falloff = 2)
						M<<"You start to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>fire."
						M.Doing=1
								//sleep(5)
								//J.RemoveFromStack(1)
						src:name="Lit Fire"
						M<<"You light the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Fire."
						//new /light/circle(src, 6)
						//light.on(src)
						if(spotlight)
							src.edit_spotlight(src,0, 0, 4.5, 255)
						if(!spotlight)
							src.draw_spotlight(src,0, 0, 4.5, 255)

						//var/sound/F2 = _SoundEngine('snd/cleaned/fire2.ogg', src, channel=11, range = 10, repeat = 1)//works but the range deletes the sound! boo
						world << fire
						while(fire)//sleep(src.sleeptime)
						//world << F2

							M.Doing=0
									//flick('fire.dmi',src)
							//src.overlays += image('dmi/64/fire.dmi',icon_state="LF")
							src.icon_state="LF"
									//new /light/circle(src, 9)
							sleep(src.sleeptime)
									//new /light/circle(src, 9)
							M<<"The Fire is beginning to fade..."
							src.edit_spotlight(src,0, 0, 3.5, 200)
							src:sleeptime += 50
							//src.overlays -= image('dmi/64/fire.dmi',icon_state="LF")
							//src.overlays += image('dmi/64/fire.dmi',icon_state="FF")
							src:name="Unfueled Fire"
							src.icon_state="GOF"

							sleep(src.sleeptime)

							src.remove_spotlight()
							src.icon_state="GC"
							src.edit_spotlight(src,0, 0, 1.5, 155)

							src:name="Empty Fire"

							sleep(src.sleeptime)
							src.remove_spotlight()
							//world << FM
							//world << sound(src)
							world << fire
							M<<"The Fire dies \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='outfire'>"
							src.icon_state="CO"

							if(R>=4)	// make sure we haven't reached limit
								new Carbon(src.loc)
								return

							src.sleeptime = 0
							return

					else
						usr << "You need to use \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Pyrite'>Pyrite or <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife with a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint on an <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='unlitfire'>Unlit Fire to Light it!"
						return
			/*proc
				STFU()
					var/mob/players/M
					M = usr
					for(M in oview(10,src))
						//M.unlistenSoundmob(s)
					for(src)
						del s*/
	townlamp
		density = 0
		//plane = 4
		layer = MOB_LAYER+10
		//luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "brasslamp"
		name = "Town Lamp"
		//Pname = "Town Lamp"
		//Lit = 1
		//light = /light/circle
		disallow_in = NORTH
		disallow_out = SOUTH
		New()
			src.draw_spotlight(0, 0, "#FFFFFF", 5.5, 255)//WorkStamp -- might need checked
			..()
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

	items
		Buildable
			lamps
				layer = 15
				//icon='dmi/64/build.dmi'
				//icon_state="brasslamps"
				can_stack=TRUE
				blockcarry=1
				var/burntime
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
				proc
					FindJar(mob/players/M)
						for(var/obj/items/tools/Containers/Jar/J in M.contents)
							locate(J)
							if(J.suffix=="Equipped"&&J.filled==1)
								return J
				verb
					Ignite_Lamp()
						set waitfor = 0
						set popup_menu = 1
						set src in oview(1)
						set category = null//"Commands"
						//set hidden = 1
						//set src in usr
						var/WoodenTorch=/obj/items/Buildable/lamps/woodentorchlit
						var/IronLamp=/obj/items/Buildable/lamps/ironlamplit
						var/CopperLamp=/obj/items/Buildable/lamps/copperlamplit
						var/BronzeLamp=/obj/items/Buildable/lamps/bronzelamplit
						var/BrassLamp=/obj/items/Buildable/lamps/brasslamplit
						var/SteelLamp=/obj/items/Buildable/lamps/steellamplit
						var/mob/players/M
						M = usr
						if(M.Doing==0)
							var/obj/items/Buildable/lamps/J = locate() in oview(1)
							if(src.name=="Lit Lamp")
								M<<"You already lit the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]."
								return 0
							if(src.name=="Empty Lamp")
								M<<"You need to add fuel to light the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]."
								return 0
							if(src.Scount>=5)
								M<<"The snuffed material is reduced to residue."
								src:Scount=0
								src:name="Empty Lamp"
								return
							if(M.CKequipped==1&&M.FLequipped==1&&src.name=="Unlit Lamp"||M.PYequipped==1&&M.FLequipped==1&&src.name=="Unlit Lamp")
								M<<"You start to ignite the fuel in the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
								M.Doing=1
								sleep(5)
								//lamps



								if(J.type==WoodenTorch)
									src:name="Lit Lamp"
									M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
									//new /light/circle(src, 2)
									//src.light.on()//testing
									src.draw_spotlight(0, 0, "#FFFFFF", 3.5, 255)
									M.Doing=0
									src.icon_state="WTL"//src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
									src.name = "Wooden Torch (Warm)"
									sleep(burntime)
									src.name = "Wooden Torch (Hot)"
									//if(src.name=="Unlit Lamp")
									//	return 0
									if(src.name=="Lit Lamp")
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
										burntime +=50
										sleep(burntime)
										src.name = "Wooden Torch (Warm)"
										src.icon_state="woodentorch"//src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
										//for(src)
										//src.light.off()
											//light.off()
											//light.off(src)
											//del src.light
										src.remove_spotlight()
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
										src:name="Empty Lamp"
										return
									else if(src.name=="Unlit Lamp")
										return
									else if(src.Scount>=5)
										M<<"The snuffed material is reduced to residue."
										src:Scount=0
										src:name="Empty Lamp"
										return

								if(J.type==IronLamp)
									src:name="Lit Lamp"
									M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
									//new /light/circle(src, 2)
									//src.light.on()//testing
									src.draw_spotlight(0, 0, "#FFFFFF", 4, 255)
									M.Doing=0
									src.icon_state="ILL"//src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
									src.name = "Iron Lamp (Warm)"
									sleep(burntime)
									src.name = "Iron Lamp (Hot)"
									if(src.name=="Lit Lamp")
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
										burntime +=50
										sleep(burntime)
										src.name = "Iron Lamp (Warm)"
										src.icon_state="ironlamp"//src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
										src.remove_spotlight()
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
										src:name="Empty Lamp"
										return
									else if(src.name=="Unlit Lamp")
										return
									else if(src.Scount>=5)
										M<<"The snuffed material is reduced to residue."
										src:Scount=0
										src:name="Empty Lamp"
										return

								if(J.type==CopperLamp)
									src:name="Lit Lamp"
									M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
									//new /light/circle(src, 2)
									//src.light.on()//testing
									src.draw_spotlight(0, 0, "#FFFFFF", 4.5, 255)
									M.Doing=0
									src.icon_state="CLL"//src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
									src.name = "Copper Lamp (Warm)"
									sleep(burntime)
									src.name = "Copper Lamp (Hot)"
									if(src.name=="Lit Lamp")
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
										burntime +=50
										sleep(burntime)
										src.name = "Copper Lamp (Warm)"
										src.icon_state="copperlamp"//src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
										src.remove_spotlight()
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
										src:name="Empty Lamp"
										return
									else if(src.name=="Unlit Lamp")
										return
									else if(src.Scount>=5)
										M<<"The snuffed material is reduced to residue."
										src:Scount=0
										src:name="Empty Lamp"
										return

								if(J.type==BronzeLamp)
									src:name="Lit Lamp"
									M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
									//new /light/circle(src, 2)
									//src.light.on()//testing
									src.draw_spotlight(0, 0, "#FFFFFF", 5, 255)
									M.Doing=0
									src.icon_state="BLL"//src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
									src.name = "Bronze Lamp (Warm)"
									sleep(burntime)
									src.name = "Bronze Lamp (Hot)"
									if(src.name=="Lit Lamp")
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
										burntime +=50
										sleep(burntime)
										src.name = "Bronze Lamp (Warm)"
										src.icon_state="bronzelamp"//src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
										src.remove_spotlight()
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
										src:name="Empty Lamp"
										return
									else if(src.name=="Unlit Lamp")
										return
									else if(src.Scount>=5)
										M<<"The snuffed material is reduced to residue."
										src:Scount=0
										src:name="Empty Lamp"
										return

								if(J.type==BrassLamp)
									src:name="Lit Lamp"
									M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
									//new /light/circle(src, 2)
									//src.light.on()//testing
									src.draw_spotlight(0, 0, "#FFFFFF", 5.5, 255)
									M.Doing=0
									src.icon_state="BSLL"//src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
									src.name = "Brass Lamp (Warm)"
									sleep(burntime)
									src.name = "Brass Lamp (Hot)"
									if(src.name=="Lit Lamp")
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
										burntime +=50
										sleep(burntime)
										src.name = "Brass Lamp (Warm)"
										src.icon_state="brasslamp"//src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
										src.remove_spotlight()
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
										src:name="Empty Lamp"
										return
									else if(src.name=="Unlit Lamp")
										return
									else if(src.Scount>=5)
										M<<"The snuffed material is reduced to residue."
										src:Scount=0
										src:name="Empty Lamp"
										return

								if(J.type==SteelLamp)
									src:name="Lit Lamp"
									M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
									//new /light/circle(src, 2)
									//src.light.on()//testing
									src.draw_spotlight(0, 0, "#FFFFFF", 6, 255)
									M.Doing=0
									src.icon_state="SLL"//src.overlays += image('dmi/64/fire.dmi',icon_state="ll")
									src.name = "Steel Lamp (Warm)"
									sleep(burntime)
									src.name = "Steel Lamp (Hot)"
									if(src.name=="Lit Lamp")
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is burning away"
										burntime +=50
										sleep(burntime)
										src.name = "Steel Lamp (Warm)"
										src.icon_state="steellamp"//src.overlays -= image('dmi/64/fire.dmi',icon_state="ll")
										src.remove_spotlight()
										M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] turns to ash"
										src:name="Empty Lamp"
										return
									else if(src.name=="Unlit Lamp")
										return
									else if(src.Scount>=5)
										M<<"The snuffed material is reduced to residue."
										src:Scount=0
										src:name="Empty Lamp"
										return
							else
								usr<<"Need to use your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and or <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pyrite'>Pyrite with <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint to light the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>Lamp."
						else
							usr << "You are already lighting the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> [src]..."
					Snuff_Lamp()//?
						set waitfor = 0
						set popup_menu = 1
						set category = null
						//for(src.name=="Lit Lamp")
						set src in oview(1)
						////set category = "Commands"
						//set hidden = 1
						var/mob/players/M
						M = usr
							//var/obj/items/Kindling/J = locate() in M.contents
						if(src.name=="Lit Lamp")
							M<<"You snuff the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]."
							sleep(5)
							//J.RemoveFromStack(1)
							//src.overlays -= overlays
							src.remove_spotlight()
							src.icon_state="[src.icon]"
							src:Scount+=1
							//src.light.off()
							//src.overlays += icon('dmi/64/fire.dmi',icon_state="snuffedfire")
							src:name="Unlit Lamp"
						else
							return
					Fuel_Lamp()//works
						set waitfor = 0
						set popup_menu = 1
						set src in oview(1)
					//	set src in usr
						set category = null//"Commands"
						//set hidden = 1
						var/mob/players/M
						M = usr
						/*
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
										*/
						var/obj/items/tools/Containers/Jar/J = FindJar(M)
						//var/obj/items/tools/Containers/Vessel/J2 = FindVes(M)
						//if(!J)
							//return
						for(J)//streamlined and working
							//if(J.suffix=="Equipped"&&M.JRequipped==1&&filled==1&&CType=="Tar")

							if(J.CType=="Tar"&&src.name=="Empty Lamp")
								M<<"You add the [J.CType] into the empty \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Lamp."
								J.icon_state = "Jar"
								J.volume = 0
								J.CType="Empty"
								J.name = "Jar"
								J.filled=0
								src:burntime+=250
								src:name="Unlit Lamp"
								return

							else if(J.CType=="Oil"&&src.name=="Empty Lamp")
								M<<"You add the [J.CType] into the empty \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Lamp."
								J.icon_state = "Jar"
								J.volume = 0
								J.CType="Empty"
								J.name = "Jar"
								J.filled=0
								src:burntime+=500
								src:name="Unlit Lamp"
								return
							else if(J.CType=="Water"||J.CType=="Sand")
								M<<"You need Tar or Oil to fuel the Lamp."
								return
							else if(src.name!="Empty Lamp")
								M << "This Lamp doesn't need fuel."
							if(J.filled==0&&M.JRequipped==0)
								M<<"You need to hold and fill the Jar to use it."
								return
							else if(J.filled==0&&M.JRequipped==1)
								M<<"You need to fill the Jar to use it."
								return
					Plant()//works
						set waitfor = 0
						set popup_menu = 1
						//set src in oview(1)//?
						set category = null//"Commands"
						var/obj/items/Buildable/lamps/woodentorch/WoodenTorch
						var/obj/items/Buildable/lamps/ironlamp/IronLamp
						var/obj/items/Buildable/lamps/copperlamp/CopperLamp
						var/obj/items/Buildable/lamps/bronzelamp/BronzeLamp
						var/obj/items/Buildable/lamps/brasslamp/BrassLamp
						var/obj/items/Buildable/lamps/steellamp/SteelLamp
						var/obj/items/Buildable/lamps/J = locate() in usr.contents
						var/mob/players/M
						M = usr
						if(M.Doing==0)
							//if(usr.Wequipped==1 && usr.Sequipped==1 && usr.LSequipped==1 && usr.AXequipped==1 && usr.WHequipped==1 && usr.JRequipped==1 && usr.FPequipped==1 && usr.PXequipped==1 && usr.SHequipped==1 && usr.HMequipped==1 && usr.SKequipped==1 && usr.HOequipped==1 && usr.CKequipped==1 && usr.FLequipped==1 && usr.PYequipped==1 && usr.OKequipped==1 && usr.SHMequipped==1 && usr.UPKequipped==1)
								//M<<"You need your hands free of tools to Plant [J]! (To Pull it, you will need \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>Gloves)"
								//return	//M.Doing=1
										//sleep(3)
							if(usr.GVequipped==1)
								if(J.Pname=="Wooden Torch"&&J.Planted==0)
									for(WoodenTorch in M.contents)
											//	set src in usr.contents
										M<<"You start to Plant the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] into the Ground..."
										M.Doing=1
										sleep(39)
												//src.Planted = 1
													//del J:light
													//J.overlays += icon('dmi/64/build.dmi',icon_state="TLO")
										new /obj/items/Buildable/lamps/woodentorchlit(usr.loc)//Move(src.loc)
										for(var/obj/items/Buildable/lamps/woodentorchlit/J1 in oview(1))
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
										new /obj/items/Buildable/lamps/ironlamplit(usr.loc)//Move(src.loc)
										for(var/obj/items/Buildable/lamps/ironlamplit/J1 in oview(1))
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
										new /obj/items/Buildable/lamps/copperlamplit(usr.loc)//Move(src.loc)
										for(var/obj/items/Buildable/lamps/copperlamplit/J1 in oview(1))
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
										new /obj/items/Buildable/lamps/brasslamplit(usr.loc)//Move(src.loc)
										for(var/obj/items/Buildable/lamps/brasslamplit/J1 in oview(1))
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
										new /obj/items/Buildable/lamps/bronzelamplit(M.loc)//Move(src.loc)
										for(var/obj/items/Buildable/lamps/bronzelamplit/J1 in oview(1))
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
										new /obj/items/Buildable/lamps/steellamplit(M.loc)//Move(src.loc)
										for(var/obj/items/Buildable/lamps/steellamplit/J1 in oview(1))
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
					Pull()//works
						set waitfor = 0
						set popup_menu = 1
						set src in oview(1)
						set category = null//"Commands"
						var/WoodenTorch=/obj/items/Buildable/lamps/woodentorch
						var/IronLamp=/obj/items/Buildable/lamps/ironlamp
						var/CopperLamp=/obj/items/Buildable/lamps/copperlamp
						var/BronzeLamp=/obj/items/Buildable/lamps/bronzelamp
						var/BrassLamp=/obj/items/Buildable/lamps/brasslamp
						var/SteelLamp=/obj/items/Buildable/lamps/steellamp
						var/obj/items/Buildable/lamps/J = locate() in oview(1)
						var/mob/players/M
						M = usr
						if(J.name=="Lit Lamp")
							M << "Can't pull [J] while lit."
							return
						if(M.Doing==0)
							if(M.GVequipped==1&&J.name!="Lit Lamp")
								//M.Doing=1
								//sleep(3)
								if(J.type==WoodenTorch&&J.Planted==1)//works -confirmed
									M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
									M.Doing=1
									sleep(39)
									J:Planted = 0
									M.Doing=0
									icon_state="woodentorch"
									M.stamina -= 5
									M.updateST()
									M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
									new WoodenTorch(M)
									del src
								if(J.type==IronLamp&&J.Planted==1)//works -confirmed
									M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
									M.Doing=1
									sleep(39)
									J:Planted = 0
									M.Doing=0
									icon_state="ironlamp"
									M.stamina -= 5
									M.updateST()
									M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
									new IronLamp(M)
									del src
								if(J.type==CopperLamp&&J.Planted==1)//works -confirmed
									M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
									M.Doing=1
									sleep(39)
									J:Planted = 0
									M.Doing=0
									icon_state="copperlamp"
									M.stamina -= 5
									M.updateST()
									M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
									new CopperLamp(M)
									del src
								if(J.type==BronzeLamp&&J.Planted==1)//works -confirmed
									M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
									M.Doing=1
									sleep(39)
									J:Planted = 0
									M.Doing=0
									icon_state="bronzelamp"
									M.stamina -= 5
									M.updateST()
									M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
									new BronzeLamp(M)
									del src
								if(J.type==BrassLamp&&J.Planted==1)//works -confirmed
									M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
									M.Doing=1
									sleep(39)
									J:Planted = 0
									M.Doing=0
									icon_state="brasslamp"
									M.stamina -= 5
									M.updateST()
									M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
									new BrassLamp(M)
									del src
								if(J.type==SteelLamp&&J.Planted==1)//works -confirmed
									M<<"You start to Pull the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground..."
									M.Doing=1
									sleep(39)
									J:Planted = 0
									M.Doing=0
									icon_state="steellamp"
									M.stamina -= 5
									M.updateST()
									M<<"You Finish Pulling the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] out of the Ground"
									new SteelLamp(M)
									del src

							else
								M<<"You need to use \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>gloves on an Empty or Unlit Lamp to do that..."
						else
							M<<"You are already Pulling [J]..."
//buildable lamps \|/
				woodentorch//easy way to fix circle in inventory issue, when pulling a lamp out, create a new object that has no light, when planting, creat one that does!
					density = 0
					layer = 6
					burntime = 340
					//luminosity = 1
					icon = 'dmi/64/build.dmi'
					icon_state = "woodentorch"
					name = "Empty Lamp"
					Pname = "Wooden Torch"
					Planted = 0
					////light = /light/circle

					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
						//soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
						// we make the lamps have directional light sources,
						// the /light/directional object is defined at the
						// top of this file.
						//if(src.loc!=usr||src.loc!=null)
							//new /light/circle(src, 3)
							//src.light.off()
				woodentorchlit//for planting
					density = 0
					layer = 6
					burntime = 340
					//luminosity = 1
					icon = 'dmi/64/build.dmi'
					icon_state = "woodentorch"
					name = "Empty Lamp"
					Pname = "Wooden Torch"
					Planted = 0
					////light = /light/circle

					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
						//soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
						// we make the lamps have directional light sources,
						// the /light/directional object is defined at the
						// top of this file.
						//if(src.loc!=usr||src.loc!=null)
							//new /light/circle(src, 1)
							//src.light.off()

				ironlamp
					density = 0
					layer = 6
					//luminosity = 1
					burntime = 550
					icon = 'dmi/64/build.dmi'
					icon_state = "ironlamp"
					name = "Empty Lamp"
					Pname = "Iron Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()

				ironlamplit
					density = 0
					layer = 6
					//luminosity = 1
					burntime = 550
					icon = 'dmi/64/build.dmi'
					icon_state = "ironlamp"
					name = "Empty Lamp"
					Pname = "Iron Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
						//if(src.loc!=usr||src.loc!=null)
							//new /light/circle(src, 2)
							//src.light.off()
				copperlamp
					density = 0
					layer = MOB_LAYER+3
					//luminosity = 1
					burntime = 750
					icon = 'dmi/64/build.dmi'
					icon_state = "copperlamp"
					name = "Empty Lamp"
					Pname = "Copper Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()

				copperlamplit
					density = 0
					layer = MOB_LAYER+3
					//luminosity = 1
					burntime = 750
					icon = 'dmi/64/build.dmi'
					icon_state = "copperlamp"
					name = "Empty Lamp"
					Pname = "Copper Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
						//if(src.loc!=usr||src.loc!=null)
							//new /light/circle(src, 3)
							//src.light.off()
				bronzelamp
					density = 0
					layer = 6
					burntime = 850
					//luminosity = 1
					icon = 'dmi/64/build.dmi'
					icon_state = "bronzelamp"
					name = "Empty Lamp"
					Pname = "Bronze Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
				bronzelamplit
					density = 0
					layer = 6
					burntime = 850
					//luminosity = 1
					icon = 'dmi/64/build.dmi'
					icon_state = "bronzelamp"
					name = "Empty Lamp"
					Pname = "Bronze Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
				brasslamp
					density = 0
					layer = 6
					burntime = 1075
					//luminosity = 1
					icon = 'dmi/64/build.dmi'
					icon_state = "brasslamp"
					name = "Empty Lamp"
					Pname = "Brass Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()

				brasslamplit
					density = 0
					layer = 6
					burntime = 1075
					//luminosity = 1
					icon = 'dmi/64/build.dmi'
					icon_state = "brasslamp"
					name = "Empty Lamp"
					Pname = "Brass Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
						//if(src.loc!=usr||src.loc!=null)
							//new /light/circle(src, 4)
							//src.light.off()
				steellamp
					density = 0
					layer = 6
					//luminosity = 1
					burntime = 2750
					icon = 'dmi/64/build.dmi'
					icon_state = "steellamp"
					name = "Empty Lamp"
					Pname = "Steel Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
				steellamplit
					density = 0
					layer = 6
					//luminosity = 1
					burntime = 2750
					icon = 'dmi/64/build.dmi'
					icon_state = "steellamp"
					name = "Empty Lamp"
					Pname = "Steel Lamp"
					//light = /light/circle
					//disallow_in = NORTH
					//disallow_out = SOUTH
					New()
						..()
						//if(src.loc!=usr||src.loc!=null)
							//new /light/circle(src, 5)
							//src.light.off()


						// we make the lamps have directional light sources,
						// the /light/directional object is defined at the
						// top of this file.
						//new /light/circle(src, 6)
						//light.on = 0

	TownTorches
		//Lit = 1
		Torch
			density = 1
			layer = MOB_LAYER+1
			//Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "tt1"
			//light = /light/circle


		Torcha
			density = 1
			layer = 6
			//Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "Torcha1"
			//light = /light/directional


		Torchb
			density = 1
			layer = 6
			//Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "Torchb1"
			//light = /light/directional


		Torchc
			density = 1
			layer = 6
			//Lit = 1
			//luminosity = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "Torchc1"
			//light = /light/directional


		castlwll5a
			name = "castlwll5a"
			density = 0
			mouse_opacity = 0
			layer = 6
			//Lit = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "5a"
			//light = /light/directional


		introof6a
			name = "introof6a"
			density = 0
			layer = 6
			mouse_opacity = 0
			opacity = 0
			//Lit = 1
			icon = 'dmi/64/Castl.dmi'
			icon_state = "r6a"
			//light = /light/directional


		btmwll1a
			name = "btmwll1a"
			density = 0
			layer = 6
			//Lit = 1
			mouse_opacity = 0
			opacity = 0
			icon = 'dmi/64/Castl.dmi'
			icon_state = "btmwll1a"
			//light = /light/directional


/*mob/players
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
				..()*/

obj/items/torches
	//icon = 'dmi/64/build.dmi'
	var/spawntime
	var/soundmob/s
	var/state
	density = 0
	layer = 11
	//New()
		//..()
		//soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40)
	proc/FindJar(mob/players/M)
		for(var/obj/items/tools/Containers/Jar/J in M.contents)
			locate(J)
			if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&J.CType=="Tar"||J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&J.CType=="Oil")
				return J
	proc/FindJar2(mob/players/M)
		for(var/obj/items/tools/Containers/Jar/J in M.contents)
			locate(J)
			if(J.filled==0)
				return J
			//else
				//M << "Need to hold a Filled Jar."
				//return
	verb
		Fuel_Torch()//converted to jar
			set waitfor = 0
			set category=null
			set popup_menu = 1
			//set hidden = 1
			var/mob/players/M
			M = usr
			var/obj/items/tools/Containers/Jar/J = FindJar(M)
			var/obj/items/tools/Containers/Jar/J1 = FindJar2(M)
			var/obj/items/torches/S = locate() in M
			var/HandTorch=/obj/items/torches/Handtorch
			//if(J.filled==1)
			//	J.CType="Water"

			if(J&&src.state=="Empty Torch"||J&&src.state=="Unfueled Torch")
				for(J)//streamlined and working
				//if(suffix=="Equipped"&&M.JRequipped==1&&filled==1&&CType=="Water")
					//usingjar(M,100)
					J.icon_state = "Jar"
					J.volume = 0
					src.spawntime += S.spawntime
					//if(volume<0)
					//	volume=0
					//M<<"You drink the contents of the Jar."
					J.CType="Empty"
					J.name = "Jar"
					J.filled=0
				if(istype(S,HandTorch))
					src.icon_state="torchfueled"
				M<<"You add the fuel to the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."
				if(src.state=="Empty Torch")
					src:state="Unlit Torch"
				if(src.state=="Unfueled Torch")
					src:state="Fueled Torch"
			/*else if(J.filled==1&&J.CType=="Tar"||J.filled==1&&J.CType=="Oil"||J.filled==1&&J.CType=="Sand")
				M<<"You don't want to drink that."
				return*/
			//else if(J.filled==1&&J.CType=="Oil")
				//M<<"You don't want to drink that."
				//return
			if(M.JRequipped==0)
				M<<"You need to hold a Jar filled with Tar or Oil to fuel the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."
				return
			else if(M.JRequipped==1&&J1)
				M<<"You need to fill the Jar with Tar or Oil to fuel the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."
				return

			//Old Way
				/*var/obj/items/Tar/J = locate() in M.contents
				if((J in M.contents) && (src.state=="Empty Torch"))
					M<<"You add the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'> [J] onto the empty <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."
					sleep(5)
					J.RemoveFromStack(1)
					//src.overlays += icon('dmi/64/fire.dmi',icon_state="unlitfire")
					src:state="Unlit Torch"
					return
				else
					M<<"Can only add \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to an empty <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>torch."
		*/
		Light_Torch()//works
			//set hidden = 1
			set category = null
			set popup_menu = 1
			set waitfor = 0
			//set src in usr
			var/mob/players/M
			M = usr
			var/HandTorch=/obj/items/torches/Handtorch
			var/IronHandLamp=/obj/items/torches/ironhandlamp
			var/CopperHandLamp=/obj/items/torches/copperhandlamp
			var/BronzeHandLamp=/obj/items/torches/bronzehandlamp
			var/BrassHandLamp=/obj/items/torches/brasshandlamp
			var/SteelHandLamp=/obj/items/torches/steelhandlamp
			//var/soundmob/tmp/s = new/soundmob(M, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 40, FALSE)




			var/obj/items/torches/J = locate() in M.contents
			if(M.Doing==0)
				//var/obj/items/torches/J = locate() in M.contents
				if(src.state=="Lit Torch")
					M<<"Already lit!"
					return 0
				if(src.state=="Empty Torch")
					M<<"You need to add Tar or Oil to light the [src.name]."
					return 0
				if(src.state=="Snuffed Torch")
					M<<"You scrape off the carbon from the Snuffed Torch"
					//M.Doing=1
					src.state="Unlit Torch"
					return
					//src.Scount+=1
					//del torch
				if(src.Scount>=5&&istype(J,HandTorch))
					M << "You discard the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>torch as it is no longer viable..."
					M.Doing=0
					sleep(5)
					del (src)
					return
				//if((M.PYequipped==1 && M.FLequipped==1 && src.state=="Unlit Torch")||=(M.CKequipped==1 && M.FLequipped==1 && src.state=="Unlit Torch"))
				if(M.PYequipped==0&&M.FLequipped==0||M.CKequipped==0&&M.FLequipped==0)
					usr<<"Need to use your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and or <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pyrite'>Pyrite with<IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint to light the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J.name]."
					return
				else
					//s = new/soundmob(M, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 40, FALSE)
					//src.s = new/soundmob(M, 20, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
					M<<"You start to ignite the fuel in the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."
					var/sound/F2 = soundmob(usr, 20, 'snd/cleaned/fire2.ogg', TRUE, 12, 60, TRUE)
					sleep(5)
					//if(J.type==HandTorch)

//					//M.listenSoundmob(s)

					//sleep(J.spawntime)
					J:state="Lit Torch"
					world << F2
					//if(J.state=="Snuffed Torch"||J.state=="Unlit Torch"||J.state=="Empty Torch") //M.unlistenSoundmob(s)

					if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/Handtorch)&&J.type==HandTorch)//working
						var/image/torch
						torch = image('dmi/64/hto.dmi',M)
						//J:state="Lit Torch"
						M<<"You ignite the [src.name]."
						M.Doing=1
						M.edit_spotlight(0, 0, "#FFFFFF", 3.5, 255)
						usr << torch
						//M.overlays += torch
						//M.overlays += HandTorch
						//M.overlays += image('64/fire.dmi',icon_state="hto")//shows up for first frame but disappears. Annoying because I've had this working before
						//M.overlays += icon('dmi/64/fire.dmi',icon_state="[M.dir]")
						src.icon_state="torch"//J.overlays += image('64/fire.dmi',icon_state="bht")
						M.Doing=0
						sleep(J.spawntime)
						if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/Handtorch)&&J.type==HandTorch)
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away."
							src.state="Unfueled Torch"
							J.spawntime += 350

							sleep(J.spawntime)

							J.icon_state="torchout"//J.overlays -= image('64/fire.dmi',icon_state="bht")
							src.overlays -= torch
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch has reduced to residue."
							world << sound(src)
							M.remove_spotlight()
							J:state="Empty Torch"
							return
						else if(src.Scount >= 5)
							M << "The torch turns into ash..."
							del src
							return

						else if(J.state=="Snuffed Torch")
							return
						else if(J.state=="Unlit Torch")
							return
							//else
								//return M << "Torch is out."

					if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/ironhandlamp)&&J.type==IronHandLamp)//working
						var/torch
						torch = image('dmi/64/ILO.dmi',M)
						//J:state="Lit Torch"
						M.Doing=1
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."

						M.edit_spotlight(0, 0, "#FFFFFF", 4, 255)
						////M.listenSoundmob(s)
						//world << F2
						usr << torch
						//M.overlays += torch
						M.overlays += torch//image('dmi/64/build.dmi',icon_state="ILO")
						J.icon_state="IHTL"//J.overlays += image('64/fire.dmi',icon_state="bht")

						M.Doing=0

						sleep(J.spawntime)
						if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/ironhandlamp)&&J.type==IronHandLamp)
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='IHTL'>[src] is burning away."
							src.state="Unfueled Torch"
							J.spawntime += 450

							sleep(J.spawntime)

							J.icon_state="ironhandlamp"//J.overlays -= image('64/fire.dmi',icon_state="bht")
							src.overlays -= torch
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='IHTL'>[src] has reduced to residue."
							world << sound(src)
							M.remove_spotlight()
							J:state="Empty Torch"
							return
						else if(src.Scount >= 5)
							M << "The fuel has been reduced to residue..."
							//del src
							J:state="Empty Torch"
							return

						else if(J.state=="Snuffed Torch")
							return
						else if(J.state=="Unlit Torch")
							return


					if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/copperhandlamp)&&J.type==CopperHandLamp)//working for the most part -- sound still can't repeat
						var/torch
						torch = image('dmi/64/CLO.dmi',M)
						//J:state="Lit Torch"
						M.Doing=1
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref'[src.icon]' ICONSTATE='[src.icon_state]'>[src.name]."

						world << F2
						usr << torch
						M.edit_spotlight(0, 0, "#FFFFFF", 4.5, 255)
						//M.overlays += torch
						M.overlays += image('dmi/64/build.dmi',icon_state="CLO")
						J.icon_state="CHTL"//J.overlays += image('64/fire.dmi',icon_state="bht")

						M.Doing=0
						sleep(J.spawntime)
						if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/copperhandlamp)&&J.type==CopperHandLamp)
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='CHTL'>[src] is burning away."
							src.state="Unfueled Torch"
							J.spawntime += 550

							sleep(J.spawntime)

							J.icon_state="copperhandlamp"//J.overlays -= image('64/fire.dmi',icon_state="bht")
							src.overlays -= torch
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='copperhandlamp'>[src] has reduced to residue."
							world << sound(src)
							M.remove_spotlight()
							J:state="Empty Torch"
							return
						else if(src.Scount >= 5)
							M << "The fuel has been reduced to residue..."
							//del src
							J:state="Empty Torch"
							return

						else if(J.state=="Snuffed Torch")
							return
						else if(J.state=="Unlit Torch")
							return


					if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/bronzehandlamp)&&J.type==BronzeHandLamp)//working for the most part -- sound still can't repeat
						var/torch
						torch = image('dmi/64/BLO.dmi',M)
						//J:state="Lit Torch"
						M.Doing=1
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."

						world << F2
						usr << torch
						M.edit_spotlight(0, 0, "#FFFFFF", 5, 255)
						//M.overlays += torch
						M.overlays += image('dmi/64/build.dmi',icon_state="BLO")
						J.icon_state="BHTL"//J.overlays += image('64/fire.dmi',icon_state="bht")

						M.Doing=0

						sleep(J.spawntime)
						if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/bronzehandlamp)&&J.type==BronzeHandLamp)
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='BHTL'>[src] is burning away."
							src.state="Unfueled Torch"
							J.spawntime += 650

							sleep(J.spawntime)

							J.icon_state="bronzehandlamp"//J.overlays -= image('64/fire.dmi',icon_state="bht")
							src.overlays -= torch
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='bronzehandlamp'>[src] has reduced to residue."
							world << sound(src)
							M.remove_spotlight()
							J:state="Empty Torch"
							return
						else if(src.Scount >= 5)
							M << "The fuel has been reduced to residue..."
							//del src
							J:state="Empty Torch"
							return

						else if(J.state=="Snuffed Torch")
							return
						else if(J.state=="Unlit Torch")
							return


					if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/brasshandlamp)&&J.type==BrassHandLamp)//working for the most part -- sound still can't repeat
						var/torch
						torch = image('dmi/64/BRLO.dmi',M)
						//J:state="Lit Torch"
						M.Doing=1
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."

						world << F2
						usr << torch
						M.edit_spotlight(0, 0, "#FFFFFF", 5.5, 255)
						//M.overlays += torch
						M.overlays += image('dmi/64/build.dmi',icon_state="BRLO")
						J.icon_state="BSHTL"//J.overlays += image('64/fire.dmi',icon_state="bht")

						M.Doing=0

						sleep(J.spawntime)
						if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/brasshandlamp)&&J.type==BrassHandLamp)
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='BSHTL'>[src] is burning away."
							src.state="Unfueled Torch"
							J.spawntime += 750

							sleep(J.spawntime)

							J.icon_state="brasshandlamp"//J.overlays -= image('64/fire.dmi',icon_state="bht")
							src.overlays -= torch
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='brasshandlamp'>[src] has reduced to residue."
							world << sound(src)
							M.remove_spotlight()
							J:state="Empty Torch"
							return
						else if(src.Scount >= 5)
							M << "The fuel has been reduced to residue..."
							//del src
							J:state="Empty Torch"
							return

						else if(J.state=="Snuffed Torch")
							return
						else if(J.state=="Unlit Torch")
							return


					if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/steelhandlamp)&&J.type==SteelHandLamp)//working for the most part -- sound still can't repeat
						var/torch
						torch = image('dmi/64/SLO.dmi',M)
						//J:state="Lit Torch"
						M.Doing=1
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.name]."

						world << F2
						usr << torch
						M.edit_spotlight(0, 0, "#FFFFFF", 6, 255)
						//M.overlays += torch
						M.overlays += image('dmi/64/build.dmi',icon_state="SLO")
						J.icon_state="SHTL"//J.overlays += image('64/fire.dmi',icon_state="bht")

						M.Doing=0

						sleep(J.spawntime)
						if(J.state=="Lit Torch"&&istype(src,/obj/items/torches/steelhandlamp)&&J.type==SteelHandLamp)
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='SHTL'>[src] is burning away."
							src.state="Unfueled Torch"
							J.spawntime += 850

							sleep(J.spawntime)

							J.icon_state="steelhandlamp"//J.overlays -= image('64/fire.dmi',icon_state="bht")
							src.overlays -= torch
							M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='steelhandlamp'>[src] has reduced to residue."
							world << sound(src)
							M.remove_spotlight()
							J:state="Empty Torch"
							return
						else if(src.Scount >= 5)
							M << "The fuel has been reduced to residue..."
							//del src
							J:state="Empty Torch"
							return

						else if(J.state=="Snuffed Torch")
							return
						else if(J.state=="Unlit Torch")
							return



				//else
					//usr<<"Need to use your \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and or <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pyrite'>Pyrite with<IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint to light the <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J.name]."
					//return
			else
				usr << "You are already lighting the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src]..."
				return
		/*Light_Novice_Torch()
			set waitfor = 0
			set popup_menu = 1
			set category = null
			set hidden = 1
			var/HandTorch=/obj/items/torches/Handtorch
			var/mob/players/M
			M = usr
			if(M.Doing==0)
				//var/obj/items/torches/J = src
				if(src.state=="Lit Torch")
					M<<"You already lit the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch."
					return 0
				if(src.state=="Empty Torch")
					M<<"You need to add \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to light the  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."
					return 0
				if(src.Scount==5)
					M<<"The snuffed material turns to ash"
					src:Scount=0
					src:state="Empty Torch"
				if(M.FLequipped==1&&M.PYequipped==1&&src.state=="Unlit Torch")
					M<<"You start to ignite the \  fuel in the <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch"
					M.Doing=1
					sleep(5)
					src:state="Lit Torch"
					//M.listenSoundmob(s)
					if(src.state=="Dead Torch") //M.unlistenSoundmob(s)
					if(src.state=="Lit Torch"&&src.type==HandTorch)
						//src:state="Lit Torch"
						M<<"You ignite the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch"
						//M.new /light/directional(usr, 6)
						//M.light.dir = M.dir
						M.light = new (M, 3)
						//light.loc = M
						//light.on = 1//new /light/circle(M, 3)
						M.Doing=0
						src.overlays += icon('dmi/64/fire.dmi',icon_state="bht")
						//M.overlays += icon('dmi/64/fire.dmi',icon_state="[get_step(M,dir]")
						sleep(1240)
						if(src.state=="Unlit Torch") return 0
						M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='bht'>Torch is burning away"
						//if(src.state=="Unlit Torch") return 0
						sleep(149)
						src.overlays -= icon('dmi/64/fire.dmi',icon_state="bht")
						src:state="Dead Torch"
						if(src.state=="Dead Torch") //M.unlistenSoundmob(s)
						//M.overlays -= icon('dmi/64/fire.dmi',icon_state="[M.dir]")
						src:state="Empty Torch"
						M<<"The fuel in the \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch is reduced to residue."
						//del src.light
						M.light.off()
						return*/
		Snuff_Torch()
			set popup_menu = 1
			set category = null
			set waitfor = 0
			//set hidden = 1
			var/mob/players/M
			M=usr
			var/HandTorch=/obj/items/torches/Handtorch
			var/IronHandLamp=/obj/items/torches/ironhandlamp
			var/CopperHandLamp=/obj/items/torches/copperhandlamp
			var/BronzeHandLamp=/obj/items/torches/bronzehandlamp
			var/BrassHandLamp=/obj/items/torches/brasshandlamp
			var/SteelHandLamp=/obj/items/torches/steelhandlamp

			//if(src.state=="Snuffed Torch"&&istype(src,HandTorch))
				//M.overlays -= overlays

			var/obj/items/torches/J = locate() in M
			if(J)
				for(J)
					//var/obj/items/Kindling/J = locate() in M.contents
					if(src.state=="Lit Torch"||src.state=="Unfueled Torch")
						//var/torch
						M<<"You snuff the [src.name]."
						sleep(5)
						//J.RemoveFromStack(1)
						if(src.type==HandTorch)
							M.overlays -= image('dmi/64/hto.dmi')
							src.icon_state="torchout"//J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
							//M.light.off()
							M.remove_spotlight()
							world << sound(src)
							src:state="Snuffed Torch."
							src.Scount+=1
							//J.state = "Unlit Torch"
							break
							return
						if(J.type==IronHandLamp)
							M.overlays -= image('dmi/64/ILO.dmi')
							src.icon_state="ironhandlamp"//J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
							M.remove_spotlight()
							world << sound(src)
							src:state="Snuffed Torch."
							src.Scount+=1
							return
						if(J.type==CopperHandLamp)
							M.overlays -= image('dmi/64/CLO.dmi')
							J.icon_state="copperhandlamp"//J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
							M.remove_spotlight()
							world << sound(src)
							src:state="Snuffed Torch."
							src.Scount+=1
							return
						if(J.type==BronzeHandLamp)
							M.overlays -= image('dmi/64/BRLO.dmi')
							J.icon_state="bronzehandlamp"//J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
							M.remove_spotlight()
							world << sound(src)
							src:state="Snuffed Torch."
							src.Scount+=1
							return
						if(J.type==BrassHandLamp)
							M.overlays -= image('dmi/64/BLO.dmi')
							J.icon_state="brasshandlamp"//J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
							M.remove_spotlight()
							world << sound(src)
							src:state="Snuffed Torch."
							src.Scount+=1
							return
						if(J.type==SteelHandLamp)
							M.overlays -= image('dmi/64/SLO.dmi')
							J.icon_state="steelhandlamp"//J.overlays-=image('dmi/64/fire.dmi',icon_state="bht")
							M.remove_spotlight()
							world << sound(src)
							src:state="Snuffed Torch."
							src.Scount+=1
							return
						//M.light.off()
						//M.unlistenSoundmob(s)
						//del light
						//M.unsetListeners(s)
						//src.overlays += icon('dmi/64/fire.dmi',icon_state="snuffedfire")
						//src:state="Snuffed [src]."
						//del torch
						return
					else
						M << "Torch is already out."
						return
			else
				M << "Need a torch or lamp to snuff."
				return
	workalready
		icon = 'dmi/64/hto.dmi'
		layer=FLOAT_LAYER-1
	Handtorch
		density = 1
		layer = 6
		//luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "torchout"
		state = "Empty Torch"
		name = "Hand Torch"
		//light = /light/circle
		spawntime = 240//good timing for sound>visual connection(when the "fire" goes out, the sound of burning stops, as well) better to simply link the sound file length with the timing of the light, as it is harder to force a sound to stop. Go with the flow!
		//var/sound = /obj/snd/sfx/fire3 //var/soundmob/s = new soundmob(src, 30, 'snd/fire.ogg', TRUE, 0, 40, FALSE) //this goes on the action
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
	//	light = /light/directional(src, 8)
	//	light.dir = usr.dir
			//new /light/circle(usr, 4)
			//light.off()
			//light.mobile = 1
	ironhandlamp
		density = 1
		layer = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "ironhandlamp"
		state = "Empty Torch"
		name = "Iron Hand Lamp"
		//light = /light/circle
		spawntime = 1240
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//new /light/circle(src, 2)
			//light.on = 0
	copperhandlamp
		density = 1
		layer = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "copperhandlamp"
		state = "Empty Torch"
		spawntime = 1420
		name = "Copper Hand Lamp"
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//new /light/circle(src, 3)
			//light.on = 0
	bronzehandlamp
		density = 1
		layer = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "bronzehandlamp"
		state = "Empty Torch"
		spawntime = 1840
		name = "Bronze Hand Lamp"
		New()
			..()

	brasshandlamp
		density = 1
		layer = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "brasshandlamp"
		state = "Empty Torch"
		spawntime = 1840
		name = "Brass Hand Lamp"
		New()
			..()

			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//new /light/circle(src, 4)
			//light.on = 0

	steelhandlamp
		density = 1
		layer = 6
		luminosity = 1
		icon = 'dmi/64/build.dmi'
		icon_state = "steelhandlamp"
		state = "Empty Torch"
		name = "Steel Hand Lamp"
		spawntime = 3680
		New()
			..()
			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//new /light/circle(src, 6)
		//	light.on = 0


