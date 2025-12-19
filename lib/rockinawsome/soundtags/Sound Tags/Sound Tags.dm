#ifdef __MAIN__
#include "demo.dm"
#include "demo.dmi"
#include "demo.dmm"
#include "CAW.wav"
#include "piano.wav"
#endif




/*
By Adam R. Turner aka Rockinawsome

How it works:

The example below demonstrates how to keep a player from hearing the sound of rain if he or she is indoors

if(src.soundtags["rain"])
	src.channel_tracker.Play(src.soundtags["rain"])

The idea is that these sound tags indicate what a player should hear in a passive manner, meaning other things in the game world control when
the sound tag is played.

Sound tags are also capable of transmitting to multiple players, and modify BYOND's sound system a little bit.

sound.repeat now repeats a number of times, once if 0, or infinitly if -1
This is different to BYOND's system, which merely uses 1 or 0 to indicate playing once, or playing infinitly.

sound.wait now waits a duration before interupting the current channel, unless specified 0 (wait for clear channel) or -1 (interupt immediately).
This is different to BYOND's system, which merely uses 1 or 0 to indicate interupting the current channel, or waiting for it to clear.

If L4OPEN is TRUE, then the code will attempt to find an open channel before playing.
If L4OPEN is TRUE and the sound tag's channel is specified -1, then L4 will look for any open channel, instead of trying the channel specified first.



*/



channel_tracker
	var/list/channels_available=list()
	var/list/channels_repeats=list()

	proc/FindOpenChannel()
		for(var/X in channels_available)
			if(X==TRUE)
				return(X)
	proc/ChangeChanRepeatNum(var/chan="",var/num=0,var/list/who)
		if(who==null)
			who=list(src)
		for(var/atom/X in who)
			X.channel_tracker.channels_repeats[chan]=num


	proc/StopChan(var/chan="",var/list/who) //stop a sound
		if(who==null)
			who=list(src)
		for(var/atom/X in who)
			X<<sound(null,,,0)
			X.channel_tracker.channels_repeats[chan]=0


	proc/Play(var/soundtag/ST,var/list/who)
		if(!ST) return FALSE
		if(!ST.where) return FALSE
		var/sound/S = sound(ST.where,0,ST.wait,ST.channel,ST.volume)
		S.falloff=ST.falloff
		S.x=ST.x
		S.y=ST.y
		S.z=ST.z
		if(ST.wait==-1) //just change from soundtag format to sound format
			ST.wait=1
		else if(ST.wait>0)
			sleep(ST.wait)
			ST.wait=1
		if(who==null)
			who=list(ST.host)
		if(ST.repeat==-1)
			ST.repeat=1
			for(var/atom/X in who)
				S = sound(ST.where,0,ST.wait,ST.channel,ST.volume)
				X<<S
		else if(ST.repeat!=0)
			while(ST.repeat>0)
				if(ST.L4OPEN&&ST.channel!=-1)
					for(var/atom/X in who)
						if(X.channel_tracker.channels_available["[ST.channel]"]==FALSE) //check specified channel first
							S = sound(ST.where,0,ST.wait,X.channel_tracker.FindOpenChannel(),ST.volume)
							X<<S
						else
							S = sound(ST.where,0,ST.wait,ST.channel,ST.volume)
							X<<S
				else
					for(var/atom/X in who)
						S = sound(ST.where,0,ST.wait,ST.channel,ST.volume)
						X<<S
				ST.repeat--
				sleep(0)
		else
			for(var/atom/X in who)
				S = sound(ST.where,0,ST.wait,ST.channel,ST.volume)
				X<<S
		return TRUE


	New()
		..()
		for(var/i=0,i<1024,i++)
			channels_available.Add("[i]"=TRUE)
			channels_repeats.Add("[i]"=0)

atom/var/channel_tracker/channel_tracker=new()



atom/var/list/soundtags=list()


soundtag
	var/channel=0
	var/repeat=0 //repeat -1 = repeat indefinitly, repeat 1 = repeat 1 times, repeat 2 = 2 times, etc.
	var/volume=75
	var/wait=0 //unlike wait in sound proc, this should wait a number of seconds before interupting, or if -1, interupt
	var/L4OPEN = FALSE //look for open channel
	var/priority=0
	var/falloff=0
	var/atom/host = null //who/what this belongs to
	var/where
	var/x=0
	var/y=0
	var/z=0
	New(atom/_host,_where,_name,_channel,_volume,_repeat,_wait,_priority,_falloff,_x,_y,_z,_L4OPEN)
		if(!_host)
			world.log<<"[src] A sound tag was created with no host. Please specify a host."
		else
			src.host=_host
			_name = (_name!="") ? _name : _host.soundtags.len //if it doesn't have a name, give it a number
			_host.soundtags.Add("[_name]")
			_host.soundtags[_name]=src
		if(!_where)
			world.log<<"A sound tag was created with no file location. Please specify a file location for the sound file."
		else
			src.where=_where
		if(!_host||!where)
			del src
		if(_volume)
			src.volume=_volume
		if(_repeat)
			src.repeat=_repeat
		if(_wait)
			src.wait=_wait
		if(_priority)
			src.priority=_priority
		if(!_L4OPEN)
			src.L4OPEN=_L4OPEN
		if(_x)
			src.x=_x
		if(_y)
			src.y=_y
		if(_z)
			src.z=_z
		if(_priority)
			src.priority=_priority
		if(!_L4OPEN)
			src.L4OPEN=_L4OPEN

