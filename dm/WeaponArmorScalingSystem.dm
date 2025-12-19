/**
 * WeaponArmorScalingSystem.dm
 * Phase 16c: Weapon/Armor Scaling & Durability
 * 
 * Purpose: Connect material properties to combat equipment stats
 * - Materials → Equipment crafting with scaled damage/AC/durability
 * - Quality modifiers from crafting skill
 * - Durability decay on use, repair mechanics
 * - Equipment degradation affects combat performance
 * 
 * Architecture:
 * - /datum/equipment_stats: Material-based equipment definition
 * - /obj/items/weapons - Weapons inherit from equipment_stats
 * - /obj/items/armor - Armor inherits from equipment_stats
 * - Integration: CentralizedEquipmentSystem + MaterialRegistrySystem
 * 
 * Tick Schedule:
 * - T+398: Weapon/armor scaling system initialization
 * - T+399: Register equipment crafting recipes
 */

// ============================================================================
// EQUIPMENT STATS DATUM
// ============================================================================

/datum/equipment_stats
	var
		// Item identification
		item_name = ""
		item_type = ""
		material_name = ""
		continent_name = ""
		
		// Crafting info
		required_level = 1
		crafting_skill = "smithing"
		
		// Base stats (from material)
		base_damage = 0
		armor_class = 0
		durability_max = 100
		durability_current = 100
		
		// Quality modifiers
		quality_percent = 100
		damage_modifier = 1.0
		armor_modifier = 1.0
		durability_modifier = 1.0
		
		// Weight & encumbrance
		weight = 0
		
		// Cosmetics
		icon_state = ""
		description = ""

// ============================================================================
// EQUIPMENT ITEM BASE CLASS
// ============================================================================

/obj/items/equipment
	/**
	 * equipment
	 * Base class for all scalable equipment
	 * Inherits material properties
	 */
	name = "Equipment"
	desc = "A piece of equipment"
	
	var
		// Equipment stats
		datum/equipment_stats/stats = null
		current_damage = 0
		current_armor = 0
		current_durability = 100
		max_durability = 100        // Added for tool durability systems
		durability_threshold = 25
		
		// Equipment binding
		is_equipped = FALSE
		equipped_by = null
		
		// Durability tracking
		hits_dealt = 0
		hits_taken = 0
		repairs_count = 0
		last_repair_time = 0
		
		// Lifecycle
		crafted_time = 0
		crafted_by = ""

/obj/items/equipment/New()
	..()
	stats = new /datum/equipment_stats()
	crafted_time = world.time

/obj/items/equipment/Click()
	/**
	 * Click()
	 * Equip/unequip item
	 */
	if(!usr)
		return
	
	if(is_equipped)
		Unequip(usr)
	else
		Equip(usr)

/proc/Equip(mob/player, obj/items/equipment/item)
	/**
	 * Equip(mob/player, obj/items/equipment/item)
	 * Equip item on player
	 */
	if(!player || !item)
		return FALSE
	
	// Check slot availability
	// Check weight limits
	// Add to equipment overlay
	
	item.is_equipped = TRUE
	item.equipped_by = player
	item.current_damage = item.stats.base_damage * (item.stats.quality_percent / 100.0)
	item.current_armor = item.stats.armor_class * (item.stats.quality_percent / 100.0)
	
	player << "You equip [item.name]"
	return TRUE

/proc/Unequip(mob/player, obj/items/equipment/item)
	/**
	 * Unequip(mob/player, obj/items/equipment/item)
	 * Unequip item from player
	 */
	if(!player || !item)
		return FALSE
	
	item.is_equipped = FALSE
	item.equipped_by = null
	item.current_damage = 0
	item.current_armor = 0
	
	player << "You unequip [item.name]"
	return TRUE

// ============================================================================
// WEAPON EQUIPMENT CLASS
// ============================================================================

/obj/items/equipment/weapon
	/**
	 * weapon
	 * Scalable weapon using material system
	 */
	name = "Weapon"
	desc = "A weapon forged from materials"
	
	var
		weapon_type = "sword"
		crit_chance = 0

