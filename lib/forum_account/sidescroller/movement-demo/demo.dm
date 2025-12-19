
// Note: In the version 2.3 update these constants were
// added to show how atom.flags is used. The ICY bit is
// set for icy floors, when on an icy floor the mob's
// slow_down proc will do nothing. The CLIMBABLE bit is
// for the climber mob - it can only climb walls if this
// bit is set.
var
	const
		ICY = 2
		CLIMBABLE = 4

world
	view = 6

	New()
		SIDESCROLLER_DEBUG = 1
		..()

atom
	icon = 'sidescroller-demo-icons.dmi'

	// By default everything is climbable.
	flags = CLIMBABLE

client
	New()
		..()
		src << "Use the Normal, Flyer, and Climber verbs on the \"Commands\" tab to change movement schemes."

mob
	base_state = "mob"

	Login()
		..()

		loc = locate(2,2,1)
		pwidth = 24
		pheight = 24

	verb
		Normal()
			client.mob = new /mob/normal(loc)
			del src

		Flyer()
			client.mob = new /mob/flyer(loc)
			del src

		Climber()
			client.mob = new /mob/climber(loc)
			del src

	// create this behavior for all mobs
	slow_down()
		// if the player is standing on ice we don't call ..()
		// so the mob doesn't slow down.
		if(on_ground & ICY)
			return

		// calling ..() runs the default behavior which makes
		// the mob slow down.
		..()

	// normal mobs can run, jump, and climb ladders
	normal
		Login()
			..()
			src << "Use the arrow keys to move and the space bar to jump."

	// flyer mobs can fly by pressing up while in the air
	flyer
		Login()
			..()
			src << "Use the arrow keys to move and the space bar to jump. Press up while in the air to fly.."

		move(d)
			..()

			// if you're holding up and you're not on the ground,
			// you'll fly (accelerate upwards)
			if(d == UP)
				if(!on_ground)
					if(vel_y < 4)
						vel_y += 1

		gravity()
			// if you're flying gravity doesn't apply to you
			if(!client.keys[K_UP] || vel_y > 4)
				..()

			// limit your falling speed
			if(vel_y < -4)
				vel_y = -4

	// climber mobs can walk up vertical walls
	climber
		Login()
			..()
			src << "Use the arrow keys to move and the space bar to jump. Press up while against a wall to climb it."

		gravity()
			// if you're a climber, you don't fall when you're
			// on the ground or next to a wall
			if(!on_ground && !(on_right & CLIMBABLE) && !(on_left & CLIMBABLE))
				..()

		// climbers can jump if they're against a wall too
		can_jump()
			return on_ground || (on_left & CLIMBABLE) || (on_right & CLIMBABLE)

		jump()
			if(on_ground)
				vel_y = 10

			// when against a wall, the climber jumps up
			// and away from the wall
			else if(on_left)
				vel_y = 7
				vel_x = 5
			else if(on_right)
				vel_y = 7
				vel_x = -5

		move(d)
			..()

			// climbers can accelerate up and down if they're
			// next to a wall
			if(d == UP)
				if((on_left & CLIMBABLE) || (on_right & CLIMBABLE))
					if(vel_y < 3)
						vel_y += 1
			else if(d == DOWN)
				if((on_left & CLIMBABLE) || (on_right & CLIMBABLE))
					if(vel_y > -5)
						vel_y -= 1

		slow_down()
			..()

			// climbers also slow down when they're next to a
			// wall and not holding up or down
			if((on_left & CLIMBABLE) || (on_right & CLIMBABLE))
				if(!client.keys[K_UP] && !client.keys[K_DOWN])
					if(abs(vel_y) < 1)
						vel_y = 0
					else if(vel_y > 0)
						vel_y -= 1
					else if(vel_y < 0)
						vel_y += 1

mob
	scaffold
		icon_state = "mob"

		// You can set the scaffold var on mobs too.
		scaffold = 1
		pwidth = 24
		pheight = 24

		movement()

turf
	icon_state = "white"

	ladder
		icon_state = "ladder"
		ladder = 1

	platform
		icon_state = "platform"

		// setting scaffold = 1 makes the turf act like a scaffold,
		// you can walk in front of it and stand on top of it. You
		// don't need to set its density for this to work.
		scaffold = 1

	platform_ramp_1
		icon_state = "platform-ramp-1"

		scaffold = 1
		pleft = 0
		pright = 16

	platform_ramp_2
		icon_state = "platform-ramp-2"

		scaffold = 1
		pleft = 16
		pright = 32

	wall
		density = 1
		icon_state = "wall"

		New()
			..()
			if(type == /turf/wall)
				var/n = 0
				var/turf/t = locate(x,y+1,z)
				if(t && istype(t,type)) n += 1
				t = locate(x+1,y,z)
				if(t && istype(t,type)) n += 2
				t = locate(x,y-1,z)
				if(t && istype(t,type)) n += 4
				t = locate(x-1,y,z)
				if(t && istype(t,type)) n += 8
				icon_state = "wall-[n]"

		ice
			flags = ICY
			icon_state = "ice"

		ice_wall
			icon_state = "ice-sides"

			// make it not climbable
			flags = 0