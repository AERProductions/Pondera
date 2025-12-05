// dm/TimeSave.dm — Global time/resource state serialization and growth stage management.

// Global basecamp resources (singular/plural forms).
var
	SPs
	MPs
	SMs
	SBs

// Serialize global time and resource state to timesave.sav.
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
		F["vgrowstage"] << vgrowstage
		F["ggrowstage"] << ggrowstage
		F["bgrowstage"] << bgrowstage
		F["growstage"] << growstage
		/*F["LogAmount"] << Treesgs.LogAmount//tree log amount
		F["SproutAmount"] << Treesgs.SproutAmount//set for trees
		F["FruitAmount"] << Plantsgs.FruitAmount//bush fruit amount
		F["SeedAmount"] << Plantsgs.SeedAmount//set for bushes
		F["VegeAmount"] << Plantsgs.VegeAmount//bush fruit amount
		F["GrainAmount"] << Plantsgs.GrainAmount//bush fruit amount
		F["OreAmount"] << Oregs.OreAmount
		F["orestage"] << orestage*/

	// Deserialize global time and resource state from timesave.sav.
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
			F["vgrowstage"] >> vgrowstage
			F["ggrowstage"] >> ggrowstage
			F["bgrowstage"] >> bgrowstage
			F["growstage"] >> growstage
			/*F["LogAmount"] >> LogAmountload//tree log amount
			F["SproutAmount"] >> SproutAmountload//set for trees
			F["FruitAmount"] >> FruitAmountload//bush fruit amount
			F["SeedAmount"] >> SeedAmountload//set for bushes
			F["VegeAmount"] >> VegeAmountload//bush fruit amount
			F["GrainAmount"] >> GrainAmountload//bush fruit amount
			F["OreAmount"] >> OreAmountload
			F["orestage"] >> orestage*/

	// Update growth stages for all bush plants in the world.
	GrowBushes()
		for(var/obj/Plants/X in bushlist)
			X.bgrowstate = bgrowstage
			X.vgrowstate = vgrowstage
			X.ggrowstate = ggrowstage
			X.UpdatePlantPic()

	// Update growth stages for all tree plants in the world.
	GrowTrees()
		for(var/obj/plant/ueiktree/X in treelist)
			X.growstate=growstage
			X.UpdateTreePic()
