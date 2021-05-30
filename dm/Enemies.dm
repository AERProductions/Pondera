
//proc/MonMake(M,X,Y,Z) // this function gets called to respawn a new monster
//	spawn(1242) // just wait a while
//		new M(locate(X,Y,Z)) // and then make another one at the location passed in

proc/Drop(J) // this function gets called a ton to say what dropped, so I moved it out here
	usr << "<font color = #dc143c>The enemy dropped <b>[J]!"
proc/itemdrop(var/mob/enemies/Q,X,Y,Z)
	var/dice = "1d20"
	var/R = roll(dice)
	if(Q.type==/mob/enemies/Giu)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,13) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==5)
					new/obj/items/GiuHide (m,1)//var/obj/items/GiuHide/J = new (m,1)//(locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>Giu Hide!"
				else if(R!=5)
					new/obj/items/Food/GiuMeat (m,1)//var/obj/items/Food/GiuMeat/J = new (m,1)//(locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>Giu Meat!"
				if(R==9)
					new/obj/items/GiuShell (m,1)//var/obj/items/GiuShell/J = new (m,1)//(locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>Giu Shell!"
	if(Q.type==/mob/enemies/Gou)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,14) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==5)
					var/obj/items/GouHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=5)
					var/obj/items/Food/GouMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==13)
					var/obj/items/GouShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Gow)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,15) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==5)
					var/obj/items/GowHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=5)
					var/obj/items/Food/GowMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==13)
					var/obj/items/GowShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Guwi)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,20) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==5)
					var/obj/items/GuwiHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=5)
					var/obj/items/Food/GuwiMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==13)
					var/obj/items/GuwiShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Gowu)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,25) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==4)
					var/obj/items/GowuHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=4)
					var/obj/items/Food/GowuMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==19)
					var/obj/items/GowuShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Giuwo)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,25) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==4)
					var/obj/items/GiuwoHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=4)
					var/obj/items/Food/GiuwoMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==19)
					var/obj/items/GiuwoShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Gouwo)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,25) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==4)
					var/obj/items/GouwoHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=4)
					var/obj/items/Food/GouwoMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==19)
					var/obj/items/GouwoShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Gowwi)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,25) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==4)
					var/obj/items/GowwiHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=4)
					var/obj/items/Food/GowwiMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==19)
					var/obj/items/GowwiShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Guwwi)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,25) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==4)
					var/obj/items/GuwwiHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=4)
					var/obj/items/Food/GuwwiMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==19)
					var/obj/items/GuwwiShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
	if(Q.type==/mob/enemies/Gowwu)
		for(var/mob/players/m as mob in view(20)) // for each thing nearby
			if(istype(m,/mob/players)) // if its a player
				//var/random/R = rand(1,25) //1 in 5 chance to smith
			//	if(R==2)
			//		var/obj/items/Food/GiuMeat/J = new (locate(X,Y,Z)) // drop a questitem
				//	m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==4)
					var/obj/items/GowwuHide/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				else if(R!=4)
					var/obj/items/Food/GowwuMeat/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"
				if(R==19)
					var/obj/items/GowwuShell/J = new (locate(X,Y,Z)) // drop a questitem
					m << "<font color = #dc143c>The enemy dropped <b>[J]!"

	//these are based on the enemy's level
	if (Q.level>1 && Q.level<9) // if the enemy is between level 1 and 9, chance to get a potion
		var/diceB = "1d12"
		var B = roll(diceB) // roll
		switch(B)
			if (12) // 1% chance
				var/obj/items/Tonics/vitaevial/J = new (locate(X,Y,Z)); Drop(J)
			if (6) // 1% chance
				var/obj/items/Tonics/energytonic/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>10 && Q.level<16) // levels 2-4 for a chance to get a book
		var/diceB = "2d20"
		var B = roll(diceB) // roll 1d600, 0.1667% chance to get each of these
		switch(B)
			if (10)
				var/obj/items/ancscrlls/heat/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/ancscrlls/shardburst/J = new (locate(X,Y,Z)); Drop(J)
			if (30)
				var/obj/items/ancscrlls/watershock/J = new (locate(X,Y,Z)); Drop(J)
			if (40)
				var/obj/items/ancscrlls/vitae/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>9 && Q.level<24) // levels 2-4, another chance to get an item also
		var/diceC = "1d10"
		var/diceC2 = "1d20"
		var C = roll(diceC) // roll 1d100
		if(Q.Unique==1) // if its unique
			C = roll(diceC2) // roll 1d20 instead
		if (C==1) // 10% chance to get an item from a unique, 1% chance from a regular enemy
			var D = rand(1,13) // you'll get one of the 13 different types of items listed below
			var/diceE = "1d20"
			var E = roll(diceE) // and you have a 1/30  (3.33%) chance that it will be unique
			switch(D)
				if(1)
					if(E>1)
						var/obj/items/weapons/avganlace/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuanlace/J = new (locate(X,Y,Z)); Drop(J)
				if(2)
					if(E>1)
						var/obj/items/weapons/avgkukri/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unukukri/J = new (locate(X,Y,Z)); Drop(J)
				if(3)
					if(E>1)
						var/obj/items/weapons/avgmarubo/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unumarubo/J = new (locate(X,Y,Z)); Drop(J)
				if(4)
					if(E>1)
						var/obj/items/weapons/avgtanto/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unutanto/J = new (locate(X,Y,Z)); Drop(J)
				if(5)
					if(E>1)
						var/obj/items/weapons/avgbrand/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unubrand/J = new (locate(X,Y,Z)); Drop(J)
				if(6)
					if(E>1)
						var/obj/items/weapons/avgmarubo/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unumarubo/J = new (locate(X,Y,Z)); Drop(J)
				if(7)
					if(E>1)
						var/obj/items/weapons/avgestoc/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuestoc/J = new (locate(X,Y,Z)); Drop(J)
				if(8)
					if(E>1)
						var/obj/items/weapons/avgbrand/J = new (locate(X,Y,Z)); Drop(J)
				if(9)
					if(E>1)
						var/obj/items/armors/avgvestments/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/unuvestments/J = new (locate(X,Y,Z)); Drop(J)
				if(10)
					if(E>1)
						var/obj/items/armors/avgtunic/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/unutunic/J = new (locate(X,Y,Z)); Drop(J)
				if(11)
					if(E>1)
						var/obj/items/armors/avgcorslet/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/unucorslet/J = new (locate(X,Y,Z)); Drop(J)
				if(12)
					if(E>1)
						var/obj/items/shields/avgbast/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/unubast/J = new (locate(X,Y,Z)); Drop(J)
				if(13)
					if(E>1)
						var/obj/items/shields/uncobast/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/choibast/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>24&&Q.level<33)
		var/diceB = "1d20"
		var B = roll(diceB) // 1% chance, 2% chance to get a potion in general
		switch(B)
			if (1)
				var/obj/items/Tonics/largevitaevial/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/Tonics/strongenergytonic/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>33&&Q.level<42) // levels 5-7 chance to drop books
		var/diceB = "2d20+10"
		var B = roll(diceB) // 0.1667% chance for each, 0.6667% to just get a book in general here
		switch(B)
			if (10)
				var/obj/items/ancscrlls/flame/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/ancscrlls/icestorm/J = new (locate(X,Y,Z)); Drop(J)
			if (30)
				var/obj/items/ancscrlls/cascadelightning/J = new (locate(X,Y,Z)); Drop(J)
			if (40)
				var/obj/items/ancscrlls/telekinesis/J = new (locate(X,Y,Z)); Drop(J)
			if (50)
				var/obj/items/ancscrlls/abjure/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>42 && Q.level<48) // levels 4-8 for items
		var/diceC = "1d20"
		var/diceC2 = "1d20+10"
		var C = roll(diceC)
		if(Q.Unique==1)
			C = roll(diceC2)
		if (C==10)
			var D = rand(1,11)
			var/diceE = "1d20"
			var E = roll(diceE)
			switch(D)
				if(1)
					if(E>1)
						var/obj/items/weapons/avgyawara/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuyawara/J = new (locate(X,Y,Z)); Drop(J)
				if(2)
					if(E>1)
						var/obj/items/weapons/avgeiku/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unueiku/J = new (locate(X,Y,Z)); Drop(J)
				if(3)
					if(E>1)
						var/obj/items/weapons/avgkakubo/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unukakubo/J = new (locate(X,Y,Z)); Drop(J)
				if(4)
					if(E>1)
						var/obj/items/weapons/avgferule/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuferule/J = new (locate(X,Y,Z)); Drop(J)
				if(5)
					if(E>1)
						var/obj/items/weapons/avgtinberochin/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unutinberochin/J = new (locate(X,Y,Z)); Drop(J)
				if(6)
					if(E>1)
						var/obj/items/weapons/avgkatar/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unukatar/J = new (locate(X,Y,Z)); Drop(J)
				if(7)
					if(E>1)
						var/obj/items/armors/unucorslet/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/uncocorslet/J = new (locate(X,Y,Z)); Drop(J)
				if(8)
					if(E>1)
						var/obj/items/armors/unucuirass/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/uncocuirass/J = new (locate(X,Y,Z)); Drop(J)
				if(9)
					if(E>1)
						var/obj/items/shields/uncovanfos/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/choivanfos/J = new (locate(X,Y,Z)); Drop(J)
				if(10)
					if(E>1)
						var/obj/items/shields/unuvanfos/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/choiaegis/J = new (locate(X,Y,Z)); Drop(J)
				if(11)
					if(E>1)
						var/obj/items/shields/uncoaegis/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/ordiaegis/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>48&&Q.level<72) // levels 5-8 for potions
		var/diceB = "1d20+10"
		var B = roll(diceB)
		switch(B)
			if (1)
				var/obj/items/Tonics/vitaeliniments/J = new (locate(X,Y,Z)); Drop(J)
			if (30)
				var/obj/items/Tonics/energyspirits/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>55&&Q.level<62) // levels 8-10 for books
		var/diceB = "3d20"
		var B = roll(diceB)
		switch(B)
			if (10)
				var/obj/items/ancscrlls/cosmos/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/ancscrlls/rephase/J = new (locate(X,Y,Z)); Drop(J)
			if (30)
				var/obj/items/ancscrlls/acid/J = new (locate(X,Y,Z)); Drop(J)
			if (40)
				var/obj/items/ancscrlls/bludgeon/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>62 && Q.level<79) // 9-11 for items
		var/diceC = "1d20+10"
		var/diceC2 = "2d20"
		var C = roll(diceC)
		if(Q.Unique==1)
			C = roll(diceC2)
		if (C==10)
			var D = rand(1,11)
			var/diceE = "1d20"
			var E = roll(diceE)
			switch(D)
				if(1)
					if(E>1)
						var/obj/items/weapons/avgvoulge/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuvoulge/J = new (locate(X,Y,Z)); Drop(J)
				if(2)
					if(E>1)
						var/obj/items/weapons/avgrakkakubo/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unurakkakubo/J = new (locate(X,Y,Z)); Drop(J)
				if(3)
					if(E>1)
						var/obj/items/weapons/avgkama/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unukama/J = new (locate(X,Y,Z)); Drop(J)
				if(4)
					if(E>1)
						var/obj/items/weapons/avgwakizashi/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuwakizashi/J = new (locate(X,Y,Z)); Drop(J)
				if(5)
					if(E>1)
						var/obj/items/weapons/avgnagamaki/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/ununagamaki/J = new (locate(X,Y,Z)); Drop(J)
				if(6)
					if(E>1)
						var/obj/items/weapons/avgtachi/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unutachi/J = new (locate(X,Y,Z)); Drop(J)
				if(7)
					if(E>1)
						var/obj/items/armors/avgcuirass/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/uncocuirass/J = new (locate(X,Y,Z)); Drop(J)
				if(8)
					if(E>1)
						var/obj/items/armors/unubattlegear/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/armors/uncobattlegear/J = new (locate(X,Y,Z)); Drop(J)
				if(9)
					if(E>1)
						var/obj/items/shields/sinaegis/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/unuravelin/J = new (locate(X,Y,Z)); Drop(J)
				if(10)
					if(E>1)
						var/obj/items/shields/uncoravelin/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/shields/ordiravelin/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>79&&Q.level<88) // levels 9-12 for potions
		var/diceB = "2d20"
		var B = roll(diceB)
		switch(B)
			if (1)
				var/obj/items/Tonics/qualityvitaeliniments/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/Tonics/antitoxin/J = new (locate(X,Y,Z)); Drop(J)
			if (40)
				var/obj/items/Tonics/strongenergyspirits/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>76&&Q.level<84) // 11-13 for books
		var/diceB = "2d20"
		var B = roll(diceB)
		switch(B)
			if (10)
				var/obj/items/ancscrlls/quietus/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/ancscrlls/panacea/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>87&&Q.level<95) // 11-14 for potions
		var/diceB = "2d20+10"
		var B = roll(diceB)
		switch(B)
			if (10)
				var/obj/items/Tonics/vitaecurative/J = new (locate(X,Y,Z)); Drop(J)
			if (20)
				var/obj/items/Tonics/energyrestorative/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>88 && Q.level<96) // 12-14 for items
		var/diceC = "2d20"
		var/diceC2 = "2d20+10"
		var C = roll(diceC)
		if(Q.Unique==1)
			C = roll(diceC2)
		if (C==10)
			var D = rand(1,11)
			var/diceE = "1d20"
			var E = roll(diceE)
			switch(D)
				if(1)
					if(E>1)
						var/obj/items/weapons/avguchigatana/J = new (locate(X,Y,Z)); Drop(J)
					else
						var/obj/items/weapons/unuuchigatana/J = new (locate(X,Y,Z)); Drop(J)
				if(2)
					if(E>1)
						var/obj/items/weapons/avgnaginata/J = new (locate(X,Y,Z)); Drop(J)
				if(3)
					if(E>1)
						var/obj/items/weapons/ununaginata/J = new (locate(X,Y,Z)); Drop(J)
				if(4)
					if(E>1)
						var/obj/items/weapons/avghakkakubo/J = new (locate(X,Y,Z)); Drop(J)
				if(5)
					if(E>1)
						var/obj/items/weapons/unuhakkakubo/J = new (locate(X,Y,Z)); Drop(J)
				if(6)
					if(E>1)
						var/obj/items/armors/choibattlegear/J = new (locate(X,Y,Z)); Drop(J)
				if(7)
					if(E>1)
						var/obj/items/armors/ordibattlegear/J = new (locate(X,Y,Z)); Drop(J)
				if(8)
					if(E>1)
						var/obj/items/shields/avgthureos/J = new (locate(X,Y,Z)); Drop(J)
				if(9)
					if(E>1)
						var/obj/items/shields/unuthureos/J = new (locate(X,Y,Z)); Drop(J)
	if (Q.level>95&&Q.level<109) // 11-14 for potions
		var/diceB = "4d20"
		var B = roll(diceB)
		switch(B)
			if (20)
				var/obj/items/Tonics/qualityvitaecurative/J = new (locate(X,Y,Z)); Drop(J)
			if (40)
				var/obj/items/Tonics/strongenergyrestorative/J = new (locate(X,Y,Z)); Drop(J)


