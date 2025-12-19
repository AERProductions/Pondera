obj
	permit
		icon = 'dmi/64/blank.dmi'


	//Enter(turf/a/nobuild/O)
		//only allow entrance if weight is within the limit
		//if(M.canbuild=1)
			//return ..()

var
	// M_UED tracking moved to character datum (modern system)
	//smelt[1]
	build[1]	//build selection menu
	L
	L0[1]	//fort mat type
	L1[1]	//wood fort section
	L2[1]	//stone fort section
	L3[1]	//house mat type
	L4[1]	//misc
	L5[1]	//furnishings
	L6[1]	//woodhouse
	L7[1]	//stonehouse
	L8[1]	//wood fort interior
	L9[1]	//stone fort interior
	L10[1]	//lampost types
	//L11[1]	//stone fort door
	/*bf[1]
	bfw[1]
	bfs[1]
	bht[1]
	bh[1]
	bhw[1]
	bfurn[1]
	bmisc[1]*/
	dig[1]
	logs = 0
mob/players
	verb
		Dig()
			set hidden = 1
			var/mob/players/M
			var/obj/DeedToken/dt
			M = usr
			//var/M.UED = 0
			//var/L[1]
			//var/X = /obj/permit
			//L = dig
			L = digunlock(arglist(dig))
			//usr << "test1"
			//var/obj/DeedToken/dt//remove this section---------------
			dt = locate(oview(src,15))
			for(dt)
				if(M.canbuild==0)
					//goto NEXT
				//else
					M << "You do not have permission to build"
					return

			if(!dt)
			//NEXT//to disable deeds----------------------------------
				if(M.stamina==0)		//Is your stamina to low???
					M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
					return
				if(M.UED == 1)
					M<<"You're too busy to do anything else!"
					return

				/*if(src.loc == oview(/obj/a/nobuild))
					M<<"You are in or near a No-Build area."
					return*/
				/*if(X in M.contents != 1)
					M<<"Must purchase a permit to be able to modify maps."
					return*/
				else
					if(M.SHequipped!=1)
						M<<"Need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Shovel'>Shovel to Dig."
						return
					else
						if(M.SHequipped==1)
							//M.UED = 1
							//usr << "test2"
							var/a
							M.UED = 1
							DIG
							switch(input("Dig?","Dig") as anything in dig) // in list("Dirt Road","Dirt Road Corner","Water")
								if("Cancel")
									M<<"You Cancel Selection..."
									M.UED = 0
									M.UED = 0
									return
								if("Dirt Road")
									//M.UED = 1
									//DIRTROAD
									switch(input("Which direction?","Dirt Road")in list("North/South","East/West","3-way North","Cancel","Back"))//,"3-way North"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("North/South")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/NSRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("East/West")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/EWRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("3-way North")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/R3WNRoad(usr.loc)  //Need to add more of these?
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								if("Dirt Road Corner")
									switch(input("Which direction?","Dirt Road")in list("NorthWest Corner","NorthEast Corner","SouthWest Corner","SouthEast Corner","Cancel","Back"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("NorthWest Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/NWCRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("NorthEast Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/NECRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("SouthWest Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/SWCRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("SouthEast Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/DirtRoad/SECRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								//								if("Wood Road")
									//M.UED = 1
									switch(input("Which direction?","Dirt Road")in list("North/South","East/West","3-way North","Cancel","Back"))//,"3-way North"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("North/South")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WRNSRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("East/West")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WREWRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("3-way North")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WR3WNRoad(usr.loc)  //Need to add more of these?
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								if("Wood Road Corner")
									switch(input("Which direction?","Dirt Road")in list("NorthWest Corner","NorthEast Corner","SouthWest Corner","SouthEast Corner","Cancel","Back"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("NorthWest Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WRNWCRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("NorthEast Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WRNECRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("SouthWest Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WRSWCRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("SouthEast Corner")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												a = new/obj/Landscaping/Road/WoodRoad/WRSECRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								if("Brick Road")
									switch(input("Which direction?","Brick Road")in list("North/South","East/West","Cancel","Back"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("North/South")
											var/obj/items/Crafting/Created/Bricks/S = locate() in M.contents
											if(M.SHequipped==1)
												for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Road/StoneRoad/SNSRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("East/West")
											var/obj/items/Crafting/Created/Bricks/S = locate() in M.contents
											if(M.SHequipped==1)
												for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Road/StoneRoad/SEWRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								//								if("Brick Road Corner")
									switch(input("Which direction?","Brick Road")in list("NorthWest Corner","NorthEast Corner","SouthWest Corner","SouthEast Corner","Cancel","Back"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("NorthWest Corner")
											var/obj/items/Crafting/Created/Bricks/S = locate() in M.contents
											if(M.SHequipped==1)
												for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Road/StoneRoad/SNWCRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("NorthEast Corner")
											var/obj/items/Crafting/Created/Bricks/S = locate() in M.contents
											if(M.SHequipped==1)
												for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Road/StoneRoad/SNECRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("SouthWest Corner")
											var/obj/items/Crafting/Created/Bricks/S = locate() in M.contents
											if(M.SHequipped==1)
												for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Road/StoneRoad/SSWCRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("SouthEast Corner")
											var/obj/items/Crafting/Created/Bricks/S = locate() in M.contents
											if(M.SHequipped==1)
												for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Road/StoneRoad/SSECRoad(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 15)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								//								if("Ditch")
									switch(input("Which direction?","Ditch")in list("Slope(NORTH)","Slope(SOUTH)","Slope(EAST)","Slope(WEST)","Corner(NORTHEAST)","Corner(NORTHWEST)","Corner(SOUTHEAST)","Corner(SOUTHWEST)","Exit Slope(NORTH)","Exit Slope(SOUTH)","Exit Slope(EAST)","Exit Slope(WEST)","Ditch(NORTH/SOUTH)","Ditch(EAST/WEST)","Cancel","Back"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("Slope(NORTH)")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSN(usr.loc)
												//new a(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												//a:dir = NORTH
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope(SOUTH)")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSS(usr.loc)
												//new a(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope(EAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope(WEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Corner(NORTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchCNE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = NORTHEAST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Corner(NORTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchCNW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Corner(SOUTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchCSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Corner(SOUTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchCSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Turn(NORTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSNEC(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = NORTHEAST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Turn(NORTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSNWC(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Turn(SOUTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSSEC(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Turn(SOUTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchSSWC(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Exit Slope(NORTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchEXN(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = NORTH
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Exit Slope(SOUTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchEXS(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												//a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Exit Slope(EAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchEXE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Exit Slope(WEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchEXW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.5
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Ditch(NORTH/SOUTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchPCNS(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Ditch(EAST/WEST)")
											////var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Ditch/ditchPCWE(usr.loc)
												//new a(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 0.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 20)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								//								if("Hill")
									switch(input("Which direction?","Hill")in list("Cancel","Slope(NORTH)","Slope(SOUTH)","Slope(EAST)","Slope(WEST)","Slope Corner(NORTHEAST)","Slope Corner(NORTHWEST)","Slope Corner(SOUTHEAST)","Slope Corner(SOUTHWEST)","Cliff(NORTH)","Cliff(SOUTH)","Cliff(EAST)","Cliff(WEST)","Cliff Corner(NORTHEAST)","Cliff Corner(NORTHWEST)","Cliff Corner(SOUTHEAST)","Cliff Corner(SOUTHWEST)","Hill-Top(CENTER)","Hill-Top(NORTH)","Hill-Top(SOUTH)","Hill-Top(EAST)","Hill-Top(WEST)","Hill-Top Corner(NORTHEAST)","Hill-Top Corner(NORTHWEST)","Hill-Top Corner(SOUTHEAST)","Hill-Top Corner(SOUTHWEST)","Hill-Top Turn(NORTHEAST)","Hill-Top Turn(NORTHWEST)","Hill-Top Turn(SOUTHEAST)","Hill-Top Turn(SOUTHWEST)"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										if("Slope(NORTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSN(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = NORTH
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope(SOUTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSS(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope(EAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope(WEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope Corner(NORTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSCNE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = NORTHEAST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope Corner(NORTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSCNW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope Corner(SOUTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSCSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Slope Corner(SOUTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillSCSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 1.5
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff(NORTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCN(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = NORTH
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff(SOUTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCS(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff(EAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff(WEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff Corner(NORTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCNE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = NORTHEAST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff Corner(NORTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCNW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = SOUTH
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff Corner(SOUTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = EAST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Cliff Corner(SOUTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillCSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = WEST
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 25
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top(CENTER)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPC(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top(NORTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPN(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top(SOUTH)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPS(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top(EAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top(WEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Corner(NORTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPCNE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Corner(NORTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPCNW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Corner(SOUTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPCSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Corner(SOUTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillPCSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Turn(NORTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillTNE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Turn(NORTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillTNW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Turn(SOUTHEAST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillTSE(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Hill-Top Turn(SOUTHWEST)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/obj/Landscaping/Hill/hillTSW(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												a:elevel = 2.0
												a:dir = null
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 10
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								//								if("Water")
									switch(input("Which direction?","Water")in list("Single Tile(Borders)","Single Tile(No Borders)","Central 4-way","North","South","East","West","Cancel","Back"))
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UED = 0
											return
										if("Back") goto DIG
										/* if("Water Level")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												var/obj/items/tools/Jar/J = locate() in M.contents
												for(J.filled==1)
													J.overlays -= /obj/liquid
													J:name="Jar"
												//else
												//	M<<"Need to have a Filled Jar to continue."
												a = new/turf/Ground/water2B(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 5
												M.updateST()
												M.updateDXP()

												a = new/turf/Water(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
											*/
											//M<<"You use the water in the jar to fill the hole in the ground."
											//a = new/turf/water2B(usr.loc)
											//a:buildingowner = ckeyEx("[usr.key]")
											//M.character.UpdateRankExp(RANK_DIGGING, 25)
										if("Border (West)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord1(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border (North)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord2(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border (East)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord3(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border (South)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord4(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border Corner (South West)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord5(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border Corner (North West)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord6(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border Corner (North East)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord7(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
										if("Border Corner (South East)")
											//var/obj/items/tools/Shovel/S = locate() in M.contents
											if(M.SHequipped==1)
												//for(S in M.contents) S.RemoveFromStack(6)
												a = new/turf/pbords/pbord8(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												M.character.UpdateRankExp(RANK_DIGGING, 25)
												M.stamina -= 15
												M.updateST()
												M.updateDXP()
												M.UED = 0
												M.UED = 0
								if("Dirt")
									M.character.UpdateRankExp(RANK_DIGGING, 5)
									a = new/obj/Landscaping/Dirt(usr.loc)
									a:buildingowner = ckeyEx("[usr.key]")
									//WTOSL += a
									M.stamina -= 5
									M.updateST()
									M.updateDXP()
									M.UED = 0
									//diglevel(M)
									M.UED = 0
								if("Grass")
									M.character.UpdateRankExp(RANK_DIGGING, 10)
									a = new/turf/Grass(usr.loc)
									a:buildingowner = ckeyEx("[usr.key]")
									M.stamina -= 10
									M.updateST()
									M.updateDXP()
									M.UED = 0
									M.UED = 0
								if("Lava")
									M.character.UpdateRankExp(RANK_DIGGING, 50)
									a = new/turf/lava(usr.loc)
									a:buildingowner = ckeyEx("[usr.key]")
									M.stamina -= 50
									M.updateST()
									M.updateDXP()
									M.UED = 0
									M.UED = 0
								/*if("Water")
									M.character.UpdateRankExp(RANK_BUILDING, 5)
									a = new/turf/Ground/water2(usr.loc)
									a:buildingowner = ckeyEx("[usr.key]")
									M.stamina -= 5
									M.updateST()
									M.updateDXP()*/
									//							//							return


/*proc
	selection()
		//var/mob/players/M
		if(Selection == 1)
			//Busing = 0
			//
			return
		else return*/
//var/
//var/Busing = 0
mob/players
	proc/FindJar(mob/players/M)
		for(var/obj/items/tools/Containers/Jar/J in M.contents)
			if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&J.CType=="Water")
				return J
			else
				//M << "Need to hold a Filled Jar."
				return
	verb
		Build()//buildlabel
			set hidden = 1
			//L11 = buildlevel(arglist(L11))
			//var/mob/players/UEB = 0
			var/mob/players/M
			var/obj/DeedToken/dt

			M = usr

			build = buildunlock(arglist(build))
			L0 = buildunlock(arglist(L0))
			L1 = buildunlock(arglist(L1))
			L2 = buildunlock(arglist(L2))
			L3 = buildunlock(arglist(L3))
			L4 = buildunlock(arglist(L4))
			L5 = buildunlock(arglist(L5))
			L6 = buildunlock(arglist(L6))
			L7 = buildunlock(arglist(L7))
			L8 = buildunlock(arglist(L8))
			L9 = buildunlock(arglist(L9))
			L10 = buildunlock(arglist(L10))
			//// REMOVED: buildlevel() proc call - building XP now handled automatically
			//var/X = /obj/permit
	//L0//fort mat type
	//L1[1]	/wood fort section
	//L2[1]	/stone fort section
	//L3[1]	/house mat type
	//L4[1]	/misc
	//L5[1]	/furnishings
	//L6[1]	/woodhouse
	//L7[1]	/stonehouse
	//L8[1]	/wood fort interior
	//L9[1]	/stone fort interior
	//L10[1]	/lampost types
			//if(Busing == 1)
			//	return null
			//	del src
			//if(null)
				//M << "You have yet to understand this category (Building Acuity: [M.brank])..."
				//return
			//var/obj/DeedToken/dt//remove this section---------------
			dt = locate(oview(src,15))
			if(dt)
				for(dt)
					if(M.canbuild==0)
						//goto NEXT
					//else
						M << "You do not have permission to build"
						return
			else if(!dt)
			//NEXT//to disable deeds----------------------------------
				if(M.stamina<=0)//Is your stamina to low or negative???
					M<<"You're too tired to do anything! Drink some \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='FilledJar'>Water."
					M.stamina=0
					return
				/*if(src.loc == locate(x,y,2))
					M<<"Can only build in Local Regions."
					return*/
				/*if(X in M.contents != 1)
					M<<"Must purchase a permit to be able to modify maps."
					return*/
				else
					if(M.HMequipped!=1)
						M<<"Need to hold the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='Hammer'>Hammer to build."
						return
					else
	//begin build menu
						if(M.HMequipped==1)
							//var/UEB = 0 //unequipblock if building activated later bitflag 1 (not if hammer equipped)
							var/a
							//var/obj/items/Logs/UeikLog/J = locate() in M.contents
							//// REMOVED: buildlevel() proc call - building XP now handled automatically
							//locate(J) in M.contents
	//build selection													//Build list holds main building menu selections
							//var/b =
							if((M.brank<=0))
								M << "You try to understand how to apply the materials, but you need to know more about building. (Building Acuity:[M.brank])..."
								return 0
							else
								M.UEB = 1
								BUILD
								switch(input("Select your creation","Building") as anything in build)//"Fort","House","Furnishings","Miscellaneous") build=build selection L0=fort material type L1=wood fort wall type L2 = stone fort wall type L3 =house material type L4 = miscellaneous L5=furnishings L6=woodhouse build selection type Fort
									if("Cancel")
										M<<"You Cancel Selection..."
										M.UED = 0
										M.UEB = 0
										return
									if("Fire")
										var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
										//var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
										//var/Head = "1 Wooden Torch Head" //Building Material Type Created/IronLampHead
										var/Wood = "1 Kindling"
										if((J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 5))
											for(J in M.contents) J.RemoveFromStack(1)
											//for(J2 in M.contents) J2.RemoveFromStack(1)
											if(M.stamina >= 5)//content
												M.stamina -= 5
												M.updateST()
												M.character.UpdateRankExp(RANK_BUILDING, 5)
												a = new/obj/Buildable/Fire(usr.loc)
												a:buildingowner = ckeyEx("[usr.key]")
												//a:layer = MOB_LAYER+1
												//a:dir = NORTH
												//// REMOVED: buildlevel() proc call - building XP now handled automatically
												M.UEB = 0
												// REMOVED: buildlevel() proc call - building XP now handled automatically
											else
												M.UEB = 0
												M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
												return
										else
											M.UEB = 0
											M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
											return
									if("Furnishings") switch(input("Select Furnishing","Furnishings") as anything in L5) //L5
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UEB = 0
											return
										if("Back") goto BUILD
										if("Table")
											var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
											var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
											var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
											var/Nail = "2 Handfuls of Iron Nails" //Building Material Type
											var/Wood = "4 Poles"
											var/Board = "3 Ueik Boards"
											if((J in M.contents)&&(J1 in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 4)&&(J2.stack_amount >= 3)&&(M.stamina >= 35))
												for(J in M.contents) J.RemoveFromStack(2)
												for(J1 in M.contents) J1.RemoveFromStack(4)
												for(J2 in M.contents) J2.RemoveFromStack(3)
												if(M.stamina >= 35)//content
													M.stamina -= 35
													M.updateST()
													M.character.UpdateRankExp(RANK_BUILDING, 25)
													a = new/obj/Buildable/Furnishings/Table(usr.loc)
													a:buildingowner = ckeyEx("[usr.key]")
													M.UEB = 0
													// REMOVED: buildlevel() proc call - building XP now handled automatically
												else
													M.UEB = 0
													M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
													return
											else
												M.UEB = 0
												M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood], [Board] and [Nail])"
												return
										if("Bed") switch(input("Select Bed Placement Direction (N^,Sv,E>,W<)","Bed Placement Direction")in list("North","South","East","West"))
											if("North")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Wood = "8 Poles"
												var/Board = "4 Ueik Board"
												if((J in M.contents)&&(J1 in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 8)&&(J2.stack_amount >= 4)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J1 in M.contents) J1.RemoveFromStack(8)
													for(J2 in M.contents) J2.RemoveFromStack(4)
													//for(J3 in M.contents) J3.RemoveFromStack(1)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Furnishings/bed(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Board], [Wood] and [Nails])"
													return
											if("South")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Wood = "8 Poles"
												var/Board = "4 Ueik Board"
												if((J in M.contents)&&(J1 in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 8)&&(J2.stack_amount >= 4)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J1 in M.contents) J1.RemoveFromStack(8)
													for(J2 in M.contents) J2.RemoveFromStack(4)
													//for(J3 in M.contents) J3.RemoveFromStack(1)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Furnishings/beds(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Board], [Wood] and [Nails])"
													return
											if("East")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Wood = "8 Poles"
												var/Board = "4 Ueik Board"
												if((J in M.contents)&&(J1 in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 8)&&(J2.stack_amount >= 4)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J1 in M.contents) J1.RemoveFromStack(8)
													for(J2 in M.contents) J2.RemoveFromStack(4)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Furnishings/bede(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Board], [Wood] and [Nails])"
													return
											if("West")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Wood = "8 Poles"
												var/Board = "4 Ueik Board"
												if((J in M.contents)&&(J1 in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 8)&&(J2.stack_amount >= 4)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J1 in M.contents) J1.RemoveFromStack(8)
													for(J2 in M.contents) J2.RemoveFromStack(4)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Furnishings/bedw(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Board], [Wood] and [Nails])"
													return
										if("Chair") switch(input("Select Chair Placement Direction (N^,Sv,E>,W<)","Chair Placement Direction")in list("North","South","East","West"))
											if("North")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Board = "2 Ueik Board"
												var/Wood = "8 Poles"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 8)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J2 in M.contents) J2.RemoveFromStack(2)
													for(J3 in M.contents) J3.RemoveFromStack(8)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Furnishings/Chairn(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														//a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Wood] and [Board])"
													return
											if("South")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Board = "2 Ueik Board"
												var/Wood = "8 Poles"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 8)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J2 in M.contents) J2.RemoveFromStack(2)
													for(J3 in M.contents) J3.RemoveFromStack(8)
													//for(J3 in M.contents) J3.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Furnishings/Chairs(usr.loc)
														a = new/obj/Buildable/Furnishings/Chairst(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														//a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Wood] and [Board])"
													return
											if("East")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Board = "2 Ueik Board"
												var/Wood = "8 Poles"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 8)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J2 in M.contents) J2.RemoveFromStack(2)
													for(J3 in M.contents) J3.RemoveFromStack(8)
													//for(J3 in M.contents) J3.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Furnishings/Chairr(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														//a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Wood] and [Board])"
													return
											if("West")
												var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
												var/Nails = "2 Handfuls of Iron Nails" //Building Material Type
												var/Board = "2 Ueik Board"
												var/Wood = "8 Poles"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 8)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(2)
													for(J2 in M.contents) J2.RemoveFromStack(2)
													for(J3 in M.contents) J3.RemoveFromStack(8)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Furnishings/Chairl(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														//a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Wood] and [Board])"
													return
										if("Log Storage")
											//var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
											var/obj/items/Crafting/Created/Pole/J = locate() in M.contents
											//var/Head = "1 Wooden Torch Head" //Building Material Type Created/IronLampHead
											var/Wood = "10 Planks"
											if((J in M.contents)&&(J.stack_amount >= 10)&&(M.stamina >= 25))
												for(J in M.contents) J.RemoveFromStack(10)
												//for(J2 in M.contents) J2.RemoveFromStack(1)
												if(M.stamina >= 25)//content
													M.stamina -= 25
													M.updateST()
													M.character.UpdateRankExp(RANK_BUILDING, 15)
													a = new/obj/Buildable/Containers/ContainerL(usr.loc)
													a:color = rgb(rand(0,255),rand(0,255),rand(0,255))
													a:buildingowner = ckeyEx("[usr.key]")
													//a:layer = MOB_LAYER+1
													//a:dir = NORTH
													//// REMOVED: buildlevel() proc call - building XP now handled automatically
													M.UEB = 0
													// REMOVED: buildlevel() proc call - building XP now handled automatically
												else
													M.UEB = 0
													M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
													return
											else
												M.UEB = 0
												M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
												return
										if("Food Container")
											//var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
											var/obj/items/Crafting/Created/Pole/J = locate() in M.contents
											//var/Head = "1 Wooden Torch Head" //Building Material Type Created/IronLampHead
											var/Wood = "10 Planks"
											if((J in M.contents)&&(J.stack_amount >= 10)&&(M.stamina >= 25))
												for(J in M.contents) J.RemoveFromStack(10)
												//for(J2 in M.contents) J2.RemoveFromStack(1)
												if(M.stamina >= 25)//content
													M.stamina -= 25
													M.updateST()
													M.character.UpdateRankExp(RANK_BUILDING, 15)
													a = new/obj/Buildable/Containers/ContainerF(usr.loc)
													a:color = rgb(rand(0,255),rand(0,255),rand(0,255))
													a:buildingowner = ckeyEx("[usr.key]")
													//a:layer = MOB_LAYER+1
													//a:dir = NORTH
													//// REMOVED: buildlevel() proc call - building XP now handled automatically
													M.UEB = 0
													// REMOVED: buildlevel() proc call - building XP now handled automatically
												else
													M.UEB = 0
													M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
													return
											else
												M.UEB = 0
												M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
												return
										if("Ore Chest")
											//var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
											var/obj/items/Crafting/Created/Pole/J = locate() in M.contents
											//var/Head = "1 Wooden Torch Head" //Building Material Type Created/IronLampHead
											var/Wood = "10 Planks"
											if((J in M.contents)&&(J.stack_amount >= 10)&&(M.stamina >= 25))
												for(J in M.contents) J.RemoveFromStack(10)
												//for(J2 in M.contents) J2.RemoveFromStack(1)
												if(M.stamina >= 25)//content
													M.stamina -= 25
													M.updateST()
													M.character.UpdateRankExp(RANK_BUILDING, 15)
													a = new/obj/Buildable/Containers/ContainerO(usr.loc)
													a:buildingowner = ckeyEx("[usr.key]")
													//a:layer = MOB_LAYER+1
													//a:dir = NORTH
													//// REMOVED: buildlevel() proc call - building XP now handled automatically
													M.UEB = 0
													// REMOVED: buildlevel() proc call - building XP now handled automatically
												else
													M.UEB = 0
													M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
													return
											else
												M.UEB = 0
												M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
												return
										if("Lampost") switch(input("Select Lampost","Lampost Type")in L10)//list("North","South","East","West"))L10
											if("Wood")
												var/obj/items/Crafting/Created/WoodenTorchHead/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J2 = locate() in M.contents
												var/Head = "1 Wooden Torch Head" //Building Material Type Created/IronLampHead
												var/Wood = "1 Pole"
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 1)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(1)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/items/Buildable/lamps/woodentorch(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Head] and [Wood])"
													return
											if("Iron")
												var/obj/items/Crafting/Created/IronLampHead/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J2 = locate() in M.contents
												var/Head = "1 Iron Lamp Head" //Building Material Type Created/IronLampHead
												var/Wood = "1 Pole"
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 1)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(1)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/items/Buildable/lamps/ironlamp(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Head] and [Wood])"
													return
											if("Copper")
												var/obj/items/Crafting/Created/CopperLampHead/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J2 = locate() in M.contents
												var/Head = "1 Copper Lamp Head" //Building Material Type Created/IronLampHead
												var/Wood = "1 Pole"
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 1)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(1)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/items/Buildable/lamps/copperlamp(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Head] and [Wood])"
													return
											if("Bronze")
												var/obj/items/Crafting/Created/BronzeLampHead/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J2 = locate() in M.contents
												var/Head = "1 Iron Lamp Head" //Building Material Type Created/IronLampHead
												var/Wood = "1 Pole"
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 1)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(1)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/items/Buildable/lamps/bronzelamp(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Head] and [Wood])"
													return
											if("Brass")
												var/obj/items/Crafting/Created/BrassLampHead/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J2 = locate() in M.contents
												var/Head = "1 Brass Lamp Head" //Building Material Type Created/IronLampHead
												var/Wood = "1 Pole"
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 1)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(1)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/items/Buildable/lamps/brasslamp(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Head] and [Wood])"
													return
											if("Steel")
												var/obj/items/Crafting/Created/SteelLampHead/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J2 = locate() in M.contents
												var/Head = "1 Steel Lamp Head" //Building Material Type Created/IronLampHead
												var/Wood = "1 Pole"
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 1)&&(M.stamina >= 25))
													for(J in M.contents) J.RemoveFromStack(1)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/items/Buildable/lamps/steellamp(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Head] and [Wood])"
													return
										//I think the anvil needs to be made in a different way... Okay got it. Smelt an anvil head that you use to build the Anvil.
										if("Anvil") switch(input("Select Anvil Placement Direction (N^,Sv,E>,W<)","Anvil Placement Direction")in list("North","South","East","West"))
											if("North")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Crafting/Created/AnvilHead/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "5 Mortar" //Building Material Type
												var/Ore = "1 Anvil Head"
												var/Wood = "2 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 1)&&(J3.stack_amount >= 2)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(5)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													for(J3 in M.contents) J3.RemoveFromStack(2)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Smithing/Anvil(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1//TestStamp -- Need to test if this works or doesn't work as intended
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Ore] and [Wood])"
													return
											if("South")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Crafting/Created/AnvilHead/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "5 Mortar" //Building Material Type
												var/Ore = "1 Anvil Head"
												var/Wood = "2 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 1)&&(J3.stack_amount >= 2)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(5)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													for(J3 in M.contents) J3.RemoveFromStack(2)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Smithing/Anvil(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														a:dir = SOUTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Ore] and [Wood])"
													return
											if("East")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Crafting/Created/AnvilHead/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "5 Mortar" //Building Material Type
												var/Ore = "1 Anvil Head"
												var/Wood = "2 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 1)&&(J3.stack_amount >= 2)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(5)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													for(J3 in M.contents) J3.RemoveFromStack(2)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Smithing/Anvil(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														a:dir = EAST
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Ore] and [Wood])"
													return
											if("West")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Crafting/Created/AnvilHead/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "5 Mortar" //Building Material Type
												var/Ore = "1 Anvil Head"
												var/Wood = "2 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 1)&&(J3.stack_amount >= 2)&&(M.stamina >= 45))
													for(J in M.contents) J.RemoveFromStack(5)
													for(J2 in M.contents) J2.RemoveFromStack(1)
													for(J3 in M.contents) J3.RemoveFromStack(2)
													if(M.stamina >= 45)//content
														M.stamina -= 45
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Smithing/Anvil(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														a:dir = WEST
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Ore] and [Wood])"
													return
										if("Forge") switch(input("Select Forge Placement Direction (N^,Sv,E>,W<)","Forge Placement Direction")in list("North","South","East","West"))
											if("North")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Ore/stone/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "10 Mortar" //Building Material Type
												var/Stone = "25 Stone ore"
												var/Wood = "4 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 10)&&(J2.stack_amount >= 25)&&(J3.stack_amount >= 4)&&(M.stamina >= 55))
													for(J in M.contents) J.RemoveFromStack(10)
													for(J2 in M.contents) J2.RemoveFromStack(25)
													for(J3 in M.contents) J3.RemoveFromStack(4)
													if(M.stamina >= 55)//content
														M.stamina -= 55
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Smithing/Forge(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														a:layer = MOB_LAYER+1
														a:dir = NORTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Wood])"
													return
											if("South")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Ore/stone/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "10 Mortar" //Building Material Type
												var/Stone = "25 Stone ore"
												var/Wood = "4 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 10)&&(J2.stack_amount >= 25)&&(J3.stack_amount >= 4)&&(M.stamina >= 55))
													for(J in M.contents) J.RemoveFromStack(10)
													for(J2 in M.contents) J2.RemoveFromStack(25)
													for(J3 in M.contents) J3.RemoveFromStack(4)
													if(M.stamina >= 55)//content
														M.stamina -= 55
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Smithing/Forge(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														a:dir = SOUTH
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Wood])"
													return
											if("East")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Ore/stone/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "10 Mortar" //Building Material Type
												var/Stone = "25 Stone ore"
												var/Wood = "4 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 10)&&(J2.stack_amount >= 25)&&(J3.stack_amount >= 4)&&(M.stamina >= 55))
													for(J in M.contents) J.RemoveFromStack(10)
													for(J2 in M.contents) J2.RemoveFromStack(25)
													for(J3 in M.contents) J3.RemoveFromStack(4)
													if(M.stamina >= 55)//content
														M.stamina -= 55
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Smithing/Forge(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														a:dir = EAST
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Wood])"
													return
											if("West")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Ore/stone/J2 = locate() in M.contents
												var/obj/items/Logs/UeikLog/J3 = locate() in M.contents
												var/Mortar = "10 Mortar" //Building Material Type
												var/Stone = "25 Stone ore"
												var/Wood = "4 Ueik Log"
												if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 10)&&(J2.stack_amount >= 25)&&(J3.stack_amount >= 4)&&(M.stamina >= 55))
													for(J in M.contents) J.RemoveFromStack(10)
													for(J2 in M.contents) J2.RemoveFromStack(25)
													for(J3 in M.contents) J3.RemoveFromStack(4)
													if(M.stamina >= 55)//content
														M.stamina -= 55
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Smithing/Forge(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														//a:layer = MOB_LAYER+1
														a:dir = WEST
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Wood])"
													return
									if("Miscellaneous") switch(input("Select Miscellaneous","Miscellaneous") as anything in L4) //L4
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UEB = 0
											return
										if("Back") goto BUILD
										if("Crate") switch(input("Select Crate","Crate size")in list("Small", "Large"))
											if("Small")
												var/obj/items/Crafting/Created/UeikBoard/J = locate() in M.contents
												var/obj/items/Crafting/Created/IronNails/J1 = locate() in M.contents
												var/Wood = "8 Ueik Board" //Building Material Type
												var/Nails = "4 Handfuls of Iron Nails"
												if((J in M.contents)&&(J.stack_amount >= 8)&&(J1 in M.contents)&&(J1.stack_amount >= 4)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(8)
													for(J1 in M.contents) J1.RemoveFromStack(4)
													if(M.stamina >= 15)//content
														M.stamina -= 15
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Furnishings/scrate(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood] and [Nails])"
													return
											if("Large")
												//var/obj/items/Crafting/Created/Pole/J = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J = locate() in M.contents
												var/obj/items/Crafting/Created/IronNails/J1 = locate() in M.contents
												var/Wood = "12 Ueik Board" //Building Material Type
												var/Nails = "8 Handfuls of Iron Nails"
												if((J in M.contents)&&(J.stack_amount >= 12)&&(J1 in M.contents)&&(J1.stack_amount >= 8)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(12)
													for(J1 in M.contents) J1.RemoveFromStack(8)
													if(M.stamina >= 25)//content
														M.stamina -= 25
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 30)
														a = new/obj/Buildable/Furnishings/crate(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood] and [Nails])"
													return
										if("Barricade") switch(input("Select Barricade Direction (N^/Sv,E>/W<)","Miscellaneous")in list("North/South","East/West"))
											if("North/South")
												var/obj/items/Logs/UeikLog/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
												var/obj/items/Crafting/Created/IronNails/J2 = locate() in M.contents
												var/Wood = "4 Ueik Log" //Building Material Type
												var/Pole = "2 Pole"
												var/Nails = "4 Handfuls of Iron Nails"
												if((J in M.contents)&&(J.stack_amount >= 4)&&(J1 in M.contents)&&(J1.stack_amount >= 2)&&(J2 in M.contents)&&(J2.stack_amount >= 4)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(4)
													for(J1 in M.contents) J.RemoveFromStack(2)
													for(J2 in M.contents) J.RemoveFromStack(4)
													if(M.stamina >= 15)//content
														M.stamina -= 15
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Barricades/barricaden(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood], [Pole] and [Nails])"
													return
											if("East/West")
												var/obj/items/Logs/UeikLog/J = locate() in M.contents
												var/obj/items/Crafting/Created/Pole/J1 = locate() in M.contents
												var/obj/items/Crafting/Created/IronNails/J2 = locate() in M.contents
												var/Wood = "4 Ueik Log" //Building Material Type
												var/Pole = "2 Pole"
												var/Nails = "4 Handfuls of Iron Nails"
												if((J in M.contents)&&(J.stack_amount >= 4)&&(J1 in M.contents)&&(J1.stack_amount >= 2)&&(J2 in M.contents)&&(J2.stack_amount >= 4)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(4)
													for(J1 in M.contents) J.RemoveFromStack(2)
													for(J2 in M.contents) J.RemoveFromStack(4)
													if(M.stamina >= 15)//content
														M.stamina -= 15
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 25)
														a = new/obj/Buildable/Barricades/barricades(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood], [Pole], [Nails])"
													return
										if("Sundial")
											var/obj/items/Crafting/Created/UeikBoard/J = locate() in M.contents
											var/obj/items/Crafting/Created/Bricks/J1 = locate() in M.contents
											var/obj/items/Mortar/J2 = locate() in M.contents
											var/Wood = "5 Ueik Board" //Building Material Type
											var/Stone = "15 Piles of Bricks"
											var/Mortar = "15 Mortar"
											if((J in M.contents)&&(J1 in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 5)&&(J1.stack_amount >= 15)&&(J2.stack_amount >= 15)&&(M.stamina >= 35))
												for(J in M.contents) J.RemoveFromStack(5)
												for(J1 in M.contents) J1.RemoveFromStack(15)
												for(J2 in M.contents) J2.RemoveFromStack(15)
												if(M.stamina >= 35)//content
													M.stamina -= 35
													M.updateST()
													M.character.UpdateRankExp(RANK_BUILDING, 25)
													a = new/obj/Buildable/sundial(usr.loc)
													a:buildingowner = ckeyEx("[usr.key]")
													M.UEB = 0
													var/obj/Navi/Compas/C = new;var/obj/Navi/Arrow/A = new
													src.client.screen += C;src.client.screen += A
													M.Target = a
													// REMOVED: buildlevel() proc call - building XP now handled automatically
												else
													M.UEB = 0
													M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
													return
											else
												M.UEB = 0
												M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood], [Mortar] and [Stone])"
												return
										if("Water Fountain")
											//var/obj/items/Logs/UeikLog/J = locate() in M.contents
											var/obj/items/Mortar/J = locate() in M.contents
											var/obj/items/Crafting/Created/Bricks/J1 = locate() in M.contents
											//var/Wood = "1 Ueik Log" //Building Material Type
											var/Mort = "35 Mortar"
											var/Stone = "35 Piles of Bricks"
											if((J in M.contents)&&(J.stack_amount >= 35)&&(J1 in M.contents)&&(J1.stack_amount >= 35)&&(M.stamina >= 65))
												for(J in M.contents) J.RemoveFromStack(35)
												for(J1 in M.contents) J1.RemoveFromStack(35)
												if(M.stamina >= 65)//content
													M.stamina -= 65
													M.updateST()
													M.character.UpdateRankExp(RANK_BUILDING, 35)
													a = new/obj/WaterFountain(usr.loc)
													a:buildingowner = ckeyEx("[usr.key]")
													M.UEB = 0
													// REMOVED: buildlevel() proc call - building XP now handled automatically
												else
													M.UEB = 0
													M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
													return
											else
												M.UEB = 0
												M << "You lack the effort (stamina: [M.stamina]) or the material...([Stone] and [Mort])"
												return
							//house wood v
									if("House") switch(input("Select Material Type","House Materials") as anything in L3) //L3
										if("Cancel")
											M<<"You Cancel Selection..."
											M.UED = 0
											M.UEB = 0
											return
										if("Back") goto BUILD
										if("Wood") switch(input("Select Section Type","Wooden House") as anything in L6)//list("Exterior Wall","Door"),"Interior Wall") L6
											if("Cancel")
												M<<"You Cancel Selection..."
												M.UED = 0
												M.UEB = 0
												return
											if("Foundation")
												var/obj/items/Ore/stone/J = locate() in M.contents
												//var/obj/items/Sand/J2 = locate() in M.contents
												var/Stone = "10 Stone ore" //Building Material Type
												//var/Filler = "Vessel of Sand"
												if((J in M.contents)&&(J.stack_amount >= 10)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(10)
													//for(J2 in M.contents) J2.RemoveFromStack(3)
													if(M.stamina >= 15)
														M.stamina -= 15
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 5)
														a = new/turf/Building/Foundations/Hfoundation(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Stone])"
													return
											if("Floor")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
												var/Mortar = "3 Mortar" //Building Material Type
												var/Planks = "6 Ueik Board"//WorkStamp -- Make such things as these require Ueik Boards instead of Poles.
												if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 3)&&(J2.stack_amount >= 6)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(3)
													for(J2 in M.contents) J2.RemoveFromStack(6)
													if(M.stamina >= 15)//content
														M.stamina -= 15
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 5)
														a = new/obj/Buildable/Ground/woodfloor(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Planks])"
													return
											if("Wall") switch(input("Select Section (N^,Sv,E>,W<)","Wood House Wall Section")in list("North", "South","East","West"))
												if("North")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/Nails = "4 Handfuls of Iron Nails" //Building Material Type
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/Wood = "6 Ueik Board" //Building Material Type
													if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 6)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(4)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/wh8(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails] and [Wood])"
														return
												if("South")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/Nails = "4 Handfuls of Iron Nails" //Building Material Type
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/Wood = "6 Ueik Board" //Building Material Type
													if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 6)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(4)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/wh1(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails] and [Wood])"
														return
												if("East")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/Nails = "4 Handfuls of Iron Nails" //Building Material Type
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/Wood = "6 Ueik Board" //Building Material Type
													if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 6)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(4)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/wh7(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails] and [Wood])"
														return
												if("West")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/Nails = "4 Handfuls of Iron Nails" //Building Material Type
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/Wood = "6 Ueik Board" //Building Material Type
													if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 6)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(4)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/wh6(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails] and [Wood])"
														return
											if("Window") switch(input("Select Window Section (N^,Sv,E>,W<)","Wood House Window Section")in list("North", "South","East","West"))
												if("North")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Nails = "6 Handfuls of Iron Nails" //Building Material Type
													var/Wood = "6 Ueik Board"
													var/Planks = "4 Pole"
													if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(6)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/whwt(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
												if("South")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Nails = "6 Handfuls of Iron Nails" //Building Material Type
													var/Wood = "6 Ueik Board"
													var/Planks = "4 Pole"
													if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(6)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/whwf(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
												if("East")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Nails = "6 Handfuls of Iron Nails" //Building Material Type
													var/Wood = "6 Ueik Board"
													var/Planks = "4 Pole"
													if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(6)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/whwr(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
												if("West")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Nails = "6 Handfuls of Iron Nails" //Building Material Type
													var/Wood = "6 Ueik Board"
													var/Planks = "4 Pole"
													if((J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 15))
														for(J in M.contents) J.RemoveFromStack(6)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														if(M.stamina >= 15)//content
															M.stamina -= 15
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 5)
															a = new/obj/Buildable/HouseWalls/whwl(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
											if("Door") switch(input("Select Section (N^,Sv,E>,W<)","Wood House Door Section")in list("North", "South","East","West"))
												if("North")
													var/obj/items/Crafting/Created/IronNails/J3 = locate() in M.contents
													var/obj/items/Logs/UeikLog/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J1 = locate() in M.contents
													var/Nails = "5 Handfuls of Iron Nails"//Building Material Type
													var/Wood = "2 Ueik Log"
													var/Planks = "3 Ueik Board"
													if((J in M.contents)&&(J1 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 3)&&(J3.stack_amount >= 5)&&(M.stamina >= 25))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J1 in M.contents) J1.RemoveFromStack(3)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														if(M.stamina >= 25)//content
															M.stamina -= 25
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 15)
															a = new/obj/Buildable/Doors/WHTopDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
												if("South")
													var/obj/items/Crafting/Created/IronNails/J3 = locate() in M.contents
													var/obj/items/Logs/UeikLog/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J1 = locate() in M.contents
													var/Nails = "5 Handfuls of Iron Nails"//Building Material Type
													var/Wood = "2 Ueik Log"
													var/Planks = "3 Ueik Board"
													if((J in M.contents)&&(J1 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 3)&&(J3.stack_amount >= 5)&&(M.stamina >= 25))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J1 in M.contents) J1.RemoveFromStack(3)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														if(M.stamina >= 25)//content
															M.stamina -= 25
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 15)
															a = new/obj/Buildable/Doors/WHDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
												if("East")
													var/obj/items/Crafting/Created/IronNails/J3 = locate() in M.contents
													var/obj/items/Logs/UeikLog/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J1 = locate() in M.contents
													var/Nails = "5 Handfuls of Iron Nails"//Building Material Type
													var/Wood = "2 Ueik Log"
													var/Planks = "3 Ueik Board"
													if((J in M.contents)&&(J1 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 3)&&(J3.stack_amount >= 5)&&(M.stamina >= 25))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J1 in M.contents) J1.RemoveFromStack(3)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														if(M.stamina >= 25)//content
															M.stamina -= 25
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 15)
															a = new/obj/Buildable/Doors/WHRightDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return
												if("West")
													var/obj/items/Crafting/Created/IronNails/J3 = locate() in M.contents
													var/obj/items/Logs/UeikLog/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J1 = locate() in M.contents
													var/Nails = "5 Handfuls of Iron Nails"//Building Material Type
													var/Wood = "2 Ueik Log"
													var/Planks = "3 Ueik Board"
													if((J in M.contents)&&(J1 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J1.stack_amount >= 3)&&(J3.stack_amount >= 5)&&(M.stamina >= 25))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J1 in M.contents) J1.RemoveFromStack(3)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														if(M.stamina >= 25)//content
															M.stamina -= 25
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 115)
															a = new/obj/Buildable/Doors/WHLeftDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															//// REMOVED: buildlevel() proc call - building XP now handled automatically
															/*switch(alert(usr,"Would you like to set a password?","[src.name] Pass Entry","Yes","No"))
																if("Yes")
																	a:pword = input("What should the [src.name] password be?","Enter the password")as text

																	if(a:pwor"")
																		a:pword = null
																		M << "Cannot be blank! Please insert a pass word or phrase for [src.name]."
																		M.UEB = 0
																		return
																else
																	a:pword = null
																	M.UEB = 0
																	M << "Cannot be blank! Please insert a pass word or phrase for [src.name]."
																	return*/
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Nails], [Planks] and [Wood])"
														return


											if("Roof") switch(input("Select Section (N^/Sv,E>/W<)","Wood House Roof Section")in list("North/South", "East/West"))
												if("North/South")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/Mortar = "4 Handfuls of Iron Nails" //Building Material Type
													var/Planks = "6 Ueik Board"
													if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 6)&&(M.stamina >= 35))
														for(J in M.contents) J.RemoveFromStack(4)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														if(M.stamina >= 35)//content
															M.stamina -= 35
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 25)
															a = new/obj/Buildable/Roofing/Roof(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															a:dir = NORTH
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Planks])"
														return
												if("East/West")
													var/obj/items/Crafting/Created/IronNails/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/Mortar = "4 Handfuls of Iron Nails" //Building Material Type
													var/Planks = "6 Ueik Board"
													if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 6)&&(M.stamina >= 35))
														for(J in M.contents) J.RemoveFromStack(4)
														for(J2 in M.contents) J2.RemoveFromStack(6)
														if(M.stamina >= 35)//content
															M.stamina -= 35
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 25)
															a = new/obj/Buildable/Roofing/Roof(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															a:dir = EAST
															M.UEB = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Planks])"
														return
								//house wood ^
									//house stone v
										if("Stone") switch(input("Select Section Type","Stone House Walls") as anything in L7)//list("Exterior Wall","Door"),"Interior Wall") L7HouseWalls/sh8HouseWalls/sh1HouseWalls/sh7HouseWalls/sh8
											if("Cancel")
												M<<"You Cancel Selection..."
												M.UED = 0
												M.UEB = 0
												M.UETW = 0
												return
											if("Back") goto BUILD
											if("Foundation")
												var/obj/items/Crafting/Created/Bricks/J = locate() in M.contents
												var/obj/items/Mortar/J2 = locate() in M.contents
												var/Ore = "4 Piles of Bricks" //Building Material Type
												var/Filler = "4 Mortar"
												if((M.TWequipped)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 4)&&(M.stamina >= 15))
													for(J in M.contents) J.RemoveFromStack(4)
													for(J2 in M.contents) J2.RemoveFromStack(4)
													M.UETW = 1
													if(M.stamina >= 15)//content
														M.stamina -= 15
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 5)
														a = new/turf/Building/Foundations/Pfoundation(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														M.UETW = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M.UETW = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M.UETW = 0
													M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Ore] and [Filler])"
													return
											if("Floor")
												var/obj/items/Mortar/J = locate() in M.contents
												var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
												var/Mortar = "4 Mortar" //Building Material Type
												var/Stone = "4 Piles of Bricks"
												if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 4)&&(J2.stack_amount >= 4)&&(M.stamina >= 20))
													for(J in M.contents) J.RemoveFromStack(4)
													for(J2 in M.contents) J2.RemoveFromStack(4)
													M.UETW = 1
													if(M.stamina >= 20)//content
														M.stamina -= 20
														M.updateST()
														M.character.UpdateRankExp(RANK_BUILDING, 15)
														a = new/obj/Buildable/Ground/pcfloor(usr.loc)
														a:buildingowner = ckeyEx("[usr.key]")
														M.UEB = 0
														M.UETW = 0
														// REMOVED: buildlevel() proc call - building XP now handled automatically
													else
														M.UEB = 0
														M.UETW = 0
														M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
														return
												else
													M.UEB = 0
													M.UETW = 0
													M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material required...([Mortar] and [Stone])"
													return
											if("Wall") switch(input("Select Wall Section (N^,Sv,E>,W<)","Stone House Wall Section")in list("North", "South","East","West"))
												if("North")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "4 Piles of Bricks"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(M.stamina >= 35))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 35)//content
															M.stamina -= 35
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 25)
															a = new/obj/Buildable/HouseWalls/sh8(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
														return
												if("South")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "4 Piles of Bricks"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(M.stamina >= 35))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 35)//content
															M.stamina -= 35
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 25)
															a = new/obj/Buildable/HouseWalls/sh1(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
														return
												if("East")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "4 Piles of Bricks"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(M.stamina >= 35))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 35)//content
															M.stamina -= 35
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 25)
															a = new/obj/Buildable/HouseWalls/sh7(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
														return
												if("West")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "4 Piles of Bricks"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(M.stamina >= 35))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 35)//content
															M.stamina -= 35
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 25)
															a = new/obj/Buildable/HouseWalls/sh6(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
														return

											if("Window") switch(input("Select Window Section (N^,Sv,E>,W<)","Stone House Window Section")in list("North", "South","East","West"))
												if("North")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "4 Pole"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/HouseWalls/shwt(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
												if("South")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "4 Pole"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/HouseWalls/shwf(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
												if("East")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "4 Pole"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/HouseWalls/shwr(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
												if("West")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "4 Pole"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 4)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/HouseWalls/shwl(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
											if("Door") switch(input("Select Section (N^,Sv,E>,W<)","Stone House Door Section")in list("North", "South","East","West"))
												if("North")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "2 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "5 Poles"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 5)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/Doors/SHTopDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		M.UETW = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		M.UETW = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	M.UETW = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
												if("South")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "2 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "5 Poles"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 5)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/Doors/SHDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		M.UETW = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		M.UETW = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	M.UETW = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
												if("East")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "2 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "5 Poles"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 5)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/Doors/SHRightDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		M.UETW = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		M.UETW = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	M.UETW = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
												if("West")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Pole/J3 = locate() in M.contents
													var/Mortar = "2 Mortar" //Building Material Type
													var/Stone = "2 Piles of Bricks"
													var/Planks = "5 Poles"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 2)&&(J2.stack_amount >= 2)&&(J3.stack_amount >= 5)&&(M.stamina >= 45))
														for(J in M.contents) J.RemoveFromStack(2)
														for(J2 in M.contents) J2.RemoveFromStack(2)
														for(J3 in M.contents) J3.RemoveFromStack(5)
														M.UETW = 1
														if(M.stamina >= 45)//content
															M.stamina -= 45
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/Doors/SHLeftDoor(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															M.UEB = 0
															M.UETW = 0
															switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																if("Yes")
																	a:unlocked = 0
																	a:locked = 1
																	var/obj/items/DoorKey/K = locate() in M.contents
																	if(K in M.contents)
																		M.UEB = 0
																		M.UETW = 0
																		return
																	else
																		new /obj/items/DoorKey(M)
																		M << "You have received a Skeleton Door Key."
																		M.UEB = 0
																		M.UETW = 0
																		return
																else
																	a:locked = 0
																	a:unlocked = 1
																	M.UEB = 0
																	M.UETW = 0
																	return
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Planks] and [Stone])"
														return
											if("Roof") switch(input("Select Section (N^,Sv,E>,W<)","Stone House Wall Section")in list("North/South", "East/West"))
												if("North/South")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J3 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Planks = "4 Poles"
													var/Ore = "4 Piles of Bricks"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(J3.stack_amount >= 4)&&(M.stamina >= 55))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(4)
														for(J3 in M.contents) J3.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 55)//content
															M.stamina -= 55
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/Roofing/HINTRoof(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															a:dir = NORTH
															//a:layer = MOB_LAYER+1
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Ore] and [Planks])"
														return
												if("East/West")
													var/obj/items/Mortar/J = locate() in M.contents
													var/obj/items/Crafting/Created/UeikBoard/J2 = locate() in M.contents
													var/obj/items/Crafting/Created/Bricks/J3 = locate() in M.contents
													var/Mortar = "1 Mortar" //Building Material Type
													var/Planks = "4 Poles"
													var/Ore = "4 Piles of Bricks"
													if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(J3.stack_amount >= 4)&&(M.stamina >= 55))
														for(J in M.contents) J.RemoveFromStack(1)
														for(J2 in M.contents) J2.RemoveFromStack(4)
														for(J3 in M.contents) J2.RemoveFromStack(4)
														M.UETW = 1
														if(M.stamina >= 55)//content
															M.stamina -= 55
															M.updateST()
															M.character.UpdateRankExp(RANK_BUILDING, 35)
															a = new/obj/Buildable/Roofing/HINTRoof(usr.loc)
															a:buildingowner = ckeyEx("[usr.key]")
															a:dir = EAST
															//a:layer = MOB_LAYER+1
															M.UEB = 0
															M.UETW = 0
															// REMOVED: buildlevel() proc call - building XP now handled automatically
														else
															M.UEB = 0
															M.UETW = 0
															M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
															return
													else
														M.UEB = 0
														M.UETW = 0
														M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Ore] and [Planks])"
														return
						//stone house ^
							//wood fort   v

									if("Fort")
										FORT
										switch(input("Select Material Type","Fort Materials") as anything in L0)//in list("Wood"),"Stone") L0wood build material selection
											if("Cancel")
												M<<"You Cancel Selection..."
												M.UED = 0
												M.UEB = 0
												return
											if("Back") goto BUILD
											if("Wood")
												WOODFORT
												switch(input("Select Section Type","Wooden Fort Walls") as anything in L1)//list("Exterior Wall","Door"),"Interior Wall") L1
													if("Cancel")
														M<<"You Cancel Selection..."
														M.UED = 0
														M.UEB = 0
														return
													if("Back") goto FORT
												if("Interior") switch(input("Select Interior Section Type","Wooden Fort Interior Walls")in L8)//list("Wooden Fort North 3-Way Wall","Wooden Fort South 3-Way Wall","Wooden Fort Central 4-Way Wall","Wooden Fort North-South Mid-Section Wall","Wooden Fort East-West Mid-Section Wall"))
													if("Cancel")
														M<<"You Cancel Selection..."
														M.UED = 0
														M.UEB = 0
														return
													if("Back") goto WOODFORT
													if("Wooden Fort Mid-Section Wall") switch(input("Select Wood Mid-Section Direction (N^/Sv,E>/W<)","Wooden Fort Mid-Wall Direction")in list("North/South","East/West"))
														if("North/South")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type Walls/N3Wwall Walls/S3Wwall Walls/C4Wwall Walls/MIDnswall Walls/MIDwewall
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 20)
																	a = new/obj/Buildable/Walls/MIDnswall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("East/West")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type Walls/N3Wwall Walls/S3Wwall Walls/C4Wwall Walls/MIDnswall Walls/MIDwewall
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 20)
																	a = new/obj/Buildable/Walls/MIDwewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
													if("Wooden Fort 3-Way Wall") switch(input("Select Wood 3-Way Direction (N^,Sv)","Wooden Fort 3-Way Direction")in list("North","South"))
														if("North")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type Walls/N3Wwall Walls/S3Wwall Walls/C4Wwall Walls/MIDnswall Walls/MIDwewall
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 35))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 35)//content
																	M.stamina -= 35
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 30)
																	a = new/obj/Buildable/Walls/N3Wwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("South")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type Walls/N3Wwall Walls/S3Wwall Walls/C4Wwall Walls/MIDnswall Walls/MIDwewall
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 35))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 35)//content
																	M.stamina -= 35
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 30)
																	a = new/obj/Buildable/Walls/S3Wwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
													if("Wooden Fort Central 4-Way Wall")
														var/obj/items/Logs/UeikLog/J = locate() in M.contents
														var/Wood = "4 Ueik Log" //Building Material Type Walls/N3Wwall Walls/S3Wwall Walls/C4Wwall Walls/MIDnswall Walls/MIDwewall
														if((J in M.contents)&&(J.stack_amount >= 4)&&(M.stamina >= 45))
															for(J in M.contents) J.RemoveFromStack(4)
															if(M.stamina >= 45)//content
																M.stamina -= 45
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 35)
																a = new/obj/Buildable/Walls/C4Wwall(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
															return
												if("Door") switch(input("Select Door Direction (N^,Sv,E>,W<)","Wooden Fort Door Direction")in list("North","South","East","West"))
													if("North")
														var/obj/items/Logs/UeikLog/J = locate() in M.contents
														var/obj/items/Ingots/ironbar/J2 = locate() in M.contents
														var/Wood = "5 Ueik Log" //Building Material Type Doors/TopDoor Doors/Door Doors/LeftDoor Doors/RightDoor
														var/Ingots = "2 Iron Ingot"
														if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 2)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(3)
															for(J2 in M.contents) J2.RemoveFromStack(3)
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/TopDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood] and [Ingots])"
															return
													if("South")
														var/obj/items/Logs/UeikLog/J = locate() in M.contents
														var/obj/items/Ingots/ironbar/J2 = locate() in M.contents
														var/Wood = "5 Ueik Log" //Building Material Type Doors/TopDoor Doors/Door Doors/LeftDoor Doors/RightDoor
														var/Ingots = "2 Iron Ingot"
														if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 2)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(3)
															for(J2 in M.contents) J2.RemoveFromStack(3)
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/Door(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood] and [Ingots])"
															return
													if("East")
														var/obj/items/Logs/UeikLog/J = locate() in M.contents
														var/obj/items/Ingots/ironbar/J2 = locate() in M.contents
														var/Wood = "5 Ueik Log" //Building Material Type Doors/TopDoor Doors/Door Doors/LeftDoor Doors/RightDoor
														var/Ingots = "2 Iron Ingot"
														if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 2)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(3)
															for(J2 in M.contents) J2.RemoveFromStack(3)
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/LeftDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood] and [Ingots])"
															return
													if("West")
														var/obj/items/Logs/UeikLog/J = locate() in M.contents
														var/obj/items/Ingots/ironbar/J2 = locate() in M.contents
														var/Wood = "5 Ueik Log" //Building Material Type Doors/TopDoor Doors/Door Doors/LeftDoor Doors/RightDoor
														var/Ingots = "2 Iron Ingot"
														if((J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 5)&&(J2.stack_amount >= 2)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(3)
															for(J2 in M.contents) J2.RemoveFromStack(3)
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/RightDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood] and [Ingots])"
															return

		//wood fort exterior wall build selection list							do these need cancel and back options added or are they already present?
												if("Exterior") switch(input("Select Section Type: Wall or Corner","Wooden Fort Exterior Walls")in list("Wooden Fort Wall","Wooden Fort Corner"))//"Wooden Fort North Wall","Wooden Fort South Wall","Wooden Fort East Wall","Wooden Fort West Wall","Wooden Fort NW Corner","Wooden Fort NE Corner","Wooden Fort SW Corner","Wooden Fort SE Corner")
													//if(bfww == "")
													if("Cancel")
														M<<"You Cancel Selection..."
														M.UED = 0
														M.UEB = 0
														return
														//wood fort wall selection
													if("Back") goto WOODFORT
													if("Wooden Fort Wall") switch(input("Select Section Direction (N^,Sv,E>,W<)","Wooden Fort Wall Direction")in list("North","South","East","West"))
														if("North")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "1 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 15))
																for(J in M.contents) J.RemoveFromStack(1)
																if(M.stamina >= 15)//content
																	M.stamina -= 15
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 5)
																	a = new/obj/Buildable/Walls/nwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("South")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "1 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 15))
																for(J in M.contents) J.RemoveFromStack(1)
																if(M.stamina >= 15)//content
																	M.stamina -= 15
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 5)
																	a = new/obj/Buildable/Walls/swall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("East")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "1 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 15))
																for(J in M.contents) J.RemoveFromStack(1)
																if(M.stamina >= 15)//content
																	M.stamina -= 15
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 5)
																	a = new/obj/Buildable/Walls/ewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("West")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "1 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 15))
																for(J in M.contents) J.RemoveFromStack(1)
																if(M.stamina >= 15)//content
																	M.stamina -= 15
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 5)
																	a = new/obj/Buildable/Walls/wall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
													if("Wooden Fort Corner") switch(input("Select Section Direction (NW,NE,SW,SE)","Wooden Fort Corner Direction")in list("Northwest","Northeast","Southwest","Southeast"))
														if("Northwest")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 20)
																	a = new/obj/Buildable/Walls/nwwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("Northeast")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 20)
																	a = new/obj/Buildable/Walls/newall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("Southwest")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 20)
																	a = new/obj/Buildable/Walls/swwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
														if("Southeast")
															var/obj/items/Logs/UeikLog/J = locate() in M.contents
															var/Wood = "3 Ueik Log" //Building Material Type
															if((J in M.contents)&&(J.stack_amount >= 3)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(3)
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 20)
																	a = new/obj/Buildable/Walls/sewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M << "You lack the effort (stamina: [M.stamina]) or the material...([Wood])"
																return
										if("Stone")
											STONEFORT
											switch(input("Select Section Type","Stone Fort Walls") as anything in L2)
											//Stone fort exterior wall build selection list
												if("Cancel")
													M<<"You Cancel Selection..."
													M.UED = 0
													M.UEB = 0
													M.UETW = 0
													return
												if("Back") goto FORT
												if("Exterior") switch(input("Select Section Type: Wall or Corner","Stone Fort Exterior Walls")in list("Stone Fort Wall","Stone Fort Corner"))//"Wooden Fort North Wall","Wooden Fort South Wall","Wooden Fort East Wall","Wooden Fort West Wall","Wooden Fort NW Corner","Wooden Fort NE Corner","Wooden Fort SW Corner","Wooden Fort SE Corner")
													if("Cancel")
														M<<"You Cancel Selection..."
														M.UED = 0
														M.UEB = 0
														M.UETW = 0
														return
													if("Back") goto STONEFORT
													if("Stone Fort Wall") switch(input("Select Section Direction (N^,Sv,E>,W<)","Stone Fort Wall Direction")in list("North","South","East","West"))
														if("North")
															var/obj/items/Crafting/Created/Bricks/J = locate() in M.contents
															var/Stone = "1 Brick" //Building Material Type
															if((M.TWequipped==1)&&(J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 25))
																for(J in M.contents)J.RemoveFromStack(1)
																M.UETW = 1
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 15)
																	a = new/obj/Buildable/Walls/Snwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Stone])"
																return
														if("South")
															var/obj/items/Crafting/Created/Bricks/J = locate() in M.contents
															var/Stone = "1 Brick" //Building Material Type
															if((M.TWequipped==1)&&(J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(1)
																M.UETW = 1
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 15)
																	a = new/obj/Buildable/Walls/Sswall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Stone])"
																return
														if("East")
															var/obj/items/Crafting/Created/Bricks/J = locate() in M.contents
															var/Stone = "1 Brick" //Building Material Type
															if((M.TWequipped==1)&&(J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(1)
																M.UETW = 1
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 15)
																	a = new/obj/Buildable/Walls/Sewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Stone])"
																return
														if("West")
															var/obj/items/Crafting/Created/Bricks/J = locate() in M.contents
															var/Stone = "1 Brick" //Building Material Type
															if((M.TWequipped==1)&&(J in M.contents)&&(J.stack_amount >= 1)&&(M.stamina >= 25))
																for(J in M.contents) J.RemoveFromStack(1)
																M.UETW = 1
																if(M.stamina >= 25)//content
																	M.stamina -= 25
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 15)
																	a = new/obj/Buildable/Walls/Swall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Stone])"
																return
													if("Stone Fort Corner") switch(input("Select Section Direction (NW,NE,SW,SE)","Stone Fort Corner Direction")in list("Northwest","Northeast","Southwest","Southeast"))
														if("Northwest")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/Snwwall Walls/Snewall Walls/Sswwall Walls/Ssewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 50))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 50)//content
																	M.stamina -= 50
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 50)
																	a = new/obj/Buildable/Walls/Snwwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
														if("Northeast")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 50))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 50)//content
																	M.stamina -= 50
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 50)
																	a = new/obj/Buildable/Walls/Snewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
														if("Southwest")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 50))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 50)//content
																	M.stamina -= 50
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 50)
																	a = new/obj/Buildable/Walls/Sswwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
														if("Southeast")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 50))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 50)//content
																	M.stamina -= 50
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 50)
																	a = new/obj/Buildable/Walls/Ssewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
		//Stone fort wall selection
												if("Interior") switch(input("Select Interior Section Type","Stone Fort Interior Walls")in L9)//list("Wooden Fort North 3-Way Wall","Wooden Fort South 3-Way Wall","Wooden Fort Central 4-Way Wall","Wooden Fort North-South Mid-Section Wall","Wooden Fort East-West Mid-Section Wall"))
													if("Cancel")
														M<<"You Cancel Selection..."
														M.UED = 0
														M.UEB = 0
														M.UETW = 0
														return
													if("Back") goto STONEFORT
													if("Stone Fort Mid-Section Wall") switch(input("Select Stone Mid-Section Direction (N^/Sv,E>/W<)","Stone Fort Mid-Wall Direction")in list("North/South","South/East"))
														if("North/South")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 50))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 50)//content
																	M.stamina -= 50
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 50)
																	a = new/obj/Buildable/Walls/SMIDnswall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
														if("East/West")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 50))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 50)//content
																	M.stamina -= 50
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 50)
																	a = new/obj/Buildable/Walls/SMIDwewall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
													if("Stone Fort 3-Way Wall") switch(input("Select Stone 3-Way Direction (N^,Sv)","Stone Fort 3-Way Direction")in list("North","South"))
														if("North")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 35))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 35)//content
																	M.stamina -= 35
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 30)
																	a = new/obj/Buildable/Walls/SN3Wwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
														if("South")
															var/obj/items/Mortar/J = locate() in M.contents
															var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
															var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
															var/Stone = "2 Piles of Bricks"
															if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 3)&&(M.stamina > 35))
																for(J in M.contents) J.RemoveFromStack(1)
																for(J2 in M.contents) J2.RemoveFromStack(3)
																M.UETW = 1
																if(M.stamina >= 35)//content
																	M.stamina -= 35
																	M.updateST()
																	M.character.UpdateRankExp(RANK_BUILDING, 30)
																	a = new/obj/Buildable/Walls/SS3Wwall(usr.loc)
																	a:buildingowner = ckeyEx("[usr.key]")
																	M.UEB = 0
																	M.UETW = 0
																	// REMOVED: buildlevel() proc call - building XP now handled automatically
																else
																	M.UEB = 0
																	M.UETW = 0
																	M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																	return
															else
																M.UEB = 0
																M.UETW = 0
																M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
																return
													if("Stone Fort Central 4-Way Wall")
														var/obj/items/Mortar/J = locate() in M.contents
														var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
														var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
														var/Stone = "4 Piles of Bricks"
														if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(M.stamina > 65))
															for(J in M.contents) J.RemoveFromStack(1)
															for(J2 in M.contents) J2.RemoveFromStack(4)
															M.UETW = 1
															if(M.stamina >= 65)//content
																M.stamina -= 65
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 50)
																a = new/obj/Buildable/Walls/SC4Wwall(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																M.UETW = 0
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M.UETW = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M.UETW = 0
															M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar] and [Stone])"
															return
												if("Door") switch(input("Select Door Direction (N^,Sv,E>,W<)","Stone Fort Door Direction")in list("North","South","East","West"))
													if("North")
														var/obj/items/Mortar/J = locate() in M.contents
														var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
														var/obj/items/Ingots/ironbar/J3 = locate() in M.contents
														var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
														var/Stone = "4 Piles of Bricks"
														var/Ingots = "3 Iron Ingot"
														if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(J3.stack_amount >= 3)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(1)
															for(J2 in M.contents) J2.RemoveFromStack(4)
															for(J3 in M.contents) J3.RemoveFromStack(3)
															M.UETW = 1
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/STopDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																M.UETW = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			M.UETW = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			M.UETW = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		M.UETW = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M.UETW = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M.UETW = 0
															M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Ingots])"
															return
													if("South")
														var/obj/items/Mortar/J = locate() in M.contents
														var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
														var/obj/items/Ingots/ironbar/J3 = locate() in M.contents
														var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
														var/Stone = "4 Piles of Bricks"
														var/Ingots = "3 Iron Ingot"
														if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(J3.stack_amount >= 3)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(1)
															for(J2 in M.contents) J2.RemoveFromStack(4)
															for(J3 in M.contents) J3.RemoveFromStack(3)
															M.UETW = 1
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/SDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																M.UETW = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			M.UETW = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			M.UETW = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		M.UETW = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M.UETW = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M.UETW = 0
															M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Ingots])"
															return
													if("East")
														var/obj/items/Mortar/J = locate() in M.contents
														var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
														var/obj/items/Ingots/ironbar/J3 = locate() in M.contents
														var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
														var/Stone = "4 Piles of Bricks"
														var/Ingots = "3 Iron Ingot"
														if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(J3.stack_amount >= 3)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(1)
															for(J2 in M.contents) J2.RemoveFromStack(4)
															for(J3 in M.contents) J3.RemoveFromStack(3)
															M.UETW = 1
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/SRightDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																M.UETW = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			M.UETW = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			M.UETW = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		M.UETW = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M.UETW = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M.UETW = 0
															M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Ingots])"
															return
													if("West")
														var/obj/items/Mortar/J = locate() in M.contents
														var/obj/items/Crafting/Created/Bricks/J2 = locate() in M.contents
														var/obj/items/Ingots/ironbar/J3 = locate() in M.contents
														var/Mortar = "1 Mortar" //Building Material Type Walls/SN3Wwall Walls/SS3Wwall Walls/SC4Wwall Walls/SMIDnswall Walls/SMIDwewall
														var/Stone = "4 Piles of Bricks"
														var/Ingots = "3 Iron Ingot"
														if((M.TWequipped==1)&&(J in M.contents)&&(J2 in M.contents)&&(J3 in M.contents)&&(J.stack_amount >= 1)&&(J2.stack_amount >= 4)&&(J3.stack_amount >= 3)&&(M.stamina >= 55))
															for(J in M.contents) J.RemoveFromStack(1)
															for(J2 in M.contents) J2.RemoveFromStack(4)
															for(J3 in M.contents) J3.RemoveFromStack(3)
															M.UETW = 1
															if(M.stamina >= 55)//content
																M.stamina -= 55
																M.updateST()
																M.character.UpdateRankExp(RANK_BUILDING, 40)
																a = new/obj/Buildable/Doors/SLeftDoor(usr.loc)
																a:buildingowner = ckeyEx("[usr.key]")
																M.UEB = 0
																M.UETW = 0
																switch(alert(usr,"Would you like to Lock the [src.name]?","[src.name] Keymaker","Yes","No"))
																	if("Yes")
																		a:unlocked = 0
																		a:locked = 1
																		var/obj/items/DoorKey/K = locate() in M.contents
																		if(K in M.contents)
																			M.UEB = 0
																			M.UETW = 0
																			return
																		else
																			new /obj/items/DoorKey(M)
																			M << "You have received a Skeleton Door Key."
																			M.UEB = 0
																			M.UETW = 0
																			return
																	else
																		a:locked = 0
																		a:unlocked = 1
																		M.UEB = 0
																		M.UETW = 0
																		return
																// REMOVED: buildlevel() proc call - building XP now handled automatically
															else
																M.UEB = 0
																M.UETW = 0
																M << "You lack the effort, replenish your stamina by hydrating. (stamina: [M.stamina])"
																return
														else
															M.UEB = 0
															M.UETW = 0
															M << "You need a Trowel equipped or lack the effort (stamina: [M.stamina]) or the material...([Mortar], [Stone] and [Ingots])"
															return

