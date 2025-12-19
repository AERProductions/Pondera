var/list/st_env_presets = list("do not change environment", "generic", "paddedcell", "room", \
		"bathroom", "livingroom", "stoneroom", "auditorium", "concerthall", "cave", "arena", \
		"hangar", "carpetted hallway", "hallway", "stone corridor", "alley", "forest", "city", \
		"mountains", "quarry", "plain", "parkinglot", "sewerpipe", "underwater", "drugged", \
		"dizzy", "psychotic")

sound
	Topic(href, hlist[])
		if(hlist["chng"])
			switch(hlist["chng"])
				if("change")
					var/new_file = input("Select a sound.", "Select a sound.") as null|sound
					if(file == new_file) return
					if(!new_file && (alert("Do you wish to replace this sound with null, \
						or keep the old sound?", "Null sound?", "Keep", "Replace with null")\
						=="Keep")) return
					file = new_file
					st_Display(usr)

				if("customenv")
					environment = list(7.5, 1.0, -1000, -100, 0, 1.49, 0.83, 1.0, -2602, 0.007, \
						200, 0.011, 0.25, 0, 0.25, 0, -5, 5000, 250, 0, 100, 100, \
						FMOD_REVERB_FLAGS_DEFAULT)
					st_Display(usr, "env_1")

				if("echooff")
					echo = null
					st_Display(usr, "echoon")

				if("echoon")
					echo = list(0, 0, 0, 0, 0, 0, 0, 0.25, 1.5, 1, 0, 1, 0, 0, 0, 0, 1, \
						FMOD_REVERB_CHANNELFLAGS_DEFAULT)
					st_Display(usr, "echooff")

				if("play")
					usr << src

				if("presetenv")
					environment = -1
					st_Display(usr, "environment")

				if("stop")
					usr << sound(null, 0, 0, channel)

				if("stopall")
					usr << sound(null, 0, 0, 0)

				else	// not a special chng flag
					var/chng = hlist["chng"]
					if(findtext(chng, "_"))	// a flag or list variable
						var/nmbr = text2num(copytext(chng,findtext(chng,"_")+1))
						switch(copytext(chng,1,findtext(chng,"_")))
							if("ecfl")	// echo flag
								if(!istype(echo,/list))
									st_Display(usr, "echoon")
									return
								if(hlist["val"]=="true")
									echo[18] |= nmbr
								else
									echo[18] &= ~nmbr
							if("ech")	// echo list
								if(!istype(echo,/list))
									st_Display(usr, "echoon")
									return
								echo[nmbr] = text2num(hlist["val"])
							if("enfl")	// environment flag
								if(!istype(environment,/list))
									st_Display(usr, "environment")
									return
								if(hlist["val"]=="true")
									environment[23] |= nmbr
								else
									environment[23] &= ~nmbr
							if("env")	// environment list
								if(!istype(environment,/list))
									st_Display(usr, "environment")
									return
								environment[nmbr] = text2num(hlist["val"])
							if("stat")	// status flag
								if(hlist["val"]=="true")
									status |= nmbr
								else
									status &= ~nmbr
							else
								world << "[copytext(chng,1,findtext(chng,"_"))] - [nmbr]"
					else if(chng == "wait")
						if(hlist["val"]=="true")
							wait = 1
						else
							wait = 0
					else if(chng in vars)	// plain var. update it
						vars[chng] = text2num(hlist["val"])
					else
						usr << "'[chng]' is not a sound var."
		return ..()

	proc/st_Display(mob/M, focus)
		// display the browser control for this sound
		var/html = {"
<HTML><HEAD>
	<TITLE>[file?"[file]":"null sound"]</TITLE>
	<SCRIPT TYPE=text/javascript>
	function chng(X) {
		document.location.href="BYOND://?src=\ref[src]&chng="+X.name+"&val="+X.value;
	}
	function chk(X) {
		document.location.href="BYOND://?src=\ref[src]&chng="+X.name+"&val="+X.checked;
	}
	</SCRIPT>
	<STYLE>
	TH {text-align: right; vertical-align:top;}
	TD {font-size: smaller}
	.divider {background: #CCCCCC; font-size:1%;}
	</STYLE>
</HEAD>
<BODY[focus?" onLoad='[focus].focus();'":""]>
<TABLE BORDER=1 CELLSPACING=0>
	<TR><TH>File</TH>
	<TH>
		[file?"[file]":"null sound"]
		<INPUT TYPE=BUTTON NAME=change VALUE='Change' onClick='chng(this);'>
		<INPUT TYPE=SUBMIT NAME=play VALUE='Play' onClick='chng(this);'>
		<INPUT TYPE=BUTTON NAME=stop VALUE='Stop' onClick='chng(this);'>
		<INPUT TYPE=BUTTON NAME=stopall VALUE='Stop All' onClick='chng(this);'>
	</TH></TR>
	<TR><TH ROWSPAN=2>Channel</TH>
	<TD><INPUT NAME=channel VALUE='[channel]' onChange='chng(this);' SIZE=5> (0 to 1024)</TD></TR>
	<TR><TD>0 indicates play on any channel</TD></TR>

	<TR><TH ROWSPAN=2>Frequency</TH>
	<TD><INPUT NAME=frequency VALUE='[frequency]' onChange='chng(this);' SIZE=5> (-705600 to 705600)\
		</TD></TR>
	<TR><TD>Values between -100 and 100 multiply the current frequency. 0 indicates no change.</TD></TR>

	<TR><TH>Pan</TH>
	<TD><INPUT NAME=pan VALUE='[pan]' onChange='chng(this);' SIZE=5> -100 (full left) to 100 (full \
		right)</TD></TR>

	<TR><TH ROWSPAN=2>Volume</TH>
	<TD><INPUT NAME=volume VALUE='[volume]' onChange='chng(this);' SIZE=5> (0 to 100)</TD></TR>
	<TR><TD>Percentage of full volume.</TD></TR>

	<TR><TH ROWSPAN=2>Priority</TH>
	<TD><INPUT NAME=priority VALUE='[priority]' onChange='chng(this);' SIZE=5> (0 to 100)</TD></TR>
	<TR><TD>High priority sounds take precidence over low priority sounds, if all channels are
	full.</TD></TR>

	<TR><TH>Wait</TH>
	<TD><INPUT TYPE=CHECKBOX NAME=wait onClick='chk(this);'\
		[wait?" CHECKED":""]> wait for channel to finish</TD></TR>

	<TR><TH>Repeat</TH>
	<TD>
		<INPUT TYPE=RADIO NAME=repeat VALUE='0' onClick='chng(this);'[repeat==0?" SELECTED":""]>
			Play once
		<INPUT TYPE=RADIO NAME=repeat VALUE='1' onClick='chng(this);'[repeat==1?" SELECTED":""]>
			Repeat
		<INPUT TYPE=RADIO NAME=repeat VALUE='2' onClick='chng(this);'[repeat==2?" SELECTED":""]>
			Bi-directional repeat
	</TD></TR>

	<TR><TH ROWSPAN=4>Status flags</TH>
	<TD><INPUT TYPE=CHECKBOX NAME=stat_16 onClick='chk(this);'\
		[status&SOUND_UPDATE?" CHECKED":""]> Update playing sound (SOUND_UPDATE)</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=stat_2 onClick='chk(this);'\
		[status&SOUND_PAUSED?" CHECKED":""]> Paused (SOUND_PAUSE)</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=stat_1 onClick='chk(this);'\
		[status&SOUND_MUTE?" CHECKED":""]> Mute (SOUND_MUTE)</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=stat_4 onClick='chk(this);'\
		[status&SOUND_STREAM?" CHECKED":""]> Create as stream (SOUND_STREAM)</TD></TR>

	<TR><TD COLSPAN=2 CLASS=divider>&nbsp;</TD></TR>

	<TR><TH>3D</TH>
	<TD><b>X:</b> <INPUT NAME=x VALUE='[x]' onChange='chng(this);' SIZE=2>
	<b>Y:</b> <INPUT NAME=y VALUE='[y]' onChange='chng(this);' SIZE=2>
	<b>Z:</b> <INPUT NAME=z VALUE='[z]' onChange='chng(this);' SIZE=2></TD></TR>

	<TR><TH ROWSPAN=2>Falloff</TH>
	<TD><INPUT NAME=falloff VALUE='[falloff]' onChange='chng(this);'></TD></TR>
	<TR><TD>Falloff is the distance at which 3D sounds begin to attenuante, and determines the
		rate at which they attenuate.</TD></TR>"}

		if(istype(environment, /list))
			var/env_flags = environment[23]
			html += {"
	<TR><TD COLSPAN=2 CLASS=divider>&nbsp;</TD></TR>

	<TR><TH>Custom Environment</TH>
		<TD><INPUT TYPE=BUTTON NAME=presetenv VALUE='Preset' onClick='chng(this);'> For details
		about these variables, see the EAX2 (and higher) documentation at
		<a href='http://developer.creative.com/' target=_new>http://developer.creative.com/</a>.</TD>
	</TR>

	<TR><TH ROWSPAN=2>Env Size</TH>
		<TD><INPUT NAME=env_1 VALUE='[environment[1]]' onChange='chng(this);' SIZE=5>
		(1.0 to 100.0) default = 7.5</TD>
	</TR>
	<TR><TD>environment size in meters</TD></TR>

	<TR><TH ROWSPAN=2>Env Diffusion</TH>
		<TD><INPUT NAME=env_2 VALUE='[environment[2]]' onChange='chng(this);' SIZE=5>
		(0.0 to 1.0) default = 1.0</TD>
	</TR>
	<TR><TD>environment diffusion</TD></TR>

	<TR><TH ROWSPAN=2>Room</TH>
		<TD><INPUT NAME=env_3 VALUE='[environment[3]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = -1000</TD>
	</TR>
	<TR><TD>room effect level at mid frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Room HF</TH>
		<TD><INPUT NAME=env_4 VALUE='[environment[4]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = -100</TD>
	</TR>
	<TR><TD>room effect level at high frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Room LF</TH>
		<TD><INPUT NAME=env_5 VALUE='[environment[5]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>room effect level at low frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Decay Time</TH>
		<TD><INPUT NAME=env_6 VALUE='[environment[6]]' onChange='chng(this);' SIZE=5>
		(0.1 to 20.0) default = 1.49</TD>
	</TR>
	<TR><TD>reverbration decay time at mid frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Decay HF Ratio</TH>
		<TD><INPUT NAME=env_7 VALUE='[environment[7]]' onChange='chng(this);' SIZE=5>
		(0.1 to 2.0) default = 0.83</TD>
	</TR>
	<TR><TD>high frequency to mid frequency decay time ratio</TD></TR>

	<TR><TH ROWSPAN=2>Decay LF Ratio</TH>
		<TD><INPUT NAME=env_8 VALUE='[environment[8]]' onChange='chng(this);' SIZE=5>
		(0.1 to 2.0) default = 1.0</TD>
	</TR>
	<TR><TD>low frequency to mid frequency decay time ratio</TD></TR>

	<TR><TH ROWSPAN=2>Reflections</TH>
		<TD><INPUT NAME=env_9 VALUE='[environment[9]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 1000) default = -2602</TD>
	</TR>
	<TR><TD>early reflections level relative to room effect</TD></TR>

	<TR><TH ROWSPAN=2>Reflections Delay</TH>
		<TD><INPUT NAME=env_10 VALUE='[environment[10]]' onChange='chng(this);' SIZE=5>
		(0.0 to 0.3) default = 0.007</TD>
	</TR>
	<TR><TD>initial reflection delay time</TD></TR>

	<TR><TH ROWSPAN=2>Reverb</TH>
		<TD><INPUT NAME=env_11 VALUE='[environment[11]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 2000) default = 200</TD>
	</TR>
	<TR><TD>late reverbration level relative to room effect</TD></TR>

	<TR><TH ROWSPAN=2>Reverb Delay</TH>
		<TD><INPUT NAME=env_12 VALUE='[environment[12]]' onChange='chng(this);' SIZE=5>
		(0.0 to 0.1) default = 0.011</TD>
	</TR>
	<TR><TD>late reverbration delay time relative to initial reflection</TD></TR>

	<TR><TH>Echo Time</TH>
		<TD><INPUT NAME=env_13 VALUE='[environment[13]]' onChange='chng(this);' SIZE=5>
		(0.075 to 0.25) default = 0.25</TD>
	</TR>

	<TR><TH>Echo Depth</TH>
		<TD><INPUT NAME=env_14 VALUE='[environment[14]]' onChange='chng(this);' SIZE=5>
		(0.0 to 1.0) default = 0.0</TD>
	</TR>

	<TR><TH>Modulation Time</TH>
		<TD><INPUT NAME=env_15 VALUE='[environment[15]]' onChange='chng(this);' SIZE=5>
		(0.04 to 4.0) default = 0.25</TD>
	</TR>

	<TR><TH>Modulation Depth</TH>
		<TD><INPUT NAME=env_16 VALUE='[environment[16]]' onChange='chng(this);' SIZE=5>
		(0.0 to 1.0) default = 0.0</TD>
	</TR>

	<TR><TH ROWSPAN=2>Air Absorption HF</TH>
		<TD><INPUT NAME=env_17 VALUE='[environment[17]]' onChange='chng(this);' SIZE=5>
		(-100.0 to 0.0) default = -5</TD>
	</TR>
	<TR><TD>change in level per meter at high frequencies</TD></TR>

	<TR><TH ROWSPAN=2>HF Reference</TH>
		<TD><INPUT NAME=env_18 VALUE='[environment[18]]' onChange='chng(this);' SIZE=5>
		(1000.0 to 20000.0) default = 5000</TD>
	</TR>
	<TR><TD>reference high frequency (hz)</TD></TR>

	<TR><TH ROWSPAN=2>LF Reference</TH>
		<TD><INPUT NAME=env_19 VALUE='[environment[19]]' onChange='chng(this);' SIZE=5>
		(20.0 to 1000.0) default = 250</TD>
	</TR>
	<TR><TD>reference low frequency (hz)</TD></TR>

	<TR><TH ROWSPAN=2>Room Rolloff Factor</TH>
		<TD><INPUT NAME=env_20 VALUE='[environment[20]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 0</TD>
	</TR>
	<TR><TD>Scaling factor for 3D sound rolloff or attenuation</TD></TR>

	<TR><TH ROWSPAN=2>Diffusion</TH>
		<TD><INPUT NAME=env_21 VALUE='[environment[21]]' onChange='chng(this);' SIZE=5>
		(0.0 to 100.0) default = 100</TD>
	</TR>
	<TR><TD>Value that controls the echo density in the late reverberation decay</TD></TR>

	<TR><TH ROWSPAN=2>Density</TH>
		<TD><INPUT NAME=env_22 VALUE='[environment[22]]' onChange='chng(this);' SIZE=5>
		(0.0 to 100.0) default = 100</TD>
	</TR>
	<TR><TD>Value that controls the modal density in the late reverberation decay</TD></TR>

	<TR><TH ROWSPAN=8>Flags</TH>
	<TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_DECAYTIMESCALE] onClick='chk(this);'\
		[env_flags&FMOD_REVERB_FLAGS_DECAYTIMESCALE?" CHECKED":""]>
		Env Size affects reverberation decay time ([FMOD_REVERB_FLAGS_DECAYTIMESCALE])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_REFLECTIONSSCALE] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_REFLECTIONSSCALE?" CHECKED":""]>
		Env Size affects reflection level ([FMOD_REVERB_FLAGS_REFLECTIONSSCALE])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_REFLECTIONSDELAYSCALE] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_REFLECTIONSDELAYSCALE?" CHECKED":""]>
		Env Size affects reflection delay time ([FMOD_REVERB_FLAGS_REFLECTIONSDELAYSCALE])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_REVERBSCALE] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_REVERBSCALE?" CHECKED":""]>
		Env Size affects reflections level ([FMOD_REVERB_FLAGS_REVERBSCALE])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_REVERBDELAYSCALE] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_REVERBDELAYSCALE?" CHECKED":""]>
		Env Size affects late reverberation delay time ([FMOD_REVERB_FLAGS_REVERBDELAYSCALE])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_DECAYHFLIMIT] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_DECAYHFLIMIT?" CHECKED":""]>
		Air Absorption HF affects DecayHFRatio ([FMOD_REVERB_FLAGS_DECAYHFLIMIT])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_ECHOTIMESCALE] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_ECHOTIMESCALE?" CHECKED":""]>
		Env Size affects echo time ([FMOD_REVERB_FLAGS_ECHOTIMESCALE])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=enfl_[FMOD_REVERB_FLAGS_MODULATIONTIMESCALE] \
		onClick='chk(this);' [env_flags&FMOD_REVERB_FLAGS_MODULATIONTIMESCALE?" CHECKED":""]>
		Env Size affects modulation time ([FMOD_REVERB_FLAGS_MODULATIONTIMESCALE])</TD></TR>"}
		else
			html += {"
	<TR><TH ROWSPAN=2>Preset Environment</TH>
	<TD><SELECT NAME=environment onChange='chng(this);'>"}
			var/val = -1
			for(var/preset in st_env_presets)
				html += "<OPTION VALUE='[val]'[environment==val?" SELECTED":""]>[val]) [preset]</OPTION>"
				val++
			html += {"<INPUT TYPE=BUTTON NAME=customenv VALUE='Custom' onClick='chng(this);'>
	</TD></TR>
	<TR><TD>Numeric environment values indicate one of the environment presets. -1 indicates no
		change.</TD></TR>"}

		if(istype(echo, /list))
			var/ech_flags = echo[18]
			html += {"
	<TR><TD COLSPAN=2 CLASS=divider>&nbsp;</TD></TR>

	<TR><TH>Echo</TH>
	<TD><INPUT TYPE=BUTTON NAME=echooff VALUE='Deactivate' onClick='chng(this);'>
	</TD></TR>

	<TR><TH ROWSPAN=2>Direct</TH>
		<TD><INPUT NAME=ech_1 VALUE='[echo[1]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 1000) default = 0</TD>
	</TR>
	<TR><TD>direct path level at low and mid frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Direct HF</TH>
		<TD><INPUT NAME=ech_2 VALUE='[echo[2]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>direct path level at high frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Room</TH>
		<TD><INPUT NAME=ech_3 VALUE='[echo[3]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 1000) default = 0</TD>
	</TR>
	<TR><TD>room effect level at low and mid frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Room HF</TH>
		<TD><INPUT NAME=ech_4 VALUE='[echo[4]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>relative room effect level at high frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Obstruction</TH>
		<TD><INPUT NAME=ech_5 VALUE='[echo[5]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>main obstruction control (attenuation at high frequencies)</TD></TR>

	<TR><TH ROWSPAN=2>Obstruction LF Ratio</TH>
		<TD><INPUT NAME=ech_6 VALUE='[echo[6]]' onChange='chng(this);' SIZE=5>
		(0.0 to 1.0) default = 0</TD>
	</TR>
	<TR><TD>obstruction low-frequency level relative to main control</TD></TR>

	<TR><TH ROWSPAN=2>Occlusion</TH>
		<TD><INPUT NAME=ech_7 VALUE='[echo[7]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>main occlusion control (attenuation at high frequencies)</TD></TR>

	<TR><TH ROWSPAN=2>Occlusion LF Ratio</TH>
		<TD><INPUT NAME=ech_8 VALUE='[echo[8]]' onChange='chng(this);' SIZE=5>
		(0.0 to 1.0) default = 0.25</TD>
	</TR>
	<TR><TD>occlusion low-frequency level relative to main control</TD></TR>

	<TR><TH ROWSPAN=2>Occlusion Room Ratio</TH>
		<TD><INPUT NAME=ech_9 VALUE='[echo[9]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 1.5</TD>
	</TR>
	<TR><TD>relative occlusion control for room effect</TD></TR>

	<TR><TH ROWSPAN=2>Occlusion Direct Ratio</TH>
		<TD><INPUT NAME=ech_10 VALUE='[echo[10]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 1</TD>
	</TR>
	<TR><TD>relative occlusion control for direct path</TD></TR>

	<TR><TH ROWSPAN=2>Exclusion</TH>
		<TD><INPUT NAME=ech_11 VALUE='[echo[11]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>main exclusion control (attenuation at high frequencies)</TD></TR>

	<TR><TH ROWSPAN=2>Exclusion LF Ratio</TH>
		<TD><INPUT NAME=ech_12 VALUE='[echo[12]]' onChange='chng(this);' SIZE=5>
		(0.0 to 1.0) default = 1</TD>
	</TR>
	<TR><TD>exclusion low-frequency level relative to main control</TD></TR>

	<TR><TH ROWSPAN=2>Outside Volume HF</TH>
		<TD><INPUT NAME=ech_13 VALUE='[echo[13]]' onChange='chng(this);' SIZE=5>
		(integer -10000 to 0) default = 0</TD>
	</TR>
	<TR><TD>outside sound cone level at high frequencies</TD></TR>

	<TR><TH ROWSPAN=2>Doppler Factor</TH>
		<TD><INPUT NAME=ech_14 VALUE='[echo[14]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 0</TD>
	</TR>
	<TR><TD>like DS3D flDopplerFactor but per source </TD></TR>

	<TR><TH ROWSPAN=2>Rolloff Factor</TH>
		<TD><INPUT NAME=ech_15 VALUE='[echo[15]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 0</TD>
	</TR>
	<TR><TD>like DS3D flRolloffFactor but per source </TD></TR>

	<TR><TH ROWSPAN=2>Room Rolloff Factor</TH>
		<TD><INPUT NAME=ech_16 VALUE='[echo[16]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 0</TD>
	</TR>
	<TR><TD>like DS3D flRolloffFactor but for room effect</TD></TR>

	<TR><TH ROWSPAN=2>Air Absorption Factor</TH>
		<TD><INPUT NAME=ech_17 VALUE='[echo[17]]' onChange='chng(this);' SIZE=5>
		(0.0 to 10.0) default = 1</TD>
	</TR>
	<TR><TD>multiplies AirAbsorptionHF member of environment</TD></TR>

	<TR><TH ROWSPAN=3>Flags</TH>
	<TD><INPUT TYPE=CHECKBOX NAME=ecfl_[FMOD_REVERB_CHANNELFLAGS_DIRECTHFAUTO] onClick='chk(this);'\
		[ech_flags&FMOD_REVERB_CHANNELFLAGS_DIRECTHFAUTO?" CHECKED":""]>
		Automatic setting of 'Direct' due to distance from listener \
		([FMOD_REVERB_CHANNELFLAGS_DIRECTHFAUTO])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=ecfl_[FMOD_REVERB_CHANNELFLAGS_ROOMAUTO] onClick='chk(this);'\
		[ech_flags&FMOD_REVERB_CHANNELFLAGS_ROOMAUTO?" CHECKED":""]>
		Automatic setting of 'Room' due to distance from listener \
		([FMOD_REVERB_CHANNELFLAGS_ROOMAUTO])</TD></TR>
	<TR><TD><INPUT TYPE=CHECKBOX NAME=ecfl_[FMOD_REVERB_CHANNELFLAGS_ROOMHFAUTO] onClick='chk(this);'\
		[ech_flags&FMOD_REVERB_CHANNELFLAGS_ROOMHFAUTO?" CHECKED":""]>
		Automatic setting of 'RoomHF' due to distance from listener \
		([FMOD_REVERB_CHANNELFLAGS_ROOMHFAUTO])</TD></TR>"}

		else
			html += {"
	<TR><TH>Echo</TH>
	<TD><INPUT TYPE=BUTTON NAME=echoon VALUE='Activate' onClick='chng(this);'>
	</TD></TR>"}

		html += "</TABLE></BODY></HTML>"

		M << browse(html, "window=snd_\ref[src];size=500x600;")
