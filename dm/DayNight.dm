// dm/DayNight.dm — Day/night cycle with animated lighting overlay and time-based transitions.

var
	obj/screen_fx/day_night/DAY_NIGHT		= new
	global/time_of_day
	global/dne = /area/screen_fx/day_night

client
	proc
		// Toggle day/night overlay on/off client screen.
		toggle_daynight(i = 0)
			if(i)
				if(!(DAY_NIGHT in screen))
					screen += DAY_NIGHT
			else
				if(DAY_NIGHT in screen)
					screen -= DAY_NIGHT

obj
	screen_fx
		day_night
			icon				= 'dmi/daynight.dmi'
			icon_state			= "daynight"
			screen_loc			= "NORTHWEST to SOUTHEAST"
			mouse_opacity		= 0
			plane				= LIGHTING_PLANE
			alpha				= 200
			color				= "#febe29"

			New()
				..()
				day_night_toggle()

			proc
				// Animate day/night color and alpha transitions smoothly.
				day_night_loop()
					set waitfor = 0
					set background = 1
					while(1)
						switch(time_of_day)
							if(NIGHT)
								animate(src, alpha = 150, color = "#04062b", time = 50, loop = 0, easing = LINEAR_EASING)
							if(DAY)
								animate(src, alpha = 0, color = "#febe29", time = 50, loop = 0, easing = LINEAR_EASING)
						sleep (35 * world.tick_lag)

				// Initialize and toggle day/night state based on time_of_day var.
				day_night_toggle()
					set waitfor = 0
					set background = 1
					label
					switch(time_of_day)
						if(NIGHT)
							animate(src, alpha = 150, color = "#04062b", time = 50, loop = 0, easing = LINEAR_EASING)
						else if(DAY)
							animate(src, alpha = 0, color = "#febe29", time = 50, loop = 0, easing = LINEAR_EASING)
					sleep (50)
					goto label

