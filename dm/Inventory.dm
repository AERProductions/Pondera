//Credit Lego

client
	proc
		buildBag() //called when not loading a savefile
			if(!src.mob.bag) src.mob.bag = new
			var/bag_slot/b
			for(var/y=5, y>=1, y--)
				for(var/x=1, x<=5, x++)
					b = new
					b.screen_loc = "bag:[x],[y]"
					src.mob.bag += b
					src.screen += b

		buildStorage() //called when not loading a savefile
			if(!src.mob.bank) src.mob.bank = new
			var/bag_slot/b
			for(var/y=5, y>=1, y--)
				for(var/x=1, x<=5, x++)
					b = new
					b.screen_loc = "bank:[x],[y]"
					src.mob.bank += b
					src.screen += b

		loadBagSlots() //called when loading a savefile
			for(var/bag_slot/b in src.mob.bag)
				src.screen += b
				b.mouse_drag_pointer = b.item
				b.refresh()

		loadStorageSlots() //called when loading a savefile
			for(var/bag_slot/b in src.mob.bank)
				src.screen += b
				b.mouse_drag_pointer = b.item
				b.refresh()

//Basic item system
item
	parent_type = /obj
	var
		const/STACK_LIMIT = 20 //enforcing a stack limit; set to 1#INF for no stack limit
		stack = 1 //any positive value for a stack denotes a stackable item

	Crossed(var/atom/movable/a)
		if(ismob(a))
			var/mob/m = a
			m.addItem(src)

	equip
		stack = -1 //any negative value for stack denotes a non-stackable item

//GFX datum for the stack numbers
stack_num
	parent_type = /obj
	layer = OBJ_LAYER+0.1
	pixel_x = 14
	icon = 'Stack Numbers.dmi'
	New(loc, var/value)
		..()
		src.icon_state = "[value]"

//Bag slot datum for the inventory slots, bank/storage slots, etc
bag_slot
	parent_type = /obj
	layer = OBJ_LAYER-0.1
	icon = 'Bag Slot.dmi'
	var
		item/item

	proc
		setItem(var/item/i)
			src.item = i
			src.mouse_drag_pointer = i
			src.refresh()

		refresh()
			src.overlays = null
			if(src.item)
				src.overlays += src.item
				if(src.item.stack > 0)
					src.overlays += new /stack_num(null, src.item.stack)

	MouseDrop(over_object, src_location, over_location, src_control, over_control, params)
		if(!src.item)
			..()
			return
		var
			list/L = params2list(params)
			item/split
		if(over_control == "default.map")
			if(L["shift"]) split = usr.splitItem(src.item)
			if(split)
				split.Move(usr.loc, SOUTH, usr.step_x, usr.step_y)
				if(split == src.item) src.setItem(null)
				else src.refresh()
			else
				src.item.Move(usr.loc, SOUTH, usr.step_x, usr.step_y)
				src.setItem(null)
		else if(over_control == "default.bag" || over_control == "storage.bank")
			if(src == over_object) return
			var/bag_slot/next_slot = over_object
			if(!next_slot.item)
				if(src.item.stack >= 0 && L["shift"])
					split = usr.splitItem(src.item)
					if(split)
						next_slot.setItem(split)
						if(split == src.item)
							src.setItem(null)
						else src.refresh()
						return
			else if(src.item.stack >= 0 && next_slot.item.type == src.item.type && next_slot.item.stack < src.item.STACK_LIMIT)
				var/stack_diff = next_slot.item.STACK_LIMIT-next_slot.item.stack
				if(L["shift"])
					split = usr.splitItem(src.item)
					if(split && split != src.item)
						var/x = min(stack_diff, split.stack)
						next_slot.item.stack += x
						next_slot.refresh()
						split.stack -= x
						src.item.stack += split.stack
				else
					var/x = min(src.item.stack, stack_diff)
					next_slot.item.stack += x
					next_slot.refresh()
					src.item.stack -= x
				if(!src.item.stack)
					src.setItem(null)
				else src.refresh()
				return
			usr.swapItems(src, next_slot)
		else ..()

mob
	var
		list/bag
		list/bank

	proc
		removeAllBagLays()
			for(var/bag_slot/b in src.bag)
				b.overlays = null

		refreshAllBagSlots()
			for(var/bag_slot/b in src.bag)
				b.refresh()

		addItem(var/item/i)
			if(!i.stack) del i //if incoming item has 0 stack, delete it
			else if(i.stack < 0) //if incoming item isn't stackable
				for(var/bag_slot/b in src.bag) //loop through all bag_slots
					if(!b.item) //to the first empty bag_slot
						b.setItem(i) //place incoming item into that slot
						i.loc = null
						return 1 //return success
			else //if incoming item is stackable
				var/bag_slot/empty
				for(var/bag_slot/b in src.bag) //loop through all bag_slots
					if(!b.item) //if an empty slot is found
						if(!empty) empty = b //save first encountered empty bag_slot if one hasn't already
					else if(b.item.type == i.type && b.item.stack < b.item.STACK_LIMIT) //if a like item is found
						var/x = min(b.item.STACK_LIMIT-b.item.stack, i.stack) //enforce the stack limit
						i.stack -= x
						b.item.stack += x
						b.refresh()
						if(!i.stack)
							del i
							return 1
				if(empty) //if no like items are found (or there's leftover stack from combining like items) and an empty slot was found
					empty.setItem(i) //place the incoming item into the empty slot
					i.loc = null
					return 1 //return sucess
			src<<"Your bag is full!" //notify if bag is full
			return 0 //return fail

		swapItems(var/bag_slot/prev_slot, var/bag_slot/next_slot)
			var/item/t_item = prev_slot.item //temporarily store an item for the swap
			prev_slot.setItem(next_slot.item)
			next_slot.setItem(t_item)

		splitItem(var/item/i)
			if(i.stack > 1) //only perform if the stackable item's stack is more than 1
				var
					item/split_item
					amt = input(src, "", "Split Stack", round(i.stack/2, 1)) as null|num //ask the player
				amt = round(abs(amt), 1) //no negatives or decimals
				if(amt && amt < i.stack)
					split_item = new i.type
					split_item.stack = amt
					i.stack -= amt
					return split_item //return newly split item
			return i //return original item everything fails