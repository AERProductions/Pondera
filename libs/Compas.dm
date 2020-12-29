mob/var/Target
proc
	get_angle_nums(ax,ay,bx,by)
		var/val = sqrt((bx - ax) * (bx - ax) + (by - ay) * (by - ay))
		if(!val) return 0
		var/ar = arccos((bx - ax) / val)
		var/deg = round(360 - (by - ay >= 0 ? ar : -ar), 1)
		while(deg > 360) deg -= 360
		while(deg < 0) deg += 360
		return deg
obj
	Navi
		Compas
			icon = 'Compas.dmi'
			icon_state = "Compas"
			layer = 10
			screen_loc = "1,14"
		Arrow
			icon = 'Compas.dmi'
			icon_state = "Arrow"
			layer = 11 //Set it above the compas
			screen_loc = "1,14"