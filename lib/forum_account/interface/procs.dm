
// File:    procs.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Defines the procs() proc that enumerates all
//   procs that a DM object contains. This doesn't
//   include any built-in procs, so if you call
//   mob.procs(), the returned list won't include Move.

datum
	proc
		procs()
			. = list()

			var/list/type_parts = split("[type]", "/")

			for(var/i = type_parts.len to 2 step -1)
				var/path = ""
				for(var/p = 1 to i)
					if(type_parts[p])
						path += "/[type_parts[p]]"

				for(var/t in typesof("[path]/proc"))
					var/list/parts = split("[t]", "/")
					. += parts[parts.len]
