obj
	//var/description
	IG//jam pack this baby full of ALL of the info of the game. And I mean ALL of it. Well, as much info as a player needs to be able to seek more on their own.

		name = "Instinctual Guide"
		var/description = "A beginners guide that explores your instinctual behaviours..."
		icon = 'dmi/64/anctxt.dmi'
		icon_state = "tut"
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
					switch(input("Which Topic?","Select Tutorial Topic") in list("The first night","Make your first fire","Close","Back"))
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
							M << {"<font color=#FFFB98><left>Your first night in the wilderness may feel overwhelming, but survival is mostly straightforward as long as you stay calm and collected.<br> You require food or potions to heal yourself (green bar). These are found by fishing or hunting. Click/DoubleClick/RightClick(menu) handle most functions in the game.<br> You must drink water to stay hydrated, replenishing your energy (blue bar), to keep active. Any pond will do, but may also be carried in a jar or found in Fountains, Oasis or even Vines/Cacti.<br> You may equip your equipment by clicking on it in your inventory tab on the statpanel to the left on the interface. Click again to remove. Ctrl+E provides a quick-unequip<br> Arrow/WASD to walk, click/double-click to run, use, or attack. <br> Stance Positions: V is Free Movement, C is Strafe mode, X is Hold Position. <br> Ctrl+G provides a quick-get, ctrl+mouse wheel is zoom+/-.<br>"}
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							return
						if("Make your first fire")
							M << {"<font color=#FFFB98><left>The first objective for basic survival should be to collect resources so you may flourish and exist.<br> You may be able to find some logs on the ground or wooden haunch from Hallow Ueik Trees (Dark Green tree) and utilize your obsidian knife or carving knife to begin Carving. To carve, use your Obsidian Knife or Carving Knife (click in inventory panel on the left) and right click on the material you wish to carve, Wooden Haunch or Log, respectively, and select Carve.<br> The first thing you might want to make is a fire so that you have light if it is dark and so you may cook food to eat or begin crafting.<br> This requires kindling, one to make and one to light. Collect wooden haunch or log and equip your obsidian knife or carving knife and right click and select carve.<br> You should create kindling infront of you on the ground. Get it and proceed to equip your carving knife and flint, right click a log and click create fire. (if using obsidian knife, right click kindling and click create novice fire, you will need pyrite and flint to light it)<br> This will create a fire on the ground infront of you, have another kindling ready to light the fire. With the carving knife and flint, or the pyrite and flint equipped, right click the fire and light fire.<br> Congratulations! You have lit your very first fire in the realm of Pondera. This small tutorial should give you a good headstart on figuring out how to survive these harsh lands.<br>"}
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
							M << {"<font color=#FFFB98><left>Advanced Tools: Steel Trowel.<br> Requiring tertiary materials, these tools are for those well situated. Steel can be made by combining hot Iron ingots with Activated Carbon. The Steel can then be utilized to create the Trowel Blade, which can be combined with a Handle to create a Steel Trowel which is used with Mortar and Bricks to create Stone Buildings.<br>"}
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
									switch(input("Which Topic?","Select Equipment Topic") in list("Jar","Gloves","Torch","Obsidian Knife","Ueik Pickaxe","Stone Hammer","Iron Hammer","Carving Knife","Iron Pickaxe","Iron Axe","Iron Shovel","Iron Hoe","Iron Sickle","Fishing Pole","Iron Chisel","Steel Trowel","Close","Back"))
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
										if("Stone Hammer")
											//alert
											M << {"<font color=#FFFB98><center>Rudimentary equipment: \  <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='StoneHammer'>Stone Hammer <br> Made with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='rock'>Rock collected from searching any variety of<IMG CLASS=bigicon SRC=\ref'dmi/64/plants.dmi' ICONSTATE='rf'>Flowers. <br> Combined with <IMG CLASS=bigicon SRC=\ref'dmi/64/inven.dmi' ICONSTATE='WDHNCH'>Wooden Haunch collected from <IMG CLASS=bigicon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='UeikTreeH'>Hallow Ueik Tree.<br> Utilized for crafting <IMG CLASS=bigicon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='IronHammer'>Iron Hammer from <IMG CLASS=bigicon SRC=\ref'dmi/64/build.dmi' ICONSTATE='ib'>Iron Ingot."}
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
		plane = 3
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
				if (!(src in range(1, usr))) return
				var/K = (input("You've arrived...","Discuss") in list("Where?"))
				switch(K)
					if("Where?")
						alert("In a realm of Pondera that is relatively safe. Be sure to use your equipment wisely and drink plenty of water to keep active.","Discuss")
						return
	FreedomNPCS
		layer = 3
		plane = 3
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
				if (!(src in range(1, usr))) return
				var/K = (input("I've Never seen you around here before... What is your business in these parts?","Discuss") in list("Huh?","What's it to you?","Keep to yourself, Beggar!"))
				switch(K)
					if("Huh?")
						alert("Ah well, I suppose it doesn't matter anyway - but you probably shouldn't leave this Principality until you are capable of defending yourself and surviving out in the wild.","Discuss","Alright, Thanks.","Hmfp. What makes you think I can't survive?")
						if("Alright, Thanks.")
							return
						else
							if("Hmfp. What makes you think I can't survive?")
								alert("Well, those creatures ~ for one ~ two, the fact that you Will run out of energy and if you don't have the resources to replinish yourself you Will Die and that is that. No coming back. Prepare Well before hand and survive in the long run.")
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
			//var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Hello and welcome to your Final Day at the Academy.","Graduation") in list("How'd I do?","What do I do now?","Alright! What do I get?"))
				switch(K)
					if("How'd I do?")
						alert("That isn't important, all that matters is today is the day that you can pursue a greater goal and utilize the basic set of abilities that we have taught you.","Graduation","Okay, So what does that mean?","Sounds good to me, let me go!")
						if("Okay, So what does that mean?")
							alert("Seek the truth and the answers that this kingdom, or even yourself, strive to uncover; Use all at hand to survive and know when to be hasty and when not to be and you should come through any situation you may come across.")
						if("Sounds good to me, let me go!")
							alert("Do not be too careless, it could be your downfall in the end.")
					if("What do I do now?")
						alert("You will probably want to train up the abilities that you have received and prepare a very large travel-pack before you head out beyond these lands.","Graduation","Beyond these lands?")
						if("Beyond these lands?")
							alert("Yes, beyond these lands lies danger that can end anyone in a matter of moments if they are careless. The world has grown tired of 'People'.","Graduation","Why?","Indeed.")
							if("Why?")
								alert("For the way the civilizations of the modern era treated it; They built figurative mountains on stilts and toxified the land, air, and sea around them and eventually it was realized to be unsustainable and crumbled beneath its own weight...Thus the lands see 'People' as the enemy and Rightly so I might add.")
					if("Alright! What do I get?")
						alert("The ability to Survive and the Knowledge to seek the Answers.","Graduation","I see...","Anything else?...")
						if("Anything else?...")
							alert("The abilities you chose to learn are what you received, it is up to you to train them and utilize them the best.","Graduation","Right!")

		POBOldMan
			name = "POBOldMan"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "poboman"
			//var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Why are you in my house?","Discussion") in list("Oh I don't know...","Just lookin around...","Drop any weapons and give me all your stuff!"))
				switch(K)
					if("Oh I don't know...")
						alert("Then what are you doing in here, Scram!","Discussion","Sheesh, sorry!","Wait a minute, who are you?")
						if("Wait a minute, who are you?")
							alert("I am just an old occupant of this Principality; I adventured my way here as a young boy and decided to stay, what with the distant ocean air in the breeze, the Oasis and the constant hot weather keep me chipper for an old man, Who'd want to leave? That is what I Believe anyway...")
					if("Just lookin around...")
						alert("So you're new to these parts? Moving here or are you an Adventurer? Either way I'd suggest to stay out of trouble, nobody likes to be messed with and this is a close knit community, we don't even have torches in the alley ways! Not much to do 'round here, this is basically a Trading Post for the shipping lanes that pass through this area.","Discussion","I'm an Adventurer seeking answers.","I'm trying to find a place to stay...","I Don't really know what I am doing, roaming free I guess...")
						if("I'm an Adventurer seeking answers.")
							alert("Well isn't that great, just keep out of my things! Darn adventurer's seem to always take whatever they want, oh well...you also lower the local monster population as well so that is one good thing about the lot of ya.","Discussion","Indeed.")
						if("I'm trying to find a place to stay...")
							alert("Try the Inn, of course, you could always build your own home but it takes a highly skilled Builder to do such a thing.","Discussion","Ahh, I see ~ Where is the Inn?")
							if("Ahh, I see ~ Where is the Inn?")
								alert("Exit the Building and go down the street and to the left all the way to the end, you should find the Inn with comfortable affordable rooms at the lower left corner of the city!","Discussion","Alright, Thanks.")
						if("I Don't really know what I am doing, roaming free I guess...")
							alert("Ah well that is interesting, roaming free can indeed be a wonderful journey to no certain destination but it is also somewhat dangerous, make sure to keep stocked up on supplies or be a really good survivalist and you should have no issues.","Discussion","Oh, Okay; Thanks.")
					if("Drop any weapons and give me all your stuff!.")
						alert("Really, You're going to try and rob me in my own home? Petty Thief!","Discussion","Yeah that's right, hand it over!","Ahh, nah I was just joking!")
						if("Yeah that's right, hand it over!")
							alert("You couldn't take it from me if you tried, Begone! There is nothing for you here.","Discussion","Hmfp!")
						if("Ahh, nah I was just joking!")
							alert("Yeah that's right, back down and get out of here before you get hurt! I don't have anything here anyway, just some of my old rusty equipment that is too brittle to serve any purpose that you seek..","Discussion","Ah well, Guess i'm wasting my time.")
	BeliefNPCS
		layer = 3
		plane = 3
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
				if (!(src in range(1, usr))) return
				var/K = (input("So you've made it this far, be wary about going further unless prepared...You won't be able to return!","Discuss") in list("Huh, What do you mean?","Why?","Interesting..."))
				switch(K)
					if("Huh, What do you mean?")
						alert("Well, at a certain point, to the west, there are holes that you can fall into and you cannot climb out of them.","Discuss","Good to know.","So I can't climb out, what's on the other side?")
						//if("Alright, Thanks.")
							//return
						if("So I can't climb out, what's on the other side?")
							alert("I'm a foreigner here so I don't really know, I haven't ventured that far yet; but I have heard rumors that certain folk have been cast away via those holes; Nobody will say what is on the other side.")
					if("Why?")
						alert("Just a guess but you probably aren't prepared well enough to venture past this point, but that isn't anything that cannot be remedied.","Discuss","Well you're wrong! I can handle anything!")
						if("Well you're wrong! I can handle anything!")
							alert("All the youth think that at first, Ten Feet Tall and Bullet Proof; But reality soon sets in, plans do not go as planned and provisions are never enough.","Discuss","I see.","Indeed...")
							if("I see.")
								alert("You will soon enough.")
					if("Interesting...")
						alert("Better shift your interest into training and aquiring what you need to survive.","Discuss","I guess so.","I want to do other things.")
						if("I want to do other things.")
							alert("Then you better turn back and stick around the Forests where you can somewhat live, although you cannot build anything.","Discuss","Right!")
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
		Explorer
			name = "Explorer"
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
				var/K = (input("I've been far and wide...I suggest you take your time, if you rush through your efforts with haste you end up cast asunder.","Discuss") in list("What?","Things change!"))
				switch(K)
					if("What?")
						alert("If you try to hurry through what you do you will forget something along the way and end up too weak or unprepared to survive.","Discuss","Makes sense.","So you think I'm weak?")
						//if("Alright, Thanks.")
							//return
						if("So you think I'm weak?")
							alert("No, but at a certain point if you get too far ahead of yourself you will be, is what I am saying.")
					if("Things change!")
						alert("Or do you mean that you want things to change? The basic fundamentals of life do not change so much, they may vary, but they generally remain the same.","Discuss","Ahh, hmm...","Sorry...I have to disagree")
						if("Sorry...I have to disagree")
							alert("That is fine, it is just your Rebel spirit fighting to survive; Just realize this, Life is Harsh and cities offer protection that enables Weakness.","Discuss","Right!")
		Traveler
			name = "Traveler"
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
				var/K = (input("I go back and forth between these two principalities, trading and offering my services","Discuss") in list("What do you do?","Why do I care?"))
				switch(K)
					if("What do you do?")
						alert("I fill various needs, finding wild goods and bringing them to merchants.","Discuss","Okay?","Give me an example?")
						//if("Alright, Thanks.")
							//return
						if("Give me an example?")
							alert("An example? I've carved planks for house building, cut stone for walls, gathered food and spice; I've also distributed random goods like Hand Made Blankets to the masses, there are only so many colors though.")
					if("Why do I care?")
						alert("You're the one talking to me.","Discuss","Ah, right.")
		Scribe
			name = "Scribe"
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
				var/K = (input("I'm very busy, what do you want?","Discuss") in list("Oh, what are you up to?","Ah sorry, I'll leave you alone."))
				switch(K)
					if("Oh, what are you up to?")
						alert("I'm a Scribe, I write down records of Higher Court affairs or anywhere I am hired to do so.","Discuss","Oh, I see.","Sounds Boring.")
						//if("Alright, Thanks.")
							//return
						if("Sounds Boring.")
							alert("Not when you have access to special information.")
		Proctor
			name = "Proctor"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "proct"
			//var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Hello and welcome to The Principality of Belief.","Welcome") in list("What do you do?","Can you help me?","Seems like an okay place..."))
				switch(K)
					if("What do you do?")
						alert("I teach new comers basic abilities to help them on their journey.","Discuss","Okay?","Sounds good to me!")
					if("Can you help me?")
						alert("You'll want to train your abilities and practice your movements if you want to make it any further, I am unable to tell you what is beyond this point but you must be prepared for it none the less.","Discuss","Beyond this point?")
						if("Beyond this point?")
							alert("Yes, at a certain point you will be unable to return and there are things that lie beyond that point that we cannot discuss.","Discuss","Why?")
							if("Why?")
								alert("That is for me to know and you to find out, because once you do, you may never return.")
					if("Seems like an okay place...")
						alert("As long as you keep your foreign nose out of our business we do not mind you being here, but we Believe Everyone to be Suspicious.","Discuss","I suppose I will find out soon enough...")
	PrideNPCS
		layer = 3
		plane = 3
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
				if (!(src in range(1, usr))) return
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
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Oh, Huh...What?","Discuss") in list("What do you do?","Who are you?"))
				switch(K)
					if("What do you do?")
						alert("I'm an artisan, I create various things for distribution.","Discuss","Oh, Okay.")
						//if("Alright, Thanks.")
							//return
					if("Who are you?")
						alert("Why does that matter? All you need to know is that I'm an artisan and I create various goods for people.","Discuss","Okay..fine.")
		Craftsman
			name = "Craftsman"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "vw1"
			var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Huh. I'm busy ~ do you need something?","Discuss") in list("Uhh, no?","What's up?"))
				switch(K)
					if("Uhh, no?")
						alert("Well if you need anything, you might as well realize that it is best to do it yourself.","Discuss","Indeed, I can agree with that.")
						//if("Alright, Thanks.")
							//return
					if("What's up?")
						alert("Nothing, busy working, as always.","Discuss","Ah, I see.")
		Builder
			name = "Builder"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "va1"
			var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("I'm responsible for all these buildings you see.","Discuss") in list("Really?","Oh yeah, why?"))
				switch(K)
					if("really?")
						alert("I'm a builder, I designed these houses to be warm and efficient; that is why they are all the same size.","Discuss","Oh, makes sense.")
						//if("Alright, Thanks.")
							//return
					if("Oh yeah, why?")
						alert("I built them all, they are designed so that they can remain warm; Their size is what makes this possible and they must be maintained.","Discuss","Ahhh, I see.")
		Lumberjack
			name = "Lumberjack"
			density = 1
			icon = 'dmi/64/npcs.dmi'
			icon_state = "vi1"
			var/Speed = 13
			Click()
				set hidden = 1
				//var/mob/players/M
				set src in oview(1)
				//M = usr
				if (!(src in range(1, usr))) return
				var/K = (input("Hmmm?","Discuss") in list("How's it going?","What are you up to?"))
				switch(K)
					if("How's it going?")
						alert("Good, I suppose ~ just taking an extended break before I get back to gathering dead wood for the towns fires, gotta keep warm!","Discuss","Oh, I see.")
						//if("Alright, Thanks.")
							//return
					if("What are you up to?")
						alert("Relaxing before I have to go out and gather more wood, I'm a Lumberjack, gotta keep these houses warm in this climate!","Discuss","Yes, indeed.")
	HonorNPCS
		layer = 3
		plane = 3
		Elder
			name = "Elder"
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
				var/K = (input("Ahh, a young survivor...","Discuss") in list("Survivor?","Young?"))
				switch(K)
					if("Survivor?")
						alert("Yes, you are a survivor are you not? You've made it this far and I've seen many days pass where not a single soul has arrived to these steps.","Discuss","Well, I suppose I am then.")
						//if("Alright, Thanks.")
							//return
					if("Young?")
						alert("Yes, compared to me you are young as I am an Elder, but it is not an insult; rather just a compliment or even envy of your remaining days over mine.","Discuss","Wise words, Elder.")

		Veteran
			name = "Veteran"
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
				var/K = (input("What do you want?","Discuss") in list("Why so rough?","What do you mean?"))
				switch(K)
					if("Why so rough?")
						alert("I'm an old Veteran, what do you expect from me; The things I've seen would drive any ordinary person into madness.","Discuss","Oh, sorry; Guess i'll leave you be.")
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