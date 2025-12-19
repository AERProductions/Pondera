turf

	//icon = 'dmi/64/gen.dmi'
	Grass
		icon = 'dmi/64/gen.dmi'
		icon_state = "grass"

		text = "a"
		elevel = 1
	Grass2
		icon = 'dmi/64/gen.dmi'
		icon_state = "grass"
		text = "b"
		buildingowner = ""
	Sand
		icon = 'dmi/64/build.dmi'
		icon_state = "sand"
	//Soil
	//	icon = 'dmi/64/build.dmi'
	//	icon_state = "soil"



	TarPit
		icon = 'dmi/64/gen.dmi'
		icon_state = "tar"
		density = 1
		name = "Tar"
		var/mob/players/M
		DblClick()
			set popup_menu = 1
			M = usr
			if (!(src in range(1, usr))) return
			if (M.Doing==1)
				return
			else
				Fill_(M)
				sleep(2)
		proc
			FindJar(mob/players/M)
				for(var/obj/items/tools/Containers/Jar/J in M.contents)
					locate(J)
					if(J.suffix=="Equipped"&&J.CType=="Empty"&&J.filled==0)
						return J
			Fill_()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				var/mob/players/M
				M = usr

				//set category = "Commands"
				//if(M.JRequipped==1)
				//if(J.CType=="")
				//	J.CType=0
				//if(Fill(M))//Need to switch all of these fills over to the new 'detect container and fill volume' system
					//var/obj/items/tools/Containers/Jar/J = FindJar(M)
				var/obj/items/tools/Containers/Jar/J = FindJar(M)
				var/obj/items/torches/Handtorch/HT = locate() in M
				var/HandTorch=/obj/items/torches/Handtorch
				//var/obj/items/tools/Containers/Vessel/J2 = FindVes(M)
				//if(!J)
					//return
				if(J&&M.JRequipped==1)
					M.Doing = 1
					M<<"You begin filling the Jar with Tar."
					sleep(2)

					J.icon_state = "Jart"
					J.name="Filled Jar"
					J.filled=1
					J.CType="Tar"
					J.volume=25
					sleep(1)
					//usr << "Ctype[J.CType] & Volume [J.volume]"//call(/obj/items/tools/Containers/Jar/proc/descr)(J)
					M<<"You Filled the Jar with Tar."
					M.Doing = 0
					return
				else if(!J&&M.JRequipped==0&&!HT)
					M<<"Need to hold an empty Jar or have a Hand Torch to utilize Tar."
					M.Doing = 0
					return
				else if(!J&&M.JRequipped==0&&HT)
					if(HT.state=="Fueled Torch")
						M << "Torch is already fueled."
						M.Doing = 0
						return
					else
						M<<"You dip the Wooden Torch into the Tar."
						if(istype(HT,HandTorch))
							HT.icon_state="torchfueled"
							if(HT.state=="Empty Torch")
								HT:state="Unlit Torch"
								M.Doing = 0
								return
							if(HT.state=="Unfueled Torch")
								HT:state="Fueled Torch"
								M.Doing = 0
								return
								M<<"You add the fuel to the \  <IMG CLASS=icon SRC=\ref[HT.icon] ICONSTATE='[HT.icon_state]'>[HT.name]."
						M.Doing = 0
						return

		/*
		DblClick()
			set popup_menu = 1
			if (!(src in range(1, usr))) return
			if (Carving==1)
				return
			else
				givetar(M)
				sleep(2)
		proc/givetar(var/turf/TarPit)
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M
			//var/obj/items/Tar/T = new(usr, 1)
			M = usr
			Carving=1
			M << "You Begin collecting some Tar..."
			sleep(9)
			//T += M.contents
			new /obj/items/Tar(M, 1)
			sleep(1)
			Carving=0
			M << "You've collected some Tar"*/
	Sand2
		icon_state = "sandb"
		icon = 'dmi/64/sand.dmi'
		density = 0
		name = "Sand"
		var/mob/players/M//these need lots of work
		DblClick()
			set popup_menu = 1
			M = usr
			if (!(src in range(1, usr))) return
			if (M.Doing==1)
				return
			else
				Fill_(M)
				sleep(2)
		proc
			FindJar(mob/players/M)
				for(var/obj/items/tools/Containers/Jar/J in M.contents)
					locate(J)
					if(J.suffix=="Equipped"&&J.CType=="Empty"&&J.filled==0)
						return J

			Fill_()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				var/mob/players/M
				M = usr

				//set category = "Commands"
				//if(M.JRequipped==1)
				//if(J.CType=="")
				//	J.CType=0
				//if(Fill(M))//Need to switch all of these fills over to the new 'detect container and fill volume' system
					//var/obj/items/tools/Containers/Jar/J = FindJar(M)
				var/obj/items/tools/Containers/Jar/J = locate(M.contents)
				//var/obj/items/tools/Containers/Vessel/J2 = FindVes(M)
				//if(!J)
					//return
				for(J in M.contents)
					if(M.JRequipped==1&&J.filled==0)
						M.Doing = 1
						M<<"You begin filling the Jar with Sand."
						sleep(2)

						J.icon_state = "Jars"
						J.name="Filled Jar"
						J.filled=1
						J.CType="Sand"
						J.volume=25
						sleep(1)
						//usr << "Ctype[J.CType] & Volume [J.volume]"//call(/obj/items/tools/Containers/Jar/proc/descr)(J)
						M<<"You Filled the Jar with Sand."
						M.Doing = 0
						return
					else if(M.JRequipped==0)
						M<<"Need to hold an empty Jar to fill it."
						M.Doing = 0
						return
		/*
		DblClick()

			set popup_menu = 1
			var/mob/players/M
			M = usr
			locate(/obj/items/tools/Containers/Jar) in M.contents
			if (!(src in range(1, usr))) return
			if (M.UED==1)
				return
			else
				if(M.JRequipped==1)
					digsand(M)
					sleep(2)
					return
				else
					M<<"You need to use a Jar to gather sand."
					return
		proc/digsand(var/turf/Sand,amount)
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M
			//var/obj/items/Sand/S = new(usr, 1)
			M = usr
			M.UED=1
			M << "You Begin collecting some Sand in the Jar..."
			sleep(9)
			//S += M.contents
			new /obj/items/Sand(M, 1)
			sleep(1)
			M.UED=0
			M << "You gather some Sand"
			return*/
	ClayDeposit
		icon = 'dmi/64/gen.dmi'
		icon_state = "clay"
		density = 1
		name = "Clay Deposit"
		var/mob/players/M
		DblClick()
			set popup_menu = 1
			if (!(src in range(1, usr))) return
			if (Carving==1)
				return
			else
				giveclay(M)
				sleep(2)
				return
		proc/giveclay(var/turf/ClayDeposit)
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M
			//var/obj/items/Crafting/Created/Clay/C = new(usr, 1)
			M = usr
			Carving=1
			M << "You Begin collecting some Clay..."
			sleep(9)
			//C += M.contents
			new /obj/items/Crafting/Created/Clay(M, 1)
			sleep(1)
			Carving=0
			M << "You've collected some Clay."
			return

	ObsidianField
		icon = 'dmi/64/gen.dmi'
		icon_state = "obsidian"
		density = 1
		name = "Obsidian Field"
		var/mob/players/M
		DblClick()
			set popup_menu = 1
			if (!(src in range(1, usr))) return
			if (Carving==1)
				return
			else
				giveobsidian(M)
				sleep(2)
				//Carving=0
				return
		proc/giveobsidian(var/turf/ObsidianField)
			set waitfor = 0
			set popup_menu = 1
			var/mob/players/M
			//var/obj/items/Obsidian/O = new(usr, 1)
			M = usr
			Carving=1
			M << "You Begin collecting some Obsidian..."
			sleep(9)
			new /obj/items/Obsidian(M, 1)
			sleep(1)
			Carving=0
			M << "You've collected some Obsidian."
			return
	pbords
		var/mob/players/M
		DblClick()
			if (!(src in range(1, usr))) return
			usingmana(M,200)
			sleep(1)
		verb //...
			Cast_Line() //...
				set popup_menu = 1
				set src in oview(1) //...
				//set category = "Commands"
				Fishing(M) //calls the fishing proc
				return
			/*Drink()
				//set category = "Commands"
				set src in oview(1)
				usingmana(src,100)*/
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid //WORKSTAMP needs changed to icon instead of overlay
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
						return
					else
						M<<"Need to hold the Jar to fill it."
						return
					if(J.filled==1)
						M<<"You already filled the Jar."
						return
			/*Hydrate()
				set src in oview(1)
				//set category = "Commands"
				usingmana(M,100)*/

		proc/usingmana(var/turf/Water/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water..."
			sleep(2)
			M.ConsumeFoodItem("fresh water", 0, 300, 0, amount)
			sleep(2)
			return
		pbord1
			name = "pbord1"
			icon = 'dmi/64/pbord1.dmi'
			icon_state = "4"
			density = 1
		pbord2
			name = "pbord2"
			icon = 'dmi/64/pbord1.dmi'
			icon_state = "2"
			density = 1
		pbord3
			name = "pbord3"
			icon = 'dmi/64/pbord1.dmi'
			icon_state = "8"
			density = 1
		pbord4
			name = "pbord4"
			icon = 'dmi/64/pbord1.dmi'
			icon_state = "1"
			density = 1
		pbord5
			name = "pbord5"
			icon = 'dmi/64/pbord2.dmi'
			icon_state = "5"
			density = 1
		pbord6
			name = "pbord6"
			icon = 'dmi/64/pbord2.dmi'
			icon_state = "6"
			density = 1
		pbord7
			name = "pbord7"
			icon = 'dmi/64/pbord2.dmi'
			icon_state = "10"
			density = 1
		pbord8
			name = "pbord8"
			icon = 'dmi/64/pbord2.dmi'
			icon_state = "9"
			density = 1
	Water
		icon = 'dmi/64/gen.dmi'
		icon_state = "water"
		density = 1
		name = "water"
		var/mob/players/M
		//New()
			//..()
		//	soundmob(src, 20, 'snd/creek.ogg', TRUE, 0, 50)
		DblClick()
			set popup_menu = 1
			if (!(src in range(1, usr))) return
			usingmana(M,200)
			sleep(1)
		verb //...
			Fish() //...
				set popup_menu = 1
			//	set src in oview(1) //...
				//set hidden = 1
				//set category = "Commands"
				Fishing(M) //calls the fishing proc might need some checks to prevent double actions
			/*Drink()
				//set category = "Commands"
				set src in oview(1)
				usingmana(src,100)*/
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))//Need to switch all of these fills over to the new 'detect container and fill volume' system
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
					else
						M<<"Need to hold the Jar to fill it."
					if(J.filled==1)
						M<<"You already filled the Jar."
						return 0
			/*Hydrate()
				set src in oview(1)
				//set category = "Commands"
				usingmana(M,100)*/

		proc/usingmana(var/turf/Water/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water..."
			sleep(2)
			M.stamina += amount
			M.updateST()
			M.hydrated=1
			sleep(2)
			M << "Ahh, Refreshing. <b>[amount] stamina recovered."
	OasisWater
		icon = 'dmi/64/gen.dmi'
		icon_state = "water"
		density = 1
		name = "Oasis Water"
		var/mob/players/M
		DblClick()
			if (!(src in range(1, usr))) return
			usingmana(M,100)
			sleep(1)
		verb //...
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
					else
						M<<"Need to hold the Jar to fill it."
					if(J.filled==1)
						M<<"You already filled the Jar."
						return 0
		proc/usingmana(var/turf/OasisWater/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water from the Oasis..."
			sleep(2)
			M.ConsumeFoodItem("oasis water", 0, 300, 0, amount)
			sleep(2)
	OasisWaterc1
		icon = 'dmi/64/gen.dmi'
		icon_state = "waterc1"
		density = 1
		name = "oasiswaterc1"
		var/mob/players/M
		DblClick()
			if (!(src in range(1, usr))) return
			usingmana(M,100)
			sleep(1)
		verb //...
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
					else
						M<<"Need to hold the Jar to fill it."
					if(J.filled==1)
						M<<"You already filled the Jar."
						return 0
		proc/usingmana(var/turf/OasisWaterc1/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water from the Oasis..."
			sleep(2)
			M.ConsumeFoodItem("oasis water", 0, 300, 0, 100)
			sleep(2)
	OasisWaterc2
		icon = 'dmi/64/gen.dmi'
		icon_state = "waterc2"
		density = 1
		name = "oasiswaterc2"
		var/mob/players/M
		DblClick()
			if (!(src in range(1, usr))) return
			usingmana(M,100)
			sleep(1)
		verb //...
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
					else
						M<<"Need to hold the Jar to fill it."
					if(J.filled==1)
						M<<"You already filled the Jar."
						return 0
		proc/usingmana(var/turf/OasisWaterc2/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water from the Oasis..."
			sleep(2)
			M.ConsumeFoodItem("oasis water", 0, 300, 0, 100)
			sleep(2)
	OasisWaterc3
		icon = 'dmi/64/gen.dmi'
		icon_state = "waterc3"
		density = 1
		name = "oasiswaterc3"
		var/mob/players/M
		DblClick()
			if (!(src in range(1, usr))) return
			usingmana(M,100)
			sleep(1)
		verb //...
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
					else
						M<<"Need to hold the Jar to fill it."
					if(J.filled==1)
						M<<"You already filled the Jar."
						return 0
		proc/usingmana(var/turf/OasisWaterc3/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water from the Oasis..."
			sleep(2)
			M.ConsumeFoodItem("oasis water", 0, 300, 0, 100)
			sleep(2)
	OasisWaterc4
		icon = 'dmi/64/gen.dmi'
		icon_state = "waterc4"
		density = 1
		name = "oasiswaterc4"
		var/mob/players/M
		DblClick()
			if (!(src in range(1, usr))) return
			usingmana(M,100)
			sleep(1)
		verb //...
			Fill_Jar()
				set waitfor = 0
				set popup_menu = 1
				set src in oview(1)
				//set category = "Commands"
				if(Fill(M))
					var/obj/items/tools/Containers/Jar/J = locate() in M.contents
					if(M.JRequipped==1)
						M<<"You begin filling the Jar."
						sleep(2)
						J.overlays += /obj/liquid
						J.filled=1
						sleep(1)
						M<<"You Filled the Jar."
					else
						M<<"Need to hold the Jar to fill it."
					if(J.filled==1)
						M<<"You already filled the Jar."
						return 0
		proc/usingmana(var/turf/OasisWaterc4/J,amount)
			set waitfor = 0
			var/mob/players/M
			M = usr
			if (amount > (M.MAXstamina-M.stamina))
				amount = (M.MAXstamina-M.stamina)
			usr << "You Begin drinking the Water from the Oasis..."
			sleep(2)
			M.ConsumeFoodItem("oasis water", 0, 300, 0, 100)
			sleep(2)
	JungleWat
		icon = 'dmi/64/gen.dmi'
		JungleWater
			icon_state = "waterj"
			density = 1
			name = "junglewater"
			var/mob/players/M
			DblClick()
				if (!(src in range(1, usr))) return
				usingmana(M,40)
				sleep(1)
			verb //...
				Fill_Jar()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set category = "Commands"
					if(Fill(M))
						var/obj/items/tools/Containers/Jar/J = locate() in M.contents
						if(M.JRequipped==1)
							M<<"You begin filling the Jar."
							sleep(2)
							J.overlays += /obj/liquid
							J.filled=1
							sleep(1)
							M<<"You Filled the Jar."
						else
							M<<"Need to hold the Jar to fill it."
						if(J.filled==1)
							M<<"You already filled the Jar."
							return 0
			proc/usingmana(var/turf/JungleWater/J,amount)
				set waitfor = 0
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				usr << "You Begin drinking Water from the Jungle..."
				sleep(2)
				M.ConsumeFoodItem("jungle water", 0, 250, 0, amount)
				sleep(2)
		JungleWaterc1
			icon_state = "waterjc1"
			density = 1
			name = "junglewaterc1"
			var/mob/players/M
			DblClick()
				if (!(src in range(1, usr))) return
				usingmana(M,40)
				sleep(1)
			verb //...
				Fill_Jar()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set category = "Commands"
					if(Fill(M))
						var/obj/items/tools/Containers/Jar/J = locate() in M.contents
						if(M.JRequipped==1)
							M<<"You begin filling the Jar."
							sleep(2)
							J.overlays += /obj/liquid
							J.filled=1
							sleep(1)
							M<<"You Filled the Jar."
						else
							M<<"Need to hold the Jar to fill it."
						if(J.filled==1)
							M<<"You already filled the Jar."
							return 0
			proc/usingmana(var/turf/JungleWaterc1/J,amount)
				set waitfor = 0
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				usr << "You Begin drinking Water from the Jungle..."
				sleep(2)
				M.ConsumeFoodItem("jungle water", 0, 250, 0, amount)
				sleep(2)
		JungleWaterc2
			icon_state = "waterjc2"
			density = 1
			name = "junglewaterc2"
			var/mob/players/M
			DblClick()
				if (!(src in range(1, usr))) return
				usingmana(M,40)
				sleep(1)
			verb //...
				Fill_Jar()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set category = "Commands"
					if(Fill(M))
						var/obj/items/tools/Containers/Jar/J = locate() in M.contents
						if(M.JRequipped==1)
							M<<"You begin filling the Jar."
							sleep(2)
							J.overlays += /obj/liquid
							J.filled=1
							sleep(1)
							M<<"You Filled the Jar."
						else
							M<<"Need to hold the Jar to fill it."
						if(J.filled==1)
							M<<"You already filled the Jar."
							return 0
			proc/usingmana(var/turf/JungleWaterc2/J,amount)
				set waitfor = 0
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				usr << "You Begin drinking Water from the Jungle..."
				sleep(2)
				M.ConsumeFoodItem("jungle water", 0, 250, 0, amount)
				sleep(2)
		JungleWaterc3
			icon_state = "waterjc3"
			density = 1
			name = "junglewaterc3"
			var/mob/players/M
			DblClick()
				if (!(src in range(1, usr))) return
				usingmana(M,40)
				sleep(1)
			verb //...
				Fill_Jar()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set category = "Commands"
					if(Fill(M))
						var/obj/items/tools/Containers/Jar/J = locate() in M.contents
						if(M.JRequipped==1)
							M<<"You begin filling the Jar."
							sleep(2)
							J.overlays += /obj/liquid
							J.filled=1
							sleep(1)
							M<<"You Filled the Jar."
						else
							M<<"Need to hold the Jar to fill it."
						if(J.filled==1)
							M<<"You already filled the Jar."
							return 0
			proc/usingmana(var/turf/JungleWaterc3/J,amount)
				set waitfor = 0
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				usr << "You Begin drinking Water from the Jungle..."
				sleep(2)
				M.ConsumeFoodItem("jungle water", 0, 250, 0, amount)
				sleep(2)
		JungleWaterc4
			icon_state = "waterjc4"
			density = 1
			name = "junglewaterc4"
			var/mob/players/M
			DblClick()
				if (!(src in range(1, usr))) return
				usingmana(M,40)
				sleep(1)
			verb //...
				Fill_Jar()
					set waitfor = 0
					set popup_menu = 1
					set src in oview(1)
					//set category = "Commands"
					if(Fill(M))
						var/obj/items/tools/Containers/Jar/J = locate() in M.contents
						if(M.JRequipped==1)
							M<<"You begin filling the Jar."
							sleep(2)
							J.overlays += /obj/liquid
							J.filled=1
							sleep(1)
							M<<"You Filled the Jar."
						else
							M<<"Need to hold the Jar to fill it."
						if(J.filled==1)
							M<<"You already filled the Jar."
							return 0
			proc/usingmana(var/turf/JungleWaterc4/J,amount)
				set waitfor = 0
				var/mob/players/M
				M = usr
				if (amount > (M.MAXstamina-M.stamina))
					amount = (M.MAXstamina-M.stamina)
				usr << "You Begin drinking Water from the Jungle..."
				sleep(2)
				M.ConsumeFoodItem("jungle water", 0, 250, 0, amount)
				sleep(2)
obj
	//icon = 'dmi/64/gen.dmi'
	liquid
		icon = 'dmi/64/creation.dmi'
		icon_state = "liquid"
		layer = 10
	liquidt
		icon = 'dmi/64/creation.dmi'
		icon_state = "liquidt"
		layer = 10
	liquido
		icon = 'dmi/64/creation.dmi'
		icon_state = "liquido"
		layer = 10
	vliquid
		icon = 'dmi/64/creation.dmi'//vessel
		icon_state = "vliquid"
		layer = 10
	vliquidt
		icon = 'dmi/64/creation.dmi'//vessel
		icon_state = "vliquidt"
		layer = 10
	vliquido
		icon = 'dmi/64/creation.dmi'//vessel
		icon_state = "vliquido"
		layer = 10
	vliquidHF
		icon = 'dmi/64/creation.dmi'//vessel
		icon_state = "vliquidHF"
		layer = 10
	vliquidHFt
		icon = 'dmi/64/creation.dmi'//vessel
		icon_state = "vliquidHFt"
		layer = 10
	vliquidHFo
		icon = 'dmi/64/creation.dmi'//vessel
		icon_state = "vliquidHFo"
		layer = 10
	bliquid
		icon = 'dmi/64/creation.dmi'//barrel
		icon_state = "bliquidw"
		layer = 10
	bliquidt
		icon = 'dmi/64/creation.dmi'//barrel
		icon_state = "bliquidt"
		layer = 10
	bliquido
		icon = 'dmi/64/creation.dmi'//barrel
		icon_state = "bliquido"
		layer = 10
	qbliquid
		icon = 'dmi/64/creation.dmi'//barrel
		icon_state = "qbliquid"
		layer = 10
	qbliquidt
		icon = 'dmi/64/creation.dmi'//barrel
		icon_state = "qbliquidt"
		layer = 10
	qbliquido
		icon = 'dmi/64/creation.dmi'//barrel
		icon_state = "qbliquido"
		layer = 10

		//plane = 10

	seed
		icon = 'dmi/64/blank.dmi'
		var/list/Spots = list(1)
	Flowers
		//density = 0
		var/searched = 0
		var/brk=0
		mouse_opacity = 1
		layer = 8
		Click()
			set popup_menu = 1
			set src in oview(1)
			var/mob/players/M = usr
			if (!(src in range(1, usr))) return
			if(M.SHequipped==1)
				M<<"You dig up the plot."
				del src
				return
			Searching(M)
			//sleep(1)
			return
		proc
			searched()
				if(src.searched==1&&brk==0)
					brk = 1
					sleep(360)
					src.searched=0
					brk = 0
					return
		verb //...
			Weed()
				set category=null
				set popup_menu = 1
				set src in oview(1) //...
				////set category = "Commands"
				var/mob/players/M = usr
				Weed1(M)
			Search() //finally working
				set category=null
				set popup_menu = 1
				set src in oview(1) //...
				////set category = "Commands"
				var/mob/players/M = usr
				//usr << "Test"
				Searching(M) //calls the fishing proc
		icon = 'dmi/64/plants.dmi'
		Redflower
			name = "Red Flowers"
			icon_state = "rf"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//mouse_opacity = 1
			//layer = 10
			//plane = 2
			/*Click()//works
				set popup_menu = 1
				set src in oview(1)
				var/mob/players/M = usr
				M << "Test"
				if (!(src in range(1, usr))) return
				//else
				Searching(M)
				//sleep(1)
				return*/
		Blueflower
			name = "Blue Flowers"
			icon_state = "bf"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Pinkflower
			name = "Pink Flowers"
			icon_state = "pnkf"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Purpflower
			name = "Purple Flowers"
			icon_state = "pf"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Lightpurpflower
			name = "Lavender Flowers"
			icon_state = "lpf"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Tallgrass0
			name = "Sprouts"
			icon_state = "tg0"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Tallgrass
			name = "Tallgrass"
			icon_state = "tg"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Tallgrass1
			name = "Tallgrass"
			icon_state = "tg1"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Tallgrass2
			name = "Tallgrass"
			icon_state = "tg2"
			icon = 'dmi/64/plants.dmi'
			density = 0
			//layer = 10
			//plane = 2
		Tallgrass3
			name = "Tallgrass"
			icon = 'dmi/64/plants.dmi'
			icon_state = "tg3"
			density = 0
			//layer = 10
			//plane = 2
		Tallgrass4
			name = "Dormant plants"
			icon = 'dmi/64/plants.dmi'
			icon_state = "tg4"
			density = 0
			//layer = 10
			//plane = 2

mob
	insects
		PLRButterfly
			icon_state = "btf"
			icon = 'dmi/64/plants.dmi'
			//plane = 4
			layer = 10
			var/Speed = 20
			var/HP = 30
			New()
				.=..()
				src.color = rgb(rand(100,200),rand(100,200),rand(100,200))
				spawn(1)
					Wander(Speed)

	proc/Wander(Speed)
		set waitfor = 0
		while(src)     //while its still there, and not deleted..
			//if (P in oview(5))    //If a PC is in 5 spaces of it...
				//step_towards(src,P)   //Step towards the PC
			//else
			sleep(Speed)
			step_rand(src)   //step random
				//for(P in view(src))  //but if a PC comes nearby...
				//	break     //stop walking random
			//sleep(speed)
		spawn(60)   //Keep the infinit loop in action, and tell it to wait for 4 seconds
			Wander(Speed)
/*mob/players
	verb/Teleport()
		usr << "current loc [usr.loc]"
		usr.loc=locate(17,9,1)
		//usr.loc=locate(/obj/accesspoint) //olddebugtool
		*/
			//****READ THIS \/****
			//this code generates a new map and automatically places objects, but needs object checking to prevent multiple object placement on same tile
/*
obj
	New()
		..()
		for(var/obj/o in loc)
			if(o == src) continue
			if(istype(o, src.type))
				del src
var list/turfs = new
turf/New(){turfs+=src;..()}
proc/GenerateTurfs()
	for(var/turf/t in turfs)
		switch(rand(1,rand(1,10)))
			if(1){new/obj/plant/ueiktree(t.loc)}
			if(2){new/obj/Rocks/IRocks(t.loc)}
			if(3){new/obj/Plants/Raspberrybush(t.loc)}*/
/*
mob/players/verb/savemap()
	var/map_name = "test3"
	//var/wscount = 1
	//var/shading = /obj/shading/shading
	/*
		The save() verb saves a map with name "[map_name].dmm".
		*/
	//if((ckey(map_name) != lowertext(map_name)) || (!ckey(map_name)))
	//	usr << "The file name you supplied includes invalid characters, or is empty. Please supply a valid file name."
	//	return
	var/dmm_suite/D = new()
	var/turf/south_west_deep = locate(1,1,1)
	var/turf/north_east_shallow = locate(100,100,1)
	world << {"Initiating world save."}
	//var/shading/s = locate()     //need to make it so shading does not get saved
	//if(istype(s, /shading))
		//for(s)
			//del s
		//return
	//var/list/light_objects = list()
	//for((x to world.maxx)&&(y to world.maxy))
	//	for(s)
	//		del s

	//D.save_map(south_west_deep, north_east_shallow, map_name, flags = DMM_IGNORE_PLAYERS)
	//var/turf/T = locate(WTOSL)
	//var/obj/O = locate(WTOSL)
	//if(T&&O in WTOSL)
	D.save_map(south_west_deep, north_east_shallow, map_name, flags = DMM_IGNORE_AREAS&&DMM_IGNORE_MOBS&&DMM_IGNORE_NPCS&&DMM_IGNORE_PLAYERS)
		world << {"World has been saved."}
*/

// === END OF FILE ===
// Legacy generator code archived and removed (see version control)
// This file contains foundational turf/area definitions and is no longer actively used for generation
// Modern map generation is handled by mapgen/backend.dm and ProceduralChunkingSystem.dm
