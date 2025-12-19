/**
 * VITAL STATE DATUM
 * 
 * Manages serialization/deserialization of player vital statistics.
 * Tracks HP, stamina, and other persistent health-related variables.
 * 
 * This ensures players log back in with their current health state,
 * allowing for proper recovery mechanics and difficulty balance.
 */

/datum/vital_state
	var
		// Core vitals
		current_hp = 210
		max_hp = 210
		current_stamina = 500
		max_stamina = 500
		
		// Status flags
		hungry = 0
		thirsty = 0
		fed = 0
		hydrated = 0
		
		// Temporary buffs/debuffs (combat related)
		temp_defense = 0
		temp_evasion = 0
		temp_damage_min = 0
		temp_damage_max = 0

	proc/CaptureVitals(mob/players/player)
		/**
		 * CaptureVitals(player)
		 * Records the current vital state from the player.
		 */
		if(!player) return
		
		current_hp = player.HP
		max_hp = player.MAXHP
		current_stamina = player.stamina
		max_stamina = player.MAXstamina
		
		hungry = player.hungry
		thirsty = player.thirsty
		fed = player.fed
		hydrated = player.hydrated
		
		temp_defense = player.tempdefense
		temp_evasion = player.tempevade
		temp_damage_min = player.tempdamagemin
		temp_damage_max = player.tempdamagemax

	proc/RestoreVitals(mob/players/player)
		/**
		 * RestoreVitals(player)
		 * Restores the vital state to the player on login.
		 * 
		 * Design decision: Restore exact state without healing.
		 * This maintains difficulty balance and prevents resting-by-logout exploits.
		 * Future: Could add optional "recovery on rest" mode (e.g., full heal in safe zones).
		 */
		if(!player) return
		
		player.HP = current_hp
		player.MAXHP = max_hp
		player.stamina = current_stamina
		player.MAXstamina = max_stamina
		
		player.hungry = hungry
		player.thirsty = thirsty
		player.fed = fed
		player.hydrated = hydrated
		
		player.tempdefense = temp_defense
		player.tempevade = temp_evasion
		player.tempdamagemin = temp_damage_min
		player.tempdamagemax = temp_damage_max

	proc/ValidateVitals()
		/**
		 * ValidateVitals()
		 * Checks if vital values are in reasonable ranges.
		 * Returns 1 if valid, 0 if corruption detected.
		 * 
		 * Thresholds:
		 * - HP: 0 to 1000 (max reasonable with buffs)
		 * - Stamina: 0 to 1500 (max reasonable with buffs)
		 * - Buffs: -500 to +500 (reasonable combat modifier range)
		 */
		if(current_hp < 0 || current_hp > 1000) return 0
		if(current_stamina < 0 || current_stamina > 1500) return 0
		if(max_hp < 0 || max_hp > 1000) return 0
		if(max_stamina < 0 || max_stamina > 1500) return 0
		
		if(temp_defense < -500 || temp_defense > 500) return 0
		if(temp_evasion < -500 || temp_evasion > 500) return 0
		if(temp_damage_min < -500 || temp_damage_min > 500) return 0
		if(temp_damage_max < -500 || temp_damage_max > 500) return 0
		
		return 1
