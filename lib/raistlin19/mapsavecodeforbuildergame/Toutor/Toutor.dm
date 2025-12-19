/*This tutoriol will teach you how to load and save objects. It's cheap,
easy to use, and gets de job done.*/


obj
	var                   //These vars define the terms so they
		saved_x           //are recognized.
		saved_y
		saved_z

proc
	SaveObjects()                            //This is the Save proc.
		var/savefile/F = new ("objects.sav") //creates the save file
		var/list/L = new
		for(var/obj/O in world)
			O.saved_x = O.x //these tell the game to save the objects
			O.saved_y = O.y //location.
			O.saved_z = O.z
			L += O
		F[""] << L

proc/LoadObjects()                         //Its time to load the objs!
	var/savefile/F = new ("objects.sav")
	var/list/L = new
	F[""] >> L
	if(!L) return
	for(var/obj/O in world) if(O.loc) del(O)
	for(var/obj/O in L)
		O.loc = locate(O.saved_x,O.saved_y,O.saved_z) //loads the obj
                                                      //location

mob/verb/Save() //the save verb
	SaveObjects()


mob/verb/Load() //the load verb
	LoadObjects()


var/global/host
var/global/ishost
mob/var/host


mob/Login() //Put this and the logout in YOUR Login and Logout somwhere
	if(host==0)            //If there isn't a host ...
		host="[usr.name]"
		ishost=1
		usr.host=1
		usr.verbs += /mob/verb/Save //give em the verbs to save and load inbetween login and logout
		usr.verbs -= /mob/verb/Load
	else
		usr.verbs -= /mob/verb/Save
		usr.verbs -= /mob/verb/Load
		return

mob/Logout()
	if(usr.host==1)   //If the host logs out...
		SaveObjects() //SAVE!!!
	else
		return