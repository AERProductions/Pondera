
// File:    list-parsing.dm
// Library: Forum_account.Interface
// Author:  Forum_account
//
// Contents:
//   Defines a recursive descent list parser to convert
//   strings of the format:
//
//     [1, 2, 3]
//
//   To DM lists. Every value in the DM list is passed to
//   the parse_value() proc which will convert JS values
//   to DM strings, numbers, lists, or objects.

__list_parser
	var
		text = ""
		index = 1
		error = 0

	New(t)
		text = t

	proc
		char()
			. = copytext(text, index, index + 1)
			index += 1

		next(t)
			if(copytext(text, index, index + length(t)) != t)
				return 0
			return 1

		match(t)
			if(next(t))
				index += length(t)
				return 1
			return 0

		Hashtable()
			if(!match("h{"))
				error = 1
				return 0

			if(next("}"))
				return list()

			var/list/return_value = list()

			while(1)
				var/list/pair = NameValuePair()

				while(match(" "))

				return_value[pair[1]] = pair[2]

				if(next("}"))
					match("}")
					break

				if(!match(","))
					error = 1
					return 0

			return return_value

		List()
			if(!match("l\["))
				error = 1
				return 0

			if(next("]"))
				return list()

			var/list/return_value = list()

			while(1)
				var/e = Element()

				return_value += 0
				return_value[return_value.len] = e

				if(next("]"))
					match("]")
					break

				if(!match(","))
					error = 1
					return 0

			return return_value

		NameValuePair()

			if(next("l\["))
				return List()

			if(next("h{"))
				return Hashtable()

			var/first_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
			var/name_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_01234567890"

			// eat whitespace
			while(match(" "))

			var/name = ""
			while(1)
				if(next(":"))
					match(":")
					break

				// if the next character is a space, we need to match
				// only spaces then the colon.
				if(next(" "))

					// eat the whitespace
					while(match(" "))

					if(match(":"))
						break
					else
						error = 1
						return 0

				var/c = char()

				if(length(name) <= 0)
					if(!findtext(first_chars, c))
						error = 1
						return 0
				else
					if(!findtext(name_chars, c))
						error = 1
						return 0

				name += c

			// eat whitespace
			while(match(" "))

			// get the value
			var/value = Element()

			return list(name, value)

		Element()
			if(next("l\["))
				return List()

			if(next("h{"))
				return Hashtable()

			// if this element is an object reference we need to treat the first
			// "]" symbol as part of the reference, not as the end ofthe list
			var/is_object = next("r\[")

			var/t = ""
			while(1)
				if(next(","))
					break

				if(next("]"))
					if(is_object)
						is_object = 0
					else
						break

				if(next("}"))
					break

				t += copytext(text, index, index + 1)
				index += 1

			return parse_value(t)

		parse()
			error = 0

			if(next("h{"))
				. = Hashtable()
			else if(next("l\["))
				. = List()
			else
				error = 1

			if(error)
				return null

			return .
