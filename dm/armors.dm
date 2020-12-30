
obj
	items

		armors
			//yeah, this gets pretty wild
			icon = 'dmi/64/armor.dmi'
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
				alvl
				rarity = ""
					//world << "[src.STRbonus] STR [src.SPRTbonus] INT [src.FIREres] FIRE [src.ICEres] ICE [src.WINDres] LIT [src.POISres] POIS [src.EARTHres] DARK"
			//verbs to get items, description, equipping, etc on right click
			//the way i handled the equipping and changing of variables is a little whacked out, i don't like it much, but here it is
			/*
				usr << src.description*/
			/*verb/Get()
				set src in oview(1)
				//set hidden = 1
				set category=null
				set popup_menu=1
				var/mob/players/M = usr
				if(src.type==/obj/items/questitem)
					var/C=0
					var/obj/items/o
					if(M.quest==0)
						for(o as obj in M.contents)
							if(o.type==/obj/items/questitem&&C==0)
								C=1
							else if(o.type==/obj/items/questitem)
								M << "You don't need that"
						if(C==0)
							src.Move(usr)
					else
						M << "You don't need that"
				else
					var/obj/O = src
					set src in oview(1)
					for(O as obj in view(3)) // only people you can SEE
						if(istype(O,/obj))
							src.Move(usr)*/
			Click()
				set category = null
				set src in usr
				if(src.suffix=="Equipped")
					usr << "<font color = teal>That's already equipped!"
				else
					if (typi=="armor")
						if (usr.tempstr>=src.strreq)
							if(usr.Aequipped==0)
								src.suffix="Equipped"
								usr.Aequipped = 1
								usr.tempdefense += src.Adefense
								usr.tempevade += src.Aevade
								var/mob/players/M = usr
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
								usr << "<font color = teal>You are Already Wearing Armor."
						else
							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
			verb/Unequip()
				set hidden = 1
				set src in usr
				if(src.suffix!="Equipped")
					usr << "<font color = teal>That's not equipped!"
				else
					if (typi=="armor")
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
			verb
				/*Drop()
					set category = null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "<font color = teal>Un-equip [src] first!"
					else
						src.Move(usr.loc)*/
				Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
//need to clean this file up, add the armors into armor category like weapons
obj/items/armors
	var
		armor_name // or weapon class or whatever.  just a text string we use for the icon state
		rank		// the rank of the weapon (or rarity?)
		desc_color
		//hand

	proc
		SetRank(n)
			n = clamp(n, 1, 6)
			alvl *= n
			strreq *= n
			Adefense *= n
			Aevade *= n
			//description = "<br><font color = #8C7853><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage,<br>[strreq] Strength-Req<br>One-Hand<br>Worth [Worth]"
			rarity = "{[num2rarity(n)]}"
			icon_state = "[num2iconstate(n)][armor_name]"
			desc_color = "[num2desccolor(n)][desc_color]"
			description = "<br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Armor Level [alvl]<br>[Adefense] Armor Defense<br>[Aevade] Armor Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"


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






