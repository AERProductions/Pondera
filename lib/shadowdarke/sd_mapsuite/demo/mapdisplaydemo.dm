var/sd_MapDisplayLine = ""

world
	New()
		..()
		for(var/X = 1 to world.maxx)
			sd_MapDisplayLine += " "

atom
	var
		sd_MapText

turf
	sd_MapText = "·"
	arch
		sd_MapText = "^"
	door
		sd_MapText = "\\"
	wall
		sd_MapText = "#"

obj
	sd_MapText = ")"

mob
	sd_MapText = "@"
	var
		list
			sd_MapDisplay

	monster
		sd_MapText = "M"

	New()
		..()
		sd_RenewMapDisplay()

	Move()
		. = ..()
		if(. && client)
			sd_MapUpdate(view(world.view,src))
//			displaymap()
/*
	generate()
		..()
		sd_RenewMapDisplay()
*/
	proc
		sd_RenewMapDisplay()
			sd_MapDisplay = new(world.maxy)

		sd_MapUpdate(list/L)
			for(var/turf/T in L)
				var/line = sd_MapDisplay[world.maxy-T.y+1]
				if(!line) line = sd_MapDisplayLine
				var/Text = T.sd_MapText
				if(T.contents.len)
					var/atom/A = T.contents[T.contents.len]
					if(A.sd_MapText) Text = A.sd_MapText
				sd_MapDisplay[world.maxy-T.y+1] = copytext(line,1,T.x) + Text + copytext(line,T.x+1)
			//var/line = sd_MapDisplay[world.maxy-y+1]
			//sd_MapDisplay[world.maxy-y+1] = copytext(line,1,x) + "@" + copytext(line,x+1)

		sd_MapCheck(turf/T)
			. = copytext(sd_MapDisplay[world.maxy-T.y+1],T.x,T.x+1)

	verb
		displaymap()
			var/html = "<style>PRE {line-height=70%; letter-spacing:2px;} BODY {margin:0; background:#DDAA00; text-align: center;}</style><pre>"
			for(var/X in sd_MapDisplay)
				html += "[X]<br>"
			html += "<BR></pre>"
			src << browse(html,"window=map;size=650x600;border=0;")

		fullmap()
			sd_MapUpdate(block(locate(1,1,1),locate(world.maxx, world.maxy,1)))
			displaymap()
