obj/reflection
	vis_flags = VIS_INHERIT_ICON|VIS_INHERIT_ICON_STATE|VIS_INHERIT_DIR|VIS_INHERIT_LAYER|VIS_UNDERLAY
	appearance_flags = PIXEL_SCALE
	color = list(1,0,0,0,
				0,1,0,0,
				0,0,1,0,
				0,0,0,1,
				0.3125,0.3125,0.3125,0)
	alpha = 192
	plane = REFLECTION_PLANE
	mouse_opacity = 0

	New(loc,mob/owner)
        //set up a simple passive animation for the reflection to give it a sort of wavering effect.
		if(!owner)
			return
		else
			pixel_y = owner.reflection_offset
			var/matrix/m2 = matrix(1.25,0,0,0,-1,0)
			var/matrix/m1 = matrix(0.75,0,0,0,-1,0)
			var/matrix/m0 = matrix(1,0,0,0,-1,0)
			transform = m0
			animate(src,transform=m1,time=2.5,loop=-1)
			animate(transform=m0,time=2.5)
			animate(transform=m2,time=2.5)
			animate(transform=m0,time=2.5)

			owner.vis_contents += src
			..()

atom/movable
	var
		has_reflection = 0
		reflection_offset = -48
		tmp/obj/reflection
	New()
		..()
		if(has_reflection)
			reflection = new/obj/reflection(null,src)
	Del()
		if(reflection)
			vis_contents -= reflection
			reflection = null
		..()