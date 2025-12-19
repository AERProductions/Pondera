/*
	IconColor library by Lummox JR

	Quickly use and access your colored and specially altered icons
 */

/*

  Global procs:

	proc/GetColor(r, g, b)  OR  GetColor(htmlcolor)
		Returns a /color datum for the RGB color you wish. Accepts r,g,b values
		separately or as a single HTML color (text) like "#a02388". Will reuse
		datums for colors that are the same.

	proc/rgb2html(r, g, b)
		Returns the HTML color string for r,g,b.

	proc/Radix16(n, digits)
		Return a hexadecimal version of n. If digits is specified, the result is
		forced to use at least that many digits, with leading 0's.

	proc/hex2num(text)
		Converts a string in hexadecimal to a number.

	proc/GetOpreratedIcon(icon, operation_type, aux, ...)
		Creates or returns an icon modified according to operation_type, where
		operation_type is a subtype of /iconop. By creating your own /iconop
		type and overriding the Operate() proc, you can perform complex icon
		operations just once and save the results in a cache.

  /icolor

	icolor/var/r
		The amount of red in a color: 0-255
	icolor/var/g
		The amount of green in a color: 0-255
	icolor/var/b
		The amount of blue in a color: 0-255
	icolor/var/HTML
		The HTML string for this color, like "#A02388".
	icolor/var/coloricon/firsticon
		The head of a linked list of colored icons

	icolor/proc/RGB()
		Returns rgb(r,g,b) for the color, for use in icon operations

	icolor/proc/RGBinverse()
		Returns rgb(255-r,255-g,255-b) for the color, for use in icon operations

	icolor/proc/GetIcon(icon, inverse, highlight_icon)
		Returns a colored icon, either already in the cache or created for you and
		cached automatically.

		icon: The original icon to color
		inverse: Color in the dark areas instead of the light ones, for
				 color-on-white instead of color-on-black
		highlight_icon: An icon (optional) to add to the colored icon for light
						highlights. Good for metallic or plastic textures. Highlight
						icons should be mostly black with some dark gray spots where
						a little light reflects.

		The same combination of effects (inverse and highlight) will be reapplied
		regardless of the inverse and highlight_icon vars if the icon is cached. If
		you need more flexibility on that, use GetOperatedIcon() and define custom
		/iconop types instead.

  /icoloricon

	This datum is not meant to be accessed directly. However the expiration time is
	user-settable.

	icoloricon/var/expire
		Time before the icon expires from the cache (default 1 minute). At random
		the expiration time is set up to double the amount you choose, so if many
		icons are created at once their deletion will be spread out a bit to spare
		the system a shock.

		If this value is zero or negative, the icon will not be deleted on its own.

  /iconop

	This datum should not be accessed directly. Its purpose is for users to create
	subtypes like /iconop/rotated or such, where they override the Operate() proc.
	Each icon operation comes with a unique piece of optional auxiliary data; icons
	with the same operation type and auxiliary data will be cached for retrieval
	later.

	iconop/var/expire
		Ticks before the icon expires from the cache (default 1 minute). At random
		the expiration time is set up to double the amount you choose, so if many
		icons are created at once their deletion will be spread out a bit to spare
		the system a shock.

		If this value is zero or negative, the icon will not be deleted on its own.

	iconop/proc/Operate(icon, aux, ...)
		Using an original icon and some auxiliary data, create and return a modified
		icon. This is meant to be overridden by the user. An example might be:

		iconop/redden/Operate(ic, aux)
			var/icon/result = new(ic)
			result.Blend(rgb(aux ? (aux) : 50, 0, 0), ICON_ADD)
			return result

 */


proc/Radix16(n,digits=0)
	.=""
	while(digits-->0 || n)
		var/d=n&15
		.="[d>=10?ascii2text(d+55):d][.]"
		n>>=4

proc/hex2num(txt)
	.=0
	for(var/i=1,i<=length(txt),++i)
		var/ch=text2ascii(txt,i)
		if(ch>=48 && ch<58) .+=ch-48
		else if(ch>=65 && ch<=70) .+=ch-55
		else if(ch>=97 && ch<=102) .+=ch-87
		else return
		.*=16

proc/rgb2html(r,g,b)
	return "#[Radix16(r,2)][Radix16(g,2)][Radix16(b,2)]"

