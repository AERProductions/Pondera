// NPCRecipeHandlers.dm - Recipe Teaching Integration for Existing NPCs
// Adds recipe/knowledge discovery dialogue to NPCs that can teach skills

// ============================================================================
// TRAVELER NPC - Teaches Gathering & Trading Recipes
// ============================================================================

/proc/TravelerRecipeDialog(mob/players/M)
	// Traveler teaches gathering and trading related recipes
	if(!M) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Traveler") in list("Fishing Basics", "Plant Gathering", "Trading Tips", "Never Mind")
	
	switch(choice)
		if("Fishing Basics")
			TeachRecipeDialog(M, "Traveler", "fishing_pole", "Basic fishing rod crafting and technique")
		
		if("Plant Gathering")
			TeachRecipeDialog(M, "Traveler", "plant_gathering", "How to identify and harvest wild plants safely")
		
		if("Trading Tips")
			TeachKnowledgeDialog(M, "Traveler", "trading_basics", "Understanding fair prices and market values")

// ============================================================================
// ELDER NPC - Teaches Foundational Knowledge & Survival
// ============================================================================

/proc/ElderRecipeDialog(mob/players/M)
	// Elder teaches fundamental knowledge and survival techniques
	if(!M) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Elder") in list("Survival Basics", "Resource Management", "Building Shelter", "Never Mind")
	
	switch(choice)
		if("Survival Basics")
			TeachKnowledgeDialog(M, "Elder", "survival_101", "How to survive your first days in these lands")
		
		if("Resource Management")
			TeachKnowledgeDialog(M, "Elder", "resource_conservation", "Making the most of limited resources")
		
		if("Building Shelter")
			TeachRecipeDialog(M, "Elder", "wooden_wall", "Constructing basic wooden shelter walls")

// ============================================================================
// VETERAN NPC - Teaches Combat & Defense
// ============================================================================

/proc/VeteranRecipeDialog(mob/players/M)
	// Veteran teaches combat-related recipes and techniques
	if(!M) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Veteran") in list("Combat Stance", "Weapon Maintenance", "Defensive Tactics", "Never Mind")
	
	switch(choice)
		if("Combat Stance")
			TeachKnowledgeDialog(M, "Veteran", "combat_basics", "Proper stance and positioning in combat")
		
		if("Weapon Maintenance")
			TeachRecipeDialog(M, "Veteran", "tool_sharpening", "Keeping your weapons sharp and ready")
		
		if("Defensive Tactics")
			TeachKnowledgeDialog(M, "Veteran", "defense_101", "How to protect yourself in dangerous situations")

// ============================================================================
// WARRIOR NPC - Teaches Crafting & Preparation
// ============================================================================

/proc/WarriorRecipeDialog(mob/players/M)
	// Warrior teaches practical crafting and preparation skills
	if(!M) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Warrior") in list("Tool Crafting", "Armor Care", "Resource Preparation", "Never Mind")
	
	switch(choice)
		if("Tool Crafting")
			TeachRecipeDialog(M, "Warrior", "carving_knife", "Creating basic tools from raw materials")
		
		if("Armor Care")
			TeachKnowledgeDialog(M, "Warrior", "armor_maintenance", "Maintaining your protective equipment")
		
		if("Resource Preparation")
			TeachRecipeDialog(M, "Warrior", "cook_food", "Preparing resources for consumption")

// ============================================================================
// SCRIBE NPC - Teaches Knowledge & Lore
// ============================================================================

/proc/ScribeRecipeDialog(mob/players/M)
	// Scribe teaches knowledge topics and recorded lore
	if(!M) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Scribe") in list("History & Lore", "Crafting Methods", "World Knowledge", "Never Mind")
	
	switch(choice)
		if("History & Lore")
			TeachKnowledgeDialog(M, "Scribe", "world_history", "The recorded history of these lands")
		
		if("Crafting Methods")
			TeachKnowledgeDialog(M, "Scribe", "crafting_theory", "The theory behind crafting and creation")
		
		if("World Knowledge")
			TeachKnowledgeDialog(M, "Scribe", "geographic_knowledge", "Information about the world's regions and biomes")

// ============================================================================
// PROCTOR NPC - Teaches Administration & Organization
// ============================================================================

/proc/ProctorRecipeDialog(mob/players/M)
	// Proctor teaches organizational and administrative recipes
	if(!M) return
	
	var/choice = input(M, "What would you like to learn?", "Learn from Proctor") in list("Inventory Management", "Base Organization", "Record Keeping", "Never Mind")
	
	switch(choice)
		if("Inventory Management")
			TeachKnowledgeDialog(M, "Proctor", "inventory_tips", "How to organize and manage inventory efficiently")
		
		if("Base Organization")
			TeachRecipeDialog(M, "Proctor", "storage_chest", "Building effective storage solutions")
		
		if("Record Keeping")
			TeachKnowledgeDialog(M, "Proctor", "record_keeping", "Tracking resources and progress over time")

// ============================================================================
// INTEGRATION HELPERS
// ============================================================================

// TeachRecipeDialog and TeachKnowledgeDialog are defined in NPCRecipeIntegration.dm
// These are the helper functions that NPC Click handlers call

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeNPCRecipeHandlers()
	world << "NPCRECIPE NPC Recipe Handlers Initialized - NPCs can now teach recipes"
