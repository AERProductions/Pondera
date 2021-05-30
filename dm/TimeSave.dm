
var/ambientload=0
//var/tstateload=0
/*var/LogAmountload=0
var/SproutAmountload=0
var/FruitAmountload=0
var/SeedAmountload=0
var/VegeAmountload=0
var/GrainAmountload=0
var/OreAmountload=0*/
var
	SPs
	MPs
	SMs
	SBs

proc
	TimeSave()
		var/savefile/F = new("timesave.sav")
		F["SP"] << SP
		F["MP"] << MP
		F["SM"] << SM
		F["SB"] << SB
		F["time_of_day"] << time_of_day
		F["hour"] << hour
		F["ampm"] << ampm
		F["minute1"] << minute1
		F["minute2"] << minute2
		F["day"] << day
		F["month"] << month
		F["year"] << year
		F["a"] << a
		F["wo"] << wo
		F["ambient"] << lighting.ambient
		F["vgrowstage"] << vgrowstage
		F["ggrowstage"] << ggrowstage
		F["bgrowstage"] << bgrowstage//bush growth stage
		F["growstage"] << growstage//tree growing stage
		/*F["LogAmount"] << Treesgs.LogAmount//tree log amount
		F["SproutAmount"] << Treesgs.SproutAmount//set for trees
		F["FruitAmount"] << Plantsgs.FruitAmount//bush fruit amount
		F["SeedAmount"] << Plantsgs.SeedAmount//set for bushes
		F["VegeAmount"] << Plantsgs.VegeAmount//bush fruit amount
		F["GrainAmount"] << Plantsgs.GrainAmount//bush fruit amount
		F["OreAmount"] << Oregs.OreAmount
		F["orestage"] << orestage*/


	TimeLoad()
		if(fexists("timesave.sav"))
			var/savefile/F = new("timesave.sav")
			F["SP"] >> SP
			F["MP"] >> MP
			F["SM"] >> SM
			F["SB"] >> SB
			F["time_of_day"] >> time_of_day
			F["hour"] >> hour
			F["ampm"] >> ampm
			F["minute1"] >> minute1
			F["minute2"] >> minute2
			F["day"] >> day
			F["month"] >> month
			F["year"] >> year
			F["a"] >> a
			F["wo"] >> wo
			F["ambient"] >> ambientload
			F["vgrowstage"] >> vgrowstage
			F["ggrowstage"] >> ggrowstage
			F["bgrowstage"] >> bgrowstage//bush growing stage
			F["growstage"] >> growstage//tree growing stage
			/*F["LogAmount"] >> LogAmountload//tree log amount
			F["SproutAmount"] >> SproutAmountload//set for trees
			F["FruitAmount"] >> FruitAmountload//bush fruit amount
			F["SeedAmount"] >> SeedAmountload//set for bushes
			F["VegeAmount"] >> VegeAmountload//bush fruit amount
			F["GrainAmount"] >> GrainAmountload//bush fruit amount
			F["OreAmount"] >> OreAmountload
			F["orestage"] >> orestage*/



//			switch(time_of_day)
//				if(4)
//					ambient=0

//OreLoad doesn't work -- all I want these to do is restore the amount of ore/logs/fruit/etc from the trees/bushes/ore
//and I want those variables to be generated randomly on first creation, but not every time.
//I replicated the amount system for ore but the oreamount is always null or 0

//	OreLoad()
		//for(var/obj/Rocks/X in orelist)
			//X.OreAmount = OreAmountload
			//X.orestate = orestage
			//X.Orestateload()
	//SetMode()
		//world << "Basecamp login SP [SP] | MP [MP] | SB [SB] | SM [SM] && SPs [SPs] | MPs [MPs] | SBs [SBs] | SMs [SMs]"

	GrowBushes()
//		bgrowstate = bgrowstage
		for(var/obj/Plants/X in bushlist)
			X.bgrowstate = bgrowstage
			X.vgrowstate = vgrowstage
			X.ggrowstate = ggrowstage
			//X.FruitAmount = FruitAmountload
			//X.SeedAmount = SeedAmountload
			//X.VegeAmount = VegeAmountload
			//X.GrainAmount = GrainAmountload
			X.UpdatePlantPic()
	GrowTrees()
//		growstate = growstage
		for(var/obj/plant/ueiktree/X in treelist)
			X.growstate=growstage
			//X.LogAmount = LogAmountload
			//X.SproutAmount = SproutAmountload
			X.UpdateTreePic()
