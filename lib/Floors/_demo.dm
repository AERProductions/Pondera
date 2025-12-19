

client

	New()
		..()
		view = "20x20"

		src << "Welcome to the Floors Demo"
		src << "To pick up something press the g key"
		src << "To drop somethin press the d key"
		src << "To go invisible press the i key"
		src << "To lock invisibility press the l key"

		winset(src,"input","command=\"!.alt\";" ) 	//forces .alt so macros can be used


mob
	icon = 'mob.dmi'
	invisibleimage = 'invisible.dmi'
	New()
		loc = locate(1,1,1)
		..()

	Stat() 		//All of this is for debugging mainly
		statpanel("[key]")				//client's key
		stat("Location","[x],[y],[z]")	//Current location
		stat("loc",loc)					//Current turf location
		stat("Elevation Level",elevel)	//Elevation they are at
		stat("Mob Layer",layer)			//The layer they are on
		stat("Invisibility",invisibility)		//Invisibility level
		stat("See_Invisibility",see_invisible)	//Invisibility level can be seen

		stat("--Loc Layers--","")	//Everything in the mob's current location
		var/turf/newloc = src.loc
		for(var/t in newloc)
			if(ismob(t)) continue
			stat("----[t]","Level [t:elevel] : Layer [t:layer] : Invis [t:invisibility]")
		stat("----[newloc]","Level [newloc.elevel] : Layer [newloc.layer] : Invis [newloc.invisibility]")

		statpanel("Contents",contents)

	verb
			//This defaults to 1, changing it locks the view to the level
			//  that the mob is currently on
		ToggleLevelInvis()
			set category = null
			SINV = !SINV
			world << "Invisible level is now locked!"

		ToggleInvisibility()
			set category = null
			mInvisible()
			world << "Mob Invisibility has been toggled!"


obj/item	//Defined under obj/item because elevations are a sub type
			//of objects and you don't want to be able to pick them up

	//Demo Get and Drop Verbs, Note the corrisponding proc needs to be called and how it is called
	verb
		Get(mob/m)
			set src in oview(1)
			set category = null
			if(Fl_Get(m)) m.contents += src

		Drop(mob/m)
			set src in usr
			set category = null
			if(Fl_Drop(m)) src.loc = m.loc



//Simple objects to show how objects only effect the layer they are on.
obj
	item 				//objects defined under item can be picked up
		icon = 'item.dmi'
		square
			icon_state = "square"
			density = 1
		circle
			icon_state = "circle"
		box
			icon_state = "box"
			density = 1
	clock				//objects defined under obj can't
		icon = 'item.dmi'
		icon_state = "clock"
		density = 1

//When creating a turf or elevation, you have to set its elevel
//  or else it will default to one. An atom can only move up or
//  down 0.5 of an elevel at a time. So make sure you allow for
//  transitions. This interval can be changed in the
//  Chk_LevelRange() proc.

turf
	icon='turf.dmi'
	grass
		grassLow
			icon_state="grassLow0"
			elevel=1
		grassMed
			icon_state="grassMed0"
			elevel=1.5
		grassHigh
			icon_state="grassHigh0"
			elevel=2
		grassHest
			icon_state="grassHest0"
			elevel=2.5

	wall
		icon_state="wall0"
		density=1
	water
		icon_state="water0"
		density=1
	housewall
		icon_state="housewall"
		density=1


elevation
	icon='elevation.dmi'
	platformLow
		icon_state="platformLow"
		elevel=1
		hide = 0						//With hide set to 0, these will not disapear when we go under them
	platformMedium
		icon_state="platformMed"
		elevel=1.5
		hide = 0
	platformHigh
		icon_state="platformHigh"
		elevel=2
		hide = 0
	platformHighest
		icon_state="platformHest"
		elevel=2.5
		hide = 0
	groundfloor
		icon_state="groundfloor"
		elevel=1
	secondfloor
		icon_state="secondfloor"
		elevel=2
	thirdfloor
		icon_state="thirdfloor"
		elevel=3

	stairs
			//The elevel of the stairs has to be set in the map editor
			//--When setting the elevel, remeber that an atom can only
			//--move to a location with an elevel of +-0.5. So if you
			//--want stairs to go between a level with an elevel of 2 and
			//--a level with a elevel of 3, set the stairs elevel to 2.5

			//The dir of the stairs is the direction of which a mob can
			//--enter it to go up an elevel

			//--EX. A direction of NORTH means that going north on that
			//----turf is only allowed when going from a lower elevel to
			//----a higher one. The inverse is also true: going south is
			//----only allowed when going from a higher elevel to a lower one.
		Nstairs
			icon_state="stairs"
			dir=NORTH