/**
 * EQUIPMENT STATE DATUM
 * 
 * Manages serialization/deserialization of player equipment loadout.
 * Tracks which equipment slots are filled and with which items.
 * 
 * Equipment slots tracked:
 * - Wequipped (Weapon)
 * - Sequipped (Shield)
 * - Aequipped (Armor)
 * - And other specific weapon types (TWequipped, LSequipped, AXequipped, etc.)
 */

/datum/equipment_state
	var
		// Equipment slot flags (0 = empty, 1 = equipped, 2 = two-handed)
		Wequipped = 0         // Single-handed weapon
		TWequipped = 0        // Two-handed weapon
		Sequipped = 0         // Shield
		Aequipped = 0         // Armor
		LSequipped = 0        // Long sword
		AXequipped = 0        // Axe
		WHequipped = 0        // War hammer
		JRequipped = 0        // ...and so on
		FPequipped = 0
		PXequipped = 0
		SHequipped = 0
		HMequipped = 0
		SKequipped = 0
		HOequipped = 0
		CKequipped = 0
		GVequipped = 0
		FLequipped = 0
		PYequipped = 0
		OKequipped = 0
		SHMequipped = 0
		UPKequipped = 0
		
		// Stored equipment object references (for quick re-equip)
		list/equipped_items = list()
		// Format: list("slot_name" = item_ref, ...)

	proc/CaptureEquipment(mob/players/player)
		/**
		 * CaptureEquipment(player)
		 * Records the current equipment state from the player.
		 */
		if(!player) return
		
		// Copy all equipment flags
		Wequipped = player.Wequipped
		TWequipped = player.TWequipped
		Sequipped = player.Sequipped
		Aequipped = player.Aequipped
		LSequipped = player.LSequipped
		AXequipped = player.AXequipped
		WHequipped = player.WHequipped
		JRequipped = player.JRequipped
		FPequipped = player.FPequipped
		PXequipped = player.PXequipped
		SHequipped = player.SHequipped
		HMequipped = player.HMequipped
		SKequipped = player.SKequipped
		HOequipped = player.HOequipped
		CKequipped = player.CKequipped
		GVequipped = player.GVequipped
		FLequipped = player.FLequipped
		PYequipped = player.PYequipped
		OKequipped = player.OKequipped
		SHMequipped = player.SHMequipped
		UPKequipped = player.UPKequipped

	proc/RestoreEquipment(mob/players/player)
		/**
		 * RestoreEquipment(player)
		 * Restores the equipment state to the player.
		 * Note: Actual item objects are restored via normal savefile loading,
		 * this just restores the "equipped" flags.
		 */
		if(!player) return
		
		// Restore all equipment flags
		player.Wequipped = Wequipped
		player.TWequipped = TWequipped
		player.Sequipped = Sequipped
		player.Aequipped = Aequipped
		player.LSequipped = LSequipped
		player.AXequipped = AXequipped
		player.WHequipped = WHequipped
		player.JRequipped = JRequipped
		player.FPequipped = FPequipped
		player.PXequipped = PXequipped
		player.SHequipped = SHequipped
		player.HMequipped = HMequipped
		player.SKequipped = SKequipped
		player.HOequipped = HOequipped
		player.CKequipped = CKequipped
		player.GVequipped = GVequipped
		player.FLequipped = FLequipped
		player.PYequipped = PYequipped
		player.OKequipped = OKequipped
		player.SHMequipped = SHMequipped
		player.UPKequipped = UPKequipped

	proc/ValidateEquipment(mob/players/player)
		/**
		 * ValidateEquipment(player)
		 * Verifies that equipped items still exist in player contents.
		 * Returns 1 if valid, 0 if corruption detected.
		 */
		if(!player) return 0
		
		var/list/equipped_slots = list(
			"Wequipped", "TWequipped", "Sequipped", "Aequipped",
			"LSequipped", "AXequipped", "WHequipped", "JRequipped",
			"FPequipped", "PXequipped", "SHequipped", "HMequipped",
			"SKequipped", "HOequipped", "CKequipped", "GVequipped",
			"FLequipped", "PYequipped", "OKequipped", "SHMequipped", "UPKequipped"
		)
		
		for(var/slot in equipped_slots)
			var/equipped_flag = player.vars[slot]
			if(equipped_flag && equipped_flag > 0)
				// Slot is marked as equipped - verify an item exists
				var/found = 0
				for(var/obj/item in player.contents)
					if(item.suffix == "Equipped")
						found = 1
						break
				if(!found) return 0
		
		return 1
