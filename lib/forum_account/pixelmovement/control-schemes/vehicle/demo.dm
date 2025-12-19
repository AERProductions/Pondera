
// File:    control-schemes\vehicle\demo.dm
// Library: Forum_account.PixelMovement
// Author:  Forum_account
//
// Contents:
//   An example of an alternate control scheme where the player
//   uses the up and down arrow keys to speed up and slow down
//   and the left/right arrow keys to turn.

world
	view = 6

PixelMovement
	debug = 1

atom
	icon = 'basic-icons.dmi'

mob
	icon_state = "round-mob"

	pwidth = 24
	pheight = 24
	pixel_x = -4
	pixel_y = -4

	// We define these vars to keep track of the mob's angle
	// and speed. The library defines the vel_x and vel_y vars,
	// but we don't have to use them.
	var
		angle = 0
		speed = 0

		// this controls how quickly or slowly the mob
		// accelerates and decelerates
		acceleration = 1

	Login()
		..()
		src << "Use the left/right arrow keys to turn and the up/down arrow keys to move."

	action()

		var/a = 0
		if(client.keys[controls.left]) a += 5
		if(client.keys[controls.right]) a -= 5

		// if you're pressing up you go forwards
		if(client.keys[controls.up])
			if(speed < move_speed)
				speed += acceleration

		// if you're pressing down you go backwards
		else if(client.keys[controls.down])
			if(speed > -move_speed / 2)
				speed -= acceleration

		// otherwise you slow down
		else
			if(speed > acceleration)
				speed -= acceleration
			else if(speed < -acceleration)
				speed += acceleration
			else
				speed = 0

		angle += a

		// generate a rotated icon to represent the angle that you're facing.
		var/icon/I = icon('basic-icons.dmi', "round-mob")
		I.Turn(-angle)
		icon = I

		if(speed != 0)
			var/dx = round(cos(angle) * speed + 0.5)
			var/dy = round(sin(angle) * speed + 0.5)
			pixel_move(dx, dy)

turf
	icon_state = "floor"

	wall
		density = 1
		icon_state = "wall"