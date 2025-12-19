/********************************************************************
 *                                                                  *
 *     Just a simple little library to allow mouse based view       *
 *     movement, similar to the 'Age of Empires' family  of games.  *
 *     Basically, the library creates a ring of screen objects      *
 *     around the client screen, and when the mouse enters one of   *
 *     these objects, the client_eye is moved in the corresponding  *
 *     direction.                                                   *
 *                                                                  *
 *     This is the code section of the library. Just include the    *
 *     library by entering #include "F_ScanView.dm" into your main  *
 *     dm file.                                                     *
 *                                                                  *
 *                                                      flick()     *
 *                                                                  *
 ********************************************************************/

var/GL_F_SV_LEFT = 0
var/GL_F_SV_RIGHT = 0
var/GL_F_SV_TOP = 0
var/GL_F_SV_BOTTOM = 0

// This is the basic screen object.  A ring of them will be created around
// a new clients screen.  They are created on a very high layer (1000) to stay safely
// above any normal objects on the map.  Their mouse_opacity is set to '2', which means
// that they will still register mouse activity, even though they have transparent icons.

obj
	f_scan_view
		var
			sv_movedelay = 3   // This is the view movement delay, in ticks.

		mouse_opacity = 2
		layer = 1000
		icon = 'blank.dmi'
		icon_state = "BLANK"
		name = ""


// When the mouse enters one of these objects, check to see if the client is scanning.  If
// so, call the client.F_SV_Control.sv_Set_Eyemover(src), which sets the clients eyemover
// to this object.  Then call the Move_Eye() proc.
// This proc will continue to move the clients eye in the objects direction, so long as
// the clients eyemover remains set to it.  When the mouse exits the object, clear
// the clients eyemover, which will stop the Move_Eye() proc.


		Entered(location)
			if(!usr.client.F_SV_Control.sv_Scanning()) return
			usr.client.F_SV_Control.sv_Set_Eyemover(src)
			spawn(3)  // A small delay, to prevent movement when passing over quickly
				sv_Move_Eye(usr.client)
			..()

		Exited(location)
			if(usr.client.F_SV_Control.sv_Eyemover()) usr.client.F_SV_Control.sv_Set_Eyemover(null)
			..()

		proc
			sv_Move_Eye(client/C)
				if(C.F_SV_Control.sv_Eyemover() <> src) return
				var/turf/T = get_step(C.eye, dir)
				if(T)
					C.F_SV_New_Loc(T, dir)
//					C.eye = T
				spawn(sv_movedelay)
					sv_Move_Eye(C)

			sv_Set_Move_Delay(value)
				sv_movedelay = value

		New(loc, icon/ICON = 'blank.dmi', ICON_STATE = "BLANK", DELAY, LAYER)
			..()
			icon = ICON
			icon_state = ICON_STATE
			sv_movedelay = DELAY
			layer = LAYER

f_sv_control
	var
		sv_left_off = 0
		sv_right_off = 0
		sv_top_off = 0
		sv_bottom_off = 0
		sv_move_delay = 2
		sv_svobjects[0]
		sv_current_icon = 'blank.dmi'
		sv_current_icon_state = "BLANK"
		sv_active = TRUE
		sv_eyemover
		sv_layer = 1000
		client/sv_Owner

	proc
		sv_Scanning_On()
			sv_active = TRUE

		sv_Scanning_Off()
			sv_active = FALSE

		sv_Set_Move_Delay(value as num)
			if(value <=0) value = 1
			sv_move_delay = value
			for(var/obj/f_scan_view/F in sv_svobjects)
				F.sv_Set_Move_Delay(value)

		sv_Set_Eyemover(obj/f_scan_view/eyemover)
			sv_eyemover = eyemover

		sv_Set_Left_Offset(value as num)
			if(value < 0) value = 0
			sv_left_off = value
			sv_Create_Ring()

		sv_Set_Right_Offset(value as num)
			if(value < 0) value = 0
			sv_right_off = value
			sv_Create_Ring()

		sv_Set_Top_Offset(value as num)
			if(value < 0) value = 0
			sv_top_off = value
			sv_Create_Ring()

		sv_Set_Bottom_Offset(value as num)
			if(value < 0) value = 0
			sv_bottom_off = value
			sv_Create_Ring()

		sv_Set_Icon(icon/I)
			if(!I) return  //If you set the icon to null, the mouse events don't trigger
			sv_current_icon = I
			for(var/obj/f_scan_view/F in sv_svobjects)
				F.icon = I

		sv_Set_Icon_State(state)
			sv_current_icon_state = state
			for(var/obj/f_scan_view/F in sv_svobjects)
				F.icon_state = state

		sv_Set_Layer(value as num)
			sv_layer = value
			for(var/obj/f_scan_view/F in sv_svobjects)
				F.layer = sv_layer

		sv_Reset()
			sv_Create_Ring()

