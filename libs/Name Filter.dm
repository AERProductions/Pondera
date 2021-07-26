#define DEBUG
/*Created by: Yash 69
A name filter for all your filtering needs,
we all hate those stupid names that are just nooby and improper,
so I made this to stop noobs in their tracks!

Credit if Used, thank you!
*/
var
	list
		capital_letters = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z")
		allowed_characters = list("A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0")
		illegal_names = list("Fuck", "Shit", "Fag", "Douche", "Queer", "Cunt", "Bitch", "Pussy", "Vagina", "Penis", "Cock", "Nigger", "Nigga", "Bastard", "Sucks", "Ass", "Dick")
		filtered_names = list()//Add names you don't want players to have, if you own a naruto game, the first name you would want to have would be Naruto

proc
	ASCII_Filter(var/text,var/options)
		var/options2 = Split(options,"&")
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
	Split(var/textstring,var/splitcharacter)
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
/*mob
	Login()
		naming:
		var/enter_name = input("What would you like to be called on this game?","Character Name") as text|null
		if(Review_Name(enter_name))
			goto naming
		src.name = html_encode(url_decode(enter_name))
		alert("Your name is now [src]","Name Complete")
		world<<"[src.key] has been named [src]"
		..()*/
proc
	Review_Name(name)
		var/fill_name = ckey(name)
		var/capitalletters = 0
		var/config = "065-090&097-122&032"//"048-057&065-090&097-122&032"
		var/name_length = length(name)
		
		if(!fill_name)
			alert("You must enter a name","Error")
			return 1
		if(!ASCII_Filter(name,config))
			alert("Your name can only contain Uppercase/Lowercase letters and spaces","Error")
			return 1
		if(name == uppertext(name))
			alert("Your name cannot be entirely capped","Error")
			return 1
		for(var/f in filtered_names)
			if(findtext(name,f))
				alert("Your name cannot contain '[f]'","Error")
				return 1
		for(var/i in illegal_names)
			if(findtext(name,i))
				alert("Your name cannot contain '[i]'","Error")
				return 1
		for(var/c in capital_letters)
			if(findtextEx(name,c))
				capitalletters ++
		if(capitalletters >= 4)
			alert("You have too many capitals in your name","Error")
			return 1
		//if(!(capital_letters.Find(copytext("[name]",1,2))))
		//	alert("Your name must start with a capital letter","Error")
		//	return 1
		if(name_length > 15 || name_length < 3)
			alert("Your name must contain 3 to 15 characters.\n- Current Length: [name_length]","Error")
			return 1
		if(copytext(name,1,2) == " ")
			alert("Your name cannot begin with a space","Error")
			return 1
		if(copytext(name,name_length,name_length+1) == " ")
			alert("Your name cannot end with a space","Error")
			return 1