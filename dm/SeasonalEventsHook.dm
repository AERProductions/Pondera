/**
 * SeasonalEventsHook.dm - World events triggered by season transitions
 * 
 * Features:
 * - Seasonal event announcements
 * - System modulation (crop growth rates, prices, animal behavior)
 * - Statistics tracking (crops planted, harvests, animals)
 * - Cosmetic effects and NPC behavior changes
 * 
 * Seasonal Mechanics:
 * - Spring: Planting festival, increased growth, breeding season
 * - Summer: Harvest abundance, high animal production, heat stress
 * - Autumn: Final harvest, soil recovery, preservation season
 * - Winter: Scarcity, survival challenge, reduced production
 * 
 * Integration:
 * - Hook into DayNight.dm month change detection
 * - Modulate system parameters globally
 * - Broadcast announcements to all players
 * - Track statistics for analytics
 */

// ============================================================================
// SEASONAL EVENT STATE
// ============================================================================

var/global/last_season_event = "none"        // Track last event fired
var/global/spring_event_active = FALSE
var/global/summer_event_active = FALSE
var/global/autumn_event_active = FALSE
var/global/winter_event_active = FALSE

var/global/list/seasonal_stats = list(
	"spring_crops_planted" = 0,
		"summer_harvests" = 0,
		"autumn_crops_planted" = 0,
		"winter_survivaldays" = 0,
		"animals_born" = 0,
		"animals_slaughtered" = 0,
	)

// ============================================================================
// SEASONAL EVENT PROCESSOR
// ============================================================================

/proc/ProcessSeasonalEvents()
	/**
	 * Main entry point - called when season changes
	 * Checks current global.season and fires appropriate event
	 * 
	 * INTEGRATION NOTE:
	 * Call this from DayNight.dm when global.season changes:
	 * if(new_season != global.season) ProcessSeasonalEvents()
	 */
	
	if(!global.season)
		return
	
	// Update seasonal modifiers (apply to actual game systems)
	UpdateSeasonalModifiersForCurrentSeason()
	
	switch(global.season)
		if("Spring")
			if(!spring_event_active)
				OnSeasonSpring()
				spring_event_active = TRUE
				summer_event_active = FALSE
				autumn_event_active = FALSE
				winter_event_active = FALSE
		
		if("Summer")
			if(!summer_event_active)
				OnSeasonSummer()
				spring_event_active = FALSE
				summer_event_active = TRUE
				autumn_event_active = FALSE
				winter_event_active = FALSE
		
		if("Autumn")
			if(!autumn_event_active)
				OnSeasonAutumn()
				spring_event_active = FALSE
				summer_event_active = FALSE
				autumn_event_active = TRUE
				winter_event_active = FALSE
		
		if("Winter")
			if(!winter_event_active)
				OnSeasonWinter()
				spring_event_active = FALSE
				summer_event_active = FALSE
				autumn_event_active = FALSE
				winter_event_active = TRUE

/proc/OnSeasonSpring()
	/**
	 * Spring Festival begins!
	 * - Planting season activates
	 * - Crop growth rates increase (+15%)
	 * - Breeding season for livestock (80% success)
	 * - Seed vendors appear in towns
	 * - Food prices increase (low availability)
	 */
	
	world << "\n<span style='color: #00FF00'><b>═══════════════════════════════════════</b></span>"
	world << "<span style='color: #00FF00'><b>🌱 THE SPRING FESTIVAL BEGINS! 🌱</b></span>"
	world << "<span style='color: #00FF00'><b>The earth awakens from winter's slumber.</b></span>"
	world << "<span style='color: #00FF00'><b>═══════════════════════════════════════</b></span>\n"
	
	// Modulate system parameters
	// global.crop_growth_modifier = 1.15  // TODO: Integrate with farming system
	// global.breeding_season_active = TRUE  // TODO: Integrate with LivestockSystem
	// global.breeding_success_rate = 80  // High success
	
	// Food price scaling
	// global.food_price_modifier = 1.3  // TODO: Integrate with DynamicMarketPricingSystem
	
	// Effect messaging
	for(var/mob/players/M in world)
		if(M.client)
			M << "<span style='color: #00FF00'>→ Crop growth rates increased</span>"
			M << "<span style='color: #00FF00'>→ Livestock breeding season activated</span>"
			M << "<span style='color: #00FF00'>→ Seeds are now available</span>"
	
	last_season_event = "spring"

