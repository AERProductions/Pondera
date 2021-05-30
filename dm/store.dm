obj/
	/*satchel
		icon = 'dmi/64/inven.dmi'
		icon_state = "satchel"
		stt_container = 1
	Click(location)
		// if clinked in the Inventory panel, and this obj is a container
		if((location == "Inventory") && stt_container)
			stt_open = !stt_open
	MouseDrop(target,start,end)
			/* if it was dragged from the inventory panel to
					another part of the inventory panel */
		if((start == "Inventory") && (end == "Inventory"))
			if(isobj(target))
				var/obj/O = target      // obj alias to target
				if(O.stt_container)
					Move(target)
					return
			Move(usr)
	ContainerI
		icon = 'dmi/64/tChest.dmi'
		//icon_state = "Box"
		name = "Box"
		var/owner2 = "" // The current owner of the storage
		verb
			Debug() //delete this verb in game, its for debug purposes
				set src in oview(1)
				src.owner2 = usr.key // Person becomes the owner
				usr<<"You are now Box Owner"


			Store(var/obj/items/obj in usr) //You can remove /Tool to make it select from all items
				set src in view(1)
				if(owner2 == usr.key) //If the person is the owner
					if (obj.items == 1) // if the item is a tool
						src.contents += obj // store the item
						usr<<"You put [obj] in the Box."
					else
						usr << "Only Items can be placed in here."
				else
					usr<<"Box does not belong to you."
			Retrieve(var/obj/obj in src)
				set src in view(1)
				if(owner2 == usr.key)
					usr.contents += obj // Retreive the selected item
					usr<<"You take [obj] from the Box."
				else
					usr<<"Box does not belong to you."
*/
	Buildable
		Containers
			ContainerF   /////// The fridge is pretty much same as tool box, all you need to do is change tool to food
				icon = 'dmi/64/tChest.dmi'
				//icon_state = "Fridge"
				name = "Container"
				var/owner2 = ""
				density = 1
				verb
					Debug() //delete this verb in game, its for debug purposes
						set src in oview(1)
						src.owner2 = usr.key
						usr<<"You are now the Container Owner"

					Store(var/obj/items/Food/obj in usr) //You can remove /Food to make it select from all items
						set src in view(1)
						if(owner2 == usr.key)
							if (obj.food == 1)
								src.contents += obj
								usr<<"You put [obj] in the Container."
							else
								usr << "Only food can be placed in here."
						else
							usr<<"Container does not belong to you."
					Retrieve(var/obj/obj in src)
						set src in view(1)
						if(owner2 == usr.key)
							usr.contents += obj
							usr<<"You take [obj] from the Fridge."
						else
							usr<<"Container does not belong to you."
			ContainerL   /////// The fridge is pretty much same as tool box, all you need to do is change tool to food
				icon = 'dmi/64/tChest.dmi'
				//icon_state = "Fridge"
				name = "Storage"
				density = 1
				var/owner2 = ""
				verb
					Debug() //delete this verb in game, its for debug purposes
						set src in oview(1)
						src.owner2 = usr.key
						usr<<"You are now the Storage Owner"

					Store(var/obj/items/Logs/obj in usr) //You can remove /Food to make it select from all items
						set src in view(1)
						if(owner2 == usr.key)
							if (obj.logs == 1)
								src.contents += obj
								usr<<"You put [obj] in the Storage."
							else
								usr << "Only Logs can be placed here."
						else
							usr<<"Storage does not belong to you."
					Retrieve(var/obj/obj in src)
						set src in view(1)
						if(owner2 == usr.key)
							usr.contents += obj
							usr<<"You take [obj] from the Storage."
						else
							usr<<"Storage does not belong to you."
			ContainerO   /////// The fridge is pretty much same as tool box, all you need to do is change tool to food
				icon = 'dmi/64/tChest.dmi'
				//icon_state = "Fridge"
				name = "Chest"
				density = 1
				var/owner2 = ""
				verb
					Debug() //delete this verb in game, its for debug purposes
						set src in oview(1)
						src.owner2 = usr.key
						usr<<"You are now the Chest Owner"

					Store(var/obj/items/Ore/obj in usr) //You can remove /Food to make it select from all items
						set src in view(1)
						if(owner2 == usr.key)
							if (obj.ore == 1)
								src.contents += obj
								usr<<"You put [obj] in the Chest."
							else
								usr << "Only Ore can be placed in here."
						else
							usr<<"Chest does not belong to you."
					Retrieve(var/obj/obj in src)
						set src in view(1)
						if(owner2 == usr.key)
							usr.contents += obj
							usr<<"You take [obj] from the Chest."
						else
							usr<<"Chest does not belong to you."

obj
	var
		items = 0
		food = 0
		logs = 0
		ore = 0
		stt_container = 0       // set this to make an obj a container
		stt_open = 0    // flagged if a container is open