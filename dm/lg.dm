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
		//usr << wscount+1
		//sleep(wscount)
	world << {"World has been saved."}*/

var/obj/o
var/turf/Water/w
var/list/ol[]
var/list/W[]
/*
mob/players
	verb/MyGenerator()
		//var/random/R = new()
		set background = 1
		world<<"Initializing Turf Seeding."


		for(var/turf/Grass/T) //Loop through all turfs in the world.
			if(prob(3)) //10% Chance of creating a seed on that turf.

				new/obj/seed(T)
		for(var/obj/seed/seed1)
			for(var/obj/seed/seed2)
				if(seed1.loc != seed2.loc)
					seed1.Spots += get_dist(seed2,seed1)

		world<<"Initializing Land Vegetation."

		for(var/obj/seed/S)
			for(var/obj/seed/D)
				if(get_dist(S,D) == max(D.Spots)||get_dist(D,S) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/Grass/T in oview(1,S))
						if(get_dist(S,D) == get_dist(T,S))
							new/obj/plant/ueiktree(T)
		*/
		/*
		world<<"Initializing Resources."


		for(var/turf/Grass/G)

			//Ponds
			//if(prob(15) && !(locate(/obj/plant/ueiktree) in range(3, G)) )
			/*if(prob(10) && !(locate(/obj/Plants/Bush/Raspberrybush)	in range(1, G)) && \
				!(locate(/obj/Plants/Bush/Blueberrybush)	in G) && \
				!(locate(/obj/Flowers/Blueflower)	in G) && \
				!(locate(/obj/Flowers/Lightpurpflower)	in G) && \
				!(locate(/obj/Flowers/Pinkflower)	in G) && \
				!(locate(/obj/Flowers/Purpflower)	in G) && \
				!(locate(/obj/Flowers/Redflower)	in G) && \
				!(locate(/obj/Flowers/Tallgrass)	in G) && \
				!(locate(/obj/Rocks/IRocks)	in G) && \
				!(locate(/obj/Rocks/ZRocks)	in G) && \
				!(locate(/obj/Rocks/CRocks)	in G) && \
				!(locate(/obj/Rocks/LRocks)	in G) && \
				!(locate(/obj/Rocks/SRocks)	in G) && \
				!(locate(/turf/TarPit)	in G) && \
				!(locate(/turf/ClayDeposit)	in G) && \
				!(locate(/turf/ObsidianField)	in G) && \
				!(locate(/turf/Sand2)	in G) && \
				!(locate(/obj/Soil/richsoil)	in G) && \
				!(locate(/obj/Soil/soil)	in G) && \
				!(locate(/obj/plant/ueiktree)	in G))
				if(prob(5))
					new/turf/Water(G)

					for(var/turf/t in oview(1, G))
						if(prob(1)) continue
						if(!(locate(/obj/Rocks/SRocks)	in t) &&!(locate(/obj/Rocks/LRocks)	in t) &&!(locate(/obj/Rocks/CRocks)	in t) &&!(locate(/obj/Rocks/ZRocks)	in t) &&!(locate(/obj/Rocks/IRocks)	in t) &&!(locate(/obj/Flowers/Tallgrass)	in t) &&!(locate(/obj/Flowers/Redflower)	in t) &&!(locate(/obj/Flowers/Purpflower)	in t) &&!(locate(/obj/Flowers/Pinkflower)	in t) &&!(locate(/obj/Flowers/Lightpurpflower)	in G) &&!(locate(/obj/Plants/Bush/Raspberrybush)	in t) && !(locate(/obj/Flowers/Blueflower) in t) && !(locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t))
							new/turf/Water(t)*/
			// Rocks
			if(prob(0.3))
				new/obj/Rocks/IRocks(G)
			else if(prob(0.1))
				new/obj/Rocks/ZRocks(G)
			else if(prob(0.1))
				new/obj/Rocks/CRocks(G)
			else if(prob(0.1))
				new/obj/Rocks/LRocks(G)
			else if(prob(0.2))
				new/obj/Rocks/SRocks(G)

			// Spawnpoints
			if(prob(0.01))
				new/obj/spawns/spawnpointB2(G)

			// Bushes
			if(prob(0.3))
				new/obj/Plants/Bush/Raspberrybush(G)
			else if(prob(0.3))
				new/obj/Plants/Bush/Blueberrybush(G)

			// Trees
			if(prob(2.02))
				if(	!(locate(/obj/plant/UeikTreeA)	in G) && \
					!(locate(/obj/plant/UeikTreeH)	in G) && \
					!(locate(/obj/plant/ueiktree)	in G))

					if(prob(50))
						new/obj/plant/UeikTreeA(G)
					else
						new/obj/plant/UeikTreeH(G)

			else if(prob(15) && !(locate(/obj/plant/ueiktree) in range(3, G)) )
				new/obj/plant/ueiktree(G)

				for(var/turf/t in oview(1, G))
					if(prob(80)) continue
					if(! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t))
						new/obj/plant/ueiktree(t)


			// Flowers
			if(prob(0.5))
				new/obj/Flowers/Blueflower(G)
			else if(prob(0.5))
				new/obj/Flowers/Lightpurpflower(G)
			else if(prob(0.5))
				new/obj/Flowers/Pinkflower(G)
			else if(prob(0.5))
				new/obj/Flowers/Purpflower(G)
			else if(prob(0.7))
				new/obj/Flowers/Redflower(G)
			else if(prob(1.0))
				new/obj/Flowers/Tallgrass(G)

			// Deposits
			if(prob(0.05))
				new/turf/TarPit(G)
			else if(prob(0.03))
				new/turf/ClayDeposit(G)
			else if(prob(0.02))
				new/turf/ObsidianField(G)
			else if(prob(0.02))
				new/turf/Sand2(G)
			else if(prob(0.03))
				new/obj/Soil/richsoil(G)
			else if(prob(0.04))
				new/obj/Soil/soil(G)

		//for(locate(o in bounds(W)))

			//W = W.contents
			//ol = new()

			//for(locate(istype(o)) in range(10,W))
			//for(o)
				//ol.Add("[o]")
				/*(locate(/obj/Plants/Bush/Blueberrybush)	in view(8, W)) && \
				(locate(/obj/Flowers/Blueflower)	in view(8, W)) && \
				(locate(/obj/Flowers/Lightpurpflower)	in view(8, W)) && \
				(locate(/obj/Flowers/Pinkflower)	in view(8, W)) && \
				(locate(/obj/Flowers/Purpflower)	in view(8, W)) && \
				(locate(/obj/Flowers/Redflower)	in view(8, W)) && \
				(locate(/obj/Flowers/Tallgrass)	in view(8, W)) && \
				(locate(/obj/Rocks/IRocks)	in view(8, W)) && \
				(locate(/obj/Rocks/ZRocks)	in view(8, W)) && \
				(locate(/obj/Rocks/CRocks)	in view(8, W)) && \
				(locate(/obj/Rocks/LRocks)	in view(8, W)) && \
				(locate(/obj/Rocks/SRocks)	in view(8, W)) && \
				(locate(/turf/TarPit)	in view(8, W)) && \
				(locate(/turf/ClayDeposit)	in view(8, W)) && \
				(locate(/turf/ObsidianField)	in view(8, W)) && \
				(locate(/turf/Sand2)	in view(8, W)) && \
				(locate(/obj/Soil/richsoil)	in view(8, W)) && \
				(locate(/obj/Soil/soil)	in view(8, W)) && \
				(locate(/obj/plant/ueiktree)	in view(8, W)))*/
			//del(o)
				//del(ol)
		world<<"Map Creation Complete"
		return*/

