







//			DEMO WORLD SETUP.


world
	name			= "kii_lighting demo"
	map_format		= TOPDOWN_MAP	// this library works in both TOPDOWN_MAP and SIDE_MAP modes, however minor engine-related layering issues may crop up depending on use-cases and which mode you use.
	fps				= 60

	New()
		..()
	/*	make sure to run daynight.draw_global_lighting() at world startup.
	*/
		daynight.draw_global_lighting()













//			EXAMPLE MOB DEFINITION.. EMISSIVE AND OCCLUDER.




mob
	icon			= 'DEMO/mob.dmi'
	plane			= ACTION_PLANE
	step_size		= 4
	/* below is the important part.

		for mobs, we want them to occlude emissives behind them..
				.. however in some cases we might want to give mobs a subtle emissive mask too.. so let's leave that option available!
				because mobs can be emissive AND occlude we need to give them the PLANE_EMITTER flag *and* the PLANE_OCCLUDER flag.


		brightness is used to determine exactly how bright the emissive mask should be.
			1.0 = 100% emissive.
			0.5 = 50% emissive.
			0 	= not emissive at all.
	*/
	plane_flags		= PLANE_EMITTER | PLANE_OCCLUDER
	brightness		= 0.5	// only 50% emissive.





	New()
		make_emissive( STATIC )
		make_occlude( STATIC )
	// 	since we don't have multiple icon_states for our mob icon, we can just use STATIC masks!
	// 	see the "emit" and "occlude" states in DEMO/mob.dmi for an example.
		walk_rand(src, 0.1, 2)









	Login()
		..()
	//	when a player joins, be sure to run this bit to make sure their lighting render_planes get drawn/applied.
		client.draw_lighting()

		if(!spotlight)
			draw_spotlight(-32, -32, null, 1.0, 200)
	//	NOTE: drawing a spotlight does *not* immediately apply the spotlight. You'll need to draw it and then also toggle it on.
		toggle_spotlight(1)	// like this..!








	//			now lets do another mob but instead of being wholly emissive.. lets only make its eyes emissive!
	eyeglow_mob
		icon			= 'DEMO/eyeglow_mob.dmi'
		plane			= ACTION_PLANE
		step_size		= 4

		plane_flags		= PLANE_EMITTER | PLANE_OCCLUDER
		brightness		= 1.0	// fully emissive this time!

		/* so it looks identical to the default mob emissive/occlusion masks. It will still be a STATIC mask.
			Main difference with the code is the brightness is 1.0 instead of 0.5 here.

			All the heavy lifting with setting up masks is done in the icon files. So since we ONLY want the eyes to be emissive on this mob,
				we need to setup a new dmi file for the mob and only whitemask the eyes of the "emit" icon_state.

				See DEMO/eyeglow_mob.dmi for an example.
		*/


		New()
			make_emissive( STATIC )
			make_occlude( STATIC )
			if(!spotlight)
				draw_spotlight(-32, -32, null, 1.0, 50)
			toggle_spotlight(1)
			walk_rand(src, 0.1, 2)











//			DEMO VERBS FOR DEMO PURPOSES.... PORPOISES.




	verb
		manual_toggle_spotlight()
			/* called to manually hide/show the spotlight for demo purposes.
			*/
			if( !(spotlight in vis_contents) )
				toggle_spotlight(1)
			else toggle_spotlight(0)


		tint_spotlight(var/_col as color)
			/* call to manually change the spotlight's tint for demo purposes.
			*/
			edit_spotlight(, , _col, , )




















//			EMISSIVE OBJECT EXAMPLE





obj
	fire
		/* so if we want to make an object like fire, that is emissive and "glows"..
		*/
		icon			= 'fire.dmi'
		icon_state		= "fire1"

		plane			= ACTION_PLANE
		layer			= MOB_LAYER
		/* this is the important part.

			since we only want fire to be emissive (not occlude emissives behind it) we only need to apply the PLANE_EMITTER flag here.
			brightness is used to determine exactly how bright the emissive mask should be.
				1.0 = 100% emissive.
				0.5 = 50% emissive.
				0 	= not emissive at all.
		*/
		plane_flags		= PLANE_EMITTER
		brightness		= 1.0


		New()
			..()
			icon_state	= "fire[rand(1,2)]"
			draw_spotlight(-32, -32, "#ffb516", 2.0, 55)
			toggle_spotlight(1)
		/*	so. since fire in this case can have multiple different icon_states; a STATIC mask won't work here.
			We'll need to make a DYNAMIC mask to handle the different icon_states.

			See DEMO/fire_mask_emit.dmi for an example of how to setup DYNAMIC masks.
		*/
			make_emissive( DYNAMIC, dynamic_mask = 'fire_mask_emit.dmi' )









//			OCCLUDER OBJECT EXAMPLE




	tree
		icon			= 'DEMO/tree.dmi'
		layer			= MOB_LAYER
		plane			= ACTION_PLANE

		bound_x			= 26
		bound_width		= 37
		bound_height	= 32
		density			= 1
	/*	so since trees aren't emissive, we only need to apply the PLANE_OCCLUDER flag. no brightness.
	*/
		plane_flags 	= PLANE_OCCLUDER


		New()
			..()
			/* since this demo uses a static tree icon, we can use a STATIC mask here.
					.. however if you're like me and have trees in your project that can take on multiple icon_states, you'd need to use a DYNAMIC mask. See Fire above for an example.
			*/
			make_occlude( STATIC )









turf
	icon	= 'DEMO/turf.dmi'
	plane	= GROUND_PLANE


	/* there's better ways to do the below bit, but this will just give random turfs a spotlight for some ambient lighting.
		not really a recommended approach for larger projects.
	*/
	New()
		..()
		if(plane == GROUND_PLANE && prob(25))
			draw_spotlight(-32,-32, "#FFFFFF", 1, rand(1,10))
			toggle_spotlight(1)