area
	screen_fx
		day_night
			icon				= 'dmi/daynight.dmi'
			icon_state			= "daynight"
			//screen_loc			= "NORTHWEST to SOUTHEAST"
			mouse_opacity		= 0
			plane				= LIGHTING_PLANE
			alpha				= 200
			color				= "#febe29"

			New()
				..()

				day_night_toggle()

			proc
				day_night_loop()
					set waitfor = 0
					set background = 1
					spawn while(1)
						//label
						if (time_of_day == DAY && hour == 8 && ampm=="pm" || time_of_day == DAY && hour == 9 && ampm=="pm" || time_of_day == DAY && hour == 10 && ampm=="pm" || time_of_day == DAY && hour == 11 && ampm=="pm" || time_of_day == DAY && hour == 12 && ampm=="am" || time_of_day == DAY && hour == 1 && ampm=="am" || time_of_day == DAY && hour == 2 && ampm=="am" || time_of_day == DAY && hour == 3 && ampm=="am" || time_of_day == DAY && hour == 4 && ampm=="am" || time_of_day == DAY && hour == 5 && ampm=="am" || time_of_day == DAY && hour == 6 && ampm=="am")
							time_of_day = NIGHT
							//weather()//calls too much placed here
							//break
							//goto label
						if (time_of_day == NIGHT && hour == 7 && ampm=="am" || time_of_day == NIGHT && hour == 8 && ampm=="am" || time_of_day == NIGHT && hour == 9 && ampm=="am" || time_of_day == NIGHT && hour == 10 && ampm=="am" || time_of_day == NIGHT && hour == 11 && ampm=="am" || time_of_day == NIGHT && hour == 12 && ampm=="pm" || time_of_day == NIGHT && hour == 1 && ampm=="pm" || time_of_day == NIGHT && hour == 2 && ampm=="pm" || time_of_day == NIGHT && hour == 3 && ampm=="pm" || time_of_day == NIGHT && hour == 4 && ampm=="pm" || time_of_day == NIGHT && hour == 5 && ampm=="pm" || time_of_day == NIGHT && hour == 6 && ampm=="pm" || time_of_day == NIGHT && hour == 7 && ampm=="pm")
							//weather()
							time_of_day = DAY
							//break
							//goto label
						switch(time_of_day)
							if(NIGHT)
								animate(src, alpha = 150, color = "#04062b", time = 50, loop = 0, easing = LINEAR_EASING)
								//break
								//goto label
								//sleep 100
								//if(auto_daynight) time_of_day = DAY

							if(DAY)
								animate(src, alpha = 0, color = "#febe29", time = 50, loop = 0, easing = LINEAR_EASING)
								//break
								//goto label
								//sleep 100
								//if(auto_daynight) time_of_day = NIGHT

						sleep(75 * world.tick_lag)//needs some kind of balance that can properly set the lighting for the time but doesn't lag after a day like 35 * world ticklag
						//goto label

				day_night_toggle()//works
					set waitfor = 0
					set background = 1
					//while(1)
					//if (time_of_day == DAY && hour == 8 && ampm=="pm" || time_of_day == DAY && hour == 9 && ampm=="pm" || time_of_day == DAY && hour == 10 && ampm=="pm" || time_of_day == DAY && hour == 11 && ampm=="pm" || time_of_day == DAY && hour == 12 && ampm=="am" || time_of_day == DAY && hour == 1 && ampm=="am" || time_of_day == DAY && hour == 2 && ampm=="am" || time_of_day == DAY && hour == 3 && ampm=="am" || time_of_day == DAY && hour == 4 && ampm=="am" || time_of_day == DAY && hour == 5 && ampm=="am" || time_of_day == DAY && hour == 6 && ampm=="am")
						//time_of_day = NIGHT

					//if (time_of_day == NIGHT && hour == 7 && ampm=="am" || time_of_day == NIGHT && hour == 8 && ampm=="am" || time_of_day == NIGHT && hour == 9 && ampm=="am" || time_of_day == NIGHT && hour == 10 && ampm=="am" || time_of_day == NIGHT && hour == 11 && ampm=="am" || time_of_day == NIGHT && hour == 12 && ampm=="pm" || time_of_day == NIGHT && hour == 1 && ampm=="pm" || time_of_day == NIGHT && hour == 2 && ampm=="pm" || time_of_day == NIGHT && hour == 3 && ampm=="pm" || time_of_day == NIGHT && hour == 4 && ampm=="pm" || time_of_day == NIGHT && hour == 5 && ampm=="pm" || time_of_day == NIGHT && hour == 6 && ampm=="pm" || time_of_day == NIGHT && hour == 7 && ampm=="pm")
						//time_of_day = DAY

					label
					//if (hour == 8 && ampm=="pm" || hour == 9 && ampm=="pm" || hour == 10 && ampm=="pm" || hour == 11 && ampm=="pm" || hour == 12 && ampm=="am" || hour == 1 && ampm=="am" || hour == 2 && ampm=="am" || hour == 3 && ampm=="am" || hour == 4 && ampm=="am" || hour == 5 && ampm=="am" || hour == 6 && ampm=="am")
						//time_of_day = NIGHT
					switch(time_of_day)
						if(NIGHT)
					//if (time_of_day==NIGHT)
							animate(src, alpha = 150, color = "#04062b", time = 50, loop = 0, easing = LINEAR_EASING)
						//return

					//if (hour == 7 && ampm=="am" || hour == 8 && ampm=="am" || hour == 9 && ampm=="am" || hour == 10 && ampm=="am" || hour == 11 && ampm=="am" || hour == 12 && ampm=="pm" || hour == 1 && ampm=="pm" || hour == 2 && ampm=="pm" || hour == 3 && ampm=="pm" || hour == 4 && ampm=="pm" || hour == 5 && ampm=="pm" || hour == 6 && ampm=="pm" || hour == 7 && ampm=="pm")
						//time_of_day = DAY
						else if(DAY)
					//else if (time_of_day==DAY)
							animate(src, alpha = 0, color = "#febe29", time = 50, loop = 0, easing = LINEAR_EASING)
						//return
					sleep (50)
					goto label
					//switch(time_of_day)

					//if(NIGHT)
						//animate(src, alpha = 150, color = "#04062b", time = 50, loop = 0, easing = LINEAR_EASING)
						//sleep 100
						//if(auto_daynight) time_of_day = DAY

					//if(DAY)
						//animate(src, alpha = 0, color = "#febe29", time = 50, loop = 0, easing = LINEAR_EASING)
						//sleep 100
						//if(auto_daynight) time_of_day = NIGHT

