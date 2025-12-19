// PLANT_SOIL_QUALITY_INTEGRATION.dm
// Phase A patch: Connects soil quality to plant harvest yields
// Integrates SoilSystem modifiers into vegetable and grain harvests

/**
 * Patch: Vegetable harvesting now applies soil quality multiplier
 * Rich soil = 20% more vegetables
 * Basic soil = normal yield (1.0x)
 * Depleted soil = 50% yield (0.5x, rounds to 0)
 */
/obj/plant/vegetables
	verb/PickV()
		set src in oview(1)
		set category = "IC"
		set name = "Harvest"

		var/mob/players/M = usr
		if(M.client == null)
			M << "You aren't logged in."
			return

		M.stamina -= 3
		M.updateST()
		
		if(prob(Rarity+grank))
			M << "You harvested [VegeType]!"
			// NEW: Apply soil quality modifier
			var/soil_type = src.loc.soil_type || SOIL_BASIC
			var/yield_modifier = GetSoilYieldModifier(soil_type)
			var/yield_amount = round(yield_modifier)
			for(var/i = 1; i <= yield_amount; i++)
				new /obj/food/vegetable(M)
			new /obj/seed(M)
			del(src)

/**
 * Patch: Grain harvesting now applies soil quality multiplier
 * Rich soil = 20% more grain
 * Basic soil = normal yield (1.0x)
 * Depleted soil = 50% yield (0.5x, rounds to 0)
 */
/obj/plant/grains
	verb/PickG()
		set src in oview(1)
		set category = "IC"
		set name = "Harvest"

		var/mob/players/M = usr
		if(M.client == null)
			M << "You aren't logged in."
			return

		M.stamina -= 3
		M.updateST()
		
		if(prob(Rarity+grank))
			M << "You harvested [GrainType]!"
			// NEW: Apply soil quality modifier
			var/soil_type = src.loc.soil_type || SOIL_BASIC
			var/yield_modifier = GetSoilYieldModifier(soil_type)
			var/yield_amount = round(yield_modifier)
			for(var/i = 1; i <= yield_amount; i++)
				new /obj/food/grain(M)
			new /obj/seed(M)
			del(src)
