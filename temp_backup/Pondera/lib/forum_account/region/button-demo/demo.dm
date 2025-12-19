
// File:    button-demo\demo.dm
// Library: Forum_account.Region
// Author:  Forum_account
//
// Contents:
//   This file contains the code for the demo that uses the
//   library. The button's constructor finds the door in its
//   same group and links the button to that door.

// we draw this region on the map to form groups connecting doors to buttons.
region
	link
		icon_state = "region-1"

turf
	button

		// every button has as reference to the door it controls
		var
			turf/door/door

		New()
			..()

			// get an instance of /turf/door that's in the same connected region
			door = region.get(src, /turf/door)

		// turning the switch on opens the door
		on()
			..()
			door.open()

		// turning it off closes the door
		off()
			..()
			door.close()

mob
	Login()
		..()

		src << "Step on a button to open a door."
