
turf
	icon_state = "sky"

	// The bumped() proc is called every time the player bumps
	// a tile from below. The default behavior is the visual effect.
	// We don't use it, but the mob that bumped the turf is passed
	// as a parameter.
	proc
		bumped(mob/bumper)
			if(pixel_y > 0) return

			for(var/mob/m in locate(x, y + 1, z))
				m.vel_y = 4

			spawn()
				pixel_y += 2
				sleep(world.tick_lag)
				pixel_y += 2
				sleep(world.tick_lag)
				pixel_y += 2
				sleep(2 * world.tick_lag)
				pixel_y -= 4
				sleep(world.tick_lag)
				pixel_y -= 4
				sleep(world.tick_lag)
				pixel_y += 2

	red_stone
		density = 1
		icon_state = "red-stone"
	red_brick
		density = 1
		icon_state = "red-brick"
	red_block
		density = 1
		icon_state = "red-block"

	bush
		left
			icon_state = "bush-left"
		middle
			icon_state = "bush-middle"
		right
			icon_state = "bush-right"

	cloud
		top_left
			icon_state = "cloud-top-left"
		top_middle
			icon_state = "cloud-top-middle"
		top_right
			icon_state = "cloud-top-right"
		bottom_left
			icon_state = "cloud-bottom-left"
		bottom_middle
			icon_state = "cloud-bottom-middle"
		bottom_right
			icon_state = "cloud-bottom-right"

	hill
		left
			icon_state = "hill-left"
		middle
			icon_state = "hill-middle"
		right
			icon_state = "hill-right"
		top
			icon_state = "hill-top"

	pipe_top_left
		density = 1
		icon_state = "pipe-top-left"
	pipe_top_right
		density = 1
		icon_state = "pipe-top-right"
	pipe_left
		density = 1
		icon_state = "pipe-left"
	pipe_right
		density = 1
		icon_state = "pipe-right"

	ladder
		icon_state = "ladder"
		ladder = 1

	coin_block
		density = 1
		icon_state = "coin-block"

		var
			coin = 1

		bumped(mob/m)

			// you only get one coin from these blocks
			if(!coin) return

			coin = 0
			icon_state = "empty-block"
			new /obj/coin(src)

// the coin object just displays the coin icon, then
// disappears after one second
obj
	coin
		pixel_y = 32
		icon_state = "coin"

		New()
			..()
			spawn(10)
				del src