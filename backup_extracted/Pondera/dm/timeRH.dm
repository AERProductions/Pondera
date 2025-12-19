/*Welcome to Neon's Time Code! :D
With this simple code, you can add a realtime clock to your game.
I have made the month and day Harvest Moon style.

Comments throughout.*/
//mob
//	see_invisible = 1
//atom
	//icon = '64/dynamic-lighting-textured.dmi'

var
	time_of_day = 0
	hour = time2text(world.timeofday,"hh")	//The Hours
	ampm//This is because this lib uses a 12hr Clock.
	//minute1 = 3//The first digit of the minutes. (0:?0)
	//minute2 = 9//The second digit of the minutes (0:0?) (This makes sure it's 12:04 instead of 12:4)
	minute = time2text(world.timeofday,"mm")
	day = time2text(world.timeofday,"DD")//1			//The day. (Currently set to the 5th, set this to whatever you like.) (Note: In this lib, months are 14 days long, but can be easily changed.)
	month = time2text(world.timeofday,"MM")//"Spring"
	year = time2text(world.timeofday,"YYYY")//682
	//TownLamps = /obj/townlamp
	wo = 0
	//time_of_day = 0

//area
//	inside	// a sample area not affected by the daycycle or weather
//		plane = 10
/*light
	day_night
		effect()
			var/mob/m = owner

			// only force an update of the entire view
			// for light sources attached to players
			if(istype(m) && m.client)
				for(var/shading/s in range(m.client.view + 1, m))
var/J = /obj/townlamp
var/J1 = /obj/TownTorches/Torch
var/J2 = /obj/TownTorches/Torcha
var/J3 = /obj/TownTorches/Torchb
var/J4 = /obj/TownTorches/Torchc
var/J5a = /obj/castlwll5a
var/J6a = /obj/btmwll1a
					// if we haven't updated this tile's ambient light
					// value, force an update
					if(s.ambient != lighting.ambient)
						s.lum(0)

			return ..()*/


