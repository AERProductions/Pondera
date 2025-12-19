/* This demo is for making things slower and faster.*/
// To test it, just Build/Compile and than Build/Run.

mob/var/delay=0
mob/var/tmp/move=1

//Simple, short, and sweet.
mob/Move()
	if(src.move)
		src.move=0
		..()
		sleep(src.delay)
		src.move=1

//Testing stuff.
mob/verb/change_delay()
	src.delay=input("The bigger the number, the slower you will walk.","Delay",src.delay)as num

turf/grass
	icon='icons.dmi'
	icon_state="grass"
mob
	icon='icons.dmi'
	icon_state="mob"
	New() src.loc=locate(1,1,1)