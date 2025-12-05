obj
	items
		shields
			layer = 9
			//yeah, this gets pretty wild
			icon = 'dmi/64/shields.dmi'
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
				staminabonus = 0
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
				slvl
				rarity = ""
					//world << "[src.STRbonus] Strength [src.SPRTbonus] INT [src.FIREres] FIRE [src.ICEres] ICE [src.WINDres] LIT [src.POISres] POIS [src.EARTHres] DARK"
			//verbs to get items, description, equipping, etc on right click
			//the way i handled the equipping and changing of variables is a little whacked out, i don't like it much, but here it is
			/*verb/Description()
				set category=null
				set popup_menu=1
				set src in usr
				usr << src.description
				*/
			/*verb/Get()
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
					if (typi=="shield")
						if (usr.tempstr>=src.strreq)
							if(usr.TWequipped!=2 && usr.Wequipped!=2 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped!=2 && usr.SKequipped!=2 && usr.HOequipped==0 && usr.CKequipped!=2 && usr.GVequipped==0 && usr.FLequipped!=2 && usr.PYequipped!=2 && usr.OKequipped!=2 && usr.SHMequipped!=2 && usr.UPKequipped==0)
								src.suffix="Equipped"
								usr.Sequipped = 1
								usr.tempdefense += src.Adefense
								usr.tempevade += src.Aevade
								var/mob/players/M = usr
								M.Strength += src.STRbonus
								M.Spirit += src.SPRTbonus
								M.HP += src.HEALTHbonus
								M.stamina += src.staminabonus
								M.MAXHP += src.HEALTHbonus
								M.MAXstamina += src.staminabonus
								M.fireres += src.FIREres
								M.iceres += src.ICEres
								M.windres += src.WINDres
								M.watres += src.WATres
								M.earthres += src.EARTHres
								M.heatlevel += src.HEATbonus
								M.vitaelevel += src.VITAEbonus
							else
								usr << "<font color = teal>You are already holding something in that hand."
						else
							usr << "<font color = teal>You do not meet or exceed the strength requirements."
			verb/Unequip()
				set category = null
				set src in usr
				if(src.suffix!="Equipped")
					usr << "<font color = teal>That's not equipped!"
				else
					if (typi=="shield")
						if(usr.Sequipped==0)
							usr << "<font color = teal>You don't have a shield equipped!"
						else
							src.suffix = ""
							usr.Sequipped = 0
							usr.tempdefense -= src.Adefense
							usr.tempevade -= src.Aevade
							var/mob/players/M = usr
							M.Strength -= src.STRbonus
							M.Spirit -= src.SPRTbonus
							M.HP -= src.HEALTHbonus
							M.stamina -= src.staminabonus
							M.MAXHP -= src.HEALTHbonus
							M.MAXstamina -= src.staminabonus
							M.fireres -= src.FIREres
							M.iceres -= src.ICEres
							M.windres -= src.WINDres
							M.watres -= src.WATres
							M.earthres -= src.EARTHres
							M.heatlevel -= src.HEATbonus
							M.vitaelevel -= src.VITAEbonus
			/*verb
				/*Drop()
					set category=null
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
					return*/