//| rating in code is from worse to best(least beneficial to most beneficial), actual armor ranking(not bitflag): 6(avg)=average, 5(unu)=unusual, 4(unco)=uncommon, 3(choi)=choice, 2(ordi)=ordinary  1(sin)=singular ||best to worse 1=singular, 2=ordinary, 3=choice, 4=uncommon, 5=unusual. 6=average
	icon = 'dmi/64/armor.dmi'
	avgvestments//|vestments monster parts armor may be expanded to cover all of the monster types -- the later variants mix parts and metals, but there could be a "leather working" monster parts variety as named below -- it would add many more armor options 6(Armor ratings)x5(armor types)x11(monster variants)=330 new armors for each type of monster and armor type and each armor ranking...wow! not to mention the random generated variants.
		name = "Giu Hide (Vestments)"
		//description = "<font color = #8C7853><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		//icon_state = "avgvestments"
		armor_name = "vestments"
		Worth = 13
		typi = "armor"
		alvl = 1
		strreq = 3
		Adefense = 2
		Aevade = 8
		//rarity = "{Average}"
		New()
			SetRank(rank||1)
			//description = "<font color = #8C7853><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	unuvestments
		name = "Giu Shell (Vestments)"
		//description = "<font color = #b87333><center><b><br>Unusual Giu Shell (Vestments):</b><br>4 Defense<br>7% Evasion<br>9 Strength-Req"
		//icon_state = "unuvestments"
		armor_name = "vestments"
		Worth = 24
		typi = "armor"
		alvl = 1
		strreq = 9
		Adefense = 4
		Aevade = 7
		//rarity = "{Unusual}"
		New()
			SetRank(rank||2)
			//description = "<font color = #b87333><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 8
		SPRTbonus = 8
		New()
			if(usr!=null)
				HEALTHbonus = rand(10,25)
				var/ad1 = "+[HEALTHbonus] Health"
				description = "<font color = #b87333><center><b><br>Giu Shell (Vestments):</b><br>15 Defense<br>8% Evasion<br>+18 Strength<br>+8 Spirit<br>[ad1]<br>9 Strength-Req"
	*/
	uncovestments
		name = "Gou ShellHide (Vestments)"
		//description = "<font color = #c0c0c0><center><b><br>Gou ShellHide (Vestments):</b><br>8 Defense<br>6% Evasion<br>12 Strength-Req"
		//icon_state = "uncovestments"
		armor_name = "vestments"
		Worth = 33
		typi = "armor"
		alvl = 1
		strreq = 12
		Adefense = 8
		Aevade = 6
		//rarity = "{Uncommon}"
		New()
			SetRank(rank||3)
			//description = "<font color = #c0c0c0><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	choivestments
		name = "Ironmail (Vestments)"
		//description = "<font color = #e6e8fa><center><b><br>Ironmail (Vestments):</b><br>13 Defense<br>4% Evasion<br>15 Strength-Req"
		//icon_state = "choivestments"
		armor_name = "vestments"
		Worth = 45
		typi = "armor"
		alvl = 1
		strreq = 15
		Adefense = 13
		Aevade = 4
		//rarity = "{Choice}"
		New()
			SetRank(rank||4)
			//description = "<font color = #e6e8fa><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	ordivestments
		name = "Copper ShellPlate (Vestments)"
		//description = "<font color= #4682b4><center><b><br>Copper ShellPlate (Vestments):</b><br>15 Defense<br>5% Evasion<br>14 Strength-Req"
		//icon_state = "ordivestments"
		armor_name = "vestments"
		Worth = 50
		typi = "armor"
		alvl = 1
		strreq = 14
		Adefense = 15
		Aevade = 5
		//rarity = "{Ordinary}"
		New()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 10
		SPRTbonus = 16
		New()
			if(usr!=null)
				WATres = rand(1,30)
				var/ad1 = "+[WATres] Water Proof"
				description = "<font color= #4682b4><center><b><br>Relief (Vestments):</b><br>18 Defense<br>9% Evasion<br>+7 Strength<br>+8 Spirit<br>[ad1]<br>18 Strength-Req"
	*/
	sinvestments
		name = "Zinc ShellPlate (Vestments)"
		//description = "<font color = #ffd700><center><b><br>Zinc ShellPlate (Vestments):</b><br>17 Defense<br>6% Evasion<br>13 Strength-Req"
		//icon_state = "sinvestments"
		armor_name = "vestments"
		Worth = 64
		typi = "armor"
		alvl = 1
		strreq = 13
		Adefense = 17
		Aevade = 6
		//rarity = "{Singular}"
		New()
			SetRank(rank||6)
			//description = "<font color = #ffd700><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
