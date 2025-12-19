// Steel Tools Equip Handlers
// These are inserted into tools.dm in the Equip verb, before SAX handler
// Pattern: Each handler follows standard tool equip structure with strength check, flag validation, and damage application

// Steel Hammer Equip Handler
if ((typi=="SHH")&&(twohanded==0))
	if (usr.tempstr>=src.strreq)
		if(usr.SHHequipped==2)
			usr << "Unable to use right now."
			return
		else if(usr.SHHequipped==0)
			usr << "You wield the Steel Hammer."
			src.suffix="Equipped"
			usr.Wequipped = 2
			usr.Sequipped = 2
			usr.LSequipped = 2
			usr.AXequipped = 2
			usr.WHequipped = 2
			usr.JRequipped = 2
			usr.FPequipped = 2
			usr.PXequipped = 2
			usr.SPXequipped = 2
			usr.SHequipped = 2
			usr.HMequipped = 2
			usr.SKequipped = 2
			usr.HOequipped = 2
			usr.CKequipped = 2
			usr.FLequipped = 2
			usr.PYequipped = 2
			usr.OKequipped = 2
			usr.SHMequipped = 2
			usr.UPKequipped = 2
			usr.CHequipped = 2
			usr.TWequipped = 2
			usr.FIequipped = 2
			usr.SWequipped = 2
			usr.WSequipped = 2
			usr.SHHequipped = 1
			usr.tempdamagemin += src.DamageMin
			usr.tempdamagemax += src.DamageMax
			var/mob/players/M = usr
			M.attackspeed -= src.wpnspd
			return

// Steel Shovel Equip Handler
if ((typi=="SSH")&&(twohanded==1))
	if (usr.tempstr>=src.strreq)
		if(usr.SSHequipped==2)
			usr << "Unable to use right now."
			return
		else if(usr.SSHequipped==0)
			usr << "You wield the Steel Shovel."
			src.suffix="Equipped"
			usr.Wequipped = 2
			usr.Sequipped = 2
			usr.LSequipped = 2
			usr.AXequipped = 2
			usr.WHequipped = 2
			usr.JRequipped = 2
			usr.FPequipped = 2
			usr.PXequipped = 2
			usr.SPXequipped = 2
			usr.SHequipped = 2
			usr.HMequipped = 2
			usr.SKequipped = 2
			usr.HOequipped = 2
			usr.CKequipped = 2
			usr.FLequipped = 2
			usr.PYequipped = 2
			usr.OKequipped = 2
			usr.SHMequipped = 2
			usr.UPKequipped = 2
			usr.CHequipped = 2
			usr.TWequipped = 2
			usr.FIequipped = 2
			usr.SWequipped = 2
			usr.WSequipped = 2
			usr.SSHequipped = 1
			usr.tempdamagemin += src.DamageMin
			usr.tempdamagemax += src.DamageMax
			var/mob/players/M = usr
			M.attackspeed -= src.wpnspd
			return

// Steel Hoe Equip Handler
if ((typi=="SHO")&&(twohanded==1))
	if (usr.tempstr>=src.strreq)
		if(usr.SHOequipped==2)
			usr << "Unable to use right now."
			return
		else if(usr.SHOequipped==0)
			usr << "You wield the Steel Hoe."
			src.suffix="Equipped"
			usr.Wequipped = 2
			usr.Sequipped = 2
			usr.LSequipped = 2
			usr.AXequipped = 2
			usr.WHequipped = 2
			usr.JRequipped = 2
			usr.FPequipped = 2
			usr.PXequipped = 2
			usr.SPXequipped = 2
			usr.SHequipped = 2
			usr.HMequipped = 2
			usr.SKequipped = 2
			usr.HOequipped = 2
			usr.CKequipped = 2
			usr.FLequipped = 2
			usr.PYequipped = 2
			usr.OKequipped = 2
			usr.SHMequipped = 2
			usr.UPKequipped = 2
			usr.CHequipped = 2
			usr.TWequipped = 2
			usr.FIequipped = 2
			usr.SWequipped = 2
			usr.WSequipped = 2
			usr.SHOequipped = 1
			usr.tempdamagemin += src.DamageMin
			usr.tempdamagemax += src.DamageMax
			var/mob/players/M = usr
			M.attackspeed -= src.wpnspd
			return

