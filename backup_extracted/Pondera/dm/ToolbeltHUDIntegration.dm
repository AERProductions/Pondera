/**
 * TOOLBELT HUD INTEGRATION
 * Hooks the existing ToolbeltHotbarSystem with the new HUD system
 * Synchronizes toolbelt state with on-screen display
 */

/**
 * NotifyToolbeltToolActivated(mob/players/player, slot_num, tool_name, mode_name)
 * Called when a tool is activated from the toolbelt
 * Updates HUD display to show active tool and mode
 */
proc/NotifyToolbeltToolActivated(mob/players/player, slot_num, tool_name, mode_name)
	if(!player || !player.main_hud) return
	
	// Update toolbelt HUD display (stub - HUD system not fully initialized)
	// player.main_hud.update_toolbelt_display()
	// player.main_hud.update_toolbelt_mode(mode_name)
	
	// Show system message (capitalize first letter of mode)
	// var/capitalized_mode = uppertext(copytext(mode_name, 1, 2)) + copytext(mode_name, 2)
	// player.main_hud.add_system_message("<span class='green'>[tool_name] equipped - [capitalized_mode] mode active</span>", 60)

/**
 * NotifyToolbeltToolDeactivated(mob/players/player)
 * Called when a tool is deactivated from the toolbelt
 * Clears HUD display
 */
proc/NotifyToolbeltToolDeactivated(mob/players/player)
	if(!player || !player.main_hud) return
	
	// Update toolbelt HUD display (stub - HUD system not fully initialized)
	// player.main_hud.update_toolbelt_display()
	// player.main_hud.update_toolbelt_mode("")
	
	// Show system message
	// player.main_hud.add_system_message("<span class='orange'>Tool deactivated</span>", 40)

/**
 * NotifyToolbeltSlotChanged(mob/players/player, slot_num)
 * Called when toolbelt inventory is updated (item added/removed from slot)
 * Refreshes hotbar display
 */
proc/NotifyToolbeltSlotChanged(mob/players/player, slot_num)
	if(!player || !player.main_hud) return
	
	// Update toolbelt display to show new inventory state (stub - HUD system not fully initialized)
	// player.main_hud.update_toolbelt_display()

/**
 * NotifyToolbeltStaminaDrain(mob/players/player, amount)
 * Called when tool usage drains stamina
 * Updates stamina warning display
 */
proc/NotifyToolbeltStaminaDrain(mob/players/player, amount)
	if(!player || !player.main_hud) return
	
	// Update stamina warning on toolbelt HUD (stub - HUD system not fully initialized)
	// player.main_hud.extended_hud.toolbelt_hud.update_stamina_warning()

/**
 * NotifyToolbeltUpgradeUnlocked(mob/players/player, new_slot_count)
 * Called when player unlocks more hotbar slots (2 -> 4 -> 6 -> 8 -> 9)
 * Updates HUD to show new available slots
 */
proc/NotifyToolbeltUpgradeUnlocked(mob/players/player, new_slot_count)
	if(!player || !player.main_hud) return
	
	// Refresh toolbelt display with new slot count (stub - HUD system not fully initialized)
	// player.main_hud.update_toolbelt_display()
	// player.main_hud.add_system_message("\green Toolbelt upgraded! [new_slot_count] slots available", 80)

/**
 * InitializeToolbeltHUD(mob/players/player)
 * Called from Login() to set up toolbelt HUD after player logs in
 * Ensures toolbelt display is synchronized with actual toolbelt state
 */
proc/InitializeToolbeltHUD(mob/players/player)
	if(!player || !player.main_hud || !player.toolbelt) return
	
	// Initialize hotbar display with current toolbelt state (stub - HUD system not fully initialized)
	spawn(2)
		if(player && player.main_hud && player.toolbelt)
			// player.main_hud.extended_hud.toolbelt_hud.update_hotbar_display()
			// player.main_hud.add_system_message("\green Toolbelt ready - press 1-[player.toolbelt.max_slots] to equip", 80)
			player << "Toolbelt ready!"
