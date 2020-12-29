/*Thank you and praises to Lord Yeshua for everything. May you continue to be our Saviour and provide your undying forgiveness and love*/
#define macro/W return "NORTH"
#define macro/S return "SOUTH"
#define macro/A return "WEST"
#define macro/D return "EAST"
#include "Sound.dm"
mob
	timekeeper
		//New()
			//light = new/light/day_night(src)
			//..()
client
	//base_num_characters_allowed = 2
	perspective=EYE_PERSPECTIVE
	control_freak = 0
//	fps=50
//proc/igd()
//	world.status("Date: [day] / [month] / [year] O·C·")
var
	t = /area/outside/proc/time
	weather = /area/outside/proc/weather
	cheats = 0 //The thing that you don't want to be changeable.
	securityoffset1 = 4132370
/*First line of defense against the hacking program.  Uses a
second notation of vars to check with cheats.  Do not use default as the
offset amount.  Make your own unique one, or the cheaters might be
able to cheat if they saw this lib.*/
	securityoffset2 = 0
/*Second line of defense against the hacking program.  Will be made
a random number later on in the lib.*/
	securityoffset3 = 0
/*Third line of defense against the hacking program.  This var is a
DYNAMCIC var, so later on, I will show it changing constantly to
avoid being matched and changed.*/
	offsetamount1 = 4132370
/*Memorize the first line of defense's offset amount.  Make sure it
matches securityoffset1!*/
	offsetamount2 = 0
//Memorize the second line of defense's offset amount.
	offsetamount3 = 0
	//DN = /area/outside/proc/DN
	//L = lighting.init()

	//igd = /proc/igd//"Date: [day] / [month] / [year] O·C·"

world
	name = "Pondera"
	hub = "AERProductions.Pondera" //Hub name
	visibility = 1
	//var/discord = new(Discord.Discord(782644477218390067, (UInt64)&&Discord.CreateFlags.Default));
	//hub = "AERProductions.SimplePVEDemo"
	//hub = "AERProductions.SimpleDABDemo1"
	//hub = "AERProductions.SimpleDABDemo2"
	//hub = "AERProductions.SimplePVPDemo"
	//hub = "AERProductions.SimpleStoryDemo"
	hub_password = "2R5Joy3ty5GRACES4mi" //Hub pass ~ Change Frequently
	//status="Date: [day] / [month] / [year] O·C·"
	loop_checks=0
	mob = /mob/mob
	//map_format = TILED_ICON_MAP
	icon_size = 64
	//maxx = 30
	//maxy = 30
	view=13
//	fps=20
	fps=40
	turf=/turf/temperate
	area = /area/outside
	New()
		..()

		securityoffset2 = rand(1,1000000)
	/*Set the second line of defense as a random var between 1 and 100.
	Will check later with cheats.  Set your own range of random vars!*/
		offsetamount2 = securityoffset2
	//Memorize the second line of defense's offset amount.
		securityoffset3 = rand(1,100000)
	// Set the third line of defense as a random obscene number.
		offsetamount3 = securityoffset3
	//Memorize the third line of defense's offset amount.
		changethirdlinevar()
	//Run a new dymanic var for the third line of defense.
		//swapmaps_mode=SWAPMAPS_SAV
		//..()

		//lighting.z_level
		//L(world)
		//new /light/day_night(/mob/players, 4)
		//new /light/day_night(usr, 4)
		//new/light(world)//del the 2 for story mode
		//new /light/day_night(world, 700)
		//call(L)(world)
		//..()
		//world.log = file("timesave.txt")
		//MAIN
		//call(/world/proc/MtrShwr)(world)
		//LordyeshuaBlessKozwithafleshieheart()
		//for(time)
			//hour = time2text(world.timeofday,"hh")
			//if(time2text(world.timeofday,"hh") == 20)
			//	ampm = "pm"
			//else
			//	if(time2text(world.timeofday,"hh") == 0)
			//		ampm = "am"
			//minute1=time2text(world.timeofday/10%3600/10)
			//minute2=time2text(world.timeofday/10%3600/10)
		//call(/mob/players/proc/listensound)()

		//call(/soundmob/proc/broadcast)(world)
		//new/mob/snd/sfx/apof/forestbirds(locate(495,645,2))//soundmob(src, 100, 'snd/cycadas.ogg', TRUE, 0, 40, TRUE)
		call(/proc/Debug_Edges)(world)

		lighting = new

		// BEGIN Map Save System Startup
		StartMapSave()
		// END Map Save System Startup

		// BEGIN Map Generation
		if(map_loaded == FALSE)
			GenerateMap(lakes = 25, hills = 15)
		// END Map Generation

		lighting.startloop()

		//TimeStuff
		TimeLoad()

		world.status = "Date: [day] / [month] / [year] O·C·"

		lighting.init(2)
		call(/proc/Debug_Lamps)(world)
		call(t)(world)//time()
		//call(/plant/ueiktree/proc/Grow)(world)
