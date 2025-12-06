obj
	items
		tools

			SteelPickaxe //name of object - Steel Pickaxe (Tier 3 - High Tier)
				icon_state = "PickAxe" //icon state of object
				typi = "SPX"
				strreq = 2
				name = "Steel PickAxe"
				Worth = 2
				wpnspd = 1
				tlvl = 3
				twohanded = 1
				DamageMin = 2
				DamageMax = 6
				pickaxe_tier = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			SteelHammer //name of object - Steel Hammer (Tier 3)
				icon_state = "Hammer" //icon state of object
				typi = "SHH"
				strreq = 2
				name = "Steel Hammer"
				Worth = 2
				wpnspd = 2
				tlvl = 3
				twohanded = 0
				DamageMin = 2
				DamageMax = 5
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			SteelShovel //name of object - Steel Shovel (Tier 3)
				icon_state = "Shovel" //icon state of object
				typi = "SSH"
				strreq = 2
				name = "Steel Shovel"
				Worth = 2
				wpnspd = 1
				tlvl = 3
				twohanded = 1
				DamageMin = 2
				DamageMax = 6
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			SteelHoe //name of object - Steel Hoe (Tier 3)
				icon_state = "hoe" //icon state of object
				typi = "SHO"
				strreq = 2
				name = "Steel Hoe"
				Worth = 2
				wpnspd = 1
				tlvl = 3
				twohanded = 1
				DamageMin = 2
				DamageMax = 5
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			SteelSickle //name of object - Steel Sickle (Tier 3)
				icon_state = "sickle" //icon state of object
				typi = "SSH2"
				strreq = 2
				name = "Steel Sickle"
				Worth = 2
				wpnspd = 2
				tlvl = 3
				twohanded = 0
				DamageMin = 5
				DamageMax = 8
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			SteelChisel //name of object - Steel Chisel (Tier 3)
				icon_state = "Chisel" //icon state of object
				typi = "SCH"
				strreq = 2
				name = "Steel Chisel"
				Worth = 2
				wpnspd = 2
				tlvl = 3
				twohanded = 0
				DamageMin = 2
				DamageMax = 5
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			SteelFile //name of object - Steel File (Tier 3)
				icon_state = "File" //icon state of object
				typi = "SFI"
				strreq = 2
				name = "Steel File"
				Worth = 2
				wpnspd = 4
				tlvl = 3
				twohanded = 0
				DamageMin = 2
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()
