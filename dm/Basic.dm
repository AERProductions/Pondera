client
	perspective = EDGE_PERSPECTIVE
world
	fps = 25		// 25 frames per second
	icon_size = 64
	view = 8

mob
	players
		icon = 'char.dmi'
		step_size = 8
		density = 1
		Feline
			char_class = "Feline"
			icon_state = "Kitty"
		Landscaper
			char_class = "Landscaper"
			icon_state = "friar"
		Builder
			char_class = "Builder"
			icon_state = "theurgist"
		Defender
			char_class = "Defender"
			icon_state = "fighter"
		Magus
			char_class = "Magus"
			icon_state = "magus"
		GameMaster
			char_class = "GM"
			icon_state = "Kitty"
	Login()
		icon = 'char.dmi'
		icon_state = "friar"




/////////////////////////////////////////SAVE FILE/////////////////////////////////////////////////////////

client
	var
		save_dir

	New()
		..()
		src.Move(locate(1, 1, 1))
		src.save_dir = "Savefiles/Players/[src.key].sav"
		if(!src.loading())
			src.buildBag()
			src.buildStorage()

	proc
		saving()
			var/savefile/s = new(src.save_dir)
			s["mob"] << src.mob

		loading()
			if(fexists(src.save_dir))
				var/savefile/s = new(src.save_dir)
				var/mob/m = src.mob
				s["mob"] >> src.mob
				del m
				return 1
			return 0

	verb
		saveNow()
			src.saving()

mob
	Read(var/savefile/s)
		..()
		if(src.client)
			src.client.loadBagSlots()
			src.client.loadStorageSlots()
		src.Move(locate(s["last_x"], s["last_y"], s["last_z"]))

	Write(var/savefile/s)
		src.removeAllBagLays() //Don't want to save any overlays/underlays
		..()
		src.refreshAllBagSlots() //Re-add the overlays/underlays after saving
		s["last_x"] << src.x
		s["last_y"] << src.y
		s["last_z"] << src.z