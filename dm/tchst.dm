/**
 * Generic treasure chest base type
 * Provides Click() and E-key (UseObject) interaction for opening/looting
 * 
 * Child types should define `contents` list with items to spawn
 */
obj/chest
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = list()  // Override in child types
	
	Click()
		set src in oview(1)
		open_chest(usr)
	
	UseObject(mob/user)
		open_chest(user)
		return 1
	
	proc/open_chest(mob/user)
		if(!src.contents.len)
			user << "The chest is empty..."
			return
		for(var/atom/movable/M in src.contents)
			if(M.Move(user))
				user << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else 
				user << "There is \a [M] in the chest, but you can't pick it up..."

obj/chest/wchest1
	contents = newlist(/obj/items/weapons/unutanto, /obj/items/weapons/unuestoc,/obj/items/weapons/unumarubo,/obj/items/armors/unutunic,/obj/items/armors/avgcuirass,/obj/items/Tonics/antitoxin,/obj/items/Tonics/vitaevial,/obj/items/shields/avgbast,/obj/items/ancscrlls/vitae)

obj/chest/achest1
	contents = newlist(/obj/items/armors/unutunic)

obj/chest/achest2
	contents = newlist(/obj/items/armors/avgcuirass)

obj/chest/ichest1
	contents = newlist(/obj/items/Tonics/antitoxin)

obj/chest/ichest2
	contents = newlist(/obj/items/Tonics/vitaevial)

obj/chest/schest2
	contents = newlist(/obj/items/shields/avgbast)

obj/chest/aschest2
	contents = newlist(/obj/items/ancscrlls/vitae)

// Legacy code and old implementations removed