//generates ponds with shorelines -- needs fixed.
		/*world<<"Initializing Land Adjustments."
		for(var/turf/Water/W)
			var/A=0
			var/B=0
			//Fixing Choppy look.
			for(var/turf/Grass/a in oview(3,W))
				if(locate(a.x,a.y,a.z)==locate(W.x-1,W.y,W.z)||locate(a.x,a.y,a.z)==locate(W.x+1,W.y,W.z))
					A++
				if(locate(a.x,a.y,a.z)==locate(W.x,W.y+1,W.z)||locate(a.x,a.y,a.z)==locate(W.x,W.y-1,W.z))
					B++
			if(A == 1)
				new/turf/Grass(W)
			if(B == 50)
				new/turf/Grass(W)
		//world<<"Initializing Land Trimming."
		//for(var/turf/Grass/a in world)
			//for(var/turf/Water/W in view(1,a))
				//W.overlays += image('dmi/64/gen.dmi',icon_state="[get_dir(a,W)]") //Adds border to water.
				for(W)
					var/C=0
					var/D=0
					//Fixing Choppy look.
					for(var/turf/Grass2/b in oview(700,W))
						if(locate(b.x,b.y,b.z)==locate(W.x-1,W.y,W.z)||locate(b.x,b.y,b.z)==locate(W.x+1,W.y,W.z))
							C++
						if(locate(b.x,b.y,b.z)==locate(W.x,W.y+1,W.z)||locate(b.x,b.y,b.z)==locate(W.x,W.y-1,W.z))
							D++
					if(C == 50)
						new/turf/Grass(W)
					if(D == 50)
						new/turf/Grass(W)
				for(var/turf/Grass2/b in world)
					for(W in view(1,b))
						W.overlays += image('dmi/64/gen.dmi',icon_state="[get_dir(b,W)]") //Adds border to grass.
				*/


