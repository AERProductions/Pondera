/* A place to store spaces in the file system.

space_storage
	New(path = "Spaces")
		A new space storage at the given path.

	Save(space/space)
	Save(name)
		Saves the space with the given name.
		Space must be named, since savefiles need a name.
		Returns true on success, false otherwise.

	Load(name)
		Loads the space with the given name.
		Space comes ready to paste.
		Returns the loaded space.

	Name(name, space/space)
		Names a space.

	Remove(space/space)
	Remove(name)
		Removes a space.
		Doesn't delete the savefile.

	Names()
		List of all names of spaces in the world.

	Spaces()
		List of all named spaces in the world.

	Lookup(name)
		Get the space of this name.

	NameOf(space/space)
		Get the name of this space.

	CanLoad(name)
		Is there a savefile for this name?

	Filename(name)
		The path to the savefile for this name.

*/

space_storage
	var/path
	var/list/lookup
	var/list/name_of

	New(path = "Spaces")
		..()
		src.path = path
		lookup = new
		name_of = new

	proc/Save(a)
		var/space/space
		var/name
		if(istext(a))
			name = a
			space = Lookup(name)
		else if(istype(a, /space))
			space = a
			name = NameOf(space)
		if(space && name)
			fdel(Filename(name))
			new/savefile(Filename(name)) << space
			return TRUE
		return FALSE

	proc/Load(name)
		if(CanLoad(name))
			var/space/space
			new/savefile(Filename(name)) >> space
			if(istype(space))
				Name(name, space)
				return space

	proc/SavedNames()
		var/list/names = new
		for(var/f in flist("[path]/"))
			if(cmptext(".sav", copytext(f, -4)))
				names += copytext(f, 1, -4)
		return names

	proc/Name(name, space/space)
		lookup[name] = space
		name_of[space] = name

	proc/Remove(a)
		if(istext(a))
			lookup -= a
			name_of -= lookup[a]
		else if(istype(a, /space))
			lookup -= name_of[a]
			name_of -= a

	proc/Names()
		return lookup.Copy()

	proc/Spaces()
		return name_of.Copy()

	proc/Lookup(name)
		return lookup[name]

	proc/NameOf(space/space)
		return name_of[space]

	proc/Filename(name)
		return "[path]/[name].sav"

	proc/CanLoad(name)
		return fexists(Filename(name))