area
	outside
		//icon = '64/Darkness.dmi'	//The icon of the darkness
		//icon_state = "dark 0"	//First Icon State
		plane = EFFECTS_LAYER	// set this plane above everything else so the overlay obscures everything
		mouse_opacity = 0
		opacity = 0
		var
			lit = 1	// determines if the area is lit or dark.
			obj/weather/Weather

		proc
			weather()
				var/weather = rand(12)
				if (weather == 12) //rainy weather
					for(var/area/outside/T in world)
						wo = 1
						T.overlays += icon('64/rain.dmi')
						sleep(rand(300,600))
						T.overlays -= icon('64/rain.dmi')
					//for(var/area/introof/F in world)
					//	F.overlays += icon('64/rain.dmi')
					//	sleep(rand(300,600))
					//	F.overlays -= icon('64/rain.dmi')
						//if(istype(F,/area/introof))F.overlays-= icon('64/rain.dmi')
				if (weather == 1) //clear weather
					for(var/area/outside/T in world)
						//T.overlays += icon('64/rain.dmi')
						//sleep(rand(300,600))
						T.overlays -= icon('64/rain.dmi')
						T.overlays -= icon('64/sand.dmi')
						T.overlays -= icon('64/snow.dmi')
					//for(var/area/introof/F in world)
					//	F.overlays += icon('64/rain.dmi')
					//	sleep(rand(300,600))
					//	F.overlays -= icon('64/rain.dmi')
						//if(istype(T,/turf/Title))T.overlays-= R
				if (weather == 35) //sandstorm
					for(var/area/outside/T in world)
						T.overlays += icon('64/sand.dmi')
						sleep(rand(300,600))
						T.overlays -= icon('64/sand.dmi')
				//	for(var/area/introof/F in world)
					//	F.overlays += icon('64/sand.dmi')
					//	sleep(rand(300,600))
					//	F.overlays -= icon('64/sand.dmi')
						//if(istype(T,/turf/Title))T.overlays-= S
				if (weather == 23) //snowstorm
					for(var/area/outside/T in world)
						T.overlays += icon('64/snow.dmi')
						sleep(rand(300,600))
						T.overlays -= icon('64/snow.dmi')
				//	for(var/area/introof/F in world)
					//	F.overlays += icon('64/snow.dmi')
					//	sleep(rand(300,600))
					//	F.overlays -= icon('64/snow.dmi')
						//if(M.loc == /area/introof)
						//	if(istype(T,/area/introof))
						//		for(M.client in T)
						//			T.overlays -= icon('64/snow.dmi')
						//if(istype(T,/turf/Title))T.overlays-= S

		//New()	// When the game starts
		//	..()	// do everything you need
		//	time()	// and start the Clock.

			time()
				set background = 1
				label	//A Label.
				//minute2 += 1	//Add 2 minutes. (Changeable)
				//if (minute2 >= 10)	//Make sure you don't get a result like 12:310pm
				//	minute2 -= 10 	//Set's the second digit to 0 (12:30)
				//	minute1 += 1	//Then add one to the first digit (12:40)
					//Basically, if the second digit goes above 9, it will set itself to 0 and add 1 to the first digit.
				//if (minute1 == 6) 	//If we reach 60 minutes
				//	minute1 = 0		//Set the minutes to 0
				//	time2text(world.timeofday,"hh") += 1		//And add one time2text(world.timeofday,"hh").
				if (time2text(world.timeofday,"hh") >= 12)//&& ampm == "am")		//If we reach the afternoon/morning...
					ampm="pm"
				//	if(ampm == "am")	//Check if it's AM or PM
				//		ampm = "pm"		//And change it to the required feature.
				//		goto label		//And go back to the beginning of the cycle.
					/*if(time2text(world.timeofday,"hh") >= 0)
						ampm = "am"
						goto label
					else
						if(time2text(world.timeofday,"hh") >= 12)
							ampm = "pm"
							goto label*/
				else if (time2text(world.timeofday,"hh") == 24&& ampm == "am")//If we reach the afternoon/morning...
					if(time2text(world.timeofday,"hh") >= 0)
						ampm = "am"
						goto label
					else
						if(time2text(world.timeofday,"hh") >= 12)
							ampm = "pm"
							goto label
					//if(ampm == "am")	//Check if it's AM or PM
					//	ampm = "pm"		//And change it to the required feature.
					//	goto label		//And go back to the beginning of the cycle.
					if(ampm == "am")
						ampm = "pm"		//Same here...
						day += 1		//But add a day at midnight.
						/*if(time2text(world.timeofday,"DD") == 16)	//If day is above max (14 is max, so set this at 15)
							if(time2text(world.timeofday,"MM") == "December")		//From here...
								month = "Tevet"
								day = 1
								for(var/obj/Flowers/J)
									J.overlays += icon('64/plants.dmi',icon_state="tg1")
								goto label*/
						if(time2text(world.timeofday,"DD") == 14)
							if(time2text(world.timeofday,"MM") == "Janurary")
								month = "Shevat"
								day = 1
								for(var/obj/Flowers/J)
									J.overlays -= J.overlays
								//for(var/obj/Flowers/J)
								//	J.overlays += icon('64/plants.dmi',icon_state="tg2")
								goto label
						if(time2text(world.timeofday,"DD") == 13)
							if (time2text(world.timeofday,"MM") == "February")
								month = "Adar"
								day = 1
								//for(var/obj/Flowers/J)
								//	J.overlays += icon('64/plants.dmi',icon_state="tg3")
								goto label
						if(time2text(world.timeofday,"DD") == 14)
							if(time2text(world.timeofday,"MM") == "March")
								//year = [year]+=1
								month = "Nissan"
								day = 1
								//for(var/obj/Flowers/J)
								//	J.overlays -= J.overlays
								goto label
						if(time2text(world.timeofday,"DD") == 13)
							if(time2text(world.timeofday,"MM") == "April")		//From here...
								month = "Iyar"
								day = 1
								//for(var/obj/Flowers/J)
								//	J.overlays += icon('64/plants.dmi',icon_state="tg1")
								goto label
						if(time2text(world.timeofday,"DD") == 12)
							if(time2text(world.timeofday,"MM") == "May")
								month = "Sivan"
								day = 1
								for(var/obj/Flowers/J)
									J.overlays += icon('64/plants.dmi',icon_state="tg2")
								goto label
						if(time2text(world.timeofday,"DD") == 11)
							if (time2text(world.timeofday,"MM") == "June")
								month = "Tammuz"
								day = 1
								//for(var/obj/Flowers/J)
								//	J.overlays += icon('64/plants.dmi',icon_state="tg3")
								goto label
						if(time2text(world.timeofday,"DD") == 10)
							if(time2text(world.timeofday,"MM") == "July")
								//year = [year]+=1
								month = "Av"
								day = 1
								//for(var/obj/Flowers/J)
								//	J.overlays -= J.overlays
								goto label
						if(time2text(world.timeofday,"DD") == 9)
							if(time2text(world.timeofday,"MM") == "August")//From here...
								month = "Elul"
								day = 1
								//for(var/obj/Flowers/J)
								//	J.overlays += icon('64/plants.dmi',icon_state="tg1")
								goto label
						if(time2text(world.timeofday,"DD") == 7)
							if(time2text(world.timeofday,"MM") = "September")
								month = "Tishrei"
								day = 1

								//for(var/obj/Flowers/J)
								//	J.overlays += icon('64/plants.dmi',icon_state="tg2")
								goto label
						if(time2text(world.timeofday,"DD") == 7)
							if(time2text(world.timeofday,"MM") == "October")
								month = "Cheshvan"
								day = 1
								for(var/obj/Flowers/J)
									J.overlays += icon('64/plants.dmi',icon_state="tg3")
								goto label
						if(time2text(world.timeofday,"DD") == 5)
							if(time2text(world.timeofday,"MM") == "November")
								month = "Kislev"
								day = 1
								for(var/obj/Flowers/J)
									J.overlays += icon('64/plants.dmi',icon_state="tg3")
								goto label
						if(time2text(world.timeofday,"DD") == 5)
							if(time2text(world.timeofday,"MM") == "December")
								year = [year]+=1
								month = "Tevet"
								day = 1
								//for(var/obj/Flowers/J)
									//J.overlays -= J.overlays
								goto label//...To here changes the month.
				if (time2text(world.timeofday,"hh") == 25)		//If the time2text(world.timeofday,"hh") clock = 13
					hour = time2text(world.timeofday,"hh")//0 Set it to 1 (Stops 13:00)
				//if (time_of_day == 2)
				//	for(var/i = 1 to 20)
				//		lighting.ambient += 0.3
				// ---Darkness/Lightness Ahead!---
				if (time2text(world.timeofday,"hh") == 23&& ampm == "pm") //Set this to when midnight starts.
					//src << "Midnight Arrives."
					//ampm = "am"
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient -= 0.1
					time_of_day = 0
				if (time2text(world.timeofday,"hh") == 3&& ampm == "am")	//Set this to when it begins to get lighter.
					if(time_of_day != 0) return
					//src << "Dawn approaches."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient += 0.1
					time_of_day = 2
				if (time2text(world.timeofday,"hh") == 4&& ampm == "am")	//Set this to when it begins to get lighter.
					src << "Dawn breaks..."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient += 0.1
					time_of_day = 2
				if (time2text(world.timeofday,"hh") == 5&& ampm == "am")	//Set this to when it begins to get lighter.
					//src << "Morning."
					time_of_day = 2
					for(var/i = 1 to 20)
						lighting.ambient += 0.1
					//for(var/snd/sfx/crickets/crkts in world)
					//	del(crkts)
					//	del S
					for(var/obj/townlamp/J)
						if(J.Lit == 1)
							J.light.off()
							J.Lit = 0
							J.overlays -= icon('64/build.dmi',icon_state="ll")
					for(var/obj/TownTorches/Torch/J1)
						if(J1.Lit == 1)
							J1.light.off()
							J1.Lit = 0
							J1.overlays -= icon('64/fire.dmi',icon_state="1")
					for(var/obj/TownTorches/Torcha/J2)
						if(J2.Lit == 1)
							J2.light.off()
							J2.Lit = 0
							J2.overlays -= icon('64/fire.dmi',icon_state="2")
					for(var/obj/TownTorches/Torchb/J3)
						if(J3.Lit == 1)
							J3.light.off()
							J3.Lit = 0
							J3.overlays -= icon('64/fire.dmi',icon_state="4")
					for(var/obj/TownTorches/Torchc/J4)
						if(J4.Lit == 1)
							J4.light.off()
							J4.Lit = 0
							J4.overlays -= icon('64/fire.dmi',icon_state="8")
					for(var/obj/castlwll5a/J5a)
						if(J5a.Lit == 1)
							J5a.light.off()
							J5a.Lit = 0
							J5a.overlays -= icon('64/fire.dmi',icon_state="8")
					for(var/obj/btmwll1a/J6a)
						if(J6a.Lit == 1)
							J6a.light.off()
							J6a.Lit = 0
							J6a.overlays -= icon('64/fire.dmi',icon_state="8")
						//J.overlays -= icon('64/fire.dmi',icon_state="1")
						//J.overlays -= icon('64/fire.dmi',icon_state="2")
						//J.overlays -= icon('64/fire.dmi',icon_state="4")
						//J.overlays -= icon('64/fire.dmi',icon_state="8")
					time_of_day = 2

				if (time2text(world.timeofday,"hh") == 6&& ampm == "am")	//Set this to when it begins to get lighter.
					//src << "Post-Morning."
					time_of_day = 1
					/*var/J = /obj/townlamp
					var/J1 = /obj/TownTorches/Torch
					var/J2 = /obj/TownTorches/Torcha
					var/J3 = /obj/TownTorches/Torchb
					var/J4 = /obj/TownTorches/Torchc
					var/J5a = /obj/castlwll5a
					var/J6a = /obj/btmwll1a*/
					for(var/i = 1 to 20)
						lighting.ambient += 0.1
					time_of_day = 2
				if (time2text(world.timeofday,"hh") == 11&& ampm == "am")	//Set this to when it begins to get lighter.
					src << "High Noon."
					time_of_day = 1
					//for(var/i = 1 to 20)
					//	lighting.ambient += 0.0
					time_of_day = 2
				if (time2text(world.timeofday,"hh") == 18&& ampm == "pm")  //And even lighter...
					if(time_of_day != 2) return
					src << "Dusk sets..."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient -= 0.1

					//for(var/turf in world)
					//	new/snd/sfx/crickets(locate(pick(122,422),pick(294,694),1))
					for(var/obj/townlamp/J)
						if(J.Lit == 0)
							J.overlays += icon('64/build.dmi',icon_state="ll")
							J.light.on()
							J.Lit = 1
							//J.overlays -= icon('64/build.dmi',icon_state="TLO")
					for(var/obj/TownTorches/Torch/J1)
						if(J1.Lit == 0)
							J1.light.on()
							J1.Lit = 1
							J1.overlays += icon('64/fire.dmi',icon_state="1")
					for(var/obj/TownTorches/Torcha/J2)
						if(J2.Lit == 0)
							J2.light.on()
							J2.Lit = 1
							J2.overlays += icon('64/fire.dmi',icon_state="2")
					for(var/obj/TownTorches/Torchb/J3)
						if(J3.Lit == 0)
							J3.light.on()
							J3.Lit = 1
							J3.overlays += icon('64/fire.dmi',icon_state="4")
					for(var/obj/TownTorches/Torchc/J4)
						if(J4.Lit == 0)
							J4.light.on()
							J4.Lit = 1
							J4.overlays += icon('64/fire.dmi',icon_state="8")
					for(var/obj/castlwll5a/J5a)
						if(J5a.Lit == 0)
							J5a.light.on()
							J5a.Lit = 1
							J5a.overlays += icon('64/fire.dmi',icon_state="8")
					for(var/obj/btmwll1a/J6a)
						if(J6a.Lit == 0)
							J6a.light.on()
							J6a.Lit = 1
							J6a.overlays += icon('64/fire.dmi',icon_state="8")
					time_of_day = 0
				if (time2text(world.timeofday,"hh") == 19&& ampm == "pm")  //And even lighter...
					//src << "Dusk Arrives."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient -= 0.1
					time_of_day = 0
				/*if (time2text(world.timeofday,"hh") == 8&& ampm == "pm")  //And even lighter...
					src << "Post-Dusk."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient -= 0.2
					time_of_day = 0
				if (time2text(world.timeofday,"hh") == 8&& ampm == "pm")  //And even lighter...
					src << "Night."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient -= 0.1
					time_of_day = 0*/
				/*if (time2text(world.timeofday,"hh") == 8&& ampm == "am")	//Quite light now...
					src << "Dawn has arrived."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient += 0.10
						sleep(2)
				if (time2text(world.timeofday,"hh") == 11&& ampm == "am")	//Midday! Brightest time of the day!
					src << "Approaching High noon."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient += 0.5
						sleep(2)

					//src << "It is now daytime."
					time_of_day = 2
				if (time2text(world.timeofday,"hh") == 3&& ampm == "pm")	//Now it starts to get darker...
					src << "Brightest time of the day."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient += 0.5
						sleep(2)

					//src << "It is now daytime."
					time_of_day = 2
				if (time2text(world.timeofday,"hh") == 6&& ampm == "pm")	//And darker...
					if(time_of_day != 2) return

					src << "Dusk approaches."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient -= 0.5
						sleep(2)

					//src << "It is now nighttime."
					time_of_day = 0
				if (time2text(world.timeofday,"hh") == 8&& ampm == "pm")	//And darker... (And we start from the top again!)

					src << "Dusk Arrives."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient -= 0.10
						sleep(2)

					//src << "It is now nighttime."
					time_of_day = 0*/
				//	---Darkness/Lightness End. ---
				if (day == 25 && month == "Adar" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am") //set the first 2 items to when a holiday starts. (Do not change the time2text(world.timeofday,"hh"), minute1, minute2 or ampm values!)
					world << "<font color = green><b>\ Happy Purim!</b>"								 //set the message.
				if (day == 27 && month == "Nissan" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am") //And it's just repeated from here...
					world << "<font color = green><b>\ Happy Pesach!</b>"
				if (day == 16 && month == "Sivan" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am")
					world << "<font color = green><b>\ Happy Shavuot!</b>"
				if (day == 6 && month == "Elul" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am")
					world << "<font color = green><b>\ Happy Yom T'rooah / Rosh Hashanah!</b>"
				if (day == 15 && month == "Tishrei" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am")
					world << "<font color = green><b>\ Happy Yom Kippur!</b>"
				if (day == 20 && month == "Tishrei" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am")
					world << "<font color = green><b>\ Happy Sukkot!</b>"
				if (day == 28 && month == "Kislev" && time2text(world.timeofday,"hh") == 24 && minute == 0)// && ampm == "am")
					world << "<font color = green><b>\ Happy Hanukkah!</b>"//...To here.
				sleep(world.realtime) //Wait 2/10ths of a second (Change this to edit how fast time passes. - The higher the number, the slower time goes.)
				goto label

// ---END REQUIRED CODING--- (You don't need anything below this.)

// ---START USEFUL CODING--- (These are useful things, but aren't required.)
/*
mob/Stat()
	statpanel("Who")	//Change this to whatever you want the clock panel to be.
	stat("<center>Time:","<center>[time2text(world.timeofday,"hh")]:[minute1][minute2][ampm]")	//Tells you the time on a Statpanel.
	stat("<center>Date:","<center>[day] of [month]")				//Tells you the date on a Statpanel.
*/
obj/sundial						//Yes, it tells the time.
	name = "Sundial"				//It's called a Clock.
	icon = '64/castl.dmi'	//The file is 'StuffNotNeeded.dmi'
	icon_state = "sundial"		//The icon state is clock.
	density = 1					//You can't walk on it. It's solid!
	plane = 5
	Click()				//Give yourself a verb to examine the clock.
		set popup_menu = 1
		set src in view(3)
		if(get_dist(src,usr)<=3)		//Makes sure you're close enough to read it (3 spaces)
			usr << "<font color = green> The Sundial reads: [time2text(world.timeofday,"hh")]:[minute][ampm] of Day: [day] / Month: [month] / Year: [year] O�C"	//It tells you the time.
			oview() << "<font color = green><b>[usr]</b> looks at the Sundial."			//And tells everyone in your view that you're looking at the clock.
			sleep(3)


obj/weather
	plane = EFFECTS_LAYER	// weather appears over the darkness because I think it looks better that way

	rain
		icon = '64/rain.dmi'

	snow
		icon = '64/snow.dmi'

	sand
		icon = '64/sand.dmi'