/*
mob/players
	verb/MyGenerator()
		//var/random/R = new()
		set background = 1
		world<<"Initializing Turf Seeding."
		for(var/turf/Grass/T) //Loop through all turfs in the world.
			if(prob(3)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1)
			for(var/obj/seed/seed2)
				if(seed1.loc != seed2.loc)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		/*world<<"Initializing Land Creation."
		for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/caves/caveflr1/T in view(15,S))
						if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
							new/turf/lava(T)*///Create a Grass turf.
					//for(var/turf/T in view(50,D))
						//if(get_dist(D,S) == get_dist(D,T)) //If the distances equal eachother.
							//new/turf/Grass2(T)
		world<<"Initializing Land Vegetation."
		/*for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/T in view(2,S))
						if(get_dist(D,S) == get_dist(D,T)) //If the distances equal eachother.
							new/obj/plant/tree(T)*/ //Create a tree.
		for(var/obj/seed/S)
			for(var/obj/seed/D)
				if(get_dist(S,D) == max(D.Spots)||get_dist(D,S) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/Grass/T in oview(1,S))
						if(get_dist(S,D) == get_dist(T,S)) //If the distances equal eachother.
							//var/obj/plant/p = locate(/obj/plant) in T.contents
							//if(p)
							//	return FALSE
							//else
							//return FALSE
							new/obj/plant/ueiktree(T)
							//new/obj/plant/ueiktree(S)
							//new/obj/plant/ueiktree(D)

							//new/turf/lava(T,5)
		//for(var/turf/clast/G in world)
		//	if(prob(10))        // 80%
				//new/turf/lava(G,5)
		/*for(var/turf/Grass/G in world)
			if(prob(5))        // 80%
				new/obj/STrees/ClastTree(G)
		for(var/turf/Grass/G in world)
			if(prob(1))        // 80%
				new/obj/Plants/Rubyberrybush(G)
		for(var/turf/Grass/G in world)
			if(prob(1))        // 80%
				new/obj/Plants/Sapphireberrybush(G)
		for(var/turf/Grass/G in world)
			if(prob(0.3))        // 80%
				new/obj/Flowers/Tallgrass1(G)
		for(var/turf/Grass/G in world)
			if(prob(0.3))        // 80%
				new/obj/Flowers/Tallgrass2(G)
		for(var/turf/Grass/G in world)
			if(prob(0.3))        // 80%
				new/obj/Flowers/Tallgrass3(G)*/
		/*for(var/turf/caves/caveflr1/G in world)
			if(prob(0.3))        // 80%
				new/obj/Flowers/Purpflower(G)
		for(var/turf/caves/caveflr1/G in world)
			if(prob(0.3))        // 80%
				new/obj/Flowers/Lightpurpflower(G)
		for(var/turf/caves/caveflr1/G in world)
			if(prob(0.6))        // 80%
				new/obj/Flowers/Tallgrass(G)
		world<<"Initializing Rock Placement."
		for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(D,S) == max(S.Spots)||get_dist(D,S) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
					P=/obj/plant/ueiktree															 //Or if the distance equals the lowest number in D's list
					for(var/turf/T in view(0.2,S))
						if(get_dist(D,S) || get_dist(D,T)) //If the distances equal eachother.
							if(T==P)
								del(P)
							new/obj/Rock(T)*/
		for(var/turf/Grass/G)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				else if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				else if(prob(0.1))
					new/obj/Rocks/LRocks(G)
				if(prob(0.1))
					new/obj/Rocks/SRocks(G)
				//if(/obj/plant/ueiktree in G)
				//	return 0
		//world<<"Initializing Food Resources."
		/*for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(D,S) == max(S.Spots)||get_dist(D,S) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
					P=/obj/plant/ueiktree															 //Or if the distance equals the lowest number in D's list
					for(var/turf/T in view(0.2,S))
						if(get_dist(D,S) || get_dist(D,T)) //If the distances equal eachother.
							if(T==P)
								del(P)
							new/obj/Rock(T)
		for(var/turf/clast/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.2))
					new/obj/spawns/spawnpointe5(G)
		for(var/turf/clast/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.1))
					new/obj/spawns/spawnpointB2(G)*/
		world<<"Initializing Building Resources."
		/*for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(D,S) == max(S.Spots)||get_dist(D,S) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
					P=/obj/plant/ueiktree															 //Or if the distance equals the lowest number in D's list
					for(var/turf/T in view(0.2,S))
						if(get_dist(D,S) || get_dist(D,T)) //If the distances equal eachother.
							if(T==P)
								del(P)
							new/obj/Rock(T)*/


		for(var/turf/Grass/G)
			//if(G == G&&G.contents)

			//	if(G)
			if(prob(0.01))
				new/obj/spawns/spawnpointB2(G)

				//if(G==G)
			else if(prob(0.3))        // 80%
				new/obj/Plants/Raspberrybush(G)

			else if(prob(0.3))        // 80%
				new/obj/Plants/Blueberrybush(G)
			//var/obj/plant/ueiktree/ut = locate(/obj/plant/ueiktree) in range(G)
			else if(prob(1.01))
				new/obj/plant/UeikTreeA(G)
				//if(G==G)
			else if(prob(1.01))
				new/obj/plant/UeikTreeH(G)
			else if(prob(0.30))
				new/obj/plant/ueiktree(G)

			if(prob(0.5))
				new/obj/Flowers/Blueflower(G)
				//if(G==G)
			if(prob(0.5))
				new/obj/Flowers/Lightpurpflower(G)
				//if(G==G)
			else if(prob(0.5))
				new/obj/Flowers/Pinkflower(G)
				//if(G==G)
			if(prob(0.5))
				new/obj/Flowers/Purpflower(G)
				//if(G==G)
			else if(prob(0.5))
				new/obj/Flowers/Redflower(G)
				//if(G==G)
			if(prob(1.0))
				new/obj/Flowers/Tallgrass(G)

			else if(prob(0.01))
				new/turf/TarPit(G)
				//if(G==G)
			else if(prob(0.03))
				new/turf/ClayDeposit(G)
				//if(G==G)
			else if(prob(0.02))
				new/turf/ObsidianField(G)
				//if(G==G)
			else if(prob(0.02))
				new/turf/Sand2(G)
				//if(G==G)
			else if(prob(0.01))
				new/obj/Soil/richsoil(G)
				//if(G==G)
			if(prob(0.02))
				new/obj/Soil/soil(G)

			//if(prob(0.6))
				//new/obj/Rocks/SRocks(G)
				//if(prob(0.3))
					//new/obj/Rocks/ZRocks(G)
				//if(prob(0.3))
					//new/obj/Rocks/CRocks(G)
				//if(prob(0.3))
					//new/obj/Rocks/LRocks(G)
		/*world<<"Creating Access Portals."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.09))
					new/obj/accesspoint(G)*/
		//world<<"Initializing Land Adjustments."
		/*for(var/turf/lava/W in world)
			var/A=0
			var/B=0
			//Fixing Choppy look.
			for(var/turf/clast/a in oview(3,W))
				if(locate(a.x,a.y,a.z)==locate(W.x-1,W.y,W.z)||locate(a.x,a.y,a.z)==locate(W.x+1,W.y,W.z))
					A++
				if(locate(a.x,a.y,a.z)==locate(W.x,W.y+1,W.z)||locate(a.x,a.y,a.z)==locate(W.x,W.y-1,W.z))
					B++
			if(A == 1)
				new/turf/clast(W)
			if(B == 50)
				new/turf/clast(W)
		//world<<"Initializing Land Trimming."
		//for(var/turf/clast/a in world)
			//for(var/turf/lava/W in view(1,a))
				//W.overlays += image('dmi/64/gen.dmi',icon_state="[get_dir(a,W)]") //Adds border to grass.
				for(W in world)
					var/C=0
					var/D=0
					//Fixing Choppy look.
					for(var/turf/Grass2/b in oview(700,W))
						if(locate(b.x,b.y,b.z)==locate(W.x-1,W.y,W.z)||locate(b.x,b.y,b.z)==locate(W.x+1,W.y,W.z))
							C++
						if(locate(b.x,b.y,b.z)==locate(W.x,W.y+1,W.z)||locate(b.x,b.y,b.z)==locate(W.x,W.y-1,W.z))
							D++
					if(C == 50)
						new/turf/Grass(W)
					if(D == 50)
						new/turf/Grass(W)
				for(var/turf/Grass2/b in world)
					for(W in view(1,b))
						W.overlays += image('dmi/64/gen.dmi',icon_state="[get_dir(b,W)]") //Adds border to grass.
				*/
		/*for(var/turf/Grass/G in world)
			var/CAF = /obj/caflag
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				new CAF(1,G)
				CAF:CAMapFlag=1*/
		world<<"Map Creation Complete"
		return

		*/

	//verb/DelSeed()
		//new/turf/Water in world
	//New()
	//	..()
		//loc=locate(world)
