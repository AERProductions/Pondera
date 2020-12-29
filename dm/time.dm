/*Welcome to Neon's Time Code! :D
With this simple code, you can add a realtime clock to your game.
I have made the month and day Harvest Moon style.

Comments throughout.*/
//mob
//	see_invisible = 1
//atom
	//icon = 'dmi/64/dynamic-lighting-textured.dmi'
var/global/
	time_of_day = 3 //1 = setting 0 = rising 2 = day 3 = night 4 = light change
	hour = 11	//The Hours
	ampm = "pm"		//This is because this lib uses a 12hr Clock.
	minute1 = 4		//The first digit of the minutes. (0:?0)
	minute2 = 9		//The second digit of the minutes (0:0?) (This makes sure its12:04 instead of 12:4)
	day = 14			//The day. //S30//A29//N30//I29//S30//T29//A30//E29NY//T30//C29//K30//T29 <days in months
	month = "Nissan"//Shevat//Adar//Nissan//Iyar//Sivan//Tammuz//Av//Elul//Tishrei//Cheshvan//Kislev//Tevet 4/3/4/1 -- Spring / Summer / Autumn / Winter
	season//Spring//Summer//Autumn//Winter
	year = 682
	a
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
		//icon = 'dmi/64/Darkness.dmi'	//The icon of the darkness
		//icon_state = "dark 0"	//First Icon State
		plane = EFFECTS_LAYER// set this plane above everything else so the overlay obscures everything
		layer = 101
		mouse_opacity = 0
		opacity = 0
		var
			lit = 1	// determines if the area is lit or dark.
			obj/weather/Weather

		proc
			weather()//now based on season
				set waitfor = 0
				var/weather = rand(1,40)
				if (season == "Spring")
					if (weather >= 18) //rainy weather
						for(var/turf/drkgrss/G in world)
							for(var/area/outside/T in G)
								wo = 1
								T.overlays += image('dmi/64/rain.dmi')
								sleep(rand(300,600))
								T.overlays -= image('dmi/64/rain.dmi')
								return
						//for(var/area/introof/F in world)
						//	F.overlays += image('dmi/64/rain.dmi')
						//	sleep(rand(300,600))
						//	F.overlays -= image('dmi/64/rain.dmi')
							//if(istype(F,/area/introof))F.overlays-= image('dmi/64/rain.dmi')
				else
					if (season == "Spring")
						if (weather <= 10) //clear weather
							for(var/area/outside/T in world)
								//T.overlays += image('dmi/64/rain.dmi')
								//sleep(rand(300,600))
								T.overlays -= image('dmi/64/rain.dmi')
								T.overlays -= image('dmi/64/sand.dmi')
								T.overlays -= image('dmi/64/snow.dmi')
								return
					//for(var/area/introof/F in world)
					//	F.overlays += image('dmi/64/rain.dmi')
					//	sleep(rand(300,600))
					//	F.overlays -= image('dmi/64/rain.dmi')
						//if(istype(T,/turf/Title))T.overlays-= R
				if (season == "Summer")
					if (weather >= 35) //sandstorm
						for(var/turf/sand1/S1 in world)
							for(var/area/outside/T in S1)
								T.overlays += image('dmi/64/sand.dmi')
								sleep(rand(300,600))
								T.overlays -= image('dmi/64/sand.dmi')
								return
				else
					if (season == "Summer")
						if (weather <= 10) //clear weather
							for(var/area/outside/T in world)
								//T.overlays += image('dmi/64/rain.dmi')
								//sleep(rand(300,600))
								T.overlays -= image('dmi/64/rain.dmi')
								T.overlays -= image('dmi/64/sand.dmi')
								T.overlays -= image('dmi/64/snow.dmi')
								return
					//	for(var/area/introof/F in world)
						//	F.overlays += image('dmi/64/sand.dmi')
						//	sleep(rand(300,600))
						//	F.overlays -= image('dmi/64/sand.dmi')
							//if(istype(T,/turf/Title))T.overlays-= S
				if (season == "Winter")
					if (weather >= 23) //snowstorm
						for(var/turf/snow/S in world)
							for(var/area/outside/T in S)
								T.overlays += image('dmi/64/snow.dmi')
								sleep(rand(300,600))
								T.overlays -= image('dmi/64/snow.dmi')
								return
				else
					if (season == "Winter")
						if (weather <= 10) //clear weather
							for(var/area/outside/T in world)
								//T.overlays += image('dmi/64/rain.dmi')
								//sleep(rand(300,600))
								T.overlays -= image('dmi/64/rain.dmi')
								T.overlays -= image('dmi/64/sand.dmi')
								T.overlays -= image('dmi/64/snow.dmi')
								return
				//	for(var/area/introof/F in world)
					//	F.overlays += image('dmi/64/snow.dmi')
					//	sleep(rand(300,600))
					//	F.overlays -= image('dmi/64/snow.dmi')
						//if(M.loc == /area/introof)
						//	if(istype(T,/area/introof))
						//		for(M.client in T)
						//			T.overlays -= image('dmi/64/snow.dmi')
						//if(istype(T,/turf/Title))T.overlays-= S
			..()

			time()
				set waitfor = 0
				//set background = 1
				//call(plant/ueiktree/proc/Grow2)()
				//Grow2()

				label	//A Label.

				minute2 += 1	//Add 2 minutes. (Changeable)
				if (minute2 >= 10)	//Make sure you don't get a result like 12:310pm
					minute2 -= 10 	//Set's the second digit to 0 (12:30)
					minute1 += 1	//Then add one to the first digit (12:40)
					//Basically, if the second digit goes above 9, it will set itself to 0 and add 1 to the first digit.
				if (minute1 == 6) 	//If we reach 60 minutes
					minute1 = 0		//Set the minutes to 0
					hour += 1		//And add one hour.
				if (hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am")		//If we reach the afternoon/morning...
					//Holiday()
					if(ampm == "am")	//Check if it's AM or PM
						ampm = "pm"		//And change it to the required feature.
						goto label		//And go back to the beginning of the cycle.
				else if (hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "pm")		//If we reach the afternoon/morning...
					//if(ampm == "am")	//Check if it's AM or PM
					//	ampm = "pm"		//And change it to the required feature.
					//	goto label		//And go back to the beginning of the cycle.
					if(ampm == "pm")
						ampm = "am"		//Same here...
						day += 1		//But add a day at midnight.
						call(/world/proc/WorldStatus)() //update world status date
						//world.log << "Pondera Date- day [day] / month [month] / year [year] O·C· Pondera Time- [hour]: [minute1][minute2][ampm]"
						//call(/world/proc/MtrShwr)(world)  //S30//A29//N30//I29//S30//T29//A30//E29NY//T30//C29//K30//T29
						//call(Holiday())()
						//Sabbath handling

						if((month == "Shevat") && (day == 5||day == 12||day == 19||day == 26))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Shevat") && (day == 6||day == 13||day == 20||day == 27))
							world << "The Sabbath ends at sunset."

						if((month == "Adar") && (day == 3||day == 10||day == 17||day == 24))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Adar") && (day == 6||day == 11||day == 18||day == 25))
							world << "The Sabbath ends at sunset."

						if((month == "Nissan") && (day == 2||day == 9||day == 16||day == 23||day == 30))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Nissan") && (day == 3||day == 10||day == 17||day == 24))
							world << "The Sabbath ends at sunset."

						if((month == "Iyar") && (day == 7||day == 14||day == 21||day == 28))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Iyar") && (day == 1||day == 8||day == 15||day == 22||day == 29))
							world << "The Sabbath ends at sunset."

						if((month == "Sivan") && (day == 6||day == 13||day == 20||day == 27))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Sivan") && (day == 7||day == 14||day == 21||day == 28))
							world << "The Sabbath ends at sunset."

						if((month == "Tammuz") && (day == 4||day == 11||day == 18||day == 25))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Tammuz") && (day == 5||day == 12||day == 19||day == 26))
							world << "The Sabbath ends at sunset."

						if((month == "Av") && (day == 3||day == 10||day == 17||day == 24))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Av") && (day == 4||day == 11||day == 18||day == 25))
							world << "The Sabbath ends at sunset."

						if((month == "Elul") && (day == 1||day == 8||day == 15||day == 22||day == 29))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Elul") && (day == 2||day == 9||day == 16||day == 23))
							world << "The Sabbath ends at sunset."

						if((month == "Tishrei") && (day == 7||day == 14||day == 21||day == 28))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Tishrei") && (day == 1||day == 8||day == 15||day == 22||day == 29))
							world << "The Sabbath ends at sunset."

						if((month == "Cheshvan") && (day == 5||day == 12||day == 19||day == 26))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Cheshvan") && (day == 6||day == 13||day == 20||day == 27))
							world << "The Sabbath ends at sunset."

						if((month == "Kislev") && (day == 4||day == 11||day == 18||day == 25))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Kislev") && (day == 5||day == 12||day == 19||day == 26))
							world << "The Sabbath ends at sunset."

						if((month == "Tevet") && (day == 3||day == 10||day == 17||day == 24))
							world << "The Sabbath begins at sunset. Enjoy spiritual rest."
						if((month == "Tevet") && (day == 4||day == 11||day == 18||day == 25))
							world << "The Sabbath ends at sunset."

						//new months

						if(day == 30 && month == "Tevet" && hour==12 && ampm == "am")//29
							month = "Shevat"
							day = 1
							season = "Spring"
							call(/world/proc/SetSeason)()
							/*for(var/obj/Flowers/J)
								J.overlays -= J.overlays
							for(var/turf/Grass/A)
								A.overlays -= A.overlays
							for(var/turf/ClayDeposit/CD)
								CD.overlays -= CD.overlays
							for(var/turf/ObsidianField/OF)
								OF.overlays -= OF.overlays
							for(var/turf/Sand/S)
								S.overlays -= S.overlays
							for(var/turf/TarPit/TP)
								TP.overlays -= TP.overlays
							for(var/obj/Soil/soil/So)
								So.overlays -= So.overlays
							for(var/obj/Soil/richsoil/RS)
								RS.overlays -= RS.overlays
							for(var/obj/Rocks/IRocks/IR)
								IR.overlays -= IR.overlays
							for(var/obj/Rocks/CRocks/CR)
								CR.overlays -= CR.overlays
							for(var/obj/Rocks/LRocks/LR)
								LR.overlays -= LR.overlays
							for(var/obj/Rocks/ZRocks/ZR)
								ZR.overlays -= ZR.overlays
							for(var/obj/Rocks/SRocks/SR)
								SR.overlays -= SR.overlays
							for(var/obj/plant/UeikTreeA/UTA)
								UTA.overlays -= UTA.overlays
							for(var/obj/plant/UeikTreeH/UTH)
								UTH.overlays -= UTH.overlays*/
							//for(var/obj/Flowers/J)
							//	J.overlays += icon('64/plants.dmi',icon_state="tg2")
							goto label
						if(day == 31 && month == "Shevat" && hour==12 && ampm == "am")//30
							month = "Adar"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Spring"
							//for(var/obj/Flowers/J)
							//	J.overlays += icon('64/plants.dmi',icon_state="tg3")
							goto label
						if(day == 30 && month == "Adar" && hour==12 && ampm == "am")//29
							//year = [year]+=1
							month = "Nissan"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Spring"
							//for(var/obj/Flowers/J)
							//	J.overlays -= J.overlays
							goto label
						if(day == 31 && month == "Nissan" && hour==12 && ampm == "am")//30
							month = "Iyar"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Spring"
							//for(var/obj/Flowers/J)
							//	J.overlays += icon('64/plants.dmi',icon_state="tg1")
							goto label
						if(day == 30 && month == "Iyar" && hour==12 && ampm == "am")//29
							month = "Sivan"
							day = 1
							season = "Summer"
							call(/world/proc/SetSeason)()
							//for(var/obj/Flowers/J)
								//J.overlays += icon('64/plants.dmi',icon_state="tg2")
							goto label
						if(day == 31 && month == "Sivan" && hour==12 && ampm == "am")//30
							month = "Tammuz"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Summer"
							//for(var/obj/Flowers/J)
							//	J.overlays += icon('64/plants.dmi',icon_state="tg3")
							goto label
						if(day == 30 && month == "Tammuz" && hour==12 && ampm == "am")//29
							//year = [year]+=1
							month = "Av"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Summer"
							//for(var/obj/Flowers/J)
							//	J.overlays -= J.overlays
							goto label
						if(day == 31 && month == "Av" && hour==12 && ampm == "am")//30
							month = "Elul"
							day = 1
							season = "Autumn"
							call(/world/proc/SetSeason)()
							/*for(var/obj/plant/UeikTreeA/UTA)
								UTA.overlays += icon('64/tree.dmi',icon_state="UTAaut")//these lines add autumn sprites.
							for(var/obj/plant/UeikTreeH/UTH)
								UTH.overlays += icon('64/tree.dmi',icon_state="UTHaut")//it should probably be handled differently
							for(var/obj/Flowers/J)
								J.overlays += icon('64/plants.dmi',icon_state="tg1")//perhaps initilize them at runtime based on season/month
							for(var/turf/Grass/A)
								//if(prob(15))
								A.overlays += icon('dmi/64/gen.dmi',icon_state="grassaut")//otherwise, if the server goes down after these dates
							for(var/turf/Grass/A)
								if(prob(15))
									A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass")//the overlays won't be set properly
							for(var/turf/Grass/A)
								if(prob(15))
									A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass2")*/
							goto label
						if(day == 30 && month == "Elul" && hour==12 && ampm == "am")//29
							year = [year]+=1
							month = "Tishrei"
							day = 1
							call(/world/proc/SetSeason)()
							/*for(var/turf/Grass/A)
								if(prob(15))
									A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass")
							for(var/turf/Grass/A)
								if(prob(15))
									A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass2")*/
							//season = "Autumn"
							//for(var/obj/Flowers/J)
							//	J.overlays += icon('64/plants.dmi',icon_state="tg2")
							goto label
						if(day == 31 && month == "Tishrei" && hour==12 && ampm == "am")//add a day so this is 30
							month = "Cheshvan"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Autumn"
							//for(var/obj/Flowers/J)
								//J.overlays += icon('64/plants.dmi',icon_state="tg2")
							goto label
						if(day == 30 && month == "Cheshvan" && hour==12 && ampm == "am")//29
							month = "Kislev"
							day = 1
							call(/world/proc/SetSeason)()
							//season = "Autumn"
							//for(var/obj/Flowers/J)
							//	J.overlays += icon('64/plants.dmi',icon_state="tg3")
							goto label
						if(day == 31 && month == "Kislev" && hour==12 && ampm == "am")//30
							//year = [year]+=1
							month = "Tevet"
							day = 1
							season = "Winter"
							call(/world/proc/SetSeason)()
							//for(var/turf/Water/W)
								//W.overlays += icon('dmi/64/gen.dmi',icon_state="waterwint")
							/*for(var/turf/ClayDeposit/CD)
								CD.overlays += icon('dmi/64/gen.dmi',icon_state="claywint")
							for(var/turf/ObsidianField/OF)
								OF.overlays += icon('dmi/64/gen.dmi',icon_state="obsidianwint")
							for(var/turf/Sand/S)
								S.overlays += icon('dmi/64/gen.dmi',icon_state="sandwint")
							for(var/turf/TarPit/TP)
								TP.overlays += icon('dmi/64/gen.dmi',icon_state="tarwint")
							for(var/obj/Soil/soil/So)
								So.overlays += icon('dmi/64/gen.dmi',icon_state="dirtwint")
							for(var/obj/Soil/richsoil/RS)
								RS.overlays += icon('dmi/64/gen.dmi',icon_state="richsoilwint")
							for(var/obj/Rocks/IRocks/IR)
								IR.overlays += icon('64/creation.dmi',icon_state="irockwint")
							for(var/obj/Rocks/CRocks/CR)
								CR.overlays += icon('64/creation.dmi',icon_state="crockwint")
							for(var/obj/Rocks/LRocks/LR)
								LR.overlays += icon('64/creation.dmi',icon_state="lrockwint")
							for(var/obj/Rocks/ZRocks/ZR)
								ZR.overlays += icon('64/creation.dmi',icon_state="zrockwint")
							for(var/obj/Rocks/SRocks/SR)
								SR.overlays += icon('64/creation.dmi',icon_state="srockwint")
							for(var/obj/plant/UeikTreeA/UTA)
								UTA.overlays += icon('64/tree.dmi',icon_state="UTAwint")
							for(var/obj/plant/UeikTreeH/UTH)
								UTH.overlays += icon('64/tree.dmi',icon_state="UTHwint")
							for(var/turf/Grass/A)
								A.overlays += icon('64/snow.dmi',icon_state="snow")
							for(var/obj/Flowers/J)
								J.overlays += icon('64/plants.dmi',icon_state="tg4")*/
							goto label
							/*
						if(day == 31)
							if(month == "Spring")		//From here...
								month = "Summer"
								day = 1
								//call(/world/proc/MtrShwr)(world)
								for(var/obj/Flowers/J)
									J.overlays += image('dmi/64/plants.dmi',icon_state="tg")
								goto label
							if(month == "Summer")
								month = "Autumn"
								day = 1
								//call(/world/proc/MtrShwr)(world)
								for(var/obj/Flowers/J)
									J.overlays += image('dmi/64/plants.dmi',icon_state="tg2")
								goto label
							if (month == "Autumn")
								month = "Winter"
								day = 1
								//call(/world/proc/MtrShwr)(world)
								for(var/obj/Flowers/J)
									J.overlays += image('dmi/64/plants.dmi',icon_state="tg3")
								goto label
							if(month == "Winter")
								year = [year]+=1
								month = "Spring"
								day = 1
								call(/world/proc/MtrShwr)(world)
								for(var/obj/Flowers/J)
									J.overlays -= J.overlays
								goto label*/
								//...To here changes the month.
				if (hour == 13)		//If the hour clock = 13
					hour = 1	//Set it to 1 (Stops 13:00)
				//if (time_of_day == 2)
				//	for(var/i = 1 to 20)
				//		lighting.ambient += 0.3
				// ---Darkness/Lightness Ahead!---
				//if (hour == 10 && minute1 == 5 && minute2 == 9 && ampm == "pm") //Set this to when midnight starts.
					//world << "Night sets."
					//if(time_of_day != 3) return
					//time_of_day = 3
					//ampm = "am"
					//time_of_day = 1 1 = setting 0 = rising 2 = day 3 = night?
					//for(var/i = 1 to 20)
						//lighting.ambient = 0
				if (hour == 11 && minute1 == 5 && minute2 == 9 && ampm == "pm") //Set this to when midnight starts.
					world << "<font color = #e3e1D7>Midnight Arrives.</font>"
					//if(time_of_day != 3) return
					time_of_day = 3
					//ampm = "am"
					//time_of_day = 1 1 = setting 0 = rising 2 = day 3 = night?
					//for(var/i = 1 to 20)
						//lighting.ambient = 0
					//time_of_day = 3
				//if (hour == 12 && minute1 == 5 && minute2 == 9 && ampm == "am") //Set this to when midnight starts.
					//time_of_day = 3


				//if (hour == 1 && minute1 == 5 && minute2 == 9 && ampm == "am") //Set this to when midnight starts.
					//world << "Midnight Arrives."
					//if(time_of_day != 3) return
					//time_of_day = 3
				//if (hour == 2 && minute1 == 5 && minute2 == 9 && ampm == "am") //Set this to when midnight starts.
					//world << "Midnight Arrives."
					//if(time_of_day != 3) return
					//time_of_day = 3
				//if (hour == 3 && minute1 == 5 && minute2 == 9 && ampm == "am") //Set this to when midnight starts.
					//world << "Midnight Arrives."
					//if(time_of_day != 3) return
					//time_of_day = 3
				if (hour == 4 && minute1 == 5 && minute2 == 9 && ampm == "am") //Set this to when midnight starts.
					world << "<font color = #ffca7c>Dawn breaks...</font>"
					//if(time_of_day != 3) return
					time_of_day = 0
					//for(var/i = 1 to 20)
						//lighting.ambient = 0.5
				//if (hour == 5 && minute1 == 5 && minute2 == 9 && ampm == "am")	//Set this to when it begins to get lighter.
					//world << "Dawn breaks..."
					//time_of_day = 1
					//if(time_of_day != 3) return
					//time_of_day = 0//1 = setting 0 = rising 2 = day 3 = night 4 = light change
					//for(var/i = 1 to 20)
						//lighting.ambient = 1
					//time_of_day = 2
					//time_of_day = 0
					//time_of_day = 0//1 = setting 0 = rising 2 = day 3 = night 4 = light change
				if (hour == 6 && minute1 == 5 && minute2 == 9 && ampm == "am")	//Set this to when it begins to get lighter.
					//time_of_day = 0
					//for(var/i = 1 to 20)
						//lighting.ambient = 2
					for(var/obj/townlamp/J)
						if(J.Lit == 1)
							J.light.off()
							J.Lit = 0
							J.overlays -= image('dmi/64/build.dmi',icon_state="ll")
					for(var/obj/TownTorches/Torch/J1)
						if(J1.Lit == 1)
							J1.light.off()
							J1.Lit = 0
							J1.overlays -= image('dmi/64/fire.dmi',icon_state="1")
					for(var/obj/TownTorches/Torcha/J2)
						if(J2.Lit == 1)
							J2.light.off()
							J2.Lit = 0
							J2.overlays -= image('dmi/64/fire.dmi',icon_state="2")
					for(var/obj/TownTorches/Torchb/J3)
						if(J3.Lit == 1)
							J3.light.off()
							J3.Lit = 0
							J3.overlays -= image('dmi/64/fire.dmi',icon_state="4")
					for(var/obj/TownTorches/Torchc/J4)
						if(J4.Lit == 1)
							J4.light.off()
							J4.Lit = 0
							J4.overlays -= image('dmi/64/fire.dmi',icon_state="8")
					for(var/obj/castlwll5a/J5a)
						if(J5a.Lit == 1)
							J5a.light.off()
							J5a.Lit = 0
							J5a.overlays -= image('dmi/64/fire.dmi',icon_state="8")
					for(var/obj/btmwll1a/J6a)
						if(J6a.Lit == 1)
							J6a.light.off()
							J6a.Lit = 0
							J6a.overlays -= image('dmi/64/fire.dmi',icon_state="8")

				//Seven o' clock minute countdown

				if (hour == 7 && minute1 == 5 && minute2 == 9 && ampm == "am")	//Set this to when it begins to get lighter.
					//world << "<font color = #ffca7c>Dawn Arrives.</font>"
					time_of_day = 2
					//for(var/i = 1 to 20)
						//lighting.ambient = 3
//1 = setting 0 = rising 2 = day 3 = night 4 = light change
				//Eight o' clock minute countdown
				//if (hour == 8 && minute1 == 5 && minute2 == 9 && ampm == "am")	//Set this to when it begins to get lighter.
					//src << "Morning."
					//time_of_day = 2
					//for(var/i = 1 to 20)
						//lighting.ambient = 4
				//Nine o' clock minute countdown
				//if (hour == 9 && minute1 == 5 && minute2 == 9 && ampm == "am")	//Set this to when it begins to get lighter.
					//src << "Morning."
					//time_of_day = 2
					//for(var/i = 1 to 20)
						//lighting.ambient = 5

					//Ten o' clock minute countdown

				//if (hour == 10 && minute1 == 5 && minute2 == 9 && ampm == "am")
					//for(var/i = 1 to 20)
						//lighting.ambient = 4
					//time_of_day = 2

				//Eleven o' clock minute countdown

				if (hour == 11 && minute1 == 5 && minute2 == 9 && ampm == "am")	//Set this to when it begins to get lighter.
					world << "<font color = #f9d71c>High Noon.</font>"
					//time_of_day = 2
					//for(var/i = 1 to 20)
						//lighting.ambient = 20

				//Twelve o' clock minute countdown

				//if (hour == 12 && minute1 == 5 && minute2 == 9 && ampm == "pm")	//Set this to when it begins to get lighter.
					//world << "High Noon."
					//time_of_day = 2
					//for(var/i = 1 to 20)
						//lighting.ambient = 5
				//One o' clock minute countdown

				//if (hour == 1 && minute1 == 5 && minute2 == 9 && ampm == "pm")	//Set this to when it begins to get lighter.
					//world << "High Noon."
					//time_of_day = 2

				//Two o' clock minute countdown


				//if (hour == 2 && minute1 == 5 && minute2 == 9 && ampm == "pm")	//Set this to when it begins to get lighter.
					//world << "High Noon."
					//time_of_day = 2

				//Three o' clock minute countdown

				//if (hour == 3 && minute1 == 5 && minute2 == 9 && ampm == "pm")
					//time_of_day = 2

				//Four o' clock minute countdown

				//if (hour == 4 && minute1 == 5 && minute2 == 9 && ampm == "pm")	//Set this to when it begins to get lighter.
					//world << "High Noon."
					//time_of_day = 2
					//for(var/i = 1 to 20)
						//lighting.ambient = 3
				//Five o' clock minute countdown

				if (hour == 5 && minute1 == 5 && minute2 == 9 && ampm == "pm")	//Set this to when it begins to get lighter.
					//world << "High Noon."
					time_of_day = 1

				if (hour == 6 && minute1 == 5 && minute2 == 9 && ampm == "pm")  //And even lighter...
					//if(time_of_day != 1) return
					world << "<font color = #fd535e>Dusk sets...</font>"
					//time_of_day = 1//1 = setting 0 = rising 2 = day 3 = night 4 = light change
					//for(var/i = 1 to 20)
						//lighting.ambient = 2  //And even lighter...
					for(var/obj/townlamp/J)
						if(J.Lit == 0)
							J.overlays += image('dmi/64/build.dmi',icon_state="ll")
							J.light.on()
							J.Lit = 1
							//J.overlays -= image('dmi/64/build.dmi',icon_state="TLO")
					for(var/obj/TownTorches/Torch/J1)
						if(J1.Lit == 0)
							J1.light.on()
							J1.Lit = 1
							J1.overlays += image('dmi/64/fire.dmi',icon_state="1")
					for(var/obj/TownTorches/Torcha/J2)
						if(J2.Lit == 0)
							J2.light.on()
							J2.Lit = 1
							J2.overlays += image('dmi/64/fire.dmi',icon_state="2")
					for(var/obj/TownTorches/Torchb/J3)
						if(J3.Lit == 0)
							J3.light.on()
							J3.Lit = 1
							J3.overlays += image('dmi/64/fire.dmi',icon_state="4")
					for(var/obj/TownTorches/Torchc/J4)
						if(J4.Lit == 0)
							J4.light.on()
							J4.Lit = 1
							J4.overlays += image('dmi/64/fire.dmi',icon_state="8")
					for(var/obj/castlwll5a/J5a)
						if(J5a.Lit == 0)
							J5a.light.on()
							J5a.Lit = 1
							J5a.overlays += image('dmi/64/fire.dmi',icon_state="8")
					for(var/obj/btmwll1a/J6a)
						if(J6a.Lit == 0)
							J6a.light.on()
							J6a.Lit = 1
							J6a.overlays += image('dmi/64/fire.dmi',icon_state="8")
				//Five o' clock minute countdown


				//if (hour == 7 && minute1 == 5 && minute2 == 9 && ampm == "pm")  //And even lighter...
					//src << "Dusk Arrives." //1 = setting 0 = rising 2 = day 3 = night 4 = light change
					//time_of_day = 1
					//for(var/i = 1 to 20)
						//lighting.ambient = 1
					//time_of_day = 1
				//Eight o' clock minute countdown

				if (hour == 8 && minute1 == 5 && minute2 == 9 && ampm == "pm")  //And even darker...
					//world << "<font color = #fd535e>Dusk Arrives.</font>"
					//time_of_day = 1
					//for(var/i = 1 to 20)
						//lighting.ambient = 0
					time_of_day = 3

				//if (hour == 9 && minute1 == 5 && minute2 == 9 && ampm == "pm")  //And even darker...
					//src << "Post-Dusk."
					//time_of_day = 1
					//for(var/i = 1 to 20)
						//lighting.ambient = 0
					//time_of_day = 3
				if(time_of_day == 3 && hour == 10 && ampm == "pm")//lightkeeper fixes logging into darkness when it is suppose to be daytime
					for(a = 1 to 20)
						lighting.ambient = 0.9
				if(time_of_day == 3 && hour == 10 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 0.8
				if(time_of_day == 3 && hour == 11 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 0.7
				if(time_of_day == 3 && hour == 11 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 0.6
				if(time_of_day == 3 && hour == 12 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 0
				if(time_of_day == 3 && hour == 12 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 0.1
				if(time_of_day == 3 && hour == 1 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 0.6
				if(time_of_day == 3 && hour == 1 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 0.7
				if(time_of_day == 3 && hour == 2 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 0.8
				if(time_of_day == 3 && hour == 2 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 0.9
				if(time_of_day == 3 && hour == 3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1
				if(time_of_day == 3 && hour == 3 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.1
				if(time_of_day == 3 && hour == 4 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.2
				if(time_of_day == 3 && hour == 4 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.3
				if(time_of_day == 0 && hour == 5 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.5
				if(time_of_day == 0 && hour == 5 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.6
				if(time_of_day == 0 && hour == 6 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.7
				if(time_of_day == 0 && hour == 6 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.8
				if(time_of_day == 0 && hour == 7 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 1.9
				if(time_of_day == 0 && hour == 7 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 2
				if(time_of_day == 2 && hour == 8 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 3
				if(time_of_day == 2 && hour == 8 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 3.5
				if(time_of_day == 2 && hour == 9 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 4
				if(time_of_day == 2 && hour == 9 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 4.5
				if(time_of_day == 2 && hour == 10 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 5
				if(time_of_day == 2 && hour == 10 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 5.5
				if(time_of_day == 2 && hour == 11 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 6
				if(time_of_day == 2 && hour == 11 && minute1==3 && ampm == "am")
					for(a = 1 to 20)
						lighting.ambient = 6.5
				if(time_of_day == 2 && hour == 12 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 20
				if(time_of_day == 2 && hour == 12 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 15.5
				if(time_of_day == 2 && hour == 1 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 6
				if(time_of_day == 2 && hour == 1 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 5.5
				if(time_of_day == 2 && hour == 2 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 5
				if(time_of_day == 2 && hour == 2 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 4.5
				if(time_of_day == 2 && hour == 3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 4
				if(time_of_day == 2 && hour == 3 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 3.5
				if(time_of_day == 2 && hour == 4 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 3
				if(time_of_day == 2 && hour == 4 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 2.9
				if(time_of_day == 2 && hour == 5 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 2.8
				if(time_of_day == 2 && hour == 5 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 2.7
				if(time_of_day == 1 && hour == 6 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 2
				//if(time_of_day == 1 && hour == 6 && minute1==3 && ampm == "pm")
					//for(a = 1 to 20)
						//lighting.ambient = 1.9
				if(time_of_day == 1 && hour == 7 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 1.8
				if(time_of_day == 1 && hour == 7 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 1.5
				if(time_of_day == 3 && hour == 8 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 1.3
				if(time_of_day == 3 && hour == 8 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 1.2
				if(time_of_day == 3 && hour == 9 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 1.1
				if(time_of_day == 3 && hour == 9 && minute1==3 && ampm == "pm")
					for(a = 1 to 20)
						lighting.ambient = 1
				if (day == 1 && month == "Shevat")
					var/mob/players/M
					for(M in world)
						if(M.gr==1)//gift received from previous holiday in winter
							M.gr=0

				if (day == 13 && month == "Adar" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am") //set the first 2 items to when a holiday starts. (Do not change the time2text(world.timeofday,"hh"), minute1, minute2 or ampm values!)
					world << "<font color = green><b>\ Happy Purim!</b>"								 //set the message.
				if (day == 14 && month == "Nissan" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am") //And it's just repeated from here...
					world << "<font color = green><b>\ Happy Pesach!</b>"
				if (day == 6 && month == "Sivan" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am")
					world << "<font color = green><b>\ Happy Shavuot!</b>"
				if (day == 29 && month == "Elul" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am")
					world << "<font color = green><b>\ Happy Yom T'rooah / Rosh Hashanah!</b>"
				if (day == 9 && month == "Tishrei" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am")
					world << "<font color = green><b>\ Happy Yom Kippur!</b>"
				if (day == 14 && month == "Tishrei" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am")
					world << "<font color = green><b>\ Happy Sukkot!</b>"
				if (day == 24 && month == "Kislev" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")// && ampm == "am")
					world << "<font color = green><b>\ Happy Hanukkah!</b>"
				if (day == 10 && month == "Tevet" && hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "am")// && ampm == "am")
					world << "<font color = green><b>\ Happy Celebration Day!</b>"
				/*
				if (day == 1 && month == "Spring" && hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am") //set the first 2 items to when a holiday starts. (Do not change the hour, minute1, minute2 or ampm values!)
					world << "<font color = green><b>\ Happy Survival Day!</b>"								 //set the message.
					var/mob/players/M
					for(M in world)
						if(M.gr==1)//gift received from previous holiday in winter
							M.gr=0
				if (day == 14 && month == "Spring" && hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am") //And it's just repeated from here...
					world << "<font color = green><b>\ Happy Effort Day!</b>"
				if (day == 15 && month == "Summer" && hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am")
					world << "<font color = green><b>\ Happy Feast Day!</b>"
				if (day == 16 && month == "Autumn" && hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am")
					world << "<font color = green><b>\ Happy Harvest Day!</b>"
				if (day == 17 && month == "Autumn" && hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am")
					world << "<font color = green><b>\ Happy Bounty Day!</b>"
				if (day == 25 && month == "Winter" && hour == 12 && minute1 == 0 && minute2 == 0 && ampm == "am")
					world << "<font color = green><b>\ Happy Celebrate Day!</b>"
				*/

				sleep(35 * world.tick_lag) //Wait 2/10ths of a second (Change this to edit how fast time passes. - The higher the number, the slower time goes.)
				goto label
				/*if (hour == 8 && minute1 == 5 && minute2 == 9 && ampm == "pm")  //And even lighter...
					src << "Night."
					time_of_day = 1
					for(var/i = 1 to 20)
						lighting.ambient -= 0.1
					time_of_day = 0*/
/*if (hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "am")	//Quite light now...
					src << "Dawn has arrived."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient += 0.10
						sleep(2)
				if (hour == 11 && minute1 == 0 && minute2 == 0 && ampm == "am")	//Midday! Brightest time of the day!
					src << "Approaching High noon."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient += 0.5
						sleep(2)

					//src << "It is now daytime."
					time_of_day = 2
				if (hour == 3 && minute1 == 0 && minute2 == 0 && ampm == "pm")	//Now it starts to get darker...
					src << "Brightest time of the day."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient += 0.5
						sleep(2)

					//src << "It is now daytime."
					time_of_day = 2
				if (hour == 6 && minute1 == 0 && minute2 == 0 && ampm == "pm")	//And darker...
					if(time_of_day != 2) return

					src << "Dusk approaches."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient -= 0.5
						sleep(2)

					//src << "It is now nighttime."
					time_of_day = 0
				if (hour == 8 && minute1 == 0 && minute2 == 0 && ampm == "pm")	//And darker... (And we start from the top again!)

					src << "Dusk Arrives."
					time_of_day = 1

					for(var/i = 1 to 20)
						lighting.ambient -= 0.10
						sleep(2)

					//src << "It is now nighttime."
					time_of_day = 0*/
				//	---Darkness/Lightness End. ---
												 //...To here.

// ---END REQUIRED CODING--- (You don't need anything below this.)

// ---START USEFUL CODING--- (These are useful things, but aren't required.)
/*
mob/Stat()
	statpanel("Who")	//Change this to whatever you want the clock panel to be.
	stat("<center>Time:","<center>[hour]:[minute1][minute2][ampm]")	//Tells you the time on a Statpanel.
	stat("<center>Date:","<center>[day] of [month]")				//Tells you the date on a Statpanel.
*/
obj/Buildable/sundial//Yes, it tells the time.
	name = "Sundial"				//It's called a Clock.
	icon = 'dmi/64/castl.dmi'	//The file is 'StuffNotNeeded.dmi'
	icon_state = "sundial"		//The icon state is clock.
	Target
	density = 1					//You can't walk on it. It's solid!
	plane = 5
	Click()				//Give yourself a verb to examine the clock.
		set popup_menu = 1
		set src in view(3)
		usr.Target = src
		var/obj/Navi/Compas/CL = locate();var/obj/Navi/Arrow/AL = locate()
		var/obj/Navi/Compas/C = new;var/obj/Navi/Arrow/A = new
		if(CL&&AL in usr.client.screen)
			goto clab
			return
		else
			usr.client.screen -= C;usr.client.screen -= A
			usr.client.screen += C;usr.client.screen += A
			return
		clab
		if(get_dist(src,usr)<=3)		//Makes sure you're close enough to read it (3 spaces)
			if(time_of_day == 1)
				usr << "Can't read the Sundial at night!"
				return
			else
				if(time_of_day == 0)
					usr << "Can't read the Sundial at night!"
					return
				else
					if (time_of_day == 2)
						usr << "<font color = green> The Sundial reads: [hour]:[minute1][minute2][ampm] of Day: [day] / Season: [month] / Year: [year] O·C"	//It tells you the time.
						oview() << "<font color = green><b>[usr]</b> looks at the Sundial."			//And tells everyone in your view that you're looking at the clock.
						sleep(3)
						if(CL&&AL in usr.client.screen)
							return
						else
							usr.client.screen -= C;usr.client.screen -= A
							usr.client.screen += C;usr.client.screen += A
							return


obj/weather
	plane = EFFECTS_LAYER	// weather appears over the darkness because I think it looks better that way

	rain
		icon = 'dmi/64/rain.dmi'

	snow
		icon = 'dmi/64/snow.dmi'

	sand
		icon = 'dmi/64/sand.dmi'

//for(var/snd/sfx/crickets/crkts in world)
					//	del(crkts)
					//	del S
					/*var/J = /obj/townlamp
					var/J1 = /obj/TownTorches/Torch
					var/J2 = /obj/TownTorches/Torcha
					var/J3 = /obj/TownTorches/Torchb
					var/J4 = /obj/TownTorches/Torchc
					var/J5a = /obj/castlwll5a
					var/J6a = /obj/btmwll1a*/
						//J.overlays -= image('dmi/64/fire.dmi',icon_state="1")
						//J.overlays -= image('dmi/64/fire.dmi',icon_state="2")
						//J.overlays -= image('dmi/64/fire.dmi',icon_state="4")
						//J.overlays -= image('dmi/64/fire.dmi',icon_state="8")