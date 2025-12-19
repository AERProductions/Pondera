#include "F_ScanView_code.dm"

/********************************************************************
 *                                                                  *
 *     Just a simple little library to allow mouse based view       *
 *     movement, similar to the 'Age of Empires' family  of games.  *
 *     Basically, the library creates a ring of screen objects      *
 *     around the client screen, and when the mouse enters one of   *
 *     these objects, the next turf in that direction is returned   *
 *     to client/F_SV_New_Loc(turf/T, direction).  You can then    *
 *     either move the clients eye or mob to the new turf.          *
 *                                                      flick()     *
 *                                                                  *
 ********************************************************************/


/*	A whole bunch of changes to the library, before anyone even got to see it :)
		There is now an f_sv_control datum client var, that gets created in client.New()
		All functions and variables are available through this var, client.F_SV_Control
		To change any of the view scanning behavior, simply call the appropriate F_SV_Control
		proc.

		Two important factors...  If you change the client.eye in F_SV_New_Loc(), you are going
		to need to set client/perspective to EYE_PERSPECTIVE, so players can still see things
		once the client eye moves out of their mobs view.  Second, anytime you change the clients
		view var, be SURE to call F_SV_Control.sv_Reset() to adjust the sv_objects.

		Rather than automatically moving the client.eye, the library now returns the turf and
		direction of movement to client/F_SV_New_Loc(turf/T, direction)
*/

client/F_SV_New_Loc(turf/T, direction)
		/*
			When the mouse moves to the edge of the map, the turf one step in the corresponding
			direction from client eye is returned to this proc, along with the direction.  You can
			use this to change either the client eye or mob location, or however else you would like
		*/
	return ..()

/*	The following are the usefull f_sv_control procs, and a brief description of what they do */




f_sv_control/sv_Reset()
		/*
		  VERY IMPORTANT!!! Any time you change the clients view var, you must call this
		  proc afterwards, or the library will not function correctly!
		*/
	return ..()




f_sv_control/sv_Scanning_On()
		/*
			By default, scanning is turned on.  However, you may turn it on and off yourself
			by calling this and the following proc.  This turns scanning on...
		*/
	return ..()



f_sv_control/sv_Scanning_Off()
		/*
			This turns it off
		*/
	return ..()

// 	If you would like scanning to be turned off by default, set this var to FALSE

f_sv_control/sv_active = TRUE



f_sv_control/sv_Set_Move_Delay(value as num)
		/*
			Use this to set the client eye movement speed.  This causes a delay of 'value' ticks
			between	movements.  The value must be >0.
		*/
	return ..()



/*		The following	four procs relate to the use of HUDs (Heads Up Displays) in the clients
			screen.  Since the sv_objects are on a very high layer (1000), and would conflict with
			HUD elements that need to be clicked, you may adjust the positioning of the sv_objects
			with these procs to keep them out of the way of your HUD.  For example, if you have a HUD
			which is one icon high running along the bottom of the clients screen, you would
			simply call client.F_SV_Control.sv_Set_Bottom_Offset(1).  That will raise the sv_objects up
			to the y=2 row of the clients screen.  Check out the demo to see how it works.  You may
			have offsets on all four sides of the screen if you want, though you must be carefull to
			keep the offsets from being bigger than the screen itself.
			client.F_SV_Control.sv_Set_Bottom_Offset(50) is probably a bad idea :)
*/

f_sv_control/sv_Set_Left_Offset(value as num)
		/*
			This sets the size of the left offset
		*/
	return ..()


f_sv_control/sv_Set_Right_Offset(value as num)
		/*
			This sets the size of the right offset
		*/
	return ..()


f_sv_control/sv_Set_Top_Offset(value as num)
		/*
			This sets the size of the top offset
		*/
	return ..()


f_sv_control/sv_Set_Bottom_Offset(value as num)
		/*
			This sets the size of the bottom offset
		*/
	return ..()



f_sv_control/sv_Set_Icon(icon/I)
		/*
			If you would like to show a different icon where the sv_objects are.  Examine the
			'arrow.dmi' icon to see how they should be set up.
		*/
	return ..()



f_sv_control/sv_Set_Icon_State(icon/I)
		/*
			If you would like to show a different icon_state (don't know why, but I figured I would
			put it in :) for the sv_objects.
		*/
	return ..()



f_sv_control/sv_Set_Layer(value as num)
		/*
			This allows you to change the layer of the sv_objects.  They default to layer 1000, so
			unless you are working on a really nasty isometric engine, you should be ok :)
		*/
	return ..()