//these descriptions also need to be converted
obj/items/shields
	var
		shield_name // or weapon class or whatever.  just a text string we use for the icon state
		rank		// the rank of the weapon (or rarity?)
		desc_color
		//hand

	proc
		SetRank(n)
			n = clamp(n, 1, 6)
			slvl *= n
			strreq *= n
			Adefense *= n
			Aevade *= n
			//description = "<br><font color = #8C7853><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage,<br>[strreq] Strength-Req<br>One-Hand<br>Worth [Worth]"
			rarity = "{[num2rarity(n)]}"
			icon_state = "[num2iconstate(n)][shield_name]"
			desc_color = "[num2desccolor(n)][desc_color]"
			//description = "<br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Armor Defense<br>[Aevade] Armor Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"


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

		/*num2hand(n)
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
											return "Two Hands"*/
	avgbast
		name = "Bastion"
		//description = "<font color = #8C7853><center><b>Bastion:</b><br>11 Defense<br>3% Evasion<br>6 Strength-Req<br>Worth 23"
		//icon_state = "avgbast"
		shield_name = "bastion"
		Worth = 23
		typi = "shield"
		slvl = 1
		strreq = 6
		Adefense = 11
		Aevade = 3
		//rarity = "{Average}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||1)
			Description()
			//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	unubast
		name = "Kal (Bastion)"
		//description = "<font color = #b87333><center><b>Kal (Bastion):</b><br>18 Defense<br>6% Evasion<br>+1 Strength<br>+6 Spirit<br>9 Strength-Req<br>Worth 38"
		//icon_state = "unubast"
		shield_name = "bastion"
		Worth = 38
		typi = "shield"
		slvl = 1
		strreq = 9
		Adefense = 18
		Aevade = 6
		STRbonus = 1
		SPRTbonus = 6
		//rarity = "{Unusual}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[SHARDBURSTbonus] Shardburst"
			var/ad2 = "+[HEATbonus] Heat"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||2)
			//Description()
			//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				SHARDBURSTbonus = rand(1,10)
				//var/ad1 = "+[SHARDBURSTbonus] Shardburst"
				HEATbonus = rand(1,10)
				//var/ad2 = "+[HEATbonus] Heat"
				Worth = 98
				Description()//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	uncobast
		name = "Siege (Bastion)"
		//description = "<font color = #c0c0c0><center><b>Siege (Bastion):</b><br>24 Defense<br>9% Evasion<br>13 Strength-Req<br>Worth 60"
		//icon_state = "uncobast"
		shield_name = "bastion"
		Worth = 60
		typi = "shield"
		slvl = 1
		strreq = 13
		Adefense = 24
		Aevade = 9
		//rarity = "{Uncommon}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||3)
			Description()
			//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	choibast
		name = "Sangar (Bastion)"
		//description = "<font color = #e6e8fa><center><b>Sangar Bastion:</b><br>33 Defense<br>7% Evasion<br>18 Strength-Req<br>Worth 72"
		//icon_state = "choibast"
		shield_name = "bastion"
		Worth = 72
		typi = "shield"
		slvl = 1
		strreq = 18
		Adefense = 33
		Aevade = 7
		//rarity = "{Choice}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||4)
			Description()
			//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	ordibast
		name = "Ward (Bastion)"
		//description = "<font color= #4682b4><center><b>Ward (Bastion):</b><br>42 Defense<br>11% Evasion<br>+10 Strength<br>+4 Spirit<br>25 Strength-Req<br>Worth 100"
		//icon_state = "ordibast"
		shield_name = "bastion"
		Worth = 100
		typi = "shield"
		slvl = 1
		strreq = 25
		Adefense = 42
		Aevade = 11
		STRbonus = 10
		SPRTbonus = 4
		//rarity = "{Ordinary}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[ICEres] Ice Proof"
			var/ad2 = "+[SHARDBURSTbonus] Shardburst"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				ICEres = rand(20,30)
				//var/ad1 = "+[ICEres] Ice Proof"
				SHARDBURSTbonus = rand(1,4)
				//var/ad2 = "+[SHARDBURSTbonus] Shardburst"
				Worth = 200
				Description()//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	sinbast
		name = "Vambrace (Bastion)"
		//description = "<font color = #ffd700><center><b>Vambrace (Bastion):</b><br>55 Defense<br>17% Evasion<br>30 Strength-Req<br>Worth 300"
		//icon_state = "sinbast"
		shield_name = "bastion"
		Worth = 300
		typi = "shield"
		slvl = 1
		strreq = 30
		Adefense = 55
		Aevade = 17
		//rarity = "{Singular}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||6)
			Description()
			//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
