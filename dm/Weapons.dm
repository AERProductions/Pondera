mob
	var
		Wequipped = 0//these control the weapon/tool equip system
		Aequipped = 0
		Sequipped = 0
		TWequipped = 0
		LSequipped = 0
		AXequipped = 0
		WHequipped = 0
		JRequipped = 0
		FPequipped = 0
		PXequipped = 0
		SHequipped = 0
		HMequipped = 0
		SKequipped = 0
		HOequipped = 0
		CKequipped = 0
		GVequipped = 0
		FLequipped = 0
		PYequipped = 0
		OKequipped = 0
		SHMequipped = 0
		UPKequipped = 0
		CHequipped = 0
		tempdefense = 0
		tempevade = 0
		tempdamagemin = 1
		tempdamagemax = 2
		tempstr = 1

obj
	/*MouseDrop(over_object,src_location,over_location)
		// from the map to the Inventory panel
		if(isturf(src_location) && (over_location == "Inventory"))
			if(get_dist(usr,src_location)<=2)       // check distance
				src.Move(usr)
				// from the Inventory panel to the map
			else if((src_location == "Inventory") && isturf(over_location))
				if(get_dist(usr,over_location)<=2)
					src.Move(over_location)
	Click(location)
			// if clinked in the Inventory panel, and this obj is a container
		if((location == "Inventory") && stt_container)
			stt_open = !stt_open    // toggle it's open state

	MouseDrop(target,start,end)
		/* if it was dragged from the inventory panel to
			another part of the inventory panel */
		if((start == "Inventory") && (end == "Inventory"))
			if(isobj(target))
				var/obj/O = target      // obj alias to target
				if(O.stt_container)
					Move(target)
					return
			Move(usr)*/
	var/Worth
