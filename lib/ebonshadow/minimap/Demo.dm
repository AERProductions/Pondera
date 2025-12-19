#include "Map.dmp"
world/turf = /turf/Grass
world/view = 5
client
	var/maps
	New()
		..()
		// This draws the map on the screen from 10,10-11,11 and scans the entire map.
		maps = minimap_Place(10,10,11,11,locate(1,1,1),locate(world.maxx,world.maxy,1))
mob
	icon = 'Player.dmi'
	MapColor=rgb(0,255,255)
	Login()
		. =..()
		loc = locate(1,1,1)
	Move()
		. =..()
		// When the mob moves, we have to make all the maps on his screen rescan
		if(.)
			for(var/MapObj/o in client.maps)
				o.Scan()
turf/Grass
	icon = 'Grass.dmi'
	MapColor=rgb(0,155,0)
turf/Dirt
	icon = 'Dirt.dmi'
	MapColor=rgb(102,51,0)