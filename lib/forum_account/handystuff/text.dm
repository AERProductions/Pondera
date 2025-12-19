
// File:    text.dm
// Library: Forum_account.HandyStuff
// Author:  Forum_account
//
// Contents:
//   This file has two purposes. First, it provides a consistent
//   naming scheme for text-related procs (copytext, findtest, etc.)
//   Second, it adds some text-related features that should probably
//   be built-in, but aren't (like replace, split, and replace).
//
//   These procs belong to a global object called Text, so you can
//   reference them like this:
//
//       instead of:
//       copytext(some_string, 1, 5)
//
//       you'd write:
//       Text.copy(some_string, 1, 5)

var
	Text_namespace/Text = new()
	Text_namespace/String = Text

Text_namespace
	proc
		copy(txt, start = 1, end = 0)
			return copytext(txt, start, end)

		find(haystack, needle, start = 1, end = 0, match_case = 0)
			if(match_case)
				return findtextEx(haystack, needle, start, end)
			else
				return findtext(haystack, needle, start, end)

		upper(txt)
			return uppertext(txt)

		lower(txt)
			return lowertext(txt)

		int(txt, base = 10)
			ASSERT(istext(txt))
			ASSERT(base >= 2)
			ASSERT(base <= 16)

			. = 0

			var/negative = 0
			if(copytext(txt,1,2) == "-")
				txt = copytext(txt,2)
				negative = 1

			txt = uppertext(txt)
			var/list/num_char = list("0"=0,"1"=1,"2"=2,"3"=3,"4"=4,"5"=5,"6"=6,"7"=7,"8"=8,"9"=9,"A"=10,"B"=11,"C"=12,"D"=13,"E"=14,"F"=15)
			for(var/i = 1 to length(txt))
				var/c = copytext(txt,i,i+1)
				if(c in num_char)
					c = num_char[c]
					if(c >= base)
						. = usr
						CRASH("Invalid character '[c]' in base [base] string '[txt]'.")
					. = (base * .) + c
				else
					return null

			if(negative)
				. = -.

		split(txt,d)
			ASSERT(istext(txt))
			ASSERT(d)

			var/pos = findtext(txt, d)
			var/start = 1

			. = list()

			while(pos > 0)
				. += copytext(txt, start, pos)
				start = pos + 1
				pos = findtext(txt, d, start)

			. += copytext(txt, start)

		join(list/L, d)
			ASSERT(istype(L))
			ASSERT(istext(d))

			. = ""
			for(var/t in L)
				if(.) . += d
				. += t

		merge(list/L,d)
			return join(L,d)

		replace(txt,a,b)
			ASSERT(istext(txt))
			ASSERT(istext(a))
			ASSERT(istext(b))

			var/start = 1
			var/pos = findtext(txt,a,start)
			while(pos > 0)
				txt = copytext(txt,1,pos) + b + copytext(txt,pos + length(a))
				start = pos + length(b)
				pos = findtext(txt,a,start)
			return txt