obj
	items
		ancscrlls
			can_stack = TRUE
			icon = 'dmi/64/anctxt.dmi'
			//Del()
				//..()
				//usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
			var
				intreq
			//var
				//description
			//fixed -- now will unlock the interface button when the spell is learned
			heat//													need to flush the descriptions out with centering
				name = "Ancient Tome of Heat"
				icon_state = "heat"
				Worth = 200
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Heat."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Heat."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.heatlevel*3)+2
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Heat
						M.heatlevel+=1
						src.icon_state = "heatu"
						//call(/mob/players/proc/spelllvlcheck)(usr)
						//view() << image(/obj/items/ancscrlls/heat,usr)
						winset(usr,"default.Heat","is-visible=true")
						usr << "<center>\  <IMG CLASS=icon SRC=\ref[src.icon] > Heat, Revision [M.heatlevel]!"
						usr << "<center>\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Heat, Revision [M.heatlevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f><center>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Heat, you require [(M.heatlevel*3)+2] Spirit."
						return
			shardburst//fixed (I guess the sound system Del was interfering with the deletion of objects/mobs)
				name = "Ancient Tome of Shard Burst"
				icon_state = "shardburst"
				Worth = 250
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Shard Burst."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Shard Burst."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = round(((M.shardburstlevel*3.2)+1),1)
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/ShardBurst
						M.shardburstlevel=1
						src.icon_state = "shardburstu"
						//call(/mob/players/proc/spelllvlcheck)(usr)
						winset(usr,"default.Shardburst","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Shard Burst, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Shard Burst, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Shard Burst Level [M.shardburstlevel]!"
						sleep(15)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Shard Burst, you require[round(((M.shardburstlevel*3.2)+1),1)] Spirit."
						return
			watershock
				name = "Ancient Tome of Water Shock"
				icon_state = "watershock"
				Worth = 300
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Water Shock."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Water Shock."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = round(((M.watershocklevel*3.7)+3),1)
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/WaterShock
						M.watershocklevel+=1
						src.icon_state = "watershocku"
						//call(/mob/players/proc/spelllvlcheck)(usr)
						winset(usr,"default.Watershock","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Water Shock, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Water Shock, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Water Shock, Revision: [M.watershocklevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Watershock, you require [round(((M.watershocklevel*3.7)+3),1)] Spirit."
						return
			vitae
				name = "Ancient Tome of Vitae"
				//icon = 'dmi/64/magi.dmi'
				icon_state = "vitae"
				Worth = 400
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Vitae."
				Click()
					Use()
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Vitae."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.vitaelevel*3)+2
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Vitae
						M.vitaelevel+=1
						src.icon_state = "vitaeu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Vitae","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Vitae, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Vitae, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Vitae, Revision [M.vitaelevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Vitae, you require [(M.vitaelevel*3)+2] Spirit."
						return
			vitaeII
				name = "Ancient Tome of Vitae II"
				//icon = 'dmi/64/magi.dmi'
				icon_state = "vitae2"
				Worth = 800
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Vitae II."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Vitae II."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.vitae2level*3)+2
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/VitaeII
						M.vitae2level+=1
						src.icon_state = "vitae2u"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Vitae2","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Vitae II, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Vitae II, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Vitae II, Revision [M.vitae2level]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Vitae II, you require [(M.vitae2level*3)+2] Spirit."
						return
			telekinesis
				name = "Ancient Tome of Telekinesis"
				icon_state = "telekinesis"
				Worth = 1000
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Telekinesis."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Telekinesis."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.telekinesislevel*4)+4
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Telekinesis
						M.telekinesislevel+=1
						src.icon_state = "telekinesisu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Telekinesis","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Telekinesis, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Telekinesis, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Telekinesis, Revision: [M.telekinesislevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Telekinesis, you require [(M.telekinesislevel*4)+4] Spirit."
						return
			abjure
				name = "Ancient Tome of Abjure"
				icon_state = "abjure"
				Worth = 1000
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Abjure."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Abjure."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.abjurelevel*5)+5
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Abjure
						M.abjurelevel+=1
						src.icon_state = "abjureu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Abjure","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Abjure, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Abjure, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Abjure, Revision: [M.abjurelevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Abjure, you require [(M.abjurelevel*5)+5] Spirit."
						return
			panacea
				name = "Ancient Tome of Panacea"
				icon_state = "panacea"
				Worth = 2000
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Panacea."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Panacea."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.panacealevel*12)+8
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Panacea
						M.panacealevel+=1
						src.icon_state = "panaceau"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Panacea","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Panacea, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Panacea, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Panacea, Revision: [M.panacealevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Panacea, you require [(M.panacealevel*12)+8] Spirit."
						return


			flame
				name = "Ancient Tome of Flame"
				icon_state = "flame"
				Worth = 1000
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Flame."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Flame."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.flamelevel*4)+8
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Flame
						M.flamelevel+=1
						src.icon_state = "flameu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Flame","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Flame, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Flame, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Flame, Revision: [M.flamelevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Flame, you require [(M.flamelevel*4)+8] Spirit."
						return
			icestorm
				name = "Ancient Tome of Ice Storm"
				icon_state = "icestorm"
				Worth = 1250
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Ice Storm."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Ice Storm."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.icestormlevel*4)+8
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/IceStorm
						M.icestormlevel+=1
						src.icon_state = "icestormu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Icestorm","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Ice Storm, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Ice Storm, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Ice Storm, Revision: [M.icestormlevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Ice Storm, you require [(M.icestormlevel*4)+8] Spirit."
						return
			cascadelightning
				name = "Ancient Tome of Cascade Lightning"
				icon_state = "caslight"
				Worth = 1500
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Cascade Lightning."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Cascade Lightning."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = M.cascadelightninglevel*4+8
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/CascadeLightning
						M.cascadelightninglevel+=1
						src.icon_state = "caslightu"
						//call(/mob/players/proc/spelllvlcheck)()
						//src.icon_state = "caslightu"
						winset(usr,"default.Cascadelightning","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Cascade Lightning, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Cascade Lightning, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Cascade Lightning, Revision: [M.cascadelightninglevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Cascade Lightning, you require [intreq] Spirit."
						return
			cosmos
				name = "Ancient Tome of Cosmos"
				icon_state = "cosmos"
				Worth = 3000
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Cosmos."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Cosmos."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.cosmoslevel*10)+10
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Cosmos
						M.cosmoslevel+=1
						src.icon_state = "cosmosu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Cosmos","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Cosmos, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Cosmos, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Cosmos Level [M.cosmoslevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Cosmos, you require [(M.cosmoslevel*10)+10] Spirit."
						return
			rephase
				name = "Ancient Tome of Rephase"
				icon_state = "rephrase"
				Worth = 3000
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Rephase."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Rephase."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.rephaselevel*10)+10
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Rephase
						M.rephaselevel+=1
						src.icon_state = "rephaseu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Rephase","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Rephase, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Rephase, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Rephase, Revision: [M.rephaselevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Rephase, you require [(M.rephaselevel*10)+10] Spirit."
						return
			acid
				name = "Ancient Tome of Acid"
				icon_state = "acid"
				Worth = 2500
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Acid."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Acid."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = round(5*sqrt(M.acidlevel),1)
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Acid
						M.acidlevel+=1
						src.icon_state = "acidu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Acid","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Acid, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Acid, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Acid, Revision: [M.acidlevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Acid, you require [round(5*sqrt(M.acidlevel),1)] Spirit."
						return
			bludgeon
				name = "Ancient Tome of Bludgeon"
				icon_state = "bludgeon"
				Worth = 2500
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to Bludgeon."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to Bludgeon."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = (M.bludgeonlevel*2)+10
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Bludgeon
						M.bludgeonlevel+=1
						src.icon_state = "bludgeonu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Bludgeon","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Bludgeon, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Bludgeon, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Bludgeon, Revision: [M.bludgeonlevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Bludgeon, you require [(M.bludgeonlevel*2)+10] Spirit."
						return
			quietus
				name = "Ancient Tome of Quietus"
				icon_state = "quietus"
				Worth = 6482
				//description = "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Quietus."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > An ancient tome containing knowledge of how to cast the magi Quietus."
					return
				verb/Use()
					set waitfor = 0
					set category = null
					set src in usr
					var/mob/players/M = usr
					intreq = round(25*sqrt(M.quietuslevel),1)
					if (M.Spirit >= intreq)
						usr.verbs+=new/mob/players/spells/verb/Quietus
						M.quietuslevel+=1
						src.icon_state = "quietusu"
						//call(/mob/players/proc/spelllvlcheck)()
						winset(usr,"default.Quietus","is-visible=true")
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] > Quietus, Revision [M.heatlevel]!"
						usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>\green<b>You decoded Quietus, Revision [M.heatlevel]!"
						usr << "\green<b>You decoded Quietus, Revision: [M.quietuslevel]!"
						sleep(25)
						usr << "<font color=#40e0d0><b>The [src.name] dissipates out of this world..."
						del(src)
						return
					else
						usr << "<font color = #00ff7f>\  <IMG CLASS=icon SRC=\ref[src.icon] >To decode the Ancient Tome of Quietus, you require [round(25*sqrt(M.quietuslevel),1)] Spirit."
						return
	items
		//the items are also not so bad, the Get() has checks for questitem quest though
		icon = 'dmi/64/inven.dmi'
		//can_stack = TRUE

			//stack()
		var
			description
			owner = ""
		verb
			GetAll()
				set category=null
				set popup_menu=1
				set src in oview(1)
				//set hidden = 1
				var/mob/players/M = usr
				var/obj/DeedToken/dt
				dt = locate(oview(src,15))
				for(dt)
					if(M.canpickup==1)
						set src in range(1)
						SplitStack(usr, stack_amount)
						return
					else
						M << "You do not have permission to pickup"
						return
				if(!dt)
					if(src.type==/obj/items/questitem)
						var/C=0
						var/obj/items/o

						if(M.quest==0)
							for(o as obj in M.contents)
								if(o.type==/obj/items/questitem&&C==0)
									C=1
									return
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
									return
							if(C==0)
								//src.Move(usr, 1)
								set src in range(1)
								SplitStack(usr, stack_amount)
								return

						else
							M << "You don't need that"
							return
					else
						var/obj/O = src
						set src in oview(1)

						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								//src.Move(usr, 1)
								set src in range(1)
								SplitStack(usr, stack_amount)
								return
			Get()
				set category=null
				set popup_menu=1
				set src in oview(1)
				//set hidden = 1
				var/mob/players/M = usr
				var/obj/DeedToken/dt
				dt = locate(oview(src,15))
				for(dt)
					if(M.canpickup==1)
						set src in range(1)
						SplitStack(usr, stack_amount)
						return
					else
						M << "You do not have permission to pickup"
						return
				if(!dt)
					if(src.type==/obj/items/questitem)
						var/C=0
						var/obj/items/o
						if(M.quest==0)
							for(o as obj in M.contents)
								if(o.type==/obj/items/questitem&&C==0)
									C=1
									return
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
									return
							if(C==0)
								src.SplitStack(usr, 1)
								return
						else
							M << "You don't need that"
							return
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.SplitStack(usr, 1)
								return

			DropAll()
				set category=null
				set popup_menu=1
				set src in usr
				var/mob/players/M = usr
				//var/region/deed/dz
				//dz = locate(oview(src,10))
				var/obj/DeedToken/dt
				dt = locate(oview(src,15))
				for(dt)
					if(M.candrop==1)
						//set src in range(1)
						SplitStack(usr.loc, stack_amount)
						return
					else
						M << "You do not have permission to drop"
						return
				if(!dt)
					if(src.suffix == "Equipped")
						usr << "<font color = teal>Un-equip [src] first!"
						return
					else
						//src.Move(usr.loc, 1)
						//set src in usr
						SplitStack(usr.loc, stack_amount)
						return

			Drop()
				set category=null
				set popup_menu=1
				set src in usr
				var/mob/players/M = usr
				//var/region/deed/dz
				//dz = locate(oview(src,10))
				var/obj/DeedToken/dt
				dt = locate(oview(src,15))
				for(dt)
					if(M.candrop==1)
						//set src in range(1)
						SplitStack(usr.loc, stack_amount)
						return
					else
						M << "You do not have permission to drop"
						return

				if(!dt)
					if(src.suffix == "Equipped")
						src << "<font color = teal>Un-equip [src] first!"
						return
					else
						src.SplitStack(usr.loc, 1)
						return

		proc/usingheal(var/obj/items/J,num)
			var/mob/players/M
			/*var/diceroll = "1d20"
			stack_amount = roll(diceroll)
			if (J.name == "Vitae Vial")
				diceroll = "1d20+19"
			if (J.name == "Large Vitae Vial")
				diceroll = "3d20+4"*/
			M = usr
			if (num > (M.MAXHP-M.HP))
				num = (M.MAXHP-M.HP)
			M.HP += num
			M.updateHP()
			M << "You used a [J]; <b>[num] Health recovered."
			J.RemoveFromStack(1)
			//Del(src)
		proc/usingmana(var/obj/items/J,num)
			var/mob/players/M
			M = usr
			if (num > (M.MAXenergy-M.energy))
				num = (M.MAXenergy-M.energy)
			M.energy += num
			M.updateEN()
			M << "You used a [J]; <b>[num] energy recovered."
			J.RemoveFromStack(1)
			//Del(src)
		questitem
			name = "questitemname"
			icon_state = "questicon"
			description = "<b>Quest description"
			Worth = 0
		Activated_Carbon
			name = "Activated Carbon"
			icon_state = "charcoal"
			description = "<b>Used with Iron to make Steel"
			Worth = 100
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Activated Carbon:</b>  Used with <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron to make <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='sb'> Steel."
				return
			verb
				Create(obj/items/Ingots/ironbar/J)
					set waitfor = 0
					//set src in oview(1)
					set src = usr.contents
					set category = "Commands"
					var/mob/players/M
					//var/random/R = rand(1,5) //1 in 5 chance to smith
					M = usr
					if(J in M.contents)
						input("Combine?","Combine") in list(J in M.contents)
						for(J in M.contents)
							if((J.name=="Iron")&&(J.Tname=="Hot"))
								M<<"You start to combine the \  <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>[J] with the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Activated Carbon..."
								//sleep(5)
								var/dice = "1d8"
								var/R = roll(dice)
								if(R>=5)
									J.RemoveFromStack(10)
										//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									sleep(15)
									//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									M<<"You finish combining the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> Activated Carbon with the <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'> Iron and create <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='sb'> Steel"
									new /obj/items/Ingots/steelbar(M)
									del src
									return
								if(R<=4)
									J.RemoveFromStack(10)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									sleep(15)
									del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									M<<"The materials fail at combining and are lost in the process."
									return
		Carbon
			name = "Carbon"
			icon_state = "Carbon"
			description = "<b>Used with Fire to make Activated Carbon"
			Worth = 100
			plane = 5
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Carbon:</b>  Used with <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'> Fire to make <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='charcoal'> Activated Carbon."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		Tar
			name = "Tar"
			icon_state = "tar"
			description = "<b>Used to Fuel Lamps and Torches"
			Worth = 20
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Tar:</b>  Used to fuel <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ironhandlamp'> <IMG CLASS=icon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ironlamp'> Lamps and <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'> Torches."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		Salve
			name = "Salve"
			icon_state = "salve"
			description = "<b>Used to Heal wounds and restore Energy"
			Worth = 20
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Salve:</b>  Used to Heal wounds and restore energy. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
			verb/Use()
				set category = "Commands"
				set src in usr
				usingheal(src,20)
				usingmana(src,20)
		Mortar
			name = "Mortar"
			icon_state = "Mortar"
			description = "<b>Used with stone bricks to create Stone Walls"
			Worth = 20
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Mortar:</b>  Used with stone bricks to create Stone Walls. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		Obsidian
			name = "Obsidian"
			icon_state = "obsidian"
			description = "<b>Used with Wooden Haunch to create an Obisidian Knife"
			Worth = 5
			Tname="Cool"
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Obsidian:</b>  Combined with <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch to create an <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obisidian Knife. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		Rock
			name = "Rock"
			icon_state = "rock"
			description = "<b>Used with Wooden Haunch to create a Stone Hammer."
			Worth = 0
			Tname="Cool"
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Rock:</b>  Combined with <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'>Stone Hammer. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		UeikThorn
			name = "Ueik Thorn"
			icon_state = "UeikThorn"
			description = "<b>Used with Wooden Haunch to create a Ueik Pickaxe."
			Worth = 0
			Tname="Cool"
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Ueik Thorn:</b>  Combined with <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		AUS
			name = "Ancient Ueik Splinter"
			icon_state = "AUS"
			description = "<b>Used with Ueik Fir to create Gloves."
			Worth = 0
			Tname="Cool"
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Ancient Ueik Splinter:</b>  Utilized to sew <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikFir'>Ueik Fir to create a set of<IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>Gloves. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		UeikFir
			name = "Ueik Fir"
			icon_state = "UeikFir"
			description = "<b>Used with Ancient Ueik Splinter to create Gloves."
			Worth = 0
			Tname="Cool"
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Ueik Fir:</b>  Utilized with <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='AUS'>Ancient Ueik Splinter to create a set of <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>Gloves. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
			verb/Create_Gloves()
				set waitfor = 0
				set category = "Commands"
				var/mob/players/M
				M = usr
				var/obj/items/AUS/J = locate() in M.contents
				var/obj/items/UeikFir/UF = locate() in M.contents
				//var/random/R = rand(1,5) //1 in 5 chance to smith
				if(J in M.contents)
					if(M.energy==0)
						M<<"You are too tired, drink some water."
						return
					else
					//if(M.Cutting==1)
						if(J.Tname!="Cool")
							M<<"Wait for it to cool before affixing."
							return
						else switch(input("Sew?","Sew") in list("Ancient Ueik Splinter"))
							if("Ancient Ueik Splinter")
								//var/random/R = rand(1,5)
								M<<"You start to Sew the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='AUS'>[J] with the <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikFir'>Ueik Fir..."
								//sleep(5)
								var/dice = "1d4"
								var/R = roll(dice)
								if(R>=3)
									J.RemoveFromStack(1)
									//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									sleep(15)
									//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
									M<<"You finish Sewing the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='AUS'>Ancient Ueik Splinter into the <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikFir'>Ueik Fir and create <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>Gloves."
									new /obj/items/tools/Gloves(M)
									UF.RemoveFromStack(1)//del src
									return
								else
									if(R<=2)
										J.RemoveFromStack(1)
											//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										sleep(15)
										UF.RemoveFromStack(1)//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
										M<<"The materials fail at combining and are lost in the process."
										return
				else
					M<<"You need an \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='AUS'>Ancient Ueik Splinter to proceed."
		WDHNCH
			name = "Wooden Haunch"
			icon_state = "WDHNCH"
			description = "<b>Used to create rudimentary Tools and Materials."
			Worth = 10
			can_stack = TRUE
			var/mob/players/M
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Wooden Haunch:</b>  Carved into <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch, <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle or <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>Kindling by <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife. <br>Utilized with <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='rock'>Rock to create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'>Stone Hammer, <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='Obsidian'>Obsidian to create an <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife, or <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikThorn'>Ueik Thorn to create a<IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe. "//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
			verb/Create_Torch()
				set waitfor = 0
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				givetrch(M)
				sleep(2)
			proc/givetrch()
				set waitfor = 0
				var/mob/players/M = usr
				var/random/R = new()
				var/obj/items/Tar/J = locate() in M.contents
				var/obj/items/WDHNCH/W = locate() in M.contents
				M = usr
				if(energy<=0)
					M<<"You are too tired."
					return
				if(src in usr)
					M << "You Begin carving and affixing the materials..."
					Carving=1
					if(R.chance(81))
						sleep(2)
						J.RemoveFromStack(1)
						W.RemoveFromStack(1)
						new /obj/items/torches/Handtorch(M, 1)
						M.energy -= 5	//Depletes one energy
						M.updateEN()
						sleep(2)
						M << "You've created a \  <IMG CLASS=icon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Hand Torch."
						Carving=0
					else
						M<<"\ The <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar failed to Affix to the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> Haunch."
				else
					M<<"You need \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch and <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar to continue..."
					return
			verb/Carve_Tinder()
				set waitfor = 0
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				givetndr(M)
				sleep(2)
			proc/givetndr()
				set waitfor = 0
				var/mob/players/M
				var/random/R = new()
				M = usr
				//var/obj/items/tools/ObsidianKnife/OK = locate() in M.contents
				//var/obj/items/Kindling/ueikkindling/UK = new(usr, 1)
				var/obj/items/WDHNCH/WH = locate() in M.contents
				if(M.energy==0)
					M<<"You are too tired."
					return
				if(M.OKequipped==1)
					if(energy==0)		//Is your energy to low???
						M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
						return
					if(WH in M.contents)
						M << "You Begin carving the materials..."
						Carving=1
						if(R.chance(81))
							sleep(2)
							//UK += M.contents
							new /obj/items/Kindling/ueikkindling(M, 1)
							M.energy -= 5	//Depletes one energy
							M.updateEN()
							sleep(2)
							M << "You've carved \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>Tinder."
							WH.RemoveFromStack(1) //del src
							Carving=0
						else
							M<<"The materials failed to create \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>Tinder."
					else
						M << "Need a \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch to continue..."
				else
					M<<"You need to use an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife to carve the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch."
					return
			verb/SetCarvingZero()
				set hidden = 1
				Carving=0
				return
			verb/Create_Handle()
				set waitfor = 0
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					usr<<"Already creating."
					return
				else
					givehnd(M)
					sleep(2)
			proc/givehnd()
				set waitfor = 0
				var/mob/players/M
				M = usr
				var/obj/items/WDHNCH/WH = locate() in M.contents
				//var/obj/items/Crafting/Created/Handle/H = new(usr, 1)
				var/random/R = new()
				//if(energy<=0)
				//	M<<"You are too tired."
				//	return
				if(M.OKequipped==1)
					if(M.energy==0)		//Is your energy to low???
						M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
						return
					else
						for(WH in M.contents)
							//M << "You Begin carving the materials..."
							if(R.chance(81))
								M << "You Begin carving the materials..."
								Carving=1
								sleep(2)
								new /obj/items/Crafting/Created/Handle(M, 1)
								sleep(2)
								M << "You've carved a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle."
								//WH.RemoveFromStack(1) //del src
								Carving=0
								WH.RemoveFromStack(1)
								return
							else
								M<<"The materials fail to create a \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle."
								Carving=0
						//else
							//M << "Need a Wooden Haunch to continue..."
				else
					M<<"You need to use an \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife to carve the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch."
					return
			verb/Affix()
				set waitfor = 0
				//set src in oview(1)
				set category = "Commands"
				var/mob/players/M
				//var/obj/items/J0
				//var/obj/items/Obsidian/J
				//var/obj/items/Rock/J1
				//var/obj/items/UeikThorn/J2
				//var/list/L
				//L = list("Obsidian","Rock","Ueik",3)
				//var/random/R = rand(1,5) //1 in 5 chance to smith
				M = usr
				var/obj/items/WDHNCH/S = locate() in M.contents
				var/obj/items/Obsidian/J = locate() in M.contents
				var/obj/items/Rock/J1 = locate() in M.contents
				var/obj/items/UeikThorn/J2 = locate() in M.contents
				var/dice = "1d4"
				var/R = roll(dice)//if(J in M.contents)
				if(Carving==1)		//This is saying if usr is already cuttin a tree...
					return
				if(energy==0)		//Is your energy to low???
					M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
					return
				else
					if(S.stack_amount==0)
						M<<"You need \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch to continue..."
						return
					else
						//input("Affix?","Affix") in list("Obsidian","Rock","Ueik Thorn")
						switch(input("Affix?","Affix") in list("Obsidian","Rock","Ueik Thorn")) // in list("Dirt Road","Dirt Road Corner","Water")
						//if(J0 in M.contents)
							//M<<"You start to affix the Wooden Haunch..."
							//Carving=1
							//sleep(5)
							//var/obj/items/WDHNCH/S = locate() in M.contents
							//var/obj/items/Obsidian/J = locate() in M.contents
							//var/obj/items/Rock/J1 = locate() in M.contents
							//var/obj/items/UeikThorn/J2 = locate() in M.contents
							//var/dice = "1d4"
							//var/R = roll(dice)
							if("Obsidian")
								if(J in M.contents)
									if(("Obsidian") && (J.name == "Obsidian"))
										for(J in M.contents)
											//M<<"You need Obsidian to continue..."
										//	return	//var/random/R = rand(1,5)

											if(R>=3)
												M<<"You start to affix the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch..."
												J.RemoveFromStack(1)
												Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
													//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='Obsidian'>Obsidian to the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Haunch and create an <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife."
												M.contents += new /obj/items/tools/ObsidianKnife(M)
												//del src
												Carving=0
												S.RemoveFromStack(1)
												return
											else
												if(R<=2)
													M<<"You start to affix the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch..."
													J.RemoveFromStack(1)
													S.RemoveFromStack(1)
													Carving=1		//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(5)
													//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"The materials fail at combining and are lost in the process."
													Carving=0
													return
								else
									M<<"You need \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='Obsidian'>Obsidian to continue..."
									return

							if("Rock")
								if(J1 in M.contents)
									if(("Rock") && (J1.name == "Rock"))
										for(J1 in M.contents)
										//	M<<"You need Rock to continue..."
										//	return		//var/random/R = rand(1,5)
											if(R>=3)
												M<<"You start to affix the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch..."
												J1.RemoveFromStack(1)
												//S.RemoveFromStack(1)
												Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												sleep(15)
														//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
												M<<"You finish combining the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='rock'>Rock to the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Haunch and create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'>Stone Hammer."
												M.contents += new /obj/items/tools/StoneHammer(M)
													//del src
												Carving=0
												S.RemoveFromStack(1)
												return
											else
												if(R<=2)
													M<<"You start to affix the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch..."
													J1.RemoveFromStack(1)
													//S.RemoveFromStack(1)
													Carving=1		//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(5)
														//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"The materials fail at combining and are lost in the process."
													//crankexp +?
													Carving=0
													S.RemoveFromStack(1)
													return
								else
									M<<"You need a \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='rock'>Rock to continue..."
									return
							else
								if("Ueik Thorn")
									if(J2 in M.contents)
										if(("Ueik Thorn") && (J2.name == "Ueik Thorn"))
											for(J2 in M.contents)
												//M<<"You need Ueik Thorn to continue..."
												//return			//var/random/R = rand(1,5)
												if(R>=3)
													M<<"You start to affix the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch..."
													J2.RemoveFromStack(1)
													//S.RemoveFromStack(1)
													Carving=1//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													sleep(15)
															//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
													M<<"You finish combining the \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikThorn'>Thorn to the <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Haunch and create a <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe."
													M.contents += new /obj/items/tools/UeikPickaxe(M)
																//del src
													Carving=0
													S.RemoveFromStack(1)
													return
												else
													if(R<=2)
														M<<"You start to affix the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Wooden Haunch..."
														J2.RemoveFromStack(1)
														//S.RemoveFromStack(1)
														Carving=1	//src.overlays += icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
														sleep(5)
														M<<"The materials fail at combining and are lost in the process."
														//del src	//src.overlays -= icon(icon='dmi/64/inven.dmi', icon_state="GiuMeat")
														Carving=0
														S.RemoveFromStack(1)
														return
									else
										M<<"You need \  <IMG CLASS=icon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikThorn'>Ueik Thorn to continue..."
										return
		Lockpick
			name = "Lockpick"
			icon_state = "Lockpick"
			description = "<b>Used on Doors to permit entrance"
			Worth = 10
			can_stack = TRUE
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Lockpick:</b>  Utilize to gain entry into secured areas."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		DoorKey
			icon_state = "Key"
			name = "Key"
			description = "<b>Used to lock or unlock Doors"
			Worth = 1
			can_stack = TRUE
			buildingowner = ""
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Door Key:</b>  Unlocks locked doors for the building owner."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		//Clay
		//	name = "Clay"
		//	icon_state = "Clay"
		//	description = "<b>Used with Fire to make Pottery"
		//	Worth = 100

		GiuHide
			name = "Giu Hide"
			icon_state = "GiuHide"
			Worth = 7
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Giu Hide</b> Odd Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Giu Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Giu'>Giu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GouHide
			name = "Gou Hide"
			icon_state = "GouHide"
			Worth = 14
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gou Hide</b> Different Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gou Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gou'>Gou."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowHide
			name = "Gow Hide"
			icon_state = "GowHide"
			Worth = 21
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gow Hide</b> Weird Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gow Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gow'>Gow."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GuwiHide
			name = "Guwi Hide"
			icon_state = "GuwiHide"
			Worth = 24
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Guwi Hide</b> Strange Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Guwi Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Guwi'>Guwi."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowuHide
			name = "Gowu Hide"
			icon_state = "GowuHide"
			Worth = 33
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gowu Hide</b> Mysterious Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowu Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gowu'>Gowu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GiuwoHide
			name = "Giuwo Hide"
			icon_state = "GiuwoHide"
			Worth = 42
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Giuwo Hide</b> Mysterious Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Giuwo Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Giuwo'>Giuwo."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GouwoHide
			name = "Gouwo Hide"
			icon_state = "GouwoHide"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gouwo Hide</b> Mysterious Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gouwu Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gouwu'>Gouwu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowwiHide
			name = "Gowwi Hide"
			icon_state = "GowwiHide"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gowwi Hide</b> Mysterious Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowwi Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gowwi'>Gowwi."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GuwwiHide
			name = "Guwwi Hide"
			icon_state = "GuwwiHide"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Guwwi Hide</b> Mysterious Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Guwwi Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Guwwi'>Guwwi."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowwuHide
			name = "Gowwu Hide"
			icon_state = "GowwuHide"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gowwu Hide</b> Mysterious Hide that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowwu Hide:</b>  The hide of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gowwu'>Gowwu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GiuShell
			name = "Giu Shell"
			icon_state = "GiuShell"
			Worth = 7
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Giu Shell</b> Odd shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Giu Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Giu'>Giu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GouShell
			name = "Gou Shell"
			icon_state = "GouShell"
			Worth = 14
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gou Shell</b> Different shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gou Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gou'>Gou."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowShell
			name = "Gow Shell"
			icon_state = "GowShell"
			Worth = 21
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gow Shell</b> Weird shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gow Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gow'>Gow."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GuwiShell
			name = "Guwi Shell"
			icon_state = "GuwiShell"
			Worth = 24
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Guwi Shell</b> Strange shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Guwi Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Guwi'>Guwi."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowuShell
			name = "Gowu Shell"
			icon_state = "GowuShell"
			Worth = 33
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gowu Shell</b> Mysterious shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowu Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gowu'>Gowu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GiuwoShell
			name = "Giuwo Shell"
			icon_state = "GiuwoShell"
			Worth = 42
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Giuwo Shell</b> Mysterious shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Giuwo Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Giuwo'>Giuwo."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GouwoShell
			name = "Gouwo Shell"
			icon_state = "GouwoShell"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gouwo Shell</b> Mysterious shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gouwo Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gouwo'>Gouwo."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowwiShell
			name = "Gowwi Shell"
			icon_state = "GowwiShell"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gowwi Shell</b> Mysterious shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowwi Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gowwi'>Gowwi."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GuwwiShell
			name = "Guwwi Shell"
			icon_state = "GuwwiShell"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Guwwi Shell</b> Mysterious shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Guwwi Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Guwwi'>Guwwi."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		GowwuShell
			name = "Gowwu Shell"
			icon_state = "GowwuShell"
			Worth = 62
			can_stack = TRUE
			//var/stack = 1
			description = "<b>Gowwu Shell</b> Mysterious shell that can be used for creating Armor."
			verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowwu Shell:</b>  The shell of a <IMG CLASS=icon SRC=\ref'dmi/64/ene.dmi' ICONSTATE='Gowwu'>Gowwu."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
				return
		Food
			food = 1
			//stack = 1
			plane = 5
			can_stack = TRUE
			trout
				name = "Trout"
				icon_state = "trout"
				Worth = 67
				//can_stack = TRUE
				food = 1
				//var/stack = 1
				description = "<b>Trout</b> Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Trout:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,70)
			salmon
				name = "Salmon"
				icon_state = "salmon"
				Worth = 87
				food = 1
				//var/stack = 1
				description = "<b>Salmon</b>Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Salmon:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,90)
			perch
				name = "Perch"
				icon_state = "perch"
				Worth = 27
				food = 1
				//var/stack = 1
				description = "<b>Perch</b>Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Perch:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
			//	verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,20)
			bass
				name = "Bass"
				icon_state = "bass"
				Worth = 57
				food = 1
				//var/stack = 1
				description = "<b>Bass</b>Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Bass:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,50)
			catfish
				name = "Catfish"
				icon_state = "catfish"
				Worth = 47
				food = 1
				//var/stack = 1
				description = "<b>Catfish</b>Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Catfish:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,40)
			carp
				name = "Carp"
				icon_state = "carp"
				Worth = 37
				food = 1
				//var/stack = 1
				description = "<b>Carp</b>Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Carp:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,30)
			sunfish
				name = "Sunfish"
				icon_state = "sunfish"
				Worth = 7
				food = 1
				//var/stack = 1
				description = "<b>Sunfish</b>Must Be Cooked to be eaten"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Sunfish:</b>  A fish, may be cooked and eaten to regain health. [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//verb/Use()
				//	set category = "Commands"
				//	set src in usr
				//	usingheal(src,10)
			GiuMeat
				name = "Giu Meat"
				icon_state = "GiuMeat"
				Worth = 7
				can_stack = TRUE
				plane = 6
				//var/stack = 1
				description = "<b>Giu Meat:</b> Odd meat that can be eaten raw or cooked for better quality; Restores 20 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Giu Meat:</b>  Odd meat that can be cooked or eaten raw; Restores 20 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,20)
					//stack -= 1
			GouMeat
				name = "Gou Meat"
				icon_state = "GouMeat"
				Worth = 14
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Gou Meat</b> Different meat that can be eaten raw or cooked for better quality; Restores 30 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gou Meat:</b>  Different meat that can be cooked or eaten raw; Restores 30 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,30)
			GowMeat
				name = "Gow Meat"
				icon = 'dmi/64/inven.dmi'
				icon_state = "GowMeat"
				Worth = 21
				can_stack = TRUE
				plane = 4
				//var/stack = 1
				description = "<b>Gow Meat</b> Weird meat that can be eaten raw or cooked for better quality; Restores 40 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gow Meat:</b>  Weird meat that can be cooked or eaten raw; Restores 40 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,40)
			GuwiMeat
				name = "Guwi Meat"
				icon_state = "GuwiMeat"
				Worth = 24
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Guwi Meat</b> Strange meat that can be eaten raw or cooked for better quality; Restores 50 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Guwi Meat:</b>  Strange meat that can be cooked or eaten raw; Restores 50 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,50)
			GowuMeat
				name = "Gowu Meat"
				icon_state = "GowuMeat"
				Worth = 33
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Gowu Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 60 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowu Meat:</b>  Mysterious meat that can be cooked or eaten raw; Restores 60 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,60)
			GiuwoMeat
				name = "Giuwo Meat"
				icon_state = "GiuwoMeat"
				Worth = 33
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Giuwo Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 80 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Giuwo Meat:</b>  Mysterious meat that can be cooked or eaten raw; Restores 80 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,80)
			GouwoMeat
				name = "Gouwo Meat"
				icon_state = "GouwoMeat"
				Worth = 33
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Gouwo Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 120 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gouwo Meat:</b>  Mysterious meat that can be cooked or eaten raw; Restores 120 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,120)
			GowwiMeat
				name = "Gowwi Meat"
				icon_state = "GowwiMeat"
				Worth = 42
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Gowwi Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 180 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowwi Meat:</b>  Mysterious meat that can be cooked or eaten raw; Restores 180 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,180)
			GuwwiMeat
				name = "Guwwi Meat"
				icon_state = "GuwwiMeat"
				Worth = 54
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Guwwi Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 213 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Guwwi Meat:</b>  Mysterious meat that can be cooked or eaten raw; Restores 213 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,213)
			GowwuMeat
				name = "Gowwu Meat"
				icon_state = "GowwuMeat"
				Worth = 64
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Gowwu Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 264 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Gowwu Meat:</b>  Mysterious meat that can be cooked or eaten raw; Restores 264 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,264)
			troutC
				name = "Cooked Trout"
				icon_state = "cookedtrout"
				Worth = 67
				can_stack = TRUE
				food = 1
				//var/stack = 1
				description = "<b>Cooked Trout</b>  Restores 80 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Trout:</b>  Fish that has been cooked; Restores 80 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,80)
			salmonC
				name = "Cooked Salmon"
				icon_state = "cookedsalmon"
				Worth = 87
				food = 1
				//var/stack = 1
				description = "<b>Cooked Salmon</b>  Restores 100 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Salmon:</b>  Fish that has been cooked; Restores 100 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,100)
			perchC
				name = "Cooked Perch"
				icon_state = "cookedperch"
				Worth = 27
				food = 1
				//var/stack = 1
				description = "<b>Cooked Perch</b>  Restores 30 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Perch:</b>  Fish that has been cooked; Restores 30 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,30)
			bassC
				name = "Cooked Bass"
				icon_state = "cookedbass"
				Worth = 57
				food = 1
				//var/stack = 1
				description = "<b>Cooked Bass</b>  Restores 60 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Bass:</b>  Fish that has been cooked; Restores 60 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,60)
			catfishC
				name = "Cooked Catfish"
				icon_state = "cookedcatfish"
				Worth = 47
				food = 1
				//var/stack = 1
				description = "<b>Cooked Catfish</b>  Restores 50 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Catfish:</b>  Fish that has been cooked; Restores 50 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,50)
			carpC
				name = "Cooked Carp"
				icon_state = "cookedcarp"
				Worth = 37
				food = 1
				//var/stack = 1
				description = "<b>Cooked Carp</b>  Restores 40 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Carp:</b>  Fish that has been cooked; Restores 40 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,40)
			sunfishC
				name = "Cooked Sunfish"
				icon_state = "cookedsunfish"
				Worth = 7
				food = 1
				//plane = 5
				//var/stack = 1
				description = "<b>Cooked Sunfish</b>  Restores 20 HP"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Sunfish:</b>  Fish that has been cooked; Restores 20 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,20)
			GiuMeatC
				name = "Cooked Giu Meat"
				icon_state = "CookedGiuMeat"
				Worth = 7
				plane = 6
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Cooked Giu Meat</b> Odd meat that can be eaten raw or cooked for better quality; Restores 40 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Giu Meat:</b>  Odd meat that has been cooked; Restores 40 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,40)
					//stack -= 1
			GouMeatC
				name = "Cooked Gou Meat"
				icon_state = "CookedGouMeat"
				Worth = 14
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Cooked Gou Meat</b> Different meat that can be eaten raw or cooked for better quality; Restores 60 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Gou Meat:</b>  Different meat that has been cooked; Restores 60 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,60)
			GowMeatC
				name = "Cooked Gow Meat"
				icon_state = "CookedGowMeat"
				Worth = 21
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Cooked Gow Meat</b> Weird meat that can be eaten raw or cooked for better quality; Restores 80 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Gow Meat:</b>  Weird meat that has been cooked; Restores 80 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,80)
			GuwiMeatC
				name = "Cooked Guwi Meat"
				icon_state = "CookedGuwiMeat"
				Worth = 24
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Cooked Guwi Meat</b> Strange meat that can be eaten raw or cooked for better quality; Restores 100 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Guwi Meat:</b>  Strange meat that has been cooked; Restores 100 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,100)
			GowuMeatC
				name = "Cooked Gowu Meat"
				icon_state = "CookedGowuMeat"
				Worth = 33
				can_stack = TRUE
				//var/stack = 1
				description = "<b>Cooked Gowu Meat</b> Mysterious meat can be eaten raw or cooked for better quality; Restores 120 Health."
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Cooked Gowu Meat:</b>  Mysterious meat that has been cooked; Restores 120 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,120)
			OCM
				name = "Overcooked Meat"
				icon='dmi/64/inven.dmi'
				icon_state="OCM"
				Worth = 1
				plane = 6
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Overcooked Meat:</b>  Used to lure creatures."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				//var/stack = 1
		Tonics
			antitoxin
				name = "Antitoxin"
				icon_state = "antitoxin"
				Worth = 150
				description = "<b>Antitoxin</b>  Relieves Acid"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Antitoxin:</b>  Relieves <IMG CLASS=icon SRC=\ref'dmi/64/magi.dmi' ICONSTATE='acid' ICONFRAME=10>Acid."
					return
				verb/Use()
					set category = null
					set src in usr
					var/mob/players/P = usr
					P.poisonD=0
					P.poisoned=0
					P.poisonDMG=0
					P.overlays = null
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>You used an Antitoxin; <b> Acid removed."
					Del(src)
			strngantitoxin
				name = "Strong Antitoxin"
				icon_state = "strngantitoxin"
				Worth = 150
				can_stack = TRUE
				description = "<b>Strong Antitoxin</b>  Relieves Acid and Restores 100 HP"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Strong Antitoxin:</b>  Relieves <IMG CLASS=icon SRC=\ref'dmi/64/magi.dmi' ICONSTATE='acid' ICONFRAME=10>Acid and Restores 100 HP."
					return
				verb/Use()
					set category = null
					set src in usr
					var/mob/players/P = usr
					P.poisonD=0
					P.poisoned=0
					P.poisonDMG=0
					P.overlays = null
					usingheal()
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> You used a Strong Antitoxin; <b> <IMG CLASS=icon SRC=\ref'dmi/64/magi.dmi' ICONSTATE='acid' ICONFRAME=10>Acid removed."
					Del(src)
			vitaevial
				items = 1
				name = "Vitae Vial"
				icon_state = "vitvial"
				Worth = 42
				//var/stack = 1
				can_stack = TRUE
				description = "<b>Vitae Vial</b>  Recovers up to 40 Health"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Vitae Vial:</b>  A weak potion; Recovers 40 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingheal(src,40)
					//stack -= 1
			energytonic
				items = 1
				name = "Energy Tonic"
				icon_state = "enertonic"
				Worth = 33
				//var/stack = 1
				can_stack = TRUE
				description = "<b>Energy Tonic</b>  Recovers up to 33 Energy"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Energy Tonic:</b>  A weak tonic; Recovers 33 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category=null
					set popup_menu=1
					set src in usr
					usingmana(src,33)
			largevitaevial
				name = "Large Vitae Vial"
				icon_state = "lrgvitvial"
				Worth = 59
				//var/stack = 1
				can_stack = TRUE
				description = "<b>Large Vitae Vial</b>  Recovers up to 64 Health"
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Large Vitae Vial:</b>  Large vial of a weak potion; Recovers 64 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingheal(src,64)
			strongenergytonic
				name = "Strong Energy Tonic"
				icon_state = "strngenertonic"
				Worth = 64
				//var/stack = 1
				description = "<b>Strong Energy Tonic</b>  Recovers up to 42 Energy"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Strong Energy Tonic:</b>  A strong tonic; Recovers 64 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingmana(src,64)
			vitaeliniments
				name = "Vitae Liniments"
				icon_state = "vitaeliniments"
				Worth = 88
				//var/stack = 1
				description = "<b>Healing Tonic</b>  Recovers up to 84 Health"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Vitae Liniments:</b>  Healing leaves of a vitae plant; Recovers 84 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingheal(src,84)
			energyspirits
				name = "Energy Spirits"
				icon_state = "enerspiri"
				Worth = 93
				//var/stack = 1
				description = "<b>Magi Spirits</b>  Recovers up to 84 Energy"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Magi Spirits:</b>  Energy healing spirits; Recovers 84 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					usingmana(src,84)
			qualityvitaeliniments
				name = "Quality Vitae Liniments"
				icon_state = "quavitlin"
				Worth = 118
				//var/stack = 1
				description = "<b>Quality Vitae Liniments</b>  Recovers up to 113 Health"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Quality Vitae Liniments:</b>  Healing leaves of a vitae plant; Recovers 113 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingheal(src,113)
			strongenergyspirits
				name = "Strong Energy Spirits"
				icon_state = "strngenerspiri"
				Worth = 124
				//var/stack = 1
				description = "<b>Strong Energy Spirits</b>  Recovers up to 104 Energy"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Strong Energy Spirits:</b>  Energy healing spirits with a kick; Recovers 104 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingmana(src,104)
			vitaecurative
				name = "Vitae Curative"
				icon_state = "vitcur"
				Worth = 190
				//var/stack = 1
				description = "<b>Vitae Curative</b>  Recovers up to 184 Health"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Vitae Curative:</b> Recovers 184 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingheal(src,184)
			energyrestorative
				name = "Energy Restorative"
				icon_state = "enerrestora"
				Worth = 204
				//var/stack = 1
				description = "<b>Energy Restorative</b>  Recovers up to 168 Energy"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Energy Restorative:</b> Recovers 168 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					usingmana(src,168)
			qualityvitaecurative
				name = "Quality Vitae Curative"
				icon_state = "qualvitcur"
				Worth = 313
				//var/stack = 1
				description = "<b>Quality Vitae Curative</b>  Recovers up to 264 Health"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Quality Vitae Curative:</b> Recovers 264 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingheal(src,264)
			strongenergyrestorative
				name = "Strong Energy Restorative"
				icon_state = "strngenerrestor"
				Worth = 324
				//var/stack = 1
				description = "<b>Strong Energy Restorative</b>  Recovers up to 224 Energy"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Strong Energy Restorative:</b> Recovers 224 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingmana(src,224)
			concentratedvitaecurative
				name = "Concentrated Vitae Curative"
				icon_state = "cvc"
				Worth = 420
				//var/stack = 1
				description = "<b>Vitae Curative Concentrate</b>  Recovers up to 464 Health"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Concentrated Vitae Curative:</b> Recovers 464 Health."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingheal(src,464)
			stronglargeenergyrestorative
				name = "Strong Energy Restorative"
				icon_state = "strnglrgenerrestor"
				Worth = 444
				//var/stack = 1
				description = "<b>Strong Large Energy Restorative</b>  Recovers up to 324 Energy"
				can_stack = TRUE
				verb/Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'> <b>Strong Large Energy Restorative:</b> Recovers 324 Energy."//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				verb/Use()
					set category = null
					set popup_menu=1
					set src in usr
					usingmana(src,324)
