
// File:    hud-groups.dm
// Library: Forum_account.HudGroups
// Author:  Forum_account
//
// Contents:
//   This file contains the defition of the HudGroup and
//   HudObject object types. The HudGroup object manages
//   the creation and positioning of screen objects, and
//   gives you the ability to hide/show groups of screen
//   objects. You never have to deal with client.images
//   or client.screen yourself. The HudGroup object has
//   the following procs:
//
//     * add()
//     * remove()
//     * pos()
//     * hide()
//     * show()
//     * toggle()
//
//   The HudObject object is created by calling the group's
//   add proc. This object is derived from /atom/movable
//   and is the actual screen object your client displays.
//   The HudObject object has these procs:
//
//     * pos()
//     * size()
//     * set_text()

HudGroup
	var
		// the icon given to all objects in the group
		icon

		// the list of objects in this group
		list/objects = list()

		// the list of clients viewing this group
		list/clients = list()

		// the position of the group
		sx = 0
		sy = 0

		// whether the group is visible or not
		visible = 1

		// the layer given to all objects in the group,
		// this value is only assigned if it's >= 0
		layer = -1

		icon_size = 32
		icon_width = 32
		icon_height = 32

		Font/font

	New(client/c, i = null)
		if(istype(c, /mob))
			var/mob/m = c
			if(m.client)
				c = m.client
			else
				CRASH("The HudGroup's constructor expects a client or mob with a client as the first argument, got [c] instead.")

		clients += c

		// you don't have to pass an icon to the constructor, you could create
		// a sub-type of HudGroup and set its icon on the type definition.
		if(i)
			icon = i

		if(icon)
			var/icon/I = icon(icon)
			icon_size = I.Width()

	proc
		// the add() proc has three forms:
		//
		//   add(client/c)
		//   add(mob/m)
		//   add(px, py, [named args])
		//
		// the first two forms add a viewer to the group, the third
		// form adds an object to the group at the specified position
		// and can take additional optional named parameters.
		add(x, y, icon_state = null, text = null, width = null, height = null, value = null, layer = null, icon = null, maptext = null, maptext_width = null, maptext_height = null)

			if(isnull(layer))
				layer = src.layer

			// if x is a client, we're adding a client
			if(istype(x, /client))
				return __add_client(x)

			// if x is a mob, add its client
			else if(istype(x, /mob))
				var/mob/m = x
				if(m.client)
					return __add_client(m.client)
				else
					return 0

			// otherwise we use the regular form to add an object
			else
				return __add_object(x, y, icon_state, text, width, height, value, layer, icon, maptext, maptext_width, maptext_height)

		// the remove() proc has five forms:
		//
		//   remove(client/c)
		//   remove(mob/m)
		//   remove(HudObject/h)
		//   remove(index)
		//   remove()
		//
		// see _readme.dm for more information about these forms.
		remove(argument = -1)

			if(istype(argument, /client))
				return __remove_client(argument)

			else if(istype(argument, /mob))
				var/mob/m = argument
				if(m.client)
					return __remove_client(m.client)
				else
					return 0

			else if(istype(argument, /HudObject))
				return __remove_object(argument)

			// otherwise, you're removing an object by index
			else
				var/index = argument

				// if no index is specified, delete the last object
				if(index == -1)
					index = objects.len

				// make sure the index is valid
				if(index > objects.len) return 0
				if(index < 1) return 0

				return __remove_object(objects[index])

		// move the group's position, this is the position that
		// all object's positions are relative to
		pos(x, y)
			sx = x
			sy = y

			// update the base x,y of all objects in the group
			for(var/HudObject/h in objects)
				h.pos(null, null, x, y)

		// hide the display of all objects from all clients
		hide()
			if(!visible) return 0

			visible = 0

			for(var/client/c in clients)
				for(var/HudObject/h in objects)
					__hide_object(h, c)

		// make all objects visible to all clients
		show()
			if(visible) return 0

			visible = 1

			for(var/client/c in clients)
				for(var/HudObject/h in objects)
					__show_object(h, c)

		toggle()
			if(visible)
				hide()
			else
				show()

		// this is called when you click a HudObject
		Click(HudObject/object)

		DragAndDrop(HudObject/a, HudObject/b)


		//     ---- Private Methods ----
		//
		// these are methods that you never need to call
		// yourself, the library just uses them internally.

		__update_text(HudObject/h)

			if(!h.__text) return
			if(!h.__text.len) return

			if(visible)
				for(var/client/c in clients)
					__show_object(h, c)

		// create a new HudObject and apply any parameters that were specified
		__add_object(x, y, icon_state, txt, width, height, value, l = null, icon/I = null, mt = null, mtw = null, mth = null)

			// create a new object and set its position, including
			// the specified x,y and its base x,y
			var/HudObject/h = new(src, icon, icon_state, value = value)

			if(!isnull(I))
				h.icon = I

			h.pos(x, y, sx, sy)

			if(!isnull(width) || !isnull(height))
				h.size(width, height)

			if(!isnull(l))
				h.layer = l
			else if(layer >= 0)
				h.layer = layer

			objects += h

			if(!isnull(txt))
				h.set_text(txt)

			h.set_maptext(mt, mtw, mth)

			// if this group is visible we have to show the
			// new object to all clients viewing this group
			if(visible)
				for(var/client/c in clients)
					__show_object(h, c)

			return h

		__add_client(client/c)

			// avoid duplicates
			if(c in clients) return 0

			clients += c

			// if the group is visible, we have to show the new
			// client all objects in this group
			if(visible)
				for(var/HudObject/h in objects)
					__show_object(h, c)

			return 1

		__remove_client(client/c)

			// check that the client is in our clients list
			if(!(c in clients)) return 0

			// remove the client
			clients -= c

			// if objects are being shown to this client, remove them
			if(visible)
				for(var/HudObject/h in objects)
					__hide_object(h, c)

			return 1

		__hide_object(HudObject/h, client/c)
			c.screen -= h
			c.images -= h.__text

		__show_object(HudObject/h, client/c)
			c.screen += h
			if(h.__text)
				c.images += h.__text

		__remove_object(HudObject/h)

			// remove the object from the list
			objects -= h

			// if this object was visible, remove it from all client displays
			if(visible)
				for(var/client/c in clients)
					__hide_object(h, c)

			// this will cause the object to get deleted
			h.loc = null

			// also delete any images attached to it
			if(h.__text)
				for(var/i in h.__text)
					del i

			return 1

