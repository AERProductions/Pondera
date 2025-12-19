

obj
	IG//jam pack this baby full of ALL of the info of the game. And I mean ALL of it. Well, as much info as a player needs to be able to seek more on their own.
		name = "Instinctual Guide"//The name of your guide
		var/description = "A beginners guide that explores your instinctual behaviours..."//A brief description to help the player understand what this is for
		icon = 'tut.dmi'//the icon file
		icon_state = "tut"//the closed book icon state (tutu is open)
		Click()//when the user clicks on this object's icon in inventory>usr cotents
			//set hidden = 1
			set popup_menu = 1//provide a popup menu for this object in the inventory
			set category = "Inventory"//category declaration
			set src in usr//this object is in the usr contents
			var/mob/M
			M = usr
			M.tutopen=1//they have clicked so this book is open
			if(M.tutopen==1)//if it is open, set the icon state
				src:icon_state = "tutu"//open book icon state
			else while(M.tutopen==1)//else while this is open, if it becomes closed, change icon state to closed.
				if(M.tutopen==0)
					src:icon_state = "tut"

			START
			switch(input("Journal of Information","Instinctual Guide") in list("Tutorial","Basics","Knowledge Base","Close"))
				if("Close")
					M.tutopen=0
					if(M.tutopen==0)
						src:icon_state = "tut"
					sleep(1)
					M << "<font color=#FFFB98>You close the guide for now..."
					return
				if("Tutorial")
					M.tutopen=1
					switch(input("Which Topic?","Select Tutorial Topic") in list("Example Tutorial Option","Close","Back"))//You can add more listings by adding a new item in the list with ,"Your New Item"
						if("Close")
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							M << "<font color=#FFFB98>You close the guide for now..."
							return
						if("Back") goto START
						if("Example Tutorial Option")
							//alert
							M << {"<font color=#FFFB98><center>Basic Info: \  <IMG CLASS=bigicon SRC=\ref'tut.dmi' ICONSTATE='tutu'>Tutorial Guide (add your own information listings with graphics for easy learning recognition)"}//this is how you can add icons for anything you want to show in the guide
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
				if("Basics")
					M.tutopen=1
					switch(input("Which Topic?","Select Basics Topic") in list("The Basics","Close","Back"))//You can add more listings by adding a new item in the list with ,"Your New Item"
						if("Close")
							M.tutopen=0
							if(M.tutopen==0)
								src:icon_state = "tut"
							sleep(1)
							M << "<font color=#FFFB98>You close the guide for now..."
							return
						if("Back") goto START
						if("The Basics")
							//alert
							M << {"<font color=#FFFB98><center>Basic Info: \  <IMG CLASS=bigicon SRC=\ref'tut.dmi' ICONSTATE='tutu'>Tutorial Guide (add your own information listings with graphics for easy learning recognition)"}//this is how you can add icons for anything you want to show in the guide
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
									switch(input("Which Topic?","Select Equipment Topic") in list("Example Tool","Close","Back"))//Add whatever info you want
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto EQUIPMENT
										if("Example Tool")
											//alert
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'tut.dmi' ICONSTATE='tutu'>Tutorial Guide (add your own information listings with graphics for easy learning recognition)"}//this is how you can add icons for anything you want to show in the guide
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
								if("Weapon")
									M << {"Current equipment database unknown"}//Change to match the example tool or allow players to discover new information to add to it and keep it unknown until they do (discovering functionality not provided by this library)
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
									switch(input("Which Topic?","Select Terranology Topic") in list("Temperate","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto BIOME
										if("Temperate")
											M << {"<font color=#FFFB98><center>Basic Terrain: \  <IMG CLASS=bigicon SRC=\ref'tut.dmi' ICONSTATE='tutu'>Tutorial Guide (add your own information listings with graphics for easy learning recognition)"}//this is how you can add icons for anything you want to show in the guide
//Examples, fill with the info you want or remove entirely || change the icons to the dmi and iconstate for the subject you want the information to represent
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
								if("Geology")
									M.tutopen=1
									switch(input("Which Topic?","Select Geology Topic") in list("Stone","Close","Back"))
										if("Close")
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											M << "<font color=#FFFB98>You close the guide for now..."
											return
										if("Back") goto BIOME
										if("Stone")
											M << {"<font color=#FFFB98><center>Basic equipment: \  <IMG CLASS=bigicon SRC=\ref'tut.dmi' ICONSTATE='tutu'>Tutorial Guide (add your own information listings with graphics for easy learning recognition)"}//this is how you can add icons for anything you want to show in the guide
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
											M << {"Current biology database unknown"}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Bush")
											M << {"Current biology database unknown"}
											M.tutopen=0
											if(M.tutopen==0)
												src:icon_state = "tut"
											sleep(1)
											return
										if("Foliage")
											M << {"Current biology database unknown"}
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
									M << {"Current biology database unknown"}
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
