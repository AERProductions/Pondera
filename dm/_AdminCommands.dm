
var
	list/admins = list("aerproductions")

mob
	Login()
		..()
		if(admins.Find(ckey))
			verbs += typesof(/mob/admin/verb)

mob/admin/verb
	Create(O as anything in typesof(/obj, /mob))
		set category = "Commands"
		set desc = "Create any object or mob type."
		if(O)
			new O (loc)