/*proc/checkdlevel(var/mob/players/M) // can i level?
	if (M.digexp >= M.mdigexp) GaindLevel(M)
	M.updateDXP()

proc/GaindLevel(var/mob/players/M) // isn't it a great feeling when this fires?
	M << "\green<b>You've become Stronger." // There's the message that inspires the good feeling
		//M.oldexp = M.expneeded // used for the green exp meter
	M.mdigexp+=(13*(M.drank*M.drank)) // my algorithm for costaminauting experience required per level, no longer a secret
	M.drank+=1 // yep.  increment that sucker.
	M.updateDXP()*/


proc
	digunlock()
		set background = 1
		var/mob/players/M
		M = usr
		if(M.drank == 1)
			//M.drank += 1
			//M << "<b><font color=silver>Your Digging Rank went up a level!"
			dig = list("Dirt")
			return
		else
			if(M.drank == 2)
				//M.drank += 1
				//M.mdigexp = 150
				//M.mdigexp += (13*(M.drank*M.drank))
				//M << "<b><font color=silver>Your Digging Rank went up a level!"
				dig = list("Dirt","Grass","Cancel","Back")
				return
			else
				if(M.drank == 3)//&&(M.digexp >= 350))
					//M.drank += 1
					//M.mdigexp = 400
					dig = list("Dirt","Grass","Dirt Road","Cancel","Back")
					return
					//M << "<b><font color=silver>Your Digging Rank went up a level!"
				else
					if(M.drank == 4)//&&(M.digexp >= 750))
						//M.drank += 1
						//M.mdigexp = 600
						dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Cancel","Back")
						return
						//M << "<b><font color=silver>Your Digging Rank went up a level!"
					else
						if(M.drank == 5)//&&(M.digexp >= 1350))
							//M.drank += 1
							//M.mdigexp = 800
							//M << "<b><font color=silver>Your Digging Rank went up a level!"
							dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Wood Road","Wood Road Corner","Cancel","Back")
							return
						else
							if(M.drank == 6)//&&(M.digexp >= 2150))
								//M.drank += 1
								//M.mdigexp = 1000
								//M << "<b><font color=silver>Your Digging Rank went up a level!"
								dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Wood Road","Wood Road Corner","Cancel","Back")
								return
							else
								if(M.drank == 7)//&&(M.digexp >= 3150))
									//M.drank += 1
									//M.mdigexp = 1200
									//M << "<b><font color=silver>Your Digging Rank went up a level!"
									dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Wood Road","Wood Road Corner","Ditch","Cancel","Back")
									return
								else
									if(M.drank == 8)//&&(M.digexp >= 4350))
										//M.drank += 1
										//M << "<b><font color=silver>Your Digging Rank went up a level!"
										//M.mdigexp = 1400
										dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Wood Road","Wood Road Corner","Brick Road","Brick Road Corner","Ditch","Hill","Cancel","Back")
										return
									else
										if(M.drank == 9)//&&(M.digexp >= 5750))
											//M.drank += 1
											//M.mdigexp = 1600
											//M << "<b><font color=silver>Your Digging Rank went up a level!"
											dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Wood Road","Wood Road Corner","Brick Road","Brick Road Corner","Ditch","Hill","Water","Cancel","Back")
											return
										else
											if(M.drank == 10)//&&(M.digexp >= 7350))
												//M.drank += 1
												//M.mdigexp == 595
												//M << "<b><font color=silver>You've reached max Digging Rank!"
												dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Wood Road","Wood Road Corner","Brick Road","Brick Road Corner","Ditch","Hill","Water","Lava","Cancel","Back")
												return
		//..()
	diglevel()
		set background = 1
		var/mob/players/M
		M = usr
		//Demo3
		//if(M.drank == 1)
			//dig.Add("Ditch")
		//EndDemo3

