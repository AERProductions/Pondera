mob
	icon_state = "player"


	verb/say(T as text)
		if(umsl_ObtainLock("mouth", 30)) world << "[src]: [T]"
		else src << "Spam protection is enabled. You must wait at least 3 seconds between utterances."


	verb/cast()
		var/obj/groat_cluster/G = locate() in src
		if(G)
			if(umsl_ObtainMultiLock(list("left hand", "right hand"), 50))
				usr << "You cast a spell! Hooray for you!"
				del G
			else
				usr << "You must have two free hands to cast a spell."
		else usr << "How can you cast a spell without groat clusters?!"


	verb/pick_nose()
		var/result = umsl_ObtainAnyOneLock(list("right hand", "left hand"), 30)
		if(result)
			usr << "You pick your nose with your [result], but beware -- there are no winners up there, friend!"
		else
			usr << "You need a free hand to do that."


	verb/scratch_armpit()
		var/result =  umsl_ObtainAnyOneLock(list("right hand", "left hand"), 50)
		if(result)
			usr << "Smart move! Now your [result] smells like an armpit."
		else
			usr << "You need a free hand to do that."


	verb/hop()
		var/result = umsl_ObtainAnyOneLock(list("right leg", "left leg"), 25)
		if(result)
			usr << "Yee-haw! You're a hoppin' fool. Look at that [result] go!"
		else
			usr << "You need a free leg to do that."


client
	Move()
		if(!mob.umsl_ObtainMultiLock(list("right leg", "left leg"), 4)) return null
		else return ..()


atom
	icon = 'demo.dmi'


turf
	sand
		icon_state = "sand"


	Entered(mob/M)
		//Player automatically picks up any groat clusters when entering a turf.
		if(istype(M))
			for(var/obj/groat_cluster/G in src) G.Move(M)


world
	turf = /turf/sand


obj
	groat_cluster
		icon_state = "groat cluster"