//bastion done
	avgvanfos
		name = "Vanfos"
		//description = "<font color = #8C7853><center><b>(Vanfos):</b><br>15 Defense<br>10% Evasion<br>12 Strength-Req<br>Worth 49"
		//icon_state = "avgvanfos"
		shield_name = "vanfos"
		Worth = 49
		typi = "shield"
		slvl = 2
		strreq = 12
		Adefense = 15
		Aevade = 10
		//rarity = "{Average}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||1)
			Description()
			//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	unuvanfos
		name = "Chevaux de Frise ((Vanfos))"
		//description = "<font color = #b87333><center><b>Chevaux de Frise ((Vanfos)):</b><br>74 Defense<br>18% Evasion<br>+17 Strength<br>+15 Spirit<br>55 Strength-Req<br>Worth 98"
		//icon_state = "unuvanfos"
		shield_name = "vanfos"
		Worth = 98
		typi = "shield"
		slvl = 2
		strreq = 55
		Adefense = 74
		Aevade = 18
		STRbonus = 17
		SPRTbonus = 15
		//rarity = "{Unusual}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[BLUDGEONbonus] Bludgeon"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||2)
			//Description()
			//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				BLUDGEONbonus = rand(14,24)
				//var/ad1 = "+[BLUDGEONbonus] Bludgeon"
				Description()//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	uncovanfos
		name = "Screen (Vanfos)"
		//description = "<font color = #c0c0c0><center><b>Screen ((Vanfos)):</b><br>30 Defense<br>2% Evasion<br>20 Strength-Req<br>Worth 64"
		//icon_state = "uncovanfos"
		shield_name = "vanfos"
		Worth = 64
		typi = "shield"
		slvl = 2
		strreq = 20
		Adefense = 30
		Aevade = 2
		//rarity = "{Uncommon}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||3)
			Description()
			//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	choivanfos
		name = "Scale (Vanfos)"
		//description = "<font color = #e6e8fa><center><b>Scale ((Vanfos)):</b><br>75 Defense<br>22% Evasion<br>54 Strength-Req<br>Worth 75"
		//icon_state = "choivanfos"
		shield_name = "vanfos"
		Worth = 75
		typi = "shield"
		slvl = 2
		strreq = 54
		Adefense = 75
		Aevade = 22
		//rarity = "{Choice}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||4)
			Description()
			//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	ordivanfos
		name = "Hermetic (Vanfos)"
		//description = "<font color= #4682b4><center><b>Hermetic ((Vanfos)):</b><br>75 Defense<br>18% Evasion<br>+11 Strength<br>+20 Spirit<br>48 Strength-Req<br>Worth 175"
		//icon_state = "ordivanfos"
		shield_name = "vanfos"
		Worth = 175
		typi = "shield"
		slvl = 2
		strreq = 48
		Adefense = 75
		Aevade = 18
		STRbonus = 11
		SPRTbonus = 20
		//rarity = "{Ordinary}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[WINDres] Wind Proof"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||5)
			//Description()
			//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				WINDres = rand(28,33)
				//var/ad1 = "+[WINDres] Wind Proof"
				Worth = 275
				Description()//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[ad1]<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	sinvanfos
		name = "Lucretius (Vanfos)"
		//description = "<font color = #ffd700><b>Lucretius ((Vanfos)):</b><br>86 Defense<br>20% Evasion<br>60 Strength-Req<br>Worth 840"
		//icon_state = "sinvanfos"
		shield_name = "vanfos"
		Worth = 840
		typi = "shield"
		slvl = 2
		strreq = 60
		Adefense = 86
		Aevade = 20
		//rarity = "{Singular}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||6)
			Description()
			//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