//Begin Dig List
	//Dig List Level 1

		//if((M.drank == 1))
			//M.drank += 1
			//M << "<b><font color=silver>Your Digging Rank went up a level!"
			//dig = list("Dirt")

		if((M.drank == 1)&&(M.digexp >= 50))
			M.drank += 1
			M.mdigexp = 100
			M << "<b><font color=silver>Your Digging Rank went up a level!"


	//Dig List Level 2



		/*if((M.drank == 2))
			M.drank += 1
			M.mdigexp = 150
			//M.mdigexp += (13*(M.drank*M.drank))
			M << "<b><font color=silver>Your Digging Rank went up a level!"
			dig = list("Dirt","Grass")*/

		if((M.drank == 2)&&(M.digexp >= 150))
			M.drank += 1
			M.mdigexp = 200
			M << "<b><font color=silver>Your Digging Rank went up a level!"
	//Dig List Level 3


		if((M.drank == 3)&&(M.digexp >= 350))
			M.drank += 1
			M.mdigexp = 400
			M << "<b><font color=silver>Your Digging Rank went up a level!"

	//Dig List Level 4


		if((M.drank == 4)&&(M.digexp >= 750))
			M.drank += 1
			M.mdigexp = 600
			//dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner")
			M << "<b><font color=silver>Your Digging Rank went up a level!"


	//Dig List Level 5


		if((M.drank == 5)&&(M.digexp >= 1350))
			M.drank += 1
			M.mdigexp = 800
			M << "<b><font color=silver>Your Digging Rank went up a level!"


	//Dig List Level 6


		if((M.drank == 6)&&(M.digexp >= 2150))
			M.drank += 1
			M.mdigexp = 1000
			M << "<b><font color=silver>Your Digging Rank went up a level!"
			//dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Brick Road","Brick Road Corner")


	//Dig List Level 7


		if((M.drank == 7)&&(M.digexp >= 3150))
			M.drank += 1
			M.mdigexp = 1200
			M << "<b><font color=silver>Your Digging Rank went up a level!"
			//dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Brick Road","Brick Road Corner","Ditch")


	//Dig List Level 8



		if((M.drank == 8)&&(M.digexp >= 4350))
			M.drank += 1
			M << "<b><font color=silver>Your Digging Rank went up a level!"
			M.mdigexp = 1400
			//dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Brick Road","Brick Road Corner","Ditch","Hill")


	//Dig List Level 9


		if((M.drank == 9)&&(M.digexp >= 5750))
			M.drank += 1
			M.mdigexp = 1600
			M << "<b><font color=silver>Your Digging Rank went up a level!"
			//dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Brick Road","Brick Road Corner","Ditch","Hill","Water")


	//Dig List Level 10


		if((M.drank == 10)&&(M.digexp >= 7350))
			//M.drank += 1
			//M.mdigexp == 595
			M.mdigexp = M.digexp
			M << "<b><font color=silver>You've reached max Digging Rank!"
			//dig = list("Dirt","Grass","Dirt Road","Dirt Road Corner","Brick Road","Brick Road Corner","Ditch","Hill","Water","Lava")
		else
			if(M.drank >= 10)
				//M << "<b><font color=silver>You begin to wonder what more is there to build... (Building Acuity: [M.brank])"
				M.drank = 10
		//..()