icolor
	var{r;g;b;HTML;tmp/icoloricon/firsticon}

	New(_r,_g,_b)
		..()
		r=_r;g=_g;b=_b;HTML=rgb2html(r,g,b)

	proc/RGB()
		return rgb(r,g,b)

	proc/RGBinverse()
		return rgb(255-r,255-g,255-b)

	proc/GetIcon(ic,inverse,highlight_icon)
		var/icoloricon/ci
		var/icoloricon/cp
		for(ci=firsticon,ci,ci=ci.next)
			if(ci.original==ic) break
			cp=ci
		if(!ci) ci=new(src,ic,inverse,highlight_icon)
		else if(cp)
			// rearrange the list to put this icon first
			cp.next=ci.next
			ci.next=firsticon
			firsticon=ci
			ci.Extend()
		return ci.icon


icoloricon
	var/icolor/color
	var/original
	var/icon
	var/tmp/icoloricon/next
	var/expire=600		// expire after 1 minute

	New(icolor/C,ic,inverse,highlight_icon)
		..()
		color=C
		next=C.firsticon
		C.firsticon=src
		original=ic
		var/icon/i
		if(ic) i=new(ic)
		if(i)
			if(inverse)
				i.Blend(C.RGBinverse(),ICON_MULTIPLY)
				i.Blend(C.RGB(),ICON_ADD)
			else
				i.Blend(C.RGB(),ICON_MULTIPLY)
			if(highlight_icon) i.Blend(highlight_icon,ICON_ADD)
		icon=i
		if(expire>0)
			expire+=world.time
			Expire()

	proc/Extend()
		if(initial(expire)>0) expire=world.time+initial(expire)

	proc/Expire()
		if(world.time>=expire) del(src)
		else
			var/spawntime=expire-world.time+1
			spawn(spawntime+rand(0,spawntime)) Expire()

	Del()
		var/icoloricon/cur
		var/icoloricon/prev
		for(cur=color.firsticon,cur!=src,cur=cur.next) prev=cur
		if(prev) prev.next=next
		else color.firsticon=next
		..()

proc/GetColor(r,g,b)
	var/icolor/c
	if(istext(r) && !g && !b)
		if(findtext(r,"#")!=1) r="#[r]"
		b=hex2num(copytext(r,6))
		g=hex2num(copytext(r,4,6))
		r=hex2num(copytext(r,2,4))
	for(c) if(c.r==r && c.g==g && c.b==b) return c
	c=new(r,g,b)
	return c

var/tmp/list/iconopcache=new

proc/GetOperatedIcon(ic,optype,aux)
	var/iconop/io
	var/iconop/ip
	for(io=iconopcache[optype],io,io=io.next)
		if(io.original==ic && io.aux==aux) break
		ip=io
	if(!io)
		var/list/newargs=args.Copy()
		newargs.Cut(2,3)
		io=new optype(arglist(newargs))
		del(newargs)
	else if(ip)
		// rearrange the list to put this first
		ip.next=io.next
		io.next=iconopcache[optype]
		iconopcache[optype]=io
		io.Extend()
	return io.icon

iconop
	var/original	// original icon
	/*
		aux is a unique key (may be a number) telling ops of the same type
		apart. For example it might be a direction for an operation that
		requires a direction, It is not necessary to use aux for anything;
		it only exists for convenience.
	 */
	var/aux
	var/icon		// modified icon

	// The expiration time is important, so BYOND doesn't get cluttered up
	var/expire=600	// expires after 1 minute

	// linked list to other icons
	var/tmp/iconop/next

	/*
		This proc does not support named arguments. It should use args in exactly
		the same order you pass them to GetOperatedIcon(), except that the type
		won't be included as the second argument.
	 */
	New(ic,a)
		..()
		original=ic
		aux=a
		icon=Operate(arglist(args))
		next=iconopcache[type]
		iconopcache[type]=src
		if(expire>0)
			expire+=world.time
			Expire()

	proc/Extend()
		if(initial(expire)>0) expire=world.time+initial(expire)

	proc/Expire()
		if(world.time>=expire) del(src)
		else
			var/spawntime=expire-world.time+1
			spawn(spawntime+rand(0,spawntime)) Expire()

	Del()
		var/iconop/io
		var/iconop/ip
		for(io=iconopcache[type],io && io!=src,io=io.next) ip=io
		if(ip) ip.next=next
		else if(next) iconopcache[type]=next
		else iconopcache-=type
		..()

	/*
		This proc does not support named arguments. It should use args in exactly
		the same order you pass them to New(). The first argument should always be
		the original icon, with others optional as you wish. You are expected to
		override this proc in sub-types like /iconop/night and so on, and return
		the modified icon. Both the original and the modified version can be an
		/icon or a regular icon file; your choice.
	 */
	proc/Operate(ic,a)
		return ic