/*	shields
		//yeah, this gets pretty wild
		icon = 'dmi/64/armor.dmi'
		var
			//these first vars are for the description of the item
			adds = ""
			adds2 = ""
			of = ""
			adj = ""
			color = ""
			add = 0
			add2 = 0
			description = ""
			typi = ""
			olditem = 0
			//these vars are for actual variables on the items that affect gameplay
			strreq = 0
			Adefense
			Aevade
			STRbonus = 0
			SPRTbonus = 0
			HEALTHbonus = 0
			ENERGYbonus = 0
			FIREres = 0
			ICEres = 0
			WINDres = 0
			WATres = 0
			EARTHres = 0
			HEATbonus = 0
			SHARDBURSTbonus = 0
			WATbonus = 0
			VITAEbonus = 0
			ACIDbonus = 0
			BLUDGEONbonus = 0
			FLAMEbonus = 0
			ICESTORMbonus = 0
			CASCADELIGHTNINGbonus = 0
			COSMOSbonus = 0
			REPHASEbonus = 0
			QUIETUSbonus = 0
			wlvl
	armors
		//yeah, this gets pretty wild
		icon = 'dmi/64/armor.dmi'
		var
			//these first vars are for the description of the item
			adds = ""
			adds2 = ""
			of = ""
			adj = ""
			color = ""
			add = 0
			add2 = 0
			description = ""
			typi = ""
			olditem = 0
			//these vars are for actual variables on the items that affect gameplay
			strreq = 0
			Adefense
			Aevade
			STRbonus = 0
			SPRTbonus = 0
			HEALTHbonus = 0
			ENERGYbonus = 0
			FIREres = 0
			ICEres = 0
			WINDres = 0
			WATres = 0
			EARTHres = 0
			HEATbonus = 0
			SHARDBURSTbonus = 0
			WATbonus = 0
			VITAEbonus = 0
			ACIDbonus = 0
			BLUDGEONbonus = 0
			FLAMEbonus = 0
			ICESTORMbonus = 0
			CASCADELIGHTNINGbonus = 0
			COSMOSbonus = 0
			REPHASEbonus = 0
			QUIETUSbonus = 0
			wlvl*/
		weapons
			//yeah, this gets pretty wild
			icon = 'dmi/64/weaps.dmi'

			var
				//these first vars are for the description of the item
				adds = ""
				adds2 = ""
				of = ""
				adj = ""
				add = 0
				add2 = 0
				//description = ""
				typi = ""
				olditem = 0
				//these vars are for actual variables on the items that affect gameplay
				twohanded = 0
				strreq = 0
				Adefense
				Aevade
				wpnspd = 0
				DamageMin = 0
				DamageMax = 0
				STRbonus = 0
				SPRTbonus = 0
				HEALTHbonus = 0
				ENERGYbonus = 0
				FIREres = 0
				ICEres = 0
				WINDres = 0
				WATres = 0
				EARTHres = 0
				HEATbonus = 0
				SHARDBURSTbonus = 0
				WATbonus = 0
				VITAEbonus = 0
				ACIDbonus = 0
				BLUDGEONbonus = 0
				FLAMEbonus = 0
				ICESTORMbonus = 0
				CASCADELIGHTNINGbonus = 0
				COSMOSbonus = 0
				REPHASEbonus = 0
				QUIETUSbonus = 0
				wlvl
				rarity = ""
			verb
				Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
				/*Get()
					set category=null
					set popup_menu=1
					set src in oview(1)
					//set hidden = 1
					var/mob/players/M = usr
					if(src.type==/obj/items/questitem)
						var/C=0
						var/obj/items/o
						if(M.quest==0)
							for(o as obj in M.contents)
								if(o.type==/obj/items/questitem&&C==0)
									C=1
									return
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
									return
							if(C==0)
								src.Move(usr, 1)
								return
						else
							M << "You don't need that"
							return
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.Move(usr, 1)
								return
				Drop()
					set category=null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "<font color = teal>Un-equip [src] first!"
						return
					else
						src.Move(usr.loc, 1)
						return*/
			New() //this is the whacked out logic that controls creating random items, this is pretty cool, this function is fired for magic items
				..()
				if(usr!=null)
					src.Worth*=2 // magic items sell for twice as much
					//lots of switches and random number generations in order to pick based on weapon level (wlvl) and probabilities
					var
						A;B;C;
					A = rand(1,3)
					if(A==1||A==2)
						C = rand(1,3)
						if(C == 1)
							color = "red"
						if(C == 2)
							color = "blue"
						if(C == 3)
							color = "yellow"
						icon_state = "[icon_state]"
						if(color=="red")
							var/D = rand(1,2)
							switch(D)
								if(1)
									switch(wlvl)
										if(1)
											add = rand(1,5)
											src.of = " of Sinew"
										if(2)
											add = rand(6,10)
											src.of = " of Brawn"
										if(3)
											add = rand(11,15)
											src.of = " of Skill"
										if(4)
											add = rand(16,20)
											src.of = " of Vehemence"
										if(5)
											add = rand(21,25)
											src.of = " of Force"
									src.adds = ", +[add] Strength"
									src.STRbonus = add
								if(2)
									switch(wlvl)
										if(1)
											add = rand(1,4)
											src.of = " of Heat"
											src.adds = ", +[add] Heat"
											src.HEATbonus = add
										if(2)
											add = rand(5,8)
											src.of = " of Heat"
											src.adds = ", +[add] Heat"
											src.HEATbonus = add
										if(3)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(9,16)
													src.of = " of Heat"
													src.adds = ", +[add] Heat"
													src.HEATbonus = add
												if(2)
													add = rand(5,8)
													src.of = " of Flame"
													src.adds = ", +[add] Flame"
													src.FLAMEbonus = add
										if(4)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(17,32)
													src.of = " of Heat"
													src.adds = ", +[add] Heat"
													src.HEATbonus = add
												if(2)
													add = rand(9,16)
													src.of = " of Flame"
													src.adds = ", +[add] Flame"
													src.FLAMEbonus = add
										if(5)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(33,64)
													src.of = " of Heat"
													src.adds = ", +[add] Heat"
													src.HEATbonus = add
												if(2)
													add = rand(17,32)
													src.of = " of Flame"
													src.adds = ", +[add] Flame"
													src.FLAMEbonus = add
						else if(color=="blue")
							var/D = rand(1,2)
							switch(D)
								if(1)
									switch(wlvl)
										if(1)
											add = rand(1,5)
											src.of = " of Psyche"
										if(2)
											add = rand(6,10)
											src.of = " of The Architect"
										if(3)
											add = rand(11,15)
											src.of = " of Tutelage"
										if(4)
											add = rand(16,20)
											src.of = " of Bodhi"
										if(5)
											add = rand(21,25)
											src.of = " of Insight"
									src.adds = ", +[add] Energy"
									src.SPRTbonus = add
								if(2)
									switch(wlvl)
										if(1)
											add = rand(1,4)
											src.of = " of ShardBurst"
											src.adds = ", +[add] ShardBurst"
											src.SHARDBURSTbonus = add
										if(2)
											add = rand(5,8)
											src.of = " of IceStorm"
											src.adds = ", +[add] IceStorm"
											src.SHARDBURSTbonus = add
										if(3)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(9,16)
													src.of = " of ShardBurst"
													src.adds = ", +[add] ShardBurst"
													src.SHARDBURSTbonus = add
												if(2)
													add = rand(5,8)
													src.of = " of IceStorm"
													src.adds = ", +[add] IceStorm"
													src.ICESTORMbonus = add
										if(4)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(17,32)
													src.of = " of ShardBurst"
													src.adds = ", +[add] ShardBurst"
													src.SHARDBURSTbonus = add
												if(2)
													add = rand(9,16)
													src.of = " of IceStorm"
													src.adds = ", +[add] IceStorm"
													src.ICESTORMbonus = add
										if(5)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(33,64)
													src.of = " of ShardBurst"
													src.adds = ", +[add] ShardBurst"
													src.SHARDBURSTbonus = add
												if(2)
													add = rand(17,32)
													src.of = " of IceStorm"
													src.adds = ", +[add] IceStorm"
													src.ICESTORMbonus = add
						else if(color=="yellow")
							var/D = rand(1,2)
							switch(D)
								if(1)
									switch(wlvl)
										if(1)
											add = rand(1,4)
											src.of = " of Lucent"
										if(2)
											add = rand(5,8)
											src.of = " of Aurora"
										if(3)
											add = rand(9,12)
											src.of = " of Blaze"
										if(4)
											add = rand(16,20)
											src.of = " of Darkness"
										if(5)
											add = rand(21,25)
											src.of = " of Obscurity"
									src.adds = ", +[add] energy, +[add] Strength"
									src.STRbonus = add
									src.SPRTbonus = add
								if(2)
									switch(wlvl)
										if(1)
											add = rand(1,4)
											src.of = " of WaterShock"
											src.adds = ", +[add] WaterShock"
											src.WATbonus = add
										if(2)
											add = rand(5,8)
											src.of = " of CascadeLightning"
											src.adds = ", +[add] CascadeLightning"
											src.WATbonus = add
										if(3)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(9,16)
													src.of = " of WaterShock"
													src.adds = ", +[add] WaterShock"
													src.WATbonus = add
												if(2)
													add = rand(5,8)
													src.of = " of CascadeLightning"
													src.adds = ", +[add] CascadeLightning"
													src.CASCADELIGHTNINGbonus = add
										if(4)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(17,32)
													src.of = " of WaterShock"
													src.adds = ", +[add] WaterShock"
													src.WATbonus = add
												if(2)
													add = rand(9,16)
													src.of = " of CascadeLightning"
													src.adds = ", +[add] CascadeLightning"
													src.CASCADELIGHTNINGbonus = add
										if(5)
											var/F = rand(1,2)
											switch(F)
												if(1)
													add = rand(33,64)
													src.of = " of WaterShock"
													src.adds = ", +[add] WaterShock"
													src.WATbonus = add
												if(2)
													add = rand(17,32)
													src.of = " of CascadeLightning"
													src.adds = ", +[add] CascadeLightning"
													src.CASCADELIGHTNINGbonus = add
					if(A==2||A==3)
						var/D = rand(1,2)
						switch(D)
							if(1)
								B = rand(1,6)
								switch(B)
									if(1)
										switch(wlvl)
											if(1)
												add2 = rand(1,14)
												adj = "Crimson "
											if(2)
												add2 = rand(15,28)
												adj = "Scarlet "
											if(3)
												add2 = rand(29,32)
												adj = "Garnet "
											if(4)
												add2 = rand(33,46)
												adj = "Rufescent "
											if(5)
												add2 = rand(47,50)
												adj = "Titian "
										src.adds2 = ", +[add2] Fire Proof"
										src.FIREres = add2
									if(2)
										switch(wlvl)
											if(1)
												add2 = rand(1,14)
												adj = "Beryl "
											if(2)
												add2 = rand(15,28)
												adj = "Cerulean "
											if(3)
												add2 = rand(29,32)
												adj = "Cobalt "
											if(4)
												add2 = rand(33,46)
												adj = "Royal "
											if(5)
												add2 = rand(47,50)
												adj = "Azure "
										src.adds2 = ", +[add2] Ice Proof"
										src.ICEres = add2
									if(3)
										switch(wlvl)
											if(1)
												add2 = rand(1,14)
												adj = "Aurous "
											if(2)
												add2 = rand(15,28)
												adj = "Xanthos "
											if(3)
												add2 = rand(29,32)
												adj = "Sorrel "
											if(4)
												add2 = rand(33,46)
												adj = "Halcyon "
											if(5)
												add2 = rand(47,50)
												adj = "Aureate "
										src.adds2 = ", +[add2] Water Proof"
										src.WINDres = add2
									if(4)
										switch(wlvl)
											if(1)
												add2 = rand(1,14)
												adj = "Malachite "
											if(2)
												add2 = rand(15,28)
												adj = "Aquamarine "
											if(3)
												add2 = rand(29,32)
												adj = "Viridian "
											if(4)
												add2 = rand(33,46)
												adj = "Verdigris "
											if(5)
												add2 = rand(47,50)
												adj = "Jade "
										src.adds2 = ", +[add2] Acid Proof"
										src.WATres = add2
									if(5)
										switch(wlvl)
											if(1)
												add2 = rand(1,14)
												adj = "Scoriac "
											if(2)
												add2 = rand(15,28)
												adj = "Sable "
											if(3)
												add2 = rand(29,32)
												adj = "Stygian "
											if(4)
												add2 = rand(33,46)
												adj = "Obsidian "
											if(5)
												add2 = rand(47,50)
												adj = "Atramentous "
										src.adds2 = ", +[add2] Earth Proof"
										src.EARTHres = add2
									if(6)
										switch(wlvl)
											if(1)
												add2 = rand(1,14)
												adj = "Lambent "
											if(2)
												add2 = rand(15,28)
												adj = "Fulgent "
											if(3)
												add2 = rand(29,32)
												adj = "Luminous "
											if(4)
												add2 = rand(33,46)
												adj = "Radiant "
											if(5)
												add2 = rand(47,50)
												adj = "Scintillating "
										src.adds2 = ", +[add2] Omni-Proof"
										src.FIREres = add2
										src.ICEres = add2
										src.WINDres = add2
										src.WATres = add2
										src.EARTHres = add2
							if(2)
								var/E = rand(1,2)
								switch(E)
									if(1)
										switch(wlvl)
											if(1)
												add2 = rand(12,40)
												adj = "Rabbit's "
											if(2)
												add2 = rand(42,120)
												adj = "Wolve's "
											if(3)
												add2 = rand(84,180)
												adj = "Cougar's "
											if(4)
												add2 = rand(200,420)
												adj = "Buffalo's "
											if(5)
												add2 = rand(333,945)
												adj = "Lion's "
										src.adds2 = ", +[add2] HP"
										src.HEALTHbonus = add2
									if(2)
										switch(wlvl)
											if(1)
												add2 = rand(12,30)
												adj = "Viper's "
											if(2)
												add2 = rand(31,80)
												adj = "Basilisk's "
											if(3)
												add2 = rand(81,150)
												adj = "Asp's "
											if(4)
												add2 = rand(151,300)
												adj = "Hydra's "
											if(5)
												add2 = rand(301,800)
												adj = "Tarragon's "
										src.adds2 = ", +[add2] Energy"
										src.ENERGYbonus = add2

						src.adj = "[adj]"
					src.name = "[adj][name][src.of]"
					if (typi=="weapon"&&twohanded==0)//								probably need to confirm this is working as intended with the graphics in description
						src.description = "<font color = #4682b4><center><b>[src.name]:</b><br>[src.DamageMin]-[src.DamageMax] Damage<br>[adds]<br>[adds2]<br>[src.strreq] Strength-Req<br>Worth: [src.Worth]"
					else if (typi=="weapon"&&twohanded==1)
						src.description = "<font color = #4682b4><center><b>[src.name]:</b><br>[src.DamageMin]-[src.DamageMax] Damage<br>Two-hands<br>[adds]<br>[adds2]<br>[src.strreq] Strength-Req<br>Worth: [src.Worth]"
					else if (typi=="armor")
						src.description = "<font color = #4682b4><center><b>[src.name]:</b><br>[Adefense] Defense<br>[Aevade]% Evasion<br>[adds]<br>[adds2]<br>[src.strreq] Strength-Req<br>Worth: [src.Worth]"
					else if (typi=="shield")
						src.description = "<font color = #4682b4><center><b>[src.name]:</b><br>[Adefense] Defense<br>[Aevade]% Evasion<br>[adds]<br>[adds2]<br>[src.strreq] Strength-Req<br>Worth: [src.Worth]"

					//world << "[src.STRbonus] STR [src.SPRTbonus] INT [src.FIREres] FIRE [src.ICEres] ICE [src.WINDres] LIT [src.WATres] POIS [src.EARTHres] DARK"
			//verbs to get items, description, equipping, etc on right click
			//the way i handled the equipping and changing of variables is a little whacked out, i don't like it much, but here it is
			/*verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << src.description*/

			Click()
				set src in usr
				if(src.suffix=="Equipped")
					usr << "<font color = teal>That's already equipped!"
				else
					if ((typi=="weapon")&&(twohanded==0))
						if (usr.tempstr>=src.strreq)
							if(usr.Wequipped==0)
								src.suffix+="Equipped"
								usr.Wequipped = 1
								usr.tempdamagemin += src.DamageMin
								usr.tempdamagemax += src.DamageMax
								var/mob/players/M = usr
								M.attackspeed -= src.wpnspd
								M.Strength += src.STRbonus
								M.Spirit += src.SPRTbonus
								M.HP += src.HEALTHbonus
								M.energy += src.ENERGYbonus
								M.MAXHP += src.HEALTHbonus
								M.MAXenergy += src.ENERGYbonus
								M.fireres += src.FIREres
								M.iceres += src.ICEres
								M.windres += src.WINDres
								M.watres += src.WATres
								M.earthres += src.EARTHres
								M.heatlevel += src.HEATbonus
								M.shardburstlevel += src.SHARDBURSTbonus
								M.watershocklevel += src.WATbonus
								M.vitaelevel += src.VITAEbonus
								M.acidlevel += src.ACIDbonus
								M.bludgeonlevel += src.BLUDGEONbonus
								M.flamelevel += src.FLAMEbonus
								M.icestormlevel += src.ICESTORMbonus
								M.cascadelightninglevel += src.CASCADELIGHTNINGbonus
								M.cosmoslevel += src.COSMOSbonus
								M.rephaselevel += src.REPHASEbonus
								M.quietuslevel += src.QUIETUSbonus
							else
								usr << "<font color = teal>You're already holding that."
						else
							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
					if ((typi=="weapon")&&(twohanded==1))
						if (usr.tempstr>=src.strreq)
							if(usr.Wequipped==0 && usr.Sequipped==0)
								src.suffix+="Equipped"
								usr.Wequipped = 1
								usr.Sequipped = 1
								usr.tempdamagemin += src.DamageMin
								usr.tempdamagemax += src.DamageMax
								var/mob/players/M = usr
								M.attackspeed -= src.wpnspd
								M.Strength += src.STRbonus
								M.Spirit += src.SPRTbonus
								M.HP += src.HEALTHbonus
								M.energy += src.ENERGYbonus
								M.MAXHP += src.HEALTHbonus
								M.MAXenergy += src.ENERGYbonus
								M.fireres += src.FIREres
								M.iceres += src.ICEres
								M.windres += src.WINDres
								M.watres += src.WATres
								M.earthres += src.EARTHres
								M.heatlevel += src.HEATbonus
								M.shardburstlevel += src.SHARDBURSTbonus
								M.watershocklevel += src.WATbonus
								M.vitaelevel += src.VITAEbonus
								M.acidlevel += src.ACIDbonus
								M.bludgeonlevel += src.BLUDGEONbonus
								M.flamelevel += src.FLAMEbonus
								M.icestormlevel += src.ICESTORMbonus
								M.cascadelightninglevel += src.CASCADELIGHTNINGbonus
								M.cosmoslevel += src.COSMOSbonus
								M.rephaselevel += src.REPHASEbonus
								M.quietuslevel += src.QUIETUSbonus
							else
								usr << "<font color = teal>You must have both hands free to hold onto this!"
						else
							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
			verb/Unequip()
				set category = null
				set src in usr
				if(src.suffix!="Equipped")
					usr << "<font color = teal>That's not equipped!"
				else
					if (typi=="weapon" && twohanded==0)
						if(usr.Wequipped==0)
							usr << "<font color = teal>You don't have anything equipped!"
						else
							//src.verbs-=/obj/items/weapons/proc/Unequip
							//src.verbs+=/obj/items/weapons/verb/Equip
							src.suffix = ""
							usr.Wequipped = 0
							usr.tempdamagemin -= src.DamageMin
							usr.tempdamagemax -= src.DamageMax
							var/mob/players/M = usr
							if(M.char_class=="Landscaper")
								M.attackspeed = 6
							else if(M.char_class=="Builder")
								M.attackspeed = 7
							else if(M.char_class=="Magus")
								M.attackspeed = 5
							else if(M.char_class=="Defender")
								M.attackspeed = 8
							else
								M.attackspeed = 5
							M.Strength -= src.STRbonus
							M.Spirit -= src.SPRTbonus
							M.HP -= src.HEALTHbonus
							M.energy -= src.ENERGYbonus
							M.MAXHP -= src.HEALTHbonus
							M.MAXenergy -= src.ENERGYbonus
							M.fireres -= src.FIREres
							M.iceres -= src.ICEres
							M.windres -= src.WINDres
							M.watres -= src.WATres
							M.earthres -= src.EARTHres
							M.heatlevel -= src.HEATbonus
							M.shardburstlevel -= src.SHARDBURSTbonus
							M.watershocklevel -= src.WATbonus
							M.vitaelevel -= src.VITAEbonus
							M.acidlevel -= src.ACIDbonus
							M.bludgeonlevel -= src.BLUDGEONbonus
							M.flamelevel -= src.FLAMEbonus
							M.icestormlevel -= src.ICESTORMbonus
							M.cascadelightninglevel -= src.CASCADELIGHTNINGbonus
							M.cosmoslevel -= src.COSMOSbonus
							M.rephaselevel -= src.REPHASEbonus
							M.quietuslevel -= src.QUIETUSbonus
					if (typi=="weapon" && twohanded==1)
						if(usr.Wequipped==0)
							usr << "<font color = teal>You don't have anything equipped!"
						else
							src.suffix = ""
							usr.Wequipped = 0
							usr.Sequipped = 0
							usr.tempdamagemin -= src.DamageMin
							usr.tempdamagemax -= src.DamageMax
							var/mob/players/M = usr
							if(M.char_class=="Landscaper")
								M.attackspeed = 6
							else if(M.char_class=="Builder")
								M.attackspeed = 7
							else if(M.char_class=="Magus")
								M.attackspeed = 5
							else if(M.char_class=="Defender")
								M.attackspeed = 8
							else
								M.attackspeed = 5
							M.Strength -= src.STRbonus
							M.Spirit -= src.SPRTbonus
							M.HP -= src.HEALTHbonus
							M.energy -= src.ENERGYbonus
							M.MAXHP -= src.HEALTHbonus
							M.MAXenergy -= src.ENERGYbonus
							M.fireres -= src.FIREres
							M.iceres -= src.ICEres
							M.windres -= src.WINDres
							M.watres -= src.WATres
							M.earthres -= src.EARTHres
							M.heatlevel -= src.HEATbonus
							M.shardburstlevel -= src.SHARDBURSTbonus
							M.watershocklevel -= src.WATbonus
							M.vitaelevel -= src.VITAEbonus
							M.acidlevel -= src.ACIDbonus
							M.bludgeonlevel -= src.BLUDGEONbonus
							M.flamelevel -= src.FLAMEbonus
							M.icestormlevel -= src.ICESTORMbonus
							M.cascadelightninglevel -= src.CASCADELIGHTNINGbonus
							M.cosmoslevel -= src.COSMOSbonus
							M.rephaselevel -= src.REPHASEbonus
							M.quietuslevel -= src.QUIETUSbonus
					/*if (typi=="armor")
						if(usr.Aequipped==0)
							usr << "<font color = teal>You don't have anything equipped!"
						else
							src.suffix = ""
							usr.Aequipped = 0
							usr.tempdefense -= src.Adefense
							usr.tempevade -= src.Aevade
							var/mob/players/M = usr
							M.Strength -= src.STRbonus
							M.Spirit -= src.SPRTbonus
							M.HP -= src.HEALTHbonus
							M.energy -= src.ENERGYbonus
							M.MAXHP -= src.HEALTHbonus
							M.MAXenergy -= src.ENERGYbonus
							M.fireres -= src.FIREres
							M.iceres -= src.ICEres
							M.windres -= src.WINDres
							M.watres -= src.WATres
							M.earthres -= src.EARTHres
							M.heatlevel -= src.HEATbonus
							M.shardburstlevel -= src.SHARDBURSTbonus
							M.watershocklevel -= src.WATbonus
							M.vitaelevel -= src.VITAEbonus
							M.acidlevel -= src.ACIDbonus
							M.bludgeonlevel -= src.BLUDGEONbonus
							M.flamelevel -= src.FLAMEbonus
							M.icestormlevel -= src.ICESTORMbonus
							M.cascadelightninglevel -= src.CASCADELIGHTNINGbonus
							M.cosmoslevel -= src.COSMOSbonus
							M.rephaselevel -= src.REPHASEbonus
							M.quietuslevel -= src.QUIETUSbonus
					if (typi=="shield")
						if(usr.Sequipped==0)
							usr << "<font color = teal>You don't have anything equipped!"
						else
							src.suffix = ""
							usr.Sequipped = 0
							usr.tempdefense -= src.Adefense
							usr.tempevade -= src.Aevade
							var/mob/players/M = usr
							M.Strength -= src.STRbonus
							M.Spirit -= src.SPRTbonus
							M.HP -= src.HEALTHbonus
							M.energy -= src.ENERGYbonus
							M.MAXHP -= src.HEALTHbonus
							M.MAXenergy -= src.ENERGYbonus
							M.fireres -= src.FIREres
							M.iceres -= src.ICEres
							M.windres -= src.WINDres
							M.watres -= src.WATres
							M.earthres -= src.EARTHres
							M.heatlevel -= src.HEATbonus
							M.shardburstlevel -= src.SHARDBURSTbonus
							M.watershocklevel -= src.WATbonus
							M.vitaelevel -= src.VITAEbonus
							M.acidlevel -= src.ACIDbonus
							M.bludgeonlevel -= src.BLUDGEONbonus
							M.flamelevel -= src.FLAMEbonus
							M.icestormlevel -= src.ICESTORMbonus
							M.cascadelightninglevel -= src.CASCADELIGHTNINGbonus
							M.cosmoslevel -= src.COSMOSbonus
							M.rephaselevel -= src.REPHASEbonus
							M.quietuslevel -= src.QUIETUSbonus*/

	//Story Weapons Start
			//here are all the weapons
			//the magic items do not have New() commands so that they will fire my New() proc instead of the default
			//each unique's New() command is overwritten locally to give each of them its special abilities

			var
				weapon_name // or weapon class or whatever.  just a text string we use for the icon state
				rank		// the rank of the weapon (or rarity?)
				desc_color
				hand

			proc
				SetRank(n)
					n = clamp(n, 1, 6)
					wpnspd *= n
					wlvl *= n
					twohanded = "[src.twohanded?"Two Handed":"One Handed"]"
					strreq *= n
					DamageMin *= n
					DamageMax *= n
					//description = "<br><font color = #8C7853><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage,<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					rarity = "{[num2rarity(n)]}"
					icon_state = "[num2iconstate(n)][weapon_name]"
					desc_color = "[num2desccolor(n)][desc_color]"
					description = "<br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded]<br>Worth [Worth]"


				num2rarity(n)
					switch(n)
						if(1) return "Average"
						if(2) return "Unusual"
						if(3) return "Uncommon"
						if(4) return "Choice"
						if(5) return "Ordinary"
						if(6) return "Singular"
						if(7) return "One of a Kind"

				num2iconstate(n)
					switch(n)
						if(1) return "avg"
						if(2) return "unu"
						if(3) return "unco"
						if(4) return "choi"
						if(5) return "ordi"
						if(6) return "sin"

				num2desccolor(n)
					switch(n)
						if(1) return "#8C7853"
						if(2) return "#b87333"
						if(3) return "#c0c0c0"
						if(4) return "#e6e8fa"
						if(5) return "#4682b4"
						if(6) return "#ffd700"

				num2hand(n)
					switch(n)
						if(1)
							if(src.twohanded==0)
								return "One Hand"
							if(src.twohanded==1)
								return "Two Hands"
						else
							if(2)
								if(src.twohanded==0)
									return "One Hand"
								if(src.twohanded==1)
									return "Two Hands"
							else
								if(3)
									if(src.twohanded==0)
										return "One Hand"
									if(src.twohanded==1)
										return "Two Hands"
								else
									if(4)
										if(src.twohanded==0)
											return "One Hand"
										if(src.twohanded==1)
											return "Two Hands"
									else
										if(5)
											if(src.twohanded==0)
												return "One Hand"
											if(src.twohanded==1)
												return "Two Hands"
										else
											if(6)
												if(src.twohanded==0)
													return "One Hand"
												if(src.twohanded==1)
													return "Two Hands"



			/*example_anlace
				name = "Example Anlace"

				weapon_name = "anlace"
				Worth = 1
				typi = "weapon"
				wpnspd = 1
				wlvl = 1
				twohanded = 0
				strreq = 1
				DamageMin = 2
				DamageMax = 4

				New()
					description = "<br><font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					SetRank(rank||1)*/
			anlace
				name = "Anlace"
				//icon_state="avganlace"
				weapon_name = "anlace"
				Worth = 1
				typi = "weapon"
				wpnspd = 1
				wlvl = 1
				twohanded = 0
				strreq = 1
				DamageMin = 2
				DamageMax = 4
				//can_stack = TRUE
				New()
					..()
					//description = "<br><font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					SetRank(rank||1)
			estoc
				name = "Estoc"

				weapon_name = "estoc"
				Worth = 6
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 4
				DamageMax = 8
				New()
					//description = "<br><font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					SetRank(rank||1)

			kukri
				name = "Kukri"
				//description = "<font color = #8C7853><center><b>Henna Kukri:</b><br>3-8 Damage<br>2 Strength-Req"
				//icon_state = "avgkukri"
				weapon_name = "kukri"
				Worth = 8
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 3
				DamageMax = 8
				New()
					SetRank(rank||1)

			brand
				name = "Brand"
				//description = "<font color = #8C7853><center><b>Russet (Brand):</b><br>8-10 Damage<br>Two-Handed<br>6 Strength-Req"
				//icon_state = "avgbrand"
				weapon_name = "brand"
				Worth = 25
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 1
				strreq = 6
				DamageMin = 8
				DamageMax = 10
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			ferule
				name = "Ferule"
				//description = "<font color = #8C7853><center><b>Blackjack (Ferule):</b><br>4-6 Damage<br>2 Strength-Req<br>Worth 25"
				//icon_state = "avgferule"
				weapon_name = "ferule"
				Worth = 25
				typi = "weapon"
				wpnspd = 5
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 4
				DamageMax = 6
				SPRTbonus = 5
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			marubo
				name = "Marubo"
				//description = "<font color = #8C7853><center><b>Firm (Marubo):</b><br>7-8 Damage<br>Two-Handed<br>3 Strength Required<br>Worth 15"
				//icon_state = "avgmarubo"
				weapon_name = "marubo"
				Worth = 15
				typi = "weapon"
				wpnspd = 6
				wlvl = 1
				twohanded = 1
				strreq = 4
				DamageMin = 8
				DamageMax = 9
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			tanto
				name = "Tanto"
				//description = "<font color = #8C7853><center><b>Worn (Tanto):</b><br>3-5 Damage<br>1 Strength Required<br>Worth 10"
				//icon_state = "avgtanto"
				weapon_name = "tanto"
				Worth = 10
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 0
				strreq = 1
				DamageMin = 3
				DamageMax = 5
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			yawara
				name = "Yawara"
				//description = "<font color = #8C7853><center><b>Worn (Yawara):</b>6-11 Damage<br>10 Strength Required<br>Worth 30"
				//icon_state = "avgyawara"
				weapon_name = "yawara"
				Worth = 30
				typi = "weapon"
				wpnspd = 5
				wlvl = 1
				twohanded = 1
				strreq = 10
				DamageMin = 6
				DamageMax = 11
				STRbonus = 5
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			eiku
				name = "Eiku"
				//description = "<font color = #8C7853><center><b>Elde (Eiku):</b><br>8-10 damage<br>5 Strength-Req<br>Worth 36"
				//icon_state = "avgeiku"
				weapon_name = "eiku"
				Worth = 36
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 1
				strreq = 5
				DamageMin = 8
				DamageMax = 10
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			broadsword
				name = "Broadsword"
				//description = "<font color = #8C7853><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "avgbroadsword"
				weapon_name = "broadsword"
				Worth = 20
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 0
				strreq = 4
				DamageMin = 5
				DamageMax = 12
				STRbonus = 2
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			kakubo
				name = "Kakubo"
				//description = "<font color = #8C7853><center><b>Swift (Kakubo):</b><br>10-13 Damage<br>14 Strength-Req<br>Worth 66"
				//icon_state = "avgkakubo"
				weapon_name = "kakubo"
				Worth = 66
				typi = "weapon"
				wpnspd = 6
				wlvl = 1
				twohanded = 1
				strreq = 14
				DamageMin = 10
				DamageMax = 13
				STRbonus = 4
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			tinberochin
				name = "Tinberochin"
				//description = "<font color = #8C7853><center><b>Butcher (Tinberochin):</b><br>5-11 Damage<br>22 Strength-Req<br>Two-Handed<br>Worth 130"
				//icon_state = "avgtinberochin"
				weapon_name = "tinberochin"
				Worth = 130
				typi = "weapon"
				wpnspd = 1
				wlvl = 2
				twohanded = 1
				strreq = 22
				DamageMin = 15
				DamageMax = 21
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			katar
				name = "Katar"
				//description = "<font color = #8C7853><center><b>Dull (Katar):</b><br>4-7 Damage<br>16 Strength-Req<br>Worth 93"
				//icon_state = "avgkatar"
				weapon_name = "katar"
				Worth = 93
				typi = "weapon"
				wpnspd = 10
				wlvl = 2
				twohanded = 1
				strreq = 12
				DamageMin = 8
				DamageMax = 14
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			voulge
				name = "Voulge"
				//description = "<font color = #8C7853><center><b>Dull (Voulge):</b><br>13-24 Damage<br>28 Strength-Req<br>Two-Handed<br>Worth 175"
				//icon_state = "avgvoulge"
				weapon_name = "voulge"
				Worth = 175
				typi = "weapon"
				wpnspd = 3
				wlvl = 2
				twohanded = 1
				strreq = 18
				DamageMin = 13
				DamageMax = 24
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			rakkakubo
				name = "Rakkakubo"
				//description = "<font color = #8C7853><center><b>Studded (Rakkakubo):</b><br>16-26 Damage<br>36 Strength-Req<br>Two-Handed<br>Worth 175"
				//icon_state = "avgrakkakubo"
				weapon_name = "rakkakubo"
				Worth = 175
				typi = "weapon"
				wpnspd = 2
				wlvl = 3
				twohanded = 1
				strreq = 23
				DamageMin = 26
				DamageMax = 26
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			kama
				name = "Kama"
				//description = "<font color = #8C7853><center><b>Harvest (Kama):</b><br>11-13 Damage<br>18 Strength-Req<br>Worth 80"
				//icon_state = "avgkama"
				weapon_name = "kama"
				Worth = 60
				typi = "weapon"
				wpnspd = 7
				wlvl = 3
				twohanded = 1
				strreq = 12
				DamageMin = 11
				DamageMax = 13
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			wakizashi
				name = "Wakizashi"
				//description = "<font color = #8C7853><center><b>Rustic (Wakizashi):</b><br>7-17 Damage<br>21 Strength-Req<br>Worth 100"
				//icon_state = "avgwakizashi"
				weapon_name = "wakizashi"
				Worth = 100
				typi = "weapon"
				wpnspd = 5
				wlvl = 3
				twohanded = 1
				strreq = 18
				DamageMin = 14
				DamageMax = 17
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			nagamaki
				name = "Nagamaki"
				//description = "<font color = #8C7853><center><b>Worn (Nagamaki):</b><br>9-23 Damage<br>24 Strength-Req<br>Two-Handed<br>Worth 100"
				//icon_state = "avgnagamaki"
				weapon_name = "nagamaki"
				Worth = 100
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 24
				DamageMin = 9
				DamageMax = 23
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			tachi
				name = "Tachi"
				//description = "<font color = #8C7853><center><b>Relic (Tachi):</b><br>11-19 Damage<br>28 Strength-Req<br>Two-Handed<br>Worth 100"
				//icon_state = "avgtachi"
				weapon_name = "tachi"
				Worth = 140
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 18
				DamageMin = 11
				DamageMax = 19
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			uchigatana
				name = "Uchigatana"
				//description = "Seems to be a fairly old Uchigatana.<br><font color = #8C7853><center><b>Rusty (Uchigatana):</b><br>170-178 Damage<br>Two-Handed<br>52 Strength-Req<br>Worth 93"
				//icon_state = "avguchigatana"
				weapon_name = "uchigatana"
				Worth = 100
				typi = "weapon"
				wpnspd = 1
				wlvl = 4
				twohanded = 1
				strreq = 30
				DamageMin = 20
				DamageMax = 28
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			naginata
				name = "Naginata"
				//description = "An Old Relic.<br><font color = #8C7853><center><b>Relic (Naginata):</b><br>142-184 Damage<br>Two-Handed<br>38 Strength-Req<br>Worth 166"
				//icon_state = "avgnaginata"
				weapon_name = "naginata"
				Worth = 166
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 20
				DamageMin = 22
				DamageMax = 24
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			hakkakubo
				name = "Hakkakubo"
				//description = "Hard wood Hakkakubo.<br><font color = #8C7853><center><b>Hard (Hakkakubo):</b><br>160-201 Damage<br>Two-Handed<br>66 Strength-Req<br>Worth 156"
				//icon_state = "avghakkakubo"
				weapon_name = "hakkakubo"
				Worth = 156
				typi = "weapon"
				wpnspd = 1
				wlvl = 4
				twohanded = 1
				strreq = 26
				DamageMin = 16
				DamageMax = 20
				//rarity = "{Average}"
				New()
					SetRank(rank||1)

			katana
				name = "Katana"
				//description = "<font color = #ffd700><b>Katana (Average):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "avgkatana"
				weapon_name = "katana"
				Worth = 100
				typi = "weapon"
				wpnspd = 8
				wlvl = 1
				twohanded = 1
				strreq = 14
				DamageMin = 20
				DamageMax = 26
				STRbonus = 2
				SPRTbonus = 3
				//rarity = "{Average}"
				New()
					SetRank(rank||1)











	//weapon defines below


			avganlace
				name = "Russet (Anlace)"

				//icon_state = "avganlace"
				Worth = 1
				typi = "weapon"
				wpnspd = 1
				wlvl = 1
				twohanded = 0
				strreq = 1
				DamageMin = 2
				DamageMax = 4
				//description = "<br><font color = #8C7853><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage,<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<br><font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuanlace//working
				name = "Titian (Anlace)"
				//description = "<font color = #b87333><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>+[wpnspd] Speed<br>+[STRbonus] Strength<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
				//icon_state = "unuanlace"
				weapon_name = "anlace"
				Worth = 24
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 6
				DamageMax = 12
				STRbonus = 6
				SPRTbonus = 5
				//rarity = "{Unusual}"
				New()
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					SetRank(rank||2)
					if(usr!=null)
						HEALTHbonus = rand(1,20)
						var/addd1 = "+[HEALTHbonus] Health"
						description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>+[SPRTbonus] Spirit<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			uncoanlace
				name = "Argent (Anlace)"
				weapon_name = "anlace"
				//description = "<font color = #c0c0c0><b><center>Argent (Anlace):</b><br>8-10 Damage<br>+8 Strength<br>+4 Spirit<br>4 Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth 42"
				//icon_state = "uncoanlace"
				Worth = 42
				typi = "weapon"
				wpnspd = 4
				wlvl = 2
				twohanded = 0
				strreq = 4
				DamageMin = 8
				DamageMax = 10
				STRbonus = 8
				SPRTbonus = 4
				//rarity = "{Uncommon}"
				New()
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					SetRank(rank||3)
					if(usr!=null)
						VITAEbonus = rand(2,4)
						var/addd = "+[VITAEbonus] Vitae"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>+[SPRTbonus] Spirit<br>[addd]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choianlace
				name = "Ferrum (Anlace)"
				weapon_name = "anlace"
				//description = "<font color = #e6e8fa><center><b>Ferrum (Anlace):</b><br>10-14 Damage<br>+6 Spirit<br>5 Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth 64"
				//icon_state = "choianlace"
				Worth = 64
				typi = "weapon"
				wpnspd = 6
				wlvl = 3
				twohanded = 0
				strreq = 7
				DamageMin = 9
				DamageMax = 13
				SPRTbonus = 6
				//rarity = "{Choice}"
				New()
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					SetRank(rank||4)
					if(usr!=null)
						ENERGYbonus = rand(24,42)
						var/addd = "+[ENERGYbonus] Energy"
						description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[addd]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordianlace
				name = "Ochre (Anlace)"
				//description = "<font color= #4682b4><center><b>Ochre (Anlace):</b><br>7-11 Damage<br>4 Strength-Req<br>Extreme Speed"
				weapon_name = "anlace"
				//icon_state = "ordianlace"
				Worth = 84
				typi = "weapon"
				wpnspd = 9
				wlvl = 4
				twohanded = 0
				strreq = 4
				DamageMin = 7
				DamageMax = 11
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			sinanlace
				name = "Aureate (Anlace)"
				weapon_name = "anlace"
				//description = "<font color = #ffd700><center><b>Aureate (Anlace):</b><br>17-19 Damage<br>+7 Strength<br>+11 Spirit<br>7 Strength-Req<br>Worth 101"
				//icon_state = "sinanlace"
				Worth = 101
				typi = "weapon"
				wpnspd = 1
				wlvl = 1
				twohanded = 0
				strreq = 7
				DamageMin = 12
				DamageMax = 14
				STRbonus = 7
				SPRTbonus = 11
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus]Strength<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					if(usr!=null)
						var/resroll = rand(1,10)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = "+[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus]Strength<br>+[SPRTbonus] Spirit<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//anlace are done
			avgestoc
				name = "Ecru (Estoc)"
				//description = "<font color = #8C7853><center><b>Ecru (Estoc):</b><br>4-8 Damage,<br>2 Strength-Req<br>Worth 6"
				//icon_state = "avgestoc"
				weapon_name = "estoc"
				Worth = 6
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 4
				DamageMax = 8
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuestoc
				name = "Sunder (Estoc)"
				//description = "<font color = #b87333><center><b>Sunder (Estoc):</b><br>6-12 Damage<br>+2 Strength<br>+5 Spirit<br>4 Strength-Req<br>Worth 24"
				//icon_state = "unuestoc"
				weapon_name = "estoc"
				Worth = 24
				typi = "weapon"
				wpnspd = 4
				wlvl = 2
				twohanded = 0
				strreq = 4
				DamageMin = 6
				DamageMax = 12
				STRbonus = 2
				SPRTbonus = 5
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus]Strength<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncoestoc
				name = "Incise (Estoc)"
				//description = "<font color = #c0c0c0><b><center>Incise (Estoc):</b>  8-10 Damage, +6 Strength, +4 Spirit, 4 Strength-Req<br>Worth 42"
				//icon_state = "uncoestoc"
				weapon_name = "estoc"
				Worth = 42
				typi = "weapon"
				wpnspd = 5
				wlvl = 3
				twohanded = 0
				strreq = 4
				DamageMin = 8
				DamageMax = 10
				STRbonus = 6
				SPRTbonus = 4
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus]Strength<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choiestoc
				name = "Asunder (Estoc)"
				//description = "<font color = #e6e8fa><center><b>Asunder (Estoc):</b><br>11-15 Damage<br>+6 Spirit<br>6 Strength-Req<br>Worth 64"
				//icon_state = "choiestoc"
				weapon_name = "estoc"
				Worth = 64
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 0
				strreq = 6
				DamageMin = 11
				DamageMax = 15
				SPRTbonus = 6
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						BLUDGEONbonus = rand(2,6)
						var/ad2 = "+[BLUDGEONbonus] Bludgeon"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[ad2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordiestoc
				name = "Slash (Estoc)"
				//description = "<font color= #4682b4><center><b>Slash (Estoc):</b><br>13-16 Damage<br>8 Strength-Req"
				//icon_state = "ordiestoc"
				weapon_name = "estoc"
				Worth = 84
				typi = "weapon"
				wpnspd = 9
				wlvl = 5
				twohanded = 0
				strreq = 8
				DamageMin = 13
				DamageMax = 16
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinestoc
				name = "Rive (Estoc)"
				//description = "<font color = #ffd700><center><b>Rive (Estoc):</b><br>17-19 Damage<br>+1 Spirit<br>11 Strength-Req<br>Worth 101"
				//icon_state = "sinestoc"
				Worth = 101
				typi = "weapon"
				wpnspd = 5
				wlvl = 6
				twohanded = 1
				strreq = 11
				DamageMin = 17
				DamageMax = 19
				SPRTbonus = 1
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						var/resroll = rand(1,10)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = "+[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

	//estocs done
			avgkukri
				name = "Henna (Kukri)"
				//description = "<font color = #8C7853><center><b>Henna Kukri:</b><br>3-8 Damage<br>2 Strength-Req"
				//icon_state = "avgkukri"
				weapon_name = "kukri"
				Worth = 8
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 3
				DamageMax = 8
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unukukri
				name = "Aithochrous (Kukri)"
				//description = "<font color = #b87333><center><b>Aithochrous (Kukri):</b><br>6-13 Damage<br>+3 Spirit<br>4 Strength-Req<br>Worth 24"
				//icon_state = "unukukri"
				weapon_name = "kukri"
				Worth = 24
				typi = "weapon"
				wpnspd = 3
				wlvl = 2
				twohanded = 0
				strreq = 4
				DamageMin = 6
				DamageMax = 13
				SPRTbonus = 3
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br><+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEATbonus = rand(1,15)
						var/ad1 = "+[HEATbonus] Heat"
						description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br><+[SPRTbonus] Spirit<br>[ad1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncokukri
				name = "Ashen (Kukri)"
				//description = "<font color = #c0c0c0><center><b>Ashen (Kukri):</b><br>7-12 Damage<br>+6 Spirit<br>5 Strength-Req"
				//icon_state = "uncokukri"
				weapon_name = "kukri"
				Worth = 42
				typi = "weapon"
				wpnspd = 5
				wlvl = 3
				twohanded = 0
				strreq = 3
				DamageMin = 7
				DamageMax = 12
				SPRTbonus = 6
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br><+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						var/resroll = rand(1,10)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = "+[resroll] Omni-Proof"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br><+[SPRTbonus] Spirit<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choikukri
				name = "Coral (Kukri)"
				//description = "<font color = #e6e8fa><center><b>Coral (Kukri):</b><br>10-14 Damage<br>+10 Spirit<br>7 Strength-Req"
				//icon_state = "choikukri"
				weapon_name = "kukri"
				Worth = 64
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 0
				strreq = 7
				DamageMin = 10
				DamageMax = 14
				SPRTbonus = 10
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br><+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						ACIDbonus = rand(1,4)
						var/addd2 = ", +[ACIDbonus] Acid"
						description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br><+[SPRTbonus] Spirit<br>[addd2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordikukri
				name = "Furious (Kukri)"
				//description = "<font color= #4682b4><center><b>Furious (Kukri):</b><br>7-14 Damage<br>4 Strength-Req"
				//icon_state = "ordikukri"
				weapon_name = "kukri"
				Worth = 84
				typi = "weapon"
				wpnspd = 9
				wlvl = 5
				twohanded = 0
				strreq = 4
				DamageMin = 7
				DamageMax = 14
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinkukri
				name = "Vim (Kukri)"
				//description = "<font color = #ffd700><center><b>Vim (Kukri):</b><br>16-22 Damage<br>+7 Strength<br>+11 Spirit<br>9 Strength-Req<br>Worth 124"
				//icon_state = "sinkukri"
				weapon_name = "kukri"
				Worth = 124
				typi = "weapon"
				wpnspd = 6
				wlvl = 6
				twohanded = 0
				strreq = 9
				DamageMin = 16
				DamageMax = 22
				STRbonus = 7
				SPRTbonus = 11
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(10,30)
						var/addd1 = ", +[HEALTHbonus] Health"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//kukri done
			avgbrand
				name = "Russet (Brand)"
				//description = "<font color = #8C7853><center><b>Russet (Brand):</b><br>8-10 Damage<br>Two-Handed<br>6 Strength-Req"
				//icon_state = "avgbrand"
				weapon_name = "brand"
				Worth = 25
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 1
				strreq = 6
				DamageMin = 8
				DamageMax = 10
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unubrand
				name = "Aurous (Brand)"
				//description = "<font color = #b87333><center><b>Aurous (Brand):</b><br>10-16 Damage<br>Two-Handed<br>+2 Spirit<br>9 Strength-Req<br>Worth 42"
				//icon_state = "unubrand"
				weapon_name = "brand"
				Worth = 42
				typi = "weapon"
				wpnspd = 2
				wlvl = 2
				twohanded = 1
				strreq = 9
				DamageMin = 10
				DamageMax = 16
				SPRTbonus = 2
				//rarity = "{Unusual"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncobrand
				name = "Argent (Brand)"
				//description = "<font color = #c0c0c0><center><b>Argent (Brand):</b><br>14-18 Damage<br>+4 Spirit<br>13 Strength-Req<br>Worth 64"
				//icon_state = "uncobrand"
				weapon_name = "brand"
				Worth = 64
				typi = "weapon"
				wpnspd = 2
				wlvl = 3
				twohanded = 1
				strreq = 13
				DamageMin = 14
				DamageMax = 18
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choibrand
				name = "Precise (Brand)"
				//description = "<font color = #e6e8fa><center><b>Precise (Brand):</b><br>18-18 Damage<br>20 Strength-Req<br>Two-Handed<br>Worth 84"
				//icon_state = "choibrand"
				weapon_name = "brand"
				Worth = 84
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 20
				DamageMin = 18
				DamageMax = 18
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordibrand
				name = "Diem (Brand)"
				//description = "<font color= #4682b4><center><b>Diem (Brand):</b><br>15-20 Damage<br>17 Strength-Req<br>Worth 74"
				//icon_state = "ordibrand"
				weapon_name = "brand"
				Worth = 74
				typi = "weapon"
				wpnspd = 2
				wlvl = 5
				twohanded = 1
				strreq = 17
				DamageMin = 15
				DamageMax = 20
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinbrand
				name = "Macabre (Brand)"
				//description = "<font color = #ffd700><center><b>Macabre (Brand):</b><br>24-33 Damage<br>+6 Spirit<br>24 Strength-Req<br>Worth 242"
				//icon_state = "sinbrand"
				weapon_name = "brand"
				Worth = 242
				typi = "weapon"
				wpnspd = 1
				wlvl = 6
				twohanded = 1
				strreq = 24
				DamageMin = 24
				DamageMax = 33
				SPRTbonus = 6
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						SHARDBURSTbonus = rand(15,25)
						var/ad2 = "+[SHARDBURSTbonus] Shard Burst"
						var/resroll = rand(10,20)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = "+[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[ad2]<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//brands done
			avgferule
				name = "Blackjack (Ferule)"
				//description = "<font color = #8C7853><center><b>Blackjack (Ferule):</b><br>4-6 Damage<br>2 Strength-Req<br>Worth 25"
				//icon_state = "avgferule"
				weapon_name = "ferule"
				Worth = 25
				typi = "weapon"
				wpnspd = 5
				wlvl = 1
				twohanded = 0
				strreq = 2
				DamageMin = 4
				DamageMax = 6
				SPRTbonus = 5
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuferule
				name = "Pummel (Ferule)"
				//description = "<font color = #b87333><center><b>Pummel (Ferule):</b><br>6-7 Damage<br>+8 Spirit<br>4 Strength-Req<br>Worth 42"
				//icon_state = "unuferule"
				weapon_name = "ferule"
				Worth = 42
				typi = "weapon"
				wpnspd = 6
				wlvl = 2
				twohanded = 0
				strreq = 4
				DamageMin = 6
				DamageMax = 7
				SPRTbonus = 8
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncoferule
				name = "Vitae (Ferule)"
				//description = "<font color = #c0c0c0><center><b>Vitae (Ferule):</b><br>4-9 Damage<br>+10 Spirit<br>6 Strength-Req<br>Worth 64"
				//icon_state = "uncoferule"
				weapon_name = "ferule"
				Worth = 64
				typi = "weapon"
				wpnspd = 4
				wlvl = 3
				twohanded = 0
				strreq = 6
				DamageMin = 4
				DamageMax = 9
				SPRTbonus = 10
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						VITAEbonus = rand(5,10)
						var/addd = "+[VITAEbonus] Vitae"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[addd]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choiferule
				name = "Clout (Ferule)"
				//description = "<font color = #e6e8fa><center><b>Clout (Ferule):</b><br>7-11 Damage<br>+7 Spirit<br>8 Strength-Req<br>Worth 84"
				//icon_state = "choiferule"
				weapon_name = "ferule"
				Worth = 84
				typi = "weapon"
				wpnspd = 7
				wlvl = 4
				twohanded = 0
				strreq = 8
				DamageMin = 18
				DamageMax = 18
				SPRTbonus = 15
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordiferule
				name = "Bludgeon (Ferule)"
				//description = "<font color= #4682b4><center><b>Bludgeon (Ferule):</b><br>9-14 Damage<br>10 Strength-Req<br>Worth 74"
				//icon_state = "ordiferule"
				weapon_name = "ferule"
				Worth = 74
				typi = "weapon"
				wpnspd = 5
				wlvl = 5
				twohanded = 0
				strreq = 10
				DamageMin = 9
				DamageMax = 14
				SPRTbonus = 12
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinferule
				name = "Trauma (Ferule)"
				//description = "<font color = #ffd700><center><b>Trauma (Ferule):</b><br>15-20 Damage<br>+10 Spirit<br>15 Strength-Req<br>Worth 142"
				//icon_state = "sinferule"
				weapon_name = "ferule"
				Worth = 142
				typi = "weapon"
				wpnspd = 5
				wlvl = 6
				twohanded = 0
				strreq = 15
				DamageMin = 15
				DamageMax = 20
				SPRTbonus = 10
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						COSMOSbonus = rand(5,10)
						var/ad3 = "+[COSMOSbonus] Cosmos"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[ad3]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

	//ferule done
			avgmarubo
				name = "Firm (Marubo)"
				//description = "<font color = #8C7853><center><b>Firm (Marubo):</b><br>7-8 Damage<br>Two-Handed<br>3 Strength Required<br>Worth 15"
				//icon_state = "avgmarubo"
				weapon_name = "marubo"
				Worth = 15
				typi = "weapon"
				wpnspd = 6
				wlvl = 1
				twohanded = 1
				strreq = 4
				DamageMin = 8
				DamageMax = 9
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unumarubo
				name = "Fanged (Marubo)"
				//description = "<font color = #b87333><center><b>Fanged (Marubo):</b><br>9-12 Damage<br>Two-Handed<br>6 Strength Required<br>Worth 25"
				//icon_state = "unumarubo"
				weapon_name = "marubo"
				Worth = 25
				typi = "weapon"
				wpnspd = 7
				wlvl = 2
				twohanded = 1
				strreq = 6
				DamageMin = 9
				DamageMax = 12
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncomarubo
				name = "Plated (Marubo)"
				//description = "<font color = #c0c0c0><center><b>Plated (Marubo):</b><br>11-13 Damage<br>Two-Handed<br>8 Strength Required<br>Worth 35"
				//icon_state = "uncomarubo"
				weapon_name = "marubo"
				Worth = 35
				typi = "weapon"
				wpnspd = 5
				wlvl = 3
				twohanded = 1
				strreq = 8
				DamageMin = 8
				DamageMax = 9
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choimarubo
				name = "Studded (Marubo)"
				//description = "<font color = #e6e8fa><center><b>Firm (Marubo):</b><br>10-12 Damage<br>Two-Handed<br>10 Strength Required<br>Worth 45"
				//icon_state = "choimarubo"
				weapon_name = "marubo"
				Worth = 45
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 10
				DamageMin = 10
				DamageMax = 12
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordimarubo
				name = "Battle (Marubo)"
				//description = "<font color= #4682b4><center><b>Studded (Marubo):</b><br>13-16 Damage<br>Two-Handed<br>13 Strength Required<br>Worth 88"
				//icon_state = "ordimarubo"
				weapon_name = "marubo"
				Worth = 88
				typi = "weapon"
				wpnspd = 5
				wlvl = 5
				twohanded = 1
				strreq = 13
				DamageMin = 13
				DamageMax = 16
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinmarubo
				name = "Violent (Marubo)"
				//description = "<font color = #ffd700><center><b>Violent (Marubo):</b><br>20-24 Damage<br>Two-Handed<br>16 Strength Required<br>Worth 145"
				//icon_state = "sinmarubo"
				weapon_name = "marubo"
				Worth = 145
				typi = "weapon"
				wpnspd = 4
				wlvl = 6
				twohanded = 1
				strreq = 16
				DamageMin = 20
				DamageMax = 24
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//marubo done
			avgtanto
				name = "Relic (Tanto)"
				//description = "<font color = #8C7853><center><b>Worn (Tanto):</b><br>3-5 Damage<br>1 Strength Required<br>Worth 10"
				//icon_state = "avgtanto"
				weapon_name = "tanto"
				Worth = 10
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 0
				strreq = 1
				DamageMin = 3
				DamageMax = 5
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unutanto
				name = "Ancient (Tanto)"
				//description = "<font color = #b87333><center><b>Unrefinied (Tanto):</b><br>4-6 Damage<br>2 Strength Required<br>Worth 25"
				//icon_state = "unutanto"
				weapon_name = "tanto"
				Worth = 25
				typi = "weapon"
				wpnspd = 4
				wlvl = 2
				twohanded = 1
				strreq = 2
				DamageMin = 4
				DamageMax = 6
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncotanto
				name = "Classic (Tanto)"
				//description = "<font color = #c0c0c0><center><b>Derived (Tanto):</b><br>4-7 Damage<br>3 Strength Required<br>Worth 35"
				//icon_state = "uncotanto"
				weapon_name = "tanto"
				Worth = 35
				typi = "weapon"
				wpnspd = 5
				wlvl = 3
				twohanded = 0
				strreq = 3
				DamageMin = 4
				DamageMax = 7
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choitanto
				name = "Refined (Tanto)"
				//description = "<font color = #e6e8fa><center><b>Refined (Tanto):</b><br>6-8 Damage<br>4 Strength Required<br>Worth 45"
				//icon_state = "choitanto"
				weapon_name = "tanto"
				Worth = 45
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 0
				strreq = 4
				DamageMin = 6
				DamageMax = 8
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			orditanto
				name = "Current (Tanto)"
				//description = "<font color= #4682b4><center><b>Veridical (Tanto):</b><br>7-9 Damage<br>4 Strength Required<br>Worth 88"
				//icon_state = "orditanto"
				weapon_name = "tanto"
				Worth = 88
				typi = "weapon"
				wpnspd = 5
				wlvl = 5
				twohanded = 0
				strreq = 4
				DamageMin = 7
				DamageMax = 9
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sintanto
				name = "Foreyear (Tanto)"
				//description = "<font color = #ffd700><center><b>Violent (Tanto):</b><br>10 Damage<br>5 Strength Required<br>Worth 145"
				//icon_state = "sintanto"
				weapon_name = "tanto"
				Worth = 145
				typi = "weapon"
				wpnspd = 7
				wlvl = 6
				twohanded = 0
				strreq = 5
				DamageMin = 10
				DamageMax = 10
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//tanto done
			avgyawara
				name = "Worn (Yawara)"
				//description = "<font color = #8C7853><center><b>Worn (Yawara):</b>6-11 Damage<br>10 Strength Required<br>Worth 30"
				//icon_state = "avgyawara"
				weapon_name = "yawara"
				Worth = 30
				typi = "weapon"
				wpnspd = 5
				wlvl = 1
				twohanded = 1
				strreq = 10
				DamageMin = 6
				DamageMax = 11
				STRbonus = 5
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuyawara
				name = "Blunt (Yawara)"
				//description = "<font color = #b87333><center><b>Blunt (Yawara):</b>  9-18 Damage, +11 Strength, 10 strength required<br>Worth 120"
				//icon_state = "unuyawara"
				weapon_name = "yawara"
				Worth = 120
				typi = "weapon"
				wpnspd = 10
				wlvl = 1
				twohanded = 1
				strreq = 10
				DamageMin = 9
				DamageMax = 18
				STRbonus = 7
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(5,20)
						var/addd1 = ", +[HEALTHbonus] Health"
						HEATbonus = rand(1,2)
						var/addd2 = ", +[HEATbonus] Heat"
						description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[addd1]<br>[addd2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncoyawara
				name = "Dense (Yawara)"
				//description = "<font color = #c0c0c0><center><b>Dense (Yawara):</b>  11-16 Damage, +11 Strength, 11 strength required"
				//icon_state = "uncoyawara"
				weapon_name = "yawara"
				Worth = 50
				typi = "weapon"
				wpnspd = 9
				wlvl = 1
				twohanded = 1
				strreq = 7
				DamageMin = 11
				DamageMax = 22
				STRbonus = 10
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choiyawara
				name = "Ritual (Yawara)"
				//description = "<font color = #e6e8fa><center><b>Ritual (Yawara):</b>  8-16 Damage, two-handed, +11 Spirit, 5 strength required<br>Worth 60"
				//icon_state = "choiyawara"
				weapon_name = "yawara"
				Worth = 60
				typi = "weapon"
				wpnspd = 11
				wlvl = 1
				twohanded = 1
				strreq = 5
				DamageMin = 8
				DamageMax = 16
				STRbonus = 20
				SPRTbonus = 11
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						ENERGYbonus = rand(5,20)
						var/addd1 = ", +[ENERGYbonus] Energy"
						WATbonus = rand(1,6)
						var/addd2 = ", +[WATbonus] Water Shock"
						description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[addd1]<br>[addd2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordiyawara
				name = "Friar (Yawara)"
				//description = "<font color = #4682b4><center><b>Friar (Yawara):</b>  8-16 Damage, two-handed, +11 Spirit, 5 strength required<br>Worth 45"
				//icon_state = "ordiyawara"
				weapon_name = "yawara"
				Worth = 45
				typi = "weapon"
				wpnspd = 10
				wlvl = 1
				twohanded = 1
				strreq = 5
				DamageMin = 2
				DamageMax = 8
				STRbonus = 15
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinyawara
				name = "Martial (Yawara)"
				//description = "<font color = #ffd700><center><b>Martial (Yawara):</b>  14-25 Damage, two-handed, 5 strength required<br>Worth 200"
				//icon_state = "sinyawara"
				weapon_name = "yawara"
				Worth = 200
				typi = "weapon"
				wpnspd = 15
				wlvl = 1
				twohanded = 1
				strreq = 5
				DamageMin = 14
				DamageMax = 25
				STRbonus = 20
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//yawara done
			avgeiku
				name = "Elde (Eiku)"
				//description = "<font color = #8C7853><center><b>Elde (Eiku):</b><br>8-10 damage<br>5 Strength-Req<br>Worth 36"
				//icon_state = "avgeiku"
				weapon_name = "eiku"
				Worth = 36
				typi = "weapon"
				wpnspd = 3
				wlvl = 1
				twohanded = 1
				strreq = 5
				DamageMin = 8
				DamageMax = 10
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			unueiku
				name = "Silic (Eiku)"
				//description = "<font color = #b87333><center><b>Silic (Eiku):</b><br>7-12 damage<br>7 Strength-Req<br>Worth 47"
				//icon_state = "unueiku"
				weapon_name = "eiku"
				Worth = 47
				typi = "weapon"
				wpnspd = 4
				wlvl = 1
				twohanded = 1
				strreq = 7
				DamageMin = 5
				DamageMax = 11
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			uncoeiku
				name = "Iron (Eiku)"
				//description = "<center><b>Long Staff:</b>  5-11 Damage, two-handed, 8 strength required, Worth: 30"
				//icon_state = "uncoeiku"
				weapon_name = "eiku"
				Worth = 60
				typi = "weapon"
				wpnspd = 5
				wlvl = 1
				twohanded = 1
				strreq = 8
				DamageMin = 7
				DamageMax = 12
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			choieiku
				name = "Shard (Eiku)"
				//description = "<font color = #><center><b>Frost (Long Staff):</b>  10-22 Damage, two-handed, +2 Str, +9 Int, 8 strength required"
				//icon_state = "choieiku"
				weapon_name = "eiku"
				Worth = 120
				typi = "weapon"
				wpnspd = 0
				wlvl = 1
				twohanded = 1
				strreq = 8
				DamageMin = 10
				DamageMax = 22
				STRbonus = 2
				SPRTbonus = 9
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
					if(usr!=null)
						ENERGYbonus = rand(5,20)
						var/addd1 = ", +[ENERGYbonus] Energy"
						SHARDBURSTbonus = rand(1,6)
						var/addd2 = ", +[SHARDBURSTbonus] Shard Burst"
						ICEres = rand(1,10)
						var/addd3 = ", +[ICEres] Ice Proof"
						description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[addd1]<br>[addd2]<br>[addd3]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordieiku
				name = "Razor (Eiku)"
				//description = ""
				//icon_state = "ordieiku"
				weapon_name = "eiku"
				Worth = 80
				typi = "weapon"
				wpnspd = 0
				wlvl = 1
				twohanded = 1
				strreq = 8
				DamageMin = 5
				DamageMax = 11
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sineiku
				name = "Combat (Eiku)"
				//description = "<center><b>Blade:</b>  10-13 damage, 14 strength required, Worth: 100"
				//icon_state = "sineiku"
				weapon_name = "eiku"
				Worth = 200
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 0
				strreq = 14
				DamageMin = 10
				DamageMax = 13
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//eiku done
			avgbroadsword
				name = "Dull (Broadsword)"
				//description = "<font color = #8C7853><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "avgbroadsword"
				weapon_name = "broadsword"
				Worth = 20
				typi = "weapon"
				wpnspd = 2
				wlvl = 1
				twohanded = 0
				strreq = 4
				DamageMin = 5
				DamageMax = 12
				STRbonus = 2
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unubroadsword
				name = "Chipped (Broadsword)"
				//description = "<font color = #ffd700><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "unubroadsword"
				weapon_name = "broadsword"
				Worth = 40
				typi = "weapon"
				wpnspd = 4
				wlvl = 1
				twohanded = 0
				strreq = 8
				DamageMin = 8
				DamageMax = 14
				STRbonus = 3
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncobroadsword
				name = "Edge (Broadsword)"
				//description = "<font color = #ffd700><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "uncobroadsword"
				weapon_name = "broadsword"
				Worth = 60
				typi = "weapon"
				wpnspd = 6
				wlvl = 1
				twohanded = 0
				strreq = 12
				DamageMin = 10
				DamageMax = 16
				STRbonus = 5
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						var/resroll = rand(10,30)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = ", +[resroll] Omni-Proof"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choibroadsword
				name = "Lode (Broadsword)"
				//description = "<font color = #><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "choibroadsword"
				weapon_name = "broadsword"
				Worth = 100
				typi = "weapon"
				wpnspd = 8
				wlvl = 1
				twohanded = 0
				strreq = 14
				DamageMin = 12
				DamageMax = 18
				STRbonus = 10
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordibroadsword
				name = "Knicked (Broadsword)"
				//description = "<font color = #ffd700><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "ordibroadsword"
				weapon_name = "broadsword"
				Worth = 80
				typi = "weapon"
				wpnspd = 7
				wlvl = 1
				twohanded = 0
				strreq = 15
				DamageMin = 10
				DamageMax = 18
				STRbonus = 7
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinbroadsword
				name = "Shimmer (Broadsword)"
				//description = "<font color = #ffd700><center><b>Prismatic (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "sinbroadsword"
				weapon_name = "broadsword"
				Worth = 200
				typi = "weapon"
				wpnspd = 12
				wlvl = 1
				twohanded = 0
				strreq = 18
				DamageMin = 20
				DamageMax = 26
				STRbonus = 15
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						var/resroll = rand(10,30)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = ", +[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//broadsword done
			avgkakubo
				name = "Swift (Kakubo)"
				//description = "<font color = #8C7853><center><b>Swift (Kakubo):</b><br>10-13 Damage<br>14 Strength-Req<br>Worth 66"
				//icon_state = "avgkakubo"
				weapon_name = "kakubo"
				Worth = 66
				typi = "weapon"
				wpnspd = 6
				wlvl = 1
				twohanded = 1
				strreq = 14
				DamageMin = 10
				DamageMax = 13
				STRbonus = 4
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unukakubo
				name = "Steady (Kakubo)"
				//description = "<center><b>Long Sword:</b>  14-17 damage, 24 strength required, Worth: 140"
				//icon_state = "unukakubo"
				weapon_name = "kakubo"
				Worth = 80
				typi = "weapon"
				wpnspd = 7
				wlvl = 1
				twohanded = 1
				strreq = 20
				DamageMin = 14
				DamageMax = 17
				STRbonus = 8
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncokakubo
				name = "Sturdy (Kakubo)"
				//description = ""
				//icon_state = "uncokakubo"
				weapon_name = "kakubo"
				Worth = 100
				typi = "weapon"
				wpnspd = 10
				wlvl = 10
				twohanded = 1
				strreq = 24
				DamageMin = 14
				DamageMax = 17
				STRbonus = 10
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			choikakubo
				name = "Strong (Kakubo)"
				//description = "<center><b>Broad Blade:</b>  19-22 damage, 30 strength required, Worth: 300"
				//icon_state = "choikakubo"
				weapon_name = "kakubo"
				Worth = 120
				typi = "weapon"
				wpnspd = 12
				wlvl = 2
				twohanded = 1
				strreq = 28
				DamageMin = 16
				DamageMax = 20
				STRbonus = 12
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordikakubo
				name = "Stout (Kakubo)"
				//description = "<center><b>Broad Blade:</b>  19-22 damage, 30 strength required, Worth: 300"
				//icon_state = "ordikakubo"
				weapon_name = "kakubo"
				Worth = 130
				typi = "weapon"
				wpnspd = 15
				wlvl = 2
				twohanded = 1
				strreq = 30
				DamageMin = 19
				DamageMax = 22
				STRbonus = 9
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinkakubo
				name = "Solid (Kakubo)"
				//description = "<center><font color = #ffd700><b>Pestilence (Broad Blade):</b>  30-32 Damage, +20 Spirit, 30 strength required"
				//icon_state = "sinkakubo"
				weapon_name = "kakubo"
				Worth = 200
				typi = "weapon"
				wpnspd = 20
				wlvl = 2
				twohanded = 1
				strreq = 36
				DamageMin = 28
				DamageMax = 34
				STRbonus = 10
				SPRTbonus = 20
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						ENERGYbonus = rand(50,100)
						var/addd1 = ", +[ENERGYbonus] Energy"
						ACIDbonus = rand(1,2)
						var/addd2 = ", +[ACIDbonus] Acid"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[addd1]<br>[addd2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//kakubo done
			avgtinberochin
				name = "Rust & Recoil (Tinberochin)"
				//description = "<font color = #8C7853><center><b>Butcher (Tinberochin):</b><br>5-11 Damage<br>22 Strength-Req<br>Two-Handed<br>Worth 130"
				//icon_state = "avgtinberochin"
				weapon_name = "tinberochin"
				Worth = 130
				typi = "weapon"
				wpnspd = 1
				wlvl = 2
				twohanded = 1
				strreq = 22
				DamageMin = 15
				DamageMax = 21
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unutinberochin
				name = "Reach & Reflex (Tinberochin)"
				//description = "<center><b>Broad Sword:</b>  26-29 damage, two-handed, 42 strength required, Worth: 490"
				//icon_state = "unutinberochin"
				weapon_name = "tinberochin"
				Worth = 190
				typi = "weapon"
				wpnspd = 3
				wlvl = 2
				twohanded = 1
				strreq = 32
				DamageMin = 16
				DamageMax = 23
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncotinberochin
				name = "Calcite & Seashell (Tinberochin)"
				//description = "<font color = #ffd700><center><b>Mithra's Edge (Broad Sword):</b>  52-58 Damage, two-handed, +17 Str, +3 Int, 42 strength required"
				//icon_state = "uncotinberochin"
				weapon_name = "tinberochin"
				Worth = 260
				typi = "weapon"
				wpnspd = 6
				wlvl = 2
				twohanded = 1
				strreq = 36
				DamageMin = 22
				DamageMax = 28
				STRbonus = 1
				SPRTbonus = 3
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					if(usr!=null)
						FIREres = rand(5,20)
						var/ad1 = ", +[FIREres] Fire Proof"
						ICEres = rand(5,20)
						var/ad2 = ", +[ICEres] Ice Proof"
						WINDres = rand(5,20)
						var/ad3 = ", +[WINDres] Wind Proof"
						EARTHres = rand(5,20)
						var/ad5 = ", +[EARTHres] Earth Proof"
						WATres = rand(5,20)
						var/ad4 = ", +[WATres] Water Proof"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[ad1]<br>[ad2]<br>[ad3]<br>[ad4]<br>[ad5]<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choitinberochin
				name = "Rapier & Guard (Tinberochin)"
				//description = ""
				//icon_state = "choitinberochin"
				weapon_name = "tinberochin"
				Worth = 290
				typi = "weapon"
				wpnspd = 10
				wlvl = 2
				twohanded = 1
				strreq = 38
				DamageMin = 26
				DamageMax = 29
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			orditinberochin
				name = "Strike & Scale (Tinberochin)"
				//description = "<center><b>Large Axe:</b>  20-25 damage, 38 strength required, Worth: 363"
				//icon_state = "orditinberochin"
				weapon_name = "tinberochin"
				Worth = 263
				typi = "weapon"
				wpnspd = 8
				wlvl = 2
				twohanded = 1
				strreq = 40
				DamageMin = 25
				DamageMax = 30
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sintinberochin
				name = "Saint & Sage (Tinberochin)"
				//description = "<center><font color = #ffd700><b>Amethyst (Large Axe):</b>  40-50 Damage, +12 Str, +8 Int, 38 strength required"
				//icon_state = "sintinberochin"
				weapon_name = "tinberochin"
				Worth = 450
				typi = "weapon"
				wpnspd = 0
				wlvl = 2
				twohanded = 1
				strreq = 38
				DamageMin = 30
				DamageMax = 40
				STRbonus = 6
				SPRTbonus = 8
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(30,90)
						var/ad1 = ", +[HEALTHbonus] Health"
						ENERGYbonus = rand(30,90)
						var/ad2 = ", +[ENERGYbonus] Energy"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//tinberochin done
			avgkatar
				name = "Bronze (Katar)"
				//description = "<font color = #8C7853><center><b>Dull (Katar):</b><br>4-7 Damage<br>16 Strength-Req<br>Worth 93"
				//icon_state = "avgkatar"
				weapon_name = "katar"
				Worth = 93
				typi = "weapon"
				wpnspd = 10
				wlvl = 2
				twohanded = 1
				strreq = 12
				DamageMin = 8
				DamageMax = 14
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unukatar
				name = "Stalactite (Katar)"
				//description = "<center><b>Battle Axe:</b>  34-39 damage, two-handed, 55 strength required, Worth: 925"
				//icon_state = "unukatar"
				weapon_name = "katar"
				Worth = 125
				typi = "weapon"
				wpnspd = 12
				wlvl = 2
				twohanded = 1
				strreq = 16
				DamageMin = 14
				DamageMax = 19
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncokatar
				name = "Horn (Katar)"
				//description = "<font color = #ffd700><center><b>Soar (Battle Axe):</b>  68-78 Damage, two-handed, +20 Strength, 55 strength required"
				//icon_state = "uncokatar"
				weapon_name = "katar"
				Worth = 170
				typi = "weapon"
				wpnspd = 15
				wlvl = 2
				twohanded = 1
				strreq = 14
				DamageMin = 18
				DamageMax = 23
				STRbonus = 3
				SPRTbonus = 4
				//rarity = "{Unusual}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(1,500)
						var/ad1 = ", +[HEALTHbonus] Health"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choikatar
				name = "Scissor (Katar)"
				//description = ""
				//icon_state = "choikatar"
				weapon_name = "katar"
				Worth = 225
				typi = "weapon"
				wpnspd = 18
				wlvl = 2
				twohanded = 1
				strreq = 18
				DamageMin = 24
				DamageMax = 29
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordikatar
				name = "Copper (Katar)"
				//description = "<center><b>Wand:</b>  15-16 damage, 20 strength required, Worth: 215"
				//icon_state = "ordikatar"
				weapon_name = "katar"
				Worth = 215
				typi = "weapon"
				wpnspd = 16
				wlvl = 2
				twohanded = 1
				strreq = 17
				DamageMin = 25
				DamageMax = 26
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinkatar
				name = "Brass (Katar)"
				//description = "<font color = #ffd700><center><b>Ruby (Wand):</b>  30-32 Damage,+3 Str, +17 Int, 20 strength required"
				//icon_state = "sinkatar"
				weapon_name = "katar"
				Worth = 460
				typi = "weapon"
				wpnspd = 1
				wlvl = 2
				twohanded = 1
				strreq = 20
				DamageMin = 30
				DamageMax = 32
				STRbonus = 3
				SPRTbonus = 17
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						FIREres = rand(20,30)
						var/ad1 = ", +[FIREres] Fire Proof"
						HEALTHbonus = rand(20,60)
						var/ad2 = ", +[HEALTHbonus] Health"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//katar finished
			avgvoulge
				name = "Bronze (Voulge)"
				//description = "<font color = #8C7853><center><b>Dull (Voulge):</b><br>13-24 Damage<br>28 Strength-Req<br>Two-Handed<br>Worth 175"
				//icon_state = "avgvoulge"
				weapon_name = "voulge"
				Worth = 175
				typi = "weapon"
				wpnspd = 3
				wlvl = 2
				twohanded = 1
				strreq = 18
				DamageMin = 13
				DamageMax = 24
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuvoulge
				name = "Clan (Voulge)"
				//description = "<center><b>Power Staff:</b>  16-22 damage, two-handed, 22 strength required, Worth: 200"
				//icon_state = "unuvoulge"
				weapon_name = "voulge"
				Worth = 200
				typi = "weapon"
				wpnspd = 4
				wlvl = 2
				twohanded = 1
				strreq = 22
				DamageMin = 16
				DamageMax = 25
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncovoulge
				name = "Hook (Voulge)"
				//description = "<font color = #ffd700><center><b>Conflagration (Power Staff):</b>  32-44 Damage, two-handed, +6 Str, +14 Int, 22 strength required"
				//icon_state = "uncovoulge"
				weapon_name = "voulge"
				Worth = 300
				typi = "weapon"
				wpnspd = 3
				wlvl = 2
				twohanded = 1
				strreq = 24
				DamageMin = 22
				DamageMax = 26
				STRbonus = 4
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						FIREres = rand(5,10)
						var/ad1 = ", +[FIREres] Fire Proof"
						ENERGYbonus = rand(1,500)
						var/ad2 = ", +[ENERGYbonus] Energy"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choivoulge
				name = "Iron (Voulge)"
				//description = ""
				//icon_state = "choivoulge"
				weapon_name = "voulge"
				Worth = 400
				typi = "weapon"
				wpnspd = 6
				wlvl = 2
				twohanded = 1
				strreq = 22
				DamageMin = 20
				DamageMax = 30
				STRbonus = 6
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordivoulge
				name = "Copper (Voulge)"
				//description = "<center><b>Rapier:</b>  48-51 damage, 70 strength required, Worth: 1625"
				//icon_state = "ordivoulge"
				weapon_name = "voulge"
				Worth = 525
				typi = "weapon"
				wpnspd = 8
				wlvl = 3
				twohanded = 1
				strreq = 26
				DamageMin = 28
				DamageMax = 34
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinvoulge
				name = "Brass (Voulge)"
				//description = "<font color = #ffd700><center><b>Element (Rapier):</b>  96-102 damage, +15 Str, +25 Int, 70 strength required"
				//icon_state = "sinvoulge"
				weapon_name = "voulge"
				Worth = 600
				typi = "weapon"
				wpnspd = 10
				wlvl = 3
				twohanded = 1
				strreq = 30
				DamageMin = 36
				DamageMax = 42
				SPRTbonus = 5
				STRbonus = 5
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEATbonus = rand(15,25)
						var/ad1 = ", +[HEATbonus] Heat"
						SHARDBURSTbonus = rand(15,25)
						var/ad2 = ", +[SHARDBURSTbonus] Shard Burst"
						WATbonus = rand(15,25)
						var/ad3 = ", +[WATbonus] Water Shock"
						FLAMEbonus = rand(5,15)
						var/ad4 = ", +[FLAMEbonus] Flame"
						ICESTORMbonus = rand(5,15)
						var/ad5 = ", +[ICESTORMbonus] Ice Storm"
						CASCADELIGHTNINGbonus = rand(5,15)
						var/ad6 = ", +[CASCADELIGHTNINGbonus] Cascade Lightning"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>[ad4]<br>[ad5]<br>[ad6]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//voulge finished
			avgrakkakubo
				name = "Blunt (Rakkakubo)"
				//description = "<font color = #8C7853><center><b>Studded (Rakkakubo):</b><br>16-26 Damage<br>36 Strength-Req<br>Two-Handed<br>Worth 175"
				//icon_state = "avgrakkakubo"
				weapon_name = "rakkakubo"
				Worth = 175
				typi = "weapon"
				wpnspd = 2
				wlvl = 3
				twohanded = 1
				strreq = 23
				DamageMin = 26
				DamageMax = 26
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unurakkakubo
				name = "Studded (Rakkakubo)"
				//description = "<center><b>Batblade:</b>  56-59 damage, 82 strength required, Worth: 2250"
				//icon_state = "unurakkakubo"
				weapon_name = "rakkakubo"
				Worth = 250
				typi = "weapon"
				wpnspd = 4
				wlvl = 3
				twohanded = 1
				strreq = 28
				DamageMin = 26
				DamageMax = 29
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncorakkakubo
				name = "Iron (Rakkakubo)"
				//description = "<font color = #ffd700><center><b>Bat's Seizure (Batblade):</b>  112-118 damage, +40 Strength, 82 strength required"
				//icon_state = "uncorakkakubo"
				weapon_name = "rakkakubo"
				Worth = 200
				typi = "weapon"
				wpnspd = 1
				wlvl = 3
				twohanded = 1
				strreq = 32
				DamageMin = 32
				DamageMax = 38
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						EARTHres = rand(15,30)
						var/ad1 = ", +[EARTHres] Earth Proof"
						BLUDGEONbonus = rand(20,30)
						var/ad2 = ", +[BLUDGEONbonus] Bludgeon"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choirakkakubo
				name = "Club (Rakkakubo)"
				//description = ""
				//icon_state = "choirakkakubo"
				weapon_name = "rakkakubo"
				Worth = 320
				typi = "weapon"
				wpnspd = 6
				wlvl = 3
				twohanded = 1
				strreq = 28
				DamageMin = 28
				DamageMax = 31
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordirakkakubo
				name = "Strike (Rakkakubo)"
				//description = "<center><b>Jade Staff:</b>  61-65 damage, 63 strength required, Worth: 3400"
				//icon_state = "ordirakkakubo"
				weapon_name = "rakkakubo"
				Worth = 340
				typi = "weapon"
				wpnspd = 4
				wlvl = 3
				twohanded = 1
				strreq = 33
				DamageMin = 31
				DamageMax = 35
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinrakkakubo
				name = "Brass Plate (Rakkakubo)"
				//description = "<font color = #ffd700><center><b>Jade Whirl (Jade Staff):</b>  122-130 damage, 63 strength required"
				//icon_state = "sinrakkakubo"
				weapon_name = "rakkakubo"
				Worth = 600
				typi = "weapon"
				wpnspd = 6
				wlvl = 3
				twohanded = 1
				strreq = 43
				DamageMin = 42
				DamageMax = 50
				SPRTbonus = 5
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						ENERGYbonus = rand(50,150)
						var/ad1 = ", +[ENERGYbonus] Energy"
						ICEres = rand(15,30)
						var/ad2 = ", +[ICEres] Ice Proof"
						WATres = rand(15,30)
						var/ad3 = ", +[WATres] Water Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[ad1]<br>[ad2]<br>[ad3]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//rakkakubo finished
			avgkama
				name = "Harvest (Kama)"
				//description = "<font color = #8C7853><center><b>Harvest (Kama):</b><br>11-13 Damage<br>18 Strength-Req<br>Worth 80"
				//icon_state = "avgkama"
				weapon_name = "kama"
				Worth = 60
				typi = "weapon"
				wpnspd = 7
				wlvl = 3
				twohanded = 1
				strreq = 12
				DamageMin = 11
				DamageMax = 13
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unukama
				name = "Trim (Kama)"
				//description = "<center><b>Triadic Orb:</b>  74-78 damage, two-handed, 77 strength required, Worth: 3750"
				//icon_state = "unukama"
				weapon_name = "kama"
				Worth = 80
				typi = "weapon"
				wpnspd = 8
				wlvl = 3
				twohanded = 1
				strreq = 10
				DamageMin = 14
				DamageMax = 18
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncokama
				name = "Thrash (Kama)"
				//description = "<font color = #ffd700><center><b>Kaleidoscope (Triadic Orb):</b>  148-156 damage, two-handed, +7 Str, +33 Int, 77 strength required"
				//icon_state = "uncokama"
				weapon_name = "kama"
				Worth = 90
				typi = "weapon"
				wpnspd = 10
				wlvl = 3
				twohanded = 1
				strreq = 14
				DamageMin = 18
				DamageMax = 22
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(150,250)
						var/ad1 = ", +[HEALTHbonus] Health"
						var/resroll = rand(20,30)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/ad2 = ", +[resroll] Omni-Proof"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choikama
				name = "Edge (Kama)"
				//description = "A (Kama) with an Edge!<br><font color = #8C7853><center><b>Edge (Kama):</b><br>174-195 Damage<br>52 Strength-Req<br>Worth 175"
				//icon_state = "choikama"
				weapon_name = "kama"
				Worth = 105
				typi = "weapon"
				wpnspd = 14
				wlvl = 3
				twohanded = 1
				strreq = 12
				DamageMin = 24
				DamageMax = 25
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordikama
				name = "Copper (Kama)"
				//description = "<center><b>Icicle Blade:</b>  80-85 damage, two-handed, 118 strength required, Worth: 7860"
				//icon_state = "ordikama"
				weapon_name = "kama"
				Worth = 160
				typi = "weapon"
				wpnspd = 16
				wlvl = 3
				twohanded = 1
				strreq = 18
				DamageMin = 23
				DamageMax = 28
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinkama
				name = "Brass (Kama)"
				//description = "<font color = #ffd700><center><b>Blade of Karim (Icicle Blade):</b>  160-170 damage, two-handed, Increased Attack Speed, +35 Str, +5 Int, 118 strength required"
				//icon_state = "sinkama"
				weapon_name = "kama"
				Worth = 240
				typi = "weapon"
				wpnspd = 24
				wlvl = 3
				twohanded = 1
				strreq = 20
				DamageMin = 30
				DamageMax = 38
				SPRTbonus = 5
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					if(usr!=null)
						ENERGYbonus = rand(200,300)
						var/ad1 = ", +[ENERGYbonus] Energy"
						BLUDGEONbonus = rand(20,35)
						var/ad2 = ", +[BLUDGEONbonus] Bludgeon"
						COSMOSbonus = rand(5,10)
						var/ad3 = ", +[COSMOSbonus] Cosmos"
						var/resroll = rand(1,10)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/ad4 = ", +[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[ad1]<br>[ad2]<br>[ad3]<br>[ad4]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//kama finished
			avgwakizashi
				name = "Rustic (Wakizashi)"
				//description = "<font color = #8C7853><center><b>Rustic (Wakizashi):</b><br>7-17 Damage<br>21 Strength-Req<br>Worth 100"
				//icon_state = "avgwakizashi"
				weapon_name = "wakizashi"
				Worth = 100
				typi = "weapon"
				wpnspd = 5
				wlvl = 3
				twohanded = 1
				strreq = 18
				DamageMin = 14
				DamageMax = 17
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuwakizashi
				name = "Heirloom (Wakizashi)"
				//description = "<center><b>Scorching Sword:</b>  94-97 damage, two-handed, 144 strength required, Worth: 12000"
				//icon_state = "unuwakizashi"
				weapon_name = "wakizashi"
				Worth = 120
				typi = "weapon"
				wpnspd = 7
				wlvl = 3
				twohanded = 1
				strreq = 20
				DamageMin = 24
				DamageMax = 27
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncowakizashi
				name = "Keepsake (Wakizashi)"
				//description = "<font color = #ffd700><center><b>Scourge (Scorching Sword):</b>  188-194 damage, two-handed, +24 Str, +16 Int, 144 strength required"
				//icon_state = "uncowakizashi"
				weapon_name = "wakizashi"
				Worth = 140
				typi = "weapon"
				wpnspd = 8
				wlvl = 3
				twohanded = 1
				strreq = 19
				DamageMin = 24
				DamageMax = 28
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(250,350)
						var/ad1 = ", +[HEALTHbonus] Health"
						ENERGYbonus = rand(150,250)
						var/ad2 = ", +[ENERGYbonus] Energy"
						ACIDbonus = rand(10,15)
						var/ad3 = ", +[ACIDbonus] Acid"
						WATres = rand(20,30)
						var/ad4 = ", +[WATres] Water Proof"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[ad1]<br>[ad2]<br>[ad3]<br>[ad4]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choiwakizashi
				name = "Iron (Wakizashi)"
				//description = "A (Wakizashi) with an Edge!<br><font color = #8C7853><center><b>Edge (Wakizashi):</b><br>290-334 Damage<br>58 Strength-Req<br>Worth 186"
				//icon_state = "choiwakizashi"
				weapon_name = "wakizashi"
				Worth = 186
				typi = "weapon"
				wpnspd = 7
				wlvl = 3
				twohanded = 1
				strreq = 26
				DamageMin = 28
				DamageMax = 34
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordiwakizashi
				name = "Copper (Wakizashi)"
				//description = "<font color = #4682b4><center><b>Steel Sword:</b>  174-195 damage, two-handed, 240 strength required, Worth: 46000"
				//icon_state = "ordiwakizashi"
				weapon_name = "wakizashi"
				Worth = 220
				typi = "weapon"
				wpnspd = 10
				wlvl = 4
				twohanded = 1
				strreq = 24
				DamageMin = 24
				DamageMax = 35
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinwakizashi
				name = "Brass (Wakizashi)"
				//description = "<font color = #4682b4><center><b>The Mmbahfather (Steel Sword):</b>  348-390 damage, one-handed, Increased Attack Speed, +60 Str, +20 Int,  240 strength required"
				//icon_state = "sinwakizashi"
				weapon_name = "wakizashi"
				Worth = 310
				typi = "weapon"
				wpnspd = 15
				wlvl = 4
				twohanded = 1
				strreq = 30
				DamageMin = 28
				DamageMax = 39
				SPRTbonus = 5
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus = rand(600,1000)
						var/ad1 = ", +[HEALTHbonus] Health"
						ENERGYbonus = rand(600,1000)
						var/ad2 = ", +[ENERGYbonus] Energy"
						QUIETUSbonus = rand(5,10)
						var/ad3 = ", +[QUIETUSbonus] Quietus"
						var/resroll = rand(24,33)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/ad4 = ", +[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>[ad1]<br>[ad2]<br>[ad3]<br>[ad4]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//wakizashi done
			avgnagamaki
				name = "Worn (Nagamaki)"
				//description = "<font color = #8C7853><center><b>Worn (Nagamaki):</b><br>9-23 Damage<br>24 Strength-Req<br>Two-Handed<br>Worth 100"
				//icon_state = "avgnagamaki"
				weapon_name = "nagamaki"
				Worth = 100
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 24
				DamageMin = 9
				DamageMax = 23
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ununagamaki
				name = "Bronze (Nagamaki)"
				//description = "<font color = #ffd700><center><b>Gold Sword:</b>  170-178 damage, 195 strength required, Worth: 60000"
				//icon_state = "ununagamaki"
				weapon_name = "nagamaki"
				Worth = 120
				typi = "weapon"
				wpnspd = 2
				wlvl = 4
				twohanded = 1
				strreq = 25
				DamageMin = 10
				DamageMax = 26
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unconagamaki
				name = "Ceremonial (Nagamaki)"
				//description = ""
				//icon_state = "unconagamaki"
				weapon_name = "nagamaki"
				Worth = 160
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 25
				DamageMin = 12
				DamageMax = 28
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choinagamaki
				name = " (Nagamaki)"
				//description = "<font color = #ffd700><center><b>Gold Wand:</b>  142-148 damage, 95 strength required, Worth: 32000"
				//icon_state = "choinagamaki"
				weapon_name = "nagamaki"
				Worth = 200
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 28
				DamageMin = 16
				DamageMax = 30
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordinagamaki
				name = "Copper (Nagamaki)"
				//description = ""
				//icon_state = "ordinagamaki"
				weapon_name = "nagamaki"
				Worth = 220
				typi = "weapon"
				wpnspd = 7
				wlvl = 4
				twohanded = 1
				strreq = 30
				DamageMin = 22
				DamageMax = 34
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinnagamaki
				name = "Brass (Nagamaki)"
				//description = "<font color = #ffd700><center><b>Gold Staff:</b>  160-171 damage, two-handed, 112 strength required, Worth: 35000"
				//icon_state = "sinnagamaki"
				weapon_name = "nagamaki"
				Worth = 250
				typi = "weapon"
				wpnspd = 8
				wlvl = 4
				twohanded = 1
				strreq = 32
				DamageMin = 26
				DamageMax = 37
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//Nagamaki done
			avgtachi
				name = "Relic (Tachi)"
				//description = "<font color = #8C7853><center><b>Relic (Tachi):</b><br>11-19 Damage<br>28 Strength-Req<br>Two-Handed<br>Worth 100"
				//icon_state = "avgtachi"
				weapon_name = "tachi"
				Worth = 140
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 18
				DamageMin = 11
				DamageMax = 19
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unutachi
				name = "Worn (Tachi)"
				//description = "<font color = #ffd700><center><b>Gold Axe:</b>  290-334 damage, two-handed, 380 strength required, Worth: 98000"
				//icon_state = "unutachi"
				weapon_name = "tachi"
				Worth = 200
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 22
				DamageMin = 19
				DamageMax = 23
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncotachi
				name = "Bronze (Tachi)"
				//description = ""
				//icon_state = "uncotachi"
				weapon_name = "tachi"
				Worth = 210
				typi = "weapon"
				wpnspd = 5
				wlvl = 4
				twohanded = 1
				strreq = 26
				DamageMin = 26
				DamageMax = 30
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choitachi
				name = "Iron (Tachi)"
				//description = ""
				//icon_state = "choitachi"
				weapon_name = "tachi"
				Worth = 250
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 30
				DamageMin = 29
				DamageMax = 34
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			orditachi
				name = "Copper (Tachi)"
				//description = ""
				//icon_state = "orditachi"
				weapon_name = "tachi"
				Worth = 300
				typi = "weapon"
				wpnspd = 7
				wlvl = 4
				twohanded = 1
				strreq = 33
				DamageMin = 36
				DamageMax = 40
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sintachi
				name = "Brass (Tachi)"
				//description = ""
				//icon_state = "sintachi"
				weapon_name = "tachi"
				Worth = 340
				typi = "weapon"
				wpnspd = 8
				wlvl = 4
				twohanded = 1
				strreq = 38
				DamageMin = 42
				DamageMax = 50
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//tachi done
			avguchigatana
				name = "Bronze (Uchigatana)"
				//description = "Seems to be a fairly old Uchigatana.<br><font color = #8C7853><center><b>Rusty (Uchigatana):</b><br>170-178 Damage<br>Two-Handed<br>52 Strength-Req<br>Worth 93"
				//icon_state = "avguchigatana"
				weapon_name = "uchigatana"
				Worth = 100
				typi = "weapon"
				wpnspd = 1
				wlvl = 4
				twohanded = 1
				strreq = 30
				DamageMin = 20
				DamageMax = 28
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuuchigatana
				name = "Relic (Uchigatana)"
				//description = ""
				//icon_state = "unuuchigatana"
				weapon_name = "uchigatana"
				Worth = 140
				typi = "weapon"
				wpnspd = 2
				wlvl = 4
				twohanded = 1
				strreq = 38
				DamageMin = 30
				DamageMax = 44
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncouchigatana
				name = "Regent (Uchigatana)"
				//description = ""
				//icon_state = "uncouchigatana"
				weapon_name = "uchigatana"
				Worth = 200
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 40
				DamageMin = 40
				DamageMax = 48
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choiuchigatana
				name = "Iron (Uchigatana)"
				//description = ""
				//icon_state = "choiuchigatana"
				weapon_name = "uchigatana"
				Worth = 260
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 50
				DamageMin = 50
				DamageMax = 64
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordiuchigatana
				name = "Copper (Uchigatana)"
				//description = ""
				//icon_state = "ordiuchigatana"
				weapon_name = "uchigatana"
				Worth = 300
				typi = "weapon"
				wpnspd = 5
				wlvl = 4
				twohanded = 1
				strreq = 58
				DamageMin = 60
				DamageMax = 74
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinuchigatana
				name = "Brass (Uchigatana)"
				//description = ""
				//icon_state = "sinuchigatana"
				weapon_name = "uchigatana"
				Worth = 400
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 60
				DamageMin = 70
				DamageMax = 84
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//uchigatana done
			avgnaginata
				name = "Relic (Naginata)"
				//description = "An Old Relic.<br><font color = #8C7853><center><b>Relic (Naginata):</b><br>142-184 Damage<br>Two-Handed<br>38 Strength-Req<br>Worth 166"
				//icon_state = "avgnaginata"
				weapon_name = "naginata"
				Worth = 166
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 20
				DamageMin = 22
				DamageMax = 24
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ununaginata
				name = "Ceremonial (Naginata)"
				//description = ""
				//icon_state = "ununaginata"
				weapon_name = "naginata"
				Worth = 200
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 22
				DamageMin = 24
				DamageMax = 28
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unconaginata
				name = "Bronze (Naginata)"
				//description = ""
				//icon_state = "unconaginata"
				weapon_name = "naginata"
				Worth = 240
				typi = "weapon"
				wpnspd = 0
				wlvl = 4
				twohanded = 1
				strreq = 26
				DamageMin = 29
				DamageMax = 34
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choinaginata
				name = "Iron (Naginata)"
				//description = ""
				//icon_state = "choinaginata"
				weapon_name = "naginata"
				Worth = 300
				typi = "weapon"
				wpnspd = 5
				wlvl = 4
				twohanded = 1
				strreq = 32
				DamageMin = 32
				DamageMax = 38
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordinaginata
				name = "Copper (Naginata)"
				//description = ""
				//icon_state = "ordinaginata"
				weapon_name = "naginata"
				Worth = 340
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 38
				DamageMin = 40
				DamageMax = 44
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinnaginata
				name = "Brass (Naginata)"
				//description = ""
				//icon_state = "sinnaginata"
				weapon_name = "naginata"
				Worth = 400
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 40
				DamageMin = 40
				DamageMax = 54
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//naginata done
			avghakkakubo
				name = "Hardwood (Hakkakubo)"
				//description = "Hard wood Hakkakubo.<br><font color = #8C7853><center><b>Hard (Hakkakubo):</b><br>160-201 Damage<br>Two-Handed<br>66 Strength-Req<br>Worth 156"
				//icon_state = "avghakkakubo"
				weapon_name = "hakkakubo"
				Worth = 156
				typi = "weapon"
				wpnspd = 1
				wlvl = 4
				twohanded = 1
				strreq = 26
				DamageMin = 16
				DamageMax = 20
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unuhakkakubo
				name = "Blunt (Hakkakubo)"
				//description = ""
				//icon_state = "unuhakkakubo"
				weapon_name = "hakkakubo"
				Worth = 180
				typi = "weapon"
				wpnspd = 2
				wlvl = 4
				twohanded = 1
				strreq = 30
				DamageMin = 19
				DamageMax = 24
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncohakkakubo
				name = "Club (Hakkakubo)"
				//description = ""
				//icon_state = "uncohakkakubo"
				weapon_name = "hakkakubo"
				Worth = 200
				typi = "weapon"
				wpnspd = 3
				wlvl = 4
				twohanded = 1
				strreq = 36
				DamageMin = 29
				DamageMax = 34
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choihakkakubo
				name = "Studded (Hakkakubo)"
				//description = ""
				//icon_state = "choihakkakubo"
				weapon_name = "hakkakubo"
				Worth = 240
				typi = "weapon"
				wpnspd = 4
				wlvl = 4
				twohanded = 1
				strreq = 38
				DamageMin = 30
				DamageMax = 44
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordihakkakubo
				name = "Bout (Hakkakubo)"
				//description = ""
				//icon_state = "ordihakkakubo"
				weapon_name = "hakkakubo"
				Worth = 280
				typi = "weapon"
				wpnspd = 5
				wlvl = 4
				twohanded = 1
				strreq = 40
				DamageMin = 40
				DamageMax = 54
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4862b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinhakkakubo
				name = "Brass Plate (Hakkakubo)"
				//description = ""
				//icon_state = "sinhakkakubo"
				weapon_name = "hakkakubo"
				Worth = 300
				typi = "weapon"
				wpnspd = 6
				wlvl = 4
				twohanded = 1
				strreq = 50
				DamageMin = 50
				DamageMax = 64
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//hakkakubo done
			avgkatana
				name = "Worn (Katana)"
				//description = "<font color = #ffd700><b>Katana (Average):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "avgkatana"
				weapon_name = "katana"
				Worth = 100
				typi = "weapon"
				wpnspd = 8
				wlvl = 1
				twohanded = 1
				strreq = 14
				DamageMin = 20
				DamageMax = 26
				STRbonus = 2
				SPRTbonus = 3
				//rarity = "{Average}"
				New()
					SetRank(rank||1)
					//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			unukatana
				name = "Bronze (Katana)"
				//description = "<font color = #ffd700><b>Katana (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "unukatana"
				weapon_name = "katana"
				Worth = 200
				typi = "weapon"
				wpnspd = 12
				wlvl = 1
				twohanded = 1
				strreq = 18
				DamageMin = 22
				DamageMax = 28
				STRbonus = 5
				SPRTbonus = 6
				//rarity = "{Unusual}"
				New()
					SetRank(rank||2)
					//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			uncokatana
				name = "Relic (Katana)"
				//description = "<font color = #ffd700><b>Katana (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "uncokatana"
				weapon_name = "katana"
				Worth = 300
				typi = "weapon"
				wpnspd = 14
				wlvl = 1
				twohanded = 1
				strreq = 22
				DamageMin = 26
				DamageMax = 30
				STRbonus = 7
				SPRTbonus = 8
				//rarity = "{Uncommon}"
				New()
					SetRank(rank||3)
					//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						var/resroll = rand(10,30)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = ", +[resroll] Omni-Proof"
						description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			choikatana
				name = "Iron (Katana)"
				//description = "<font color = #ffd700><b>Katana (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "choikatana"
				weapon_name = "katana"
				Worth = 400
				typi = "weapon"
				wpnspd = 16
				wlvl = 1
				twohanded = 1
				strreq = 26
				DamageMin = 30
				DamageMax = 36
				STRbonus = 8
				SPRTbonus = 10
				//rarity = "{Choice}"
				New()
					SetRank(rank||4)
					//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ordikatana
				name = "Copper (Katana)"
				//description = "<font color = #ffd700><b>Katana (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "ordikatana"
				weapon_name = "katana"
				Worth = 500
				typi = "weapon"
				wpnspd = 18
				wlvl = 1
				twohanded = 1
				strreq = 28
				DamageMin = 34
				DamageMax = 38
				STRbonus = 9
				SPRTbonus = 9
				//rarity = "{Ordinary}"
				New()
					SetRank(rank||5)
					//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sinkatana
				name = "Brass (Katana)"
				//description = "<font color = #ffd700><b>Katana (Blade):</b>  20-26 Damage,+5 Str, +6 Int, 14 strength required"
				//icon_state = "sinkatana"
				weapon_name = "katana"
				Worth = 600
				typi = "weapon"
				wpnspd = 22
				wlvl = 1
				twohanded = 1
				strreq = 34
				DamageMin = 40
				DamageMax = 46
				STRbonus = 10
				SPRTbonus = 10
				//rarity = "{Singular}"
				New()
					SetRank(rank||6)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						var/resroll = rand(10,30)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/addd1 = ", +[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[addd1]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
	//katana done



			sumasamune
				name = "Balance (Masamune)"
				//description = "<font color = #ffd700><b>~Masamune (Singular, Umbral)~</b><br>420-840 Damage<br>Two-Handed<br>+Attack Speed<br>+64 Strength<br>+84 Spirit<br>Zero Strength Required<br>(Weightless - Umbral effect)"
				icon_state = "sumasamune"
				Worth = 0
				typi = "weapon"
				wpnspd = 11
				wlvl = 7
				twohanded = 1
				strreq = 0
				DamageMin = 420
				DamageMax = 840
				SPRTbonus = 84
				STRbonus = 64
				//rarity = "{Singular}"
				New()
					SetRank(rank||7)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					if(usr!=null)
						HEALTHbonus = rand(420,840)
						var/ad1 = "+[HEALTHbonus] Health"
						ENERGYbonus = rand(420,840)
						var/ad2 = "+[ENERGYbonus] Energy"
						BLUDGEONbonus = rand(13,37)
						var/ad3 = "+[BLUDGEONbonus] Bludgeon"
						var/resroll = rand(42,84)
						FIREres = resroll
						ICEres = resroll
						WINDres = resroll
						WATres = resroll
						EARTHres = resroll
						var/ad4 = "+[resroll] Omni-Proof"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>[ad4]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			sumuramasa
				name = "Curse (Muramasa)"
				//description = "<font color = #ffd700><center><b>Muramasa (Singular, Oni):</b><br>640-940 Damage<br>Two-Handed<br>+Attack Speed<br>74 Strength-Req"
				icon_state = "sumuramasa"
				Worth = 0
				typi = "weapon"
				wpnspd = 13
				wlvl = 7
				twohanded = 1
				strreq = 74
				DamageMin = 640
				DamageMax = 940
				//rarity = "{Singular}"
				New()
					SetRank(rank||7)
					//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					if(usr!=null)
						HEALTHbonus -= rand(30,40)
						var/ad1 = "+[ENERGYbonus] Energy"
						ACIDbonus = rand(42,84)
						var/ad2 = "+[ACIDbonus] Acid"
						WATbonus = rand(13,37)
						var/ad3 = "+[WATbonus] Water Shock"
						description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>Weapon Level [wlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[ad1]<br>[ad2]<br>[ad3]<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
//specials done