/proc/CraftWeapon(material_name, continent_name, crafter_level)
	/**
	 * CraftWeapon(material_name, continent_name, crafter_level)
	 * Craft a weapon from material
	 * Returns: /obj/items/equipment/weapon or null
	 */
	
	if(!material_name || !continent_name)
		return null
	
	// Get material from registry
	var/datum/material_config/material = GetMaterial(continent_name, material_name)
	if(!material)
		return null
	
	// Create weapon
	var/obj/items/equipment/weapon/weapon = new()
	weapon.name = material.name + " Sword"
	weapon.stats.item_name = weapon.name
	weapon.stats.material_name = material_name
	weapon.stats.continent_name = continent_name
	weapon.stats.base_damage = material.base_damage
	weapon.stats.durability_max = material.durability
	weapon.stats.weight = material.weight || 5
	var/quality = CalculateEquipmentQuality(crafter_level)
	weapon.stats.quality_percent = quality
	weapon.stats.damage_modifier = quality / 100.0
	weapon.stats.durability_modifier = quality / 100.0
	weapon.current_damage = weapon.stats.base_damage * weapon.stats.damage_modifier
	weapon.current_durability = weapon.stats.durability_max * weapon.stats.durability_modifier
	
	world.log << "CRAFTING: [material.name] weapon crafted (quality: [quality]%)"
	
	return weapon

/proc/CalculateEquipmentQuality(crafter_level)
	/**
	 * CalculateEquipmentQuality(crafter_level)
	 * Calculate equipment quality from crafting level
	 * Returns: 80-120 quality percentage
	 */
	
	// Base 100% at level 1
	// +4% per level (so level 5 = 116%)
	var/quality = 100 + ((crafter_level - 1) * 4)
	if(quality > 120)
		quality = 120
	
	return quality

// ============================================================================
// ARMOR EQUIPMENT CLASS
// ============================================================================

/obj/items/equipment/armor
	/**
	 * armor
	 * Scalable armor using material system
	 */
	name = "Armor"
	desc = "Protective armor forged from materials"
	
	var
		armor_type = "plate"
		coverage = 0
		encumbrance = 0

/proc/CraftArmor(material_name, continent_name, crafter_level)
	/**
	 * CraftArmor(material_name, continent_name, crafter_level)
	 * Craft armor from material
	 * Returns: /obj/items/equipment/armor or null
	 */
	
	if(!material_name || !continent_name)
		return null
	
	// Get material from registry
	var/datum/material_config/material = GetMaterial(continent_name, material_name)
	if(!material)
		return null
	
	// Create armor
	var/obj/items/equipment/armor/armor = new()
	armor.name = material.name + " Plate Armor"
	armor.stats.item_name = armor.name
	armor.stats.material_name = material_name
	armor.stats.continent_name = continent_name
	armor.stats.armor_class = material.armor_ac
	armor.stats.durability_max = material.durability * 1.5
	armor.stats.weight = (material.weight || 5) * 2
	
	// Apply quality modifier from crafter skill
	var/quality = CalculateEquipmentQuality(crafter_level)
	armor.stats.quality_percent = quality
	armor.stats.armor_modifier = quality / 100.0
	armor.stats.durability_modifier = quality / 100.0
	armor.current_armor = armor.stats.armor_class * armor.stats.armor_modifier
	armor.current_durability = armor.stats.durability_max * armor.stats.durability_modifier
	
	world.log << "CRAFTING: [material.name] armor crafted (quality: [quality]%)"
	
	return armor

// ============================================================================
// DURABILITY & DEGRADATION
// ============================================================================

