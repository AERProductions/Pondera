var/list
	sounds = list()

world/New()
	..()
	sounds += new/sound()

mob
	Login()
		..()
		refresh()

	verb
		new_sound()
			var/sound/S = new()
			sounds+=S
			S.st_Display(src)

		refresh()
			for(var/sound/S in sounds)
				S.st_Display(src)