mob/enemies
	Click() //needs to have every weapon and tool overlay defined.
		//var/mob/players/P // define the player
		var/mob/enemies/M = src // define the enemy
		if (!(src in range(1, usr)))
			usr << "Need to be within range to attack!"
			return // make sure that the person clicking is right by the emem
		//if(istype(M,/mob/enemies)&&P.waiter > 0) //When the mob Clicks the enemies
		if(LSequipped==1)//This system needs refined and expanded for all weapons.
			if(istype(M,/mob/enemies))
				if(LSequipped==1) overlays -= image('dmi/64/LSoy.dmi',icon_state="[get_dir(usr,src)]")
				sleep(1)
				if(LSequipped==1) overlays += image('dmi/64/LSoy.dmi',icon_state="[get_dir(usr,src)]")
				M.AttackE()
				sleep(5)
				if(LSequipped==1) overlays -= image('dmi/64/LSoy.dmi',icon_state="[get_dir(usr,src)]")
				return
			//if(P.LSequipped==1)
		//if(LSequipped==0)
		sleep(10)
		M.AttackE()
		return
	Del()
		world << "[src] has Perished..."

		//del src
		..()
mob
	enemies//needs fixed -- enemies aren't being deleted and procs are still able to be used (like spellcasting) because of it
		var/speed = 10
		var/awake = FALSE
		var/mob/players/P
		var/mob/enemies/M
		icon = 'dmi/64/ene.dmi'
		/*proc
			wake()

				// If we aren't already awake
				if(!awake)
					awake = TRUE
					move_randomly()


			move_randomly()

				// Run in the background
				spawn()

					// While wakeful
					while(awake)
						// Move randomly
						Unique()

				// Run in the background
				spawn()
					while(awake)
						sleep(IDLE_REPEAT_DELAY)
						idle()

			idle()

				// If there's no players around we can go idle
				var/players = locate(/mob/players) in oview(MAX_WAKE_DISTANCE)
				if(!players)
					awake = FALSE*/
		proc
			AttackE() // hit that enemy
				set waitfor = 0
				//var/mob/enemies/M
				M = src
				//var/mob/players/J
				P = usr
				P.waiter=0 // you can't attack again yet
				var/damage = round(((rand(P.tempdamagemin,P.tempdamagemax))*((P.Strength/100)+1)),1) // calculate the damage
				if(P.energy>P.MAXenergy)
					P.energy=P.MAXenergy
				if(P.energy<0)
					P.energy=0
				if(P.energy==0)			//Calling this again... Some screwy stuff could happen.
					P.waiter=0
					P<<"Your energy is too low."
				if(P.energy<=0)
					P.waiter=1
				if(P.waiter==0)

				//waiter=1
				/*if(J.char_class=="Builder")
					J.overlays += image('dmi/64/WHoy.dmi',icon_state="[get_dir(J,M)]")
				if(J.char_class=="Builder")
					J.overlays += image('dmi/64/LSoy.dmi',icon_state="[get_dir(J,M)]")
				if(J.char_class=="GM")
					J.overlays += image('dmi/64/GMoy.dmi',icon_state="[get_dir(J,M)]")
				if(J.char_class=="Builder")
					J.overlays += image('dmi/64/WRoy.dmi',icon_state="[get_dir(J,M)]")
				if(J.char_class=="Builder")
					J.overlays += image('dmi/64/HNoy.dmi',icon_state="[get_dir(J,M)]")*/
				//J.overlays += image('dmi/64/32/LSoy.dmi',icon_state="[get_dir(J,M)]")
					s_damage(M, damage, "#32cd32") // show the damage on the enemy
					M.HP -= damage // deal the actual damage to their variable
					//J.updateHP()
					P.energy -= damage
					P.updateEN()
					M.DeadEnemy(src) // checking to see if the enemy is dead, and doing things about it
					oview(P,3) << "[M] has perished..."//J.overlays -= image('dmi/64/LSoy.dmi',icon_state="[get_dir(J,src)]")//J.overlays -= overlays
					sleep(P.attackspeed) // wait a time period based on your attack speed
					P:waiter=1 // you can fight again
					return
					//..()
		proc
			DeadEnemy()//fixed? testing

				var/mob/players/M = usr
				//locate(E in range(usr,10))
				//M.exp += E.expgive//
				var/mob/enemies/E = locate(range(usr,10))
				var/obj/items/weapons/sumuramasa/S = locate() in M
				for(E in range(usr,10))
					if(E.HP > 0) // if the enemy is dead

						//var/mob/players/J = usr // get a reference to the player
						//J.exp += M.expgive // give you the experience
						//M.lucre += E.lucregive // and the lucre
						//M.checklevel() // see if you leveled
							//updateXP(usr)
						//itemdrop(E,E.x,E.y,E.z) // check to see what the enemy dropped, if anything
						//usr << blood
						//sleep(1)
							//var
							//	X;Y;Z;
							//X=M.x; Y=M.y; Z=M.z;
							//MonMake(M.type,X,Y,Z) // respawns the monster in this location at a later point in time
						//del(E) // you are a dead monster now, get lost.
						//return
					else
						if(M.inparty==1&&E.HP <= 0) // if the player is in a party, we're going to split the exp up
							//this list stuff finds the people in the party who are nearby to share with
							var/list/V[2]
							var/C = 2
							V[1] = M
							var/plevelsum = level
							for(var/mob/players/U as mob in oview(20)) // they have to be within 20 squares
								if(istype(U,/mob/players)) // and be a player
									if(U.partynumber==M.partynumber) // and be in your party
										plevelsum+=U.level
										V[C] = U
										C++
										V.len++
										E.expgive*=1.1 // for each added player. increase the total exp given by 10%
										E.lucregive*=1.1 // and increase the total lucre given by 10% as well
										//return
							var/Q
							//now we go through all those players, distributing the experience and lucre accordingly
							for(Q=1, Q<V.len, Q++) // give everyone their fair share of the loot
								var/mob/players/L = V[Q]
								var/Lperc = (L.level/plevelsum)
								var/blood
								blood = image('blood.dmi',E.loc)
								L.pvekills += 1
								if(S)
									S:volume += 5
								L.exp += round((E.expgive * Lperc),1)
								L.lucre += round((E.lucregive *Lperc),1)
								//this line was used by me when checking how much was being distributed in what way, now its gone because it works correctly
								oview(20,usr) << "[L] is getting [round((E.expgive * Lperc),1)]exp and [round((E.lucregive *Lperc),1)]lucre"
								//L.checklevel() // see if they've leveled up yet
								//return
								//updateXP(L)
							//itemdrop(E,E.x,E.y,E.z) // this is the function with the %s to drop certain items from killing monsters
								usr << blood
							//this stuff makes the monster respawn later in this spot where it died
							//var
								//X;Y;Z;
							//X=M.x; Y=M.y; Z=M.z; // the spot where it died, why aren't these an array?!
							//MonMake(M.type,X,Y,Z) // call the respawning function
							//M.checklevel() // see if they've leveled up yet
								L.updateXP(L)
								L.exp += E.expgive // give you the experience
								L.lucre += E.lucregive // and the lucre
								L.checklevel() // see if you leveled
								M.updateXP()
								//usr << blood
								itemdrop(E,E.x,E.y,E.z)
								del src // get rid of that dead one
								del E
							//return
						//else // you aren't in a party
						else
							if(M.inparty == 0&&E.HP <= 0)
								var/blood
								blood = image('blood.dmi',E.loc)
								M.exp += E.expgive // give you the experience
								M.lucre += E.lucregive // and the lucre
								M.checklevel() // see if you leveled
								M.updateXP()
								usr << blood
								M.pvpkills += 1
								if(S)
									S:volume += 10

								itemdrop(E,E.x,E.y,E.z) // check to see what the enemy dropped, if anything
								//var
								//	X;Y;Z;
								//X=M.x; Y=M.y; Z=M.z;
								//MonMake(M.type,X,Y,Z) // respawns the monster in this location at a later point in time
								//del E // you are a dead monster now, get lost.
							//return
								del E
								del src
							//return


		proc
			Unique() //this is the main enemy logic
				set waitfor = 0
				//var/obj/items/Food/OCM/OCM
				while(src) // while its alive
					if (P in oview(8)) // if theres something in sight
						if(hasspells==0) // if this enemy doesn't cast spells
							step_towards(src,P) // step towards the player
							if(Unique==1) // if its a unique
								step_towards(src,P) // step twice
								step_towards(src,P) // this causes uniques to attack twice and move faster
						else // magi caster

							var/V = rand(1,6) // 1 in 6 chance to do something

							//if the enemy has all 6 of these spells, it wont attack regularly until it is out of energy
							//if the enemy has 2 of these spells, it has a 1/6 chance to cast either of them and a 4/6 chance to attack
							switch(V)
								if(1)
									if(heatlevel>0) 		HEAT()
									else 					step_towards(src,P)
								if(2)
									if(shardburstlevel>0) 	SHARDBURST()
									else 					step_towards(src,P)
								if(3)
									if(watershocklevel>0) 	WATERSHOCK()
									else 					step_towards(src,P)
								if(4)
									if(rephaselevel>0) 		REPHASE()
									else 					step_towards(src,P)
								if(5)
									if(acidlevel>0)			ACID()
									else 					step_towards(src,P)
								if(6)
									if(bludgeonlevel>0) 	BLUDGEON()
									else 					step_towards(src,P)
					else
						if(!P in oview(8))
							sleep(speed) // pause based on speed
						//step_rand(src) // then step randomly | disable random movement to spare CPU usage? Only move when player is in range
						for(P in view(src)) // if something comes nearby
							break // break out to start taking fighting actions
					/*if(OCM in oview(6)) // if theres something in sight // if this enemy doesn't cast spells
						step_towards(src,OCM)
						if(OCM in view(src))
							del OCM*/
					sleep(speed) // pause based on speed
				spawn(speed) // infinite loop based on speed before next calling
					Unique(speed)
		/*proc
			Attack(mob/players/M)
				var/mob/enemies/Giu/A
				if(istype(A,/mob/enemies/Giu))
					flick("Giu_attack",src)
					//if(istype(M,/mob/players))
					if (prob(M.tempevade))
						view(src) << "[src] \red misses <font color = gold>[M]"
					else
						HitPlayer(M)
					//else return
				else return
				if(istype(src,/mob/enemies/Gou))
					flick("Gou_attack",src)
					sleep(3)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return
				if(istype(src,/mob/enemies/Gow))
					flick("Gow_attack",src)
					sleep(3)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return
				if(istype(src,/mob/enemies/Guwi))
					flick("Guwi_attack",src)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return
				if(istype(src,/mob/enemies/Gowu))
					flick("Gowu_attack",src)
					sleep(3)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return
				if(istype(src,/mob/enemies/Gowl))
					flick("Gowl_attack",src)
					sleep(3)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return
				if(istype(src,/mob/enemies/Giuwo))
					flick("Giuwo_attack",src)
					sleep(3)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return
				if(istype(src,/mob/enemies/Gouwo))
					flick("Gouwo_attack",src)
					sleep(3)
					if(istype(M,/mob/players))
						if (prob(M.tempevade))
							view(src) << "[src] \red misses <font color = gold>[M]"
						else
							src.Attack(M)
					else return
				else return*/

		proc
			HitPlayer(var/mob/players/P) // hitting the player
				var/dmgreduced // you reduce your damage based on defense
				if(P.tempdefense<=1050)
					dmgreduced = (((P.tempdefense)/10 * (1.05-(0.0005*(P.tempdefense))))/100) // calculation for dmg reduced
				else if(P.tempdefense>1050)
					var/resroll = P.tempdefense-1050
					dmgreduced = 0.55 + 0.55*(((resroll)/10 * (1.05-(0.0005*(resroll))))/100) // another calculation for dmg reduced because the first one is negative parabolic, and we dont want the dmg reduced to be decreased with high defense ratings
				var/damage = round(((rand(Strength/2,Strength))*(1-dmgreduced)),1) // calculate damage
				P.HP -= damage // take damage
				P.updateHP()
				s_damage(P, damage, "#ff4500") // show the damage taken
				checkdeadplayer(P,src) // see if the enemy killed the player
				return

			checkdeadplayer(var/mob/players/P)
				if(P.HP <= 0&&P.affinity<=-0.1) // if you have less than or equal to 0 HP, you are dead
					world << "<font color = red><b>[P] died to [src] and went to the Sheol"
					var/G = round((P.lucre/4),1)
					P << "<font color = lucre>Your pouch slipped and spilled [G] Lucre!"
					//M.unlistenSoundmob(fb)
					P.lucre-=G
					P.poisonD=0
					P.poisoned=0
					P.poisonDMG=0
					P.overlays = null
					P.needrev=1
					var/turf/rd = locate(16,9,12)
					//var/turf/fl = locate(pick(333,474),pick(678,613),pick(2,2)) //anti griefing spawn
					//var/turf/fl = locate(pick(421,413),pick(692,686),pick(2,2)) //for testing
					P.Move(rd)
					//M.loc = locate(16,2,1)//locate(rand(100,157),rand(113,46),12)
					P.location = "Sheol"
					//usr << sound('mus.ogg',1, 0, 1024)
					//if(P.location=="Sheol")
						//P.HP = P.MAXHP
					return
				else
					if(P.HP <= 0&&P.affinity>=0)
						world << "<font color = red><b>[P] died to [src] and went to the Holy Light"
						var/G = round((P.lucre/4),1)
						P << "<font color = lucre>Your pouch slipped and spilled [G] Lucre!"
						//stfu()
						//M.unlistenSoundmob(fb)
						//call(/soundmob/proc/unsetListener)(M)//oh yeah I am just remembering that when a player died the sound would play really loud and I was trying to fix it
						P.lucre-=G
						P.poisonD=0
						P.poisoned=0
						P.poisonDMG=0
						P.overlays = null
						P.needrev=1
						var/turf/hl = locate(101,159,12)
						//var/turf/fl = locate(pick(333,474),pick(678,613),pick(2,2)) //anti griefing spawn
						//var/turf/fl = locate(pick(421,413),pick(692,686),pick(2,2)) //for testing
						P.Move(hl)
						//M.loc = locate(101,159,1)//locate(rand(100,157),rand(113,46),12)
						P.location = "Holy Light"
						//if(P.location=="Holy Light")
							//M.unlistenSoundmob(fb)
							//call(/soundmob/proc/unsetListener)(M)
						//usr << sound('mus.ogg',1, 0, 1024)
							//P.HP = P.MAXHP
						return

		//this Wander thing is what I based my enemy logic on, this function doesn't get called anymore, it was replaced by Unique(speed)
	/*	proc/Wander(speed)
			while(src)     //while its still there, and not deleted..
				if (P in oview(5))    //If a PC is in 5 spaces of it...
					step_towards(src,P)   //Step towards the PC
				else
					sleep(speed)
					step_rand(src)   //step random
					for(P in view(src))  //but if a PC comes nearby...
						break     //stop walking random
				sleep(speed)
			spawn(60)   //Keep the infinit loop in action, and tell it to wait for 4 seconds
				Wander(speed)


	*/
		//these procedures get called by the main logic loop in order to cast spells if the enemy has the energy to do it, otherwise they just step towards you
		proc
			HEAT()
				set waitfor = 0
				if (energy < 1+(heatlevel*2))
					step_towards(src,P)
				else
					energy -= 1+(heatlevel*2)
					missile(/obj/spells/heat,usr,P)
					sleep(get_dist(usr,P))
					var/damage = round(((rand(2+(heatlevel*2),4+(heatlevel*3)))*((Spirit/100)+1)),1)
					if (P.fireres>0)
						damage -= round(damage*(P.fireres/100),1)
					else
						P.HP -= damage
						P.updateHP()
						s_damage(P, damage, "#ff4500")
						checkdeadplayer(P,src)
						step_towards(src,P)
			SHARDBURST()
				set waitfor = 0
				if (energy < 3+(shardburstlevel*2))
					step_towards(src,P)
				else
					energy -= 3+(shardburstlevel*2)
					missile(/obj/spells/shardburst,usr,P)
					sleep(get_dist(usr,P))
					var/damage = round(((rand(1+(shardburstlevel*3),3+(shardburstlevel*3)))*((Spirit/100)+1)),1)
					if (P.iceres>0)
						damage -= round(damage*(P.iceres/100),1)
					P.HP -= damage
					P.updateHP()
					s_damage(P, damage, "#ff4500")
					checkdeadplayer(P,src)
					step_towards(src,P)
			WATERSHOCK()
				set waitfor = 0
				if (energy < 5+(watershocklevel*2))
					usr << "Low energy."
				else
					energy -= 5+(watershocklevel*2)
					missile(/obj/spells/watershock,usr,P)
					sleep(get_dist(usr,P))
					var/damage = round(((rand(1,round((10+(watershocklevel*10.72)),1)))*((Spirit/100)+1)),1)
					if (P.windres>0)
						damage -= round(damage*(P.windres/100),1)
					P.HP -= damage
					P.updateHP()
					s_damage(P, damage, "#ff4500")
					checkdeadplayer(P,src)
					step_towards(src,P)
			REPHASE()
				set waitfor = 0
				if (energy < 15+(rephaselevel*5))
					step_towards(src,P)
				else
					energy -= 15+(rephaselevel*5)
					var/amount = round(((rand(5+(rephaselevel*3),10+(rephaselevel*5)))*((Spirit/100)+1)),1)
					if (amount > (P.energy))
						amount = (P.energy)
					if (amount < 0)
						amount = 0
					missile(/obj/spells/cosmos,usr,P)
					sleep(get_dist(usr,P))
					s_damage(P, amount, "#4b7bdc")
					P.energy -= amount
					var/damage = round((amount*(0.092*rephaselevel)),1)
					if (damage < 0)
						damage = 0
					P.overlays += /obj/spells/rephase
					spawn(5)
						P.overlays = null
						P.HP -= damage
						P.updateHP()
						s_damage(P, damage, "#ff4500")
						checkdeadplayer(P,src)
					step_away(src,P)
			ACID()
				set waitfor = 0
				if (energy < round(14*sqrt(acidlevel),1))
					step_towards(src,P)
				else
					energy -= round(14*sqrt(acidlevel),1)
					missile(/obj/spells/acid,usr,P)
					sleep(get_dist(usr,P))
					P.overlays += /obj/spells/acid
					P.poisoned = 1
					P.poisonD = round(4+(acidlevel/2),1)
					P.poisonDMG = round( rand(10*(sqrt(acidlevel*((Spirit/100)+1))),13*(sqrt(acidlevel*((Spirit/100)+1)))) , 1)
					P.updateHP()
					step_away(src,P)
			BLUDGEON()
				set waitfor = 0
				if (energy < 9+(bludgeonlevel*2))
					step_towards(src,P)
				else
					energy -= 9+(bludgeonlevel*2)
					missile(/obj/spells/bludgeon,usr,P)
					sleep(get_dist(usr,P))
					var/damage = round(((rand(10+(bludgeonlevel*2),16+(bludgeonlevel*3)))*((Strength/100)+1)),1)
					if (P.earthres>0)
						damage -= round(damage*(P.earthres/100),1)
					P.HP -= damage
					P.updateHP()
					s_damage(P, damage, "#ff4500")
					checkdeadplayer(P,src)
					step_towards(src,P)


		//these are all the different enemies and their variables and actions...

		var // enemy variables
			HP; MAXHP; energy; MAXenergy; expgive; lucregive; Strength; Spirit; level=0; Speed; Unique=0;
			fireres=0; iceres=0; watres=0; poisres=0; earthres=0; windres=0
			firewk=0; icewk=0; watwk=0; poiswk=0; earthwk=0; windwk=0
			hasspells=0; // the magi casters have different fighting logic
			heatlevel; shardburstlevel; watershocklevel; rephaselevel; acidlevel;
			bludgeonlevel; icestormlevel; cosmoslevel

		Giu
			icon_state = "Giu"
			icon = 'dmi/64/ene.dmi'
			level = 1
			Speed = 1
			HP = 30
			MAXHP = 30
			energy = 5
			MAXenergy = 5
			expgive = 12
			lucregive = 4
			Strength = 4
			Spirit = 1
			//icewk=20
			//Resistances
			fireres = 0
			iceres = 0
			windres = 1
			watres = 0
			earthres = 1
			poisres = 1
			//Weaknesses
			firewk = 1
			icewk = 20
			windwk = 0
			watwk = 1
			earthwk = 0
			poiswk = 0

			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GiuAttack(M)
			proc/GiuAttack(mob/players/M)
				flick("Giu_attack",src)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
				//Unique(speed)
			/*Bump(mob/players/M)
				if (istype(M,/mob/players))
					Attack(M)
			proc/Attack1(mob/players/M)
				flick("Giu_attack",src)
				sleep(3)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)*/
		Gou
			icon_state = "Gou"
			icon = 'dmi/64/ene.dmi'
			level = 2
			Speed = 18
			HP = 85
			MAXHP = 85
			energy = 10
			MAXenergy = 10
			expgive = 24
			lucregive = 13
			Strength = 8
			Spirit = 6
			//Resistances
			fireres = 0
			iceres = 1
			windres = 1
			watres = 0
			earthres = 1
			poisres = 1
			//Weaknesses
			firewk = 10
			icewk = 0
			windwk = 0
			watwk = 1
			earthwk = 0
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GouAttack(M)
			proc/GouAttack(mob/players/M)
				flick("Gou_attack",src)
				//sleep(2)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Gow
			icon_state = "Gow"
			icon = 'dmi/64/ene.dmi'
			level = 3
			Speed = 17
			HP = 100
			MAXHP = 100
			energy = 15
			MAXenergy = 15
			expgive = 16
			lucregive = 36
			Strength = 14
			Spirit = 3
			//watwk=35
			//Resistances
			fireres = 1
			iceres = 1
			windres = 1
			watres = 0
			earthres = 1
			poisres = 1
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 0
			watwk = 35
			earthwk = 0
			poiswk = 0
			New()
				..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GowAttack(M)
			proc/GowAttack(mob/players/M)
				flick("Gow_attack",src)
				//sleep(2)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Guwi
			icon_state = "Guwi"
			icon = 'dmi/64/ene.dmi'
			level = 4
			Speed = 15
			HP = 160
			MAXHP = 160
			energy = 35
			MAXenergy = 35
			expgive = 49
			lucregive = 42
			Strength = 16
			Spirit = 8
			//firewk=20
			//Resistances
			fireres = 0
			iceres = 1
			windres = 1
			watres = 1
			earthres = 1
			poisres = 1
			//Weaknesses
			firewk = 20
			icewk = 0
			windwk = 0
			watwk = 0
			earthwk = 0
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GuwiAttack(M)
			proc/GuwiAttack(mob/players/M)
				flick("Guwi_attack",src)
				//sleep(2)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Gowu
			icon_state = "Gowu"
			icon = 'dmi/64/ene.dmi'
			level = 5
			Speed = 13
			HP = 260
			MAXHP = 260
			energy = 43
			MAXenergy = 43
			expgive = 67
			lucregive = 54
			Strength = 22
			Spirit = 16
			Unique = 1
			hasspells = 1
			heatlevel = 4
			shardburstlevel = 2
			acidlevel = 1
			//fireres = 20
			//watres = 20
			//iceres = 20
			//poisres = 20
			//earthwk = 20
			//Resistances
			fireres = 1
			iceres = 1
			windres = 1
			watres = 1
			earthres = 0
			poisres = 1
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 0
			watwk = 0
			earthwk = 20
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GowuAttack(M)
			proc/GowuAttack(mob/players/M)
				flick("Gowu_attack",src)
				//sleep(2)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Gowl
			icon = 'dmi/64/ene.dmi'
			icon_state = "Gowl"
			level = 5
			Speed = 13
			HP = 300
			MAXHP = 300
			energy = 64
			MAXenergy = 64
			expgive = 84
			lucregive = 65
			Strength = 24
			Spirit = 9
			Unique = 0
			hasspells = 0
			//fireres = 20
			//watres = 20
			//iceres = 20
			//poisres = 20
			//earthwk = 20
			//Resistances
			fireres = 1
			iceres = 1
			windres = 0
			watres = 1
			earthres = 0
			poisres = 1
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 10
			watwk = 0
			earthwk = 20
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GowlAttack(M)
			proc/GowlAttack(mob/players/M)
				flick("Gowl_attack",src)
				//sleep(2)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Giuwo
			icon_state = "Giuwo"
			icon = 'dmi/64/ene.dmi'
			level = 6
			Speed = 9
			HP = 333
			MAXHP = 333
			energy = 75
			MAXenergy = 75
			expgive = 92
			lucregive = 72
			Strength = 27
			Spirit = 16
			Unique = 0
			hasspells = 1
			icestormlevel = 4
			//earthwk = 20
			//Resistances
			fireres = 1
			iceres = 1
			windres = 1
			watres = 1
			earthres = 0
			poisres = 1
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 0
			watwk = 0
			earthwk = 20
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GiuwoAttack(M)
			proc/GiuwoAttack(mob/players/M)
				flick("Giuwo_attack",src)
				//sleep(4)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Gouwo
			icon_state = "Gouwo"
			icon = 'dmi/64/ene.dmi'
			level = 7
			Speed = 13
			HP = 420
			MAXHP = 420
			energy = 113
			MAXenergy = 113
			expgive = 124
			lucregive = 91
			Strength = 33
			Spirit = 13
			Unique = 1
			hasspells = 1
			icestormlevel = 9
			//fireres = 10
			//watres = 40
			//iceres = 50
			//poisres = 20
			//earthwk = 20
			//Resistances
			fireres = 10
			iceres = 50
			windres = 0
			watres = 40
			earthres = 0
			poisres = 20
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 30
			watwk = 0
			earthwk = 20
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GouwoAttack(M)
			proc/GouwoAttack(mob/players/M)
				flick("Gouwo_attack",src)
				//sleep(4)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Gowwi
			icon_state = "Gowwi"
			icon = 'dmi/64/ene.dmi'
			level = 8
			Speed = 18
			HP = 554
			MAXHP = 554
			energy = 183
			MAXenergy = 183
			expgive = 184
			lucregive = 111
			Strength = 42
			Spirit = 24
			Unique = 0
			hasspells = 1
			bludgeonlevel = 13
			//fireres = 10
			//watres = 40
			//iceres = 40
			//poisres = 20
			//earthwk = 30
			//Resistances
			fireres = 10
			iceres = 40
			windres = 0
			watres = 40
			earthres = 0
			poisres = 20
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 0
			watwk = 0
			earthwk = 30
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/P)
				if (istype(P,/mob/players))
					GowwiAttack(P)
			proc/GowwiAttack(mob/players/P)
				flick("Gowwi_attack",src)
				//sleep(4)
				if (prob(P.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(P)
		Guwwi
			icon_state = "Guwwi"
			icon = 'dmi/64/ene.dmi'
			level = 7
			Speed = 13
			HP = 642
			MAXHP = 642
			energy = 213
			MAXenergy = 213
			expgive = 264
			lucregive = 171
			Strength = 55
			Spirit = 33
			Unique = 1
			hasspells = 1
			bludgeonlevel = 24
			//fireres = 10
			//watres = 40
			//iceres = 20
			//poisres = 20
			//earthwk = 40
			//Resistances
			fireres = 40
			iceres = 0
			windres = 40
			watres = 40
			earthres = 50
			poisres = 50
			//Weaknesses
			firewk = 0
			icewk = 40
			windwk = 0
			watwk = 0
			earthwk = 0
			poiswk = 0
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GuwwiAttack(M)
			proc/GuwwiAttack(mob/players/M)
				flick("Guwwi_attack",src)
				//sleep(4)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)
		Gowwu
			icon_state = "Gowwu"
			icon = 'dmi/64/ene.dmi'
			level = 7
			Speed = 13
			HP = 824
			MAXHP = 824
			energy = 333
			MAXenergy = 333
			expgive = 304
			lucregive = 213
			Strength = 64
			Spirit = 42
			Unique = 1
			hasspells = 1
			cosmoslevel = 33
			//fireres = 20
			//watres = 20
			//iceres = 20
			//poisres = 20
			//earthwk = 20
			//Resistances
			fireres = 40
			iceres = 50
			windres = 40
			watres = 40
			earthres = 50
			poisres = 0
			//Weaknesses
			firewk = 0
			icewk = 0
			windwk = 0
			watwk = 0
			earthwk = 0
			poiswk = 50
			New()
				.=..()
				spawn(1)
					Unique(Speed)
			Bump(mob/players/M)
				if (istype(M,/mob/players))
					GowwuAttack(M)
			proc/GowwuAttack(mob/players/M)
				flick("Gowwu_attack",src)
				//sleep(4)
				if (prob(M.tempevade))
					view(src) << "[src] \red misses <font color = gold>[M]"
				else
					HitPlayer(M)