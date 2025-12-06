// CentralizedEquipmentSystem.dm
// Refactored equipment system replacing individual equip flags with a generic centralized system

// Equipment slot constants
#define EQUIP_SLOT_MAIN_HAND "main_hand"
#define EQUIP_SLOT_OFF_HAND "off_hand"
#define EQUIP_SLOT_ARMOR "armor"
#define EQUIP_SLOT_SHIELD "shield"

// Equipment state values
#define EQUIP_STATE_UNEQUIPPED 0
#define EQUIP_STATE_EQUIPPED 1
#define EQUIP_STATE_DUAL_WIELD 2

// Equipment categories
#define EQUIP_CAT_WEAPON 1
#define EQUIP_CAT_TOOL 2
#define EQUIP_CAT_ARMOR 3
#define EQUIP_CAT_SHIELD 4

// Base equipment class
obj/items/equipment
	var
		equip_slot = null
		equip_category = null
		equip_state = EQUIP_STATE_UNEQUIPPED
		strreq = 0
		dexreq = 0
		intreq = 0
		spiritreq = 0
		damage_min = 0
		damage_max = 0
		attack_speed = 0
		defense = 0
		twohanded = FALSE
		can_dual_wield = FALSE
		dual_wield_pairs = list()
		on_equip_proc = null
		on_unequip_proc = null
		on_use_proc = null
		overlay_icon_state = null

// Weapon subtypes
obj/items/equipment/weapon
	equip_category = EQUIP_CAT_WEAPON
	can_dual_wield = TRUE

obj/items/equipment/weapon/LongSword
	name = "Long Sword"
	icon = 'dmi/tower.dmi'
	icon_state = "sword1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 8
	damage_max = 15
	attack_speed = -3
	twohanded = TRUE
	strreq = 8

obj/items/equipment/weapon/WarHammer
	name = "War Hammer"
	icon = 'dmi/tower.dmi'
	icon_state = "hammer1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 10
	damage_max = 18
	attack_speed = -4
	twohanded = TRUE
	strreq = 12

obj/items/equipment/weapon/GreatMace
	name = "Great Mace"
	icon = 'dmi/tower.dmi'
	icon_state = "mace1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 12
	damage_max = 20
	attack_speed = -5
	twohanded = TRUE
	strreq = 14

obj/items/equipment/weapon/Axe
	name = "Axe"
	icon = 'dmi/tower.dmi'
	icon_state = "axe1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 7
	damage_max = 14
	attack_speed = -2
	strreq = 7

obj/items/equipment/weapon/Scythe
	name = "Scythe"
	icon = 'dmi/tower.dmi'
	icon_state = "scythe1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 9
	damage_max = 16
	attack_speed = -3
	strreq = 10

// Tool subtypes
obj/items/equipment/tool
	equip_category = EQUIP_CAT_TOOL
	can_dual_wield = TRUE

obj/items/equipment/tool/Pickaxe
	name = "Pickaxe"
	icon = 'dmi/tower.dmi'
	icon_state = "pickaxe1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 5
	damage_max = 10
	attack_speed = -2
	strreq = 6
	on_use_proc = "UseMiningTool"

obj/items/equipment/tool/Hammer
	name = "Hammer"
	icon = 'dmi/tower.dmi'
	icon_state = "hammer2"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 6
	damage_max = 12
	attack_speed = -2
	strreq = 8
	can_dual_wield = TRUE

obj/items/equipment/tool/CarvingKnife
	name = "Carving Knife"
	icon = 'dmi/tower.dmi'
	icon_state = "knife1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 3
	damage_max = 8
	attack_speed = 1
	strreq = 4
	can_dual_wield = TRUE
	on_use_proc = "UseCarvingKnife"

obj/items/equipment/tool/Flint
	name = "Flint"
	icon = 'dmi/tower.dmi'
	icon_state = "flint1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 2
	damage_max = 6
	attack_speed = 2
	can_dual_wield = TRUE
	on_use_proc = "UseFlint"

obj/items/equipment/tool/Pyrite
	name = "Pyrite"
	icon = 'dmi/tower.dmi'
	icon_state = "pyrite1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 2
	damage_max = 6
	attack_speed = 2
	can_dual_wield = TRUE
	on_use_proc = "UsePyrite"

obj/items/equipment/tool/Chisel
	name = "Chisel"
	icon = 'dmi/tower.dmi'
	icon_state = "chisel1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 3
	damage_max = 7
	attack_speed = 1
	strreq = 5
	can_dual_wield = TRUE