/proc/DurabilityScan(obj/items/equipment/item)
	/**
	 * DurabilityScan(obj/items/equipment/item)
	 * Check equipment condition and apply degradation
	 * Lower durability = reduced performance
	 */
	
	if(!item)
		return FALSE
	
	var/durability_percent = (item.current_durability / item.stats.durability_max) * 100
	switch(durability_percent)
		if(75 to 100)
			// Perfect condition
			item.current_damage = item.stats.base_damage * item.stats.damage_modifier
			item.current_armor = item.stats.armor_class * item.stats.armor_modifier
		if(50 to 75)
			// Worn - 10% performance loss
			item.current_damage = item.stats.base_damage * item.stats.damage_modifier * 0.9
			item.current_armor = item.stats.armor_class * item.stats.armor_modifier * 0.9
		if(25 to 50)
			// Damaged - 30% performance loss
			item.current_damage = item.stats.base_damage * item.stats.damage_modifier * 0.7
			item.current_armor = item.stats.armor_class * item.stats.armor_modifier * 0.7
		if(0 to 25)
			// Nearly broken - 60% performance loss
			item.current_damage = item.stats.base_damage * item.stats.damage_modifier * 0.4
			item.current_armor = item.stats.armor_class * item.stats.armor_modifier * 0.4
	
	return TRUE

/proc/DecrementDurability(obj/items/equipment/item, damage_amount)
	/**
	 * DecrementDurability(obj/items/equipment/item, damage_amount)
	 * Reduce equipment durability (in combat)
	 */
	
	if(!item)
		return FALSE
	
	// Only equipped items take durability damage
	if(!item.is_equipped)
		return FALSE
	
	// 1 durability per 5 damage taken (0.2x damage = durability loss)
	var/durability_loss = damage_amount * 0.2
	item.current_durability -= durability_loss
	
	if(item.current_durability < 0)
		item.current_durability = 0
	DurabilityScan(item)
	
	item.hits_taken++
	
	return TRUE

/proc/RepairEquipment(obj/items/equipment/item, lucre_cost)
	/**
	 * RepairEquipment(obj/items/equipment/item, lucre_cost)
	 * Repair equipment to full durability
	 * Player must pay lucre
	 */
	
	if(!item || item.current_durability >= item.stats.durability_max)
		return FALSE
	
	// Framework: Deduct lucre from player
	// Restore durability
	item.current_durability = item.stats.durability_max
	item.repairs_count++
	item.last_repair_time = world.time
	DurabilityScan(item)
	
	world.log << "REPAIR: [item.name] repaired to [item.stats.durability_max] durability"
	
	return TRUE

/proc/CalculateRepairCost(obj/items/equipment/item)
	/**
	 * CalculateRepairCost(obj/items/equipment/item)
	 * Calculate repair cost based on damage taken
	 * Higher tier materials cost more to repair
	 */
	
	if(!item)
		return 0
	
	// Get material tier
	var/datum/material_config/material = GetMaterial(item.stats.continent_name, item.stats.material_name)
	if(!material)
		return 0
	
	// Base repair cost = material base_price * (durability loss % / 100)
	var/durability_loss_percent = ((item.stats.durability_max - item.current_durability) / item.stats.durability_max) * 100
	var/repair_cost = material.base_price * (durability_loss_percent / 100.0)
	
	return ceil(repair_cost)

// ============================================================================
// EQUIPMENT DAMAGE CALCULATION
// ============================================================================

/proc/GetEquipmentDamage(mob/attacker)
	/**
	 * GetEquipmentDamage(mob/attacker)
	 * Calculate total damage from equipped weapons
	 * Returns: Total damage value
	 */
	
	if(!attacker)
		return 0
	
	var/total_damage = 0
	// For now: framework ready
	// TODO: Query equipped weapons from character equipment system
	
	return total_damage

/proc/GetEquipmentArmor(mob/defender)
	/**
	 * GetEquipmentArmor(mob/defender)
	 * Calculate total armor from equipped armor
	 * Returns: Total AC value
	 */
	
	if(!defender)
		return 0
	
	var/total_armor = 0
	// For now: framework ready
	// TODO: Query equipped armor from character equipment system
	
	return total_armor

// ============================================================================
// EQUIPMENT TRADING & ENCHANTING FRAMEWORK
// ============================================================================

