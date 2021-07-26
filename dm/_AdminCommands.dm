
//var
	//list/admins = world.host

mob
	Login()
		..()
		//if(admins.Find(ckey))
		if(ckeyEx("[usr.key]") == world.host&&MP==1)
			verbs += typesof(/mob/players/Special1/verb)

mob/players/Special1/verb
	Create(O as anything in typesof(/obj, /mob))
		set category = "Commands"
		set desc = "Create any object or mob type."
		if(O)
			new O (usr.loc)
