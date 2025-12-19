/*
MiniMap Library v.1.5
Ebonshadow
//////////////////////////////////////////////////
Use this library to make mini-maps on the screen.  I made
this for my own purposes with my RTS game engine for BYOND.
A few things you should know about this library:
	The minimap caches output to make further loading
	faster.  However, the first load will be pretty slow.

	The minimap will be little affected by the size of the map, but
	more by the size of minimap (loading time).

client/minimap_Place()

Format:
	minimap_Place(sx1,sy1,sx2,sy2,turf/loc0,turf/loc1)

Returns:
	A list of Map objects that may update the minimap
	with MapObj.Scan()
Args:
	sx1,sy1,sx2,sy2:  These are the locations to draw the map on the
	screen.  1,1 to 2,2 would draw a 2x2 map in the lower left
	hand corner of the screen.

	loc0: Lower left hand corner of the map
	loc1: Lower left hand corner of the map

If loc0 is 1,1,1 and loc1 is world.maxx,world.maxy,1, the mini-map
will scan the entire map for z = 1.  Use this command to create a
map and then store the output in a variable(list of map objects).
You may then update the map objects or delete them from the screen
later.  At first, the map will update really slow, but since
it caches the pixels on the map, it will be a lot faster the
next time around.  For all atoms you want to show up on the
map, assign them a map color value. EX.
turf/grass/MapColor = rgb(0,155,0)

Example:
	client/New()
		. = ..()
		var/list/maps = minimap_Place(10,10,11,11,locate(1,1,1),locate(world.maxx,world.maxy,1))
		for(var/MapObj/o in maps)
			o.Scan()

Refer to Demo.dm for a better example
*/

client
	proc/minimap_Place(lx1,ly1,lx2,ly2,turf/loc0,turf/loc1)
		var/maps = list()
		var/lx = loc0.x
		var/ly = loc0.y
		var/lz = loc0.z
		var/hx = loc1.x
		var/hy = loc1.y
		var/distx = abs(lx1-lx2)+1
		var/disty = abs(ly1-ly2)+1
		var/xcount = 0
		var/ycount = 0
		for(var/x1 = lx1 to lx2)
			xcount ++
			ycount = 0
			for(var/y1 = ly1 to ly2)
				ycount ++
				var/xperc = xcount/distx
				var/yperc = ycount/disty
				var/newpx = hx * xperc
				var/newpy = hy * yperc
				var/fx = xcount - 1
				var/fy = ycount - 1
				var/lastpx
				var/lastpy
				if(fx == 0) lastpx = lx
				else lastpx = hx * (fx/distx)+1
				if(fy == 0) lastpy = ly
				else lastpy = hy * (fy/disty)+1
				var/MapObj/m = new()
				m.screen_loc = "[x1],[y1]"
				screen += m
				maps += m
				m.t1 = locate(lastpx,lastpy,lz)
				m.t2 = locate(newpx,newpy,lz)
		return maps
atom/var/MapColor
PixelData
	var/list/cached_icon[200][32][32]
	var/list/hex_num_list[0]
	proc/GetHex(nu)
		for(var/i in hex_num_list)
			if(hex_num_list[i] == nu) return i
	proc/GetNum(he)
		return hex_num_list[he]
	proc/AssignNumHex(MC)
		var/total = hex_num_list.len
		total++
		hex_num_list[MC] = total
		return total
	proc/GetPixel(x1,y1,MC)
		var/icon/pixel
		var/col = GetNum(MC)
		if(col)
			if(cached_icon[col][x1][y1])
				pixel = cached_icon[col][x1][y1]
		else
			col = AssignNumHex(MC)
		if(!pixel)
			pixel = new('Pixel.dmi')
			pixel.Shift(NORTH,(y1-1)*4)
			pixel.Shift(EAST,(x1-1)*4)
			pixel.SwapColor(rgb(0,0,0),MC)
			cached_icon[col][x1][y1] = pixel
		return pixel
var/PixelData/pixel_data = new()
MapObj
	parent_type= /obj
	icon = 'Back.dmi'
	var/turf/t1
	var/turf/t2
	var/mapgroup = list()
	proc/Scangroup()
		for(var/MapObj/o in mapgroup)
			o.Scan()
	proc/Point(x1,y1,MC)
		var/icon/pixel = pixel_data.GetPixel(x1,y1,MC)
		overlays += pixel
	proc/Clear()
		overlays.Cut()
	proc/Scan()
		var/turf/loc0 = t1
		var/turf/loc1 = t2
		Clear()
		var/sx = loc0.x
		var/sy = loc0.y
		var/sz = loc0.z
		var/ex = loc1.x
		var/ey = loc1.y
		var/stepx = abs(ex-sx)/8
		var/stepy = abs(ey-sy)/8
		for(var/px = 1 to 8)
			var/locx = sx + (stepx*px)-stepx
			for(var/py = 1 to 8)
				var/locy = sy + (stepy*py)-stepy
				var/turf/t = locate(locx,locy,sz)
				if(t)
					Point(px,py,t.MapColor)
		for(var/turf/t in block(loc0,loc1))
			for(var/atom/a in t)
				if(a.MapColor)
					var/px = round((t.x-(sx-1))/stepx)
					var/py = round((t.y-(sy-1))/stepy)
					if(px <= 0) px = 1
					if(py <= 0) py = 1
					if(px > 32) px = 32
					if(py > 32) py = 32
					Point(px,py,a.MapColor)
					break
