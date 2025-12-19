/// FireStartingSystem.dm
/// Fire-starting system using dual-wield Flint and Pyrite
/// Integrates with CentralizedEquipmentSystem durability
///
/// Features:
/// - Dual-wield Flint + Pyrite (no visible action when equipped)
/// - These tools ENABLE fire-making but create nothing themselves
/// - Fire is created via recipe: Flint + Pyrite + Kindling → Campfire
/// - Durability reduction: 1 per fire creation (via recipe execution)
/// - Player role: Equip both, then use in campfire_light recipe

/mob/players
	proc/UseFlintAndPyrite()
		/// Called when player has Flint+Pyrite equipped
		/// This proc exists for integration but doesn't do anything
		/// Flint+Pyrite are TOOLS that enable recipes, not action items
		/// 
		/// To make fire:
		/// 1. Have Kindling (from Carving Knife)
		/// 2. Have Flint + Pyrite equipped
		/// 3. Access campfire_light recipe
		/// 4. Recipe uses up: Flint (1), Pyrite (1), Kindling (1)
		/// 5. Creates: Campfire object
		
		// No action needed - they're just enabling tools
		src << "<yellow>You have flint and pyrite equipped. You can now make fire with kindling.</yellow>"
		return TRUE

// ==================== FIRE-MAKING WORKFLOW ====================
// Step 1: Carve Kindling
//   - Equip Carving Knife
//   - Press E → Select "Carve Kindling"
//   - Get 1-3 Kindling items
//
// Step 2: Equip Fire-Making Tools
//   - Equip Flint (off-hand) + Pyrite (main-hand)
//   - They sit there, enabling fire recipes
//
// Step 3: Access Fire Recipe
//   - Have Kindling + Flint + Pyrite
//   - Open crafting menu (location: UNKNOWN)
//   - Select "campfire_light" recipe
//   - Inputs: Flint (1), Pyrite (1), Kindling (1)
//   - Outputs: Campfire (1)
//
// Step 4: Use Fire
//   - Campfire object created at player location or forge
//   - Used for cooking, smelting, forging

