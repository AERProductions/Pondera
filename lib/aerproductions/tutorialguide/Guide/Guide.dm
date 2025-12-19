/*
	Simple library to add a useful tutorial guide to your game.
	AUTHOR: AERProductions (JGP)
	1/24/2020
 */

world
	hub = "AERProductions.TutorialGuide" //Hub name
	fps = 25		// 25 frames per second
	icon_size = 64	// 32x32 icon size by default
	turf = /turf/Grass //define the turf icon
	view = 6		// show up to 6 tiles outward from center (13x13 view)
	mob = /mob/ //define the mob

mob
	step_size = 8// Make objects move 8 pixels per tick when walking
	var
		tutopen = 0//tutorial open variable, bitflag 1 = true (open) 0 = false(closed)

	Login()//logging in...
		for(usr)//declaring who
			var/obj/IG/TUT = new(src)//new guide in source
			usr << "<font color=#FFFB98>[TUT] added to inventory. Use it to learn more!"//usr notification and var usage(otherwise undefined)
			winset(usr, null,"output.background-color=#474747")
mob

	Stat() //statpanel to show inventory with usr contents
		..()
		statpanel("Inventory")//inventory statpanel (text tab)
		stat(contents)//actual usr contents

obj
	step_size = 8

turf
	Grass//turf name
		icon = 'tut.dmi'//tutorial icon declaration
		icon_state = "Grass"//Grass icon stat declaration