//vanfos finished
	avgaegis
		name = "Aegis"
		//description = "<font color = #8C7853><center><b>(Aegis):</b><br>60 Defense<br>4% Evasion<br>30 Strength-Req<br>Worth 94"
		//icon_state = "avgaegis"
		shield_name = "aegis"
		Worth = 94
		typi = "shield"
		slvl = 2
		strreq = 30
		Adefense = 60
		Aevade = 4
		//rarity = "{Average}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||1)
			Description()
			//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	unuaegis
		name = "Pro aris et focis (Aegis)"
		//description = "<font color = #b87333><center><b>Pro aris et focis ((Aegis)):</b><br>103 Defense<br>30% Evasion<br>+18 Strength<br>+24 Spirit<br>84 Strength-Req<br>Worth 101"
		//icon_state = "unuaegis"
		shield_name = "aegis"
		Worth = 101
		typi = "shield"
		slvl = 2
		strreq = 84
		Adefense = 103
		Aevade = 30
		STRbonus = 18
		SPRTbonus = 24
		var/resroll
		//rarity = "{Unusual}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[HEALTHbonus] Health"
			var/ad2 = "+[resroll] Omni-Proof"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||2)
			//Description()
			//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				HEALTHbonus = rand(200,300)
				//var/ad1 = "+[HEALTHbonus] Health"
				resroll = rand(15,30)
				FIREres = resroll
				ICEres = resroll
				WINDres = resroll
				WATres = resroll
				EARTHres = resroll
				Worth = 1011
				//var/ad2 = "+[resroll] Omni-Proof"
				Description()//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	uncoaegis
		name = "Murrion (Aegis)"
		//description = "<font color = #c0c0c0><center><b>Murrion ((Aegis)):</b><br>84 Defense<br>28% Evasion<br>46 Strength-Req<br>Worth 142"
		//icon_state = "uncoaegis"
		shield_name = "aegis"
		Worth = 142
		typi = "shield"
		slvl = 2
		strreq = 46
		Adefense = 84
		Aevade = 28
		//rarity = "{Uncommon}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||3)
			Description()
			//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	choiaegis
		name = "Heaume (Aegis)"
		//description = "<font color = #e6e8fa><center><b>Heaume ((Aegis)):</b><br>125 Defense<br>33% Evasion<br>80 Strength-Req<br>Worth 121"
		//icon_state = "choiaegis"
		shield_name = "aegis"
		Worth = 121
		typi = "shield"
		slvl = 3
		strreq = 80
		Adefense = 125
		Aevade = 33
		//rarity = "{Choice}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||4)
			Description()
			//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	ordiaegis
		name = "Vauntmure (Aegis)"
		//description = "<font color= #4682b4><center><b>Vauntmure ((Aegis)):</b><br>136 Defense<br>36% Evasion<br>+24 Strength<br>+24 Spirit<br>8 Strength-Req<br>Worth 142"
		//icon_state = "ordiaegis"
		shield_name = "aegis"
		Worth = 142
		typi = "shield"
		slvl = 3
		strreq = 88
		Adefense = 136
		Aevade = 36
		STRbonus = 24
		SPRTbonus = 24
		//rarity = "{Ordinary}"
		var/resroll
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[HEALTHbonus] Health"
			var/ad2 = "+[staminabonus] stamina"
			var/ad3 = "+[resroll] Omni-Proof"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||5)
			//Description()
			//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			if(usr!=null)
				HEALTHbonus = rand(200,300)
				//var/ad1 = "+[HEALTHbonus] Health"
				staminabonus = rand(200,300)
				//var/ad2 = "+[staminabonus] stamina"
				resroll = rand(33,42)
				FIREres = resroll
				ICEres = resroll
				WINDres = resroll
				WATres = resroll
				EARTHres = resroll
				Worth = 1420
				//var/ad3 = "+[resroll] Omni-Proof"
				Description()//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	sinaegis
		name = "Hauberk (Aegis)"
		//description = "<font color = #ffd700><b>Hauberk ((Aegis)):</b><br>124 Defense<br>33% Evasion<br>90 Strength-Req<br>Worth 1884"
		//icon_state = "sinaegis"
		shield_name = "aegis"
		Worth = 1884
		typi = "shield"
		slvl = 3
		strreq = 90
		Adefense = 124
		Aevade = 33
		//rarity = "{Singular}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||6)
			Description()
			//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
