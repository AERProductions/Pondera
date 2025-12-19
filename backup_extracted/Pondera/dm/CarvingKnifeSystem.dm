/// CarvingKnifeSystem.dm
/// Carving system for WOOD CARVING ONLY
/// Outputs kindling only (primary use for fire-making)
/// Works with CentralizedEquipmentSystem durability tracking
/// 
/// Features:
/// - Wood carving to produce kindling
/// - Durability reduction per carving action (1 durability per action)
/// - Output: Kindling (for fire-making via kindling + forge recipe)
/// - Skill progression via RANK_CARVING

/mob/players
	proc/UseCarvingKnife()
		/// Called when carving knife is equipped and user initiates carving UI
		/// Opens menu for selecting what to carve
		src.OpenCarvingMenu()
	
	proc/OpenCarvingMenu()
		/// Main carving menu - WOOD CARVING ONLY
		/// Carves kindling for fire-making (primary use)
		var/obj/items/equipment/tool/knife = equipment_slots["main_hand"]
		
		if(!knife || !istype(knife, /obj/items/equipment/tool/CarvingKnife))
			src << "<yellow>You need a carving knife equipped.</yellow>"
			return
		
		// Check durability
		if(knife.IsBroken())
			src << "<red>Your carving knife is broken!</red>"
			return
		
		// Show carving options - WOOD ONLY
		var/list/carving_options = list(
			"Carve Kindling",
			"Cancel"
		)
		
		var/choice = input("What would you like to carve?", "Wood Carving") in carving_options
		
		if(choice == "Cancel" || !choice)
			src << "You stop carving."
			return
		
		switch(choice)
			if("Carve Kindling")
				AttemptCarvingAction("kindling")
	
	proc/AttemptCarvingAction(carving_type = "kindling")
		/// Performs carving action and consumes durability
		/// carving_type: "kindling" (for fire-starting) or "details" (crafting materials)
		
		var/obj/items/equipment/knife = equipment_slots["main_hand"]
		
		if(!knife || !istype(knife, /obj/items/equipment/tool/CarvingKnife))
			return FALSE
		
		// Verify knife still works
		if(knife.IsBroken())
			src << "<red>Your carving knife is broken!</red>"
			return FALSE
		
		// Verify stamina
		if(stamina < 10)
			src << "<yellow>You're too tired to carve. Rest first.</yellow>"
			return FALSE
		
		// Reduce knife durability for carving (1 per action)
		if(!knife.AttemptUse())
			src << "<red>Your carving knife has shattered mid-carving!</red>"
			return FALSE
		
		// Show wear warning
		if(knife.IsFragile())
			var/percent = knife.GetDurabilityPercent()
			src << "<yellow>Your carving knife is almost broken ([percent]% durability left).</yellow>"
		
		// Consume stamina for carving action
		stamina = max(0, stamina - 10)
		
		// Perform the carving action
		ExecuteCarvingAction(carving_type)
		
		return TRUE
	
	proc/ExecuteCarvingAction(carving_type = "kindling")
		/// Executes actual carving logic and generates kindling output ONLY
		/// carving_type: "kindling" (for fire-starting)
		
		if(!character) return
		
		var/rank = character.GetRankLevel(RANK_CARVING) || 1
		var/success_chance = 50 + (rank * 10)  // 60-100% based on rank
		var/critical_chance = rank * 5  // 5-25% critical chance
		
		// Roll for success
		if(rand(0, 100) > success_chance)
			src << "<orange>Your carving attempt fails and the wood splits! You waste materials.</orange>"
			return
		
		// Check for critical success
		var/is_critical = (rand(0, 100) <= critical_chance)
		
		// Generate output - KINDLING ONLY
		var/output_amount = 1
		var/xp_reward = 5 + (rank * 2)
		
		if(is_critical)
			output_amount = 3
			src << "<lime>CRITICAL SUCCESS! You carve three bundles of kindling!</lime>"
		else
			src << "<cyan>You carve some kindling.</cyan>"
		
		// Create kindling items and add to inventory
		for(var/i = 1; i <= output_amount; i++)
			var/obj/items/Kindling/K = new(src)
			//src.AddItemInventory(K)  // TODO: Fix inventory integration
			src.contents.Add(K)
		
		// Award XP for carving
		character.UpdateRankExp(RANK_CARVING, xp_reward)
		
		// Check for rank up
		var/old_rank = rank
		var/new_rank = character.GetRankLevel(RANK_CARVING)
		if(new_rank > old_rank)
			src << "<lime>Your carving skill has improved to rank [new_rank]!</lime>"

// ==================== CARVING RANK DEFINITION ====================

// Ensure RANK_CARVING is defined in UnifiedRankSystem
// If not defined elsewhere, add to UnifiedRankSystem.dm:
// #define RANK_CARVING "carving_rank"

