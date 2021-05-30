mob/verb
	Maximize()
		set waitfor = 0
		set name=".maximize"
		winset(src, "default", {"
			titlebar=false;
			is-minimized=true;
			"})
		sleep(1)
		winset(src, "default", {"
			is-minimized=false;
			is-maximized=true;
			"})


mob/verb
	Normal()
		set name=".normal"
		winset(src, "default", {"
			titlebar=true;
			is-maximized=false;
			image=/imgs/bckgrnd2.jpg;
			"})


/*
mob/var/talk=0
mob/verb/talk()
    set hidden = 1
    if(usr.talk==1)//if its up
        winshow(src,"Talk",0)//hide it
        usr.talk=0//recognise that it's hidden
    else//otherwise...
        winshow(src,"Talk",1)//show it
        usr.talk=1//recognise that it's showing
*/