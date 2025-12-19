// dm/RecipeState.dm — Recipe and Knowledge Discovery Persistence
// Phase 4 of player persistence pipeline (Commit: Phases 1-3 f14f933)
// Tracks all discovered recipes, unlocked crafting techniques, and tutorial knowledge
// 
// Datum Structure:
//   - Recipe discovery flags (20+ crafting recipes across: smithing, building, tool crafting)
//   - Knowledge unlocks (tutorial progress, location discoveries, NPC lore)
//   - Crafting experience tracking (per recipe type)
//   - Skill-gated content flags

datum/recipe_state
	// === TOOL CRAFTING RECIPES ===
	// Carving & Basic Tools
	var/discovered_stone_hammer = FALSE      // Stone Hammer (Rock + Wooden Haunch)
	var/discovered_carving_knife = FALSE     // Carving Knife (Iron Ingot + Handle)
	var/discovered_iron_hammer = FALSE       // Iron Hammer (Iron Ingot + Handle)
	var/discovered_iron_shovel = FALSE       // Iron Shovel (Iron Ingot + Pole)
	var/discovered_iron_hoe = FALSE          // Iron Hoe (Iron Ingot + Pole)
	var/discovered_iron_sickle = FALSE       // Iron Sickle (Iron Ingot + Handle)
	var/discovered_fishing_pole = FALSE      // Fishing Pole (Iron Ingot + Pole)
	var/discovered_iron_chisel = FALSE       // Iron Chisel (Iron Ingot + Handle)

	// Steel Tools (Advanced)
	var/discovered_steel_pickaxe = FALSE     // Steel Pickaxe (Steel Ingot + materials)
	var/discovered_steel_hammer = FALSE      // Steel Hammer (Steel Ingot + materials)
	var/discovered_steel_shovel = FALSE      // Steel Shovel (Steel Ingot + materials)
	var/discovered_steel_hoe = FALSE         // Steel Hoe (Steel Ingot + materials)
	var/discovered_steel_axe = FALSE         // Steel Axe (Steel Ingot + materials)
	var/discovered_steel_sword = FALSE       // Steel Sword (Steel Ingot + materials)

	// === BUILDING/STRUCTURE RECIPES ===
	// Furnishings
	var/discovered_bed = FALSE               // Bed (Nails + Poles + Board)
	var/discovered_chest = FALSE             // Chest (storage furniture)

	// Smithing Structures
	var/discovered_forge = FALSE             // Forge (Mortar + Stone + Ueik Log)
	var/discovered_anvil = FALSE             // Anvil (Mortar + Anvil Head + Ueik Log)

	// Misc
	var/discovered_wooden_haunch_carving = FALSE  // Wooden Haunch carving techniques

	// === SMELTING/REFINEMENT RECIPES ===
	var/discovered_iron_ingot_smelting = FALSE    // Iron Ore -> Iron Ingot
	var/discovered_steel_ingot_creation = FALSE   // Iron Ingot + Carbon -> Steel Ingot
	var/discovered_tool_filing = FALSE            // Tool refinement stage 1 (File)
	var/discovered_tool_sharpening = FALSE        // Tool refinement stage 2 (Whetstone)
	var/discovered_tool_polishing = FALSE         // Tool refinement stage 3 (Polish Cloth)

	// === COOKING RECIPES ===
	var/discovered_vegetable_soup = FALSE         // Boiled vegetables + water
	var/discovered_grain_porridge = FALSE         // Boiled grain + water
	var/discovered_roasted_vegetables = FALSE     // Roasted root vegetables
	var/discovered_roasted_meat = FALSE           // Roasted raw meat
	var/discovered_fish_fillet = FALSE            // Fried fish
	var/discovered_berry_compote = FALSE          // Boiled berries + water
	var/discovered_baked_bread = FALSE            // Baked wheat + water
	var/discovered_meat_stew = FALSE              // Stewed meat + vegetables
	var/discovered_vegetable_medley = FALSE       // Steamed mixed vegetables
	var/discovered_shepherds_pie = FALSE          // Baked meat pie with potato topping

	// === KNOWLEDGE/TUTORIAL FLAGS ===
	var/tutorial_completed = FALSE           // Basic tutorial finished
	var/learned_gathering = FALSE            // Gathering basics (rocks, flowers, etc.)
	var/learned_mining = FALSE               // Mining mechanics explained
	var/learned_crafting = FALSE             // Crafting system fundamentals
	var/learned_smelting = FALSE             // Smelting/forge mechanics
	var/learned_smithing = FALSE             // Smithing/anvil mechanics
	var/learned_refinement = FALSE           // Tool refinement process
	var/learned_building = FALSE             // Building/construction basics
	var/learned_fishing = FALSE              // Fishing mechanics

	// === LOCATION DISCOVERIES ===
	var/discovered_biome_temperate = FALSE   // Temperate biome visited
	var/discovered_biome_arctic = FALSE      // Arctic biome visited
	var/discovered_biome_desert = FALSE      // Desert biome visited
	var/discovered_biome_rainforest = FALSE  // Rainforest biome visited

	// === SKILL-BASED CONTENT UNLOCKS ===
	// Track which skill thresholds player has crossed (for skill-gated recipes)
	var/skill_mining_level = 0               // Current mining skill (gates ore access)
	var/skill_smithing_level = 0             // Current smithing skill (gates tool crafting)
	var/skill_building_level = 0             // Current building skill (gates structure recipes)
	var/skill_cooking_level = 0              // Current cooking skill (gates food recipes)
	var/skill_refining_level = 0             // Current refining skill (gates high-tier tools)

	// === CRAFTING EXPERIENCE ===
	var/experience_smithing = 0              // Total smithing XP earned
	var/experience_building = 0              // Total building XP earned
	var/experience_refining = 0              // Total refining XP earned

	// === HELPER PROCS ===

	// Discover a single recipe (called when recipe discovered via NPC or item interaction)
	proc/DiscoverRecipe(recipe_name)
		switch(recipe_name)
			// Tool Recipes
			if("stone_hammer")
				discovered_stone_hammer = TRUE
			if("carving_knife")
				discovered_carving_knife = TRUE
			if("iron_hammer")
				discovered_iron_hammer = TRUE
			if("iron_shovel")
				discovered_iron_shovel = TRUE
			if("iron_hoe")
				discovered_iron_hoe = TRUE
			if("iron_sickle")
				discovered_iron_sickle = TRUE
			if("fishing_pole")
				discovered_fishing_pole = TRUE
			if("iron_chisel")
				discovered_iron_chisel = TRUE
			if("steel_pickaxe")
				discovered_steel_pickaxe = TRUE
			if("steel_hammer")
				discovered_steel_hammer = TRUE
			if("steel_shovel")
				discovered_steel_shovel = TRUE
			if("steel_hoe")
				discovered_steel_hoe = TRUE
			if("steel_axe")
				discovered_steel_axe = TRUE
			if("steel_sword")
				discovered_steel_sword = TRUE
			// Building Recipes
			if("bed")
				discovered_bed = TRUE
			if("chest")
				discovered_chest = TRUE
			if("forge")
				discovered_forge = TRUE
			if("anvil")
				discovered_anvil = TRUE
			if("wooden_haunch_carving")
				discovered_wooden_haunch_carving = TRUE
			// Smelting Recipes
			if("iron_ingot_smelting")
				discovered_iron_ingot_smelting = TRUE
			if("steel_ingot_creation")
				discovered_steel_ingot_creation = TRUE
			if("tool_filing")
				discovered_tool_filing = TRUE
			if("tool_sharpening")
				discovered_tool_sharpening = TRUE
			if("tool_polishing")
				discovered_tool_polishing = TRUE
			// Cooking Recipes
			if("vegetable_soup")
				discovered_vegetable_soup = TRUE
			if("grain_porridge")
				discovered_grain_porridge = TRUE
			if("roasted_vegetables")
				discovered_roasted_vegetables = TRUE
			if("roasted_meat")
				discovered_roasted_meat = TRUE
			if("fish_fillet")
				discovered_fish_fillet = TRUE
			if("berry_compote")
				discovered_berry_compote = TRUE
			if("baked_bread")
				discovered_baked_bread = TRUE
			if("meat_stew")
				discovered_meat_stew = TRUE
			if("vegetable_medley")
				discovered_vegetable_medley = TRUE
			if("shepherds_pie")
				discovered_shepherds_pie = TRUE

	// Learn a knowledge topic (unlock tutorial/lore)
	proc/LearnTopic(topic_name)
		switch(topic_name)
			if("tutorial")
				tutorial_completed = TRUE
			if("gathering")
				learned_gathering = TRUE
			if("mining")
				learned_mining = TRUE
			if("crafting")
				learned_crafting = TRUE
			if("smelting")
				learned_smelting = TRUE
			if("smithing")
				learned_smithing = TRUE
			if("refinement")
				learned_refinement = TRUE
			if("building")
				learned_building = TRUE
			if("fishing")
				learned_fishing = TRUE
			if("cooking")
				skill_cooking_level = max(skill_cooking_level, 1)

	// Discover a location
	proc/DiscoverBiome(biome_name)
		switch(biome_name)
			if("temperate")
				discovered_biome_temperate = TRUE
			if("arctic")
				discovered_biome_arctic = TRUE
			if("desert")
				discovered_biome_desert = TRUE
			if("rainforest")
				discovered_biome_rainforest = TRUE

	// Update skill level (typically when player ranks up in that skill)
	proc/SetSkillLevel(skill_name, level)
		switch(skill_name)
			if("mining")
				skill_mining_level = level
			if("smithing")
				skill_smithing_level = level
			if("building")
				skill_building_level = level
			if("cooking")
				skill_cooking_level = level
			if("refining")
				skill_refining_level = level

	// Add crafting experience
	proc/AddExperience(type_name, amount)
		switch(type_name)
			if("smithing")
				experience_smithing += amount
			if("building")
				experience_building += amount
			if("refining")
				experience_refining += amount

	// Check if recipe is discovered
	proc/IsRecipeDiscovered(recipe_name)
		switch(recipe_name)
			if("stone_hammer")
				return discovered_stone_hammer
			if("carving_knife")
				return discovered_carving_knife
			if("iron_hammer")
				return discovered_iron_hammer
			if("iron_shovel")
				return discovered_iron_shovel
			if("iron_hoe")
				return discovered_iron_hoe
			if("iron_sickle")
				return discovered_iron_sickle
			if("fishing_pole")
				return discovered_fishing_pole
			if("iron_chisel")
				return discovered_iron_chisel
			if("steel_pickaxe")
				return discovered_steel_pickaxe
			if("steel_hammer")
				return discovered_steel_hammer
			if("steel_shovel")
				return discovered_steel_shovel
			if("steel_hoe")
				return discovered_steel_hoe
			if("steel_axe")
				return discovered_steel_axe
			if("steel_sword")
				return discovered_steel_sword
			if("bed")
				return discovered_bed
			if("chest")
				return discovered_chest
			if("forge")
				return discovered_forge
			if("anvil")
				return discovered_anvil
			if("wooden_haunch_carving")
				return discovered_wooden_haunch_carving
			if("iron_ingot_smelting")
				return discovered_iron_ingot_smelting
			if("steel_ingot_creation")
				return discovered_steel_ingot_creation
			if("tool_filing")
				return discovered_tool_filing
			if("tool_sharpening")
				return discovered_tool_sharpening
			if("tool_polishing")
				return discovered_tool_polishing
			// Cooking Recipes
			if("vegetable_soup")
				return discovered_vegetable_soup
			if("grain_porridge")
				return discovered_grain_porridge
			if("roasted_vegetables")
				return discovered_roasted_vegetables
			if("roasted_meat")
				return discovered_roasted_meat
			if("fish_fillet")
				return discovered_fish_fillet
			if("berry_compote")
				return discovered_berry_compote
			if("baked_bread")
				return discovered_baked_bread
			if("meat_stew")
				return discovered_meat_stew
			if("vegetable_medley")
				return discovered_vegetable_medley
			if("shepherds_pie")
				return discovered_shepherds_pie
		return FALSE

	// Check if knowledge topic is learned
	proc/IsTopicLearned(topic_name)
		switch(topic_name)
			if("tutorial")
				return tutorial_completed
			if("gathering")
				return learned_gathering
			if("mining")
				return learned_mining
			if("crafting")
				return learned_crafting
			if("smelting")
				return learned_smelting
			if("smithing")
				return learned_smithing
			if("refinement")
				return learned_refinement
			if("building")
				return learned_building
			if("fishing")
				return learned_fishing
		return FALSE

	// Validate recipe state for corruption
	proc/ValidateRecipeState()
		// All flags should be boolean (0 or 1)
		discovered_stone_hammer = (discovered_stone_hammer == TRUE)
		discovered_carving_knife = (discovered_carving_knife == TRUE)
		discovered_iron_hammer = (discovered_iron_hammer == TRUE)
		discovered_iron_shovel = (discovered_iron_shovel == TRUE)
		discovered_iron_hoe = (discovered_iron_hoe == TRUE)
		discovered_iron_sickle = (discovered_iron_sickle == TRUE)
		discovered_fishing_pole = (discovered_fishing_pole == TRUE)
		discovered_iron_chisel = (discovered_iron_chisel == TRUE)
		discovered_steel_pickaxe = (discovered_steel_pickaxe == TRUE)
		discovered_steel_hammer = (discovered_steel_hammer == TRUE)
		discovered_steel_shovel = (discovered_steel_shovel == TRUE)
		discovered_steel_hoe = (discovered_steel_hoe == TRUE)
		discovered_steel_axe = (discovered_steel_axe == TRUE)
		discovered_steel_sword = (discovered_steel_sword == TRUE)
		discovered_bed = (discovered_bed == TRUE)
		discovered_chest = (discovered_chest == TRUE)
		discovered_forge = (discovered_forge == TRUE)
		discovered_anvil = (discovered_anvil == TRUE)
		discovered_wooden_haunch_carving = (discovered_wooden_haunch_carving == TRUE)
		discovered_iron_ingot_smelting = (discovered_iron_ingot_smelting == TRUE)
		discovered_steel_ingot_creation = (discovered_steel_ingot_creation == TRUE)
		discovered_tool_filing = (discovered_tool_filing == TRUE)
		discovered_tool_sharpening = (discovered_tool_sharpening == TRUE)
		discovered_tool_polishing = (discovered_tool_polishing == TRUE)

		tutorial_completed = (tutorial_completed == TRUE)
		learned_gathering = (learned_gathering == TRUE)
		learned_mining = (learned_mining == TRUE)
		learned_crafting = (learned_crafting == TRUE)
		learned_smelting = (learned_smelting == TRUE)
		learned_smithing = (learned_smithing == TRUE)
		learned_refinement = (learned_refinement == TRUE)
		learned_building = (learned_building == TRUE)
		learned_fishing = (learned_fishing == TRUE)

		discovered_biome_temperate = (discovered_biome_temperate == TRUE)
		discovered_biome_arctic = (discovered_biome_arctic == TRUE)
		discovered_biome_desert = (discovered_biome_desert == TRUE)
		discovered_biome_rainforest = (discovered_biome_rainforest == TRUE)

		// Skill levels should be 0-10
		skill_mining_level = clamp(skill_mining_level, 0, 10)
		skill_smithing_level = clamp(skill_smithing_level, 0, 10)
		skill_building_level = clamp(skill_building_level, 0, 10)
		skill_cooking_level = clamp(skill_cooking_level, 0, 10)
		skill_refining_level = clamp(skill_refining_level, 0, 10)

		// Experience should be non-negative
		experience_smithing = max(0, experience_smithing)
		experience_building = max(0, experience_building)
		experience_refining = max(0, experience_refining)

		return TRUE

	// Create default recipe state for new players (no recipes discovered yet)
	proc/SetRecipeDefaults()
		discovered_stone_hammer = FALSE
		discovered_carving_knife = FALSE
		discovered_iron_hammer = FALSE
		discovered_iron_shovel = FALSE
		discovered_iron_hoe = FALSE
		discovered_iron_sickle = FALSE
		discovered_fishing_pole = FALSE
		discovered_iron_chisel = FALSE
		discovered_steel_pickaxe = FALSE
		discovered_steel_hammer = FALSE
		discovered_steel_shovel = FALSE
		discovered_steel_hoe = FALSE
		discovered_steel_axe = FALSE
		discovered_steel_sword = FALSE
		discovered_bed = FALSE
		discovered_chest = FALSE
		discovered_forge = FALSE
		discovered_anvil = FALSE
		discovered_wooden_haunch_carving = FALSE
		discovered_iron_ingot_smelting = FALSE
		discovered_steel_ingot_creation = FALSE
		discovered_tool_filing = FALSE
		discovered_tool_sharpening = FALSE
		discovered_tool_polishing = FALSE

		tutorial_completed = FALSE
		learned_gathering = FALSE
		learned_mining = FALSE
		learned_crafting = FALSE
		learned_smelting = FALSE
		learned_smithing = FALSE
		learned_refinement = FALSE
		learned_building = FALSE
		learned_fishing = FALSE

		discovered_biome_temperate = FALSE
		discovered_biome_arctic = FALSE
		discovered_biome_desert = FALSE
		discovered_biome_rainforest = FALSE

		skill_mining_level = 0
		skill_smithing_level = 0
		skill_building_level = 0
		skill_cooking_level = 0
		skill_refining_level = 0

		experience_smithing = 0
		experience_building = 0
		experience_refining = 0

	// Get summary of discovered recipes (for UI display)
	proc/GetDiscoveredRecipeCount()
		var/count = 0
		if(discovered_stone_hammer) count++
		if(discovered_carving_knife) count++
		if(discovered_iron_hammer) count++
		if(discovered_iron_shovel) count++
		if(discovered_iron_hoe) count++
		if(discovered_iron_sickle) count++
		if(discovered_fishing_pole) count++
		if(discovered_iron_chisel) count++
		if(discovered_steel_pickaxe) count++
		if(discovered_steel_hammer) count++
		if(discovered_steel_shovel) count++
		if(discovered_steel_hoe) count++
		if(discovered_steel_axe) count++
		if(discovered_steel_sword) count++
		if(discovered_bed) count++
		if(discovered_chest) count++
		if(discovered_forge) count++
		if(discovered_anvil) count++
		if(discovered_wooden_haunch_carving) count++
		if(discovered_iron_ingot_smelting) count++
		if(discovered_steel_ingot_creation) count++
		if(discovered_tool_filing) count++
		if(discovered_tool_sharpening) count++
		if(discovered_tool_polishing) count++
		return count

	// Get total topics learned
	proc/GetLearnedTopicCount()
		var/count = 0
		if(tutorial_completed) count++
		if(learned_gathering) count++
		if(learned_mining) count++
		if(learned_crafting) count++
		if(learned_smelting) count++
		if(learned_smithing) count++
		if(learned_refinement) count++
		if(learned_building) count++
		if(learned_fishing) count++
		return count
