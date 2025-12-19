atom
	icon='demo.dmi'


turf
	outside
		Entered(mob/M)
			if(ismob(M))
				if(!src.soundtags.Find("birds"))
					new/soundtag(M,"CAW.wav","birds",1,30,1,0,1,4,0,1,0,TRUE)
				del M.soundtags["piano"]


		grass
			icon_state="grass"
		tree
			icon_state="tree"
			density=1
		bush
			icon_state="bush"
			density=1
	room
		Entered(mob/M)
			if(ismob(M))
				if(!src.soundtags.Find("piano"))
					new/soundtag(M,"piano.wav","piano",1,50,1,0,1,5,0,0,0,TRUE)
				del M.soundtags["birds"]
		wall
			icon_state="wall"
			opacity=1
			density=1
		floor
			icon_state="floor"

obj/room
	piano
		icon_state="piano"
		density=1
		verb/Play() //I suppose you'd need 2 people, or to log in on 2 different computers to test this
			set src in oview(1)
			if(usr.soundtags.Find("piano"))
				usr.channel_tracker.Play(usr.soundtags["piano"])

	bird
		layer=MOB_LAYER+1
		icon_state="bird"
		density=0

		proc/soundloop()
			sleep(4)
			while(src) //normally a loop like this is a terrible idea, but for a demo...
				for(var/mob/X in range(4,src))
					if(!ismob(X)) continue
					if(X.soundtags.Find("birds")) //not the best example
						X.channel_tracker.Play(X.soundtags["birds"]) //src could keep track of everyone it sends sounds to by passing a list in the second argument here, but I'm keeping it simple
				sleep(20)

		New()
			..()
			spawn() soundloop()
			walk_rand(src,7)

world/mob = /mob/PC


mob/var/soundtag/birds
mob/PC
	icon_state="player"
	Login()
		world<<"Notice that when the birds passes over the building, the player still doesn't hear them. If you have two accounts, the second account could play the piano, and the first could walk outside and not hear the piano."
		..()


