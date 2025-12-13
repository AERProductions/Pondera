// ========================================
// Smithing Recipes Database
// ========================================
// Comprehensive recipe registry for all smithing items
// Sources: Pondera Recipe Book.txt + Objects.dm analysis
// Total: 65+ recipes with standardized format
// 
// Format: SMITHING_RECIPES["recipe_name"] = list(
//     "name" = Display name,
//     "category" = "misc"/"tools"/"weapons"/"armor_evasive"/"armor_defensive"/"armor_offensive"/"lamps"/"containers",
//     "ingredients" = list("item_name" = amount, ...),
//     "output_proc" = proc name to create item OR null (for dynamic creation),
//     "xp_reward" = XP amount,
//     "required_rank" = Minimum smithing rank (1-11),
//     "base_success_rate" = Base success % (75-85),
//     "description" = Flavor text
// )

var/global/list/SMITHING_RECIPES = list()

proc/InitializeSmithingRecipes()
	// ========== MISCELLANEOUS ITEMS (Rank 1+) ==========
	
	SMITHING_RECIPES["iron nails"] = list(
		"name" = "Iron Nails",
		"category" = "misc",
		"ingredients" = list("iron ingot" = 1),
		"output_type" = "iron nails",
		"xp_reward" = 15,
		"required_rank" = 1,
		"base_success_rate" = 80,
		"description" = "Simple iron nails for basic construction"
	)
	
	SMITHING_RECIPES["iron ribbon"] = list(
		"name" = "Iron Ribbon",
		"category" = "misc",
		"ingredients" = list("iron ingot" = 2),
		"output_type" = "iron ribbon",
		"xp_reward" = 20,
		"required_rank" = 1,
		"base_success_rate" = 75,
		"description" = "Decorative iron ribbon for armor reinforcement"
	)
	
	// ========== TOOL PARTS (Rank 1-7+) ==========
	
	SMITHING_RECIPES["carving knife blade"] = list(
		"name" = "Carving Knife blade",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 1),
		"output_type" = "carving knife blade",
		"xp_reward" = 15,
		"required_rank" = 1,
		"base_success_rate" = 80,
		"description" = "Blade for carving knife tool"
	)
	
	SMITHING_RECIPES["hammer head"] = list(
		"name" = "Hammer head",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 1),
		"output_type" = "hammer head",
		"xp_reward" = 15,
		"required_rank" = 1,
		"base_success_rate" = 80,
		"description" = "Heavy hammer head for basic construction"
	)
	
	SMITHING_RECIPES["file blade"] = list(
		"name" = "File blade",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 1),
		"output_type" = "file blade",
		"xp_reward" = 15,
		"required_rank" = 1,
		"base_success_rate" = 80,
		"description" = "Blade for file tool"
	)
	
	SMITHING_RECIPES["axe head"] = list(
		"name" = "Axe head",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 2),
		"output_type" = "axe head",
		"xp_reward" = 25,
		"required_rank" = 2,
		"base_success_rate" = 75,
		"description" = "Head for woodcutting axe"
	)
	
	SMITHING_RECIPES["pickaxe head"] = list(
		"name" = "Pickaxe head",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "pickaxe head",
		"xp_reward" = 35,
		"required_rank" = 4,
		"base_success_rate" = 70,
		"description" = "Head for mining pickaxe"
	)
	
	SMITHING_RECIPES["shovel head"] = list(
		"name" = "Shovel head",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "shovel head",
		"xp_reward" = 35,
		"required_rank" = 4,
		"base_success_rate" = 70,
		"description" = "Head for digging shovel"
	)
	
	SMITHING_RECIPES["hoe blade"] = list(
		"name" = "Hoe blade",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 2),
		"output_type" = "hoe blade",
		"xp_reward" = 25,
		"required_rank" = 2,
		"base_success_rate" = 75,
		"description" = "Blade for farming hoe"
	)
	
	SMITHING_RECIPES["sickle blade"] = list(
		"name" = "Sickle blade",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 2),
		"output_type" = "sickle blade",
		"xp_reward" = 25,
		"required_rank" = 2,
		"base_success_rate" = 75,
		"description" = "Blade for harvesting sickle"
	)
	
	SMITHING_RECIPES["saw blade"] = list(
		"name" = "Saw blade",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 2),
		"output_type" = "saw blade",
		"xp_reward" = 25,
		"required_rank" = 2,
		"base_success_rate" = 75,
		"description" = "Blade for cutting saw"
	)
	
	SMITHING_RECIPES["chisel blade"] = list(
		"name" = "Chisel blade",
		"category" = "tools",
		"ingredients" = list("iron ingot" = 2),
		"output_type" = "chisel blade",
		"xp_reward" = 25,
		"required_rank" = 6,
		"base_success_rate" = 75,
		"description" = "Blade for stone chisel"
	)
	
	SMITHING_RECIPES["trowel blade"] = list(
		"name" = "Trowel blade",
		"category" = "tools",
		"ingredients" = list("steel ingot" = 3),
		"output_type" = "trowel blade",
		"xp_reward" = 45,
		"required_rank" = 11,
		"base_success_rate" = 70,
		"description" = "Steel blade for advanced masonry trowel"
	)
	
	// ========== WEAPONS (Rank 7-11) ==========
	// Note: Weapon output types need to be verified in Objects.dm
	// These recipes serve as templates for the menu system
	
	SMITHING_RECIPES["broad sword"] = list(
		"name" = "Broad Sword",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "broad sword",
		"xp_reward" = 40,
		"required_rank" = 7,
		"base_success_rate" = 70,
		"description" = "Wide iron sword for strong slashing attacks"
	)
	
	SMITHING_RECIPES["war sword"] = list(
		"name" = "War Sword",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "war sword",
		"xp_reward" = 45,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Balanced iron sword for combat"
	)
	
	SMITHING_RECIPES["battle sword"] = list(
		"name" = "Battle Sword",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "battle sword",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Heavy iron sword for powerful strikes"
	)
	
	SMITHING_RECIPES["war maul"] = list(
		"name" = "War Maul",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "war maul",
		"xp_reward" = 45,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Heavy iron maul for crushing blows"
	)
	
	SMITHING_RECIPES["battle hammer"] = list(
		"name" = "Battle Hammer",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "battle hammer",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Iron hammer designed for combat"
	)
	
	SMITHING_RECIPES["war axe"] = list(
		"name" = "War Axe",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "war axe",
		"xp_reward" = 45,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Iron war axe for heavy combat"
	)
	
	SMITHING_RECIPES["battle axe"] = list(
		"name" = "Battle Axe",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "battle axe",
		"xp_reward" = 50,
		"required_rank" = 10,
		"base_success_rate" = 65,
		"description" = "Large iron axe for devastating strikes"
	)
	
	SMITHING_RECIPES["war scythe"] = list(
		"name" = "War Scythe",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "war scythe",
		"xp_reward" = 45,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Iron scythe adapted for combat"
	)
	
	SMITHING_RECIPES["battle scythe"] = list(
		"name" = "Battle Scythe",
		"category" = "weapons",
		"ingredients" = list("iron ingot" = 3),
		"output_type" = "battle scythe",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Large iron scythe for combat"
	)
	
	// ========== ARMOR - EVASIVE (Rank 8-11) ==========
	// Note: Armor output types need to be verified in Objects.dm
	
	SMITHING_RECIPES["giu hide vestments"] = list(
		"name" = "Giu Hide Vestments",
		"category" = "armor_evasive",
		"ingredients" = list("copper ingot" = 2, "giu hide" = 1),
		"output_type" = "giu hide vestments",
		"xp_reward" = 35,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Light leather vestments with copper reinforcement"
	)
	
	SMITHING_RECIPES["giu shell vestments"] = list(
		"name" = "Giu Shell Vestments",
		"category" = "armor_evasive",
		"ingredients" = list("copper ingot" = 2, "giu shell" = 1),
		"output_type" = "giu shell vestments",
		"xp_reward" = 35,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Shell-reinforced copper vestments"
	)
	
	SMITHING_RECIPES["gou shellhide vestments"] = list(
		"name" = "Gou ShellHide Vestments",
		"category" = "armor_evasive",
		"ingredients" = list("bronze ingot" = 3, "gou hide" = 1, "gou shell" = 1),
		"output_type" = "gou shellhide vestments",
		"xp_reward" = 45,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Enhanced bronze vestments with creature parts"
	)
	
	SMITHING_RECIPES["coppermail vestments"] = list(
		"name" = "Coppermail Vestments",
		"category" = "armor_evasive",
		"ingredients" = list("copper ingot" = 2, "gow hide" = 1),
		"output_type" = "coppermail vestments",
		"xp_reward" = 35,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Copper mail vestments with reinforcement"
	)
	
	SMITHING_RECIPES["zinc shellplate vestments"] = list(
		"name" = "Zinc ShellPlate Vestments",
		"category" = "armor_evasive",
		"ingredients" = list("zinc ingot" = 3, "guwi hide" = 1),
		"output_type" = "zinc shellplate vestments",
		"xp_reward" = 45,
		"required_rank" = 10,
		"base_success_rate" = 65,
		"description" = "Zinc shell-plated vestments"
	)
	
	SMITHING_RECIPES["steel shellplate vestments"] = list(
		"name" = "Steel Shellplate Vestments",
		"category" = "armor_evasive",
		"ingredients" = list("steel ingot" = 3, "gowu shell" = 1),
		"output_type" = "steel shellplate vestments",
		"xp_reward" = 55,
		"required_rank" = 11,
		"base_success_rate" = 60,
		"description" = "Advanced steel shell-plated vestments"
	)
	
	SMITHING_RECIPES["monk tunic"] = list(
		"name" = "Monk Tunic",
		"category" = "armor_evasive",
		"ingredients" = list("copper ingot" = 2, "giu shell" = 1, "giu hide" = 1),
		"output_type" = "monk tunic",
		"xp_reward" = 40,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Lightweight tunic for spiritual practitioners"
	)
	
	SMITHING_RECIPES["iron studded tunic"] = list(
		"name" = "Iron Studded Tunic",
		"category" = "armor_evasive",
		"ingredients" = list("iron ingot" = 2, "gou shell" = 1, "gou hide" = 1),
		"output_type" = "iron studded tunic",
		"xp_reward" = 40,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Iron-studded leather tunic"
	)
	
	SMITHING_RECIPES["copper shellplate tunic"] = list(
		"name" = "Copper ShellPlate Tunic",
		"category" = "armor_evasive",
		"ingredients" = list("copper ingot" = 2, "gou hide" = 1, "gou shell" = 1),
		"output_type" = "copper shellplate tunic",
		"xp_reward" = 45,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Copper shell-plated tunic"
	)
	
	SMITHING_RECIPES["bronzemail tunic"] = list(
		"name" = "Bronzemail Tunic",
		"category" = "armor_evasive",
		"ingredients" = list("bronze ingot" = 2, "gow hide" = 1),
		"output_type" = "bronzemail tunic",
		"xp_reward" = 40,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Bronze mail tunic for flexible protection"
	)
	
	SMITHING_RECIPES["zincmail tunic"] = list(
		"name" = "Zincmail Tunic",
		"category" = "armor_evasive",
		"ingredients" = list("zinc ingot" = 2, "guwi hide" = 1),
		"output_type" = "zincmail tunic",
		"xp_reward" = 45,
		"required_rank" = 10,
		"base_success_rate" = 65,
		"description" = "Zinc mail tunic for cold resistance"
	)
	
	SMITHING_RECIPES["landscaper tunic"] = list(
		"name" = "Landscaper Tunic",
		"category" = "armor_evasive",
		"ingredients" = list("steel ingot" = 2, "gowu shell" = 1, "gowu hide" = 1),
		"output_type" = "landscaper tunic",
		"xp_reward" = 50,
		"required_rank" = 11,
		"base_success_rate" = 60,
		"description" = "Steel tunic designed for landscaping work"
	)
	
	SMITHING_RECIPES["giu shellhide corslet"] = list(
		"name" = "Giu ShellHide Corslet",
		"category" = "armor_evasive",
		"ingredients" = list("bronze ingot" = 3, "giu shell" = 1, "giu hide" = 1),
		"output_type" = "giu shellhide corslet",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Bronze corslet with creature reinforcement"
	)
	
	SMITHING_RECIPES["gou shellplate corslet"] = list(
		"name" = "Gou ShellPlate Corslet",
		"category" = "armor_evasive",
		"ingredients" = list("iron ingot" = 3, "gou hide" = 1, "gou shell" = 1),
		"output_type" = "gou shellplate corslet",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Iron shell-plate corslet"
	)
	
	SMITHING_RECIPES["iron platemail corslet"] = list(
		"name" = "Iron Platemail Corslet",
		"category" = "armor_evasive",
		"ingredients" = list("iron ingot" = 3, "gou hide" = 1, "gou shell" = 1),
		"output_type" = "iron platemail corslet",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Iron plate-mail corslet"
	)
	
	SMITHING_RECIPES["copper platemail corslet"] = list(
		"name" = "Copper Platemail Corslet",
		"category" = "armor_evasive",
		"ingredients" = list("copper ingot" = 3, "gow hide" = 1, "gow shell" = 1),
		"output_type" = "copper platemail corslet",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Copper plate-mail corslet"
	)
	
	SMITHING_RECIPES["bronzemail corslet"] = list(
		"name" = "Bronzemail Corslet",
		"category" = "armor_evasive",
		"ingredients" = list("bronze ingot" = 3, "guwi hide" = 1, "guwi shell" = 1),
		"output_type" = "bronzemail corslet",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Bronze mail corslet"
	)
	
	SMITHING_RECIPES["zinc platemail corslet"] = list(
		"name" = "Zinc Platemail Corslet",
		"category" = "armor_evasive",
		"ingredients" = list("zinc ingot" = 3, "gowu hide" = 1, "gowu shell" = 1),
		"output_type" = "zinc platemail corslet",
		"xp_reward" = 55,
		"required_rank" = 10,
		"base_success_rate" = 60,
		"description" = "Zinc plate-mail corslet"
	)
	
	// ========== ARMOR - DEFENSIVE (Rank 9-11) ==========
	
	SMITHING_RECIPES["copperplate cuirass"] = list(
		"name" = "CopperPlate Cuirass",
		"category" = "armor_defensive",
		"ingredients" = list("copper ingot" = 4, "giu hide" = 1, "giu shell" = 1),
		"output_type" = "copperplate cuirass",
		"xp_reward" = 55,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Heavy copper plate armor for the torso"
	)
	
	SMITHING_RECIPES["ironplate cuirass"] = list(
		"name" = "IronPlate Cuirass",
		"category" = "armor_defensive",
		"ingredients" = list("iron ingot" = 4, "gou hide" = 1, "gou shell" = 1),
		"output_type" = "ironplate cuirass",
		"xp_reward" = 55,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Heavy iron plate armor"
	)
	
	SMITHING_RECIPES["iron halfplate cuirass"] = list(
		"name" = "Iron HalfPlate Cuirass",
		"category" = "armor_defensive",
		"ingredients" = list("iron ingot" = 3, "gow hide" = 1, "gow shell" = 1),
		"output_type" = "iron halfplate cuirass",
		"xp_reward" = 50,
		"required_rank" = 9,
		"base_success_rate" = 65,
		"description" = "Half-plate iron cuirass for moderate defense"
	)
	
	SMITHING_RECIPES["bronze solidplate cuirass"] = list(
		"name" = "Bronze SolidPlate Cuirass",
		"category" = "armor_defensive",
		"ingredients" = list("bronze ingot" = 5, "gow hide" = 1, "gow shell" = 1),
		"output_type" = "bronze solidplate cuirass",
		"xp_reward" = 65,
		"required_rank" = 10,
		"base_success_rate" = 60,
		"description" = "Solid bronze plate cuirass for strong defense"
	)
	
	SMITHING_RECIPES["boreal zincplate cuirass"] = list(
		"name" = "Boreal ZincPlate Cuirass",
		"category" = "armor_defensive",
		"ingredients" = list("zinc ingot" = 5, "guwi hide" = 1, "guwi shell" = 1),
		"output_type" = "boreal zincplate cuirass",
		"xp_reward" = 65,
		"required_rank" = 10,
		"base_success_rate" = 60,
		"description" = "Zinc plate cuirass for cold regions"
	)
	
	SMITHING_RECIPES["aurelian steelplate cuirass"] = list(
		"name" = "Aurelian SteelPlate Cuirass",
		"category" = "armor_defensive",
		"ingredients" = list("steel ingot" = 7, "gowu hide" = 1, "gowu shell" = 1),
		"output_type" = "aurelian steelplate cuirass",
		"xp_reward" = 75,
		"required_rank" = 11,
		"base_success_rate" = 55,
		"description" = "Elite steel plate cuirass for maximum protection"
	)
	
	// ========== ARMOR - OFFENSIVE (Rank 9-11) ==========
	
	SMITHING_RECIPES["ironplate battlegear"] = list(
		"name" = "IronPlate Battlegear",
		"category" = "armor_offensive",
		"ingredients" = list("iron ingot" = 5, "giu hide" = 1, "giu shell" = 1),
		"output_type" = "ironplate battlegear",
		"xp_reward" = 65,
		"required_rank" = 9,
		"base_success_rate" = 60,
		"description" = "Heavy iron battle armor for combat"
	)
	
	SMITHING_RECIPES["copperplate battlegear"] = list(
		"name" = "CopperPlate Battlegear",
		"category" = "armor_offensive",
		"ingredients" = list("copper ingot" = 5, "gou hide" = 1, "gou shell" = 1),
		"output_type" = "copperplate battlegear",
		"xp_reward" = 65,
		"required_rank" = 9,
		"base_success_rate" = 60,
		"description" = "Copper battle armor with aggressive styling"
	)
	
	SMITHING_RECIPES["bronzeplate battlegear"] = list(
		"name" = "BronzePlate Battlegear",
		"category" = "armor_offensive",
		"ingredients" = list("bronze ingot" = 5, "gow hide" = 1, "gow shell" = 1),
		"output_type" = "bronzeplate battlegear",
		"xp_reward" = 65,
		"required_rank" = 9,
		"base_success_rate" = 60,
		"description" = "Bronze battle armor for warriors"
	)
	
	SMITHING_RECIPES["omphalos ironplate battlegear"] = list(
		"name" = "Omphalos IronPlate Battlegear",
		"category" = "armor_offensive",
		"ingredients" = list("iron ingot" = 3, "copper ingot" = 2, "gow hide" = 1, "gow shell" = 1),
		"output_type" = "omphalos ironplate battlegear",
		"xp_reward" = 70,
		"required_rank" = 10,
		"base_success_rate" = 55,
		"description" = "Mixed iron and copper battle armor with special design"
	)
	
	SMITHING_RECIPES["zincplate battlegear"] = list(
		"name" = "ZincPlate Battlegear",
		"category" = "armor_offensive",
		"ingredients" = list("zinc ingot" = 5, "guwi hide" = 1, "guwi shell" = 1),
		"output_type" = "zincplate battlegear",
		"xp_reward" = 70,
		"required_rank" = 10,
		"base_success_rate" = 55,
		"description" = "Zinc battle armor with superior properties"
	)
	
	SMITHING_RECIPES["steelplate battlegear"] = list(
		"name" = "SteelPlate Battlegear",
		"category" = "armor_offensive",
		"ingredients" = list("steel ingot" = 5, "gowu hide" = 1, "gowu shell" = 1),
		"output_type" = "steelplate battlegear",
		"xp_reward" = 80,
		"required_rank" = 11,
		"base_success_rate" = 50,
		"description" = "Elite steel battle armor for master warriors"
	)
	
	// ========== LAMPS (Rank 10-11) ==========
	
	SMITHING_RECIPES["iron lamp head"] = list(
		"name" = "Iron Lamp Head",
		"category" = "lamps",
		"ingredients" = list("iron ingot" = 4),
		"output_type" = "iron lamp head",
		"xp_reward" = 35,
		"required_rank" = 10,
		"base_success_rate" = 70,
		"description" = "Iron head for a basic lamp"
	)
	
	SMITHING_RECIPES["copper lamp head"] = list(
		"name" = "Copper Lamp Head",
		"category" = "lamps",
		"ingredients" = list("copper ingot" = 4),
		"output_type" = "copper lamp head",
		"xp_reward" = 35,
		"required_rank" = 10,
		"base_success_rate" = 70,
		"description" = "Copper head for decorative lamp"
	)
	
	SMITHING_RECIPES["bronze lamp head"] = list(
		"name" = "Bronze Lamp Head",
		"category" = "lamps",
		"ingredients" = list("bronze ingot" = 4),
		"output_type" = "bronze lamp head",
		"xp_reward" = 40,
		"required_rank" = 10,
		"base_success_rate" = 65,
		"description" = "Bronze head for ornate lamp"
	)
	
	SMITHING_RECIPES["brass lamp head"] = list(
		"name" = "Brass Lamp Head",
		"category" = "lamps",
		"ingredients" = list("brass ingot" = 4),
		"output_type" = "brass lamp head",
		"xp_reward" = 40,
		"required_rank" = 10,
		"base_success_rate" = 65,
		"description" = "Brass head for elegant lamp"
	)
	
	SMITHING_RECIPES["steel lamp head"] = list(
		"name" = "Steel Lamp Head",
		"category" = "lamps",
		"ingredients" = list("steel ingot" = 4),
		"output_type" = "steel lamp head",
		"xp_reward" = 50,
		"required_rank" = 11,
		"base_success_rate" = 60,
		"description" = "Steel head for advanced lamp design"
	)
	
	// ========== CONTAINERS (Rank 8-11) ==========
	
	SMITHING_RECIPES["quench box"] = list(
		"name" = "Quench Box",
		"category" = "containers",
		"ingredients" = list("ueik board" = 3, "iron ribbon" = 2, "ueik shingle" = 2),
		"output_type" = "quench box",
		"xp_reward" = 45,
		"required_rank" = 8,
		"base_success_rate" = 70,
		"description" = "Specialized box for quenching hot metals"
	)
	
	SMITHING_RECIPES["barrel"] = list(
		"name" = "Barrel",
		"category" = "containers",
		"ingredients" = list("cask board" = 18, "iron ribbon" = 10),
		"output_type" = "barrel",
		"xp_reward" = 60,
		"required_rank" = 10,
		"base_success_rate" = 60,
		"description" = "Large barrel for storage and liquid containment"
	)
	
	
	return TRUE

// Proc to get a recipe by name
/proc/GetSmithingRecipe(recipe_name)
	recipe_name = lowertext(recipe_name)
	if(recipe_name in SMITHING_RECIPES)
		return SMITHING_RECIPES[recipe_name]
	return null

// Proc to get all available recipes for a rank
/proc/GetSmithingRecipesForRank(rank)
	var/list/available = list()
	for(var/recipe_name in SMITHING_RECIPES)
		var/recipe = SMITHING_RECIPES[recipe_name]
		if(recipe["required_rank"] <= rank)
			available[recipe["name"]] = recipe_name
	return available

// Proc to get smithing recipes by category (distinct from GetRecipesByCategory in KnowledgeBase)
/proc/GetSmithingRecipesByCategory(category, rank)
	var/list/available = list()
	for(var/recipe_name in SMITHING_RECIPES)
		var/recipe = SMITHING_RECIPES[recipe_name]
		if(recipe["category"] == category && recipe["required_rank"] <= rank)
			available[recipe["name"]] = recipe_name
	return available