//vestments done
	avgtunic
		name = "Monk (Tunic)"
		//description = "<font color = #8C7853><center><b><br>Monk (Tunic):</b><br>5 Defense<br>8% Evasion<br>5 Strength-Req"
		//icon_state = "avgtunic"
		armor_name = "tunic"
		Worth = 17
		typi = "armor"
		alvl = 1
		strreq = 5
		Adefense = 6
		Aevade = 5
		//rarity = "{Average}"
		New()
			SetRank(rank||1)
			//description = "<font color = #8C7853><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	unutunic
		name = "Iron Studded (Tunic)"
		//description = "<font color = #b87333><center><b><br>Iron Studded (Tunic):</b><br>8 Defense<br>6% Evasion<br>10 Strength-Req"
		//icon_state = "unutunic"
		armor_name = "tunic"
		Worth = 24
		typi = "armor"
		alvl = 1
		strreq = 10
		Adefense = 8
		Aevade = 6
		//rarity = "{Unusual}"
		New()
			SetRank(rank||2)
			//description = "<font color = #b87333><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 18
		SPRTbonus = 8
		New()
			if(usr!=null)
				HEALTHbonus = rand(10,25)
				var/ad1 = "+[HEALTHbonus] Health"
				description = "<font color = #b87333><center><b><br>Iron Studded (Tunic):</b><br>15 Defense<br>8% Evasion<br>+18 Strength<br>+8 Spirit<br>[ad1]<br>9 Strength-Req"
	*/
	uncotunic
		name = "Copper ShellPlate (Tunic)"
		//description = "<font color = #c0c0c0><center><b><br>Copper ShellPlate (Tunic):</b><br>10 Defense<br>8% Evasion<br>9 Strength-Req"
		//icon_state = "uncotunic"
		armor_name = "tunic"
		Worth = 33
		typi = "armor"
		alvl = 1
		strreq = 9
		Adefense = 10
		Aevade = 8
		//rarity = "{Uncommon}"
		New()
			SetRank(rank||3)
			//description = "<font color = #c0c0c0><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	choitunic
		name = "Bronzemail (Tunic)"
		//description = "<font color = #e6e8fa><center><b><br>Bronzemail (Tunic):</b><br>13 Defense<br>7% Evasion<br>11 Strength-Req<br>Worth 45"
		//icon_state = "choitunic"
		armor_name = "tunic"
		Worth = 45
		typi = "armor"
		alvl = 1
		strreq = 11
		Adefense = 13
		Aevade = 7
		//rarity = "{Choice}"
		New()
			SetRank(rank||4)
			//description = "<font color = #e6e8fa><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	orditunic
		name = "Zincmail (Tunic)"
		//description = "<font color= #4682b4><center><b><br>Zincmail (Tunic):</b><br>15 Defense<br>9% Evasion<br>10 Strength-Req"
		//icon_state = "orditunic"
		armor_name = "tunic"
		Worth = 50
		typi = "armor"
		alvl = 1
		strreq = 10
		Adefense = 15
		Aevade = 9
		//rarity = "{Ordinary}"
		New()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 10
		SPRTbonus = 16
		New()
			if(usr!=null)
				WATres = rand(1,30)
				var/ad1 = "+[WATres] Water Proof"
				description = "<font color= #4682b4><center><b><br>Zincmail (Tunic):</b><br>18 Defense<br>9% Evasion<br>+7 Strength<br>+8 Spirit<br>[ad1]<br>18 Strength-Req"
	*/
	sintunic
		name = "Builder (Tunic)"
		//description = "<font color = #ffd700><center><b><br>Builder (Tunic):</b><br>17 Defense<br>8% Evasion<br>15 Strength-Req"
		//icon_state = "sintunic"
		armor_name = "tunic"
		Worth = 64
		typi = "armor"
		alvl = 1
		strreq = 15
		Adefense = 17
		Aevade = 8
		//rarity = "{Singular}"
		New()
			SetRank(rank||6)
			//description = "<font color = #ffd700><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