/*obj
	caflag
		var/CAMapFlag
		CAMapFlag = 0*/

random
	var/seed

	New(seed = 1)
		src.seed = seed
	proc/rnd(n = 0)
		seed = (seed * 171) % 30269
		. = seed / 30269
		if(n) . = round(. * n)

  // equivalent to prob(percent)
	proc/chance(percent = 50)
		return (rnd() * 100 < percent)

var/tg = /turf/Grass
/*
mob/players/verb
	Debug_Edges()
		Debug_Edges()

mob/players/verb
	GeneratePond()
		world<<"Initializing Resources."


		for(var/turf/Grass/G)

			//Ponds
			//if(prob(15) && !(locate(/obj/plant/ueiktree) in range(3, G)) )
			if(prob(10) && !(locate(/obj/Plants/Bush/Raspberrybush)	in range(1, G)) && \
				!(locate(/obj/Plants/Bush/Blueberrybush)	in G) && \
				!(locate(/obj/Flowers/Blueflower)	in G) && \
				!(locate(/obj/Flowers/Lightpurpflower)	in G) && \
				!(locate(/obj/Flowers/Pinkflower)	in G) && \
				!(locate(/obj/Flowers/Purpflower)	in G) && \
				!(locate(/obj/Flowers/Redflower)	in G) && \
				!(locate(/obj/Flowers/Tallgrass)	in G) && \
				!(locate(/obj/Rocks/IRocks)	in G) && \
				!(locate(/obj/Rocks/ZRocks)	in G) && \
				!(locate(/obj/Rocks/CRocks)	in G) && \
				!(locate(/obj/Rocks/LRocks)	in G) && \
				!(locate(/obj/Rocks/SRocks)	in G) && \
				!(locate(/turf/TarPit)	in G) && \
				!(locate(/turf/ClayDeposit)	in G) && \
				!(locate(/turf/ObsidianField)	in G) && \
				!(locate(/turf/Sand2)	in G) && \
				!(locate(/obj/Soil/richsoil)	in G) && \
				!(locate(/obj/Soil/soil)	in G) && \
				!(locate(/obj/plant/ueiktree)	in G))
				if(prob(5))
					new/turf/Water(G)

					for(var/turf/t in oview(1, G))
						if(prob(1)) continue
						if(!(locate(/obj/Rocks/SRocks)	in t) &&!(locate(/obj/Rocks/LRocks)	in t) &&!(locate(/obj/Rocks/CRocks)	in t) &&!(locate(/obj/Rocks/ZRocks)	in t) &&!(locate(/obj/Rocks/IRocks)	in t) &&!(locate(/obj/Flowers/Tallgrass)	in t) &&!(locate(/obj/Flowers/Redflower)	in t) &&!(locate(/obj/Flowers/Purpflower)	in t) &&!(locate(/obj/Flowers/Pinkflower)	in t) &&!(locate(/obj/Flowers/Lightpurpflower)	in G) &&!(locate(/obj/Plants/Bush/Raspberrybush)	in t) && !(locate(/obj/Flowers/Blueflower) in t) && !(locate(/obj/Plants/Bush/Blueberrybush) in t) && ! (locate(/obj/plant/UeikTreeH) in t) && ! (locate(/obj/plant/UeikTreeA) in t) && ! (locate(/obj/plant/ueiktree) in t))
							new/turf/Water(t)


*/









