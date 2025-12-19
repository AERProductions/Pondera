// dm/AdvancedEconomySystem.dm — Enhanced supply/demand economics with tech-tier pricing
// Expands DynamicMarketPricingSystem with advanced mechanics:
// - Real-time price adjustments based on kingdom supply/demand
// - Tech-tier pricing multipliers (tier 1-5 items cost differently)
// - Market volatility simulations
// - NPC merchant pricing integration
// - Kingdom material reserves tracking

#define ECONOMY_UPDATE_INTERVAL 100  // Ticks between market updates (5 seconds)
#define ECONOMY_VOLATILITY_BASE 0.05  // 5% base price swing per update
#define ECONOMY_ELASTICITY 0.8  // Price sensitivity to supply changes

// Global economy system
var/datum/AdvancedEconomySystem/advanced_economy = null

// Initialize on world startup
proc/InitializeAdvancedEconomy()
	advanced_economy = new /datum/AdvancedEconomySystem()
	RegisterInitComplete("Advanced Economy")

// Get economy system singleton
proc/GetAdvancedEconomy()
	if(!advanced_economy)
		world.log << "ERROR: Advanced Economy system not initialized!"
		return null
	return advanced_economy

// Advanced economy engine with supply/demand pricing
datum/AdvancedEconomySystem
	var/initialized = FALSE
	var/list/tech_tier_prices = list()  // Tier 1-5 base multipliers
	var/list/kingdom_supplies = list()  // Per-kingdom material reserves
	var/list/merchant_inventories = list()  // NPC merchant stock levels
	var/last_update = 0
	var/market_volatility = ECONOMY_VOLATILITY_BASE
	var/inflation_factor = 1.0

	New()
		initialized = TRUE
		InitializeTechTierPrices()
		InitializeKingdomSupplies()
		spawn(ECONOMY_UPDATE_INTERVAL)
			UpdateMarketPrices()

	// Initialize tech tier multipliers (tier affects base price)
	proc/InitializeTechTierPrices()
		tech_tier_prices[1] = 1.0    // Basic iron, wood, stone
		tech_tier_prices[2] = 1.5    // Bronze, steel tools
		tech_tier_prices[3] = 2.5    // Damascus steel, advanced armor
		tech_tier_prices[4] = 4.0    // Enchanted materials, rare metals
		tech_tier_prices[5] = 8.0    // Legendary, artifact-grade materials

	// Initialize kingdom material reserves
	proc/InitializeKingdomSupplies()
		kingdom_supplies["story"] = list(
			"stone" = 5000,    // Story mode: abundant resources
			"metal" = 2000,
			"timber" = 3000
		)
		kingdom_supplies["sandbox"] = list(
			"stone" = 10000,   // Sandbox: unlimited resources
			"metal" = 10000,
			"timber" = 10000
		)
		kingdom_supplies["pvp"] = list(
			"stone" = 500,     // PvP: scarce resources
			"metal" = 300,
			"timber" = 400
		)

	// Calculate item price based on tech tier and supply/demand
	proc/GetTechTierPrice(var/item_name, var/base_price, var/tech_tier, var/kingdom = "story")
		if(!tech_tier_prices[tech_tier])
			return base_price  // Fallback if invalid tier

		// Base price with tech tier multiplier
		var/tier_multiplier = tech_tier_prices[tech_tier]
		var/tier_adjusted = base_price * tier_multiplier

		// Supply/demand multiplier
		var/supply_factor = 1.0
		if(kingdom_supplies[kingdom])
			var/list/supplies = kingdom_supplies[kingdom]
			
			// Extract material type from item name
			var/material_type = GetMaterialType(item_name)
			if(material_type && supplies[material_type])
				var/supply = supplies[material_type]
				
				// Price inversely proportional to supply
				// Low supply = high price, high supply = low price
				if(supply < 100)
					supply_factor = 2.5  // Scarce: 2.5x
				else if(supply < 300)
					supply_factor = 1.8  // Low: 1.8x
				else if(supply < 700)
					supply_factor = 1.2  // Medium: 1.2x
				else if(supply > 2000)
					supply_factor = 0.7  // Abundant: 0.7x
				else if(supply > 5000)
					supply_factor = 0.5  // Overabundant: 0.5x

		// Apply inflation
		supply_factor *= inflation_factor

		// Final price with ceiling/floor
		var/final_price = tier_adjusted * supply_factor
		if(final_price < base_price * 0.3)  // Min 30% of base
			final_price = base_price * 0.3
		if(final_price > base_price * 3.0)  // Max 300% of base
			final_price = base_price * 3.0

		return final_price

	// Get material type from item name
	proc/GetMaterialType(var/item_name)
		if(!item_name) return null
		
		// Check for material keywords in item name
		if("stone" in item_name || "rock" in item_name)
			return "stone"
		else if("metal" in item_name || "ore" in item_name || "iron" in item_name || "steel" in item_name)
			return "metal"
		else if("timber" in item_name || "wood" in item_name || "log" in item_name)
			return "timber"
		
		return null

	// Update kingdom material supplies (called when items harvested/crafted)
	proc/UpdateKingdomSupply(var/kingdom, var/material, var/amount)
		if(!kingdom_supplies[kingdom])
			kingdom_supplies[kingdom] = list()
		
		if(!kingdom_supplies[kingdom][material])
			kingdom_supplies[kingdom][material] = 0
		
		kingdom_supplies[kingdom][material] += amount
		
		// Clamp supplies to reasonable ranges
		if(kingdom_supplies[kingdom][material] < 0)
			kingdom_supplies[kingdom][material] = 0
		if(kingdom_supplies[kingdom][material] > 10000)
			kingdom_supplies[kingdom][material] = 10000

	// Simulate market volatility (random price fluctuations)
	proc/UpdateMarketPrices()
		set background = 1
		set waitfor = 0

		while(src)
			sleep(ECONOMY_UPDATE_INTERVAL)
			
			// Random volatility (-/+ 5%)
			var/volatility = rand(-ECONOMY_VOLATILITY_BASE * 100, ECONOMY_VOLATILITY_BASE * 100) / 100
			market_volatility = ECONOMY_VOLATILITY_BASE + volatility
			
			// Gradual inflation simulation (0.1% per update)
			inflation_factor += 0.001
			if(inflation_factor > 2.0)  // Cap at 2.0x
				inflation_factor = 2.0

	// Get current price for item at NPC merchant
	proc/GetMerchantPrice(var/item_name, var/base_price, var/tech_tier, var/mob/npcs/merchant)
		var/kingdom = GetMerchantKingdom(merchant)
		if(!kingdom) kingdom = "story"
		
		var/price = GetTechTierPrice(item_name, base_price, tech_tier, kingdom)
		
		// NPC-specific markup (each merchant has personality)
		if(merchant)
			var/markup = 1.0  // Default no markup
			if(merchant.vars && "price_markup" in merchant.vars)
				markup = merchant.vars["price_markup"]
			price *= markup
		
		return price

	// Get kingdom from merchant NPC
	proc/GetMerchantKingdom(var/mob/npcs/merchant)
		if(!merchant) return "story"
		
		// Check merchant location for kingdom inference
		var/turf/T = isturf(merchant.loc) ? merchant.loc : null
		if(!T) return "story"
		
		// TODO: Implement zone-based kingdom detection
		// For now, story mode is default
		return "story"

	// Register new merchant inventory
	proc/RegisterMerchantInventory(var/mob/npcs/merchant, var/list/items)
		if(!merchant) return FALSE
		
		var/merchant_key = "[merchant.name]_[merchant]"
		merchant_inventories[merchant_key] = items
		return TRUE

	// Get merchant inventory
	proc/GetMerchantInventory(var/mob/npcs/merchant)
		if(!merchant) return null
		
		var/merchant_key = "[merchant.name]_[merchant]"
		return merchant_inventories[merchant_key]

	// Process trade between kingdoms
	proc/ProcessKingdomTrade(var/kingdom_A, var/kingdom_B, var/list/exchange)
		// exchange format: list("material" = "stone", "amount_A" = 100, "amount_B" = 150)
		
		if(!exchange["material"] || !exchange["amount_A"] || !exchange["amount_B"])
			return FALSE
		
		var/material = exchange["material"]
		var/amount_A = exchange["amount_A"]
		var/amount_B = exchange["amount_B"]
		
		// Validate both kingdoms have sufficient resources
		if(!kingdom_supplies[kingdom_A] || !kingdom_supplies[kingdom_B])
			return FALSE
		
		if(kingdom_supplies[kingdom_A][material] < amount_A)
			return FALSE
		if(kingdom_supplies[kingdom_B][material] < amount_B)
			return FALSE
		
		// Execute trade
		kingdom_supplies[kingdom_A][material] -= amount_A
		kingdom_supplies[kingdom_B][material] -= amount_B
		kingdom_supplies[kingdom_A][material] += amount_B
		kingdom_supplies[kingdom_B][material] += amount_A
		
		// Log trade
		world << "Kingdom trade: [kingdom_A] gave [amount_A] [material] for [amount_B] [material] from [kingdom_B]"
		
		return TRUE

	// Get supply/demand ratio for market visualization
	proc/GetSupplyDemandRatio(var/kingdom, var/material)
		if(!kingdom_supplies[kingdom])
			return 1.0
		
		var/supply = kingdom_supplies[kingdom][material] || 0
		var/demand = 1000  // Base demand (assumed constant)
		
		return supply / demand

	// Get market health report
	proc/GetMarketReport()
		var/report = "=== MARKET ECONOMIC REPORT ===\n"
		report += "Inflation Factor: [inflation_factor]\n"
		report += "Market Volatility: [market_volatility * 100]%\n"
		report += "\n=== KINGDOM SUPPLIES ===\n"
		
		for(var/kingdom in kingdom_supplies)
			report += "[kingdom]:\n"
			var/list/supplies = kingdom_supplies[kingdom]
			for(var/material in supplies)
				report += "  [material]: [supplies[material]]\n"
		
		return report

// Integration with player transactions
proc/GetDynamicPrice(var/item_name, var/base_price, var/tech_tier = 1, var/kingdom = "story")
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	if(!econ)
		return base_price  // Fallback
	
	return econ.GetTechTierPrice(item_name, base_price, tech_tier, kingdom)

// Update kingdom supply when items harvested
proc/UpdateKingdomMaterial(var/kingdom, var/material, var/amount)
	var/datum/AdvancedEconomySystem/econ = GetAdvancedEconomy()
	if(!econ) return FALSE
	
	econ.UpdateKingdomSupply(kingdom, material, amount)
	return TRUE
