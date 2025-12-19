#define DEBUG
proc
	split(var/textstring,var/splitcharacter)
		if(!istext(textstring))return
		if(!istext(splitcharacter))return
		var/list/list2make = list("")
		var/currenttext
		var/out = ""
		for(var/i = 1,i < length(textstring),i++)
			currenttext = copytext(textstring,i,i+1)
			if(length(textstring) - 1 == i)
				currenttext = copytext(textstring,i,i+2)
				out += currenttext
				if(out)list2make += out
				out = ""
				continue
			if(currenttext == splitcharacter)
				if(out)list2make += out
				out = ""
				continue
			out += currenttext
		return list2make

	asciifilter(var/text,var/options)
		var/options2 = split(options,"&")
		var/list/allowedlist = list("")
		for(var/x in options2)
			if(findtext(x,"-"))
				var/startnum = text2num(copytext(x,1,4))
				var/endnum = text2num(copytext(x,5,8))
				for(var/i = startnum, i <= endnum)
					allowedlist += i
					i ++
			else
				allowedlist += text2num(x)
		for(var/ii = 1, ii <= length(text), ii++)
			var/a = text2ascii(copytext(text, ii, ii+1))
			if(a in allowedlist)
				continue
			else
				return 0
		return 1

