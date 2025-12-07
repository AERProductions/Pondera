// CurrencyDisplayUI.dm - Player Currency Display and HUD Integration
// Handles visual display of player currency, balance updates, and transaction notifications
// Integrates with HUDManager for on-screen currency widgets

// ============================================================================
// CURRENCY DISPLAY SCREEN OBJECT
// ============================================================================

obj
	screen_fx
		currency_display
			/**
			 * currency_display
			 * Screen-fixed object showing player's current stone balance
			 * Appears in top-right corner of player's screen
			 * Updates in real-time as currency changes
			 */
			layer = FLOAT_LAYER
			plane = 2  // HUD plane
			icon = null
			screen_loc = "TOP-RIGHT:30,TOP-1"
			mouse_opacity = 0
			
			var
				last_currency_value = 0
				update_timer = 0
			
			proc/UpdateDisplay()
				// Update the currency display text
				if(!usr) return
				
				var/current_balance = GetPlayerCurrency(usr)
				
				if(current_balance != last_currency_value)
					last_currency_value = current_balance
					maptext = {"<div align="center" style="color: #FFD700; font-size: 20px; font-weight: bold;">
					Stone: [current_balance]
					</div>"}
				
			proc/AnimateBalanceChange(old_val, new_val)
				// Flash animation when balance changes
				if(!usr) return
				
				var/change = new_val - old_val
				var/color_flash = (change > 0) ? "#00FF00" : "#FF6347"
				
				animate(src, color = rgb(255, 215, 0), time = 3)
				sleep(3)
				animate(src, color = rgb(255, 255, 255), time = 5)

// ============================================================================
// CURRENCY NOTIFICATION SYSTEM
// ============================================================================

/proc/NotifyCurrencyChange(mob/players/player, amount, reason = "transaction")
	/**
	 * NotifyCurrencyChange(player, amount, reason)
	 * Displays notification when player's currency changes
	 * amount > 0 for gains (green), amount < 0 for losses (red)
	 */
	if(!player) return
	
	var/color = (amount > 0) ? "#00FF00" : "#FF0000"
	var/symbol = (amount > 0) ? "+" : "-"
	var/abs_amount = abs(amount)
	
	player << "<font color=[color]>[symbol][abs_amount] stone ([reason])</font>"

/proc/NotifyMarketTransaction(mob/players/buyer, mob/players/seller, amount, item_name)
	/**
	 * NotifyMarketTransaction(buyer, seller, amount, item_name)
	 * Notifies both parties of a market transaction
	 */
	if(!buyer || !seller) return
	
	buyer << "<font color=#87CEEB>Purchased [item_name] for [amount] stone</font>"
	seller << "<font color=#FFD700>Sold [item_name] for [amount] stone</font>"

/proc/NotifyStallProfit(mob/players/owner, amount, total_profit)
	/**
	 * NotifyStallProfit(owner, amount, total_profit)
	 * Notifies stall owner of daily profit accumulation
	 */
	if(!owner) return
	
	owner << "<font color=#FFD700>Stall profit +[amount] stone (Daily total: [total_profit])</font>"

// ============================================================================
// CURRENCY HUD MANAGER INTEGRATION
// ============================================================================

/proc/AttachCurrencyDisplayToPlayer(mob/players/player)
	/**
	 * AttachCurrencyDisplayToPlayer(player)
	 * Attaches currency display screen object to player's HUD
	 * Called on player login
	 */
	if(!player) return
	
	// Check if already attached
	for(var/obj/screen_fx/currency_display/cd in player.client.screen)
		return  // Already attached
	
	var/obj/screen_fx/currency_display/display = new()
	display.UpdateDisplay()
	player.client.screen += display

/proc/UpdatePlayerCurrencyDisplay(mob/players/player)
	/**
	 * UpdatePlayerCurrencyDisplay(player)
	 * Refreshes currency display for player
	 * Called when balance changes
	 */
	if(!player || !player.client) return
	
	for(var/obj/screen_fx/currency_display/display in player.client.screen)
		display.UpdateDisplay()
		break

/proc/RemoveCurrencyDisplay(mob/players/player)
	/**
	 * RemoveCurrencyDisplay(player)
	 * Removes currency display from player's HUD
	 * Called on player logout
	 */
	if(!player || !player.client) return
	
	for(var/obj/screen_fx/currency_display/display in player.client.screen)
		del display

// ============================================================================
// BALANCE CHECK & VALIDATION PROCEDURES
// ============================================================================

/proc/GetPlayerBalanceString(mob/players/player)
	/**
	 * GetPlayerBalanceString(player)
	 * Returns formatted string of player's current balance
	 * Format: "Stone: 1,500"
	 */
	if(!player) return "Stone: 0"
	
	var/balance = GetPlayerCurrency(player)
	return "Stone: [balance]"

/proc/CanAffordPurchase(mob/players/player, amount)
	/**
	 * CanAffordPurchase(player, amount)
	 * Checks if player has sufficient currency for purchase
	 * Returns: 1 if can afford, 0 if cannot
	 */
	if(!player) return 0
	if(amount <= 0) return 1
	
	var/balance = GetPlayerCurrency(player)
	return (balance >= amount)

/proc/ValidateCurrencyTransaction(mob/players/payer, mob/players/receiver, amount, description)
	/**
	 * ValidateCurrencyTransaction(payer, receiver, amount, description)
	 * Validates a currency transfer between two players
	 * Returns: list(success, error_message)
	 */
	if(!payer || !receiver) return list(0, "Invalid players")
	if(amount <= 0) return list(0, "Invalid amount")
	
	if(!CanAffordPurchase(payer, amount))
		return list(0, "Insufficient currency")
	
	if(payer == receiver)
		return list(0, "Cannot trade with yourself")
	
	return list(1, "Valid transaction")

// ============================================================================
// CURRENCY PERSISTENCE (Save/Load)
// ============================================================================

/proc/SavePlayerCurrency(mob/players/player, savefile/F)
	/**
	 * SavePlayerCurrency(player, savefile)
	 * Saves player's currency to savefile
	 * Should be called during character save
	 */
	if(!player || !F) return
	
	F["player_currency"] = player.basecamp_stone

/proc/LoadPlayerCurrency(mob/players/player, savefile/F)
	/**
	 * LoadPlayerCurrency(player, savefile)
	 * Loads player's currency from savefile
	 * Should be called during character load
	 */
	if(!player || !F) return
	
	var/loaded_currency = F["player_currency"]
	if(loaded_currency)
		player.basecamp_stone = loaded_currency
	else
		player.basecamp_stone = 0

// ============================================================================
// CURRENCY AUDIT & LOGGING
// ============================================================================

/proc/LogCurrencyTransaction(mob/players/payer, mob/players/payee, amount, type)
	/**
	 * LogCurrencyTransaction(payer, payee, amount, type)
	 * Logs all currency transactions for audit trail
	 * type: "purchase", "trade", "stall_profit", "refund", etc.
	 */
	if(!payer || !payee) return
	
	var/timestamp = time2text(world.realtime, "YYYY-MM-DD hh:mm:ss")
	var/log_entry = "[timestamp] | [payer.key] transferred to [payee.key] | [amount] stone | [type]"
	
	world.log << "CURRENCY_AUDIT: [log_entry]"

/proc/AuditPlayerCurrency(mob/players/player)
	/**
	 * AuditPlayerCurrency(player)
	 * Returns audit information for player's currency
	 * Format: list(current_balance, last_transaction, transaction_count)
	 */
	if(!player) return list(0, "Unknown", 0)
	
	return list(
		GetPlayerCurrency(player),
		"Last transaction: Unknown",
		0
	)

// ============================================================================
// CURRENCY BONUS SYSTEMS
// ============================================================================

/proc/ApplyCurrencyBonus(mob/players/player, bonus_amount, bonus_type)
	/**
	 * ApplyCurrencyBonus(player, bonus_amount, bonus_type)
	 * Applies bonus currency to player (quests, achievements, etc.)
	 * bonus_type: "quest", "achievement", "event", "daily_login", etc.
	 */
	if(!player) return 0
	if(bonus_amount <= 0) return 1
	
	AddPlayerCurrency(player, bonus_amount)
	NotifyCurrencyChange(player, bonus_amount, bonus_type)
	LogCurrencyTransaction(player, player, bonus_amount, "bonus_[bonus_type]")
	
	return 1

/proc/ApplyDailyLoginBonus(mob/players/player)
	/**
	 * ApplyDailyLoginBonus(player)
	 * Applies daily login bonus (if not already received today)
	 * Returns: 1 if bonus applied, 0 if already received
	 */
	if(!player) return 0
	
	// Check if already received today
	var/today = time2text(world.realtime, "YYYY-MM-DD")
	if(player.vars["last_login_bonus_date"] == today)
		return 0
	
	var/bonus = 50  // Stone reward for daily login
	ApplyCurrencyBonus(player, bonus, "daily_login")
	player.vars["last_login_bonus_date"] = today
	
	return 1

// ============================================================================
// INITIALIZATION
// ============================================================================

/proc/InitializeCurrencyDisplayUI()
	world.log << "Currency Display UI initialized"

