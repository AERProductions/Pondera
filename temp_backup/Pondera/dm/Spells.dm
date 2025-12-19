/*var/blood
blood = image('blood.dmi',E.loc)
usr << blood*/
mob/players
	/*Click(mob/players/M)      //When the mob Clicks into another mob
		var/mob/players/J = usr
		if (istype(M,/mob/players)&&(waiter>0))    //If the mob is an enemy...
			J.Attack(M)
		else
			sleep(J.attackspeed)
		if(stamina>MAXstamina)
			stamina=MAXstamina
		if(stamina<0)
			stamina=0
			..()
		if(Attack(J))
			waiter = 0
			J<<"Don't want to do that."
		if(J.stamina==0)			//Calling this again... Some screwy stuff could happen.
			waiter = 0
			J<<"Your stamina is too low."*/

	var // enemy variables
		lucregive; Speed; Unique=0;
		fireres=0; iceres=0; watres=0; poisres=0; earthres=0; windres=0;
		firewk=0; icewk=0; watwk=0; poiswk=0; earthwk=0; windwk=0
		hasspells=0;
obj/spells // these are the actual magi icons that get created and moved around
	icon = 'dmi/64/magi.dmi'
			//lightS.update()
	//r/obj/items/ancscrlls/heat/H
	//H = locate(world.contents)//view(world.contents)
	chainlightning //m
		icon_state = "chainlightning"
		layer = MOB_LAYER+1
	cascadelightning //m
		icon_state = "cascadelightning"
		layer = MOB_LAYER+1
	heat //m
		icon_state = "heat"
		//layer = MOB_LAYER+1
		//light = new/light/circle

		//layer = MOB_LAYER+1
		//ght = new /light/circle()
			//light.loc = src.loc
			//lightS.update()

				// we make the lamps have directional light sources,
				// the /light/directional object is defined at the
				// top of this file.
			//new /light/directional(loc, 8)
			//light.dir = SOUTH
			//new /light/circle
			//light.mobile = 1
			// we make the lamps have directional light sources,
			// the /light/directional object is defined at the
			// top of this file.
			//new /light/circle(src, 2)
			//new /light/circle(src, 3)
			//light.on = 1
	icestorm //m
		icon_state = "icestorm"
		layer = MOB_LAYER+1
	shardburst //m
		icon_state = "shardburst"
		layer = MOB_LAYER+1
	watershock //m
		icon_state = "watershock"
		layer = MOB_LAYER+1
	acid //f
		icon_state = "acid"
		layer = MOB_LAYER+1
	vitae1 //f
		icon_state = "vitae1"
		layer = MOB_LAYER+1
		New()
			..()
			//new /light/circle(src,2)
	vitae2 //t
		icon_state = "vitae2"
		layer = MOB_LAYER+1
	manahealing //?
		icon_state = "manaheal"
		layer = MOB_LAYER+1
	gmanahealing //?
		icon_state = "gmanaheal"
		layer = MOB_LAYER+1
	cosmos //m
		icon_state = "cosmos"
		layer = MOB_LAYER+1
	abjure //t
		icon_state = "abjure"
		layer = MOB_LAYER+1
	rephase //?
		icon_state = "rephase"
		layer = MOB_LAYER+1
	toxin //?
		icon_state = "toxin"
		layer = MOB_LAYER+1
	bludgeon //f
		icon_state = "bludgeon"
		layer = MOB_LAYER+1
	quietus //m
		icon_state = "quietus"
		layer = MOB_LAYER+1
	panacea //t
		icon_state = "panacea"
		layer = MOB_LAYER+1
mob/players
	verb
		vitae()//party spells
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			VitaE()
		vitaeII()//party spells
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			VitaE2()
		telekinesis()//obj/M as obj in oview(5) //this no longer uses that parameter, it gets whatever it feels like getting so that there is no GUI
				//set category = "Spells"
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			TelekinesiS()
		abjure()
				//set category = "Spells"
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			AbjurE()

		panacea()
				//set category = "Spells"
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			PanaceA()
		//Vitae()//party spells
			//set popup_menu = 1
			//set category="Spells"//hidden = 1
			//VitaE()
		acid()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			AciD()
		bludgeon()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			BludgeoN()
//mob/players
	//verb
		heat()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			HeaT()
		shardburst()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			ShardBursT()
		watershock()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			WatershocK()
		flame()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			FlamE()
		icestorm()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			IceStorM()
		cascadelightning()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			CascadeLightninG()
		rephase()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			RephasE()
		cosmos()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			CosmoS()
		quietus()
			set popup_menu = 1
			set category=null//"Spells"//hidden = 1
			QuietuS()


//mob/players
//	verb
		//VitaeII()//party spells
			//set popup_menu = 1
			//set category="Spells"//hidden = 1
			//VitaE2()
		//abjure(var/M in forts)
			//set category = "Spells"
			//set popup_menu = 1
			//set category="Spells"//hidden = 1
			//AbjurE(M)
		//panacea()
			//set category = "Spells"
			//set popup_menu = 1
			//set category="Spells"//hidden = 1
			//PanaceA()

