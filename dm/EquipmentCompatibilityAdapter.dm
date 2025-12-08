/**
 * EquipmentCompatibilityAdapter.dm
 * 
 * Bridges legacy equipped flags (Wequipped, LSequipped, etc.) to modern equipment_slots system
 * Allows gradual migration without breaking existing combat/equipment code
 * 
 * Strategy:
 * 1. All new code uses equipment_slots
 * 2. Legacy code continues using old flags (defined in Weapons.dm)
 * 3. Adapter keeps them in sync automatically via SyncLegacyFlags()
 * 4. When all code migrated, remove adapter
 * 
 * Note: Legacy flags are defined in dm/Weapons.dm on mob type
 */

// ============================================================================
// LEGACY FLAG MAPPINGS
// ============================================================================

/**
 * Map legacy equipment flags to modern slot system
 * Format: "legacy_flag" -> "modern_slot"
 */
var/list/LEGACY_EQUIPMENT_MAP = list(
	"Wequipped" = EQUIP_SLOT_MAIN_HAND,      // Weapon
	"LSequipped" = EQUIP_SLOT_MAIN_HAND,     // Long Sword
	"AXequipped" = EQUIP_SLOT_MAIN_HAND,     // Axe
	"WHequipped" = EQUIP_SLOT_MAIN_HAND,     // War Hammer
	"TWequipped" = EQUIP_SLOT_MAIN_HAND,     // Two-Weapon
	"Sequipped" = EQUIP_SLOT_OFF_HAND,       // Shield/Off-hand
	"Aequipped" = EQUIP_SLOT_ARMOR           // Armor
)

// ============================================================================
// COMPATIBILITY PROCS
// ============================================================================

/**
 * Sync legacy flags when equipping via new system
 * Called automatically when equipment_slots[slot] is set
 * 
 * @param slot - Equipment slot being equipped
 * @param item - Item being equipped (or null if unequipping)
 */
mob/players/proc/SyncLegacyFlags(slot, obj/items/equipment/item)
	if(!slot) return
	
	var/should_be_equipped = (item ? 1 : 0)
	
	// Sync main hand weapons
	if(slot == EQUIP_SLOT_MAIN_HAND)
		if(item)
			// Set appropriate legacy flag based on item type
			if(istype(item, /obj/items/equipment/weapon/LongSword))
				LSequipped = should_be_equipped
				Wequipped = should_be_equipped
			else if(istype(item, /obj/items/equipment/weapon/Axe))
				AXequipped = should_be_equipped
				Wequipped = should_be_equipped
			else if(istype(item, /obj/items/equipment/weapon/WarHammer))
				WHequipped = should_be_equipped
				Wequipped = should_be_equipped
			else if(istype(item, /obj/items/equipment/weapon))
				Wequipped = should_be_equipped
		else
			// Unequipping
			LSequipped = 0
			AXequipped = 0
			WHequipped = 0
			Wequipped = 0
	
	// Sync off-hand (shields)
	else if(slot == EQUIP_SLOT_OFF_HAND)
		Sequipped = should_be_equipped
	
	// Sync armor
	else if(slot == EQUIP_SLOT_ARMOR)
		Aequipped = should_be_equipped

/**
 * Get modern equipment slot from legacy flag name
 * Used when legacy code modifies old flags
 * 
 * @param flag_name - Legacy flag name (e.g., "LSequipped")
 * @return Modern slot name or null
 */
proc/GetSlotFromLegacyFlag(flag_name)
	if(!flag_name) return null
	return LEGACY_EQUIPMENT_MAP[flag_name]

/**
 * Check if item matches legacy equipment class
 * Used for compatibility checks in combat/overlay code
 * 
 * @param M - Player mob
 * @param equipment_type - Legacy type to check (e.g., "WHequipped")
 * @return TRUE if equipped, FALSE otherwise
 */
