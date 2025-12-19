mob/verb/test()
	var/a = null
	var/config = "065-090&097-122&095&032"
	while(!asciifilter(a,config)||a == null)a = input("Pick a name","Name") as text
	world << "Name <b>[a]</b>, has passed"

mob/verb/checkascii()
	var/a = input("Input a character to check the ascii value of it.","Input")as text
	world << text2ascii(a)

/*
Made by Thomas Polasek(thomas41546), checkascii(), split()
=======================
IMPORTANT... READ THIS!
=======================
The filer works perfectly, but you must enter the variables in the proc correctly, or you
could get some weird stuff.

asciifilter(var/text,var/options)
This filter works, by returning 0 if a character found in "text" is not found in options.
1 is returned if all the characters fit into the option ascii values.

In the variable text, add the string you wish to check, to make sure that an appropiate name
is choosen.

In options you must use the following format, or it will cause an error.

You must use numbers that represent ascii characters, ranging from
001 to 255.

If the number is less then 3 characters in length, for examaple

23

this would not work, so what you have to do, is add zero's infront of the number to make
it 3 characters long.

ex.

12 ---> 012
5  ---> 005
124 --> 124

now if you want to use a range, for number a to number b, then seperate the two values, with
a hyphen "-"

065-090 will set it so all uppercase letters.

if you wish to have multiple ranges and single values then use the "&" character to seperate,
them.

ex.

065-090&097-122&095&032

065-090 means all uppercase ascii letters
097-122 means all lowercase ascii letters
095     means underscore
032     means spaces
each range, or single number was seperated with "&"

these are the same options used in the demo...

using the demo's options
ex.

name = "BoB rock_s"  will allow it
name = "Bob is cool" will allow it
name = "Bob@shaw"    will not be allowed, and will be requested to enter a new name, until a
proper name is chosen.



THE FULL ASCIILIST IS FOUND IN ASCIILIST.dm

REMEMBER TO MAKE THE DIGITS 3 CHARACTERS LONG!

*/