proc
	Debug_Edges()
		set background = 1
		for(var/turf/Grass/a in world)
			for(var/turf/Water/W in oview(1,a))
				for(var/obj/o in bounds(W))
					del(o)
				var/turf/Water/W2
				var/turf/Water/W3
				W.overlays += image('dmi/64/pbord1.dmi',icon_state="[get_dir(a,W)]")
				for (W2 in block(locate(W.x - 1, W.y - 1, W.z), locate(W.x + 1, W.y + 1, W.z))) if (!istype(W2)) break
				if (W2) //this is a corner, because one of the tiles surrounding it is not of the type /turf/Water
					W.overlays += image('dmi/64/pbord2.dmi',icon_state="[get_dir(a,W)]")
				for (W3 in block(locate(W.x - 1, W.y - 1, W.z), locate(W.x + 2, W.y + 2, W.z))) if (!istype(W3)) break
				if (W3) //this is a corner, because one of the tiles surrounding it is not of the type /turf/Water
					W.overlays += image('dmi/64/pbord2.dmi',icon_state="[get_dir(a,W)]")

		/*for(var/turf/clast/a in world)
			for(var/turf/lava/W in oview(1,a))
				var/turf/lava/W2
				var/turf/lava/W3
				W.overlays += image('dmi/64/lava.dmi',icon_state="[get_dir(a,W)]")
				for (W2 in block(locate(W.x - 1, W.y - 1, W.z), locate(W.x + 1, W.y + 1, W.z))) if (!istype(W2)) break
				if (W2) //this is a corner, because one of the tiles surrounding it is not of the type /turf/Water
					W.overlays += image('dmi/64/lava2.dmi',icon_state="[get_dir(a,W)]")
				for (W3 in block(locate(W.x - 1, W.y - 1, W.z), locate(W.x + 2, W.y + 2, W.z))) if (!istype(W3)) break
				if (W3) //this is a corner, because one of the tiles surrounding it is not of the type /turf/Water
					W.overlays += image('dmi/64/lava2.dmi',icon_state="[get_dir(a,W)]")*/


proc
	Debug_Lamps()
		set background = 1
		for(var/obj/townlamp/J)
			//if(J.Lit == 0)
			J.overlays += icon('dmi/64/build.dmi',icon_state="ll")
					//J.light.on()
					//J.Lit = 1
					//J.overlays -= icon('dmi/64/build.dmi',icon_state="TLO")
		for(var/obj/TownTorches/Torch/J1)
			//if(J1.Lit == 0)
					//J1.light.on()
					//J1.Lit = 1
			J1.overlays += icon('dmi/64/fire.dmi',icon_state="1")
		for(var/obj/TownTorches/Torcha/J2)
			//if(J2.Lit == 0)
					//J2.light.on()
					//J2.Lit = 1
			J2.overlays += icon('dmi/64/fire.dmi',icon_state="2")
		for(var/obj/TownTorches/Torchb/J3)
			//if(J3.Lit == 0)
					//J3.light.on()
					//J3.Lit = 1
			J3.overlays += icon('dmi/64/fire.dmi',icon_state="4")
		for(var/obj/TownTorches/Torchc/J4)
			//if(J4.Lit == 0)
					//J4.light.on()
					//J4.Lit = 1
			J4.overlays += icon('dmi/64/fire.dmi',icon_state="8")
		for(var/obj/TownTorches/castlwll5a/J5a)
		//	if(J5a.Lit == 0)
					//J5a.light.on()
				//J5a.Lit = 1
			J5a.overlays += icon('dmi/64/fire.dmi',icon_state="8")
		for(var/obj/TownTorches/btmwll1a/J6a)
			//if(J6a.Lit == 0)
					//J6a.light.on()
					//J6a.Lit = 1
			J6a.overlays += icon('dmi/64/fire.dmi',icon_state="8")

			/*
			W.overlays += image('dmi/64/gen.dmi',icon_state="[get_dir(a,W)]")
			for(var/turf/Grass/a in world)
				for(var/turf/Dirt/D in oview(1,a))
					D.overlays += image('dmi/64/build.dmi',icon_state="[get_dir(a,D)]")
			for(var/turf/Grass/a in world)
				for(var/turf/Sand/S in oview(1,a))
					S.overlays += image('dmi/64/build.dmi',icon_state="[get_dir(a,S)]")
			for(var/turf/Grass/a in world)
				for(var/obj/Soil/soil/SO in oview(1,a))
					SO.overlays += image('dmi/64/build.dmi',icon_state="[get_dir(a,SO)]")
			for(var/turf/Grass/a in world)
				for(var/obj/Soil/richsoil/rs in oview(1,a))
					rs.overlays += image('dmi/64/build.dmi',icon_state="[get_dir(a,rs)]")*/
				//world<<"Map Creation Complete"
		/*Purge_CA()
			var/obj/caflag/FL = locate() in world
			set background = 1
			FL = src
			for(FL in world)
				if(FL.CAMapFlag == 1)
					var/turf/Grass/A = locate(1,1,1)
					var/turf/Grass/B = locate(world.maxx,world.maxy,1)
					//var/turf/Water/a = locate(world.maxx,world.maxy,1)
					world<<"Regenerating a New World {Reticulating Spline}/n/World is Processing grab a snack or preoccupy yourself for a few/n/ Commencing Combat Area Purge T-10."
					sleep(10)
					world<<"T-0"
					for((A)&&(B))
						del (A&&B)
						world<<"Combat Area Purge Complete"
						return*/