//tunic done
	avgcorslet
		name = "Gou ShellHide (Corslet)"
		//description = "<font color = #8C7853><center><b><br>Giu ShellHide Corslet:</b><br>14 Defense<br>4% Evasion<br>11 Strength-Req"
		//icon_state = "avgcorslet"
		armor_name = "corslet"
		Worth = 15
		typi = "armor"
		alvl = 1
		strreq = 11
		Adefense = 14
		Aevade = 4
		//rarity = "{Average}"
		New()
			SetRank(rank||1)
			//description = "<font color = #8C7853><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	unucorslet
		name = "Gou ShellPlate (Corslet)"
		//description = "<font color = #b87333><center><b><br>Gou ShellPlate (Corslet):</b><br>15 Defense<br>2% Evasion<br>14 Strength-Req"
		//icon_state = "unucorslet"
		armor_name = "corslet"
		Worth = 27
		typi = "armor"
		//var/mob/J
		alvl = 2
		strreq = 14
		Adefense = 15
		Aevade = 2
		//rarity = "{Unusual}"
		New()
			SetRank(rank||2)
			//description = "<font color = #b87333><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 3
		SPRTbonus = 11
		New()
			if(usr!=null)
				earthres = rand(5,30)
				var/ad1 = "+[earthres] Earth Proof"
				description = "<font color = #b87333><center><b><br>Gou ShellPlate (Corslet):</b><br>40 Defense<br>1% Evasion<br>+6 Strength<br>+20 Spirit<br>[ad1]<br>33 Strength-Req"
	*/
	uncocorslet
		name = "Iron Platemail (Corslet)"
		//description = "<font color = #c0c0c0><center><b><br>Iron Platemail (Corslet):</b><br>17 Defense<br>1% Evasion<br>16 Strength-Req"
		//icon_state = "uncocorslet"
		armor_name = "corslet"
		Worth = 30
		typi = "armor"
		alvl = 2
		strreq = 16
		Adefense = 17
		Aevade = 1
		//rarity = "{Uncommon}"
		New()
			SetRank(rank||3)
			//description = "<font color = #c0c0c0><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	choicorslet
		name = "Copper Platemail (Corslet)"
		//description = "<font color = #e6e8fa><center><b><br>Copper Platemail (Corslet):</b><br>19 Defense<br>2% Evasion<br>15 Strength-Req"
		//icon_state = "choicorslet"
		armor_name = "corslet"
		Worth = 45
		typi = "armor"
		alvl = 2
		strreq = 15
		Adefense = 19
		Aevade = 2
		//rarity = "{Choice}"
		New()
			SetRank(rank||4)
			//description = "<font color = #e6e8fa><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	ordicorslet
		name = "Bronzemail (Corslet)"
		//description = "<font color= #4682b4><center><b><br>Bronzemail (Corslet):</b><br>22 Defense<br>1% Evasion<br>18 Strength-Req"
		//icon_state = "ordicorslet"
		armor_name = "corslet"
		Worth = 65
		typi = "armor"
		alvl = 2
		strreq = 18
		Adefense = 22
		Aevade = 1
		//rarity = "{Ordinary}"
		New()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 2
		SPRTbonus = 9
		New()
			if(usr!=null)
				WINDres = rand(1,30)
				var/ad1 = "+[WINDres] Wind Proof"
				WATbonus = rand(5,20)
				var/ad2 = "+[WATbonus] WaterShock"
				description = "<font color= #4682b4><center><b><br>Bronzemail (Corlset):</b><br>59 Defense<br>6% Evasion<br>+2 Strength<br>+9 Spirit<br>[ad1]<br>[ad2]<br>35 Strength-Req"
	*/
	sincorslet
		name = "Zinc Platemail (Corslet)"
		//description = "<font color = #ffd700><center><b><br>Zinc Platemail (Corslet):</b><br>26 Defense<br>2% Evasion<br>20 Strength-Req"
		//icon_state = "sincorslet"
		armor_name = "corslet"
		Worth = 85
		typi = "armor"
		alvl = 2
		strreq = 20
		Adefense = 26
		Aevade = 2
		//rarity = "{Singular}"
		New()
			SetRank(rank||6)
			//description = "<font color = #ffd700><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