// Steel Sickle Equip Handler
if ((typi=="SSH2")&&(twohanded==0))
	if (usr.tempstr>=src.strreq)
		if(usr.SSH2equipped==2)
			usr << "Unable to use right now."
			return
		else if(usr.SSH2equipped==0)
			usr << "You wield the Steel Sickle."
			src.suffix="Equipped"
			usr.Wequipped = 2
			usr.Sequipped = 2
			usr.LSequipped = 2
			usr.AXequipped = 2
			usr.WHequipped = 2
			usr.JRequipped = 2
			usr.FPequipped = 2
			usr.PXequipped = 2
			usr.SPXequipped = 2
			usr.SHequipped = 2
			usr.HMequipped = 2
			usr.SKequipped = 2
			usr.HOequipped = 2
			usr.CKequipped = 2
			usr.FLequipped = 2
			usr.PYequipped = 2
			usr.OKequipped = 2
			usr.SHMequipped = 2
			usr.UPKequipped = 2
			usr.CHequipped = 2
			usr.TWequipped = 2
			usr.FIequipped = 2
			usr.SWequipped = 2
			usr.WSequipped = 2
			usr.SSH2equipped = 1
			usr.tempdamagemin += src.DamageMin
			usr.tempdamagemax += src.DamageMax
			var/mob/players/M = usr
			M.attackspeed -= src.wpnspd
			return

// Steel Chisel Equip Handler
if ((typi=="SCH")&&(twohanded==0))
	if (usr.tempstr>=src.strreq)
		if(usr.SCHequipped==2)
			usr << "Unable to use right now."
			return
		else if(usr.SCHequipped==0)
			usr << "You wield the Steel Chisel."
			src.suffix="Equipped"
			usr.Wequipped = 2
			usr.Sequipped = 2
			usr.LSequipped = 2
			usr.AXequipped = 2
			usr.WHequipped = 2
			usr.JRequipped = 2
			usr.FPequipped = 2
			usr.PXequipped = 2
			usr.SPXequipped = 2
			usr.SHequipped = 2
			usr.HMequipped = 2
			usr.SKequipped = 2
			usr.HOequipped = 2
			usr.CKequipped = 2
			usr.FLequipped = 2
			usr.PYequipped = 2
			usr.OKequipped = 2
			usr.SHMequipped = 2
			usr.UPKequipped = 2
			usr.CHequipped = 2
			usr.TWequipped = 2
			usr.FIequipped = 2
			usr.SWequipped = 2
			usr.WSequipped = 2
			usr.SCHequipped = 1
			usr.tempdamagemin += src.DamageMin
			usr.tempdamagemax += src.DamageMax
			var/mob/players/M = usr
			M.attackspeed -= src.wpnspd
			return

// Steel File Equip Handler
if ((typi=="SFI")&&(twohanded==0))
	if (usr.tempstr>=src.strreq)
		if(usr.SFIequipped==2)
			usr << "Unable to use right now."
			return
		else if(usr.SFIequipped==0)
			usr << "You wield the Steel File."
			src.suffix="Equipped"
			usr.Wequipped = 2
			usr.Sequipped = 2
			usr.LSequipped = 2
			usr.AXequipped = 2
			usr.WHequipped = 2
			usr.JRequipped = 2
			usr.FPequipped = 2
			usr.PXequipped = 2
			usr.SPXequipped = 2
			usr.SHequipped = 2
			usr.HMequipped = 2
			usr.SKequipped = 2
			usr.HOequipped = 2
			usr.CKequipped = 2
			usr.FLequipped = 2
			usr.PYequipped = 2
			usr.OKequipped = 2
			usr.SHMequipped = 2
			usr.UPKequipped = 2
			usr.CHequipped = 2
			usr.TWequipped = 2
			usr.FIequipped = 2
			usr.SWequipped = 2
			usr.WSequipped = 2
			usr.SFIequipped = 1
			usr.tempdamagemin += src.DamageMin
			usr.tempdamagemax += src.DamageMax
			var/mob/players/M = usr
			M.attackspeed -= src.wpnspd
			return