//aegis finished
	avgravelin
		name = "Ravelin"
		//description = "<font color = #8C7853><center><b>(Ravelin):</b><br>113 Defense<br>21% Evasion<br>67 Strength-Req<br>Worth 224"
		//icon_state = "avgravelin"
		shield_name = "ravelin"
		Worth = 224
		typi = "shield"
		slvl = 3
		strreq = 67
		Adefense = 113
		Aevade = 21
		//rarity = "{Average}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||1)
			Description()
			//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	unuravelin
		name = "Annex (Ravelin)"
		//description = "<font color = #b87333><center><b>Annex ((Ravelin)):</b><br>142 Defense<br>42% Evasion<br>+42 Strength<br>100 Strength-Req<br>Worth 242"
		//icon_state = "unuravelin"
		shield_name = "ravelin"
		Worth = 242
		typi = "shield"
		slvl = 3
		strreq = 100
		Adefense = 142
		Aevade = 42
		STRbonus = 42
		//rarity = "{Unusual}"
		//var/resroll
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[HEALTHbonus] Health"
			var/ad2 = "+[BLUDGEONbonus] Bludgeon"
			var/ad3 = "+[QUIETUSbonus] Quietus"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||2)
			//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				Worth = 2420
				HEALTHbonus = rand(300,420)
				//var/ad1 = "+[HEALTHbonus] Health"
				BLUDGEONbonus = rand(33,42)
				//var/ad2 = "+[BLUDGEONbonus] Bludgeon"
				QUIETUSbonus = rand(6,12)
				//var/ad3 = "+[BLUDGEONbonus] Bludgeon"
				Description()//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	uncoravelin
		name = "Fang (Ravelin)"
		//description = "<font color = #c0c0c0><center><b>Fang ((Ravelin)):</b><br>152 Defense<br>22% Evasion<br>105 Strength-Req<br>Worth 442"
		//icon_state = "uncoravelin"
		shield_name = "ravelin"
		Worth = 442
		typi = "shield"
		slvl = 3
		strreq = 105
		Adefense = 152
		Aevade = 22
		//rarity = "{Uncommon}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||3)
			Description()
			//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	choiravelin
		name = "Longtooth (Ravelin)"
		//description = "<font color = #e6e8fa><center><b>Longtooth ((Ravelin)):</b><br>125 Defense<br>33% Evasion<br>80 Strength-Req<br>Worth 612"
		//icon_state = "choiravelin"
		shield_name = "ravelin"
		Worth = 612
		typi = "shield"
		slvl = 3
		strreq = 80
		Adefense = 125
		Aevade = 33
		//rarity = "{Choice}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||4)
			Description()
			//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	ordiravelin
		name = "Sabretooth (Ravelin)"
		//description = "<font color= #4682b4><center><b>Sabretooth ((Ravelin)):</b><br>136 Defense<br>36% Evasion<br>+24 Strength<br>+24 Spirit<br>8 Strength-Req<br>Worth 820"
		//icon_state = "ordiravelin"
		shield_name = "ravelin"
		Worth = 820
		typi = "shield"
		slvl = 3
		strreq = 88
		Adefense = 136
		Aevade = 36
		STRbonus = 24
		SPRTbonus = 24
		//rarity = "{Ordinary}"
		var/resroll
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			var/ad1 = "+[HEALTHbonus] Health"
			var/ad2 = "+[staminabonus] stamina"
			var/ad3 = "+[resroll] Omni-Proof"
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>+[STRbonus] Strength<br>+[SPRTbonus] Spirit<br>[ad1]<br>[ad2]<br>[ad3]<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||5)
			//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

			if(usr!=null)
				HEALTHbonus = rand(200,300)
				//var/ad1 = "+[HEALTHbonus] Health"
				staminabonus = rand(200,300)
				//var/ad2 = "+[staminabonus] stamina"
				resroll = rand(33,42)
				FIREres = resroll
				ICEres = resroll
				WINDres = resroll
				WATres = resroll
				EARTHres = resroll
				Worth = 1420
				//var/ad3 = "+[resroll] Omni-Proof"
				Description()//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>+[SPRTbonus] Spirit<br>+[STRbonus] Strength<br>[ad1]<br>[ad2]<br>[ad3]<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	sinravelin
		name = "Lion (Ravelin)"
		//description = "<font color = #ffd700><b>Lion ((Ravelin)):</b><br>124 Defense<br>33% Evasion<br>90 Strength-Req<br>Worth 1884"
		//icon_state = "sinravelin"
		shield_name = "ravelin"
		Worth = 1884
		typi = "shield"
		slvl = 3
		strreq = 90
		Adefense = 124
		Aevade = 33
		//rarity = "{Singular}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||6)
			Description()
			//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