/proc/OnSeasonSummer()
	/**
	 * Summer Abundance!
	 * - Peak growing season
	 * - Harvest begins
	 * - Food prices drop dramatically (-40%, high abundance)
	 * - Animal production peaks (milk, eggs, wool)
	 * - High temperature increases hunger/thirst consumption (+25%)
	 * - Weather effects more pronounced (rain/drought)
	 */
	
	world << "\n<span style='color: #FFAA00'><b>═══════════════════════════════════════</b></span>"
	world << "<span style='color: #FFAA00'><b>☀️ SUMMER ABUNDANCE ARRIVES! ☀️</b></span>"
	world << "<span style='color: #FFAA00'><b>The fields overflow with bounty.</b></span>"
	world << "<span style='color: #FFAA00'><b>═══════════════════════════════════════</b></span>\n"
	
	// Modulate system parameters
	// global.crop_growth_modifier = 1.20  // TODO: Integrate with farming system
	// global.breeding_season_active = TRUE  // TODO: Integrate with LivestockSystem
	// global.breeding_success_rate = 70  // High success
	// global.animal_production_modifier = 1.3  // TODO: Integrate with LivestockSystem
	
	// Food price scaling
	// global.food_price_modifier = 0.6  // TODO: Integrate with DynamicMarketPricingSystem
	
	// Consumption increase
	// global.consumption_rate_modifier = 1.25  // TODO: Integrate with HungerThirstSystem.dm
	
	// Effect messaging
	for(var/mob/players/M in world)
		if(M.client)
			M << "<span style='color: #FFAA00'>→ Crop growth rates at peak</span>"
			M << "<span style='color: #FFAA00'>→ Food prices plummeting due to abundance</span>"
			M << "<span style='color: #FFAA00'>→ Animal production peak season</span>"
			M << "<span style='color: #FF6600'>→ Heat increases food consumption</span>"
	
	last_season_event = "summer"

/proc/OnSeasonAutumn()
	/**
	 * Harvest Season!
	 * - Final harvest push begins
	 * - Crop yields increased (+10%)
	 * - Soil recovery at peak (+25% fertility restoration)
	 * - Preservation season (drying, storage, preservation recipes)
	 * - Animal products higher quality (+20%)
	 * - Moderate temperatures (balanced consumption)
	 * - Breeding season ends (20% success rate)
	 */
	
	world << "\n<span style='color: #FF8800'><b>═══════════════════════════════════════</b></span>"
	world << "<span style='color: #FF8800'><b>🍂 HARVEST SEASON COMMENCES! 🍂</b></span>"
	world << "<span style='color: #FF8800'><b>Time to gather the year's bounty.</b></span>"
	world << "<span style='color: #FF8800'><b>═══════════════════════════════════════</b></span>\n"
	
	// Modulate system parameters
	// global.crop_growth_modifier = 1.10  // TODO: Integrate with farming system
	// global.breeding_season_active = TRUE  // TODO: Integrate with LivestockSystem
	// global.breeding_success_rate = 50  // Declining
	// global.animal_production_modifier = 1.2  // TODO: Integrate with LivestockSystem
	// global.soil_recovery_modifier = 1.25  // TODO: Integrate with soil system
	// global.harvest_yield_modifier = 1.10  // TODO: Integrate with farming system
	
	// Food price scaling
	// global.food_price_modifier = 0.7  // TODO: Integrate with DynamicMarketPricingSystem
	
	// Effect messaging
	for(var/mob/players/M in world)
		if(M.client)
			M << "<span style='color: #FF8800'>→ Harvest yields increased</span>"
			M << "<span style='color: #FF8800'>→ Soil recovery at peak effectiveness</span>"
			M << "<span style='color: #FF8800'>→ Preservation season - preservation recipes available</span>"
			M << "<span style='color: #FF8800'>→ Animal products at premium quality</span>"
	
	last_season_event = "autumn"

/proc/OnSeasonWinter()
	/**
	 * Winter Scarcity!
	 * - No outdoor crop growth
	 * - Food scarcity (prices increase +50%, low supply)
	 * - Survival challenge activated
	 * - Animal production drops (-40%)
	 * - Cold weather increases hunger/thirst consumption (+50%)
	 * - Breeding season disabled (5% success rate)
	 * - Food preservation becomes critical
	 */
	
	world << "\n<span style='color: #0088FF'><b>═══════════════════════════════════════</b></span>"
	world << "<span style='color: #0088FF'><b>❄️ WINTER ARRIVES - SURVIVAL TIME ❄️</b></span>"
	world << "<span style='color: #0088FF'><b>The land falls silent under snow.</b></span>"
	world << "<span style='color: #0088FF'><b>═══════════════════════════════════════</b></span>\n"
	
	// Modulate system parameters
	// global.crop_growth_modifier = 0.0  // TODO: Integrate with farming system
	// global.breeding_season_active = FALSE  // TODO: Integrate with LivestockSystem
	// global.breeding_success_rate = 5  // Nearly impossible
	// global.animal_production_modifier = 0.6  // -40% production
	
	// Food price scaling
	// global.food_price_modifier = 1.5  // TODO: Integrate with DynamicMarketPricingSystem
	
	// TODO: Consumption increase integration
	// Requires integration with HungerThirstSystem.dm
	
	// Effect messaging
	for(var/mob/players/M in world)
		if(M.client)
			M << "<span style='color: #0088FF'>→ Outdoor crops cannot grow</span>"
			M << "<span style='color: #0088FF'>→ Food prices high due to scarcity</span>"
			M << "<span style='color: #0088FF'>→ Animal production severely reduced</span>"
			M << "<span style='color: #FF6600'>→ SURVIVAL CHALLENGE: Cold weather increases food consumption 50%</span>"
			M << "<span style='color: #FF6600'>→ Preserved food becomes essential</span>"
	
	last_season_event = "winter"

