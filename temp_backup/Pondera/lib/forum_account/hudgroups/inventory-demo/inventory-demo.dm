
#define DEBUG

HudInventory
	parent_type = /HudGroup

	icon = 'inventory-demo-icons.dmi'
	layer = MOB_LAYER + 50

	var
		list/slots = list()

		HudObject/boots
		HudObject/armor

	New(mob/m)
		..()

		hide()

		for(var/x = 0 to 7)
			for(var/y = 0 to 3)
				var/px = x * 32 + 48
				var/py = y * 32 + 16

				add(px, py, "[x],[y]")

		for(var/y = 0 to 1)
			for(var/x = 0 to 6)
				var/px = x * 32 + 64
				var/py = y * 32 + 32

				var/HudObject/h = add(px, py, "slot")
				h.name = "slot"
				slots += h

		armor = add(72, 104, "armor")
		armor.name = "armor"
		slots += armor

		boots = add(108, 104, "boots")
		boots.name = "boots"
		slots += boots

	// drop a onto b
	DragAndDrop(HudObject/a, HudObject/b)

		// a has to be an item
		if(!istype(a.value, /item)) return

		// b has to be a slot
		if(!(b in slots)) return

		// try to swap the items
		swap(a, b)

	proc
		swap(HudObject/a, HudObject/b)
			// you can't swap two equipped items
			if(a.name != "slot" && b.name != "slot") return

			// always format the call so the equipped item is
			// the second argument
			if(a.name != "slot")
				return swap(b, a)

			// if a has a value, that means that a.value is the item
			// we're equipping and b is the slot we're putting it in.
			if(a.value)
				var/item/i = a.value

				// if b is the slot this item goes in, equip a
				if(b.name == i.slot)
					usr.equip(i)

				// if b is a regular inventory slot then we're merely
				// moving the item and don't have to do anything special.
				else if(b.name == "slot")

				// this else clause is the case where b is an inventory
				// slot, but not the one that a.value would be equipped
				// in. in this case we return
				else
					usr << "[i] can't go in the [b.name] slot."
					return

			// otherwise, a is an empty slot and b.value is the item
			// we're unequipping.
			else
				usr.unequip(b.value)

			// do the swap
			var/t = b.value
			var/t_state = b.icon_state
			b.value = a.value
			b.icon_state = a.icon_state
			a.value = t
			a.icon_state = t_state

			// fix the slot's icon_state
			if(!a.value) a.icon_state = a.name
			if(!b.value) b.icon_state = b.name

		add_item(item/i)
			for(var/HudObject/h in slots)
				if(!h.value)
					h.value = i
					h.icon_state = i.icon_state
					break

item
	parent_type = /obj

	icon = 'inventory-demo-icons.dmi'

	var
		slot

	Move()
		. = ..()

		var/mob/m = loc

		if(istype(m))
			m.hud_inventory.add_item(src)

	boots
		slot = "boots"
		one
			name = "leather boots"
			icon_state = "boots-1"

		two
			name = "soldier boots"
			icon_state = "boots-2"

		three
			name = "fancy boots"
			icon_state = "boots-3"

	armor
		slot = "armor"
		one
			name = "shirt"
			icon_state = "armor-1"

		two
			name = "leather armor"
			icon_state = "armor-2"

		three
			name = "plate mail"
			icon_state = "armor-3"

mob
	var
		HudInventory/hud_inventory
		list/equipped = list()

	Login()
		loc = locate(15, 9, 1)

		hud_inventory = new(src)

		src << "Walk over items to pick them up. Use the 'toggle inventory' verb to show your inventory. In the inventory menu, drag items to move, equip, and unequip them."

	Move()
		. = ..()

		for(var/item/i in loc)
			i.Move(src)

	verb
		toggle_inventory()
			hud_inventory.toggle()

	proc
		equip(item/i)
			if(i.slot in equipped)
				var/item/e = equipped[i.slot]

				if(e)
					unequip(e)

				equipped[i.slot] = i
			else
				equipped[i.slot] = i

			src << "You equip [i]."
			return 1

		unequip(item/i)
			equipped[i.slot] = null
			src << "You remove [i]."


// the rest of this code is needed for the demo but doesn't
// relate to how you'd use the HUD library.
atom
	icon = 'hud-demo-icons.dmi'

turf
	icon_state = "grass"

	water
		density = 1
		icon_state = "water"

	trees
		density = 1
		icon_state = "trees"

	rock
		density = 1
		icon_state = "rock"

mob
	icon_state = "mob"
