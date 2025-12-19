#include "F_ScanView.dm"
#include "demo.dmp"
#define MOVE_EYE  1
#define MOVE_MOB  0


// A simple little demo to go with my simple little library.


client
	view = "14x12"
	var/movewhat = MOVE_MOB

//		Determine whether we are moving client.eye or client.mob and move it.

	F_SV_New_Loc(turf/T, direction)
		if(movewhat == MOVE_EYE)
			eye = T
		else
			mob.loc = T

	verb

//		Move the client eye.  Rememeber if you do this to set client/perspective to EYE_PERSPECTIVE
		Move_Eye()
			set desc = "Cause F_ScanView to move the client eye"
			movewhat = MOVE_EYE
			perspective = EYE_PERSPECTIVE
			verbs -= /client/verb/Move_Eye
			verbs += /client/proc/Move_Mob

//		To stop scanning

		Stop_Scanning()
			set desc = "Turn off client view scanning."
			F_SV_Control.sv_Scanning_Off()
			verbs -= /client/verb/Stop_Scanning
			verbs += /client/proc/Start_Scanning



//	To set the client eye back to the original mob.

		Eye_to_Mob()
			set desc = "Set the client eye back to you (or, at least your mob)."
			eye = mob



//	Change the clients view.  You may use any of the valid view formats, the library will adjust
//	for them.  Just be sure to call F_SV_Control.sv_Reset() after you change it.

		Change_View(value as anything in list(5,6,7,8,"10x8", "12x10", "20x14"))
			set desc = "(new_view) Set the clients view size."
			view = value
			F_SV_Control.sv_Reset()



//	This allow you to see the locations and directions of the f_scan_view objects
//	by assigning an arrow icon to them.  You can assign any icon you would like using
//	F_SV_Control.sv_Set_Icon(icon/I), but be sure the icon exists, or the Mouse_Entered
//	functions won't work.

		Show_Arrows()
			set desc = "Show directional arrows around the sv_objects."
			F_SV_Control.sv_Set_Icon('arrow.dmi')
			verbs += /client/proc/Hide_Arrows
			verbs -= /client/verb/Show_Arrows



//	You can set the speed of the client view movement like this.  This may be set to a
//	different number for each client.

		Set_Delay(value as num)
			set desc = "(delay_amount) Set the movement delay, in ticks."
			F_SV_Control.sv_Set_Move_Delay(value)



//	OK, I lied.  You aren't actually creating a HUD, but you are creating a place for the HUD
//	to go when you do create it.  Otherwise, the sv_objects would cover it up, and that wouldn't
//	be good, now would it?  :)

		Create_HUD()
			set desc = "Create a space for a HUD in the client view window."
			var/where = input(src, "Where would you like the HUD to be placed?", "Create HUD") in list("TOP", "BOTTOM", "LEFT", "RIGHT")
			var/width = input(src, "How wide would you like the HUD to be?", "HUD width") in list(0,1,2,3)
			switch(where)
				if("TOP")
					F_SV_Control.sv_Set_Top_Offset(width)
				if("BOTTOM")
					F_SV_Control.sv_Set_Bottom_Offset(width)
				if("LEFT")
					F_SV_Control.sv_Set_Left_Offset(width)
				if("RIGHT")
					F_SV_Control.sv_Set_Right_Offset(width)
			usr << "I'm leaving the actual creation of the HUD to you, but if you show the arrows, you can see they now allow a space for the HUD to go."



//	This clears all the HUD offsets, though you could just clear one if you needed to.

		Clear_HUDs()
			set desc = "Clear all HUD spaces."
			F_SV_Control.sv_Set_Top_Offset(0)
			F_SV_Control.sv_Set_Bottom_Offset(0)
			F_SV_Control.sv_Set_Left_Offset(0)
			F_SV_Control.sv_Set_Right_Offset(0)


	proc
		Move_Mob()
			set desc = "Cause F_ScanView to move the client mob"
			movewhat = MOVE_MOB
			perspective = MOB_PERSPECTIVE
			eye = mob
			verbs += /client/verb/Move_Eye
			verbs -= /client/proc/Move_Mob

//	Hide the sv_object icons, which would probably be the normal look, I would think.

		Hide_Arrows()
			set desc = "Hide the directional arrows."
			F_SV_Control.sv_Set_Icon('blank.dmi')
			verbs += /client/verb/Show_Arrows
			verbs -= /client/proc/Hide_Arrows



//	This starts the scanning process if you turned it off.

		Start_Scanning()
			set desc = "Turn on client view scanning."
			F_SV_Control.sv_Scanning_On()
			verbs += /client/verb/Stop_Scanning
			verbs -= /client/proc/Start_Scanning



//	Generic mob and turf stuff...

turf
	icon = 'turf.dmi'
	grass
		icon_state = "GRASS"
	forest
		icon_state = "FOREST"
	water
		icon_state = "WATER"
client
	verb
		Say(message as text)
			set desc = "(message) Say something to everyone here."
			if(message)
				world << "<B>[src]:</b> [message]"
mob
	icon = 'mob.dmi'

client
	New()
		..()
		src << "<center><b>Welcome [src]!</b></center><br><br>This is just a demo for my F_ScanView library.  The library allows you to move a players client eye around the world, simply by moving their mouse to the edge of the screen in the direction they would like to go.<br><BR>The library is compatible with HUDs, and you may still change the clients view in game.  Most of the variables are configurable, so play around with it a bit and test out the different functions.   Show/Hide Arrows allows you to see the location and direction of the f_scan_view objects.<br><br>Have fun!<br>flick()"
world
	hub = "Flick.F_ScanView_Demo"