/proc/GetEquipmentValue(obj/items/equipment/item)
	/**
	 * GetEquipmentValue(obj/items/equipment/item)
	 * Calculate equipment resale value
	 * Returns: Lucre value
	 */
	
	if(!item || !item.stats)
		return 0
	
	// Base value = material base_price * damage/armor stat ratio
	var/datum/material_config/material = GetMaterial(item.stats.continent_name, item.stats.material_name)
	if(!material)
		return 0
	
	// Equipment worth 50% of material price initially
	// Increases with quality
	// Decreases with wear
	var/durability_percent = (item.current_durability / item.stats.durability_max) * 100
	var/quality_multiplier = item.stats.quality_percent / 100.0
	var/condition_multiplier = durability_percent / 100.0
	
	var/value = material.base_price * 0.5 * quality_multiplier * condition_multiplier
	
	return ceil(value)

/proc/EnchantEquipment(obj/items/equipment/item, enchantment_name)
	/**
	 * EnchantEquipment(obj/items/equipment/item, enchantment_name)
	 * Apply enchantment to equipment (framework for Phase 17)
	 * Returns: TRUE if successful
	 */
	
	if(!item)
		return FALSE
	
	// Framework: Would add special properties
	// - Fire damage, lightning, frost, poison
	// - Stat bonuses: +damage, +armor, +speed
	// - Passive effects: life steal, dodge, block
	
	return FALSE  // Not yet implemented

// ============================================================================
// WEAPON/ARMOR SCALING INITIALIZATION
// ============================================================================

/proc/InitializeWeaponArmorScaling()
	/**
	 * InitializeWeaponArmorScaling()
	 * Called from InitializationManager.dm at T+398
	 * Sets up equipment scaling system
	 */
	
	world.log << "SCALING: Weapon/armor scaling system initialized"
	
	// Would register equipment crafting recipes:
	// - Basic Swords (Copper, Tin, Iron)
	// - Advanced Swords (Bronze, Steel)
	// - Armor sets per material
	// - Shields, accessories
	
	return TRUE

/proc/RegisterEquipmentRecipe(material_name, equipment_type)
	/**
	 * RegisterEquipmentRecipe(material_name, equipment_type)
	 * Register that a material can be crafted into equipment
	 */
	
	if(!material_name || !equipment_type)
		return FALSE
	
	// Framework: Would register in global equipment recipe registry
	// Indexed by material and equipment type
	
	world.log << "SCALING: Registered [material_name] [equipment_type] recipe"
	
	return TRUE

// ============================================================================
// COMBAT INTEGRATION
// ============================================================================

/proc/ApplyEquipmentDamage(mob/attacker, mob/defender, base_damage)
	/**
	 * ApplyEquipmentDamage(mob/attacker, mob/defender, base_damage)
	 * Apply combat damage with equipment scaling
	 * Returns: Actual damage dealt
	 */
	
	if(!attacker || !defender)
		return 0
	
	// Get attacker's equipped weapon damage
	var/weapon_damage = GetEquipmentDamage(attacker)
	var/armor_defense = GetEquipmentArmor(defender)
	var/total_damage = base_damage + weapon_damage
	total_damage = total_damage * (100 - armor_defense) / 100.0
	
	// Apply to defender (framework - actual integration deferred)
	// Would modify defender HP based on type
	// For now: just return calculated damage
	return total_damage

// ============================================================================
// BACKGROUND PROCESSING
// ============================================================================

/proc/EquipmentDegradationProcessor()
	/**
	 * EquipmentDegradationProcessor()
	 * Background loop: Process equipment degradation, durability alerts
	 */
	set background = 1
	set waitfor = 0
	
	var/process_interval = 100
	var/last_process = world.time
	
	while(1)
		sleep(50)
		
		if(world.time - last_process >= process_interval)
			last_process = world.time
			// Check durability thresholds
			// Send warnings to players whose gear is degraded
			// Would calculate repair costs