// ============================================================================
// STATISTICS TRACKING
// ============================================================================

/proc/IncrementSeasonalStat(stat_name)
	/**
	 * Increment seasonal statistics
	 * Called by: crop planting, harvesting, animal birth/slaughter
	 */
	
	if(stat_name in seasonal_stats)
		seasonal_stats[stat_name]++

/proc/GetSeasonalStats()
	/**
	 * Return current seasonal statistics
	 * Used for analytics and world state display
	 */
	
	return seasonal_stats.Copy()

/proc/ResetSeasonalStats()
	/**
	 * Reset stats for new season (called at season change)
	 */
	
	seasonal_stats = list(
		"spring_crops_planted" = 0,
		"summer_harvests" = 0,
		"autumn_crops_planted" = 0,
		"winter_survivaldays" = 0,
		"animals_born" = 0,
		"animals_slaughtered" = 0,
	)

// ============================================================================
// INTEGRATION HOOKS (Placeholders for future integration)
// ============================================================================

/*
 * HOOK 1: In DayNight.dm, add seasonal event trigger:
 * 
 * area/screen_fx/day_night
 * 	proc/day_night_loop()
 * 		var/last_season = ""
 * 		while(1)
 * 			if(global.season != last_season)
 * 				ProcessSeasonalEvents()
 * 				last_season = global.season
 * 			sleep(50)
 * 
 * HOOK 2: In ConsumptionManager.dm, add price modulation:
 * 
 * proc/GetFoodPrice(food_name)
 * 	var/base_price = FOOD_PRICES[food_name]
 * 	return base_price * (global.food_price_modifier || 1.0)
 * 
 * HOOK 3: In LivestockSystem.dm, add breeding success check:
 * 
 * proc/BreedAnimal(animal1, animal2)
 * 	if(global.breeding_season_active)
 * 		success_rate = global.breeding_success_rate
 * 	else
 * 		success_rate = max(5, global.breeding_success_rate - 50)
 * 
 * HOOK 4: In plant.dm, add growth modulation:
 * 
 * turf/var/growth_loop()
 * 	growth_rate *= (global.crop_growth_modifier || 1.0)
 * 
 * HOOK 5: In HungerThirstSystem.dm, add consumption increase:
 * 
 * proc/UpdateHunger(mob/M)
 * 	hunger_loss *= (global.consumption_rate_modifier || 1.0)
 */

// ============================================================================
// ADMIN COMMANDS FOR TESTING
// ============================================================================

mob/players
	verb/test_spring()
		set name = "Test Spring"
		set category = "Debug"
		
		if(!ismob(usr) || !check_admin(usr.key))
			return
		
		global.season = "Spring"
		ProcessSeasonalEvents()
		usr << "Spring event triggered."
	
	verb/test_summer()
		set name = "Test Summer"
		set category = "Debug"
		
		if(!ismob(usr) || !check_admin(usr.key))
			return
		
		global.season = "Summer"
		ProcessSeasonalEvents()
		usr << "Summer event triggered."
	
	verb/test_autumn()
		set name = "Test Autumn"
		set category = "Debug"
		
		if(!ismob(usr) || !check_admin(usr.key))
			return
		
		global.season = "Autumn"
		ProcessSeasonalEvents()
		usr << "Autumn event triggered."
	
	verb/test_winter()
		set name = "Test Winter"
		set category = "Debug"
		
		if(!ismob(usr) || !check_admin(usr.key))
			return
		
		global.season = "Winter"
		ProcessSeasonalEvents()
		usr << "Winter event triggered."
	
	verb/show_seasonal_stats()
		set name = "Show Seasonal Stats"
		set category = "Debug"
		
		if(!ismob(usr) || !check_admin(usr.key))
			return
		
		var/list/stats = GetSeasonalStats()
		usr << "Seasonal Statistics:"
		for(var/stat in stats)
			usr << "[stat]: [stats[stat]]"

// ============================================================================
// HELPER FUNCTION
// ============================================================================

/proc/check_admin(key)
	/**
	 * Simple admin check (extend based on your admin system)
	 */
	return TRUE  // TODO: Integrate with actual admin system
