
#define DEBUG

// File:    wire-demo\demo.dm
// Library: Forum_account.Region
// Author:  Forum_account
//
// Contents:
//   This file contains the code for the demo that uses the
//   library. We use the region's added() and removed() procs
//   to place objects on the map to represent the wire.

// we create a global reference to the wire region
var
	region/wire/wire

world
	New()
		..()

		// get a reference to the wire
		wire = locate(/region/wire)

region
	// the wire region acts like any other region except we place
	// a wire obj (/obj/wire) on each turf to create a visual effect.
	wire
		icon_state = "wire-15"

		// when a turf is added to the region we create the /obj/wire
		added(turf/t)
			new /obj/wire(t)

		// when a turf is removed from the region, we remove the /obj/wire
		removed(turf/t)
			t << "Snip!"
			del locate(/obj/wire) in t

// The Center proc places or removes wires.
client
	Center()

		// All we have to do here is add or remove a turf from the region.
		// The graphical effect is handled by the region object itself.
		if(mob.loc in wire.turfs)
			wire.remove(mob.loc)
		else
			wire.add(mob.loc)

// The wire object manages only the graphical representation of the wire,
// it handles the autojoining for when wires are created and removed.
obj
	wire
		New(turf/t)
			..()

			for(var/obj/wire/w in view(1, src))
				w.autojoin()

		Del()
			var/turf/t = loc

			// Remove the wire from the map.
			loc = null

			// Then call autojoin for its former neighbors.
			for(var/obj/wire/w in oview(1, t))
				w.autojoin()

			..()

		proc
			autojoin()
				var/n = 0
				if(locate(/obj/wire) in locate(x, y + 1, z)) n += 1
				if(locate(/obj/wire) in locate(x + 1, y, z)) n += 2
				if(locate(/obj/wire) in locate(x, y - 1, z)) n += 4
				if(locate(/obj/wire) in locate(x - 1, y, z)) n += 8

				icon_state = "wire-[n]"

turf
	door
		layer = OBJ_LAYER + 0.5

	button
		layer = OBJ_LAYER + 0.5

		var
			list/doors

		// we get a list of doors every time you step on the button because
		// the doors its connected to may change if you add or remove wires
		toggle()
			doors = wire.get_list(src, /turf/door)
			..()

		// turning the switch on opens all of the  the doors
		on()
			..()
			for(var/turf/door/d in doors)
				d.open()

		// turning it off closes all of the doors
		off()
			..()
			for(var/turf/door/d in doors)
				d.close()

mob
	Login()
		..()
		src << "Step on a button to open a door."
		src << "Press 5 on the numpad to place or remove wires."