//ravelin finished
	avgthureos
		name = "Thureos Shield"
		//description = "<font color = #8C7853><center><b><br>Thureos Shield:</b><br>155 Defense<br>22% Evasion<br>105 Strength-Req<br>Worth 380"
		//icon_state = "avgthureos"
		shield_name = "thureos"
		Worth = 380
		typi = "shield"
		slvl = 4
		strreq = 105
		Adefense = 155
		Aevade = 22
		//rarity = "{Average}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||1)
			Description()
			//description = "<font color = #8C7853><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	unuthureos
		name = "Tower (Thureos)"
		//description = "<font color = #8C7853><center><b><br>Tower (Thureos):</b><br>165 Defense<br>20% Evasion<br>125 Strength-Req<br>Worth 470"
		//icon_state = "unuthureos"
		shield_name = "thureos"
		Worth = 470
		typi = "shield"
		slvl = 4
		strreq = 125
		Adefense = 165
		Aevade = 20
		//rarity = "{Unusual}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||2)
			Description()
			//description = "<font color = #b87333><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	uncothureos
		name = "Magistrate (Thureos)"
		//description = "<font color = #c0c0c0><center><b><br>Magistrate (Thureos):</b><br>185 Defense<br>18% Evasion<br>133 Strength-Req<br>Worth 500"
		//icon_state = "uncothureos"
		shield_name = "thureos"
		Worth = 500
		typi = "shield"
		slvl = 4
		strreq = 133
		Adefense = 185
		Aevade = 18
		//rarity = "{Uncommon}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||3)
			Description()
			//description = "<font color = #c0c0c0><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	choithureos
		name = "Ravenous (Thureos)"
		//description = "<font color = #e6e8fa><center><b><br>Ravenous (Thureos):</b><br>225 Defense<br>15% Evasion<br>142 Strength-Req<br>Worth 700"
		//icon_state = "choithureos"
		shield_name = "thureos"
		Worth = 700
		typi = "shield"
		slvl = 4
		strreq = 142
		Adefense = 225
		Aevade = 15
		//rarity = "{Choice}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||4)
			Description()
			//description = "<font color = #e6e8fa><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	ordithureos
		name = "Castle (Thureos)"
		//description = "<font color= #4682b4><center><b><br>Castle (Thureos):</b><br>265 Defense<br>10% Evasion<br>155 Strength-Req<br>Worth 1400"
		//icon_state = "ordithureos"
		shield_name = "thureos"
		Worth = 1400
		typi = "shield"
		slvl = 4
		strreq = 155
		Adefense = 265
		Aevade = 10
		//rarity = "{Ordinary}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||5)
			Description()
			//description = "<font color = #4682b4><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

	sinthureos
		name = "Triumph (Thureos)"
		//description = "<font color = #ffd700><b><br><br>Triumph (Thureos):</b><br>285 Defense<br>5% Evasion<br>165 Strength-Req<br>Worth 4000"
		//icon_state = "sinthureos"
		shield_name = "thureos"
		Worth = 4000
		typi = "shield"
		slvl = 4
		strreq = 165
		Adefense = 285
		Aevade = 5
		//rarity = "{Singular}"
		verb/Description()//Fixed description
			set category=null
			set popup_menu=1
			set src in usr
			//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
			//return
			usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = [desc_color]><center><b>[name]</b><br>[rarity]<br>Shield Level [slvl]<br>[Adefense] Shield Defense<br>[Aevade] Shield Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"

		New()
			..()
			SetRank(rank||6)
			Description()
			//description = "<font color = #ffd700><center><b>[name]</b><br>[rarity]<br>[slvl] Shield Level<br>[Adefense] Defense<br>[Aevade]% Evasion<br>[strreq] Strength-Req<br>Worth [Worth]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like