obj/items/equipment/tool/Hoe
	name = "Hoe"
	icon = 'dmi/tower.dmi'
	icon_state = "hoe1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 4
	damage_max = 9
	attack_speed = -1
	strreq = 5
	on_use_proc = "UseHoe"

obj/items/equipment/tool/Shovel
	name = "Shovel"
	icon = 'dmi/tower.dmi'
	icon_state = "shovel1"
	equip_slot = EQUIP_SLOT_MAIN_HAND
	damage_min = 5
	damage_max = 11
	attack_speed = -2
	strreq = 7
	on_use_proc = "UseShovel"

// Armor subtypes
obj/items/equipment/armor
	equip_category = EQUIP_CAT_ARMOR
	equip_slot = EQUIP_SLOT_ARMOR

obj/items/equipment/armor/LightArmor
	name = "Light Armor"
	icon = 'dmi/tower.dmi'
	icon_state = "armor1"
	defense = 3

obj/items/equipment/armor/MediumArmor
	name = "Medium Armor"
	icon = 'dmi/tower.dmi'
	icon_state = "armor2"
	defense = 6
	strreq = 8

obj/items/equipment/armor/HeavyArmor
	name = "Heavy Armor"
	icon = 'dmi/tower.dmi'
	icon_state = "armor3"
	defense = 10
	strreq = 15

// Shield subtypes
obj/items/equipment/shield
	equip_category = EQUIP_CAT_SHIELD
	equip_slot = EQUIP_SLOT_SHIELD
	can_dual_wield = TRUE

obj/items/equipment/shield/BasicShield
	name = "Basic Shield"
	icon = 'dmi/tower.dmi'
	icon_state = "shield1"
	defense = 2

obj/items/equipment/shield/KiteShield
	name = "Kite Shield"
	icon = 'dmi/tower.dmi'
	icon_state = "shield2"
	defense = 5
	strreq = 6

// Equipment verbs (defined after types to avoid forward references)
obj/items/equipment
	verb/Equip()
		set category = null
		set popup_menu = 1
		set src in usr
		var/mob/players/M = usr
		if(!M) return
		M.EquipItem(src)
	
	verb/Unequip()
		set category = null
		set popup_menu = 1
		set src in usr
		var/mob/players/M = usr
		if(!M) return
		M.UnequipItem(src)

// Mob equipment management
mob/players
	var
		list/equipment_slots = alist(
			"main_hand" = null,
			"off_hand" = null,
			"armor" = null,
			"shield" = null
		)
	
	// Equip item into appropriate slot
	proc/EquipItem(obj/items/equipment/item)
		if(!item || !item.equip_slot) return FALSE
		
		var/slot = item.equip_slot
		
		// Check requirements
		if(item.strreq && tempstr < item.strreq)
			usr << "Insufficient strength. Requires [item.strreq], you have [tempstr]."
			return FALSE
		
		// Check if slot occupied
		var/obj/items/equipment/current = equipment_slots[slot]
		if(current)
			UnequipItem(current)
		
		// Equip the item
		item.equip_state = EQUIP_STATE_EQUIPPED
		item.suffix = "Equipped"
		equipment_slots[slot] = item
		
		// Apply stat bonuses
		tempdamagemin += item.damage_min
		tempdamagemax += item.damage_max
		tempdefense += item.defense
		
		// Call custom equip handler if defined
		if(item.on_equip_proc)
			call(src, item.on_equip_proc)()
		
		usr << "You equip [item.name]."
		return TRUE
	
	// Unequip item
	proc/UnequipItem(obj/items/equipment/item)
		if(!item) return FALSE
		
		var/slot = item.equip_slot
		if(!slot) return FALSE
		
		// Remove stat bonuses
		tempdamagemin -= item.damage_min
		tempdamagemax -= item.damage_max
		tempdefense -= item.defense
		
		// Call custom unequip handler if defined
		if(item.on_unequip_proc)
			call(src, item.on_unequip_proc)()
		
		item.equip_state = EQUIP_STATE_UNEQUIPPED
		item.suffix = ""
		equipment_slots[slot] = null
		
		usr << "You unequip [item.name]."
		return TRUE
	
	// Get all equipped items
	proc/GetAllEquippedItems()
		var/list/equipped = list()
		for(var/slot in equipment_slots)
			if(equipment_slots[slot])
				equipped += equipment_slots[slot]
		return equipped
