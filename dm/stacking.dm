/*

	Item Stacking
	Handles stacking of items both on the game map and in the player inventory

	This dm file contains everything needed to make this system function

	Any inquiries or assistance in using this system can be directed to F0lak
	at f0lak.haz@gmail.com
	Subject: Pondera Item Stacking

	version 1.0 | 12/02/20 | by F0lak

*/

#define DEBUG_STACKING FALSE

#if DEBUG_STACKING
#warn DEBUG_STACKING is on
#endif

proc
	STACKINGDebugOutput(txt)
		world.log << "Stacking Debug: [txt]"

// Items are the only object type that can stack
obj/items

	// maptext is used for the stack numbers
	maptext_y = 20
	maptext_x = 20


	var
		can_stack = FALSE	// by default, items cannot stack, so this won't lead to unexpected behaviour
		stack_amount = 1	// by default, one item exists in a stack

	// Stacking is called on any Move() call, so it's taken care of whenever
	// an item enters any container, turf, or is created
	New(atom/NewLoc)
		..()
		if(can_stack)
			var/obj/items/target = locate(type) in NewLoc
			if(target && CanStack(target))
				MergeStack(target)

	proc
		// Checks if two items can stack with each other
		CanStack(obj/items/target)
			if(target != src && target.can_stack && target.type == type)
				return TRUE
			else
				return FALSE

		// Merges two stacks together
		MergeStack(obj/items/target)
			target.AddToStack(stack_amount)
			del src

		// Splits two stacks apart
		SplitStack(atom/new_loc, amount)
			var/obj/items/new_item = new type(new_loc)
			new_item = locate()
			new_item.stack_amount = amount

			new_item.UpdateStack()
			RemoveFromStack(amount)

		// Adds to a stack
		AddToStack(i)
			stack_amount += i
			UpdateStack()

		// Removes from a stack
		RemoveFromStack(i)
			stack_amount -= i
			UpdateStack()

		// Updates the stack numbers and handles deleting empty stacks
		UpdateStack()


			if(stack_amount <= 0)
				del src

			else
				if(stack_amount > 1)
					if(stack_amount > 99)
						maptext_x = 46
						maptext = "99+"
					else
						if(stack_amount >= 10)
							maptext_x = 52
						else
							maptext_x = 58
						maptext = "[stack_amount]"
				else
					maptext = null
				suffix = maptext


	/*verb
		getall()
			set src in range(1)
			SplitStack(usr, stack_amount)

		dropall()
			set src in usr
			SplitStack(usr.loc, stack_amount)

		get_amount(amount as num)
			set src in range(1)
			if(amount)
				SplitStack(usr, amount)
			else
				SplitStack(usr, stack_amount)

		drop_amount(amount as num)
			set src in range(1)
			if(amount)
				SplitStack(usr.loc, amount)
			else
				SplitStack(usr.loc, stack_amount)*/