/*mob/players
	verb
		SnowGenerator()
			var/random/R = new()
			set background = 1
			/*for(var/turf/snow/T in world) //Loop through all turfs in the world.
				if(prob(0.1)) //10% Chance of creating a seed on that turf.
					new/obj/seed(T)
					//new/turf/mntn(T)
			world<<"Seeding World..."
			//for(var/obj/seed/seed1 in world)
				//for(var/obj/seed/seed2 in world)
					//if(seed1 != seed2)
						//seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
			world<<"Initializing Land Creation."
			for(var/obj/seed/S in world)
				for(var/turf/snow/T in world)
					if(get_dist(S,T) == (S.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																						 //Or if the distance equals the lowest number in D's list
						for(T in oview(1,S))
							//if(get_dist(T,S)) //If the distances equal eachother.
							var/obj/STrees/aspen/A
							//if(istype(T,/turf/snow))//&&(T.contents=!A))
							if(A in T)
								return
							else
								new/obj/STrees/aspen(S,1)
								//else
									//world<<"null"
									*/
			for(var/turf/snow/G in world)
				if(prob(10))        // 80%
					//new/obj/Flowers/Purpflower(G)
					//new/obj/Duskele(G)
					//for(G as icon)
						//G.override += image('dmi/64/plants.dmi',icon_state="tg3")
					new/obj/STrees/aspen(G,5)
			world<<"Initializing Land Vegetation."
			//for(var/turf/stnflr/G in world)
			//	if(prob(0.8))
			//		new/obj/Crate(G)
			for(var/turf/snow/G in world)
				if(prob(0.3))        // 80%
					//new/obj/Flowers/Purpflower(G)
					//new/obj/Duskele(G)
					//for(G as icon)
						//G.override += image('dmi/64/plants.dmi',icon_state="tg3")
					new/obj/Flowers/Tallgrass3(G)
			for(var/turf/snow/G in world)
				if(prob(0.3))        // 80%
					//new/obj/Flowers/Purpflower(G)
					//new/obj/Duskele(G)
					//for(G as icon)
						//G.override += image('dmi/64/plants.dmi',icon_state="tg3")
					new/obj/Flowers/Tallgrass2(G)
			for(var/turf/snow/G in world)
				if(prob(0.3))        // 80%
					//new/obj/Flowers/Purpflower(G)
					//new/obj/Duskele(G)
					//for(G as icon)
						//G.override += image('dmi/64/plants.dmi',icon_state="tg3")
					new/obj/Flowers/Tallgrass1(G)
			for(var/turf/snow/G in world)
				if(prob(0.3))        // 80%
					new/obj/Plants/Rubyberrybush(G)
			for(var/turf/snow/G in world)
				if(prob(0.3))        // 80%
					new/obj/Plants/Sapphireberrybush(G)
			//for(var/turf/stnflr/G in world)
			//	if(prob(0.1))
			//		new/obj/WaterFountain(G)
			//for(var/turf/stnflr/G in world)
			//	if(prob(0.3))
			//		new/obj/PoisonDarts(G)
			//for(var/turf/snow/G in world)
			//	if(prob(0.1))
		//			new/obj/STrees/aspen(G)
		//	for(var/turf/stnflr/G in world)
			//	if(prob(0.2))
			//		new/obj/Trap1(G)
			//for(var/turf/stnflr/G in world)
			//	if(prob(0.1))
			//		new/obj/Trap2(G)
			world<<"Initializing Rock Placement."
			for(var/turf/snow/G in world)
				//if(G!=G)
					//return 0
				//if(G)     // 80%
				//if(prob(0.01))        // 80%
						//new/obj/Flowers/Tallgrass3(G)
					//for(G as icon)
						//G.override += image('dmi/64/plants.dmi',icon_state="tg3")
				if(prob(0.01))
					new/obj/Rocks/IRocks(G)
				if(prob(0.01))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.01))
					new/obj/Rocks/CRocks(G)
				if(prob(0.01))
					new/obj/Rocks/LRocks(G)
					//if(/obj/plant/ueiktree in G)
					//	return 0
			world<<"Initializing Food Resources."
			//for(var/turf/snow/G in world)
				//if(G!=G)
				//	return 0
				//else if(G==G)
				//	if(prob(0.2))
				//		new/obj/spawns/spawnpointe1(G)
			/*for(var/turf/Water/G in world)
				if(G!=G)
					return 0
				else if(G==G)
					if(prob(0.3))
						new/obj/spawns/spawnpointe5(G)*/
			world<<"Initializing Building Resources."
			for(var/turf/snow/G in world)
				//if(G!=G)
					//return 0
			//	if(G)
				if(prob(0.1))
					new/obj/items/LogsUeikLog(G)
					//for(G as icon)
						//G.override += image('dmi/64/plants.dmi',icon_state="tg3")
						//new/obj/Flowers/Tllgras(G)
			for(var/turf/snow/G in world)
			//	if(G)
				if(prob(0.01))
					new/turf/TarPit(G)
				//if(G==G)
				if(prob(0.01))
					new/turf/ClayDeposit(G)
				//if(G==G)
				if(prob(0.01))
					new/turf/ObsidianField(G)
				//if(G==G)
				if(prob(0.01))
					new/turf/Sand2(G)
				//if(G==G)
				if(prob(0.08))
					new/obj/Soil/richsoil(G)
				//if(G==G)
				if(prob(0.01))
					new/obj/Soil/soil(G)

			world<<"Finished."
			return*/


/*mob/players
	verb
		Teleport1()
			usr.loc=locate(163,57,2)
		Teleport2()
			usr.loc=locate(156,24,3)
		Teleport3()
			usr.loc=locate(146,30,6)
		Teleport4()
			usr.loc=locate(250,99,9)*/