mob/players/proc
	spelllvlcheck(var/mob/players/M)//fixed.
		M = usr
		if(M.heatlevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Heat","is-visible=true")
			return
			//winset(M,"default.Heatbar","is-visible=true")
			//winset(M,"default.Heatbarlabel","is-visible=true")
		else if(M.heatlevel==0)
			winset(M,"default.Heat","is-visible=false")
			return
		else if(M.shardburstlevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Shardburst","is-visible=true")
			return
			//winset(M,"default.Shardburstbar","is-visible=true")
			//winset(M,"default.Shardburstbarlabel","is-visible=true")
		else if(M.shardburstlevel==0)
			winset(M,"default.Shardburst","is-visible=false")
			return
		else if(M.watershocklevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Watershock","is-visible=true")
			return
			//winset(M,"default.Watershockbar","is-visible=true")
			//winset(M,"default.Watershockbarlabel","is-visible=true")
		else if(M.watershocklevel==0)
			winset(M,"default.Watershock","is-visible=false")
			return
		else if(M.cosmoslevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Cosmos","is-visible=true")
			return
			//winset(M,"default.Cosmosbar","is-visible=true")
			//winset(M,"default.Cosmosbarlabel","is-visible=true")
		else if(M.cosmoslevel==0)
			winset(M,"default.Cosmos","is-visible=false")
			return
		else if(M.quietuslevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Quietus","is-visible=true")
			return
			//winset(M,"default.Quietusbar","is-visible=true")
			//winset(M,"default.Quietusbarlabel","is-visible=true")
		else if(M.quietuslevel==0)
			winset(M,"default.Quietus","is-visible=false")
			return
		else if(M.flamelevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Flame","is-visible=true")
			return
			//winset(M,"default.Flamebar","is-visible=true")
			//winset(M,"default.Flamebarlabel","is-visible=true")
		else if(M.flamelevel==0)
			winset(M,"default.Flame","is-visible=false")
			return
		else if(M.icestormlevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Icestorm","is-visible=true")
			return
			//winset(M,"default.IceStormbar","is-visible=true")
			//winset(M,"default.IceStormbarlabel","is-visible=true")
		else if(M.icestormlevel==0)
			winset(M,"default.Icestorm","is-visible=false")
			return
		else if(M.cascadelightninglevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Cascadelightning","is-visible=true")
			return
			//winset(M,"default.CascadeLightningbar","is-visible=true")
			//winset(M,"default.CascadeLightningbarlabel","is-visible=true")
		else if(M.cascadelightninglevel==0)
			winset(M,"default.Cascadelightning","is-visible=false")
			return
		else if(M.rephaselevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Rephase","is-visible=true")
			return
			//winset(M,"default.Rephasebar","is-visible=true")
			//winset(M,"default.Rephasebarlabel","is-visible=true")
		else if(M.rephaselevel==0)
			winset(M,"default.Rephase","is-visible=false")
			return
		else if(M.telekinesislevel>=1)//&&(src.char_class=="Magus"))
			winset(M,"default.Telekinesis","is-visible=true")
			return
		else if(M.telekinesislevel==0)
			winset(M,"default.Telekinesis","is-visible=false")
			return
		//if(M.char_class=="Magus")
		else if(M.vitaelevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Vitae","is-visible=true")
			return
			//winset(M,"default.Vitaebar","is-visible=true")
			//winset(M,"default.Vitaebarlabel","is-visible=true")
		else if(M.vitaelevel==0)
			winset(M,"default.Vitae","is-visible=false")
			return
		else if(M.acidlevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Acid","is-visible=true")
			return
			//winset(M,"default.Acidbar","is-visible=true")
			//winset(M,"default.Acidbarlabel","is-visible=true")
		else if(M.acidlevel==0)
			winset(M,"default.Acid","is-visible=false")
			return
		else if(M.bludgeonlevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Bludgeon","is-visible=true")
			return
			//winset(M,"default.Bludgeonbar","is-visible=true")
			//winset(M,"default.Bludgeonbarlabel","is-visible=true")
		else if(M.bludgeonlevel==0)
			winset(M,"default.Bludgeon","is-visible=false")
			return
		//if(M.char_class=="Magus")
		else if(M.panacealevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Panacea","is-visible=true")
			return
			//winset(M,"default.Panaceabar","is-visible=true")
			//winset(M,"default.Panaceabarlabel","is-visible=true")
		else if(M.panacealevel==0)
			winset(M,"default.Panacea","is-visible=false")
			return
		else if(M.abjurelevel>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Abjure","is-visible=true")
			return
			//winset(M,"default.Abjurebar","is-visible=true")
			//winset(M,"default.Abjurebarlabel","is-visible=true")
		else if(M.abjurelevel==0)
			winset(M,"default.Abjure","is-visible=false")
			return
		else if(M.vitae2level>=1)//&&(M.char_class=="Magus"))
			winset(M,"default.Vitae2","is-visible=true")
			return
			//winset(M,"default.VitaeIIbar","is-visible=true")
			//winset(M,"default.VitaeIIbarlabel","is-visible=true")
		else if(M.vitae2level==0)
			winset(M,"default.Vitae2","is-visible=false")
			return

mob/players/
	spells // healing spells


	proc/VitaE()//working?
		set waitfor = 0
		if(vitaelevel>0)
			if (stamina < 1+(vitaelevel*2)) // make sure you have enough stamina
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return
			else
				stamina -= 1+(vitaelevel*2) // take the stamina cost
				updateST()
				//this J list, C var, and M reference counter stuff is to find the people who can be targets of this magi
				var/list/J[1]
				var/C = 1
				var/mob/players/M
				for(M in view(5))
					if(istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				M = (input("Vitae","Who") as mob in J) // pick one of those people
				if(vitaelevel<15)
					missile(/obj/spells/vitae1,usr,M)
				else if(vitaelevel>50) // use a cooler magi icon if healing is 25+
					missile(/obj/spells/vitae2,usr,M)
				sleep(get_dist(usr,M)) // wait the distance traveled before displaying the amount healed
				var/amount = round(((rand(2+(vitaelevel*2),4+(vitaelevel*3)))*((Spirit/100)+1)),1) // healing amount calculations
				if (amount > (M.MAXHP-M.HP))
					amount = (M.MAXHP-M.HP) // only heal them to their maxhp, do not give them more.
				spawn()
					usr.overlays += image('dmi/64/magi.dmi',icon_state="vitae")
				M.HP += amount // bam! you are healed.
				M.updateHP()
				s_damage(M, amount, "#87ceed") // and now you know how much you were healed
				return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [vitaelevel])"
			return
			//this next line is deprecated by the above line
			//view(usr) << "[usr] cast Healing on [M]; <b>[amount] HP restored"
	proc/VitaE2()//working?
		set waitfor = 0
		if(vitae2level>0)
			if (stamina <1+(vitae2level*2)) // make sure you have enough stamina
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return
			else
				stamina -= 1+(vitae2level*2) // take the stamina cost
				updateST()
				//this J list, C var, and M reference counter stuff is to find the people who can be targets of this magi
				var/mob/players/M
				for(M in view(5))
					if(vitae2level<15)
						missile(/obj/spells/vitae1,usr,M)
					else if(vitae2level>50) // use a cooler magi icon if healing is 25+
						missile(/obj/spells/vitae2,usr,M)
					sleep(get_dist(usr,M)) // wait the distance traveled before displaying the amount healed
					var/amount = round(((rand(2+(vitaelevel*2),4+(vitaelevel*3)))*((Spirit/100)+1)),1) // healing amount calculations
					if (amount > (M.MAXHP-M.HP))
						amount = (M.MAXHP-M.HP) // only heal them to their maxhp, do not give them more.
					spawn(10)
						usr.overlays += image('dmi/64/magi.dmi',icon_state="vitaeII")
					M.HP += amount // bam! you are healed.
					M.updateHP()
					s_damage(M, amount, "#4682b4") // and now you know how much you were healed
					return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [vitae2level])"
			return
	proc/TelekinesiS()//working. for the most part
		var/obj/items/questitem/o
		var/obj/items/ancscrlls/TI = locate(oview(13,usr))
		var/list/J[2]
		var/C = 1
		J = list("Cancel","[C]")
		var/telecost = (telekinesislevel*4/2)
		if(telekinesislevel>0)
			if (telecost < 0)
				telecost = 0
			if (stamina < telecost)
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return
			for(TI in oview(13,usr))
				if (istype(M,/mob/players))
					J[C] = TI
					C++
					J.len++
					(input("Which object?") in TI)
				if(J[1]!=null)
					stamina -= telecost
					updateST()
				//this stuff is to find the nearby items to pick from
					TI.Move(usr)
					usr << "You move [TI] with your mind!"
					return
				//var/obj/M
					if(istype(o,/obj/items/questitem)) // if its questitem
						var/D=0 // used to only check your inventory until you find questitem, this logic is poorly written and inefficient
						//var/obj/items/o
						if(src.quest==0)
							for(o as obj in usr.contents)
								if(o.type==/obj/items/questitem&&D==0)
									D=1
									return
								else if(o.type==/obj/items/questitem)
									usr << "You don't need that"
									return
							if(D==0)
								TI.Move(usr)
								return
						else
							usr << "You don't need that"
							return

		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [telekinesislevel])"
			return
	/*proc/AbjurE(mob/players/M in world) // very useful, move people back to the beginning
		var/warpcost = 50-(abjurelevel*2)
		if (warpcost < 0)
			warpcost = 0
		if (stamina < warpcost)
			usr << "Low stamina."
		else
			if((input("Want to Restart [M]?") in list("Yes","No")) != "Yes")
				return
				if("Yes")
					if(M.needrev==1)
						for(M)
							if(M.location=="Sheol")
								stamina -= warpcost
								usr.overlays += /obj/spells/abjure // add the cool little color sparkles
								sleep(3) // wait a while
								M.loc = locate(627,64,2)
								//var/mob/players/A = usr
								M.location = "Aldoryn"
								M << "You get another chance..."
								spawn(3) overlays -= /obj/spells/abjure
								return
							if(M.location=="Holy Light")
								stamina -= warpcost
								usr.overlays += /obj/spells/abjure // add the cool little color sparkles
								sleep(3) // wait a while
								M.loc = locate(pick(421,413),pick(692,686),pick(2,2))
								//var/mob/players/A = usr
								M.location = "Aldoryn"
								M << "You have been revived, be more cautious!"
								spawn(3) overlays -= /obj/spells/abjure
								return

							if(M.location=="Aldoryn")
								usr<<"That spirit is still in this world..."
								return
					else
						if("No")
							usr << "You wait..."
							return*/
			//if(M==
			/*if(M=="")
				usr.loc = locate(/turf/)
				var/mob/players/A = usr
				A.location = ""
			if(M=="")
				usr.loc = locate(/turf/)
				var/mob/players/A = usr
				A.location = ""
			if(M=="")
				usr.loc = locate(/turf/)
				var/mob/players/A = usr
				A.location = ""*/
			 // get rid of the cool sparkles
	proc/AbjurE() //working? - Dual spell for revival (Abjure I) and home teleport (Abjure II)
		set waitfor = 0
		
		var/mob/players/caster = usr
		if(!caster || !caster.character) return
		
		// Check stamina cost (requires full stamina for revival magic)
		if(caster.stamina < caster.MAXstamina)
			caster << "Low stamina. You need full stamina to cast revival magic."
			return
		
		if(caster.abjurelevel <= 0)
			caster << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [abjurelevel])"
			return
		
		// Choose spell variant
		var/spell_choice = input(caster, "Choose spell variant:", "Abjure Spell") as null|anything in list("Abjure I - Revival", "Abjure II - Teleport Home", "Cancel")
		
		if(!spell_choice || spell_choice == "Cancel")
			return
		
		if(spell_choice == "Abjure I - Revival")
			AbjureRevival(caster)
		else if(spell_choice == "Abjure II - Teleport Home")
			AbjureTeleport(caster)

	proc/AbjureRevival(mob/players/caster)
		/**
		 * Abjure I - Revival Spell
		 * Revives a fainted player, preventing them from reaching permanent death
		 * Requires full stamina and abjurelevel > 0
		 */
		if(!caster || !death_penalty_manager) return
		
		// Cost: Full stamina
		caster.stamina = 0
		caster.updateST()
		
		// Visual effect
		caster.overlays += image('dmi/64/magi.dmi', icon_state="abjure")
		spawn(3) caster.overlays -= image('dmi/64/magi.dmi', icon_state="abjure")
		
		// Find fainted players to revive
		var/list/fainted = list()
		for(var/mob/players/M in oview(13, caster))
			if(M.character && M.character.is_fainted == 1)  // Only first-death faints
				fainted += M
		
		if(fainted.len == 0)
			caster << "There is nobody nearby who is fainted."
			return
		
		var/mob/players/target = null
		if(fainted.len == 1)
			target = fainted[1]
		else
			target = input(caster, "Whom do you want to revive?", "Select Target") as null|mob in fainted
		
		if(!target)
			return
		
		// Revive target
		death_penalty_manager.RevivePlayer(target, caster)

	proc/AbjureTeleport(mob/players/caster)
		/**
		 * Abjure II - Teleport to Home Point
		 * Teleports player to their set home_point location
		 * If no home_point is set, prompts to set one via compass
		 * Requires full stamina
		 */
		if(!caster || !caster.character) return
		
		// Check if home point is set
		if(!caster.character.home_point)
			caster << "You have no home point set."
			caster << "Visit a sundial during daytime to set your home point using the 'Set Home Point' option."
			return
		
		// Verify home point still exists and is valid
		if(!isturf(caster.character.home_point))
			caster << "Your home point location no longer exists!"
			caster.character.home_point = null
			return
		
		// Cost: Full stamina
		caster.stamina = 0
		caster.updateST()
		
		// Visual effect
		caster.overlays += image('dmi/64/magi.dmi', icon_state="abjure")
		spawn(3) caster.overlays -= image('dmi/64/magi.dmi', icon_state="abjure")
		
		// Teleport to home point
		var/turf/destination = caster.character.home_point
		caster.loc = destination
		caster << "<span class='good'>You return home...</span>"
		world << "<span class='info'>[caster.name] vanishes in a flash of light.</span>"

	proc/PanaceA(var/mob/players/M in oview(3)) //working?
		set waitfor = 0
		if(panacealevel>0)
			if (stamina <95+(panacealevel*5))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				stamina -= 95+(panacealevel*5)
				updateST()
				//var/mob/players/M
				for(M as mob in view(5)) // cast on everyone nearby
					if(istype(M,/mob/players)) // at least just the players anyway
						world << "<font color=#90ee90>[usr] casts Panacea on [M]!</font>"
						missile(/obj/spells/panacea,usr,M) // visuals
						sleep(get_dist(usr,M)) // wait until the visual gets to them
						var/lifeleft = M.MAXHP-M.HP // used for calculation
						var/perc = round(((panacealevel)*((Spirit/100)+1)),1) // calculate %
						if(perc>70) perc = 70 // only heal up to 70%
						var/amount = round(lifeleft*(perc/100),1) // set the number amount
						if (amount > (M.MAXHP-M.HP)) // make sure it isn't more than they need
							amount = (M.MAXHP-M.HP) // set it to what they need if it is
						M.HP += amount // healing time
						s_damage(M, amount, "#90ee90") // lovely numbers#660000red
						//no more poison either!
						M.poisonD=0
						M.poisoned=0
						M.poisonDMG=0
						M.overlays = null
						return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [panacealevel])"
			return


	spells // other spells
		verb

			Vitae()//party spells
				set popup_menu = 1
				set category=null//"Spells"//hidden = 1
				VitaE()
			VitaeII()//party spells
				set popup_menu = 1
				set category=null//"Spells"//hidden = 1
				VitaE2()
			Telekinesis()//obj/M as obj in oview(5) //this no longer uses that parameter, it gets whatever it feels like getting so that there is no GUI
				//set category = "Spells"
				set popup_menu = 1
				set category=null//"Spells"//hidden = 1
				TelekinesiS()
			Abjure(var/mob/players/M in world)
				//set category = "Spells"
				set popup_menu = 1
				set category=null//"Spells"//hidden = 1
				AbjurE(M)
			Panacea()
				//set category = "Spells"
				set popup_menu = 1
				set category=null//"Spells"//hidden = 1
				PanaceA()
			Heat()
				set popup_menu = 1
				set category = null//"Spells"
				HeaT()
			ShardBurst()
				set popup_menu = 1
				set category = null//"Spells"
				ShardBursT()
			WaterShock()
				set popup_menu = 1
				set category = null//"Spells"
				WatershocK()
			Flame()
				set popup_menu = 1
				set category = null//"Spells"
				FlamE()
			IceStorm()
				set popup_menu = 1
				set category = null//"Spells"
				IceStorM()
			CascadeLightning()
				set popup_menu = 1
				set category = null//"Spells"
				CascadeLightninG()
			Cosmos()
				set popup_menu = 1
				set category = null//"Spells"
				CosmoS()
			Rephase()
				set popup_menu = 1
				set category = null//"Spells"
				RephasE()
			Acid()
				set popup_menu = 1
				set category = null//"Spells"
				AciD()
			Quietus()
				set popup_menu = 1
				set category = null//"Spells"
				QuietuS()
			Bludgeon()
				set popup_menu = 1
				set category = null//"Spells"
				BludgeoN()


	proc/HeaT() //fixed?
		set waitfor = 0
		if (stamina < 17+(heatlevel*3))
			usr << "Low stamina."
			return
		if (stamina <= 0)
			usr << "Low stamina."
			return

		else
			//var/mob/players/pvptest=0
			var/mob/players/M = locate(oview(usr,3))
			var/mob/enemies/J = locate(oview(usr,3))
			var/damage = round(((rand(2+(flamelevel*2),4+(heatlevel*3)))*((Spirit/100)+1)),1) // calculate the dmg
			//check to make sure there is an enemy nearby
			//for ((M as mob in oview(5))&&(istype(M,/mob/players)))//&&(M.pvptest=1))
			if(heatlevel>0) // if there is an enemy nearby
				//stamina -= 17+(heatlevel*3) // decrement stamina by cost
				//updateST()
				//for (M as mob in oview(4)) // visually shoot every enemy within 4
					//if (istype(M,/mob/players))
						//missile(/obj/spells/heat,usr,M)
				sleep(5) // wait for 5
				//for (M as mob in oview(4)) // for each of those enemies just shot
					//if (istype(M,/mob/players)) // making sure it is an enemy to be sure
						//var/damage = round(((rand(2+(flamelevel*2),4+(flamelevel*3)))*((Spirit/100)+1)),1) // calculate the dmg
						//if(M) // making sure it is still there to be sure
							//adjusting damage based on weaknesses and resistances
							//var/mob/enemies/J
							//if (J.firewk>0)
							//	damage = round(damage*(1+(J.firewk/100)),1)
							//if (J.fireres>0)
							//	damage -= round(damage*(J.fireres/100),1)
							//deal the damage and show it
							//M.HP -= damage
							//s_damage(M, damage, "#ff4500")
				//var/mob/heat/H
				//var/H
				//H = new/light/circle(loc,1)//H = locate(oview(usr,13))
				//var/O
				//O = /obj/spells/heat
				// in oview(usr,13)
						//new H(/light/circle)//light/circle(src,1)
						//light.on(H)
				//if(H)
				//if(istype(H,/mob/heat)) //in view(13,src))
				//trying to get dyn light to work with heat magi
				//light.on()
				//missile(H,usr,J)
				//locate(H in oview(usr,13))
				//for(O in oview(src,13))
					//new H(O)//sleep(1)missile(H,usr,J)
				//everything within 2 of the hit enemy...
					//missile(O,H,J)
				//for(var/obj/spells/heat/O in block(locate(world.maxx, world.maxy, 2), locate(world.maxx, world.maxy, world.maxz)))

				for (J in oview(usr,13))
					if (istype(J,/mob/enemies))
						if (J.firewk>0)
							damage = round(damage*(1+(J.firewk/100)),1)
						if (J.fireres>0)
							damage -= round(damage*(J.fireres/100),1)
						stamina -= 17+(heatlevel*3) // decrement stamina by cost
						updateST()
						usr << "<font color=#660000>You shoot a fireball at [J]!</font>"
						missile(/obj/spells/heat,usr,J)

						// shoot at them too visually
						//for(locate(O in oview(src,13)))
							//spawn(light = new(O,3))
							//light.on(O)
							//overlays += image(/light/circle)
							//locate(O in oview(usr,13))
							//light.on = 1
						//J.overlays += image('dmi/64/fire.dmi',icon_state="ffire")
						//J.overlays += image('dmi/64/magi.dmi',icon_state="heat")
						//sleep(15)
						if(J.HP<=0)
							//J.overlays -= image('dmi/64/fire.dmi',icon_state="ffire")
							//J.overlays -= image('dmi/64/magi.dmi',icon_state="heat")
							call(/mob/enemies/proc/DeadEnemy)(J)
							return
						else
							J.HP -= damage
							//sleep(15)
							//J.overlays -= image('dmi/64/fire.dmi',icon_state="ffire")
							//J.overlays -= image('dmi/64/magi.dmi',icon_state="heat")
							s_damage(J, damage, "#ff4500")
							call(/mob/enemies/proc/DeadEnemy)(J)
							return
						//usr << "[E] has perished..."

							//everything within 2 of the hit enemy...
							//hit them with the fire magi as well
					else
						usr << "No targets in range."
						return
				for (M in oview(usr,13))
					if (istype(M,/mob/players))
						//damage = round(((rand(2+(flamelevel*2),4+(flamelevel*3)))*((Spirit/100)+1)),1)
						//if(M)heatlevel
						if (M.firewk>0)
							//M.overlays += image('dmi/64/creation.dmi',icon_state="heat")
							damage = round(damage*(1+(M.firewk/100)),1) //weakness damage increased
							//M.HP -= damage
						if (M.fireres>0)
							//M.overlays += image('dmi/64/creation.dmi',icon_state="heat")
							damage -= round(damage*(M.fireres/100),1) //resistance damage reduced
							//M.HP -= damage
						world << "<font color=#660000>[usr] shoots a fireball at [M]!</font>"
						missile(/obj/spells/heat,usr,M)
						//M.overlays += image('dmi/64/creation.dmi',icon_state="heat")
						//sleep(15)
						if(M.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/players/proc/checkdeadplayer2)(M)
							return
						else
							M.HP -= damage
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							s_damage(M, damage, "#ff4500")
							call(/mob/players/proc/checkdeadplayer2)(M)
							return
						//usr << "[M] has gone to the [M.location]..."
						return
										 // checking each enemy in the second round
							//DeadEnemy(M) // checking the original enemies
							//return
					else
						usr << "No targets in range."
						return
			else
				usr << "You simply cannot fathom how to cast such magi...(Magi Acuity: [heatlevel])"
				return

	proc/ShardBursT()//fixed.
		set waitfor = 0
		if(shardburstlevel>0)
			if (stamina < 3+(shardburstlevel*2))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(13,usr))
				var/mob/enemies/E = locate(oview(13,usr))
				for(M in oview(13,usr))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				if(J[1]!=null)
					stamina -= 3+(shardburstlevel*2)
					updateST()
					for(M in oview(13,usr))
						if(M.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/players/proc/checkdeadplayer2)(M)
							return
						else
							if(M in oview(13,usr))
								usr << "<font color =#f0f8ff>You slice [M] with Ice Shards!</font>"
								missile(/obj/spells/shardburst,usr,M)
								sleep(get_dist(usr,M))
							//M.overlays += image('dmi/64/magi.dmi',icon_state="icestorm")
							else return
							var/damage = round(((rand(1+(shardburstlevel*3),3+(shardburstlevel*3)))*((Spirit/100)+1)),1)

							if (M.icewk>0) // if it is weak against fire
								damage = round(damage*(1+(M.icewk/100)),1) // do more damage
							if (M.iceres>0) // if it has resistance to fire
								damage -= round(damage*(M.iceres/100),1) // do less damage
							if(M.HP<=0)
								//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
								call(/mob/players/proc/checkdeadplayer2)(M)
								return
							else
								M.HP -= damage // actually deal the damage
								//M.overlays -= image('dmi/64/magi.dmi',icon_state="icestorm")
								//updateHP()
								s_damage(M, damage, "#ff4500") // and show it
								//usr << "You cast FireBolt for \blue[damage] damage"
								call(/mob/players/proc/checkdeadplayer2)(M)
								//usr << "[E] has perished..."
								return

				for(E in oview(13,usr))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				if(J[1]!=null)//below is fixed
					stamina -= 3+(shardburstlevel*2)
					updateST()

					for(E in oview(13,usr))
						var/damage = round(((rand(1+(shardburstlevel*3),3+(shardburstlevel*3)))*((Spirit/100)+1)),1)
						if (E.icewk>0) // if it is weak against fire
							damage = round(damage*(1+(E.icewk/100)),1) // do more damage
						if (E.iceres>0) // if it has resistance to fire
							damage -= round(damage*(E.iceres/100),1) // do less damage
						if(E.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/enemies/proc/DeadEnemy)(E)
							return
						else
							if(E in oview(13,usr))
								usr << "<font color =#f0f8ff>You slice [E] with Ice Shards!</font>"
								missile(/obj/spells/shardburst,usr,E)
								sleep(get_dist(usr,E))

								//E.overlays += image('dmi/64/magi.dmi',icon_state="icestorm")



							//if(E.HP<=0)
								//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
								//call(/mob/enemies/proc/DeadEnemy)(E)

							//else
								for(E in oview(13,usr))
									E.HP -= damage // actually deal the damage
								//E.overlays -= image('dmi/64/magi.dmi',icon_state="icestorm")
								//updateHP()
									s_damage(E, damage, "#ff4500") // and show it
								//usr << "You cast FireBolt for \blue[damage] damage"
								//call(/mob/enemies/proc/DeadEnemy)(E)
								//usr << "[E] has perished..."
								//return
							else return
				else
					usr << "No targets in range..."
					return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [shardburstlevel])"
			return

	proc/WatershocK()//fixed.
		set waitfor = 0
		if(watershocklevel>0)///obj/spells/watershock watershocklevel watres watwk
			if (stamina < 5+(watershocklevel*2))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(13,usr))
				var/mob/enemies/E = locate(oview(13,usr))
				for(M in oview(13))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				//else
					//usr << "No targets in range..."
				if(J[1]!=null)
					stamina -= 5+(watershocklevel*2)
					updateST()
					for(M in oview(13,usr))
						if(M.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/players/proc/checkdeadplayer2)(M)
							return
						else
							world << "<font color=#ffffe0>[usr] sends electrified water towards [M]!</font>"
							missile(/obj/spells/watershock,usr,M)
							sleep(get_dist(usr,M))
							usr << "<font color=#ffffe0>You electrocute [M]!</font>"
						//missile(/obj/spells/watershock,usr,E)
						//sleep(get_dist(usr,E))
					var/damage = round(((rand(1,round((10+(watershocklevel*10.72)),1)))*((Spirit/100)+1)),1)
					for(M in oview(13,usr))
						if (M.watwk==null)
							return
						if (M.watres==null)
							return
						if (M.watwk>0)
							damage = round(damage*(1+(M.watwk/100)),1)
						if (M.watres>0)
							damage -= round(damage*(M.watres/100),1)
						if(M.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/players/proc/checkdeadplayer2)(M)
							return
						else
							M.HP -= damage
							M.updateHP()
							s_damage(M, damage, "#ff4500")
							//usr << "You cast LightningBolt for \blue[damage] damage"
							call(/mob/players/proc/checkdeadplayer2)(M)
							//usr << "[M] has gone to the [M.location]..."
							return
				for(E in oview(13))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				//else
					//usr << "No targets in range..."
				if(J[1]!=null)
					stamina -= 5+(watershocklevel*2)
					updateST()
					for(E in oview(13))
						world << "<font color=#ffffe0>[usr] sends electrified water towards [E]!</font>"
						missile(/obj/spells/watershock,usr,E)
						sleep(get_dist(usr,E))
						usr << "<font color=#ffffe0>You electrocute [E]!</font>"
						//missile(/obj/spells/watershock,usr,E)
						//sleep(get_dist(usr,E))
					var/damage = round(((rand(1,round((10+(watershocklevel*10.72)),1)))*((Spirit/100)+1)),1)
					for(E in oview(13,usr))
						if (E.watwk==null)
							return
						if (E.watres==null)
							return
						if (E.watwk>0)
							damage = round(damage*(1+(E.watwk/100)),1)
						if (E.watres>0)
							damage -= round(damage*(E.watres/100),1)
						if(E.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/enemies/proc/DeadEnemy)(E)
							return
						else
							E.HP -= damage
							//E.updateHP()
							s_damage(E, damage, "#ff4500")
							//usr << "You cast LightningBolt for \blue[damage] damage"
							call(/mob/enemies/proc/DeadEnemy)(E)
							//usr << "[M] has gone to the [M.location]..."
							return
				//else
					//usr << "No targets in range..."
					//return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [watershocklevel])"
			return
	proc/FlamE() //working.
		set waitfor = 0
		if (stamina < 17+(flamelevel*3))
			usr << "Low stamina."
			return
		if (stamina <= 0)
			usr << "Low stamina."
			return

		else
			//var/mob/players/pvptest=0
			var/mob/players/M
			var/mob/enemies/J
			var/damage = round(((rand(2+(flamelevel*2),4+(flamelevel*3)))*((Spirit/100)+1)),1) // calculate the dmg
			//check to make sure there is an enemy nearby
			//for ((M as mob in oview(5))&&(istype(M,/mob/players)))//&&(M.pvptest=1))
			if(flamelevel>0) // if there is an enemy nearby
				//stamina -= 17+(flamelevel*3) // decrement stamina by cost
				//updateST()
				//for (M as mob in oview(4)) // visually shoot every enemy within 4
					//if (istype(M,/mob/players))
						//missile(/obj/spells/heat,usr,M)
				sleep(5) // wait for 5
				//for (M as mob in oview(4)) // for each of those enemies just shot
					//if (istype(M,/mob/players)) // making sure it is an enemy to be sure
						//var/damage = round(((rand(2+(flamelevel*2),4+(flamelevel*3)))*((Spirit/100)+1)),1) // calculate the dmg
						//if(M) // making sure it is still there to be sure
							//adjusting damage based on weaknesses and resistances
							//var/mob/enemies/J
							//if (J.firewk>0)
							//	damage = round(damage*(1+(J.firewk/100)),1)
							//if (J.fireres>0)
							//	damage -= round(damage*(J.fireres/100),1)
							//deal the damage and show it
							//M.HP -= damage
							//s_damage(M, damage, "#ff4500")

							//sleep(1)
							//everything within 2 of the hit enemy...
				for (J in oview(usr,13))
					if (istype(J,/mob/enemies))
						if (J.firewk>0)
							damage = round(damage*(1+(J.firewk/100)),1)
						if (J.fireres>0)
							damage -= round(damage*(J.fireres/100),1)
						usr << "<font color=#660000>You spontaneously combust [J]!</font>"
						stamina -= 17+(flamelevel*3) // decrement stamina by cost
						updateST()
						missile(/obj/spells/heat,usr,J) // shoot at them too visually
						J.overlays += image('dmi/64/creation.dmi',icon_state="ffire")
						//sleep(15)
						if(J.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/enemies/proc/DeadEnemy)(J)
							return
						else
							J.HP -= damage
							//sleep(15)
							J.overlays -= image('dmi/64/creation.dmi',icon_state="ffire")
							s_damage(J, damage, "#ff4500")
							call(/mob/enemies/proc/DeadEnemy)(J)
							//usr << "[E] has perished..."
							return
							//everything within 2 of the hit enemy...
							//hit them with the fire magi as well
				for (M in oview(usr,13))
					if (istype(M,/mob/players))
						//damage = round(((rand(2+(flamelevel*2),4+(flamelevel*3)))*((Spirit/100)+1)),1)
						//if(M)
						if (M.firewk>0)
							M.overlays += image('dmi/64/creation.dmi',icon_state="ffire")
							damage = round(damage*(1+(M.firewk/100)),1) //weakness damage increased
							//M.HP -= damage
						if (M.fireres>0)
							M.overlays += image('dmi/64/creation.dmi',icon_state="ffire")
							damage -= round(damage*(M.fireres/100),1) //resistance damage reduced
							//M.HP -= damage
						world << "<font color=#660000>[usr] spontaneously combusts [M]!</font>"
						stamina -= 17+(flamelevel*3) // decrement stamina by cost
						updateST()
						missile(/obj/spells/heat,usr,M)
						M.overlays += image('dmi/64/creation.dmi',icon_state="ffire")
						//sleep(15)
						if(M.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/players/proc/checkdeadplayer2)(M)
							return
						else
							M.HP -= damage
							M.overlays -= image('dmi/64/creation.dmi',icon_state="ffire")
							s_damage(M, damage, "#ff4500")
							checkdeadplayer2(M)
							//usr << "[M] has gone to the [M.location]..."
							return
										 // checking each enemy in the second round
							//DeadEnemy(M) // checking the original enemies
							//return
			else
				usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [flamelevel])"
				return
	proc/IceStorM()//working, very fun, needs cool SFX
		set waitfor = 0
		if (stamina < 20+(icestormlevel*3))
			usr << "Low stamina."
			return
		if (stamina <= 0)
			usr << "Low stamina."
			return

		else
			//var/testmonsters=0
			var/mob/players/M
			var/mob/enemies/E
			//for (M as mob in view(5))
				//if (istype(M,/mob/players))
					//testmonsters=1
			if(icestormlevel>0) // making sure that there is at least 1 monster nearby
				stamina -= 20+(icestormlevel*3) // decrement stamina by cost
				updateST()
				world << "<font color =#f0f8ff>Ice flies in every direction!</font>"
				//lots of visual junk =]
				missile(/obj/spells/shardburst,usr,locate(usr.x,usr.y+5,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x,usr.y-5,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x+5,usr.y,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x-5,usr.y,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x+5,usr.y+5,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x-5,usr.y-5,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x+5,usr.y-5,usr.z))
				missile(/obj/spells/shardburst,usr,locate(usr.x-5,usr.y+5,usr.z))
				sleep(3)
				missile(/obj/spells/shardburst,locate(usr.x+5,usr.y,usr.z),locate(usr.x+3,usr.y+5,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x-5,usr.y,usr.z),locate(usr.x-3,usr.y-5,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x,usr.y-5,usr.z),locate(usr.x+5,usr.y-3,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x,usr.y+5,usr.z),locate(usr.x-5,usr.y+3,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x+1,usr.y-2,usr.z),locate(usr.x+2,usr.y+1,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x-2,usr.y-1,usr.z),locate(usr.x+1,usr.y-2,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x-1,usr.y+2,usr.z),locate(usr.x-2,usr.y-1,usr.z))
				missile(/obj/spells/shardburst,locate(usr.x+2,usr.y+1,usr.z),locate(usr.x-1,usr.y+2,usr.z))
				sleep(2)
				//for each enemy nearby
				for (E in oview(13))
					if (istype(E,/mob/enemies))
						//deal the calculated damage to it
						var/damage = round(((rand(3+(icestormlevel*3),4+(icestormlevel*3)))*((Spirit/100)+1)),1)
						if(E)
							//change damage according to weakness/resistance
							if (E.icewk>0)
								damage = round(damage*(1+(E.icewk/100)),1)
							if (E.iceres>0)
								damage -= round(damage*(E.iceres/100),1)
							//deal the damage, show the damage, and check to see if the enemy is dead
							world << "Hitting [E]!"
							if(E.HP<=0)
								//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
								call(/mob/enemies/proc/DeadEnemy)(E)
								return
							else
								E.HP -= damage
								s_damage(E, damage, "#ff4500")
								call(/mob/enemies/proc/DeadEnemy)(E)
								//usr << "[E] has perished..."
								return
				for (M in oview(13))
					if (istype(M,/mob/players))
						//deal the calculated damage to it
						var/damage = round(((rand(3+(icestormlevel*3),4+(icestormlevel*3)))*((Spirit/100)+1)),1)
						if(M)
							//change damage according to weakness/resistance
							if (M.icewk>0)
								damage = round(damage*(1+(M.icewk/100)),1)
							if (M.iceres>0)
								damage -= round(damage*(M.iceres/100),1)
							world << "Hitting [M]!"
							//deal the damage, show the damage, and check to see if the enemy is dead
							if(M.HP<=0)
								//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
								call(/mob/players/proc/checkdeadplayer2)(M)
								return
							else
								M.HP -= damage
								s_damage(M, damage, "#ff4500")
								checkdeadplayer2(M)
								//usr << "[M] has gone to the [M.location]..."
								return
			else
				usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [icestormlevel])"
				return
	proc/CascadeLightninG()//fixed!
		set waitfor = 0
		var/mob/enemies/U	=	locate(oview(13,src))
		var/mob/enemies/U2	=	locate(oview(13,src))
		var/mob/enemies/U3	=	locate(oview(13,src))
		var/mob/enemies/U4	=	locate(oview(13,src))
		var/mob/enemies/U5	=	locate(oview(13,src))
		var/mob/players/P	=	locate(oview(13,src))
		var/mob/players/P2	=	locate(oview(13,src))
		var/mob/players/P3	=	locate(oview(13,src))
		var/mob/players/P4	=	locate(oview(13,src))
		var/mob/players/P5	=	locate(oview(13,src))
				//make a list of all the nearby enemies
		var/stillcharged
		if(stillcharged==1)
			overlays += image('dmi/64/magi.dmi',icon_state="cascadelightning")
		//else
		//	overlays -= image('dmi/64/magi.dmi',icon_state="cascadelightning")
		if(cascadelightninglevel>0)
			var/K = 1
			var/list/J[1]
			//usr << "test"
			if (stamina < 23+(cascadelightninglevel*3))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return
			for (U in oview(src,13))
				if(istype(U,/mob/enemies) in oview(src,13))
					K++
					J[K] = U
					J.len++
			//if(U>0) // if theres at least 1 enemy in that list
				//U = J[1] // reference it with U
				if(U!=null) // making sure it exists and is an enemy
					usr << "<font color=#ffff00>You blast a cascade of lightning at [U]!</font>"
					stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
					updateST()
					missile(/obj/spells/cascadelightning,src,U) // visually shoot it
					sleep(get_dist(src,U)) // and wait until it gets there
					//var/mob/enemies // references to the next enemies to attack
					//	U2;U3;U4;U5;
					stillcharged=1
					var/damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
					var/cl
					cl = image('dmi/64/magi.dmi',src)
					//src << cl
					if (U) // if the enemy still exists
							//change dmg according to weaknesses/resistances
						if (U.watwk>0)
							damage = round(damage*(1+(U.watwk/100)),1)
						if (U.watres>0)
							damage -= round(damage*(U.watres/100),1)
						if(U.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/enemies/proc/DeadEnemy)(U)
							return
						else
							U.HP -= damage
							s_damage(U, damage, "#ffff00")
							return
					//find the next enemy within 6 of the enemy just shot
					K=0
					if(stillcharged==1)
						overlays += image('dmi/64/magi.dmi',icon_state="cascadelightning")
						usr << cl
					for (U2 in oview(13,U))
						if(istype(U2,/mob/enemies))
							K++
							J[K] = U2
							J.len++
					//if(U2>0) // if you found one
							//do the same thing to that one as well
						//U2 = J[1]
						if(U2!=null) // making sure it exists and is an enemy
							usr << "<font color=#ffff00>Lightning chains to [U2]!</font>"
							stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
							updateST()
							missile(/obj/spells/chainlightning,U,U2) // visually shoot it
							sleep(get_dist(U,U2)) // and wait until it gets there
							//var/mob/enemies // references to the next enemies to attack
							//	U2;U3;U4;U5;
							stillcharged=1
							damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
							if (U2) // if the enemy still exists
									//change dmg according to weaknesses/resistances
								if (U2.watwk>0)
									damage = round(damage*(1+(U2.watwk/100)),1)
								if (U2.watres>0)
									damage -= round(damage*(U2.watres/100),1)
								if(U2.HP<=0)
									//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
									call(/mob/enemies/proc/DeadEnemy)(U2)
									return
								else
									U2.HP -= damage
									s_damage(U2, damage, "#ffff00")
									return
						//keep finding the next enemy and so forth
						K=0
						for (U3 in oview(13,U2))
							if(istype(U3,/mob/enemies))
								K++
								J[K] = U3
								J.len++
						//if(K>0)
							//U3 = J[1]
							if(U3!=null) // making sure it exists and is an enemy
								usr << "<font color=#ffff00>Lightning chains to [U3]!</font>"
								stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
								updateST()
								missile(/obj/spells/chainlightning,U2,U3) // visually shoot it
								sleep(get_dist(U2,U3)) // and wait until it gets there
								//var/mob/enemies // references to the next enemies to attack
								//	U2;U3;U4;U5;
								stillcharged=1
								damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
								if (U3) // if the enemy still exists
										//change dmg according to weaknesses/resistances
									if (U3.watwk>0)
										damage = round(damage*(1+(U3.watwk/100)),1)
									if (U3.watres>0)
										damage -= round(damage*(U3.watres/100),1)
									if(U3.HP<=0)
										//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
										call(/mob/enemies/proc/DeadEnemy)(U3)
										return
									else
										U3.HP -= damage
										s_damage(U3, damage, "#ffff00")
										return
								K=0
								for (U4 in oview(13,U3))
									if(istype(U4,/mob/enemies))
										K++
										J[K] = U4
										J.len++
								//if(K>0)
									//U5 = J[1]
									if(U4!=null) // making sure it exists and is an enemy
										usr << "<font color=#ffff00>Lightning chains to [U4]!</font>"
										stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
										updateST()
										missile(/obj/spells/chainlightning,U3,U4) // visually shoot it
										sleep(get_dist(U3,U4)) // and wait until it gets there
										//var/mob/enemies // references to the next enemies to attack
										//	U2;U3;U4;U5;
										//stillcharged=1
										stillcharged=1
										damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
										if (U4) // if the enemy still exists
												//change dmg according to weaknesses/resistances
											if (U4.watwk>0)
												damage = round(damage*(1+(U4.watwk/100)),1)
											if (U4.watres>0)
												damage -= round(damage*(U4.watres/100),1)
											if(U4.HP<=0)
												//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
												call(/mob/enemies/proc/DeadEnemy)(U4)
												return
											else
												U4.HP -= damage
												s_damage(U4, damage, "#ffff00")
												return
									for (U5 in oview(13,U4))
										if(istype(U5,/mob/enemies))
											K++
											J[K] = U5
											J.len++
									//if(K>0)
										//U5 = J[1]
										if(U5!=null) // making sure it exists and is an enemy
											usr << "<font color=#ffff00>Lightning chains to [U5]!</font>"
											stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
											updateST()
											missile(/obj/spells/chainlightning,U4,U5) // visually shoot it
											sleep(get_dist(U4,U5)) // and wait until it gets there
											//var/mob/enemies // references to the next enemies to attack
											//	U2;U3;U4;U5;
											stillcharged=1
											damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
											if (U5) // if the enemy still exists
													//change dmg according to weaknesses/resistances
												if (U5.watwk>0)
													damage = round(damage*(1+(U5.watwk/100)),1)
												if (U5.watres>0)
													damage -= round(damage*(U5.watres/100),1)
												if(U5.HP<=0)
													//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
													call(/mob/enemies/proc/DeadEnemy)(U5)
													return
												else
													U5.HP -= damage
													s_damage(U5, damage, "#ffff00")
													stillcharged=0
													return
			for (P in oview(src,13))
				if(istype(P,/mob/players) in oview(src,13))
					K++
					J[K] = P
					J.len++
			//if(U>0) // if theres at least 1 enemy in that list
				//U = J[1] // reference it with U
				if(P!=null) // making sure it exists and is an enemy
					usr << "<font color=#ffff00>You blast a cascade of lightning at [P]!</font>"
					stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
					updateST()
					missile(/obj/spells/cascadelightning,src,P) // visually shoot it
					sleep(get_dist(src,P)) // and wait until it gets there
					//var/mob/enemies // references to the next enemies to attack
					//	P2;P3;P4;P5;
					stillcharged=1
					var/damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
					if (P) // if the enemy still exists
							//change dmg according to weaknesses/resistances
						if (P.watwk>0)
							damage = round(damage*(1+(P.watwk/100)),1)
						if (P.watres>0)
							damage -= round(damage*(P.watres/100),1)
						if(P.HP<=0)
							//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							call(/mob/players/proc/checkdeadplayer2)(P)
							return
						else
							P.HP -= damage
							P.updateHP()
							s_damage(P, damage, "#ffff00")
					//find the next enemy within 6 of the enemy just shot
					K=0
					for (P2 in oview(13,P))
						if(istype(P2,/mob/players))
							K++
							J[K] = P2
							J.len++
					//if(P2>0) // if you found one
							//do the same thing to that one as well
						//P2 = J[1]
						if(P2!=null) // making sure it exists and is an enemy
							usr << "<font color=#ffff00>Lightning chains to [P2]!</font>"
							stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
							updateST()
							missile(/obj/spells/chainlightning,P,P2) // visually shoot it
							sleep(get_dist(P,P2)) // and wait until it gets there
							//var/mob/enemies // references to the next enemies to attack
							//	P2;P3;P4;P5;
							damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
							if (P2) // if the enemy still exists
									//change dmg according to weaknesses/resistances
								if (P2.watwk>0)
									damage = round(damage*(1+(P2.watwk/100)),1)
								if (P2.watres>0)
									damage -= round(damage*(P2.watres/100),1)
								if(P2.HP<=0)
									//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
									call(/mob/players/proc/checkdeadplayer2)(P2)
									return
								else
									P2.HP -= damage
									P2.updateHP()
									s_damage(P2, damage, "#ffff00")
						//keep finding the next enemy and so forth
						K=0
						for (P3 in oview(13,P2))
							if(istype(P3,/mob/players))
								K++
								J[K] = P3
								J.len++
						//if(K>0)
							//P3 = J[1]
							if(P3!=null) // making sure it exists and is an enemy
								usr << "<font color=#ffff00>Lightning chains to [P3]!</font>"
								stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
								updateST()
								missile(/obj/spells/chainlightning,P2,P3) // visually shoot it
								sleep(get_dist(P2,P3)) // and wait until it gets there
								//var/mob/enemies // references to the next enemies to attack
								//	P2;P3;P4;P5;
								damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
								if (P3) // if the enemy still exists
										//change dmg according to weaknesses/resistances
									if (P3.watwk>0)
										damage = round(damage*(1+(P3.watwk/100)),1)
									if (P3.watres>0)
										damage -= round(damage*(P3.watres/100),1)
									if(P3.HP<=0)
										//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
										call(/mob/players/proc/checkdeadplayer2)(P3)
										return
									else
										P3.HP -= damage
										P3.updateHP()
										s_damage(P3, damage, "#ffff00")
								K=0
								for (P4 in oview(13,P3))
									if(istype(P4,/mob/players))
										K++
										J[K] = P4
										J.len++
								//if(K>0)
									//P5 = J[1]
									if(P4!=null) // making sure it exists and is an enemy
										usr << "<font color=#ffff00>Lightning chains to [P4]!</font>"
										stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
										updateST()
										missile(/obj/spells/chainlightning,P3,P4) // visually shoot it
										sleep(get_dist(P3,P4)) // and wait until it gets there
										//var/mob/enemies // references to the next enemies to attack
										//	P2;P3;P4;P5;
										stillcharged = 1
										damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
										if (P4) // if the enemy still exists
												//change dmg according to weaknesses/resistances
											if (P4.watwk>0)
												damage = round(damage*(1+(P4.watwk/100)),1)
											if (P4.watres>0)
												damage -= round(damage*(P4.watres/100),1)
											if(P4.HP<=0)
												//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
												call(/mob/players/proc/checkdeadplayer2)(P4)
												return
											else
												P4.HP -= damage
												P4.updateHP()
												s_damage(P4, damage, "#ffff00")
									for (P5 in oview(13,P4))
										if(istype(P5,/mob/players))
											K++
											J[K] = P5
											J.len++
									//if(K>0)
										//P5 = J[1]
										if(P5!=null) // making sure it exists and is an enemy
											usr << "<font color=#ffff00>Lightning chains to [P5]!</font>"
											stamina -= 23+(cascadelightninglevel*3) // decrement stamina by cost
											updateST()
											missile(/obj/spells/chainlightning,P4,P5) // visually shoot it
											sleep(get_dist(P4,P5)) // and wait until it gets there
											//var/mob/enemies // references to the next enemies to attack
											//	P2;P3;P4;P5;
											damage = round(((rand(1,round((10+(cascadelightninglevel*10.72)),1)))*((Spirit/100)+1)),1) // damage calculation
											if (P5) // if the enemy still exists
													//change dmg according to weaknesses/resistances
												if (P5.watwk>0)
													damage = round(damage*(1+(P5.watwk/100)),1)
												if (P5.watres>0)
													damage -= round(damage*(P5.watres/100),1)
												if(P5.HP<=0)
													//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
													call(/mob/players/proc/checkdeadplayer2)(P5)
													return
												else
													P5.HP -= damage
													P5.updateHP()
													s_damage(P5, damage, "#ffff00")
													stillcharged=0
													return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [cascadelightninglevel])"
			return
	proc/CosmoS()//steals enemy stamina. --fixed
		set waitfor = 0
		if(cosmoslevel>0)
			if (HP < 15+(cosmoslevel*5))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				//find the closes enemy
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(3,usr))
				var/mob/enemies/E = locate(oview(3,usr))
				for(M in oview(13))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				if(J[1]!=null) // if there is an enemy nearby
					if(HP<=0)
												//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
						call(/mob/players/proc/checkdeadplayer2)(usr)
						return
					else
						HP-=15+(cosmoslevel*5)
						updateHP()
						s_damage(usr, 15+(cosmoslevel*5), "#660000")
					M = J[1]
					var/amount = round(((rand(5+(cosmoslevel*3),10+(cosmoslevel*5)))*((Spirit/100)+1)),1) // calculate amount
					if (amount > (M.stamina))
						amount = (M.stamina)
					if (amount < 0)
						amount = 0
					missile(/obj/spells/cosmos,usr,M) // visual
					sleep(get_dist(usr,M)) // wait for the visual to get there
					s_damage(M, amount, "#4b7bdc")
					M.stamina -= amount // YOINK!
					M.updateST()
					var/damage = round((amount*(0.049*cosmoslevel)),1) // calculate the damage you'll take from doing this
					if (damage < 0)
						damage = 0
					missile(/obj/spells/manahealing,M,usr) //visual
					sleep(get_dist(M,usr)) // wait for the visual to get there
					if (damage > (MAXstamina-stamina))
						amount = (MAXstamina-stamina)
					if (damage < 0)
						damage = 0
					stamina += damage // ahhhhhh more stamina!
					updateST()
					s_damage(usr, damage, "#adff2f")
					if (stamina > MAXstamina)
						stamina = MAXstamina
					usr << "[M] been sapped of [damage] stamina!"
					usr << "Your stamina has been replenished. ([damage]+)"
					return
				//else
					//usr << "No targets in range..."
					//return
				for(E as mob in oview(13))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				if(J[1]!=null) // if there is an enemy nearby
					if(HP<=0)
												//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
						call(/mob/players/proc/checkdeadplayer2)(usr)
						return
					else
						HP-=15+(cosmoslevel*5)
						updateHP()
						s_damage(usr, 15+(cosmoslevel*5), "#660000")
					E = J[1]
					var/amount = round(((rand(5+(cosmoslevel*3),10+(cosmoslevel*5)))*((Spirit/100)+1)),1) // calculate amount
					if (amount > (E.stamina))
						amount = (E.stamina)
					if (amount < 0)
						amount = 0
					missile(/obj/spells/cosmos,usr,E) // visual
					sleep(get_dist(usr,E)) // wait for the visual to get there
					s_damage(E, amount, "#4b7bdc")
					E.stamina -= amount // YOINK!
					var/damage = round((amount*(0.049*cosmoslevel)),1) // calculate the damage you'll take from doing this
					if (damage < 0)
						damage = 0
					missile(/obj/spells/manahealing,E,usr) //visual
					sleep(get_dist(E,usr)) // wait for the visual to get there
					if (damage > (MAXstamina-stamina))
						amount = (MAXstamina-stamina)
					if (damage < 0)
						damage = 0
					stamina += damage // ahhhhhh more stamina!
					updateST()
					s_damage(usr, damage, "#adff2f")
					if (stamina > MAXstamina)
						stamina = MAXstamina
					usr << "[E] been sapped of [damage] stamina!"
					usr << "Your stamina has been replenished. ([damage]+)"
					return
				//else
					//usr << "No targets in range..."
					//return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [cosmoslevel])"
			return
	proc/RephasE() //damages enemy stamina and then attacks again based on that dmg -- fixed.

		if(rephaselevel>0)
			if (stamina < 15+(rephaselevel*5))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(3,usr))
				var/mob/enemies/E = locate(oview(3,usr))
				for(M in oview(5))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				if(J[1]!=null)
					stamina-=15+(rephaselevel*5)
					updateST()
					M = J[1]
					var/amount = round(((rand(5+(rephaselevel*3),10+(rephaselevel*5)))*((Spirit/1)+1)),1)
					if (amount > M.stamina)
						amount = M.stamina
					if (amount < M.stamina)
						amount = amount
					else
						if(amount <= 0)
							amount = 1
					missile(/obj/spells/rephase,usr,M)//stamina missile
					//sleep(get_dist(usr,M))
					M.overlays += image('dmi/64/magi.dmi',icon_state="rephase")
					M.stamina -= amount//damages enemy stamina
					s_damage(M, amount, "#4b7bdc")
					M.updateST()
					var/damage = round((amount*(9*rephaselevel)),1)
					if (damage <= 0)
						damage = 0
					else
						if(damage>M.stamina)
							amount=M.stamina
					damage = round(24*(sqrt(rephaselevel)))
					M.HP -= damage
					M.updateHP()
					s_damage(M, damage, "#ff4500")
					M.overlays -= image('dmi/64/magi.dmi',icon_state="rephase")
					//M.overlays += /obj/spells/rephase
					if(M)
						//M.overlays -= image('dmi/64/creation.dmi',icon_state="rephase")
						call(/mob/players/proc/checkdeadplayer2)(M)
						return
					//spawn(5)
						//M.overlays += image('dmi/64/magi.dmi',icon_state="rephase")
						//if(M.HP<=0)
													//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
							//call(/mob/players/proc/checkdeadplayer2)(M)
							//return
						//else

							//damage = round(24*(sqrt(rephaselevel)))
							//M.HP -= damage
							//M.updateHP()
							//s_damage(M, damage, "#ff4500")
							//call(/mob/players/proc/checkdeadplayer2)(M)
							//usr << "[E] has perished..."
							//return
				//else
					//usr << "No targets in range..."
					//return
				for(E in oview(13))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				if(J[1]!=null)
					stamina-=15+(rephaselevel*5)
					updateST()
					E = J[1]
					var/amount = round(((rand(5+(rephaselevel*3),10+(rephaselevel*5)))*((Spirit/1)+1)),1)
					if (amount > E.stamina)
						amount = E.stamina
					if (amount < E.stamina)
						amount = amount
					else
						if(amount <= 0)
							amount = 1
					missile(/obj/spells/rephase,usr,E)//stamina missile
					E.overlays += image('dmi/64/magi.dmi',icon_state="rephase")
					E.stamina -= amount//damages enemy stamina
					s_damage(E, amount, "#4b7bdc")
					var/damage = round((amount+(9*rephaselevel)),1)
					if (damage <= 0)
						damage = 0
					else
						if(damage>E.stamina)
							amount=E.stamina
					damage = round(24/(sqrt(rephaselevel)))
					E.overlays -= image('dmi/64/magi.dmi',icon_state="rephase")
					E.HP -= damage
					s_damage(E, damage, "#ff4500")
					//E.HP -= damage
					//sleep(get_dist(usr,E))
					//s_damage(E, amount, "#4b7bdc")
					//E.stamina -= amount//damages enemy stamina
					//E.overlays += image('dmi/64/magi.dmi',icon_state="rephase")

					//M.overlays += image('dmi/64/magi.dmi',icon_state="rephase")
					//M.overlays += /obj/spells/rephase
					//if(E)
						//E.overlays -= image('dmi/64/creation.dmi',icon_state="rephase")
						//call(/mob/enemies/proc/DeadEnemy)(E)
						//return
					//spawn(5)
						//E.overlays += image('dmi/64/magi.dmi',icon_state="rephase")
					if(E)
													//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
						call(/mob/enemies/proc/DeadEnemy)(E)
						return
					//else
						//damage = round(24*(sqrt(rephaselevel)))
							//E.HP -= damage
						//s_damage(E, damage, "#ff4500")
						//call(/mob/enemies/proc/DeadEnemy)(E)
							//usr << "[E] has perished..."
						//return
				else
					usr << "No targets in range..."
					return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [rephaselevel])"
			return
	proc/AciD() //fixed
		set waitfor = 0
		if(acidlevel>0)
			if (stamina < round(14*sqrt(acidlevel),1))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(usr,3))
				var/mob/enemies/E = locate(oview(usr,3))
				for(M in oview(13))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				if(J[1]!=null)
					stamina -= round(14*sqrt(acidlevel),1)
					updateST()
					M = J[1]
					missile(/obj/spells/acid,usr,M)
					//M.overlays += image('dmi/64/magi.dmi',icon_state="acid")
					sleep(get_dist(usr,M))
					//M.overlays += /obj/spells/acid
					M.overlays += image('dmi/64/magi.dmi',icon_state="acid")
					if(M.HP<=0)
						//spawn(3)
							//M.overlays += image('dmi/64/magi.dmi',icon_state="acid")
						//M.overlays -= image('dmi/64/magi.dmi',icon_state="acid")
					//else
						return
					var/D = round(4+(acidlevel/2),1) // duration
					//spawn while(D>0) M.overlays += image('dmi/64/magi.dmi',icon_state="acid")
					while(D>0)
						//this damage calculation should probably be outside of the loop, meh, inefficient, whatever. it is what it is.
						var/damage = round( rand(10*(sqrt(acidlevel*((Spirit/100)+1))),13*(sqrt(acidlevel*((Spirit/100)+1)))) , 1)
						if (M.poiswk>0)
							damage = round(damage*(1+(M.poiswk/100)),1)
						if (M.poisres>0)
							damage -= round(damage*(M.poisres/100),1)
						if(M.HP<=0)
							//M.overlays -= image('dmi/64/magi.dmi',icon_state="acid")
							call(/mob/players/proc/checkdeadplayer2)(M)
							//M.overlays = null
							return
						else
							//M.overlays -= image('dmi/64/magi.dmi',icon_state="acid")
							//M.overlays = null
							M.HP -= damage
							M.updateHP()
							s_damage(M, damage, "#800080")
							//sleep(10)

							D--
							checkdeadplayer2(M)
						//if(M)
							//M.overlays = null
							//usr << "[M] has gone to the [M.location]..."
							return

				//else
					//usr << "No targets in range..."
					//return
				for(E in oview(13))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				if(J[1]!=null)
					stamina -= round(14*sqrt(acidlevel),1)
					updateST()
					E = J[1]
					missile(/obj/spells/acid,usr,E)
					sleep(get_dist(usr,E))
					E.overlays += image('dmi/64/magi.dmi',icon_state="acid")
					//E.overlays += /obj/spells/acid
					if(E.HP<=0)
						//spawn(3)
							//E.overlays += image('dmi/64/magi.dmi',icon_state="acid")
						//E.overlays -= image('dmi/64/magi.dmi',icon_state="acid")
					//else
						//E.overlays = null
						return
					var/D = round(4+(acidlevel/2),1) // duration
					//E.overlays += image('dmi/64/magi.dmi',icon_state="acid")
					while(D>0)
						//this damage calculation should probably be outside of the loop, meh, inefficient, whatever. it is what it is.
						var/damage = round( rand(10*(sqrt(acidlevel*((Spirit/100)+1))),13*(sqrt(acidlevel*((Spirit/100)+1)))) , 1)
						if (E.poiswk>0)
							damage = round(damage*(1+(E.poiswk/100)),1)
						if (E.poisres>0)
							damage -= round(damage*(E.poisres/100),1)
						if(E.HP<=0)
							//E.overlays -= image('dmi/64/magi.dmi',icon_state="acid")
							call(/mob/enemies/proc/DeadEnemy)(E)
							return
						else
							//E.overlays -= image('dmi/64/magi.dmi',icon_state="acid")
							E.HP -= damage
							//E.updateHP()
							s_damage(E, damage, "#800080")
							//sleep(10)
							//call(/mob/enemies/proc/DeadEnemy)(E)
							D--
							call(/mob/enemies/proc/DeadEnemy)(E)
							//E.overlays = null
							//usr << "[E] has perished..."
							return

				else
					usr << "No targets in range..."
					return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [acidlevel])"
			return
	proc/BludgeoN() // just like the other bolts, but strength based.    and now its fixed.
		set waitfor = 0
		if(bludgeonlevel>0)
			if (stamina < 9+(bludgeonlevel*2))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(usr,13))
				var/mob/enemies/E = locate(oview(usr,13))
				for(M in oview(13))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				if(J[1]!=null)
					stamina -= 9+(bludgeonlevel*2)
					updateST()
					M = J[1]
					missile(/obj/spells/bludgeon,usr,M)
					//var/fistsoffury
					//fistsoffury = image('magi.dmi',"bludgeon",usr)
					//flick(fistsoffury,usr)
					var/fistsoffury
					fistsoffury = image('dmi/64/magi.dmi',"bludgeon1",M)
					//flick(fistsoffury,E)
					M.overlays += fistsoffury
					var/quickstrikes
					quickstrikes = image('dmi/64/magi.dmi',"bludgeon",M)
					M.overlays += quickstrikes
					if(M.HP<=0)
						//usr << "[M]'s dead, Jim."//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
						call(/mob/players/proc/checkdeadplayer2)(M)
						//var/blood
						//blood = image('blood.dmi',M.loc)
						//usr << blood

						return
					else
						//flick('blood.dmi',E.loc)//E.loc += image('dmi/64/creation.dmi',icon_state="heat")//new/obj/bloodspill(E.loc)
						sleep(get_dist(usr,M))
						var/damage = round(((rand(10+(bludgeonlevel*2),16+(bludgeonlevel*3)))*((Strength/100)+1)),1) // calculation based on strength
						for(M in oview(usr,3))
							if(M)
								if (M.earthwk>0)
									damage = round(damage*(1+(M.earthwk/100)),1)
								if (M.earthres>0)
									damage -= round(damage*(M.earthres/100),1)
								if(M.HP<=0)
									//usr << "[M]'s dead, Jim."//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
									call(/mob/players/proc/checkdeadplayer2)(M)
									//var/blood
									//blood = image('blood.dmi',M.loc)
									//usr << blood//potentially have to make a nobloodmode? silly people
									return
								else
									M.HP -= damage
									M.updateHP()
									s_damage(M, damage, "#ff4500")
									call(/mob/players/proc/checkdeadplayer2)(M)
									//var/blood
									//blood = image('blood.dmi',M.loc)
									//usr << blood
									//usr << "[E] has perished..."
									return
				//else
					//usr << "No targets in range..."
					//return
				//else
					//usr << "No targets in range..."
					//return
				for(E in oview(13))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				if(J[1]!=null)
					stamina -= 9+(bludgeonlevel*2)
					updateST()
					E = J[1]
					missile(/obj/spells/bludgeon,usr,E)
					//var/fistsoffury
					//fistsoffury = image('magi.dmi',"bludgeon",usr)
					//flick(fistsoffury,usr)
					var/fistsoffury
					fistsoffury = image('dmi/64/magi.dmi',"bludgeon1",E)
					//flick(fistsoffury,E)
					E.overlays += fistsoffury
					var/quickstrikes
					quickstrikes = image('dmi/64/magi.dmi',"bludgeon",E)
					E.overlays += quickstrikes
					//flick(quickstrikes,E)
					if(E.HP<=0)
						//usr << "[E]'s dead, Jim."//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
						//usr << blood
						call(/mob/enemies/proc/DeadEnemy)(E)
						//var/blood
						//E.loc << blood// = image('blood.dmi',E.loc)
						return
					else
						//flick('blood.dmi',E.loc)//E.loc += image('dmi/64/creation.dmi',icon_state="heat")//new/obj/bloodspill(E.loc)
						sleep(get_dist(usr,E))
						var/damage = round(((rand(10+(bludgeonlevel*2),16+(bludgeonlevel*3)))*((Strength/100)+1)),1) // calculation based on strength
						for(E in oview(usr,13))
							if(E)
								if (E.earthwk>0)
									damage = round(damage*(1+(E.earthwk/100)),1)
								if (E.earthres>0)
									damage -= round(damage*(E.earthres/100),1)
								if(E.HP<=0)
									//usr << "[E]'s dead, Jim."//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
									//usr << blood
									call(/mob/enemies/proc/DeadEnemy)(E)
									//E.loc << blood
									return
								else
									E.HP -= damage
									s_damage(E, damage, "#ff4500")
									//usr << blood
									call(/mob/enemies/proc/DeadEnemy)(E)
									//var/blood
									// = image('blood.dmi',E.loc)
									//usr << "[E] has perished..."
									return
				else
					usr << "No targets in range..."
					return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [bludgeonlevel])"
			return
	proc/QuietuS()//fixed -- its like demi, it calculates damage based on enemy stamina until it does 0, leaving you easy prey to claim -- alternately a nasty side bonus  if the damage calculated equates to more than the targets max HP it straight up kills them dead with one shot.
		set waitfor = 0
		if(quietuslevel>0)
			if (stamina < round(24*(sqrt(quietuslevel)),1))
				usr << "Low stamina."
				return
			if (stamina <= 0)
				usr << "Low stamina."
				return

			else
				var/list/J[1]
				var/C = 1
				var/mob/players/M = locate(oview(usr,3))
				var/mob/enemies/E = locate(oview(usr,3))
				for(M in oview(13))
					if (istype(M,/mob/players))
						J[C] = M
						C++
						J.len++
				if(J[1]!=null) // making sure that there is an enemy nearby
					stamina -= round(24*(sqrt(quietuslevel)),1) // decrementing stamina according to cost
					updateST()
					for(M in oview(13)) // casting demi on everything within 5
						if (istype(M,/mob/players)) // if it is an enemy of course
							missile(/obj/spells/quietus,usr,M) // visuals
							sleep(get_dist(usr,M))
							var/perc = round(rand(((sqrt(quietuslevel*Strength))/1),((sqrt(quietuslevel*Strength))/0.4)),1) // calculate percent
							if(perc>70)
								perc=70
							var/damage = M.HP * (perc/100) // calculate the damage
							if(M) // gotta make sure that it is still there
								if (M.earthwk>0)
									damage = round(damage*(1+(M.earthwk/100)),1)
								if (M.earthres>0)
									damage -= round(damage*(M.earthres/100),1)
								if(damage<0)
									damage = 0
								//if(damage>M.MAXHP)
									//damage = M.MAXHP
									//usr << "[damage] must be > than [M.MAXHP]"
								var/reduced = round(M.MAXstamina-((75*(0.5*quietuslevel))/50),1)
								if(reduced<=round(M.MAXstamina*0.1,1))
									reduced = round(M.MAXstamina*0.1,1)
								if(M.HP>=reduced)
									damage = perc
								if(damage>M.MAXHP)//too weak? you're gone
									damage = M.MAXHP+1
								if(M.HP<0)
															//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
									call(/mob/players/proc/checkdeadplayer2)(M)
									return
								//if(E.HP<=reduced)
								else
									M.HP -= damage
									M.updateHP()
									s_damage(M, damage, "#ff4500")
									call(/mob/players/proc/checkdeadplayer2)(M)
									//usr << "[E] has perished..."
									return
				//else
					//usr << "No targets in range..."
					//return
				for(E in oview(13))
					if (istype(E,/mob/enemies))
						J[C] = E
						C++
						J.len++
				if(J[1]!=null) // making sure that there is an enemy nearby
					stamina -= round(24*(sqrt(quietuslevel)),1) // decrementing stamina according to cost
					updateST()
					for(E in oview(13)) // casting demi on everything within 5
						if (istype(E,/mob/enemies)) // if it is an enemy of course
							missile(/obj/spells/quietus,usr,E) // visuals
							sleep(get_dist(usr,E))
							var/perc = round(rand(((sqrt(quietuslevel*Strength))/1),((sqrt(quietuslevel*Strength))/0.4)),1) // calculate percent
							if(perc>70)
								perc=70
							var/damage = E.HP * (perc/100) // calculate the damage
							if(E) // gotta make sure that it is still there
								if (E.earthwk>0)
									damage = round(damage*(1+(E.earthwk/100)),1)
								if (E.earthres>0)
									damage -= round(damage*(E.earthres/100),1)
								if(damage<0)
									damage = 0
								//if(damage>E.MAXHP)
									//damage = E.MAXHP+1
									//usr << "[damage] must be > than [E.MAXHP]"
								var/reduced = round(E.MAXstamina-((75*(0.5*quietuslevel))/50),1)
								if(reduced<=round(E.MAXstamina*0.1,1))
									reduced = round(E.MAXstamina*0.1,1)
								if(E.HP>=reduced)
									damage = perc
								if(damage>E.MAXHP)
									damage = E.MAXHP+1
								if(E.HP<0)
															//M.overlays -= image('dmi/64/creation.dmi',icon_state="heat")
									call(/mob/enemies/proc/DeadEnemy)(E)
									return
								//if(E.HP<=reduced)
								else
									E.HP -= damage
									s_damage(E, damage, "#ff4500")
									call(/mob/enemies/proc/DeadEnemy)(E)
									//usr << "[E] has perished..."
									return
				else
					usr << "No targets in range..."
					return
		else
			usr << "You simply cannot fathom how to cast such a magi...(Magi Acuity: [quietuslevel])"
			return