proc
	buildunlock()  //this is the building menu leveling unlock system, it doesn't need announcements because it gets called a lot and notification is annoying to the user. These are lists in a procedure called by a reference and arglist activation in a switch input menu.
	//Unlocking
		set background = 1
		var/mob/players/M
		M = usr
		if(M.brank <= 0)
			return
		else if(M.brank == 1)
		//if(M.buildexp >= 0)
			//M.brank += 1
			//M << "<b><font color=silver>Your Build Rank went up a level!"
			build = list("Miscellaneous","Fire","Cancel","Back")
			L0 = list("Wood","Cancel","Back")
			L1 = list("Exterior","Door","Cancel","Back")
			L2 = list("Exterior","Door","Cancel","Back")
			L3 = list("Wood","Cancel","Back")
			L4 = list("Barricade","Sundial","Cancel","Back")
			L5 = list("Cancel")
			L6 = list("Cancel")
			L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")
			L8 = list("Cancel")	//wood fort interior L8
			L9 = list("Cancel")	//stone fort interior L9
			L10 = list("Wood","Cancel","Back")	//lampost type L10
			return
		else
			if(M.brank == 2)
				build = list("House","Miscellaneous","Fire","Cancel","Back")
				L0 = list("Wood","Cancel","Back")
				L1 = list("Exterior","Door","Cancel","Back")
				L2 = list("Exterior","Door","Cancel","Back")
				L3 = list("Wood","Cancel","Back")
				L4 = list("Barricade","Sundial","Cancel","Back")
				L5 = list("Chair","Forge","Cancel","Back")
				L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")
				L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")
				//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"
				L8 = list("")	//wood fort interior L8
				L9 = list("")	//stone fort interior L9
				L10 = list("Wood")	//lampost type L10
				return
			else
				if(M.brank == 3)
					build = list("House","Furnishings","Miscellaneous","Fire","Cancel","Back")
					L0 = list("Wood","Cancel","Back")
					L1 = list("Exterior","Door","Cancel","Back")
					L2 = list("Exterior","Door","Cancel","Back")
					L3 = list("Wood","Cancel","Back")
					L4 = list("Barricade","Sundial","Cancel","Back")
					L5 = list("Chair","Table","Forge","Anvil","Cancel","Back")
					L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")
					L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")
					L8 = list("Cancel")	//wood fort interior L8
					L9 = list("Cancel")	//stone fort interior L9
					L10 = list("Wood","Cancel","Back")	//lampost type L10
					return
				else
					if(M.brank == 4)
						build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
						L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
						L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
						L2 = list("Exterior","Door","Cancel","Back")	//stone fort section type selection  L2
						L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
						L4 = list("Barricade","Sundial","Cancel","Back")	//miscellaneous  L4
						L5 = list("Chair","Table","Forge","Anvil","Log Storage","Cancel","Back")	//furnishings  L5
						L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
						L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
						L8 = list("Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
						L9 = list("Cancel")	//stone fort interior L9
						L10 = list("Wood","Iron","Cancel","Back")	//lampost type L10
						return
					else
						if(M.brank == 5)
							build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
							L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
							L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
							L2 = list("Exterior","Door","Cancel","Back")	//stone fort section type selection  L2
							L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
							L4 = list("Barricade","Sundial","Water Fountain","Cancel","Back")	//miscellaneous  L4
							L5 = list("Chair","Table","Bed","Forge","Anvil","Lampost","Log Storage","Cancel","Back")	//furnishings  L5
							L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
							L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
							L8 = list("Wooden Fort 3-Way Wall","Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
							L9 = list("Cancel")	//stone fort interior L9
							L10 = list("Wood","Iron","Bronze","Cancel","Back")	//lampost type L10
							//L11 = list("Stone Fort 3-Way Wall","Stone Fort Mid-Section Wall")	//stone fort door L11
							//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"
							return
						else

							if(M.brank == 6)
								build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
								L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
								L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
								L2 = list("Exterior","Door","Interior","Cancel","Back")	//stone fort section type selection  L2
								L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
								L4 = list("Barricade","Sundial","Cancel","Back")	//miscellaneous  L4
								L5 = list("Chair","Table","Bed","Crate","Forge","Anvil","Lampost","Log Storage","Food Container","Cancel","Back")	//furnishings  L5
								L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
								L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
								L8 = list("Wooden Fort 3-Way Wall","Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
								L9 = list("Stone Fort Mid-Section Wall","Cancel","Back")	//stone fort interior L9
								L10 = list("Wood","Iron","Bronze","Cancel","Back")	//lampost type L10
								//L11 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall")	//stone fort door L11

								//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"
								return
							else
			//return
								if(M.brank == 7)
									build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
									L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
									L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
									L2 = list("Exterior","Door","Interior","Cancel","Back")	//stone fort section type selection  L2
									L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
									L4 = list("Barricade","Sundial","Cancel","Back")	//miscellaneous  L4
									L5 = list("Chair","Table","Bed","Crate","Forge","Anvil","Lampost","Log Storage","Food Container","Ore Chest","Cancel","Back")	//furnishings  L5
									L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
									L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
									L8 = list("Wooden Fort 3-Way Wall","Wooden Fort Central 4-Way Wall","Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
									L9 = list("Stone Fort 3-Way Wall","Stone Fort Mid-Section Wall","Cancel","Back")	//stone fort interior L9
									L10 = list("Wood","Iron","Bronze","Cancel","Back")	//lampost type L10
									//L11 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall")	//stone fort door L11

									//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"
									return
								else
			//return
									if(M.brank == 8)
										build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
										L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
										L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
										L2 = list("Exterior","Door","Interior","Cancel","Back")	//stone fort section type selection  L2
										L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
										L4 = list("Barricade","Sundial")	//miscellaneous  L4
										L5 = list("Chair","Table","Bed","Crate","Forge","Anvil","Lampost","Log Storage","Food Container","Ore Chest","Cancel","Back")	//furnishings  L5
										L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
										L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
										L8 = list("Wooden Fort 3-Way Wall","Wooden Fort Central 4-Way Wall","Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
										L9 = list("Stone Fort 3-Way Wall","Stone Fort Mid-Section Wall","Cancel","Back")	//stone fort interior L9
										L10 = list("Wood","Iron","Bronze","Copper","Cancel","Back")	//lampost type L10
										//L11 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall")	//stone fort door L11

										//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"
										return
									else
			//return
										if(M.brank == 9)
											build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
											L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
											L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
											L2 = list("Exterior","Door","Interior","Cancel","Back")	//stone fort section type selection  L2
											L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
											L4 = list("Barricade","Sundial","Cancel","Back")	//miscellaneous  L4
											L5 = list("Chair","Table","Bed","Crate","Forge","Anvil","Lampost","Log Storage","Food Container","Ore Chest","Cancel","Back")	//furnishings  L5
											L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
											L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
											L8 = list("Wooden Fort 3-Way Wall","Wooden Fort Central 4-Way Wall","Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
											L9 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall","Cancel","Back")	//stone fort interior L9
											L10 = list("Wood","Iron","Bronze","Copper","Brass","Cancel","Back")	//lampost type L10
											//L11 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall")	//stone fort door L11

											//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"  //need to fill these out
											return
										else
											//return
											if(M.brank == 10)
												build = list("House","Fort","Furnishings","Miscellaneous","Fire","Cancel","Back")	//build menu selection  build
												L0 = list("Wood","Stone","Cancel","Back")	//fort material type selection  L0
												L1 = list("Exterior","Door","Interior","Cancel","Back")	//wood fort section type selection  L1
												L2 = list("Exterior","Door","Interior","Cancel","Back")	//stone fort section type selection  L2
												L3 = list("Wood","Stone","Cancel","Back")	//house material type  L3
												L4 = list("Barricade","Sundial","Cancel","Back")	//miscellaneous  L4
												L5 = list("Chair","Table","Bed","Crate","Forge","Anvil","Lampost","Log Storage","Food Container","Ore Chest","Cancel","Back")	//furnishings  L5
												L6 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//woodhouse  L6
												L7 = list("Foundation","Floor","Wall","Window","Door","Roof","Cancel","Back")	//stonehouse  L7
												L8 = list("Wooden Fort 3-Way Wall","Wooden Fort Central 4-Way Wall","Wooden Fort Mid-Section Wall","Cancel","Back")	//wood fort interior L8
												L9 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall","Cancel","Back")	//stone fort interior L9
												L10 = list("Wood","Iron","Bronze","Copper","Brass","Steel","Cancel","Back")	//lampost type L10
												//L11 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall")	//stone fort door L11

												//M << "<b><font color=silver>You've grown to understand more (Building Acuity: [M.brank])...!"
												return
											//return
											//else
												/*if(M.brank == 11)
													M << "<b><font color=silver>You've reached Max Build Rank!"
													build = list("House","Fort","Furnishings","Miscellaneous","Fire")	//build menu selection  build
													L0 = list("Wood","Stone")	//fort material type selection  L0
													L1 = list("Exterior","Door","Interior")	//wood fort section type selection  L1
													L2 = list("Exterior","Door","Interior")	//stone fort section type selection  L2
													L3 = list("Wood","Stone")	//house material type  L3
													L4 = list("Barricade")	//miscellaneous  L4
													L5 = list("Forge","Anvil","Lampost")	//furnishings  L5
													L6 = list("Foundation","Floor","Wall","Window","Door","Roof")	//woodhouse  L6
													L7 = list("Foundation","Floor","Wall","Window","Door","Roof")	//stonehouse  L7
													L8 = list("Wood Fort 3-Way Wall","Wood Fort Central 4-Way Wall","Wood Fort Mid-Section Wall")	//wood fort interior L8
													L9 = list("Stone Fort 3-Way Wall","Stone Fort Central 4-Way Wall","Stone Fort Mid-Section Wall")	//stone fort interior L9
													L10 = list("Wood","Iron","Bronze","Copper","Brass")	//lampost type L10
													return*/
												//if (M.brank>=10)
													//M << "<b><font color=silver>You've reached Max Build Rank!"
													//M.brank = 10
													//return

		//..()

	// buildlevel() - REMOVED: Function was only used for old building XP level-up checks
	// Building levels are now handled automatically by character.UpdateRankExp(RANK_BUILDING, amount)

mob/players/Special1/verb
	Delete_Turf(turf/T)
		//if(T.buildingowner == "[usr.key]")
		if(istype(T,/turf))
			switch(alert("Would you like to remove [T]?",,"Yes","No"))
				if("Yes")
					del(T)
				if("No")
					usr << "You Spare [T]."
		else usr.verbs -= /mob/players/Special1/verb/Delete_Object//usr << "You are not the building owner! [T.buildingowner]"
	Delete_Object(obj/T)
		//if(T.buildingowner == "[usr.key]")
		if(istype(T,/obj))
			switch(alert("Would you like to remove [T]?",,"Yes","No"))
				if("Yes")
					del(T)
				if("No")
					usr << "You Spare [T]."
					return
		else usr.verbs -= /mob/players/Special1/verb/Delete_Object//usr << "You are not the building owner! [T.buildingowner]"
	Spawn_Grass(var/turf/temperate/T in oview(3)) // so does this one
		if(istype(T,/turf/temperate)) // gotta check to be sure it is the right type of item
			del T
		else usr << "[T] Cannot be terraformed."

	Destroy_Wall(var/obj/O in oview(3)) // so does this one
		if(istype(O,/obj/Buildable/Walls)) // gotta check to be sure it is the right type of item
			del O
		else usr.verbs -= /mob/players/Special1/verb/Destroy_Wall//usr << "Selected: [O] Is not a Wall."

mob/players/verb
	Destroy_Property(obj/T in oview(3)) //fixed?
		set category=null
		set popup_menu=0
		if(istype(T,/obj))
			if(T.buildingowner==ckeyEx("[usr.key]"))

				switch(alert("Would you like to destroy [T]?",,"Yes","No"))
					if("Yes")
						//del(T.light)//need to setup proper checks if it actually has a light or sound attached
						//del(sound)
						//T.light.off()
						//unlistenSoundmob(T)
						del(T)
					if("No")
						usr << "You Spare [T]."
						return
			else
				usr.verbs -= /mob/players/verb/Destroy_Property
				//usr << "You are not the building owner! [T.buildingowner]"
				//return
		else usr.verbs -= /mob/players/verb/Destroy_Property
	/*SodGrass(var/turf/T in view(1)) // so does this one
		set category=null
		set popup_menu=1
		if(T.buildingowner == "[usr.key]")
			switch(alert("Would you like to Sod Grass [T] (Reset to default)?",,"Yes","No"))
				if("Yes")
					del(T)
				if("No")
					usr << "You Spare [T]."
		else usr << "You are not the building owner! [T.buildingowner]"*/
	/*Destroy_Owned_Property()
		var/obj/T = locate()
		if(T==null)
			usr<<"Nothing to destroy!"
			return
		else
			if(T in oview(usr,1) && T.buildingowner == "[usr.key]")
				for(T as obj in oview(usr,1))
					del(T)
			else
				return usr << "That isn't yours to destroy! [T.buildingowner]"*/
		//else
			//return usr << "You are in the afterlife and cannot presently manipulate physical objects."

obj
	//var/buildingowner = ""
	var/expgive
	var/HP
	stat
		icon = 'dmi/64/furnishings.dmi'
		icon_state = "statue"
		density = 1
	box
		icon = 'dmi/64/furnishings.dmi'
		icon_state = "scrate"
		density = 1
	pot
		icon = 'dmi/64/furnishings.dmi'
		icon_state = "pot"
		density = 1
	rug
		icon = 'dmi/64/castl.dmi'
		icon_state = "rug"
	Buildable
		Walls
			Click()
				set waitfor = 0
				if(get_dist(src,usr)<2&&get_dir(usr,src)==usr.dir)
					var/mob/players/Player = usr // define the player
					var/obj/Buildable/Walls/W = src // define the enemy
					if(Player.char_class<>"Builder")//&&"GM")
						Player<<"You need to be a Builder to destroy walls."
						return
					else
						if(Player.char_class=="Builder" && W in view(1)) // make sure that the person clicking is right by the emem
							if(istype(W,/obj/Buildable/Walls)&&Player.waiter > 0) //When the mob Clicks the enemies
								Player.Destroy(W)
							else
								sleep(Player.attackspeed)
						else
							if(Player.char_class=="GM" && W in view(1)) // make sure that the person clicking is right by the emem
								if(istype(W,/obj/Buildable/Walls)&&Player.waiter > 0) //When the mob Clicks the enemies
									Player.Destroy(W)
								else
									sleep(Player.attackspeed)
			//var/HP
			//var/expgive
			wall
				icon = 'dmi/64/wall.dmi'
				icon_state = "W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			nwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "N"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			swall
				icon = 'dmi/64/wall.dmi'
				icon_state = "S"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			ewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "E"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			nwwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "NWC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			newall
				icon = 'dmi/64/wall.dmi'
				icon_state = "NEC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			swwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SWC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			sewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SEC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			N3Wwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "N3W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			S3Wwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "S3W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			C4Wwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "C4W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			MIDnswall
				icon = 'dmi/64/wall.dmi'
				icon_state = "MIDns"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			MIDwewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "MIDwe"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			MIDCEwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "MIDCE"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			MIDCWwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "MIDCW"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

		//stone fort walls
			Swall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SW"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Snwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SN"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Sswall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SS"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Sewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SE"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Snwwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SNWC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Snewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SNEC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Sswwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SSWC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			Ssewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SSEC"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SN3Wwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SN3W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SS3Wwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SS3W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SC4Wwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SC4W"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SMIDnswall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SMIDns"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SMIDwewall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SMIDwe"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SMIDCEwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SMIDCE"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

			SMIDCWwall
				icon = 'dmi/64/wall.dmi'
				icon_state = "SMIDCW"
				density = 1
				//layer = 11
				opacity = 0
				HP = 100
				expgive = 15

		HouseWalls
			icon = 'dmi/64/wall.dmi'
			//var/disallow_in
			//var/disallow_out
			Cross(atom/movable/O)
				if(disallow_in)
					if(disallow_in & O.dir)
						return 0
					. = ..()

			Uncross(atom/movable/O)
				if(disallow_out)
					if(disallow_out & O.dir)
						return 0
					. = ..()
			wh1
				icon_state = "wh1"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = 5
				disallow_in = NORTH
				disallow_out = SOUTH
				expgive = 25
			wh2
				icon_state = "wh2"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH | EAST
				disallow_out = NORTH | WEST
				expgive = 25
			wh3
				icon_state = "wh3"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH | WEST
				disallow_out = NORTH | EAST
				expgive = 25
			wh4
				icon_state = "wh4"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = NORTH | EAST
				disallow_out = SOUTH | WEST
				expgive = 25
			wh5
				icon_state = "wh5"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = NORTH | WEST
				disallow_out = SOUTH | EAST
				expgive = 25
			wh6
				icon_state = "wh6"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = EAST
				disallow_out = WEST
				expgive = 25
			wh7
				icon_state = "wh7"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = WEST
				disallow_out = EAST
				expgive = 25
			wh8
				icon_state = "wh8"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH
				disallow_out = NORTH
				expgive = 25
			whwf
				icon_state = "whwf"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = NORTH
				disallow_out = SOUTH
				expgive = 25
			whwr
				icon_state = "whwr"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = WEST
				disallow_out = EAST
				expgive = 25
			whwl
				icon_state = "whwl"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = EAST
				disallow_out = WEST
				expgive = 25
			whwt
				icon_state = "whwt"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH
				disallow_out = NORTH
				expgive = 25
			//whroof
				//icon_state = "whroof"
				//density = 1
			//	opacity = 0
				//buildingowner = ""
			sh1
				icon_state = "sh1"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = 5
				disallow_in = NORTH
				disallow_out = SOUTH
				expgive = 35
			sh2
				icon_state = "sh2"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH | EAST
				disallow_out = NORTH | WEST
				expgive = 35
			sh3
				icon_state = "sh3"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH | WEST
				disallow_out = NORTH | EAST
				expgive = 35
			sh4
				icon_state = "sh4"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = NORTH | EAST
				disallow_out = SOUTH | WEST
				expgive = 35
			sh5
				icon_state = "sh5"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = NORTH | WEST
				disallow_out = SOUTH | EAST
				expgive = 35
			sh6
				icon_state = "sh6"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = EAST
				disallow_out = WEST
				expgive = 35
			sh7
				icon_state = "sh7"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = WEST
				disallow_out = EAST
				expgive = 35
			sh8
				icon_state = "sh8"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH
				disallow_out = NORTH
				expgive = 35
			shwf
				icon_state = "shwf"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = NORTH
				disallow_out = SOUTH
				expgive = 35
			shwr
				icon_state = "shwr"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = WEST
				disallow_out = EAST
				expgive = 35
			shwl
				icon_state = "shwl"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = EAST
				disallow_out = WEST
				expgive = 35
			shwt
				icon_state = "shwt"
				density = 0
				opacity = 0
				mouse_opacity = 0
				buildingowner = ""
				layer = MOB_LAYER+3
				disallow_in = SOUTH
				disallow_out = NORTH
				expgive = 35
		//verb //...
		//	Destroy() //...
		//		//set category = "Commands"
		//		set src in oview(1) //...
		//		Destroying(M) //calls the mining proc
obj
	var
		disallow_in
		disallow_out
	Buildable
		Ground
			woodfloor
				icon = 'dmi/64/build.dmi'
				icon_state = "woodfloor"
				density = 0
				opacity = 0
				buildingowner = ""
				expgive = 5
			stonefloor
				icon = 'dmi/64/build.dmi'
				icon_state = "stonefloor"
				density = 0
				opacity = 0
				buildingowner = ""
				expgive = 15
			pcfloor
				icon = 'dmi/64/build.dmi'
				icon_state = "pcfloor"
				density = 0
				opacity = 0
				buildingowner = ""
				expgive = 20

		Barricades
			barricaden
				density = 1
				icon = 'dmi/64/creation.dmi'
				icon_state = "barricaden"
				disallow_in = SOUTH
				disallow_out = NORTH
				expgive = 5
			barricades
				density = 1
				icon = 'dmi/64/creation.dmi'
				icon_state = "barricadee"
				disallow_in = NORTH
				disallow_out = SOUTH
				expgive = 5
			barricadee
				density = 1
				icon = 'dmi/64/creation.dmi'
				icon_state = "barricades"
				disallow_in = WEST
				disallow_out = EAST
				expgive = 5
			barricadew
				density = 1
				icon = 'dmi/64/creation.dmi'
				icon_state = "barricadew"
				disallow_in = EAST
				disallow_out = WEST
				expgive = 5
	sprout
		density = 1
		icon = 'dmi/64/tree.dmi'
		icon_state = "sprout1"
	chair
		icon = 'dmi/64/furnishings.dmi'
		icon_state = "chair"
		expgive = 5
	table
		density = 1
		icon = 'dmi/64/furnishings.dmi'
		icon_state = "table"
		expgive = 5
	accesspoint
		density = 1
		opacity = 0
		mouse_opacity = 1
		icon = 'dmi/64/cli.dmi'
		icon_state = "cli"
		name = "Yasumidokoro"
		Click()
			usr.loc=locate(rand(119,125),rand(92,99),2)

	accesspoint2
		density = 1
		opacity = 0
		mouse_opacity = 1
		icon = 'dmi/64/cli.dmi'
		icon_state = "cli"
		name = "Combat Area"
		Click()
			usr.loc=locate(rand(1,139),rand(1,149),1)
	//waterfor(var/turf/Grass/G in world)
		//icon_state = "water"
	mountain1
		opacity = 0
		density = 1
		icon_state = "Mountain1"
	exits
		icon = 'dmi/64/blank.dmi'
		exit1
			Click()
				usr.loc = locate(4,6,1)
		oneway
			icon = 'dmi/64/blank.dmi'
			density = 1
			disallow_in
			disallow_out
		Bump(obj/O)
			if(istype(O,/obj/exits/oneway))
				if(usr.dir == O.dir)
					O.density = 0
					step(usr,usr.dir)
					O.density = 1
	Z
		icon = 'dmi/64/blank.dmi'
		sign
			var/msg
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "sign"
			density = 1
		//fire
		//	icon = 'dmi/64/blank.dmi'
		//	density = 1

	N
		icon = 'dmi/64/blank.dmi'
		density = 1
		roundtable
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "roundtable"
			expgive = 5
		firewood
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "firewood"
			expgive = 5
		stove
			icon = 'dmi/64/creation.dmi'
			icon_state = "stove"
			expgive = 35
		forge
			icon = 'dmi/64/creation.dmi'
			icon_state = "forge"
			expgive = 45
		ltab
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "ltab"
			expgive = 5
		ltabl
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "ltabl"
			expgive = 5
		ltabr
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "ltabr"
			expgive = 5
		throne
			icon = 'dmi/64/Castl.dmi'
			icon_state = "throne"
			expgive = 5
		signs
			Posts
				signpostnr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "sptr"
					density = 1
					expgive = 5
				signpostnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "sptl"
					density = 1
					expgive = 5
				signpostsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "spbsr"
					density = 1
					expgive = 5
				signpostsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "spbsl"
					density = 1
					expgive = 5
				signpostte
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "spsr"
					density = 1
					expgive = 5
				signposttw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "spsl"
					density = 1
					expgive = 5
				signpostbe
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "spbr"
					density = 1
					expgive = 5
				signpostbw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "spbl"
					density = 1
					expgive = 5
			Inn
				innsignnr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "innsbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				innsignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "innsbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				innsignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "innstr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				innsignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "innstl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				innsigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "innsr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				innsignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "innsl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
			Inventory
				itemsignr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "isbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				itemsignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "isbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				itemsignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "istr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				itemsignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "istl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				itemsigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "isl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				itemsignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "isr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
			Weapon
				weapsignr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "wsbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				weapsignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "wsbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				weapsignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "wstr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				weapsignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "wstl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				weapsigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "wsl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				weapsignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "wsr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
			Armor
				armsignnr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "asbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				armsignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "asbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				armsignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "astr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				armsignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "astl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				armsigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "asl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				armsignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "asr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
			Bank
				banksignnr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "bnksbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				banksignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "bnksbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				banksignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "bnkstr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				banksignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "bnkstl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				banksigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "bnksl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				banksignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "bnksr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
			Pub
				pubsignnr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "pubsbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				pubsignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "pubsbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				pubsignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "pubstr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				pubsignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "pubstl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				pubsigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "pubsl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				pubsignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "pubsr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
			Magi
				magsignnr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "atsbr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				magsignnl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "atsbl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				magsignsr
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "atstr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				magsignsl
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "atstl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				magsigne
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "atsl"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
				magsignw
					icon = 'dmi/64/furnishings.dmi'
					icon_state = "atsr"
					density = 0
					layer = FLY_LAYER+4
					expgive = 5
		bedtop
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "bed top"
			expgive = 5
		bedbottom
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "bed"
			expgive = 5
		fruitrbb
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "fruitrbb"
			expgive = 5
		fruitbbb
			icon = 'dmi/64/furnishings.dmi'
			icon_state = "fruitbbb"
			expgive = 5

turf
	//var/buildingowner = ""
	UndergroundDitch
		uditchSN
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSN"
			dir = NORTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		uditchSS
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSS"
			dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchSE
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSE"
			dir = EAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		uditchSW
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSW"
			dir = WEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchCNE
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchCNE"
			dir = NORTHEAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		uditchCNW
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchCNW"
			dir = NORTHWEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchCSE
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchCSE"
			//dir = SOUTHEAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		uditchCSW
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchCSW"
			dir = SOUTHWEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchEXN
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchEXN"
			dir = NORTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchEXS
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchEXS"
			dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchEXE
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchEXE"
			dir = EAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchEXW
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchEXW"
			dir = WEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchPCWE
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchPCWE"
			//dir = SOUTH
		uditchPCNS
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchPCNS"
			//dir = SOUTH
		uditchSNWC
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSNWC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchSNEC
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSNEC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchSSWC
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSSWC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		uditchSSEC
			icon = 'dmi/64/build.dmi'
			icon_state = "uditchSSEC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
	SnowDitch
		sditchSN
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSN"
			dir = NORTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		sditchSS
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSS"
			dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchSE
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSE"
			dir = EAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		sditchSW
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSW"
			dir = WEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchCNE
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchCNE"
			dir = NORTHEAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		sditchCNW
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchCNW"
			dir = NORTHWEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchCSE
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchCSE"
			//dir = SOUTHEAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

		sditchCSW
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchCSW"
			dir = SOUTHWEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchEXN
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchEXN"
			dir = NORTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchEXS
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchEXS"
			dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchEXE
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchEXE"
			dir = EAST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchEXW
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchEXW"
			dir = WEST
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchPCWE
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchPCWE"
			//dir = SOUTH
		sditchPCNS
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchPCNS"
			//dir = SOUTH
		sditchSNWC
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSNWC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchSNEC
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSNEC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchSSWC
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSSWC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0
		sditchSSEC
			icon = 'dmi/64/build.dmi'
			icon_state = "sditchSSEC"
			//dir = SOUTH
			elevel = 0.5
			Enter(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

			Exit(atom/movable/e)
				if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
				else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
				else return 0

	Hill
		GrassHill
			ghillSN
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSN"
				mouse_opacity=1
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ghillSS
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSS"
				mouse_opacity=1
				//dir = SOUTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSE"
				//dir = EAST | WEST
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

			ghillSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSW"
				//dir = WEST
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0
			ghillSCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSCNE"
				//dir = NORTHEAST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ghillSCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSCNW"
				//dir = NORTHWEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillSCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSCSE"
				//dir = SOUTHEAST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ghillSCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillSCSW"
				//dir = SOUTHWEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillPC
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPC"
				//dir = SOUTH
				elevel = 2.0
			ghillPN
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPN"
				//dir = SOUTH
				elevel = 2.0
			ghillPS
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPS"
				//dir = SOUTH
				elevel = 2.0
			ghillPE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPE"
				//dir = SOUTH
				elevel = 2.0
			ghillPW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPW"
				//dir = SOUTH
				elevel = 2.0
			ghillPCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPCNE"
				//dir = SOUTH
				elevel = 2.0
			ghillPCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPCNW"
				//dir = SOUTH
				elevel = 2.0
			ghillPCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPCSE"
				//dir = SOUTH
				elevel = 2.0
			ghillPCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillPCSW"
				//dir = SOUTH
				elevel = 2.0
			ghillCN
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCN"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCST
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCST"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCS
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCS"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ghillCE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCE"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCW"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillCSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillTNE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillTNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillTNW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillTNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillTSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillTSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ghillTSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ghillTSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
		SnowHill
			shillSN
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSN"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			shillSS
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSS"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillSE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSE"
				//dir = NORTH
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

			shillSW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSW"
				//dir = NORTH
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0
			shillSCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSCNE"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			shillSCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSCNW"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillSCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSCSE"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			shillSCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillSCSW"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillPC
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPC"
				//dir = SOUTH
				elevel = 2.0
			shillPN
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPN"
				//dir = SOUTH
				elevel = 2.0
			shillPS
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPS"
				//dir = SOUTH
				elevel = 2.0
			shillPE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPE"
				//dir = SOUTH
				elevel = 2.0
			shillPW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPW"
				//dir = SOUTH
				elevel = 2.0
			shillPCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPCNE"
				//dir = SOUTH
				elevel = 2.0
			shillPCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPCNW"
				//dir = SOUTH
				elevel = 2.0
			shillPCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPCSE"
				//dir = SOUTH
				elevel = 2.0
			shillPCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillPCSW"
				//dir = SOUTH
				elevel = 2.0
			shillCAVESN
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCAVESN"
				//dir = SOUTH
				elevel = 2.0
			shillCN
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCN"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillCS
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCS"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			shillCE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCE"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillCW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCW"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillCSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillTNE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillTNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillTNW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillTNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillTSE
				icon = 'dmi/64/build.dmi'
				icon_state = "shillTSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			shillTSW
				icon = 'dmi/64/build.dmi'
				icon_state = "shillTSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
		ClastHill
			chillSN
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSN"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			chillSS
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSS"
				//dir = NORTH
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillSE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSE"
				//dir = EAST | WEST
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

			chillSW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSW"
				//dir = EAST | WEST
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0
			chillSCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSCNE"
				dir = NORTHEAST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			chillSCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSCNW"
				dir = NORTHWEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillSCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSCSE"
				dir = SOUTHEAST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			chillSCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillSCSW"
				dir = SOUTHWEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillPC
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPC"
				//dir = SOUTH
				elevel = 2.0
			chillPN
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPN"
				//dir = SOUTH
				elevel = 2.0
			chillPS
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPS"
				//dir = SOUTH
				elevel = 2.0
			chillPE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPE"
				//dir = SOUTH
				elevel = 2.0
			chillPW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPW"
				//dir = SOUTH
				elevel = 2.0
			chillPCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPCNE"
				//dir = SOUTH
				elevel = 2.0
			chillPCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPCNW"
				//dir = SOUTH
				elevel = 2.0
			chillPCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPCSE"
				//dir = SOUTH
				elevel = 2.0
			chillPCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillPCSW"
				//dir = SOUTH
				elevel = 2.0
			chillCAVESN
				icon = 'dmi/64/build.dmi'
				icon_state = "hhillCAVESN"
				//dir = SOUTH
				elevel = 2.0
			chillCN
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCN"
				//dir = SOUTH
				elevel = 2.0
				//borders = NORTH
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillCS
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCS"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			chillCE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCE"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillCW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCW"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillCSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillTNE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillTNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillTNW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillTNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillTSE
				icon = 'dmi/64/build.dmi'
				icon_state = "chillTSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			chillTSW
				icon = 'dmi/64/build.dmi'
				icon_state = "chillTSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCN
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCN"
				//dir = SOUTH
				elevel = 2.0
				//borders = NORTH
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCS
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCS"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			pohhillCE
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCE"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCW
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCW"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillCSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillTNE
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillTNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillTNW
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillTNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillTSE
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillTSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			pohhillTSW
				icon = 'dmi/64/build.dmi'
				icon_state = "pohhillTSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
	Ground
		water2
			icon = 'dmi/64/build.dmi'
			icon_state = "water2"
			density = 1
			opacity = 0
			buildingowner = ""
		/*water2C
			icon = 'dmi/64/build.dmi'
			icon_state = "water2C"
			density = 1
			opacity = 0
			buildingowner = ""
		water2E
			icon = 'dmi/64/build.dmi'
			icon_state = "water2E"
			density = 1
			opacity = 0
			buildingowner = ""
		water2W
			icon = 'dmi/64/build.dmi'
			icon_state = "water2W"
			density = 1
			opacity = 0
			buildingowner = ""
		water2N
			icon = 'dmi/64/build.dmi'
			icon_state = "water2N"
			density = 1
			opacity = 0
			buildingowner = ""
		water2S
			icon = 'dmi/64/build.dmi'
			icon_state = "water2S"
			density = 1
			opacity = 0
			buildingowner = ""
		water2B
			icon = 'dmi/64/build.dmi'
			icon_state = "water2B"
			density = 1
			layer = 4
			buildingowner = ""*/
		blue
			icon_state = "blue"
		brown
			icon_state = "brown"
		black
			density = 1
		//dirt
		//	icon = 'dmi/64/build.dmi'
		//	icon_state = "dirt"
	//Landscaping
obj
	Landscaping
		Ditch
			ditchSN
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSN"
				dir = NORTH
				elevel = 0.5

				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ditchSS
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSS"
				dir = SOUTH
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSE"
				dir = EAST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ditchSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSW"
				dir = WEST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchCNE"
				dir = NORTHEAST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ditchCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchCNW"
				dir = NORTHWEST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchCSE"
				//dir = SOUTHEAST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			ditchCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchCSW"
				dir = SOUTHWEST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchEXN
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchEXN"
				dir = NORTH
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchEXS
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchEXS"
				//dir = SOUTH
				elevel = 0.5
				/*Enter(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0*/
			ditchEXE
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchEXE"
				dir = EAST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchEXW
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchEXW"
				dir = WEST
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel <= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel >= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchPCWE
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchPCWE"
				//dir = SOUTH
			ditchPCNS
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchPCNS"
				//dir = SOUTH
			ditchSNWC
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSNWC"
				//dir = SOUTH
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchSNEC
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSNEC"
				//dir = SOUTH
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchSSWC
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSSWC"
				//dir = SOUTH
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			ditchSSEC
				icon = 'dmi/64/build.dmi'
				icon_state = "ditchSSEC"
				//dir = SOUTH
				elevel = 0.5
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

		Dirt
			icon = 'dmi/64/build.dmi'
			icon_state = "dirt"
		Hill
			hillSN
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSN"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			hillSS
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSS"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillSE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSE"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

			hillSW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSW"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel /*&& src.dir == e.dir*/) return ..()
					else if(src.elevel <= e.elevel /*&& src.dir == Odir(e.dir)*/) return ..()
					else return 0
			hillSCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSCNE"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			hillSCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSCNW"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillSCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSCSE"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			hillSCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillSCSW"
				//dir = NORTH
				//borders = EAST | WEST
				elevel = 1.0
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillPC
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPC"
				//dir = SOUTH
				elevel = 2.0
			hillPN
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPN"
				//dir = SOUTH
				elevel = 2.0
			hillPS
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPS"
				//dir = SOUTH
				elevel = 2.0
			hillPE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPE"
				//dir = SOUTH
				elevel = 2.0
			hillPW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPW"
				//dir = SOUTH
				elevel = 2.0
			hillPCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPCNE"
				//dir = SOUTH
				elevel = 2.0
			hillPCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPCNW"
				//dir = SOUTH
				elevel = 2.0
			hillPCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPCSE"
				//dir = SOUTH
				elevel = 2.0
			hillPCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillPCSW"
				//dir = SOUTH
				elevel = 2.0
			hillCN
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCN"
				elevel = 2.0
				//dir = EAST|WEST
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillCS
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCS"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTH | SOUTH
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

			hillCE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCE"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillCW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCW"
				//dir = SOUTH
				elevel = 2.0
				borders = EAST | WEST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillCNE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillCNW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillCSE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillCSW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillCSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillTNE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillTNE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillTNW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillTNW"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillTSE
				icon = 'dmi/64/build.dmi'
				icon_state = "hillTSE"
				//dir = SOUTH
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
			hillTSW
				icon = 'dmi/64/build.dmi'
				icon_state = "hillTSW"
				elevel = 2.0
				borders = NORTHEAST | SOUTHWEST | NORTHWEST | SOUTHEAST
				Enter(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0
				Exit(atom/movable/e)
					if(src.elevel >= e.elevel && src.dir == e.dir) return ..()
					else if(src.elevel <= e.elevel && src.dir == Odir(e.dir)) return ..()
					else return 0

		Road
			DirtRoad
				NSRoad
					icon = 'dmi/64/build.dmi'
					icon_state = "RNS"
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				EWRoad
					icon_state = "REW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				NECRoad
					icon_state = "RCNE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				NWCRoad
					icon_state = "RCNW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				SECRoad
					icon_state = "RCSE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				SWCRoad
					icon_state = "RCSW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				R4WRoad
					icon_state = "R4W"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				R3WNRoad
					icon_state = "R3WN"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				R3WSRoad
					icon_state = "R3WS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				R3WERoad
					icon_state = "R3WE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				R3WWRoad
					icon_state = "R3WW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
			StoneRoad
				SNSRoad
					icon_state = "SRNS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				SEWRoad
					icon_state = "SREW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				SNECRoad
					icon_state = "SRCNE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SNWCRoad
					icon_state = "SRCNW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SSECRoad
					icon_state = "SRCSE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SSWCRoad
					icon_state = "SRCSW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SR4WRoad
					icon_state = "SR4W"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SR3WNRoad
					icon_state = "SR3WN"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SR3WSRoad
					icon_state = "SR3WS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SR3WERoad
					icon_state = "SR3WE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				SR3WWRoad
					icon_state = "SR3WW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STRNSRoad
					icon_state = "STRNS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STREWRoad
					icon_state = "STREW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STRNECRoad
					icon_state = "STRCNE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STRNWCRoad
					icon_state = "STRCNW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STRSECRoad
					icon_state = "STRCSE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STRSWCRoad
					icon_state = "STRCSW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STR4WRoad
					icon_state = "STR4W"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STR3WNRoad
					icon_state = "STR3WN"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STR3WSRoad
					icon_state = "STR3WS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STR3WERoad
					icon_state = "STR3WE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				STR3WWRoad
					icon_state = "STR3WW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
			WoodRoad
				WRNSRoad
					icon_state = "WRNS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				WREWRoad
					icon_state = "WREW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					buildingowner = ""
					layer = 3
				WRNECRoad
					icon_state = "WRCNE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WRNWCRoad
					icon_state = "WRCNW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WRSECRoad
					icon_state = "WRCSE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WRSWCRoad
					icon_state = "WRCSW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WR4WRoad
					icon_state = "WR4W"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WR3WNRoad
					icon_state = "WR3WN"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WR3WSRoad
					icon_state = "WR3WS"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WR3WERoad
					icon_state = "WR3WE"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
				WR3WWRoad
					icon_state = "WR3WW"
					icon = 'dmi/64/build.dmi'
					density = 0
					opacity = 0
					layer = 3
turf
	Road
//stone road

//HCASTLEROAD
		Clast
			HSTRNSRoad
				icon_state = "HSTRNS"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTREWRoad
				icon_state = "HSTREW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTRNECRoad
				icon_state = "HSTRCNE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTRNWCRoad
				icon_state = "HSTRCNW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTRSECRoad
				icon_state = "HSTRCSE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTRSWCRoad
				icon_state = "HSTRCSW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTR4WRoad
				icon_state = "HSTR4W"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTR3WNRoad
				icon_state = "HSTR3WN"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTR3WSRoad
				icon_state = "HSTR3WS"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTR3WERoad
				icon_state = "HSTR3WE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			HSTR3WWRoad
				icon_state = "HSTR3WW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
		Sand
			bNSRoad
				icon = 'dmi/64/build.dmi'
				icon_state = "bRNS"
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bEWRoad
				icon_state = "bREW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bNECRoad
				icon_state = "bRCNE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bNWCRoad
				icon_state = "bRCNW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bSECRoad
				icon_state = "bRCSE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bSWCRoad
				icon_state = "bRCSW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bR4WRoad
				icon_state = "bR4W"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bR3WNRoad
				icon_state = "bR3WN"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bR3WSRoad
				icon_state = "bR3WS"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bR3WERoad
				icon_state = "bR3WE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3
			bR3WWRoad
				icon_state = "bR3WW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				buildingowner = ""
				layer = 3

			/*WRNSRoad
				icon_state = "WRNS"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WREWRoad
				icon_state = "WREW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WRNECRoad
				icon_state = "WRCNE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WRNWCRoad
				icon_state = "WRCNW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WRSECRoad
				icon_state = "WRCSE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WRSWCRoad
				icon_state = "WRCSW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WR4WRoad
				icon_state = "WR4W"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WR3WNRoad
				icon_state = "WR3WN"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WR3WSRoad
				icon_state = "WR3WS"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WR3WERoad
				icon_state = "WR3WE"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3
			WR3WWRoad
				icon_state = "WR3WW"
				icon = 'dmi/64/build.dmi'
				density = 0
				opacity = 0
				layer = 3*/
