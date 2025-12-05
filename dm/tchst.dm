obj/wchest1//treasure chest
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/weapons/unutanto, /obj/items/weapons/unuestoc,/obj/items/weapons/unumarubo,/obj/items/armors/unutunic,/obj/items/armors/avgcuirass,/obj/items/Tonics/antitoxin,/obj/items/Tonics/vitaevial,/obj/items/shields/avgbast,/obj/items/ancscrlls/vitae) //define what chests contain by default
	
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		open_chest(usr)

	proc/open_chest(mob/user)
		if(!src.contents.len) //if there is no items in the chest
			user << "The chest is empty..."
			return
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			getR(M)
			if(M.Move(user)) //attempt to move the object into the player
				user << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else user << "There is \a [M] in the chest, but you can't pick it up..."

	proc/getR()
		return pick(contents)

/*
obj/wchest2
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/weapons/unuestoc) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."



obj/wchest3
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/weapons/unumarubo) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."


obj/wchest4
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/weapons/unubrand) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."


obj/achest1
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/armors/unutunic) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."
obj/achest2
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/armors/avgcuirass) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."


obj/ichest1
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/antitoxin) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."


obj/ichest2
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/vitaevial) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."



obj/schest2
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/shields/avgbast) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."



obj/aschest2
	icon = 'dmi/64/tChest.dmi'
	density = 1
	contents = newlist(/obj/items/ancscrlls/vitae) //define what chests contain by default
	Click()
		set src in oview(1) //only accessible when within 1 tile of the chest
		if(!src.contents.len) //if there is no items in the chest
			usr << "The chest is empty..."
			return //stop the verb
		for(var/atom/movable/M in src.contents) //loop threw every obj or mob in the chest
			if(M.Move(usr)) //attempt to move the object into the player
				usr << "You get \a [M] from the chest!"
				src.icon_state = "open"
			else usr << "There is \a [M] in the chest, but you can't pick it up..."*/