//		call(/obj/Plants/Bush/Raspberrybush/proc/Grow)(world)
//		call(/obj/Plants/Bush/Blueberrybush/proc/Grow)(world)
		call(weather)(world)
		//call(/proc/GenerateTurfs)(world)
		GrowBushes()
		GrowTrees()
		SetSeason()
		//OreLoad()
		MtrShwr()


	Del()
		TimeSave()
		..()

	proc/changethirdlinevar()
		spawn(100) //After 10 seconds, run this.
			if(cheats + offsetamount1 == securityoffset1) //Check it.
				if(cheats + offsetamount2 == securityoffset2)
					if(cheats + offsetamount2 == securityoffset2)
					else
						world << "[usr.ckey] has been found Hacking, Refrain from hacking or be Perma IP Banned and reported to Byond Administrators."
				else
					world << "[usr.ckey] has been found Hacking, CEASE AND DESIST from hacking or be PERMA IP Banned and reported to Byond Administrators."
			else
				world << "[usr.ckey] has been found Hacking, Incoming BanHammer!"
			securityoffset3 = rand(1,100000) + cheats
	//Set the third line of defense as a random obscene number.
			offsetamount3 = securityoffset3
	//Memorize the third line of defense's offset amount.
			changethirdlinevar() //Do it again.
	proc
		WorldStatus()
			var data = "[world.name]<br>"
			data = "Date: [day] / [month] / [year] O·C·"
			world.status="[data]"
			return
	proc
		L()
			var/my = world.maxy
			var/mx = world.maxx
			//var turf/L
			//L = locate(rand(1,mx),rand(1,my),2)
			//new /light/day_night(L)//kind of works? but leaves darkness on the map, guess it could be fog of war...
			var/mob/timekeeper/L
			L = locate(mx,my,2)
			new /light/day_night(L)

			//return
			//..()
	proc
		SetSeason()
			if(month=="Shevat")
				season = "Spring"
				for(var/obj/Flowers/J)
					J.overlays -= J.overlays
				for(var/turf/temperate/A)
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
					UTH.overlays -= UTH.overlays
				//spring debris
				for(var/turf/temperate/G)
					if(prob(1))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="rck")
				for(var/turf/temperate/G)
					if(prob(5))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="sprg2")
				for(var/turf/temperate/G)
					if(prob(5))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="sprg3")
				for(var/turf/temperate/G)
					if(prob(0.1))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="rck2")
				for(var/turf/temperate/G)
					if(prob(0.1))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="stcks")
				for(var/turf/temperate/G)
					if(prob(0.1))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="rck2")
				for(var/turf/temperate/G)
					if(prob(0.1))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="duskele")
			if(month=="Adar")
				season = "Spring"
			if(month=="Nissan")
				season = "Spring"
			if(month=="Iyar")
				season = "Spring"
			if(month=="Sivan")
				season = "Summer"
			if(month=="Tammuz")
				season = "Summer"
			if(month=="Av")
				season = "Summer"
			if(month=="Elul")
				season = "Autumn"
				for(var/obj/plant/UeikTreeA/UTA)
					UTA.overlays += icon('64/tree.dmi',icon_state="UTAaut")//these lines add autumn sprites.
				for(var/obj/plant/UeikTreeH/UTH)
					UTH.overlays += icon('64/tree.dmi',icon_state="UTHaut")//it should probably be handled differently
				for(var/obj/Flowers/J)
					J.overlays += icon('64/plants.dmi',icon_state="tg1")//perhaps initilize them at runtime based on season/month
				for(var/turf/temperate/A)
					//if(prob(15))
					A.overlays += icon('dmi/64/gen.dmi',icon_state="grassaut")//otherwise, if the server goes down after these dates
				for(var/turf/temperate/A)
					if(prob(15))
						A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass")//the overlays won't be set properly
				for(var/turf/temperate/A)
					if(prob(15))
						A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass2")
			if(season=="Autumn"&&month == "Tishrei")
				for(var/turf/temperate/A)
					if(prob(15))
						A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass")
				for(var/turf/temperate/A)
					if(prob(15))
						A.overlays += icon('dmi/64/gen.dmi',icon_state="autgrass2")
			if(season=="Autumn"&&month=="Cheshvan")
				for(var/obj/Flowers/J)
					J.overlays += icon('64/plants.dmi',icon_state="tg2")
			if(season=="Autumn"&&month=="Kislev")
				for(var/obj/Flowers/J)
					J.overlays += icon('64/plants.dmi',icon_state="tg3")
			if(month == "Tevet")//30
				season = "Winter"
				//year = [year]+=1
				//month = "Tevet"
				//day = 1
				//season = "Winter"
				//for(var/turf/Water/W)
					//W.overlays += icon('dmi/64/gen.dmi',icon_state="waterwint")
				for(var/turf/ClayDeposit/CD)
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
				for(var/turf/temperate/A)
					A.overlays += icon('64/snow.dmi',icon_state="snow")
				for(var/obj/Flowers/J)
					J.overlays += icon('64/plants.dmi',icon_state="tg4")
				for(var/turf/temperate/G)
					if(prob(0.1))
						G.overlays += icon('dmi/64/gen.dmi',icon_state="stcks")

	proc
		MtrShwr()
			set waitfor = 0
			var/my = world.maxy
			var/mx = world.maxx
			var turf/snow/sn
			sn = locate(rand(1,mx),rand(1,my),2)
			var turf/snow/sn2
			sn2 = locate(rand(1,mx),rand(1,my),2)
			var turf/sand1/sa
			sa = locate(rand(1,mx),rand(1,my),2)
			var turf/sand1/sa2
			sa2 = locate(rand(1,mx),rand(1,my),2)
			var turf/clast/pc
			pc = locate(rand(1,mx),rand(1,my),2)
			var turf/clast/pc2
			pc2 = locate(rand(1,mx),rand(1,my),2)
			var turf/drkgrss/dgr
			dgr = locate(rand(1,mx),rand(1,my),2)
			var turf/drkgrss/dgr2
			dgr2 = locate(rand(1,mx),rand(1,my),2)
			var turf/lava/La
			La = locate(rand(1,mx),rand(1,my),2)
			var turf/Grass/gr
			gr = locate(rand(1,mx),rand(1,my),2)
			var turf/Grass/gr2
			gr2 = locate(rand(1,mx),rand(1,my),2)
			var turf/Grass/gr3
			gr3 = locate(rand(1,mx),rand(1,my),2)
			var turf/Grass/gr4
			gr4 = locate(rand(1,mx),rand(1,my),2)
			var turf/Grass/gr5
			gr5 = locate(rand(1,mx),rand(1,my),2)
			var turf/Grass/gr6
			gr6 = locate(rand(1,mx),rand(1,my),2)
			var turf/Water/Wtr
			Wtr = locate(rand(1,mx),rand(1,my),2)
			var turf/Water/Wtr2
			Wtr2 = locate(rand(1,mx),rand(1,my),2)
			sleep(35)
			world << "<font color=#bba231>A <font color=#bb4631>Meteor shower</font> occurs...</font>"
			//if(sn)
				//world << "<font color=#bba231>A <font color=#bb4631>Meteor shower</font> occurs...</font>"
				//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/icestorm(sn)//snow
			//for(var/turf/snow/sn in world)
				//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/shardburst(sn2)//snow
			//for(var/turf/sand1/sa in world)
				//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/bludgeon(sa)//desert
			//for(var/turf/sand1/sa in world)
				//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/quietus(sa2)//desert
				//for(var/turf/clast/pc in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/heat(pc)//pyroclast
				//for(var/turf/clast/pc in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/flame(pc2)//pyroclast
				//for(var/turf/drkgrss/dgr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/acid(dgr)//jungle
				//for(var/turf/drkgrss/dgr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/panacea(dgr2)//jungle
				//for(var/turf/Grass/gr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/telekinesis(gr)//Grass
				//for(var/turf/Grass/gr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/rephase(gr2)//Grass
				//for(var/turf/Grass/gr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/vitae(gr3)//Grass
				//for(var/turf/Grass/gr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/vitaeII(gr4)//Grass
				//for(var/turf/Grass/gr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/cosmos(gr5)//Grass
				//for(var/turf/Water/Wtr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/watershock(Wtr)//Water
				//for(var/turf/Grass/gr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/ancscrlls/cascadelightning(gr6)//Grass
				//for(var/turf/Water/Wtr in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/weapons/sumasamune(Wtr2)//Water
				//for(var/turf/lava/La in world)
					//if(R.chance(0.01))        // 80%
			new/obj/items/weapons/sumuramasa(La)//Water
	/*proc
		Spellbookspawner() // i used this verb for debugging alot, mostly making books and items from nothing
			var/random/R = new()
			var/rloc = locate(pick(1,700),pick(700,1),pick(2,2))
			for(var/obj/Flowers in world)
				if(R.chance(0.001))
					new/obj/items/ancscrlls(rloc)
					world << "...A bright flash above..."


				proc
		LordyeshuaBlessKozwithafleshieheart()
			var/my = world.maxy
			var/mx = world.maxx
			var turf/t, o
			var/obj/items/ancscrlls = 15
			for(var/i=1 to ancscrlls)
				RETRY
				t = locate(rand(1,mx),rand(1,my),2)
				if(t && t.density)
					for(o in t.contents)
						if(o:density)
							goto RETRY
					new/obj/items/ancscrlls(t)
					world << "<font color=#bba231>A <font color=#bb4631>Meteor shower</font> occurs...</font>"
				*/

