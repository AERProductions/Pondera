// CharacterData Datum - Centralized character skill/progression data
// Consolidates all rank, exp, and skill variables into a single encapsulated structure
// Used by mob/players and can be extended for NPCs with specific behaviors

/datum/character_data
	var
		// === SKILL RANKS & EXPERIENCE ===
		// Rank Levels (0-5 for most, configurable per skill)
		frank = 0           // Fishing rank
		crank = 0           // Crafting rank
		grank = 0           // Gardening rank
		hrank = 0           // Harvesting/Woodcutting rank
		mrank = 0           // Mining rank
		smirank = 0         // Smithing rank
		smerank = 0         // Smelting rank
		brank = 0           // Building rank
		drank = 0           // Digging rank
		Crank = 0           // Carving rank
		CSRank = 0          // Sprout Cutting rank
		PLRank = 0          // Pole rank

		// Experience Points (current)
		frankEXP = 0
		crankEXP = 0
		grankEXP = 0
		hrankEXP = 0
		mrankEXP = 0
		smirankEXP = 0
		smerankEXP = 0
		brankEXP = 0
		drankEXP = 0
		CrankEXP = 0
		CSRankEXP = 0
		PLRankEXP = 0

		// Experience Thresholds (exp needed for next level)
		frankMAXEXP = 100
		crankMAXEXP = 10
		grankMAXEXP = 100
		hrankMAXEXP = 10
		mrankMAXEXP = 100
		smirankMAXEXP = 100
		smerankMAXEXP = 100
		brankMAXEXP = 100
		drankMAXEXP = 100
		CrankMAXEXP = 10
		CSRankMAXEXP = 10
		PLRankMAXEXP = 100

		// === RECIPE & KNOWLEDGE STATE ===
		datum/recipe_state/recipe_state = null  // Tracks discovered recipes and knowledge
		purchased_items = list()             // Items purchased from market stalls
		
		// === MULTI-WORLD SYSTEM ===
		// Continent & World variables
		current_continent = CONT_STORY       // Which continent player is on
		continent_positions = list()         // Saved positions per continent: CONT_STORY = list(x,y,z,dir)
		
		// Stall system (per-continent trading)
		stall_owner = ""                     // NPC stall owner name (story continent)
		stall_inventory = list()             // Items for sale in stall
		stall_prices = list()                // Prices for items
		stall_profits = 0                    // Accumulated stall profits (shared globally)

/datum/character_data/proc/Initialize()
	// Reset all ranks and exp to zero on creation
	// Can be called during character creation
	frank = 0
	frankEXP = 0
	frankMAXEXP = 100

	crank = 0
	crankEXP = 0
	crankMAXEXP = 10

	grank = 0
	grankEXP = 0
	grankMAXEXP = 100

	hrank = 0
	hrankEXP = 0
	hrankMAXEXP = 10

	mrank = 0
	mrankEXP = 0
	mrankMAXEXP = 100

	smirank = 0
	smirankEXP = 0
	smirankMAXEXP = 100

	smerank = 0
	smerankEXP = 0
	smerankMAXEXP = 100

	brank = 0
	brankEXP = 0
	brankMAXEXP = 100

	drank = 0
	drankEXP = 0
	drankMAXEXP = 100

	Crank = 0
	CrankEXP = 0
	CrankMAXEXP = 10

	CSRank = 0
	CSRankEXP = 0
	CSRankMAXEXP = 10

	PLRank = 0
	PLRankEXP = 0
	PLRankMAXEXP = 100

	// Initialize recipe state with defaults
	recipe_state = new /datum/recipe_state()
	recipe_state.SetRecipeDefaults()