// when you add an object to a HudGroup, the object that's created is
// of the /HudObject type. Because this type's parent is set to /atom/movable
// this object can be used as the screen object (so you can change its
// icon, icon_state, or layer directly) and it also has the procs defined
// here to extend its behavior.
HudObject
	parent_type = /atom/movable

	maptext_width = 32
	maptext_height = 32

	var
		sx = 0
		sy = 0

		__sx = 0
		__sy = 0
		__base_x = 0
		__base_y = 0

		__width = 1
		__height = 1

		HudGroup/hud_group
		value

		list/__text

	New(HudGroup/hg, i, state, sx = 0, sy = 0, value = null)
		hud_group = hg

		if(i) icon = i
		if(state) icon_state = state

		src.value = value

		__sx = sx
		__sy = sy

	Click()
		hud_group.Click(src)

	MouseDrop(over_object,src_location,over_location,src_control,over_control,params)
		hud_group.DragAndDrop(src, over_object)

	proc
		// updates the screen object's position. you can ignore
		// the last two arguments, they're used by the library
		// but you'll never need to use them.
		pos(sx = null, sy = null, base_x = null, base_y = null)

			// update the internal vars to match any specified parameter
			if(!isnull(sx)) __sx = sx
			if(!isnull(sy)) __sy = sy
			if(!isnull(base_x)) __base_x = base_x
			if(!isnull(base_y)) __base_y = base_y

			src.sx = __sx
			src.sy = __sy

			__set()

		// set the size of the screen object. the size is measured
		// in tiles, not pixels. the default size is 1x1.
		size(width = null, height = null)
			if(!isnull(width)) __width = width
			if(!isnull(height)) __height = height
			__set()

		// set the text that's attached to this screen object. if there
		// is already text on this screen object it will be erased. you
		// can specify a font, but if you don't the HudGroup's font will
		// be used.
		set_text(t, Font/font)
			if(!font)
				font = hud_group.font

			// if the object already has text attached to it,
			// we delete the old text.
			if(__text)
				for(var/i in __text)
					del i
				__text.Cut()

			// otherwise we initialize the __text list
			else
				__text = list()

			// create objects to represent each letter in the string
			var/px = 0
			var/py = -font.descent
			for(var/i = 1 to length(t))
				var/char = copytext(t, i, i + 1)

				// handle line breaks
				if(char == "\n")
					px = 0
					py -= font.line_height
					continue

				// we create an image object for every symbol in the string
				// of text. the images are attached to the screen object so
				// that moving the screen object moves the text.
				var/image/symbol = image(font.icon, src, char, layer)
				symbol.layer = layer
				symbol.pixel_x = px
				symbol.pixel_y = py
				__text += symbol

				px += font.char_width(char) + font.spacing

			// we notify the hud group that the text has changed and it
			// handles displaying it to clients
			hud_group.__update_text(src)

		set_maptext(maptext = null, width = null, height = null)
			if(!isnull(maptext)) src.maptext = maptext
			if(!isnull(width)) src.maptext_width = width
			if(!isnull(height)) src.maptext_height = height


		//     ---- Private Methods ----
		//
		// these are methods that you never need to call
		// yourself, the library just uses them internally.

		// sx and sy are in pixels, width and height are in tiles
		// since screen objects can only have full tile sizes.
		__screen(sx, sy, width = 1, height = 1)
			var/tx = round(sx / hud_group.icon_size) + 1
			var/ty = round(sy / hud_group.icon_size) + 1
			var/ox = sx % hud_group.icon_size
			var/oy = sy % hud_group.icon_size

			return "[tx + width - 1]:[ox],[ty + height - 1]:[oy]"

		__set()

			// compute px and py, then compute the overall position
			// as screen_loc needs it (both tile and pixel offset)
			var/px = __sx + __base_x
			var/py = __sy + __base_y

			if(__width > 1 || __height > 1)
				var/c1 = __screen(px, py)
				var/c2 = __screen(px, py, __width, __height)
				screen_loc = "[c1] to [c2]"
			else
				screen_loc = __screen(px, py)
