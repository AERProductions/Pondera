
#define DEBUG

// File:    v3.0/demo.dm
// Library: Forum_account.Sidescroller
// Author:  Forum_account
//
// Contents:
//   This demo shows how to use the new accel, decel, and
//   gravity vars to change how a mob moves.

world
	view = 6

atom
	icon = 'sidescroller-demo-icons.dmi'

mob
	base_state = "mob"

	Login()
		..()
		pwidth = 24
		pheight = 24

		SIDESCROLLER_DEBUG = 1

	verb
		// verbs to modify movement acceleration/deceleration rates
		Movement_Slow()
			accel = 0.5
			decel = 0.5
			world << "accel = [accel], decel = [decel]"

		Movement_Normal()
			accel = 1
			decel = 1
			world << "accel = [accel], decel = [decel]"

		Movement_Quick()
			accel = 3
			decel = 2
			world << "accel = [accel], decel = [decel]"

		Movement_Instant()
			accel = move_speed
			decel = move_speed
			world << "accel = [accel], decel = [decel]"

		// verbs to modify acceleration from gravity
		Gravity_Low()
			gravity = 0.5
			world << "gravity = [gravity]"

		Gravity_Normal()
			gravity = 1
			world << "gravity = [gravity]"

		Gravity_High()
			gravity = 1.5
			world << "gravity = [gravity]"

turf
	icon_state = "white"

	var
		vel_x = 0
		vel_y = 0

	ladder
		icon_state = "ladder"
		ladder = 1

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
