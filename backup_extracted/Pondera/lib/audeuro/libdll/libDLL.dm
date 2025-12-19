DLL
	var
		_lib_name = null
	New(name = null)
		if((!name && !_lib_name) || !istext(name) || (_lib_name && !istext(_lib_name)))
			del src
		if(!_lib_name)
			_lib_name = name
	proc
		Call(func_name, list/argslist)
			if(!istext(func_name) || !func_name || (argslist && !istype(argslist)) || !_lib_name || !istext(_lib_name)) return -1
			return call(_lib_name, func_name)(arglist(argslist))
		GetName()
			return _lib_name