proc/CheckLegacyEquipment(mob/players/M, equipment_type)
	if(!M || !equipment_type) return FALSE
	
	switch(equipment_type)
		if("Wequipped")
			return M.Wequipped
		if("LSequipped")
			return M.LSequipped
		if("AXequipped")
			return M.AXequipped
		if("WHequipped")
			return M.WHequipped
		if("Sequipped")
			return M.Sequipped
		if("Aequipped")
			return M.Aequipped
		if("TWequipped")
			return M.TWequipped
		else
			return FALSE

/**
 * Modern compatibility check - use this instead of legacy flag checks
 * Checks both legacy flags AND new equipment system
 * 
 * @param M - Player mob
 * @param equipment_class - Equipment type to check
 * @return TRUE if equipped, FALSE otherwise
 * 
 * Example: IsEquippedModern(usr, "weapon") checks if any weapon equipped
 */
proc/IsEquippedModern(mob/players/M, equipment_class)
	if(!M) return FALSE
	
	switch(equipment_class)
		if("weapon")
			return M.Wequipped || M.equipment_slots[EQUIP_SLOT_MAIN_HAND]
		if("shield")
			return M.Sequipped || M.equipment_slots[EQUIP_SLOT_OFF_HAND]
		if("armor")
			return M.Aequipped || M.equipment_slots[EQUIP_SLOT_ARMOR]
		else
			return FALSE

// ============================================================================
// MIGRATION HELPERS
// ============================================================================

/**
 * Convert legacy equip operation to modern system
 * Use this when refactoring old code:
 * 
 * OLD: usr.WHequipped = 1
 * NEW: ConvertLegacyEquip(usr, "WHequipped", 1, item)
 * 
 * @param M - Player mob
 * @param flag_name - Legacy flag (e.g., "WHequipped")
 * @param value - 0=unequip, 1=equip, 2=dual-wield
 * @param item - Item object being equipped
 */
proc/ConvertLegacyEquip(mob/players/M, flag_name, value, obj/items/equipment/item)
	if(!M || !flag_name) return FALSE
	
	// Legacy value: 0=unequipped, 1=equipped, 2=dual-wielding
	if(value == 2)
		// Dual wield - needs special handling
		world.log << "[M.name] dual-wielding (legacy mode)"
		return TRUE
	
	// Get modern slot
	var/slot = GetSlotFromLegacyFlag(flag_name)
	if(!slot) return FALSE
	
	// Equip or unequip via modern system
	if(value == 1)
		return M.EquipItem(item)
	else
		return M.UnequipItem(item)

// ============================================================================
// INTEGRATION HOOKS
// ============================================================================

/**
 * NOTE: CentralizedEquipmentSystem.EquipItem() should call SyncLegacyFlags()
 * after successful equipment to keep legacy flags in sync
 * 
 * In CentralizedEquipmentSystem.dm EquipItem() proc, add:
 *   SyncLegacyFlags(slot, item)
 * at the end of the proc
 */

/**
 * NOTE: CentralizedEquipmentSystem.UnequipItem() should call SyncLegacyFlags()
 * after successful unequipment to keep legacy flags in sync
 * 
 * In CentralizedEquipmentSystem.dm UnequipItem() proc, add:
 *   SyncLegacyFlags(slot, null)
 * at the end of the proc
 */

// ============================================================================
// MIGRATION ROADMAP
// ============================================================================

/*
PHASE 1: Compatibility Layer (CURRENT)
- Legacy flags continue to work
- New equipment_slots system parallel
- Adapter keeps them in sync
- No combat code changes

PHASE 2: Gradual Code Migration (Next Sprint)
- Refactor Basics.dm combat code to use IsEquippedModern()
- Refactor Objects.dm overlay code to use modern equipment
- Test that both systems work simultaneously

PHASE 3: Legacy Flag Deprecation (Later)
- Once all combat code migrated, remove legacy flags
- Remove this compatibility layer
- Clean equipment system only

MIGRATION CHECKLIST:
- [ ] Test combat with legacy flags (should still work)
- [ ] Test combat with modern equipment_slots (should work)
- [ ] Test overlay rendering with both systems
- [ ] Verify equipment persistence (save/load)
- [ ] Profile performance (should be equivalent)
*/
