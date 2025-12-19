
// File:    overlays.dm
// Library: Forum_account.HandyStuff
// Author:  Forum_account
//
// Contents:
//   BYOND's built-in support for overlays is pretty good, but
//   it has a few quirks. For example, creating an overlay with
//   a pixel offset is kind of strange (you have to create an
//   object first and add the object as an overlay). Then, if you
//   want to change its pixel offset you have to remove the overlay
//   and add it back for the change to take effect.
//
//   This file defines the /Overlay object which provides you with
//   an easier way to deal with overlays. The constructor for the
//   /Overlay object looks like this:
//
//       new /Overlay(atom, icon, [icon_state])
//
//   "atom" is the object which the overlay is attached to. If you
//   don't specify an icon_state, the overlay's icon state will
//   always match its owner's icon state.
//
//   The /Overlay object has procs which let you read and write its
//   properties. For example:
//
//       overlay.PixelX()
//       overlay.PixelX(3)
//
//   The first call to PixelX returns the overlay's pixel_x. The
//   second call sets the overlay's pixel_x to 3. This same behavior
//   (no argument = return value, one argument = set value) exists
//   for procs to read/write the overlay's pixel_y, icon_state,
//   icon, and layer.
//
//   The /Overlay proc also contains support for animating
//   overlays. By calling overlay.Flick(state, duration) you'll
//   play an animation for that single overlay. Using BYOND's
//   built-in overlays you can only animate an overlay by calling
//   flick() for the mob that has the overlays, this would also
//   animate all other overlays. The Flick() proc defined here lets
//   you animate individual overlays.

mob
	var
		list/flicked_overlays = list()
		list/flicked_overlay_pool

	New()
		..()

		flicked_overlay_pool = list()
		for(var/i = 1 to 3)
			var/obj/o = new /obj(loc)
			o.invisibility = 1
			o.layer = layer + 0.1
			flicked_overlay_pool += o

	Move()
		. = ..()

		if(.)
			for(var/obj/o in flicked_overlays)
				o.pixel_step_size = pixel_step_size
				o.Move(loc)

			for(var/obj/o in flicked_overlay_pool)
				o.pixel_step_size = pixel_step_size
				o.Move(loc)

Overlay
	var
		mob/owner
		obj/overlay_obj
		visible = 1

	New(mob/o, i, is = null)

		overlay_obj = new /obj()
		overlay_obj.icon = i
		overlay_obj.layer = o.layer + 1

		owner = o

		if(is != null)
			overlay_obj.icon_state = is

		owner.overlays += overlay_obj

	proc
		Icon()
			if(args.len)
				owner.overlays -= overlay_obj
				overlay_obj.icon = args[1]
				owner.overlays += overlay_obj
			else
				return overlay_obj.icon

		PixelX()
			if(args.len)
				owner.overlays -= overlay_obj
				overlay_obj.pixel_x = args[1]
				owner.overlays += overlay_obj
			else
				return overlay_obj.pixel_x

		PixelY()
			if(args.len)
				owner.overlays -= overlay_obj
				overlay_obj.pixel_y = args[1]
				owner.overlays += overlay_obj
			else
				return overlay_obj.pixel_y

		IconState()
			if(args.len)
				owner.overlays -= overlay_obj
				overlay_obj.icon_state = args[1]
				owner.overlays += overlay_obj
			else
				return overlay_obj.icon_state

		Layer()
			if(args.len)
				owner.overlays -= overlay_obj
				overlay_obj.layer = args[1]
				owner.overlays += overlay_obj
			else
				return overlay_obj.layer

		Flick(is, duration)

			if(duration == null)
				CRASH("Flick requires 2 arguments, the second is the duration of the animation.")

			// initialize owner.flicked_overlay_pool if we need to
			if(!owner.flicked_overlay_pool)
				owner.flicked_overlay_pool = list()
				for(var/i = 1 to 3)
					var/obj/o = new /obj(owner.loc)
					o.invisibility = 1
					o.layer = owner.layer + 0.1
					owner.flicked_overlay_pool += o

			// If the pool is empty, add another object
			if(!owner.flicked_overlay_pool.len)
				var/obj/o = new /obj(owner.loc)
				o.invisibility = 101
				o.layer = 0
				owner.flicked_overlay_pool += o

			// grab an object from the pool and use it as the flicked overlay
			var/obj/o = owner.flicked_overlay_pool[1]
			owner.flicked_overlay_pool.Cut(1,2)

			o.animate_movement = SYNC_STEPS
			o.invisibility = owner.invisibility
			o.icon = overlay_obj.icon
			o.layer = overlay_obj.layer

			visible -= 1
			owner.flicked_overlays += o

			owner.overlays -= overlay_obj
			flick(is, o)

			sleep(duration)

			owner.flicked_overlays -= o
			owner.flicked_overlay_pool += o
			o.invisibility = 101
			o.layer = 0

			visible += 1
			if(visible > 0)
				owner.overlays += overlay_obj

/*
		// This is the old implementation of Flick, it doesn't use the flicked_overlay_pool list
		Flick(is, duration)

			if(duration == null)
				CRASH("Flick requires 2 arguments, the second is the duration of the animation.")

			var/obj/o = new /obj(owner.loc)
			o.animate_movement = SYNC_STEPS
			o.icon = overlay_obj.icon
			o.layer = overlay_obj.layer

			visible -= 1
			owner.flicked_overlays += o

			owner.overlays -= overlay_obj
			flick(is, o)

			sleep(duration)

			owner.flicked_overlays -= o
			del o

			visible += 1
			if(visible > 0)
				owner.overlays += overlay_obj
*/