//corslet done
	avgcuirass
		name = "CopperPlate (Cuirass)"
		//description = "<font color = #8C7853><center><b><br>CopperPlate (Cuirass):</b><br>23 Defense<br>1% Evasion<br>12 Strength-Req<br>Worth 42"
		//icon_state = "avgcuirass"
		armor_name = "corslet"
		Worth = 22
		typi = "armor"
		alvl = 1
		strreq = 12
		Adefense = 23
		Aevade = 1
		//rarity = "{Average}"
		New()
			SetRank(rank||1)
			//description = "<font color = #8C7853><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	unucuirass
		name = "LeadPlate (Cuirass)"
		//description = "<font color = #b87333><font color = #ffd700><center><b><br>LeadPlate (Cuirass):</b><br>15 Defense<br>1% Evasion<br>15 Strength-Req"
		//icon_state = "unucuirass"
		armor_name = "cuirass"
		Worth = 32
		typi = "armor"
		alvl = 2
		strreq = 15
		Adefense = 15
		Aevade = 1
		//rarity = "{Unusual}"
		New()
			SetRank(rank||2)
			//description = "<font color = #b87333><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 3
		SPRTbonus = 10
		New()
			if(usr!=null)
				ENERGYbonus = rand(10,50)
				var/ad1 = "+[ENERGYbonus] energy"
				ICEres = rand(5,20)
				var/ad2 = "+[ICEres] Ice Proof"
				description = "<font color = #ffd700><center><b><br>LeadPlate Cuirass (Cuirass):</b><br>77 Defense<br>7% Evasion<br>+3 Strength<br>+10 Spirit<br>[ad1]<br>[ad2]<br>47 Strength-Req"
	*/
	uncocuirass
		name = "Iron HalfPlate (Cuirass)"
		//description = "<font color = #c0c0c0><center><b><br>Iron HalfPlate (Cuirass):</b><br>17 Defense<br>1% Evasion<br>16 Strength-Req"
		//icon_state = "uncocuirass"
		armor_name = "cuirass"
		Worth = 45
		typi = "armor"
		alvl = 3
		strreq = 16
		Adefense = 17
		Aevade = 1
		//rarity = "{Uncommon}"
		New()
			SetRank(rank||3)
			//description = "<font color = #c0c0c0><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	choicuirass
		name = "Bronze SolidPlate (Cuirass)"
		//description = "<font color = #e6e8fa><center><b><br>Bronze SolidPlate (Cuirass):</b><br>20 Defense<br>2% Evasion<br>17 Strength-Req"
		//icon_state = "choicuirass"
		armor_name = "cuirass"
		Worth = 65
		typi = "armor"
		alvl = 4
		strreq = 17
		Adefense = 20
		Aevade = 2
		//rarity = "{Choice}"
		New()
			SetRank(rank||4)
			//description = "<font color = #e6e8fa><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	ordicuirass
		name = "Boreal ZincPlate (Cuirass)"
		//description = "<font color= #4682b4><center><b><br>Boreal ZincPlate (Cuirass):</b><br>23 Defense<br>2% Evasion<br>18 Strength-Req"
		//icon_state = "ordicuirass"
		armor_name = " cuirass"
		Worth = 70
		typi = "armor"
		alvl = 4
		strreq = 18
		Adefense = 23
		Aevade = 2
		//rarity = "{Ordinary}"
		New()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 6
		SPRTbonus = 13
		New()
			if(usr!=null)
				ICESTORMbonus = rand(5,25)
				var/ad1 = "+[ICESTORMbonus] Ice Storm"
				ICEres = rand(10,30)
				var/ad2 = "+[ICEres] Ice Proof"
				description = "<font color= #4682b4><center><b><br>Boreal ZincPlate (Cuirass):</b><br>88 Defense<br>8% Evasion<br>+6 Strength<br>+13 Spirit<br>[ad1]<br>[ad2]<br>55 Strength-Req"
	*/
	sincuirass
		name = "Aurelian SteelPlate (Cuirass)"
		//description = "<font color = #ffd700><center><b><br>Aurelian SteelPlate (Cuirass):</b><br>26 Defense<br>1% Evasion<br>20 Strength-Req"
		//icon_state = "sincuirass"
		armor_name = "cuirass"
		Worth = 142
		typi = "armor"
		alvl = 4
		strreq = 20
		Adefense = 26
		Aevade = 1
		//rarity = "{Singular}"
		New()
			SetRank(rank||6)
			//description = "<font color = #ffd700><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