//mob/opaque = 1
mob/var/logincheck = 1
var/AllowLogin = 1
//var/list/Server_Testers = list("T.Key")//to add on to tester list simply add this=.   ,"T.Key","T.Key","T.Key")
//var/list/ByondMember = IsByondMember()
mob/var
	list/HostGM = list("AERProductions") //"UmbrousSoul","Kirikae","AERProductions","Seikitai"

	//list/PermaBanned = list("B.key")//"Xorbah","Southv2") //One time
//var/list/objs = list ()
/*var
	username = "pondlog" // Edit this to fit the username on your Database
	my_database = "pondreg" // Edit this to fit the name of your database on the server
	my_server = "" // Edit this to fit the address of the server, unless it is running on your machine, where it'd be localhost
	server_port = "3306" // The default ports for MySQL is 3306, so it's best to leave this unless your using a different port
	DBI = "dbi:mysql:[my_database]:[my_server]:[server_port]" // This can be left as it is
	password = GeneratePassword()
proc
	GeneratePassword() // This makes the password to the server a bit more secure, I recommend using this way
		return "1" + "K"*/
#include "Sound.dm"
mob/mob
	//base_save_allowed = 0	// If player quits before choosing, don't want to save this mob.
	var
		Form/NewCharacter/char_form = new()
		error_text = ""// For error text if they fill out the form wrong.
	/*Login()
		//call(/soundmob/proc/broadcast)(src)
		//usr << sound('snd/mus2.ogg', wait= 0, repeat= 0)
		//lighting.icon = 'dmi/64/dlighting64.dmi'
		//lighting.init()
		//winset(src, "macro","parent=default; is-visible = yes; focus = yes")
		//lighting.init()
		winset(src, "loadscrn","parent=loadscrn; is-visible = true; focus = true")
		sleep(5)
		winset(src, "loadscrn","parent=loadscrn; is-visible = false; focus = false")
		//winset(usr, "default","parent=default; is-visible = true; focus = true")
		//winset(usr, "loadscrn","parent=loadscrn; is-visible = false; focus = false")
		//world << "<center><b><font color=#00bfff>Welcome [src.key].<br>|Game is in Early <|Alpha|> Testing|<br> Enjoy.<br>"
		world << "<center><b><font color=#00bfff>[src.key] has entered this realm!<p>"
		sleep(3)
		//src << "<font color=gold><center>Information: <font color=gold>Arrow or wasd keys to walk, click/double-click to sprint, use, or attack. <br> Use the stance positions, V is sprint mode, C is Strafe mode and X is Hold Position. <br>Ctrl+E provides a quick-unequip menu and Ctrl+G provides a quick-get menu and ctrl+mouse wheel is zoom."
		src << "<center><b><font color=#00bfff>[src.key], Welcome to Pondera Sandbox mode! <p> Find Bugs? Report on the Hub, Pager or e-mail (AERSupport@live.com).<br>"// - (http://pondera.aerproductions.com | AERSupport@live.com)."
		src.char_form.DisplayForm()*/
		// First we create new images contained by src for /image/master_plane and /image/darkness.
		/*master_plane = new(loc=src)
		darkness = new/image/darkness(loc=src)
		// Then we output them to the player so that they're added to images and displayed.
		src << master_plane
		src << darkness
		// Now we create a new mlight at the player's location.
		mlight = new(src.loc)
		// And set the alpha value of it so that it's not full-bright.
		mlight.alpha = 150
		// Then set the darkness alpha somewhere low so it gets dark outside.
		darkness.alpha = 20

		// And make the player's mlight a little bigger so they're not totally blind.
		var/matrix/m = new()
		m.Scale(160)
		mlight.transform = m*/
		//if(HostGM.Find(src.key))
			//call(/proc/Debug_Lamps)(usr)				//world.log << "<center><b><font color=#00bfff>Welcome [src.key].<br>|Game Is In Open Early <|Alpha|> Testing|<br> Enjoy.<br>"
			//call(/proc/Debug_Edges)(usr)
	var/tmp
		list/_listening_soundmobs = null
		list/_channels_taken = null

	New()
		..()

		//spawn() if(client && _autotune_soundmobs) for(var/soundmob/soundmob in _autotune_soundmobs) listenSoundmob(soundmob)

	//Del()
		//if(!_listening_soundmobs) for(var/soundmob/soundmob in _listening_soundmobs) unlistenSoundmob(soundmob)

		//..()




	proc
		_unlockChannel(channel)
			if(channel in _channels_taken)
				_channels_taken -= channel
				if(!length(_channels_taken)) _channels_taken = null

		_lockChannel(channel)
			if(!(channel in _channels_taken))
				if(!_channels_taken) _channels_taken = list()
				_channels_taken += channel

		_updateListeningSoundmobs()
			if(_listening_soundmobs)
				for(var/soundmob/soundmob in _listening_soundmobs)
					if(soundmob.attached)
						soundmob.updateListener(src)

		_getAvailableChannel()
			for(var/channel = _channel_reserve_start, channel <= _channel_reserve_end, channel ++)
				if(!(channel in _channels_taken)) return channel

			CRASH("You've managed to use a ridiculous number of channels. You're doing it wrong.")

		listenSoundmob(soundmob/soundmob)
			if(!(soundmob in _listening_soundmobs))
				if(!_listening_soundmobs) _listening_soundmobs = list()
				_listening_soundmobs += soundmob
				if(soundmob.attached)
					soundmob.updateListener(src)

		unlistenSoundmob(soundmob/soundmob)
			if(soundmob in _listening_soundmobs)
				var/tmp/sound/sound = _listening_soundmobs[soundmob]
				_channels_taken -= sound.channel

				_listening_soundmobs -= soundmob
				if(!length(_listening_soundmobs)) _listening_soundmobs = null
				soundmob.unsetListener(src)
