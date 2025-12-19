// ============================================================================
// SmithingModernE-Key.dm - E-key Support for Smithing Stations
// ============================================================================
// Purpose: Add UseObject() support to anvil/forge objects for E-key macro access
// Integration: Calls new modular SmithingMenuSystem.dm instead of monolithic verb
// Status: Phase 2 Complete - E-key routing to modern menu system
//
// Architecture:
// - Anvil/Forge UseObject() → DisplaySmithingCraftingMenu(M)
// - DisplaySmithingCraftingMenu() → DisplaySmithingMenu() [SmithingMenuSystem.dm]
// - Menu system → Category selection → Item crafting
// ============================================================================

/obj/Buildable/Smithing/Anvil
	// E-key handler for anvil interaction
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Call new modular menu system instead of old verb
			DisplaySmithingCraftingMenu(user)
			return 1
		return 0

/obj/Buildable/Smithing/Forge
	// E-key handler for forge interaction  
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			// Call new modular menu system instead of old verb
			DisplaySmithingCraftingMenu(user)
			return 1
		return 0

/obj/Buildable/Smithing/EmptyForge
	// E-key handler for empty forge interaction
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			DisplaySmithingCraftingMenu(user)
			return 1
		return 0

/obj/Buildable/Smithing/LitForge
	// E-key handler for lit forge interaction
	UseObject(mob/user)
		if(user in range(1, src))
			set waitfor = 0
			DisplaySmithingCraftingMenu(user)
			return 1
		return 0

// ============================================================================
// Phase 2 Refactor Notes:
// 
// BEFORE (monolithic):
//  - Objects.dm Smithing() verb: 3765+ lines
//  - Nested rank switches (1-11)
//  - Nested category switches (5 types)
//  - 65+ hardcoded item handlers
//  - Difficulty: Adding new recipes required editing verb deeply
// 
// AFTER (modular):
//  - SmithingRecipes.dm: 717 lines (registry only)
//  - SmithingMenuSystem.dm: 192 lines (UI/category display)
//  - SmithingCraftingHandler.dm: 270 lines (crafting logic)
//  - Total: 1179 lines vs 3765 lines (-3.2x reduction)
//  - Difficulty: Adding new recipes = 1 list entry in registry
// 
// ============================================================================
// END SmithingModernE-Key.dm
// ============================================================================
