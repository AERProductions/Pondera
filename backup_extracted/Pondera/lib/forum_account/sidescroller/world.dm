
// File:    world.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This file contains the global movement loop,
//   some other global things (variables), and other
//   stuff.

var
	icon_width = -1
	icon_height = -1
	tick_count = 0

world
	// 40 frames per second
	fps = 40

	proc
		// This is the global movement loop. It calls world.movement
		// every tick. If you want to change the behavior of the global
		// movement loop, override world.movement, not movement_loop.
		movement_loop()
			movement()
			spawn(world.tick_lag)
				movement_loop()

			tick_count += 1
			if(tick_count >= 1000)
				tick_count -= 1000

		movement()
			for(var/mob/m in world)
				m.check_loc()
				m.movement(tick_count)

		set_icon_size()
			if(isnum(world.icon_size))
				icon_width = world.icon_size
				icon_height = world.icon_size
			else
				var/p = findtext(world.icon_size, "x")
				icon_width = text2num(copytext(world.icon_size, 1, p))
				icon_height = text2num(copytext(world.icon_size, p + 1))

	New()
		world.set_icon_size()

		..()

		spawn(world.tick_lag)
			movement_loop()



/*
// This is just some debugging stuff I was goofing around with.
// It creates a translucent red overlay that represents the
// bounding box defined by the mob's pwidth and pheight.
mob
	var
		obj/bounding_box

	proc
		bounding_box(show = 1)
			if(!bounding_box)
				var/icon/I = icon('sidescroller-demo-icons.dmi', "")
				I.DrawBox(rgb(0,0,0,0), 1, 1, 32, 32)
				I.DrawBox(rgb(255, 0, 0, 128), 1, 1, pwidth, pheight)

				bounding_box = new()
				bounding_box.icon = I
				bounding_box.layer = layer + 1

			if(show)
				overlays += bounding_box

			else
				overlays -= bounding_box
*/
