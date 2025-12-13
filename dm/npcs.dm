obj
	//var/description
	IG//jam pack this baby full of ALL of the info of the game. And I mean ALL of it. Well, as much info as a player needs to be able to seek more on their own.

		name = "Instinctual Guide"
		var/description = "A guide that contains information and describes survival strategies..."
		icon = 'dmi/64/anctxt.dmi'
		icon_state = "tut"
		verb/Description()
			set category=null
			usr << "[description]"
		Click()
			//set hidden = 1
			set waitfor = 0
			set popup_menu = 1
			set category = "Inventory"
				//var/mob/players/M
			set src in usr
			var/mob/players/M
			M = usr
			M.tutopen=1
			if(M.tutopen==1)
				src:icon_state = "tutu"
			else while(M.tutopen==1)
				if(M.tutopen==0)
					src:icon_state = "tut"

				//M = usr
			//if (!(src in range(1, usr))) return
			//var/K = (
			START
			switch(input("Journal of Information","Instinctual Guide") in list("Controls","Tutorial","Survive and Thrive","Knowledge Base","Close"))
				if("Close")
					M.tutopen=0
					if(M.tutopen==0)
						src:icon_state = "tut"
					sleep(1)
					M << "<font color=#FFFB98>You close the guide for now..."
					return
				if("Controls")
					M << "<font color=#FFFB98><p><b>Movement</b>: <br>LMB</b> Click, <b>WASD</b> or <b>Arrow</b> keys</p><p><b>Actions</b>: <br>Left Mouse Button</b>(Actions)/<b>Right Mouse Button</b>(Menu)</p><p><b>Macros</b>: <b>Ctrl+E</b> Quick-Unequip <b>Ctrl+G</b> Quick-Get, <b>Ctrl+Mouse Wheel</b> Zoom +/-</p><p><b>V</b> Free Movement, <b>C</b> Strafe mode, <b>X</b> Hold Position.</p>"
					M.tutopen=0
					if(M.tutopen==0)
						src:icon_state = "tut"
					sleep(1)
					return
				if("Tutorial")
					M.tutopen=1
					switch(input("Which Topic?","Select Tutorial Topic") in list("The first night","Make your first Fire","Make your first set of Tools","Make your first Forge","Close","Back"))
						if("Close")
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							M << "<font color=#FFFB98>You close the guide for now..."
							return
						if("Back") goto START
						if("The first night")
							//alert
							M << {"<font color=#FFFB98><left>Your first night in the wilderness may feel overwhelming, but survival is mostly straightforward as
							long as you stay calm and collected.<br> You require food (or potions) to heal yourself (Health = green bar). These are found by fishing
							or hunting. Left Click/Left Double Click / Right Click(menu) handle most functions in the game.<br> You must drink water to stay
							hydrated, replenishing your stamina (stamina/Stamina = blue bar), to keep active. Any pond will do, but may also be carried in a Jar or
							Vessel, found in Fountains, Oasis, Vines/Cacti.<br> You may use your equipment by clicking on it in your inventory tab on
							the interface. Click again to remove. Ctrl+E provides a quick-unequip<br> Arrow/WASD to walk, Left Click to use, Left Double Click to
							 attack. <br> Stance Positions: V is Free Movement, C is Strafe mode, X is Hold Position. <br> Ctrl+G provides a quick-get,
							Ctrl+Mouse Wheel is zoom in/out and Shift is run/walk.<br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Make your first Fire")
							M << {"<font color=#FFFB98><left>The first objective for basic survival should be to collect resources and create tools so you may
							flourish and exist.<br> You may find wooden haunch from Hallow Ueik Trees (Dark Green/Blue tree) to begin Carving.
							Don't have a knife, you say? Use wooden haunch and find and collect some obsidian (purple deposit), then combine the haunch with the
							obsidian. It is important to have fire so that you have light if it is dark and so you may cook food to eat and smelt ore for tools.<br>
							This requires kindling, one to make a fire and one to light the fire. Equip your obsidian knife and right click and select
							carve on a wooden haunch.<br> You should create kindling in front of you on the ground. Get it and proceed to use your obsidian knife to
							create a fire out of kindling (with obsidian knife equipped, right click kindling and click create novice fire),<br> This will create a
							fire on the ground in front of you, have another kindling ready to light the fire. With the pyrite and flint equipped, right click the
							fire and click light fire.<br> Congratulations! You have lit your very first fire in the realm of Pondera.<br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Make your first set of Tools")
							M << {"<font color=#FFFB98><left>Having sourced wooden haunch and having created a fire, you may proceed to create your first complete set
							of rudimentary tools.<br>You may have already created your first tool of the rudimentary set, the Obsidian Knife. Completing the rest
							of the set will require Searching for and obtaining Ancient Ueik Fir, Ancient Ueik Thorn, Ancient Ueik Splinter, Wooden Haunch x2, and a Rock.<br>
							Search flowers and tall grass for a Rock that is suitable. This will combine with a wooden haunch to create a Stone Hammer.<br>
							In this process, you may find Ancient Ueik Splinter if you search for long enough, among other things. <br>
							Search Ancient Ueik Trees (Pink trees) for a suitable Ueik Thorn which will create a Ueik Pickaxe when combined with Wooden Haunch.<br>
							If you obtain an Ancient Ueik Splinter, use your obsidian knife to carve off some Ancient Ueik Fir from Ancient Ueik Trees (Pink tree).<br>
							Use the Fir and Splinter together to create the ever-so-useful Gloves. You have completed your first set of rudimentary tools!"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Make your first Iron Tool")
							M << {"<font color=#FFFB98><left>Having created your first set of rudimentary tools, you may proceed to create your first Iron Tool!<br>
							Utilize the Ueik Pickaxe and find some Stone to mine with it. In the stone lies some Iron Ore, which you may smelt with a Fire.<br>
							Using your Stone Hammer and having obtained some Iron Ore, you may create an Iron Hammer head in a Fire by Smelting Iron Ore.<br>
							You may need to quench or polish the tool part before you can place a handle on it, use local water sources to submerge the part to quench while it is hot.<br>
							If it has cooled down, Heat it with the fire until it is Hot and then quickly quench it. After creating the Hammer head , you will need to carve a handle from a wooden haunch.<br>
							Combine the handle with the part to complete the creation of the tool. After successfully creating an Iron Hammer, you may create the final rudimentary tool, the Stone Axe. <br>
							Using the Hammer, you can shard Stone Ore to create a Stone Axe head that can be combined with a Handle to create the Stone Axe, which you may use to chop down trees for wood."}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Make your first Forge and Anvil")
							M << {"<font color=#FFFB98><left> Now that you have an Iron Hammer, you can proceed to creating your first Forge and Anvil to Smelt and Smith.<br>
							This will require having 25 Stone Ore which you can mine with the Ueik Pickaxe. This will also require 10 Mortar, which can be made by combining Sand and Clay (Collect sand in a jar and combine it with clay). <br>
							You will need 4 Ueik Log to complete the attempt. Use the Iron Hammer and select Build. Navigate the menu to Furnishings and select Forge. You may have to rank building up to see this menu (Build some fires/sundials/barricades).<br>
							For the Anvil you will require a Forge and 5 Mortar, 1 Iron Anvil Head and 2 Ueik Logs. If you manage to succeed in building a Forge, you will now be able to Smelt Ore into Ingots, Smelt an Iron Anvil Head out of 15 Iron Ingots, and Heat items for smithing. <br>
							After smelting an Iron Anvil Head via the Forge, you may build an Anvil to gain access to Smithing new items. Right click the Iron Anvil Head and click Create Anvil, have the materials required ready. Congratulations, you can now Smelt and Smith!"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Your first Smithing experience")
							M << {"<font color=#FFFB98><left> After forging and smithing for some time, you should have all of the tools you need to build a House.
							"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						//if("Building something more")
							//usr << {""}
							//return

					//alert("","Instinctual Guide")"Surviving the first night","Building something out of nothing"
					//return
				if("Survive and Thrive")
					M.tutopen=1
					switch(input("Which Topic?","Select Survival Topic") in list("Rudimentary Survival","The Basics","Intermediary","Advanced","Close","Back"))
						if("Close")
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							M << "<font color=#FFFB98>You close the guide for now..."
							return
						if("Back") goto START
						if("Rudimentary Survival")
							//alert
							M << {"<font color=#FFFB98><left>Rudimentary Tools: Obsidian Knife, Stone Hammer, Ueik Pickaxe, Pyrite, Flint, Torch.<br> Starting with absolutely no equipment can be terrifying at first, but Situational awareness is key to triumph over that fear. Use your surroundings to your advantage. More often than not, there is always something useful within reach.<p> To obtain these materials, you must search and utilize what is around you while you explore. <br>Right-click and Search on flowering tiles for the Rock you need for a Stone Hammer, or Pyrite and Flint for lighting fires, or an Ancient Ueik Splinter for sowing gloves out of Ueik Fir. <br>Look around the area for purple hued land, that indicates Obsidian; Click on it to harvest some. <br>For Wooden Haunch, harvest (Click) the Hallowed Ueik Tree (Dark Green Leaves, dark brown bark); Besides serving as a rough handle for your rudimentary tools, it can be combined with Tar (Black hued land) to create a Torch. <br>Finally, For the Ueik Thorn you must harvest (Click) on an Ancient Ueik Tree (Pink leaves, white bark).<br> Right click the proper starting material and click combine or affix.<br> If you succeed, Congratulations! You've made your first rudimentary tool in Pondera and can survive from starting with nothing! <br>If you failed in your attempt, keep trying, you will find suitable material eventually; Never give up.<br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("The Basics")
							//alert
							//M << {"<font color=#FFFB98><left>Basic equipment: Obsidian Knife, Stone Hammer, Ueik Pickaxe, Wooden Haunch/Torch.<br> With an empty bag, the first thing you want to make is an Obsidian Knife. With it you can create kindling to start Novice fires which enable you to cook and brings about the second and third requirements to get started: smelting iron collected with the Ueik Pickaxe you create, to forge an Iron Hammer head and a Carving Knife blade.<br> To obtain Wooden Haunch, locate a Hallowed Ueik Tree (Dark green leaf, dark brown bark) and harvest (click) it. This serves as a rough handle and can also create a Torch when combined with Tar (Dark hued land) Obsidian Knife, you must gather Obsidian and combine it with a Wooden Haunch.<br> To obtain Ueik Pickaxe, you must affix a Ueik Thorn and Wooden Haunch. <br> To obtain Stone Hammer, you must combine a Rock with Wooden Haunch.<br>"}
							M << {"<font color=#FFFB98><left>Basic Tools: Carving Knife, Iron Hammer, Iron Pickaxe, Iron Shovel, Iron Axe, Gloves, Wooden Haunch/Torch.<br> These tools are the first set you want to focus on after achieving your Rudimentary tool set. They are the primary means of survival, crafting and landscaping.<br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Intermediary")
							//alert
							M << {"<font color=#FFFB98><left>Intermediary Tools: Fishing Pole, Iron Sickle, Iron Hoe, Iron Chisel.<br> These tools require sectiary materials, these tools are the next stage for those who have a basic set. <br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"//need to finish the descriptions with roughly how to make each tool in basic and intermediary
							sleep(1)
							return
						if("Advanced")
							//alert
							M << {"<font color=#FFFB98><left>Advanced Tools: Steel Trowel.<br> Requiring tertiary materials, these tools are for those whom are well situated. Steel can be made by combining hot Iron ingots with Activated Carbon. The Steel can then be utilized to create the Trowel Blade, which can be combined with a Handle to create a Steel Trowel which is used with Mortar and Bricks to create Stone Buildings.<br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
				if("Knowledge Base")
					M.tutopen=1
					//var/A// = list("Equipment","Biome","Biology","Close")
					KNOWLEDGEBASE
					switch(input("Which Topic?","Select Knowledge Base Topic") in list("Equipment","Biome","Biology","Close","Back"))
						if("Close")
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							M << "<font color=#FFFB98>You close the guide for now..."
							return
						if("Back") goto START
						if("Equipment")
							EQUIPMENT
							switch(input("Which Topic?","Select Equipment Topic") in list("Tool","Weapon","Armor","Magi","Item","Close","Back"))
								if("Close")
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									M << "<font color=#FFFB98>You close the guide for now..."
									return
								if("Back") goto KNOWLEDGEBASE
									//M.tutopen=0
									//if(M.tutopen==0)
									//	src:icon_state = "tut"
									//sleep(1)
									//M << "<font color=#FFFB98>You close the guide for now..."
									//return
								if("Tool")
									switch(input("Which Topic?","Select Equipment Topic") in list("Jar","Gloves","Torch","Obsidian Knife","Ueik Pickaxe","Stone Hammer","Iron Hammer","Carving Knife","Stone Axe","Iron Pickaxe","Iron Axe","Iron Shovel","Iron Hoe","Iron Sickle","Fishing Pole","Iron Chisel","Steel Trowel","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto EQUIPMENT
										if("Jar")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Jar'>Jar <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='clay'>Clay collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/gen.dmi' ICONSTATE='clay'>Clay deposit. <br> Use your hands (right click clay > Form Jar) to form the <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='clay'>Clay into an <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UBJar'>Unbaked Jar. <br> Utilize a <IMG CLASS=bigicon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='LF'>Lit Fire to bake the <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UBJar'>Unbaked Jar into a <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Jar'>Jar.<br> Utilized for carrying water from <IMG CLASS=bigicon SRC=\ref'dmi/64/gen.dmi' ICONSTATE='water'>Water Sources."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Gloves")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='gloves'>Gloves <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='AUS'>Ancient Ueik Splinter collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='rf'>Flowers. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikFir'>Ueik Fir collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeA'>Ancient Ueik Tree.<br> Gloves are utilized for handling hot objects, such as claywork, smithing and smelting or to receive your Celebration day gift!"}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Torch")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='tar'>Tar collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/gen.dmi' ICONSTATE='tar'>Tar pits.<br> Ignite a torch once Tar is applied by utilizing <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pyrite'>Pyrite and <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint, or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Flint'>Flint. Useful for creating Light to relieve the darkness."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Obsidian Knife")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='obsidian'>Obsidian collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/gen.dmi' ICONSTATE='obsidian'>Obsidian fields. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree.<br> Utilized for carving novice <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handles, <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>Kindling, <br>and <IMG CLASS=bigicon SRC=\ref'dmi/64/fire.dmi' ICONSTATE='ht'>Torch."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Ueik Pickaxe")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikThorn'>Ueik Thorn collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeA'>Ancient Ueik Tree. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree.<br> Utilized for mining <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore from <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='srock'>Stone Rocks."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Stone Axe")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneAxe'>Stone Axe <br> Made from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='stone'>Stone Ore. Stone Axe head is created by using <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Hammer'>Hammer to create shards from Stone Ore.<br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hndl'>Handle carved via the <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='ObsidianKnife'>Obsidian Knife on <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree.<br> Utilized for chopping down <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='umat4'> Mature Ueik Trees to create <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Logs."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Stone Hammer")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'>Stone Hammer <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='rock'>Rock collected from searching any variety of<IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='rf'>Flowers. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree.<br> Utilized for crafting <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='IronHammer'>Iron Hammer from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Hammer")
											//alert
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='IronHammer'>Iron Hammer <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WDHNCH'>Wooden Haunch or <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Building or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='anvil'>Smithing."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Carving Knife")
											//alert
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WDHNCH'>Wooden Haunch or <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Carving and Lighting Fire with Flint."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Pickaxe")
											//alert
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log via <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>.<br> Utilized for Mining."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Axe")
											//alert
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Axe'>Iron Axe <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WDHNCH'>Wooden Haunch or <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for chopping down Ueik trees for logs."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Shovel")
											//alert
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Shovel'>Iron Shovel <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Landscaping or Removing Stumps."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Hoe")
											//alert
											M << {"<font color=#FFFB98><center>Intermediary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='hoe'>Iron Hoe <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Gardening."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Sickle")
											//alert
											M << {"<font color=#FFFB98><center>Intermediary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Iron Sickle <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WDHNCH'>Wooden Haunch or <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Botany (harvesting seeds and sprouts)."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Fishing Pole")
											//alert
											M << {"<font color=#FFFB98><center>Intermediary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='546'>Fishing Pole <br> Crafted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='pole'>Pole carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for catching Fish."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron Chisel")
											//alert
											M << {"<font color=#FFFB98><center>Intermediary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Chisel'>Iron Chisel <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot smelted from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WDHNCH'>Wooden Haunch or <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Stoneworking."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Steel Trowel")
											//alert
											M << {"<font color=#FFFB98><center>Advanced equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='trowel'>Steel Trowel <br> Smithied from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='sb'>Steel Ingot created from mixing <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='charcoal'>Activated Carbon with a Hot<IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='hndl'>Handle carved from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WDHNCH'>Wooden Haunch or <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log.<br> Utilized for Brickworking."}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
											//need to finish details
								if("Weapon")
									M << {"Current equipment database unknown"}
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									return
								if("Armor")
									M << {"Current equipment database unknown"}
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									return
								if("Magi")
									M << {"Current equipment database unknown"}
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									return
								if("Item")
									M << {"Current equipment database unknown"}
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									return
						if("Biome")
							M.tutopen=1
							BIOME
							switch(input("Which Topic?","Select Biome Topic") in list("Terranology","Geology","Close","Back"))
								if("Close")
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									M << "<font color=#FFFB98>You close the guide for now..."
									return
								if("Back") goto KNOWLEDGEBASE
								if("Terranology")
									switch(input("Which Topic?","Select Terranology Topic") in list("Temperate", "Arctic", "Pyroclastic", "Desert", "Tropical","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto BIOME
										if("Temperate")
											//alert
											M << {"<font color=#FFFB98><center>Temperate Terrain: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/gen.dmi' ICONSTATE='grass'> The most common type of terrain, most survival options are provided by this biome. <br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Arctic")
											M << {"<font color=#FFFB98><center>Arctic Terrain: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/snow.dmi' ICONSTATE='snow'> An uncommon type of terrain, sparse survival options are provided by this biome. <br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Pyroclastic")
											M << {"<font color=#FFFB98><center>Pyroclastic Terrain: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/sand.dmi' ICONSTATE='clast'> A rare type of terrain, no survival options are provided by this biome. <br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Desert")
											M << {"<font color=#FFFB98><center>Desert Terrain: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/sand.dmi' ICONSTATE='sand'> A common type of terrain, some survival options are provided by this biome. <br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Tropical")
											M << {"<font color=#FFFB98><center>Jungle Terrain: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/drkgrss.dmi'> A common type of terrain, some survival options are provided by this biome. <br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
								if("Geology")
									M.tutopen=1
									switch(input("Which Topic?","Select Geology Topic") in list("Stone", "Iron", "Lead", "Zinc", "Copper","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto BIOME
										if("Stone")
											M << {"<font color=#FFFB98><center>Rudimentary Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='srock'>Stone Rock - A common type of material, some crafting and survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='stone'>Stone ore and <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore. <br>Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe to access this material.<br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Iron")
											M << {"<font color=#c0c0c0><center>Basic Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='irock'>Iron rock - A common type of material, crafting and survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='stone'>Stone ore and <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='iron'>Iron Ore.<br> Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='UeikPickAxe'>Ueik Pickaxe on <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='srock'>Stone rock or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe on <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='irock'>Iron rock to access this material.<br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Lead")
											M << {"<font color=#4682b4><center>Intermediate Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='lrock'>Lead rock - An uncommon type of material, crafting options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='lead'>Lead ore smelted into <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='lb'>Lead Ingot.<br> Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe on <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='lrock'>Lead rock to access this material.<br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Zinc")
											M << {"<font color=#e6e8fa><center>Intermediate Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='zrock'>Zinc rock - An uncommon type of material, crafting options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='zinc'>Zinc ore smelted into <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='zb'>Zinc Ingot.<br> Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe on <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='zrock'>Zinc rock to access this material.<br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Copper")
											M << {"<font color=#b87333><center>Intermediate Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='crock'>Copper rock - A common type of material, crafting options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='copper'>Copper ore smelted into <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='cb'>Copper Ingot.<br> Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='PickAxe'>Iron Pickaxe on <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='crock'>Copper rock to access this material.<br> "}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
						if("Biology")
							M.tutopen=1
							BIOLOGY
							switch(input("Which Topic?","Select Biology Topic") in list("Plant","Animal","Insect","Unknown","Close","Back"))
								if("Close")
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									M << "<font color=#FFFB98>You close the guide for now..."
									return
								if("Back") goto KNOWLEDGEBASE
								if("Plant")
									PLANT
									switch(input("Which Topic?","Select Plant Topic") in list("Tree","Bush","Foliage","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto BIOLOGY
										if("Tree")
											switch(input("Which Tree?","Select Tree Topic") in list("Hallow Ueik Tree","Ueik Tree","Ancient Ueik Tree","Hydrating Cactus","Healing Cactus","Poisonous Cactus","Hydrating Vine","Healing Vine","Poisonous Vine","Close","Back"))
												if("Close")
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													M << "<font color=#FFFB98>You close the guide for now..."
													return
												if("Back") goto PLANT
												if("Hallow Ueik Tree")
													M << {"<font color=#FFFB98><center>Rudimentary Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree - An uncommon type of material, crafting and survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch. <br> Utilize Hands (click with nothing equipped) on <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree to access this material.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Ueik Tree")
													M << {"<font color=#FFFB98><center>Basic Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='umat4'>Ueik Tree - The most common type of material, crafting and survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log and <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='usprout1'>Ueik Sprouts. <br> Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife on <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikLog'>Ueik Log or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle for sprouts, to access this material.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Ancient Ueik Tree")
													M << {"<font color=#FFFB98><center>Intermediate Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeA'>Ancient Ueik Tree - An uncommon type of material, crafting and survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikThorn'>Ueik Thorn and <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='UeikFir'>Ueik Fir. <br> Utilize <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife on <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeA'>Ancient Ueik Tree or Hands (click with nothing equipped) to access these materials.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Hydrating Cactus")
													M << {"<font color=#FFFB98><center>\  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WCactus'>Hydrating Cactus -  Survival options are provided by this material. <br> Utilize Hands (click with nothing equipped) or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Jar'>Jar to access this material.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Healing Cactus")
													M << {"<font color=#FFFB98><center>\  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='HCactus'>Healing Cactus - Survival options are provided by this material. It's Salve will restore your health. Utilize Hands (click with nothing equipped) to access this material.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Poisonous Cactus")
													M << {"<font color=#FFFB98><center>\  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='PCactus'>Poisonous Cactus - This material should be avoided. It may have some use at a later date.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Hydrating Vine")
													M << {"<font color=#FFFB98><center>\  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='WVine'>Hydrating Vine -  Survival options are provided by this material. <br> Utilize Hands (click with nothing equipped) or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife and <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Jar'>Jar to access this material.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Healing Vine")
													M << {"<font color=#FFFB98><center>\  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='HVine'>Healing Vine - Survival options are provided by this material. It's Salve will restore your health. Utilize Hands (click with nothing equipped) to access this material.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Poisonous Vine")
													M << {"<font color=#FFFB98><center>\  <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='PVine'>Poisonous Vine - This material should be avoided. It may have some use at a later date.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
										if("Bush")
											switch(input("Which Bush?","Select Bush Topic") in list("Blueberry Bush","Raspberry Bush","Close","Back"))
												if("Close")
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													M << "<font color=#FFFB98>You close the guide for now..."
													return
												if("Back") goto PLANT
												if("Blueberry Bush")
													M << {"<font color=#FFFB98><center>Basic Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='ripe2'>Blueberry Bush - A common type of material, survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='bb'>Blueberry and <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='bbs'>Blueberry Seed. <br> Utilize Hands (click with nothing equipped) or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to access these materials.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Raspberry Bush")
													M << {"<font color=#FFFB98><center>Basic Material: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='ripe1'>Raspberry Bush - A common type of material, survival options are provided by this material in the form of <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='rb'>Raspberry and <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='rbs'>Raspberry Seed. <br> Utilize Hands (click with nothing equipped) or <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='sickle'>Sickle to access these materials.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
										if("Foliage")
											switch(input("Which Foliage?","Select Foliage Topic") in list("Flowers","Jungle Fern","Short Grass","Tall Grass","Close","Back"))
												if("Close")
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													M << "<font color=#FFFB98>You close the guide for now..."
													return
												if("Back") goto PLANT
												if("Flowers")
													M << {"<font color=#FFFB98><center>Common: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='rf'>Flowers - A common type of material, crafting and survival options are provided by this material by the act of Searching. <br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Fern")
													M << {"<font color=#FFFB98><center>Common: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='junglefern'>Jungle Fern - A common type of material, it may have some use in the future.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Short Grass")
													M << {"<font color=#FFFB98><center>Common: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='shrtgrss'>Short Grass - A common type of material, it may have some use in the future.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
												if("Tall Grass")
													M << {"<font color=#FFFB98><center>Uncommon: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='elegrss'>Tall Grass - A common type of material, it may have some use in the future.<br> "}
													M.tutopen=0
													if(M.tutopen==0)
														src:icon_state = "tut"
													sleep(1)
													return
								if("Animal")
									switch(input("Which Topic?","Select Animal Topic") in list("Predator","Prey","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto BIOLOGY
										if("Predator")
											M << {"Current biology database unknown"}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Prey")
											M << {"Current biology database unknown"}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
								if("Insect")
									M << {"<font color=#FFFB98><center>Common: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='btf'>Butterfly.<br> "}
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									return
								if("Unknown")
									M << {"Current biology database unknown"}
									M.tutopen=0
									if(M.tutopen==0)
										src:icon_state = "tut"
									sleep(1)
									return
mob
	PonderaNPCS
		layer = 3
		//plane = 3
		BoatCaptain
			name = "Boat Captain"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "boat1captain"
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				// Validate distance BEFORE input dialog
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/K = (input("You've arrived...","Discuss") in list("Where?"))
				switch(K)
					if("Where?")
						alert("In a realm of Pondera that is relatively safe. Be sure to use your equipment wisely and drink plenty of water to keep active.","Discuss")
						return
	FreedomNPCS
		layer = 3
		//plane = 3
		Adventurer
			name = "Adventurer"
			density = 1
			//layer = 3
			//plane = 3
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				// Validate distance BEFORE input dialog
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/K = (input("I've Never seen you around here before... What is your business in these parts?","Discuss") in list("Huh?","What's it to you?","Keep to yourself, Beggar!"))
				switch(K)
					if("Huh?")
						alert("Ah well, I suppose it doesn't matter anyway - but you probably shouldn't leave this Principality until you are capable of defending yourself and surviving out in the wild.","Discuss","Alright, Thanks.","Hmfp. What makes you think I can't survive?")
						if("Alright, Thanks.")
							return
						else
							if("Hmfp. What makes you think I can't survive?")
								alert("Well, those creatures ~ for one ~ two, the fact that you Will run out of stamina and if you don't have the resources to replinish yourself you Will Die and that is that. No coming back. Prepare Well before hand and survive in the long run.")
					if("What's it to you?")
						alert("I suppose if you're new you might want to know to be well prepared before leaving for your Journey to the Crater and I Sincerely mean that, if that is your destination.","Discuss","Okay..")
						if("Okay..")
							alert("That is your Destination right? I suppose that is the sole destination if you are here, as if the Mundus Eversor is Calling to its Inhabinants","Discuss","Mundo what now?","Indeed.")
							if("Mundo what now?")
								alert("Nevermind, you will find out soon enough if you have the persistence within yourself to survive that long; After all, I've heard those creatures are those who couldn't make it through.")
					if("Keep to yourself, Beggar!")
						alert("Beggar? Guess you are free to say what you wish here but elsewhere I'd be Wary, Be Gone.","Discuss","I do what I want!","Sorry...")
						if("Sorry...")
							alert("It's okay, Just be careful not to get ahead of yourself or you won't last a day.","Discuss","Right!")
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)     //while its still there, and not deleted..
					//if (P in oview(5))    //If a PC is in 5 spaces of it...
						//step_towards(src,P)   //Step towards the PC
					//else
					if(P in range(src))
						break
					else
						sleep(Speed)
						step_rand(src)   //step random
						//for(P in view(src))  //but if a PC comes nearby...
						//	break     //stop walking random
					//sleep(speed)
				spawn(260)   //Keep the infinit loop in action, and tell it to wait for 4 seconds
					NPCWander(Speed)
		Instructor
			name = "Instructor"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "inst"
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("How did I do", "howdid"),
					new /datum/npc_interaction_option("What do I do now", "whatnext"),
					new /datum/npc_interaction_option("What do I get", "whatget"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_howdid(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("That isn't important, all that matters is today is the day that you can pursue a greater goal and utilize the basic set of abilities that we have taught you. Seek the truth and the answers that this kingdom, or even yourself, strive to uncover. Use all at hand to survive and know when to be hasty and when not to be and you should come through any situation you may come across. Do not be too careless, it could be your downfall in the end.")
			
			proc/Interact_whatnext(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("You will probably want to train up the abilities that you have received and prepare a very large travel-pack before you head out beyond these lands. Yes, beyond these lands lies danger that can end anyone in a matter of moments if they are careless. The world has grown tired of 'People'. For the way the civilizations of the modern era treated it: They built figurative mountains on stilts and toxified the land, air, and sea around them and eventually it was realized to be unsustainable and crumbled beneath its own weight. Thus the lands see 'People' as the enemy and Rightly so.")
			
			proc/Interact_whatget(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("The ability to Survive and the Knowledge to seek the Answers. The abilities you chose to learn are what you received, it is up to you to train them and utilize them the best.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()

		POBOldMan
			name = "POBOldMan"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "poboman"
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Say I don't know", "idk"),
					new /datum/npc_interaction_option("Say looking around", "lookaround"),
					new /datum/npc_interaction_option("Say give stuff", "robbery"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_idk(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Then what are you doing in here, Scram! I am just an old occupant of this Principality. I adventured my way here as a young boy and decided to stay, what with the distant ocean air in the breeze, the Oasis and the constant hot weather keep me chipper for an old man. Who'd want to leave? That is what I Believe anyway...")
			
			proc/Interact_lookaround(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("So you're new to these parts? Moving here or are you an Adventurer? Either way I'd suggest to stay out of trouble, nobody likes to be messed with and this is a close knit community. We don't even have torches in the alley ways! Not much to do 'round here, this is basically a Trading Post for the shipping lanes that pass through this area.\n\nWell isn't that great, just keep out of my things! Darn adventurer's seem to always take whatever they want. You also lower the local monster population as well so that is one good thing about the lot of ya.\n\nTry the Inn, of course, you could always build your own home but it takes a highly skilled Builder to do such a thing. Exit the Building and go down the street and to the left all the way to the end, you should find the Inn with comfortable affordable rooms at the lower left corner of the city!\n\nAh well that is interesting, roaming free can indeed be a wonderful journey to no certain destination but it is also somewhat dangerous. Make sure to keep stocked up on supplies or be a really good survivalist and you should have no issues.")
			
			proc/Interact_robbery(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Really, You're going to try and rob me in my own home? Petty Thief! You couldn't take it from me if you tried, Begone! There is nothing for you here. Yeah that's right, back down and get out of here before you get hurt! I don't have anything here anyway, just some of my old rusty equipment that is too brittle to serve any purpose that you seek.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
	BeliefNPCS
		layer = 3
		//plane = 3
		Adventurer
			name = "Adventurer"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask meaning", "meaning"),
					new /datum/npc_interaction_option("Ask why", "why"),
					new /datum/npc_interaction_option("Shift focus", "focus"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_meaning(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Well, at a certain point, to the west, there are holes that you can fall into and you cannot climb out of them. I'm a foreigner here so I don't really know, I haven't ventured that far yet; but I have heard rumors that certain folk have been cast away via those holes; Nobody will say what is on the other side.")
			
			proc/Interact_why(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Just a guess but you probably aren't prepared well enough to venture past this point, but that isn't anything that cannot be remedied. All the youth think they're Ten Feet Tall and Bullet Proof; But reality soon sets in, plans do not go as planned and provisions are never enough.")
			
			proc/Interact_focus(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Better shift your interest into training and acquiring what you need to survive. If you want to do other things, you better turn back and stick around the Forests where you can somewhat live, although you cannot build anything.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Explorer
			name = "Explorer"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask what", "whatmean"),
					new /datum/npc_interaction_option("Say things change", "disagree"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_whatmean(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("If you try to hurry through what you do you will forget something along the way and end up too weak or unprepared to survive. If you get too far ahead of yourself you will be weak. Is what I am saying.")
			
			proc/Interact_disagree(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("That is fine, it is just your Rebel spirit fighting to survive. Just realize this: Life is Harsh and forts offer protection that enables Weakness. The basic fundamentals of life do not change so much, they may vary, but they generally remain the same.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Traveler
			name = "Traveler"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask what do", "whatdo"),
					new /datum/npc_interaction_option("Ask why care", "whycare"),
					new /datum/npc_interaction_option("Learn recipes", "teach", TRUE),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_whatdo(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I fill various needs, finding wild goods and bringing them to merchants. I've carved planks for house building, cut stone for walls, gathered food and spice; I've also distributed random goods like Hand Made Blankets to the masses, there are only so many colors though.")
			
			proc/Interact_whycare(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("You're the one talking to me.")
			
			proc/Interact_teach(mob/players/M, datum/NPC_Interaction/session)
				session.Close()  // Close HUD before teaching
				TravelerRecipeDialogUnified(M, src)
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Scribe
			name = "Scribe"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask what up to", "whatup"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_whatup(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I'm a Scribe, I write down records of Higher Court affairs or anywhere I am hired to do so. Not when you have access to special information.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Proctor
			name = "Proctor"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "proct"
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask what do", "whatdo"),
					new /datum/npc_interaction_option("Ask help", "helpme"),
					new /datum/npc_interaction_option("Say okay place", "okayplace"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_whatdo(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I teach newcomers basic abilities to help them on their journey.")
			
			proc/Interact_helpme(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("You'll want to train your abilities and practice your movements if you want to make it any further. I am unable to tell you what is beyond this point but you must be prepared for it none the less. Yes, at a certain point you will be unable to return and there are things that lie beyond that point that we cannot discuss. That is for me to know and you to find out, because once you do, you may never return.")
			
			proc/Interact_okayplace(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("As long as you keep your foreign nose out of our business we do not mind you being here, but we Believe Everyone to be Suspicious.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
	PrideNPCS
		layer = 3
		//plane = 3
		Adventurer
			name = "Adventurer"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				// Validate distance BEFORE input dialog
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/K = (input("You've Survived? Good, but there are much harder roads ahead; I tried, earlier, to venture further but it was just too tough.","Discuss") in list("Yeah I'm still here.","Piece of cake!"))
				switch(K)
					if("Yeah I'm still here.")
						alert("That's good, stay on your toes and keep your guard up, you should come out okay; I'm going to rest here before venturing further, seems like a nice cozy place.","Discuss","Alright.","Yeah.")
						//if("Alright, Thanks.")
							//return
					if("Piece of cake!")
						alert("It gets much harder past this point, I've tried to move ahead and I decided to rest here for awhile until I try again, hopefully I make it.","Discuss","Yeah, Good luck!")
						if("Yeah, Good luck!")
							alert("Good luck to you too.","Discuss","Later.","Goodbye, see you again!")
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)     //while its still there, and not deleted..
					//if (P in oview(5))    //If a PC is in 5 spaces of it...
						//step_towards(src,P)   //Step towards the PC
					//else
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)   //step random
						//for(P in view(src))  //but if a PC comes nearby...
						//	break     //stop walking random
					//sleep(speed)
				spawn(260)   //Keep the infinit loop in action, and tell it to wait for 4 seconds
					NPCWander(Speed)
		Artisan
			name = "Artisan"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "advF"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask what do", "whatdo"),
					new /datum/npc_interaction_option("Ask who are", "whoare"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_whatdo(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I'm an artisan, I create various things for distribution.")
			
			proc/Interact_whoare(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Why does that matter? All you need to know is that I'm an artisan and I create various goods for people.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Craftsman
			name = "Craftsman"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "vw1"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Say no need", "noneed"),
					new /datum/npc_interaction_option("Ask whats up", "whatsup"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_noneed(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Well if you need anything, you might as well realize that it is best to do it yourself.")
			
			proc/Interact_whatsup(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Nothing, busy working, as always.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Builder
			name = "Builder"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "va1"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Say really", "really"),
					new /datum/npc_interaction_option("Ask why", "why"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_really(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I'm a builder, I designed these houses to be warm and efficient. That is why they are all the same size.")
			
			proc/Interact_why(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I built them all, they are designed so that they can remain warm. Their size is what makes this possible and they must be maintained.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
		Lumberjack
			name = "Lumberjack"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "vi1"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask how going", "howgoing"),
					new /datum/npc_interaction_option("Ask what up to", "whatup"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_howgoing(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Good, I suppose ~ just taking an extended break before I get back to gathering dead wood for the towns fires. Gotta keep warm!")
			
			proc/Interact_whatup(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Relaxing before I have to go out and gather more wood. I'm a Lumberjack, gotta keep these houses warm in this climate!")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
	HonorNPCS
		layer = 3
		//plane = 3
		Elder
			name = "Elder"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask survivor", "survivor"),
					new /datum/npc_interaction_option("Ask young", "young"),
					new /datum/npc_interaction_option("Learn recipes", "teach", TRUE),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_survivor(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Yes, you are a survivor are you not? You've made it this far and I've seen many days pass where not a single soul has arrived to these steps.")
			
			proc/Interact_young(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("Yes, compared to me you are young as I am an Elder, but it is not an insult; rather just a compliment or even envy of your remaining days over mine.")
			
			proc/Interact_teach(mob/players/M, datum/NPC_Interaction/session)
				session.Close()  // Close HUD before teaching
				ElderRecipeDialogUnified(M, src)
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()

		Veteran
			name = "Veteran"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			
			proc/GetInteractionOptions()
				return list(
					new /datum/npc_interaction_option("Ask rough", "rough"),
					new /datum/npc_interaction_option("Ask mean", "mean"),
					new /datum/npc_interaction_option("Leave", "leave", TRUE)
				)
			
			proc/Interact_rough(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("I'm an old Veteran, what do you expect from me? The things I've seen would drive any ordinary person into madness.")
			
			proc/Interact_mean(mob/players/M, datum/NPC_Interaction/session)
				session.SetResponse("It doesn't matter anymore. I've endured things that would crush the spirit of average folk. A rough demeanor is just what's left of me.")
			
			Click()
				set hidden = 1
				set src in oview(1)
				if (!(src in range(1, usr)))
					usr << "You're too far away!"
					return
				var/datum/NPC_Interaction/menu = new(src, usr)
				menu.Show()
			
			New()
				.=..()
				spawn(60)
					NPCWander(Speed)

			proc/NPCWander(Speed)
				var/mob/players/P
				while(src)
					for(P in oview(src))
						break
					sleep(Speed)
					step_rand(src)
				spawn(260)
					NPCWander(Speed)
						//if("Alright, Thanks.")
							//return
					if("What do you mean?")
						alert("What do I mean? Do you want to die? What is your desire, because that is all that lies ahead in this existence. I find it hard to see any meaning in anything anymore, I can't continue onward it is too powerful and I just ..want to stay here..","Discuss","Ahh, I see; Sounds like you've had a rough time.")
		Warrior
			name = "Warrior"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "adv"
			var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Hey you, be careful.","Discuss") in list("What?","Why?"))
				switch(K)
					if("What?")
						alert("Well you've made it this far, no point in going out there and dying needlessly ~ Try teaming up with others to improve your results.","Discuss","Thanks for the advice.")
						//if("Alright, Thanks.")
					if("Why?")
						alert("Why? What do you mean why? Are you looking for your end in these lands? Heed caution there is no reason to run to your doom.","Discuss","Right!..","I'll do as I please...")
						if("I'll do as I please...")
							alert("That  kind of attitude is your own downfall","Discuss","How would you know old man?","Indeed.")
							if("How would you know old man?")
								alert("I'm not that old, but I've seen many others with the same attitude fall in combat, don't get careless.")