//cuirass done
	avgbattlegear
		name = "IronPlate (Battlegear)"
		//description = "<font color = #8C7853><center><b><br>LeadPlate (Battlegear):</b><br>12 Defense<br>1% Evasion<br>13 strength required"
		//icon_state = "avgbattlegear"
		armor_name = "battlegear"
		Worth = 21
		typi = "armor"
		alvl = 3
		strreq = 13
		Adefense = 12
		Aevade = 1
		//rarity = "{Average}"
		New()
			SetRank(rank||1)
			//description = "<font color = #8C7853><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	unubattlegear
		name = "CopperPlate (Battlegear)"
		//description = "<font color = #b87333><center><b><br>CopperPlate (Battlegear):</b><br>14 Defense<br>1% Evasion<br>14 strength required"
		//icon_state = "unubattlegear"
		armor_name = "battlegear"
		Worth = 31
		typi = "armor"
		alvl = 3
		strreq = 14
		Adefense = 14
		Aevade = 1
		//rarity = "{Unusual}"
		New()
			SetRank(rank||2)
			//description = "<font color = #b87333><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
		/*STRbonus = 22
		SPRTbonus = 8
		New()
			if(usr!=null)
				FLAMEbonus = rand(10,15)
				var/ad1 = "+[FLAMEbonus] Flame"
				FIREres = rand(16,23)
				var/ad2 = "+[FIREres] Fire Proof"
				HEALTHbonus = rand(150,400)
				var/ad3 = "+[HEALTHbonus] Health"
				description = "<font color = #ffd700><center><b><br>BronzePlate (Battlegear):</b>  310 Defense, 12% Evasion, +22 Str, +8 Int[ad1][ad2][ad3], 180 strength required"
	*/
	uncobattlegear
		name = "BronzePlate (Battlegear)"
		//description = "<font color = #c0c0c0><center><b><br>BronzePlate (Battlegear):</b><br>16 Defense<br>1% Evasion<br>15 strength required"
		//icon_state = "uncobattlegear"
		armor_name = "battlegear"
		Worth = 42
		typi = "armor"
		alvl = 3
		strreq = 15
		Adefense = 16
		Aevade = 1
		//rarity = "{Uncommon}"
		New()
			SetRank(rank||3)
			//description = "<font color = #c0c0c0><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	choibattlegear
		name = "Omphalos LeadPlate (Battlegear)"
		//description = "<font color = #e6e8fa><center><b><br>Omphalos LeadPlate (Battlegear):</b><br>18 Defense<br>1% Evasion<br>17 strength required"
		//icon_state = "choibattlegear"
		armor_name = "battlegear"
		Worth = 65
		typi = "armor"
		alvl = 4
		strreq = 17
		Adefense = 18
		Aevade = 1
		//rarity = "{Choice}"
		New()
			SetRank(rank||4)
			//description = "<font color = #e6e8fa><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	ordibattlegear
		name = "ZincPlate (Battlegear)"
		//description = "<font color = #4682b4><center><b><br>ZincPlate (Battlegear):</b><br>189 Defense<br>22% Evasion<br>97 strength required"
		//icon_state = "ordibattlegear"
		armor_name = "battlegear"
		Worth = 75
		typi = "armor"
		alvl = 4
		strreq = 9
		Adefense = 18
		Aevade = 22
		//rarity = "{Ordinary}"
		New()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
	sinbattlegear
		name = "SteelPlate (Battlegear)"
		//description = "<font color = #ffd700><center><b><br>SteelPlate (Battlegear):</b><br>224 Defense<br>14% Evasion<br>121 strength required"
		//icon_state = "sinbattlegear"
		armor_name = "battlegear"
		Worth = 110
		typi = "armor"
		alvl = 4
		strreq = 14
		Adefense = 26
		Aevade = 14
		//rarity = "{Singular}"
		New()
			SetRank(rank||6)
			//description = "<font color = #ffd700><center><br><b>[name]</b><br>[rarity]<br>[alvl] Armor Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req"
//battlegear done