//Character Choosing form


/*
   Character creation form
   -----------------------
   This is the form object that defines the web page where they set their
   character attributes.

   You tell the form object what kind of controls to use (radio buttons, popup menu,
   text area, etc) by adding specially named variables to the object. To see the complete
   list of possible controls, in the file tree on the left go to Lib/Dantom.htmllib and
   look at the documentation.
*/
Form/NewCharacter
	/*
	   The form_window variable provides the browse() options that the form will use.
	   We want the form to show up in its own window (not the built-in browser view).
	*/
	form_window = "window=NewCharacter;titlebar=0;can_close=0;can_minimize=0;allow_transparency=true;size=400x398;focus=true;can_resize=0"

	var
		name

		/*
		   To create radio buttons for a variable, specify the radio button options
		   by creating variables named variablename_1, variablename_2, etc.
		*/
		gender
		gender_1 = "Male"
		gender_2 = "Female"
		gender_3 = "Feline"

		/*
		   To create a popup menu they can choose from, put the options in a list
		   called variablename_values.
		*/
		class //DAB Sandbox class selection
		class_1 = "Landscaper"
		class_2 = "Defender"
		class_3 = "Builder"
		class_4 = "Magus"
		class_5 = "special1"
		//class_values = list("Landscaper","Defender","Builder","Magus","Feline")

	Initialize()
		/*
		   This sets the initial values for the form each time before it is displayed.
		   The browse_rsc() calls sends an image to the player that is used
		   in the web page.
		*/

		if (!name)	 name = usr.key
		if (!gender) gender = "Male"
		if (!gender) gender = "Female"
		if (!gender) gender = "Feline"
		if (!class)	 class = "Landscaper"
		if (!class)	 class = "Defender"
		if (!class)	 class = "Builder"
		if (!class)	 class = "Magus"
		if (!class)	 class = "Feline"
		//usr << browse_rsc('demomenu.jpg', "demomenu.jpg")
		usr << browse_rsc('csmenu.jpg', "csmenu.jpg")
		usr << browse_rsc('submit.png', "submit.png")
		usr << browse_rsc('choose.png', "choose.png")
		//usr << browse_rsc('dsc.jpg', "dsc.jpg")
		//usr << browse_rsc('chcmenu.jpg', "chcmenu.jpg")

	HtmlLayout()
		/*
		   You control the appearance of the form here.

		   We have added an error_text variable to the creating character mob, so we
		   can display an error if the form wasn't filled out correctly and needs to
		   be redisplayed with a message.  The error_text variable can't be part of
		   the form object, because then the form tries to let the player edit it.

		   When you embed a variable such as [name], the html library automatically
		   puts in the HTML for the text field or radio button or whatever is needed.
		   In the case of radio buttons, you place the numbered variables where each
		   should be displayed.

		   The [submit] variable puts in the necessary submit button at that spot.
		   You can also place a [reset] button if you want.

		   There is an image here, which was sent to the player in Initialize()
		   to put it on their system so it would show up on the page.

		   This example puts everything in table to make layout control easier.
		   Some of the table rows are blank to provide extra space between options.
		   You can change the HTML in any way you like for your game.*/

		var/mob/mob/mob = usr

		var/page = {"<style type="text/css">
		 table.c8 {position:absolute; left:100px; top:317px; width:px; height:px; z-index:4}
		 table.c7 {position:absolute; left:270px; top:235px; width:px; height:px; z-index:2}
		 table.c6 {position:absolute; left:167px; top:235px; width:px; height:px; z-index:2}
		 table.c5 {position:absolute; left:270px; top:198px; width:px; height:px; z-index:2}
		 table.c4 {position:absolute; left:167px; top:198px; width:px; height:px; z-index:2}
		 table.c3 {position:absolute; left:110px; top:115px; width:px; height:px; z-index:1}
		 table.c2 {position:absolute; left:125px; top:260px; width:px; height:px; z-index:3}
		 table.c1 {position:absolute; left:0px; top:0px; width:px; height:px; z-index:0}
		 table.c0 {position:absolute; left:115px; top:60px; width:px; height:px; z-index:2}
		 body {
		  background-color: #206B24;
		  border: none;
		  font-family: verdana;
		  font-size: 13px;
		  color: #20B728;
		  overflow: hidden;
		  position: absolute;
		  input: focus;
		  max-height: 400px;
		  max-width: 398px;
		 }
		 input {
		  background-color: transparent;
		  border: none;
		  font-family: verdana;
		  font-size: 18px;
		  color: #20B728;
		 }
		 :link { color: #20B728 }
		 :visited { color: #003DCA }
		</style>
		<table id="Layer0" class="c0" cellspacing="10" cellpadding="10" border="0">
		<font color=red><b>[mob.error_text]</b></font>
		</table>
		<table id="Layer1" class="c1" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><img src="csmenu.jpg" alt="" border="0"></td>
		</tr>
		</tbody>
		</table>
		<table align="center" id="Layer2" class="c2" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><td align="right">[submit]</td></td>
		</tr>
		</tbody>
		</table>
		<table id="Layer3" class="c3" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<tr>
		<td><tr><td>[name]</td></tr></td>
		</tr>
		</tbody>
		<table id="Layer4" class="c4" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<td>[class_1]</td>
		</tbody>
		<table id="Layer4" class="c5" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<td>[class_2]</td>
		</tbody>
		<table id="Layer4" class="c6" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<td>[class_3]</td>
		</tbody>
		<table id="Layer4" class="c7" cellspacing="0" cellpadding="0" border="0">
		<tbody>
		<td>[class_4]</td>
		</tbody>
		<table id="Layer5" class="c8" cellspacing="15" cellpadding="10" border="0">
		<tbody>
		<td>[gender]</td>
		<td>[gender_1]</td>
		<td>[gender_2]</td>
		<td>[gender_3]</td>
		</tbody>
		"}
		return page

	ProcessForm()
		/*
		   This is called when the player submits the form.
		   Make sure everything is valid; if not, send them back to the
		   form with an error message.

		   If everything is okay, create their character and log them
		   into it, then blank out the web page.

		   This checks the ckey() version of the name they chose, to make
		   sure it has actual letters and isn't just punctuation.
		*/
		var/mob/mob = usr
		var/ckey_name = ckey(name)
		if (!ckey_name || ckey_name == "")
			mob/mob.error_text = "	Invalid Form	"
			PreDisplayForm()
			DisplayForm()
			return
		switch(usr.key)
			if("AERProductions")                                                                      //~~~~~~~~~~~~~admin class key
				class = "special1"
		// Everything is okay, so create the new mob based on the class they chose.
		//var/mob/mob
		//switch(gender)
			//if ("Feline")
				//class = "Feline"
		switch(class)
			if ("Landscaper")
				mob = new /mob/players/Landscaper()
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if ("Defender")
				mob = new /mob/players/Defender()
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if ("Builder")
				mob = new /mob/players/Builder()
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if ("Magus")
				mob = new /mob/players/Magus()
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if ("Feline")
				mob = new /mob/players/Feline()
			if ("special1")
				mob = new /mob/players/Special1()
		//switch(class_3)
		//	if ("Builder")		player = new /mob/players/Builder()
		//for(class_4)
		//	if ("Builder")		player = new /mob/players/Builder()
		//switch(player.key)
		//	if("UmbrousSoul")
		//		class5 = "special1"
		//switch(class)
		//	if ("special1")		player = new /mob/players/Special1()


		// Set the new mob's attributes.
		mob.name = name
		// Now switch the player client over to the new mob and delete myself since I'm no longer needed.
		if (gender=="Feline")
			class = "Feline"
			//player = new /mob/players/Feline()
			//var/obj/items/tools/Shovel/S = new(player)
			var/obj/Deed/Deed = new(mob)
			var/obj/IG/TUT = new(mob)
			var/obj/items/tools/FishingPole/FP = new(mob)
			var/obj/items/tools/Hoe/H = new(mob)
			winset(usr,"default.Build","is-visible=false")
			winset(usr,"default.Dig","is-visible=false")
			winset(usr,"default.Sow","is-visible=true")
			winset(usr,"default.Smelt","is-visible=false")
			winset(usr,"default.Smith","is-visible=false")
			winset(usr,"default.Plant","is-visible=true")
			winset(usr,"default.bar1","is-visible=true")
			winset(usr,"default.bar2","is-visible=true")
			winset(usr,"default.bar3","is-visible=true")
			winset(usr,"default.label3","is-visible=false")
			winset(usr,"default.label4","is-visible=false")
			winset(usr,"default.label5","is-visible=false")
			winset(usr,"default.Abjure","is-visible=true")//so anyone can revive
			//winset(usr,"default.label6","is-visible=true")
			winset(usr,"default.label7","is-visible=false")
			//winset(usr,"default.Heat","is-visible=true")
			//winset(usr,"default.Vitae","is-visible=false")
			//winset(usr,"default.label15","is-visible=true")
			usr << "<font color=silver>You are a Clever, Feisty Feline! Utilize your paws ([H]) to dig, create rich soil and spread seeds! Catch fish with [FP]! Equip by clicking in inventory. Tutorial in [TUT]. You've received a [Deed]!"
			usr << "<font color=#00bfff><center>Information: <font color=green>Arrow/WASD to walk, click/double-click to run, use, or attack. <br> Stance Positions:, V is Sprint mode, C is Strafe mode, X is Hold Position. <br>Ctrl+E provides a quick-unequip and Ctrl+G provides a quick-get, ctrl+mouse wheel is zoom+/-."

		if (class=="Landscaper")
			var/obj/Deed/Deed = new(mob)
			var/obj/IG/TUT = new(mob)
			var/obj/items/tools/Jar/J = new(mob)
			var/obj/items/tools/CarvingKnife/C = new(mob)
			var/obj/items/tools/Flint/FL = new(mob)
			var/obj/items/tools/Shovel/S = new(mob)
			//var/obj/items/tools/Pyrite/PY = new(player)
			//var/obj/items/tools/ObsidianKnife/OK = new(player)
			var/obj/items/torches/Handtorch/HT = new(mob)
			var/obj/items/Tar/TR = new(mob)
			winset(usr,"default.Build","is-visible=false")
			winset(usr,"default.Dig","is-visible=true")
			winset(usr,"default.Sow","is-visible=true")
			winset(usr,"default.Smelt","is-visible=false")
			winset(usr,"default.Smith","is-visible=false")
			winset(usr,"default.Plant","is-visible=true")
			winset(usr,"default.bar1","is-visible=true")
			winset(usr,"default.bar2","is-visible=true")
			winset(usr,"default.bar3","is-visible=true")
			winset(usr,"default.label3","is-visible=false")
			winset(usr,"default.label4","is-visible=false")
			winset(usr,"default.label5","is-visible=false")
			winset(usr,"default.Abjure","is-visible=true")//so anyone can revive
			//winset(usr,"default.label6","is-visible=true")
			winset(usr,"default.label7","is-visible=false")
			//winset(usr,"default.Heat","is-visible=true")
			//winset(usr,"default.Vitae","is-visible=false")
			//winset(usr,"default.label15","is-visible=true")
			usr << "<font color=silver>You've chosen Landscaper, terraform the wilderness around you with your trusty [S]! You have received [Deed], [TUT], [J], [C], [FL], [HT] and [TR]. Equip by clicking in Inventory. <p>Fill and light your hand torch if it is dark! (Equip Knife and Flint to light)"
			usr << "<font color=#00bfff><center>Information: <font color=green>Arrow/WASD to walk, click/double-click to run, use, or attack. <br> Stance Positions:, V is Sprint mode, C is Strafe mode, X is Hold Position. <br>Ctrl+E provides a quick-unequip and Ctrl+G provides a quick-get, ctrl+mouse wheel is zoom+/-."

		if (class=="Defender")
			var/obj/Deed/Deed = new(mob)
			var/obj/IG/TUT = new(mob)
			var/obj/items/tools/Jar/J = new(mob)
			var/obj/items/tools/CarvingKnife/C = new(mob)
			var/obj/items/tools/Flint/FL = new(mob)
			var/obj/items/tools/LongSword/L = new(mob)
			var/obj/items/tools/FishingPole/FP = new(mob)
			var/obj/items/tools/PickAxe/PX = new(mob)
			var/obj/items/tools/Gloves/GL = new(mob)
			var/obj/items/Ore/iron/IO = new(mob)
			var/obj/items/tools/Hammer/H = new(mob)
			//var/obj/items/tools/Pyrite/PY = new(player)
			//var/obj/items/tools/ObsidianKnife/OK = new(player)
			var/obj/items/torches/Handtorch/HT = new(mob)
			var/obj/items/Tar/TR = new(mob)
			winset(usr,"default.Build","is-visible=false")
			winset(usr,"default.Dig","is-visible=false")
			winset(usr,"default.Sow","is-visible=false")
			winset(usr,"default.Smelt","is-visible=true")
			winset(usr,"default.Smith","is-visible=true")
			winset(usr,"default.Plant","is-visible=false")
			winset(usr,"default.bar1","is-visible=true")
			winset(usr,"default.bar2","is-visible=true")
			winset(usr,"default.bar3","is-visible=true")
			winset(usr,"default.label3","is-visible=false")
			winset(usr,"default.label4","is-visible=false")
			winset(usr,"default.label5","is-visible=false")
			winset(usr,"default.Abjure","is-visible=true")//so anyone can revive
			//winset(usr,"default.label6","is-visible=true")
			winset(usr,"default.label7","is-visible=false")
			//winset(usr,"default.Heat","is-visible=true")
			//winset(usr,"default.Vitae","is-visible=false")
			//winset(usr,"default.label15","is-visible=true")
			usr << "<font color=silver>You are a Defender, Fight to protect! Mine with your pickaxe and your gloves with fire or forge to smelt ore, hammer and anvil to smith. You have received [Deed], [TUT], [IO], [GL], [H], [L], [FP], [PX], [J], [C], [FL], [HT] and [TR]. Equip by clicking in Inventory. <p>Fill and light your hand torch if it is dark! (Equip Knife and Flint to light)"
			usr << "<font color=#00bfff><center>Information: <font color=green>Arrow/WASD to walk, click/double-click to run, use, or attack. <br> Stance Positions:, V is Sprint mode, C is Strafe mode, X is Hold Position. <br>Ctrl+E provides a quick-unequip and Ctrl+G provides a quick-get, ctrl+mouse wheel is zoom+/-."

		if (class=="Builder")
			var/obj/Deed/Deed = new(mob)
			var/obj/IG/TUT = new(mob)
			var/obj/items/tools/Jar/J = new(mob)
			var/obj/items/tools/CarvingKnife/C = new(mob)
			var/obj/items/tools/Flint/FL = new(mob)
			var/obj/items/tools/Hammer/H = new(mob)
			//var/obj/items/tools/Pyrite/PY = new(player)
			//var/obj/items/tools/ObsidianKnife/OK = new(player)
			var/obj/items/torches/Handtorch/HT = new(mob)
			var/obj/items/Tar/TR = new(mob)
			var/obj/items/Log/UeikLog/UL = new(mob, 99)
			var/obj/items/Ore/stone/ST = new(mob, 99)
			var/obj/items/Sand/SA = new(mob, 99)
			var/obj/items/Crafting/Created/Clay/CL = new(mob, 99)
			var/obj/items/Crafting/Created/Pole/PL = new(mob, 99)
			var/obj/items/Mortar/MR = new(mob, 99)
			winset(usr,"default.Build","is-visible=true")
			winset(usr,"default.Dig","is-visible=false")
			winset(usr,"default.Sow","is-visible=false")
			winset(usr,"default.Smelt","is-visible=true")
			winset(usr,"default.Smith","is-visible=true")
			winset(usr,"default.Plant","is-visible=false")
			winset(usr,"default.bar1","is-visible=true")
			winset(usr,"default.bar2","is-visible=true")
			winset(usr,"default.bar3","is-visible=true")
			winset(usr,"default.label3","is-visible=false")
			winset(usr,"default.label4","is-visible=false")
			winset(usr,"default.label5","is-visible=false")
			winset(usr,"default.Abjure","is-visible=true")//so anyone can revive
			//winset(usr,"default.label6","is-visible=true")
			winset(usr,"default.label7","is-visible=false")

			//winset(usr,"default.Heat","is-visible=true")
			//winset(usr,"default.Vitae","is-visible=false")
			//winset(usr,"default.label15","is-visible=true")
			usr << "<font color=silver>You are a Builder, founding kingdoms with one stone. You have received [Deed], [TUT], [MR], [PL], [UL], [ST], [SA], [CL], [H], [J], [C], [FL], [HT] and [TR]. Equip by clicking in Inventory. <p>Fill and light your hand torch if it is dark! (Equip Knife and Flint to light)"
			usr << "<font color=#00bfff><center>Information: <font color=green>Arrow/WASD to walk, click/double-click to run, use, or attack. <br> Stance Positions:, V is Sprint mode, C is Strafe mode, X is Hold Position. <br>Ctrl+E provides a quick-unequip and Ctrl+G provides a quick-get, ctrl+mouse wheel is zoom+/-."

		if (class=="Magus")
			var/obj/IG/TUT = new(mob)
			var/obj/items/tools/Jar/J = new(mob)
			var/obj/Deed/Deed = new(mob)
			//var/obj/items/tools/CarvingKnife/C = new(player)
			var/obj/items/tools/Flint/FL = new(mob)
			var/obj/items/tools/PickAxe/PX = new(mob)
			//var/obj/items/tools/FishingPole/FP = new(player)
			var/obj/items/tools/Pyrite/PY = new(mob)
			var/obj/items/tools/ObsidianKnife/OK = new(mob)
			var/obj/items/torches/Handtorch/HT = new(mob)
			var/obj/items/Tar/TR = new(mob)
			winset(usr,"default.Build","is-visible=false")
			winset(usr,"default.Dig","is-visible=false")
			winset(usr,"default.Sow","is-visible=false")
			winset(usr,"default.Smelt","is-visible=false")
			winset(usr,"default.Smith","is-visible=false")
			winset(usr,"default.Plant","is-visible=false")
			winset(usr,"default.bar1","is-visible=true")
			winset(usr,"default.bar2","is-visible=true")
			winset(usr,"default.bar3","is-visible=true")
			winset(usr,"default.label3","is-visible=false")
			winset(usr,"default.label4","is-visible=false")
			winset(usr,"default.label5","is-visible=false")
			winset(usr,"default.Abjure","is-visible=true")//so anyone can revive
			//winset(usr,"default.label6","is-visible=true")
			winset(usr,"default.label7","is-visible=false")
			//winset(usr,"default.Heat","is-visible=true")
			//winset(usr,"default.Vitae","is-visible=false")
			//winset(usr,"default.label15","is-visible=true")
			usr << "<font color=silver>You are a Magus, weilding aertherical bonds...and a pickaxe. You have received [Deed], [TUT], [PX], [PY], [J], [OK], [FL], [HT] and [TR]. Equip by clicking in Inventory. <p>Fill and light your hand torch if it is dark! (Equip Knife and Flint to light)"
			usr << "<font color=#00bfff><center>Information: <font color=green>Arrow/WASD to walk, click/double-click to run, use, or attack. <br> Stance Positions:, V is Sprint mode, C is Strafe mode, X is Hold Position. <br>Ctrl+E provides a quick-unequip and Ctrl+G provides a quick-get, ctrl+mouse wheel is zoom+/-."

		if (class=="special1")
			var/obj/IG/TUT = new(mob)
			var/obj/Deed/Deed = new(mob)
			var/obj/items/tools/WarHammer/W = new(mob)
			var/obj/items/tools/Axe/A = new(mob)
			var/obj/items/tools/FishingPole/FP = new(mob)
			var/obj/items/tools/CarvingKnife/C = new(mob)
			var/obj/items/tools/Flint/FL = new(mob)
			var/obj/items/tools/PickAxe/P = new(mob)
			var/obj/items/tools/LongSword/L = new(mob)
			var/obj/items/tools/Hammer/H = new(mob)
			var/obj/items/tools/Jar/J = new(mob)
			var/obj/items/tools/Shovel/S = new(mob)
			var/obj/items/tools/Gloves/G = new(mob)
			var/obj/items/tools/Sickle/SK = new(mob)
			var/obj/items/tools/Hoe/HO = new(mob)
			var/obj/items/torches/Handtorch/HT = new(mob)
			var/obj/items/Tar/TR = new(mob)
			var/obj/items/Log/UeikLog/UL = new(mob, 99)
			var/obj/items/Ore/stone/ST = new(mob, 99)
			var/obj/items/Sand/SA = new(mob, 99)
			var/obj/items/Seeds/Barleyseed/BS = new(mob, 1)
			var/obj/items/Seeds/Potatoseed/PS = new(mob, 1)
			var/obj/items/Seeds/Carrotseed/CS = new(mob, 1)
			var/obj/items/Crafting/Created/Clay/CL = new(mob, 99)
			var/obj/items/Crafting/Created/Pole/PL = new(mob, 99)
			winset(usr,"default.Build","is-visible=true")
			winset(usr,"default.Dig","is-visible=true")
			//winset(usr,"default.Vitae","is-visible=true")
			winset(usr,"default.Sow","is-visible=true")
			//winset(usr,"default.Heat","is-visible=true")
			winset(usr,"default.Smelt","is-visible=true")
			winset(usr,"default.Smith","is-visible=true")
			winset(usr,"default.bar1","is-visible=true")
			winset(usr,"default.bar2","is-visible=true")
			winset(usr,"default.bar3","is-visible=true")
			winset(usr,"default.label1","is-visible=true")
			winset(usr,"default.label2","is-visible=true")
			winset(usr,"default.label4","is-visible=true")
			winset(usr,"default.label8","is-visible=true")
			winset(usr,"default.label9","is-visible=true")
			winset(usr,"default.label10","is-visible=true")
			winset(usr,"default.label11","is-visible=true")
			winset(usr,"default.label12","is-visible=true")
			winset(usr,"default.label13","is-visible=true")
			winset(usr,"default.Abjure","is-visible=true")//so anyone can revive
			usr << "<font color=silver>You've chosen the GM, hey wait a minute! [Deed][TUT][CS][BS][PS][W][A][FL][FP][P][C][L][H][J][S][G][SK][HO][HT][PL][UL][ST][SA][CL] and [TR]"

		if (gender=="Feline")
			if(class=="Feline")
				mob.icon_state = "Kitty"
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
		if (gender=="Female")
			if(class=="Landscaper")
				mob.icon_state = "Ffriar"
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if(class=="Defender")
				mob.icon_state = "Ffighter"
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if(class=="Builder")
				mob.icon_state = "Ftheurgist"
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
			if(class=="Magus")
				mob.icon_state = "Fmagus"
				mob.color = rgb(rand(0,255),rand(0,255),rand(0,255))
		winset(usr, "loadscrn","parent=loadscrn; is-visible = false; focus = false")
		winset(usr, "default","parent=default; is-visible = true; focus = true")
		//player.light = new /light/day_night(src, 4)
		//usr.client.mob.listenSoundmob(/soundmob)
		usr.client.mob = mob

		//new /light/day_night(player, 4)
		//player.logincheck = 0
		//#include "Soundmob.dm"
		//mob/players.listenSoundmob(/soundmob)
		//var/turf/first_location = locate(100,100,1) //original locate(pick(422),pick(694),1)
		//var/turf/first_location = locate(141,129,2)
		//var/turf/first_location = locate(pick(122,422),pick(294,694),1)
		//var/turf/first_location = locate(17,9,1) //testing site
		//var/turf/first_location = locate(pick(411,684),pick(422,692),1)//locate(141,129,2)//locate(pick(411,684),pick(422,692),2)  //character creation spawn in call
		//if(class=="Magus")//spawn magus away from others so they can't AOE new players right away...
			//var/turf/mfl = locate(pick(421,413),pick(692,686),pick(2,2))
			//player.Move(mfl)
		//var/turf/fl = locate(15,550,2)
		//var/turf/fl = locate(467,682,1)
		var/turf/fl = locate(25,25,2)
		//var/turf/fl = locate(pick(333,474),pick(678,613),pick(2,2)) //anti griefing spawn
		//var/turf/fl = locate(pick(421,413),pick(692,686),pick(2,2)) //for testing
		//var/turf/fl = locate(pick(133,274),pick(178,213),pick(2,2)) //anti griefing spawn
		mob.loc = fl
		mob.base_save_allowed=1
		mob.base_save_location=1

		//player.light = new /light/day_night(usr, 4)
		//player.light = new(player, 4)
		//player.mlight = new (usr.loc)
		//player.mlight.alpha = rand(120,255)
		//player.mlight.color = rgb(rand(120,255),rand(120,255),rand(120,255))
		//player.Move(locate(142,132,2))
		mob << browse(null, "window=NewCharacter")
		//player.listenSoundmob(src)
		//call(/mob/players/proc/listenSoundmob)(usr)
		//player << soundmob(/soundmob)
		//del(src)
		// Log their client into the new mob.
		//usr.client.mob = player
		//player.listenSoundmob(/soundmob)
		// And finally, blank out their web page since they don't need it now.
		return