//	Create the ring of sv_objects around the clients screen, adjusting for HUD offsets.
/*	The ring is created so it looks a bit like so...

			^--------->
			|					|
			|         |
			|         |
			|         |
			<---------V

*/

		sv_Create_Ring()
			sv_svobjects.Cut()
			for(var/obj/f_scan_view/F in sv_Owner.screen)
				del F
			var/xval
			var/yval
			if(isnum(sv_Owner.view))  //If view is already a number, set xval and yval
				xval = 2*sv_Owner.view+1
				yval = 2*sv_Owner.view+1
			else													//If not, it is a text var.  Parse the xval and yval values
				var/divider = findtext(lowertext(sv_Owner.view), "x")
				xval = text2num(copytext(sv_Owner.view, 1, divider))
				yval = text2num(copytext(sv_Owner.view, divider+1))
			xval -= (sv_left_off + sv_right_off)		// adjust xval and yval for the HUD offsets.
			yval -= (sv_top_off + sv_bottom_off)
			var/i
			for(i in (1+sv_left_off) to (xval-1+sv_left_off))
				var/obj/f_scan_view/F = new(null, sv_current_icon, sv_current_icon_state, sv_move_delay, sv_layer)
				var/obj/f_scan_view/G = new(null, sv_current_icon, sv_current_icon_state, sv_move_delay, sv_layer)
				F.screen_loc = "[i], [1+sv_bottom_off]"  // Set the screen locs based on offsets to account for HUDs
				G.screen_loc = "[i+1], [yval+sv_bottom_off]"
						//Set the dir var.  The middle half is the cardinal direction(N, S, etc.), while the edges are combinations (SW, NW etc)
				F.dir = (i-sv_left_off<round(xval/4)+1) ? (SOUTHWEST) : (i-sv_left_off>(xval-round(xval/4)) ? (SOUTHEAST) : (SOUTH))
				G.dir = (i-sv_left_off<round(xval/4)) ? (NORTHWEST) : (i-sv_left_off>(xval-round(xval/4)-1) ? (NORTHEAST) : (NORTH))
				sv_svobjects += list(F,G)
			for(i in (1+sv_bottom_off)  to (yval-1+sv_bottom_off))
				var/obj/f_scan_view/H = new(null, sv_current_icon, sv_current_icon_state, sv_move_delay, sv_layer)
				var/obj/f_scan_view/I = new(null, sv_current_icon, sv_current_icon_state, sv_move_delay, sv_layer)
				H.screen_loc = "[1+sv_left_off], [i+1]"
				I.screen_loc = "[xval+sv_left_off], [i]"
				H.dir = (i-sv_bottom_off<round(yval/4)) ? (SOUTHWEST) : (i-sv_bottom_off>(yval-round(yval/4)-1) ? (NORTHWEST) : (WEST))
				I.dir = (i-sv_bottom_off<round(yval/4)+1) ? (SOUTHEAST) : (i-sv_bottom_off>(yval-round(yval/4)) ? (NORTHEAST) : (EAST))
				sv_svobjects += list(H,I)
			sv_Owner.screen += sv_svobjects

		sv_Eyemover()
			return sv_eyemover

		sv_Scanning()
			return sv_active

		sv_Move_Delay()
			return sv_move_delay

	New(client/C)
		sv_Owner = C
		sv_current_icon = icon('blank.dmi')
		sv_Create_Ring()
		..()

client
	var/f_sv_control/F_SV_Control

	proc
		F_SV_New_Loc(turf/T, direction)
			..()

	New()
		F_SV_Control = new(src)
		..()