/*mob/players
	verb/Teleport()
		usr.loc=locate(210,148,1)
	verb/Teleport2()
		usr.loc=locate(36,151,1)
	verb/Teleport3()
		usr.loc=locate(69,27,5)
	verb/JungleGenerator()
		var/random/R = new()
		set background = 1
		for(var/turf/drkgrss/T in world) //Loop through all turfs in the world.
			if(prob(5)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1 in world)
			for(var/obj/seed/seed2 in world)
				if(seed1 != seed2)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		world<<"Initializing Land Creation."
		for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/drkgrss/T in view(2,S))
						if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
							new/turf/drkgrss(T)//Create a water turf.
		world<<"Initializing Land Vegetation."
		for(var/turf/drkgrss/G in world)
			if(prob(40.0))
				new/obj/JungleTree(G)
		for(var/turf/drkgrss/G in world)
			if(prob(20.1))
				new/obj/JungleFern(G)
		for(var/turf/drkgrss/G in world)
			if(prob(0.1))
				new/obj/QuickSand(G)
		for(var/turf/drkgrss/G in world)
			if(prob(1.0))
				new/obj/WaterVines(G)
		for(var/turf/drkgrss/G in world)
			if(prob(1.5))
				new/obj/PoisonVines(G)
		for(var/turf/drkgrss/G in world)
			if(prob(0.5))
				new/obj/HealingVines(G)
		for(var/turf/drkgrss/G in world)
			if(prob(1.1))
				new/obj/elegrss(G)
		for(var/turf/drkgrss/G in world)
			if(prob(5.1))
				new/obj/shrtgrss(G)
		for(var/turf/drkgrss/G in world)
			if(prob(0.1))
				new/turf/JungleWater(G)
		/*world<<"Initializing Rock Placement."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				if(prob(0.1))
					new/obj/Rocks/LRocks(G)*/
				//if(/obj/plant/ueiktree in G)
				//	return 0
		world<<"Initializing Food Resources."
		for(var/turf/drkgrss/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe4(G)
		for(var/turf/drkgrss/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe3(G)
		for(var/turf/drkgrss/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe2(G)
		/*world<<"Initializing Building Resources."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/items/LogsUeikLog(G)
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.001))
					new/turf/TarPit(G)*/
		world<<"Finished."

mob/players
	verb/DunesGenerator()
		var/random/R = new()
		set background = 1
		for(var/turf/sand1/T in world) //Loop through all turfs in the world.
			if(prob(5)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1 in world)
			for(var/obj/seed/seed2 in world)
				if(seed1 != seed2)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		//world<<"Initializing Land Creation."
		//for(var/obj/seed/S in world)
			//for(var/obj/seed/D in world)
				//if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
				//	for(var/turf/sand1/T in view(1,S))
						//if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
						//	new/turf/sand1(T)//Create a water turf.
		world<<"Initializing Land Vegetation."
		for(var/turf/sand1/G in world)
			if(prob(10.0))
				new/turf/Dune1(G)
		for(var/turf/sand1/G in world)
			if(prob(5.0))
				new/turf/Dune2(G)
		for(var/turf/sand1/G in world)
			if(prob(0.01))
				new/obj/QuickSand(G)
		for(var/turf/sand1/G in world)
			if(prob(0.4))
				new/obj/Dskele(G)
		for(var/turf/sand1/G in world)
			if(prob(0.3))
				new/obj/WaterCactus(G)
		for(var/turf/sand1/G in world)
			if(prob(0.5))
				new/obj/PoisonCactus(G)
		for(var/turf/sand1/G in world)
			if(prob(0.2))
				new/obj/HealingCactus(G)
		for(var/turf/sand1/G in world)
			if(prob(0.1))
				new/obj/PalmTree(G)
		/*world<<"Initializing Rock Placement."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				if(prob(0.1))
					new/obj/Rocks/LRocks(G)*/
				//if(/obj/plant/ueiktree in G)
				//	return 0
		world<<"Initializing Food Resources."
		for(var/turf/sand1/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe1(G)
		for(var/turf/sand1/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe3(G)
		for(var/turf/sand1/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe2(G)
		/*world<<"Initializing Building Resources."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/items/LogsUeikLog(G)
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.001))
					new/turf/TarPit(G)*/
		world<<"Finished."

mob/players
	verb/DungeonGenerator()
		var/random/R = new()
		set background = 1
		for(var/turf/caves/caveflr1/T in world) //Loop through all turfs in the world.
			if(prob(5)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1 in world)
			for(var/obj/seed/seed2 in world)
				if(seed1 != seed2)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		world<<"Initializing Land Creation."
		for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/sand1/T in view(1,S))
						if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
							new/turf/stnflr(T)//Create a water turf.
		world<<"Initializing Land Vegetation."
		for(var/turf/stnflr/G in world)
			if(prob(0.8))
				new/obj/Crate(G)
		for(var/turf/stnflr/G in world)
			if(prob(0.6))
				new/obj/Duskele(G)
		for(var/turf/stnflr/G in world)
			if(prob(0.1))
				new/obj/WaterFountain(G)
		for(var/turf/stnflr/G in world)
			if(prob(0.3))
				new/obj/PoisonDarts(G)
		for(var/turf/stnflr/G in world)
			if(prob(0.1))
				new/obj/HealingFountain(G)
		for(var/turf/stnflr/G in world)
			if(prob(0.2))
				new/obj/Trap1(G)
		for(var/turf/stnflr/G in world)
			if(prob(0.1))
				new/obj/Trap2(G)
		/*world<<"Initializing Rock Placement."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				if(prob(0.1))
					new/obj/Rocks/LRocks(G)*/
				//if(/obj/plant/ueiktree in G)
				//	return 0
		world<<"Initializing Food Resources."
		for(var/turf/stnflr/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/spawnpointe4(G)
		for(var/turf/stnflr/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.3))
					new/obj/spawnpointe3(G)
		/*world<<"Initializing Building Resources."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/items/LogsUeikLog(G)
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.001))
					new/turf/TarPit(G)*/
		world<<"Finished."


mob/players
	verb/SnowGenerator()
		var/random/R = new()
		set background = 1
		for(var/turf/snow/T in world) //Loop through all turfs in the world.
			if(prob(5)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1 in world)
			for(var/obj/seed/seed2 in world)
				if(seed1 != seed2)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		world<<"Initializing Land Creation."
		for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/snow/T in view(1,S))
						if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
							new/obj/aspen(T)//Create a water turf.
		world<<"Initializing Land Vegetation."
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.8))
		//		new/obj/Crate(G)
		for(var/turf/snow/G in world)
			if(prob(0.6))
				new/obj/Duskele(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.1))
		//		new/obj/WaterFountain(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.3))
		//		new/obj/PoisonDarts(G)
		for(var/turf/Hill/SnowHill/shillPC/G in world)
			if(prob(0.1))
				new/obj/aspen(G)
	//	for(var/turf/stnflr/G in world)
		//	if(prob(0.2))
		//		new/obj/Trap1(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.1))
		//		new/obj/Trap2(G)
		/*world<<"Initializing Rock Placement."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				if(prob(0.1))
					new/obj/Rocks/LRocks(G)*/
				//if(/obj/plant/ueiktree in G)
				//	return 0
		world<<"Initializing Food Resources."
		for(var/turf/snow/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/spawnpointe4(G)
		for(var/turf/Hill/SnowHill/shillPC/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.3))
					new/obj/spawnpointe5(G)
		/*world<<"Initializing Building Resources."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/items/LogsUeikLog(G)
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.001))
					new/turf/TarPit(G)*/
		world<<"Finished."


mob/players
	verb/ClastGenerator()
		var/random/R = new()
		set background = 1
		for(var/turf/caves/caveflr1/T in world) //Loop through all turfs in the world.
			if(prob(5)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1 in world)
			for(var/obj/seed/seed2 in world)
				if(seed1 != seed2)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		world<<"Initializing Land Creation."
		for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/caves/caveflr1/T in view(1,S))
						if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
							new/turf/caves/caveflr1(T)//Create a water turf.
		world<<"Initializing Land Vegetation."
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.8))
		//		new/obj/Crate(G)
		for(var/turf/caves/caveflr1/G in world)
			if(prob(0.6))
				new/obj/Duskele(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.1))
		//		new/obj/WaterFountain(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.3))
		//		new/obj/PoisonDarts(G)
		for(var/turf/caves/caveflr1/G in world)
			if(prob(15.1))
				new/obj/ClastTree(G)
	//	for(var/turf/stnflr/G in world)
		//	if(prob(0.2))
		//		new/obj/Trap1(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.1))
		//		new/obj/Trap2(G)
		/*world<<"Initializing Rock Placement."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				if(prob(0.1))
					new/obj/Rocks/LRocks(G)*/
				//if(/obj/plant/ueiktree in G)
				//	return 0
		world<<"Initializing Food Resources."
		for(var/turf/caves/caveflr1/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.3))
					new/obj/spawnpointe6(G)
		for(var/turf/caves/caveflr1/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe7(G)
		/*world<<"Initializing Building Resources."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/items/LogsUeikLog(G)
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.001))
					new/turf/TarPit(G)*/
		world<<"Finished."

mob/players
	verb/POHGenerator()
		var/random/R = new()
		set background = 1
		for(var/turf/clast/T in world) //Loop through all turfs in the world.
			if(prob(5)) //10% Chance of creating a seed on that turf.
				new/obj/seed(T)
		for(var/obj/seed/seed1 in world)
			for(var/obj/seed/seed2 in world)
				if(seed1 != seed2)
					seed1.Spots += get_dist(seed2,seed1) //Add the distance from seed1 to seed2 to their own list.
		world<<"Initializing Land Creation."
		/*for(var/obj/seed/S in world)
			for(var/obj/seed/D in world)
				if(get_dist(S,D) == max(S.Spots)||get_dist(S,D) == min(D.Spots)) //If the distance from seed S to seed D equals the higest item is S's list
																				 //Or if the distance equals the lowest number in D's list
					for(var/turf/clast/T in view(1,S))
						if(get_dist(S,D) == get_dist(T,D)) //If the distances equal eachother.
							new/turf/clast(T)//Create a water turf.
							*/
		world<<"Initializing Land Vegetation."
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.8))
		//		new/obj/Crate(G)
		for(var/turf/clast/G in world)
			if(prob(0.6))
				new/obj/Duskele(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.1))
		//		new/obj/WaterFountain(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.3))
		//		new/obj/PoisonDarts(G)
		for(var/turf/clast/G in world)
			if(prob(15.1))
				new/obj/ClastTree(G)
	//	for(var/turf/stnflr/G in world)
		//	if(prob(0.2))
		//		new/obj/Trap1(G)
		//for(var/turf/stnflr/G in world)
		//	if(prob(0.1))
		//		new/obj/Trap2(G)
		/*world<<"Initializing Rock Placement."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)     // 80%
				if(prob(0.3))
					new/obj/Rocks/IRocks(G)
				if(prob(0.1))
					new/obj/Rocks/ZRocks(G)
				if(prob(0.1))
					new/obj/Rocks/CRocks(G)
				if(prob(0.1))
					new/obj/Rocks/LRocks(G)*/
				//if(/obj/plant/ueiktree in G)
				//	return 0
		world<<"Initializing Food Resources."
		for(var/turf/clast/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.3))
					new/obj/spawnpointe6(G)
		for(var/turf/clast/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.1))
					new/obj/spawnpointe7(G)
		/*world<<"Initializing Building Resources."
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.2))
					new/obj/items/LogsUeikLog(G)
		for(var/turf/Grass/G in world)
			if(G!=G)
				return 0
			else if(G==G)
				if(prob(0.001))
					new/turf/TarPit(G)*/
		world<<"Finished."*/