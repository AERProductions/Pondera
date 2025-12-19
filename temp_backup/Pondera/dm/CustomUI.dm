/**
 * Custom UI System - Simple Screen-Based HUD
 */

client/var/list/ui_list = list()

client/proc/add_ui(obj/screen/O)
	if(!O) return 0
	ui_list += O
	screen += O
	return 1

client/proc/remove_ui(obj/screen/O)
	if(!O || !(O in ui_list)) return 0
	ui_list -= O
	screen -= O
	del(O)
	return 1

// ==================== HEALTH BAR ====================

obj/screen/health_bar
	var/mob/target
	var/update_id = "health"

	New(mob/t)
		..()
		target = t
		maptext = "HP: 0/0"

	proc/refresh()
		if(!target) return
		var/hp = target:HP
		var/mhp = target:MAXHP
		if(!mhp) mhp = 1
		var/pct = round((hp / mhp) * 100)
		maptext = "<font color='#FF0000'><b>HP: [hp]/[mhp] ([pct]%)</b></font>"

// ==================== STAMINA BAR ====================

obj/screen/stamina_bar
	var/mob/target
	var/update_id = "stamina"

	New(mob/t)
		..()
		target = t
		maptext = "ST: 0/0"

	proc/refresh()
		if(!target) return
		var/st = target:stamina
		var/mst = target:MAXstamina
		if(!mst) mst = 1
		var/pct = round((st / mst) * 100)
		maptext = "<font color='#FFFF00'><b>ST: [st]/[mst] ([pct]%)</b></font>"
