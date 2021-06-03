
mob/players
	var
		//General vars
		char_class
		location
		lucre
		bankedlucre
		pvpkills

		//Stats vars
		Strength
		Spirit
		attackspeed
		level = 1

		HP
		MAXHP
		energy
		MAXenergy
		tempdefense
		tempevade

		exp
		expneeded
		expgive

		buildexp

		//Ranks
		frank
		drank
		grank
		hrank
		brank
		smirank
		smerank

		//Resistances
		fireres
		iceres
		windres
		waterres
		earthres
		poisonres
		//Weakness
		fireweak
		iceweak
		windweak
		waterweak
		earthweak
		poisonweak

		//Magi levels
		heatlevel
		shardburstlevel
		watershocklevel
		vitaelevel
		vitae2level
		flamelevel
		icestormlevel
		cascadelightninglevel
		telekinesislevel
		abjurelevel
		cosmoslevel
		rephaselevel
		acidlevel
		bludgeonlevel
		quietuslevel
		panacealevel


	proc/Class()
		if(char_class == "Feline")
			attackspeed = 8
			HP = 210
			MAXHP = 210
			energy = 500
			MAXenergy = 500
			tempdefense = 0
			tempevade = 10
			expneeded = 125
			expgive = 40
			Strength = 2
			Spirit = 6
			//Resistances
			iceres = 1
			windres = 1
			earthres = 1
			//Weaknesses
			fireweak = 1
			waterweak = 1
			poisonweak = 1
			//Magi levels
			abjurelevel = 1
			//Ranks
			drank = 1
			frank = 1
			grank = 1
		if(char_class == "Landscaper")
			attackspeed = 6
			HP = 310
			MAXHP = 310
			energy = 500
			MAXenergy = 500
			tempdefense = 4
			tempevade = 5
			expneeded = 125
			expgive = 40
			bankedlucre = 10
			lucre = 10
			Strength = 7
			Spirit = 3
			//Resistances
			windres = 1
			earthres = 1
			poisonres = 1
			//Weaknesses
			fireweak = 1
			iceweak = 1
			waterweak = 1
			//Magi levels
			abjurelevel = 1
			//Ranks
			drank = 1
			hrank = 1
			grank = 1
		if(char_class == "Builder")
			attackspeed = 5
			HP = 390
			MAXHP = 390
			energy = 500
			MAXenergy = 500
			tempdefense = 5
			tempevade = 3
			expneeded = 135
			expgive = 10
			bankedlucre = 10
			lucre = 100
			Strength = 6
			Spirit = 4
			//Weaknesses
			fireweak = 1
			iceweak = 1
			windweak = 1
			waterweak = 1
			earthweak = 1
			poisonweak = 1
			//Magi levels
			abjurelevel = 1
			//Ranks
			brank = 1
			hrank = 1
			smirank=1
			smerank=1
		if(char_class == "Defender")
			attackspeed = 4
			HP = 345
			MAXHP = 345
			energy = 500
			MAXenergy = 500
			tempdefense = 10
			tempevade = 1
			expneeded = 145
			expgive = 50
			bankedlucre = 10
			lucre = 10
			Strength = 7
			Spirit = 5
			//Resistances
			iceres = 1
			windres = 1
			waterres = 1
			poisonres = 1
			//Weaknesses
			fireweak = 1
			earthweak = 1
			//Magi levels
			vitaelevel = 1
			vitae2level = 1
			abjurelevel = 1
			cosmoslevel = 1
			bludgeonlevel = 1
			panacealevel = 1
			//Ranks
			frank = 1
			hrank = 1
			smirank=1
			smerank=1
		if(char_class == "Magus")
			attackspeed = 7
			HP = 365
			MAXHP = 365
			energy = 500
			MAXenergy = 500
			tempdefense = 2
			expneeded = 155
			expgive = 20
			bankedlucre = 10
			lucre = 10
			Strength = 4
			Spirit = 12
			//Resistances
			fireres = 1
			windres = 1
			earthres = 1
			//Weaknesses
			iceweak = 1
			waterweak = 1
			//magi levels
			heatlevel = 1
			shardburstlevel = 1
			watershocklevel = 1
			flamelevel = 1
			icestormlevel = 1
			abjurelevel = 1
			rephaselevel = 1
			acidlevel = 1
			quietuslevel = 1
			//Ranks
			hrank = 1
			frank = 1
		if(char_class == "GM")
			location = ""
			attackspeed = 13
			level = 9999
			HP = 99999
			MAXHP = 99999
			energy = 99999
			MAXenergy = 99999
			tempdefense = 9999
			tempevade = 99
			exp = 0
			expneeded = 999999
			expgive = 0
			bankedlucre = 999999
			lucre = 999999
			Strength = 9999
			Spirit = 9999
			//Resistances
			fireres = 99
			iceres = 99
			windres = 99
			waterres = 99
			earthres = 99
			poisonres = 99
			//magi levels
			heatlevel = 99
			shardburstlevel = 99
			watershocklevel = 99
			vitaelevel = 99
			flamelevel = 99
			icestormlevel = 99
			cascadelightninglevel = 99
			telekinesislevel = 99
			abjurelevel = 99
			cosmoslevel = 99
			rephaselevel = 99
			acidlevel = 99
			bludgeonlevel = 99
			quietuslevel = 99
			panacealevel = 99
			//Ranks
			brank=1
			hrank=1
			frank=1
			drank=1
			grank=1
			smirank=1
			smerank=1