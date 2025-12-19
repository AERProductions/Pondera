// Steel Tools Unequip Handlers
// SPX (Steel Pickaxe) unequip - goes after PX unequip, before GV
if (typi=="SPX" && twohanded==1)
	if(usr.SPXequipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SPXequipped!=0)
		usr << "You holster the steel pickaxe."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 7
		return

// SHH (Steel Hammer) unequip
if (typi=="SHH" && twohanded==0)
	if(usr.SHHequipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SHHequipped!=0)
		usr << "You stow the steel hammer."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.SHHequipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 4
		return

// SSH (Steel Shovel) unequip
if (typi=="SSH" && twohanded==1)
	if(usr.SSHequipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SSHequipped!=0)
		usr << "You holster the steel shovel."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.SSHequipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 7
		return

// SHO (Steel Hoe) unequip
if (typi=="SHO" && twohanded==1)
	if(usr.SHOequipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SHOequipped!=0)
		usr << "You holster the steel hoe."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.SHOequipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 7
		return

// SSH2 (Steel Sickle) unequip
if (typi=="SSH2" && twohanded==0)
	if(usr.SSH2equipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SSH2equipped!=0)
		usr << "You stow the steel sickle."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.SSH2equipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 4
		return

// SCH (Steel Chisel) unequip
if (typi=="SCH" && twohanded==0)
	if(usr.SCHequipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SCHequipped!=0)
		usr << "You stow the steel chisel."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.SCHequipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 4
		return

// SFI (Steel File) unequip
if (typi=="SFI" && twohanded==0)
	if(usr.SFIequipped==0)
		usr << "<font color = teal>You don't have [src.name] equipped!"
	else if(usr.SFIequipped!=0)
		usr << "You stow the steel file."
		src.suffix = ""
		usr.Wequipped = 0
		usr.Sequipped = 0
		usr.LSequipped = 0
		usr.AXequipped = 0
		usr.WHequipped = 0
		usr.JRequipped = 0
		usr.FPequipped = 0
		usr.PXequipped = 0
		usr.SPXequipped = 0
		usr.SHequipped = 0
		usr.HMequipped = 0
		usr.SKequipped = 0
		usr.HOequipped = 0
		usr.CKequipped = 0
		usr.FLequipped = 0
		usr.PYequipped = 0
		usr.OKequipped = 0
		usr.SHMequipped = 0
		usr.UPKequipped = 0
		usr.CHequipped = 0
		usr.TWequipped = 0
		usr.FIequipped = 0
		usr.SWequipped = 0
		usr.WSequipped = 0
		usr.SFIequipped = 0
		usr.tempdamagemin -= src.DamageMin
		usr.tempdamagemax -= src.DamageMax
		var/mob/players/M = usr
		if(M.char_class=="Smithy")
			M.attackspeed = 4
		return
