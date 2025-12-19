// The guts of the system.

// NOTE: This can also be done without the darkness plane, by putting the master_plane and mlight sources on the same plane (eg: 2)
// However, this will cause things to be interlayered in a way that will make players running in software rendering mode able to see fully as if no darkness existed.
// This method will give them a fully black screen with no advantage.

image
	master_plane
		// I place the master plane on 0 so it'll on the default plane of most everything in the game.
		// If things exist above plane 0, they'll appear above the master.
		plane = 0
		blend_mode = BLEND_MULTIPLY // Anything covered by this will have its color multiplied as they blend.
		appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR // Specifies the plane is a master and it will ignore client.color values.
		color = list(null,null,null,"#0000","#000f") // Sets a color matrix to pure black with full alpha.
		mouse_opacity = 0 // Makes sure all mouse events ignore the plane.

	darkness
		// The darkness will appear behind the master plane and cover the entire screen
		// I do it this way to allow finer control over the alpha levels and color of the "darkness" players see on their screen.
		// In reality it's just a scaled-up white block.
		plane = -1
		blend_mode = BLEND_ADD // Any color value applied to this image will be added to the color of anything blending with it.
		mouse_opacity = 0
		icon = 'darkness.dmi'
		New()
			..()
			var/matrix/m = matrix()
			m.Scale(world.view*2.2)
			transform = m
			// Scaling it up to cover the screen, I can probably use a single screen object for this...
			// ... but I've found some cool screen-wide effects you can pull off by using a single graphic.



obj
	mlight
		plane = -1
		blend_mode = BLEND_ADD
		icon = 'light.dmi'
		icon_state = "circle"
		mouse_opacity = 0
		// The mlight and darkness share a plane and most traits, when adding the pure white color of the mlight, and its alpha values.
		// And the color and alpha values of the darkness image...
		// ... you end up blending away the master plane's blacking out of the view.

	lamp
		icon = 'lamp.dmi'
		icon_state = "off"
		density = 1
		// A basic mlight source object.
		var
			obj/mlight/mlight
			matrix
				on_matrix = matrix()
				off_matrix = matrix()
		New()
			// With some fancy turning off and on animation...
			..()
			mlight = new(src.loc)
			on_matrix.Scale(8)
			off_matrix.Scale(0)
			mlight.transform = off_matrix
			Toggle()
		Click()
			Toggle()
		proc/Toggle()
			if(icon_state == "off")
				icon_state = "on"
				animate(mlight,transform=on_matrix,time=5)
				sleep(6)
				// And flickering...
				animate(mlight,color=rgb(220,220,220),time=4,loop=-1)
			else
				icon_state = "off"
				animate(mlight,transform=off_matrix,time=5)
				mlight.color = null


mob
	var
		// You don't actually need variables for the master_plane and darkness, unless you plan on fiddling with them on the fly.
		// You can get away with simply outputting the /image to the mob and being done with it.
		// The mlight object has a variable for obvious purposes.
		obj/mlight/mlight
		image
			darkness/darkness
			master_plane/master_plane
	Login()
		..()
		// First we create new images contained by src for /image/master_plane and /image/darkness.
		master_plane = new(loc=src)
		darkness = new/image/darkness(loc=src)
		// Then we output them to the player so that they're added to images and displayed.
		src << master_plane
		src << darkness
		// Now we create a new mlight at the player's location.
		mlight = new(src.loc)
		// And set the alpha value of it so that it's not full-bright.
		mlight.alpha = 150
		// Then set the darkness alpha somewhere low so it gets dark outside.
		darkness.alpha = 20

		// And make the player's mlight a little bigger so they're not totally blind.
		var/matrix/m = new()
		m.Scale(2)
		mlight.transform = m

	Move()
		..()
		// Simply keeps the player's mlight on the same tile as the player
		if(mlight) mlight.loc = src.loc
