obj
	items
		tools

			//yeah, this gets pretty wild
			icon = 'dmi/64/creation.dmi'
			var
				//these first vars are for the description of the item

				adds = ""
				adds2 = ""
				of = ""
				adj = ""
				add = 0
				add2 = 0
				//description = ""
				typi
				olditem = 0
				//these vars are for actual variables on the items that affect gameplay
				strreq = 0
				tlvl
				wpnspd = 0
				twohanded// = "[src.twohanded?"Two Handed":"One Handed"]"
				DamageMin = 0
				DamageMax = 0
					//world << "[src.STRbonus] STR [src.SPRTbonus] INT [src.FIREres] FIRE [src.ICEres] ICE [src.WINDres] LIT [src.POISres] POIS [src.EARTHres] DARK"
			//verbs to get items, description, equipping, etc on right click
			//the way i handled the equipping and changing of variables is a little whacked out, i don't like it much, but here it is
			/*verb/Description()
				set popup_menu = 1
				set category = null
				set src in usr
				usr << src.description*/
			//New()
				//stack()
			/*verb
				Description()//This style of description should only be used on Static Items that don't need to reflect variable changes/updates.
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return*/
				/*Get()
					set category=null
					set popup_menu=1
					set src in oview(1)
					//set hidden = 1
					var/mob/players/M = usr
					if(src.type==/obj/items/questitem)
						var/C=0
						var/obj/items/o
						if(M.quest==0)
							for(o as obj in M.contents)
								if(o.type==/obj/items/questitem&&C==0)
									C=1
									return
								else if(o.type==/obj/items/questitem)
									M << "You don't need that"
									return
							if(C==0)
								src.Move(usr, 1)
								return
						else
							M << "You don't need that"
							return
					else
						var/obj/O = src
						set src in oview(1)
						for(O as obj in view(3)) // only people you can SEE
							if(istype(O,/obj))
								src.Move(usr, 1)
								return*/
			verb/QuickEUE()
				set hidden = 1
				if(src.suffix=="Equipped"||src.suffix=="Cannot Use")
					Unequip()
				else
					Equip()

			verb/Equip()//the dual wield fix was removing the multiple tool equipped check, making it singular for the respective tool, and not setting the variables for dual wielding tools (Such as Hammer and Carving Knife or CK and Flint)
				set category=null
				set popup_menu=1
				//set hidden = 1
				set src in usr//changed &&'s to ||'s v
				//if(usr.FIequipped==2 || usr.TWequipped==2 || usr.Wequipped==2 || usr.Sequipped==2 || usr.LSequipped==2 || usr.AXequipped==2 || usr.WHequipped==2 || usr.JRequipped==2 || usr.FPequipped==2 || usr.PXequipped==2 || usr.SHequipped==2 || usr.HMequipped==2 || usr.SKequipped==2 || usr.HOequipped==2 || usr.CKequipped==2 || usr.GVequipped==2 || usr.FLequipped==2 || usr.PYequipped==2 || usr.OKequipped==2 || usr.SHMequipped==2 || usr.UPKequipped==2)
				//if(usr.FIequipped==2 || usr.TWequipped==2 || usr.Wequipped==2 || usr.Sequipped==2 || usr.LSequipped==2 || usr.AXequipped==2 || usr.WHequipped==2 || usr.JRequipped==2 || usr.FPequipped==2 || usr.PXequipped==2 || usr.SHequipped==2 || usr.SKequipped==2 || usr.HOequipped==2 || usr.OKequipped==2 || usr.SHMequipped==2 || usr.UPKequipped==2)
					//src.suffix="Cannot Use"
					//src.Unequip()

					//src.suffix=""
					//usr << "src [src] 2 Blocked tools|CK [usr.CKequipped] HM [usr.HMequipped] CH [usr.CHequipped] PY [usr.PYequipped] FL[usr.FLequipped] FI [usr.FIequipped] TW [usr.TWequipped] W [usr.Wequipped] S [usr.Sequipped] LS [usr.LSequipped] AX [usr.AXequipped] WH [usr.WHequipped] JR [usr.JRequipped] FP [usr.FPequipped] PX [usr.PXequipped] SH [usr.SHequipped] SK [usr.SKequipped] HO[usr.HOequipped] OK [usr.OKequipped] SHM[usr.SHMequipped] UPK [usr.UPKequipped]"

				//usr << "src [src] usr [usr] tools|CK [usr.CKequipped] HM [usr.HMequipped] CH [usr.CHequipped] PY [usr.PYequipped] FL[usr.FLequipped] FI [usr.FIequipped] TW [usr.TWequipped] W [usr.Wequipped] S [usr.Sequipped] LS [usr.LSequipped] AX [usr.AXequipped] WH [usr.WHequipped] JR [usr.JRequipped] FP [usr.FPequipped] PX [usr.PXequipped] SH [usr.SHequipped] SK [usr.SKequipped] HO[usr.HOequipped] OK [usr.OKequipped] SHM[usr.SHMequipped] UPK [usr.UPKequipped]"
				if(typi=="HM"||typi=="CK")//wondering if I need to detect src suffix
					if(usr.HMequipped==1&&usr.CKequipped==3||usr.HMequipped==3&&usr.CKequipped==1)
						//usr << "HM 3 CK 3 fired"
						usr << "You are now Dual Wielding a Hammer and Carving Knife."
						src.suffix="Dual Wield"
						//src.Eqpt=1
						usr.Wequipped = 2
						usr.Sequipped = 2
						usr.LSequipped = 2
						usr.AXequipped = 2
						usr.WHequipped = 2
						usr.JRequipped = 2
						usr.FPequipped = 2
						usr.PXequipped = 2
						usr.SHequipped = 2
						usr.HMequipped = 1
						usr.SKequipped = 2
						usr.HOequipped = 2
						usr.CKequipped = 1
						//usr.GVequipped = 2
						usr.FLequipped = 2
						usr.PYequipped = 2
						usr.OKequipped = 2
						usr.SHMequipped = 2
						usr.UPKequipped = 2
						usr.TWequipped = 2
						usr.FIequipped = 2
						usr.SWequipped = 2
						usr.CHequipped = 2
						usr.WSequipped = 2
						return
				if(typi=="FL"||typi=="PY")
					if(usr.FLequipped==1&&usr.PYequipped==3||usr.FLequipped==3&&usr.PYequipped==1)
						//usr << "FL PY fired"
						usr << "You are now Dual Wielding a Flint and Pyrite."
						src.suffix="Dual Wield"
						usr.Wequipped = 2
						usr.Sequipped = 2
						usr.LSequipped = 2
						usr.AXequipped = 2
						usr.WHequipped = 2
						usr.JRequipped = 2
						usr.FPequipped = 2
						usr.PXequipped = 2
						usr.SHequipped = 2
						usr.HMequipped = 2
						usr.SKequipped = 2
						usr.HOequipped = 2
						usr.CKequipped = 2
						//usr.GVequipped = 2
						usr.FLequipped = 1
						usr.PYequipped = 1
						usr.OKequipped = 2
						usr.SHMequipped = 2
						usr.UPKequipped = 2
						usr.TWequipped = 2
						usr.FIequipped = 2
						usr.SWequipped = 2
						usr.CHequipped = 2
						usr.WSequipped = 2
						return
				if(typi=="FL"||typi=="CK")
					if(usr.FLequipped==1&&usr.CKequipped==3||usr.FLequipped==3&&usr.CKequipped==1)
						//usr << "FL CK fired"
						usr << "You are now Dual Wielding a Carving Knife and Flint."
						src.suffix="Dual Wield"
						usr.Wequipped = 2
						usr.Sequipped = 2
						usr.LSequipped = 2
						usr.AXequipped = 2
						usr.WHequipped = 2
						usr.JRequipped = 2
						usr.FPequipped = 2
						usr.PXequipped = 2
						usr.SHequipped = 2
						usr.HMequipped = 2
						usr.SKequipped = 2
						usr.HOequipped = 2
						usr.CKequipped = 1
						//usr.GVequipped = 2
						usr.FLequipped = 1
						usr.PYequipped = 2
						usr.OKequipped = 2
						usr.SHMequipped = 2
						usr.UPKequipped = 2
						usr.TWequipped = 2
						usr.FIequipped = 2
						usr.SWequipped = 2
						usr.CHequipped = 2
						usr.WSequipped = 2
						return
				if(typi=="HM"&&typi=="CH")
					if(usr.HMequipped==1&&usr.CHequipped==3||usr.HMequipped==3&&usr.CHequipped==1)
						usr << "You are now Dual Wielding a Hammer and Chisel."
						src.suffix="Dual Wield"
						usr.Wequipped = 2
						usr.Sequipped = 2
						usr.LSequipped = 2
						usr.AXequipped = 2
						usr.WHequipped = 2
						usr.JRequipped = 2
						usr.FPequipped = 2
						usr.PXequipped = 2
						usr.SHequipped = 2
						usr.HMequipped = 1
						usr.SKequipped = 2
						usr.HOequipped = 2
						usr.CKequipped = 2
						//usr.GVequipped = 2
						usr.FLequipped = 2
						usr.PYequipped = 2
						usr.OKequipped = 2
						usr.SHMequipped = 2
						usr.UPKequipped = 2
						usr.TWequipped = 2
						usr.FIequipped = 2
						usr.SWequipped = 2
						usr.CHequipped = 1
						usr.WSequipped = 2
						return
					//src.Equip()
					//usr << "<font color = teal>Something is already equipped!"
				if(src.suffix!="Equipped")
					//usr << "src suffix [src.suffix]"
					//usr << "<font color = teal>That's already equipped!"
					//return
				//else
					if ((typi=="LS")&&(twohanded==1))
						if (usr.tempstr>=src.strreq)
							//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
							if(usr.LSequipped==2)
								usr << "Unable to use right now."
								return
							else if(usr.LSequipped==0)
								usr << "You unsheath and wield the Longsword."
								src.suffix="Equipped"
								usr.Wequipped = 2
								usr.Sequipped = 2
								usr.LSequipped = 1
								usr.AXequipped = 2
								usr.WHequipped = 2
								usr.JRequipped = 2
								usr.FPequipped = 2
								usr.PXequipped = 2
								usr.SHequipped = 2
								usr.HMequipped = 2
								usr.SKequipped = 2
								usr.HOequipped = 2
								usr.CKequipped = 2
								//usr.GVequipped = 2
								usr.FLequipped = 2
								usr.PYequipped = 2
								usr.OKequipped = 2
								usr.SHMequipped = 2
								usr.UPKequipped = 2
								usr.TWequipped = 2
								usr.FIequipped = 2
								usr.SWequipped = 2
								usr.CHequipped = 2
								usr.WSequipped = 2
								usr.tempdamagemin += src.DamageMin
								usr.tempdamagemax += src.DamageMax
								var/mob/players/M = usr
								M.attackspeed -= src.wpnspd
								return
							//else
								//usr << "<font color = teal>You have something equipped!"
						else
							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
							return
					else
						if ((typi=="AX")&&(twohanded==1))
							if (usr.tempstr>=src.strreq)
								//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
								if(usr.AXequipped==2)
									usr << "Unable to use right now."
									return
								else if(usr.AXequipped==0)
									usr << "You wield the Axe."
									src.suffix="Equipped"
									usr.Wequipped = 2
									usr.Sequipped = 2
									usr.LSequipped = 2
									usr.AXequipped = 1
									usr.WHequipped = 2
									usr.JRequipped = 2
									usr.FPequipped = 2
									usr.PXequipped = 2
									usr.SHequipped = 2
									usr.HMequipped = 2
									usr.SKequipped = 2
									usr.HOequipped = 2
									usr.CKequipped = 2
									//usr.GVequipped = 2
									usr.FLequipped = 2
									usr.PYequipped = 2
									usr.OKequipped = 2
									usr.SHMequipped = 2
									usr.UPKequipped = 2
									usr.TWequipped = 2
									usr.FIequipped = 2
									usr.SWequipped = 2
									usr.CHequipped = 2
									usr.WSequipped = 2
									usr.tempdamagemin += src.DamageMin
									usr.tempdamagemax += src.DamageMax
									var/mob/players/M = usr
									M.attackspeed -= src.wpnspd
									return
								//else
									//usr << "<font color = teal>You have something equipped!"
							else
								usr << "<font color = teal>You do not meet or exceed the strength requirements!"
								return
						else
							if ((typi=="HM")&&(twohanded==0))
								if (usr.tempstr>=src.strreq)
									//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
									if(usr.HMequipped==3&&usr.CKequipped==1)
										goto HMCK
									if(usr.CKequipped==0&&usr.HMequipped==3)
										usr.HMequipped=0
										src.suffix=""
									if(usr.HMequipped==3&&usr.CHequipped==1)
										goto HMCH
									if(usr.CHequipped==0&&usr.HMequipped==3)
										usr.HMequipped=0
										src.suffix=""
										//src.Unequip()
									else if(usr.HMequipped==2)
										usr << "Unable to use right now."
										return
									else if(usr.HMequipped==0)
										usr << "You wield the Hammer."
										src.suffix="Equipped"
										usr.Wequipped = 2
										usr.Sequipped = 2
										usr.LSequipped = 2
										usr.AXequipped = 2
										usr.WHequipped = 2
										usr.JRequipped = 2
										usr.FPequipped = 2
										usr.PXequipped = 2
										usr.SHequipped = 2
										usr.HMequipped = 1
										usr.SKequipped = 2
										usr.HOequipped = 2
										usr.CKequipped = 3
										//usr.GVequipped = 2
										usr.FLequipped = 2
										usr.PYequipped = 2
										usr.OKequipped = 2
										usr.SHMequipped = 2
										usr.UPKequipped = 2
										usr.CHequipped = 3
										usr.TWequipped = 2
										usr.FIequipped = 2
										usr.SWequipped = 2
										usr.WSequipped = 2
										usr.tempdamagemin += src.DamageMin
										usr.tempdamagemax += src.DamageMax
										var/mob/players/M = usr
										M.attackspeed -= src.wpnspd
										return
									//if (typi=="CK")
									HMCK
									if(usr.HMequipped==3&&usr.CKequipped==1)
										//usr.CKequipped=3
										src.suffix="Equipped"
										//usr << "Hammer equipped - Dual Wield with Carving Knife"
										usr.Wequipped = 2
										usr.Sequipped = 2
										usr.LSequipped = 2
										usr.AXequipped = 2
										usr.WHequipped = 2
										usr.JRequipped = 2
										usr.FPequipped = 2
										usr.PXequipped = 2
										usr.SHequipped = 2
										usr.HMequipped = 1
										usr.SKequipped = 2
										usr.HOequipped = 2
										usr.CKequipped = 1
										//usr.GVequipped = 2
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
										return
									//else if(usr.CKequipped==0&&usr.HMequipped==1)
										//usr << "Carving Knife not equipped for some reason."
										//return
									//if (typi=="CH")
									HMCH
									if(usr.HMequipped==3&&usr.CHequipped==1)
									//usr.CKequipped=3
										src.suffix="Dual Wield"
										//usr << "Chisel equipped - Dual Wield with Hammer"
										usr.Wequipped = 2
										usr.Sequipped = 2
										usr.LSequipped = 2
										usr.AXequipped = 2
										usr.WHequipped = 2
										usr.JRequipped = 2
										usr.FPequipped = 2
										usr.PXequipped = 2
										usr.SHequipped = 2
										usr.HMequipped = 1
										usr.SKequipped = 2
										usr.HOequipped = 2
										usr.CKequipped = 2
										//usr.GVequipped = 2
										usr.FLequipped = 2
										usr.PYequipped = 2
										usr.OKequipped = 2
										usr.SHMequipped = 2
										usr.UPKequipped = 2
										usr.CHequipped = 1
										usr.TWequipped = 2
										usr.FIequipped = 2
										usr.SWequipped = 2
										usr.WSequipped = 2
										return
										//else if(usr.CHequipped==0&&usr.HMequipped==1)
											//usr << "Carving Knife not equipped for some reason."
											//return
								else
									usr << "<font color = teal>You do not meet or exceed the strength requirements!"
									return
							else
								if ((typi=="WH")&&(twohanded==1))
									if (usr.tempstr>=src.strreq)
										//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
										if(usr.WHequipped==2)
											usr << "Unable to use right now."
											return
										else if(usr.WHequipped==0)
											usr << "You wield the Warhammer."
											src.suffix="Equipped"
											usr.Wequipped = 2
											usr.Sequipped = 2
											usr.LSequipped = 2
											usr.AXequipped = 2
											usr.WHequipped = 1
											usr.JRequipped = 2
											usr.FPequipped = 2
											usr.PXequipped = 2
											usr.SHequipped = 2
											usr.HMequipped = 2
											usr.SKequipped = 2
											usr.HOequipped = 2
											usr.CKequipped = 2
											//usr.GVequipped = 2
											usr.FLequipped = 2
											usr.PYequipped = 2
											usr.OKequipped = 2
											usr.SHMequipped = 2
											usr.UPKequipped = 2
											usr.TWequipped = 2
											usr.FIequipped = 2
											usr.SWequipped = 2
											usr.WSequipped = 2
											usr.CHequipped = 2
											usr.tempdamagemin += src.DamageMin
											usr.tempdamagemax += src.DamageMax
											var/mob/players/M = usr
											M.attackspeed -= src.wpnspd
											return
										//else
											//usr << "<font color = teal>You have something equipped!"
									else
										usr << "<font color = teal>You do not meet or exceed the strength requirements!"
										return
								else
									if ((typi=="JR")&&(twohanded==1))
										if (usr.tempstr>=src.strreq)
											//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
											if(usr.JRequipped==2)
												usr << "Unable to use right now."
												return
											else if(usr.JRequipped==0)
												usr << "You grasp the Jar."
												src.suffix="Equipped"
												usr.Wequipped = 2
												usr.Sequipped = 2
												usr.LSequipped = 2
												usr.AXequipped = 2
												usr.WHequipped = 2
												usr.JRequipped = 1
												usr.FPequipped = 2
												usr.PXequipped = 2
												usr.SHequipped = 2
												usr.HMequipped = 2
												usr.SKequipped = 2
												usr.HOequipped = 2
												usr.CKequipped = 2
												//usr.GVequipped = 2
												usr.FLequipped = 2
												usr.PYequipped = 2
												usr.OKequipped = 2
												usr.SHMequipped = 2
												usr.UPKequipped = 2
												usr.TWequipped = 2
												usr.FIequipped = 2
												usr.SWequipped = 2
												usr.WSequipped = 2
												usr.CHequipped = 2
												usr.tempdamagemin += src.DamageMin
												usr.tempdamagemax += src.DamageMax
												var/mob/players/M = usr
												M.attackspeed -= src.wpnspd
												return
											//else
												//usr << "<font color = teal>You have something equipped!"
										else
											usr << "<font color = teal>You do not meet or exceed the strength requirements!"
											return
									else
										if ((typi=="SH")&&(twohanded==1))
											if (usr.tempstr>=src.strreq)
												//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
												if(usr.SHequipped==2)
													usr << "Unable to use right now."
													return
												else if(usr.SHequipped==0)
													usr << "You wield the Shovel."
													src.suffix="Equipped"
													usr.Wequipped = 2
													usr.Sequipped = 2
													usr.LSequipped = 2
													usr.AXequipped = 2
													usr.WHequipped = 2
													usr.JRequipped = 2
													usr.FPequipped = 2
													usr.PXequipped = 2
													usr.SHequipped = 1
													usr.HMequipped = 2
													usr.SKequipped = 2
													usr.HOequipped = 2
													usr.CKequipped = 2
													//usr.GVequipped = 2
													usr.FLequipped = 2
													usr.PYequipped = 2
													usr.OKequipped = 2
													usr.SHMequipped = 2
													usr.UPKequipped = 2
													usr.TWequipped = 2
													usr.FIequipped = 2
													usr.SWequipped = 2
													usr.WSequipped = 2
													usr.CHequipped = 2
													usr.tempdamagemin += src.DamageMin
													usr.tempdamagemax += src.DamageMax
													var/mob/players/M = usr
													M.attackspeed -= src.wpnspd
													return
												//else
													//usr << "<font color = teal>You have something equipped!"
											else
												usr << "<font color = teal>You do not meet or exceed the strength requirements!"
												return
										else
											if ((typi=="FP")&&(twohanded==1))
												if (usr.tempstr>=src.strreq)
													//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
													if(usr.FPequipped==2)
														usr << "Unable to use right now."
														return
													else if(usr.FPequipped==0)
														usr << "You wield the Fishing Pole."
														src.suffix="Equipped"
														usr.Wequipped = 2
														usr.Sequipped = 2
														usr.LSequipped = 2
														usr.AXequipped = 2
														usr.WHequipped = 2
														usr.JRequipped = 2
														usr.FPequipped = 1
														usr.PXequipped = 2
														usr.SHequipped = 2
														usr.HMequipped = 2
														usr.SKequipped = 2
														usr.HOequipped = 2
														usr.CKequipped = 2
														//usr.GVequipped = 2
														usr.FLequipped = 2
														usr.PYequipped = 2
														usr.OKequipped = 2
														usr.SHMequipped = 2
														usr.UPKequipped = 2
														usr.TWequipped = 2
														usr.FIequipped = 2
														usr.SWequipped = 2
														usr.WSequipped = 2
														usr.CHequipped = 2
														usr.tempdamagemin += src.DamageMin
														usr.tempdamagemax += src.DamageMax
														var/mob/players/M = usr
														M.attackspeed -= src.wpnspd
														return
													//else
														//usr << "<font color = teal>You have something equipped!"
												else
													usr << "<font color = teal>You do not meet or exceed the strength requirements!"
													return
											else
												if ((typi=="CK")&&(twohanded==0))
													if (usr.tempstr>=src.strreq)
														//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
														if(usr.CKequipped==3&&usr.HMequipped==1)
															goto CKHM
														if(usr.HMequipped==0&&usr.CKequipped==3)
															usr.CKequipped=0
															src.suffix=""
														if(usr.CKequipped==3&&usr.FLequipped==1)
															goto CKFL
														if(usr.FLequipped==0&&usr.CKequipped==3)
															usr.CKequipped=0
															src.suffix=""
															//src.Unequip()
														else if(usr.CKequipped==2)
															usr << "Unable to use right now."
															return
														else if(usr.CKequipped==0)
															usr << "You unsheath and wield the Carving Knife."
															src.suffix="Equipped"
															usr.Wequipped = 2
															usr.Sequipped = 2
															usr.LSequipped = 2
															usr.AXequipped = 2
															usr.WHequipped = 2
															usr.JRequipped = 2
															usr.FPequipped = 2
															usr.PXequipped = 2
															usr.SHequipped = 2
															usr.HMequipped = 3
															usr.SKequipped = 2
															usr.HOequipped = 2
															usr.CKequipped = 1
															//usr.GVequipped = 2
															usr.FLequipped = 3
															usr.PYequipped = 2
															usr.OKequipped = 2
															usr.SHMequipped = 2
															usr.UPKequipped = 2
															usr.TWequipped = 2
															usr.FIequipped = 2
															usr.SWequipped = 2
															usr.WSequipped = 2
															usr.CHequipped = 2
															usr.tempdamagemin += src.DamageMin
															usr.tempdamagemax += src.DamageMax
															var/mob/players/M = usr
															M.attackspeed -= src.wpnspd
															return
														//if (typi=="HM"||typi=="CK")
														CKHM
														if(usr.CKequipped==3&&usr.HMequipped==1)
													//else if(usr.HMequipped==3&&usr.CKequipped==1)
														//usr.HMequipped=3
															src.suffix="Equipped"
															//usr << "Carving Knife equipped - Dual Wield with Hammer"
															usr.Wequipped = 2
															usr.Sequipped = 2
															usr.LSequipped = 2
															usr.AXequipped = 2
															usr.WHequipped = 2
															usr.JRequipped = 2
															usr.FPequipped = 2
															usr.PXequipped = 2
															usr.SHequipped = 2
															usr.HMequipped = 1
															usr.SKequipped = 2
															usr.HOequipped = 2
															usr.CKequipped = 1
															//usr.GVequipped = 2
															usr.FLequipped = 2
															usr.PYequipped = 2
															usr.OKequipped = 2
															usr.SHMequipped = 2
															usr.UPKequipped = 2
															usr.TWequipped = 2
															usr.FIequipped = 2
															usr.SWequipped = 2
															usr.WSequipped = 2
															usr.CHequipped = 2
															return
														//else if(usr.HMequipped==0&&usr.CKequipped==1)
															//usr << "Hammer not equipped for some reason"
															//return
														//if (typi=="HM"||typi=="CK")
														CKFL
														if(usr.CKequipped==3&&usr.FLequipped==1)
													//else if(usr.FLequipped==3&&usr.CKequipped==1)
														//usr.CKequipped=3
															src.suffix="Dual Wield"
															//usr << "Flint equipped - Dual Wield with Carving Knife"
															usr.Wequipped = 2
															usr.Sequipped = 2
															usr.LSequipped = 2
															usr.AXequipped = 2
															usr.WHequipped = 2
															usr.JRequipped = 2
															usr.FPequipped = 2
															usr.PXequipped = 2
															usr.SHequipped = 2
															usr.HMequipped = 2
															usr.SKequipped = 2
															usr.HOequipped = 2
															usr.CKequipped = 1
															//usr.GVequipped = 2
															usr.FLequipped = 1
															usr.PYequipped = 2
															usr.OKequipped = 2
															usr.SHMequipped = 2
															usr.UPKequipped = 2
															usr.CHequipped = 2
															usr.TWequipped = 2
															usr.FIequipped = 2
															usr.SWequipped = 2
															usr.WSequipped = 2
															return
														//else if(usr.FLequipped==0&&usr.CKequipped==1)
															//usr << "Carving Knife not equipped for some reason."
															//return
													else
														usr << "<font color = teal>You do not meet or exceed the strength requirements!"
														return
												else
													if ((typi=="PX")&&(twohanded==1))
														if (usr.tempstr>=src.strreq)
															//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
															if(usr.PXequipped==2)
																usr << "Unable to use right now."
																return
															else if(usr.PXequipped==0)
																usr << "You wield the Pickaxe."
																src.suffix="Equipped"
																usr.Wequipped = 2
																usr.Sequipped = 2
																usr.LSequipped = 2
																usr.AXequipped = 2
																usr.WHequipped = 2
																usr.JRequipped = 2
																usr.FPequipped = 2
																usr.PXequipped = 1
																usr.SHequipped = 2
																usr.HMequipped = 2
																usr.SKequipped = 2
																usr.HOequipped = 2
																usr.CKequipped = 2
																//usr.GVequipped = 2
																usr.FLequipped = 2
																usr.PYequipped = 2
																usr.OKequipped = 2
																usr.SHMequipped = 2
																usr.UPKequipped = 2
																usr.TWequipped = 2
																usr.FIequipped = 2
																usr.SWequipped = 2
																usr.WSequipped = 2
																usr.CHequipped = 2
																usr.tempdamagemin += src.DamageMin
																usr.tempdamagemax += src.DamageMax
																var/mob/players/M = usr
																M.attackspeed -= src.wpnspd
																return
															//else
																//usr << "<font color = teal>You have something equipped!"
														else
															usr << "<font color = teal>You do not meet or exceed the strength requirements!"
															return
													else
														if ((typi=="GV")&&(twohanded==1))
															if (usr.tempstr>=src.strreq)
																//if(/*usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0 && */usr.GVequipped==0/* && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0*/)//testing uncommenting so you can use gloves with everything
																if(usr.GVequipped==2)
																	usr << "Unable to use right now."
																	return
																else if(usr.GVequipped==0)
																	usr << "You wear the Gloves."
																	src.suffix="Equipped"
																	/*usr.Wequipped = 2
																	usr.Sequipped = 2
																	usr.LSequipped = 2
																	usr.AXequipped = 2
																	usr.WHequipped = 2
																	usr.JRequipped = 2
																	usr.FPequipped = 2
																	usr.PXequipped = 2
																	usr.SHequipped = 2
																	usr.HMequipped = 2
																	usr.SKequipped = 2
																	usr.HOequipped = 2
																	usr.CKequipped = 2*/
																	usr.GVequipped = 1
																	/*usr.FLequipped = 2
																	usr.PYequipped = 2
																	usr.OKequipped = 2
																	usr.SHMequipped = 2
																	usr.UPKequipped = 2
																	usr.TWequipped = 2*/
																	usr.tempdamagemin += src.DamageMin
																	usr.tempdamagemax += src.DamageMax
																	var/mob/players/M = usr
																	M.attackspeed -= src.wpnspd
																	return
																//else
																	//usr << "<font color = teal>You must already be wearing gloves!"
															else
																usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																return
														else
															if ((typi=="HO")&&(twohanded==1))
																if (usr.tempstr>=src.strreq)
																	//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																	if(usr.HOequipped==2)
																		usr << "Unable to use right now."
																		return
																	else if(usr.HOequipped==0)
																		usr << "You wield the Hoe."
																		src.suffix="Equipped"
																		usr.Wequipped = 2
																		usr.Sequipped = 2
																		usr.LSequipped = 2
																		usr.AXequipped = 2
																		usr.WHequipped = 2
																		usr.JRequipped = 2
																		usr.FPequipped = 2
																		usr.PXequipped = 2
																		usr.SHequipped = 2
																		usr.HMequipped = 2
																		usr.SKequipped = 2
																		usr.HOequipped = 1
																		usr.CKequipped = 2
																		//usr.GVequipped = 2
																		usr.FLequipped = 2
																		usr.PYequipped = 2
																		usr.OKequipped = 2
																		usr.SHMequipped = 2
																		usr.UPKequipped = 2
																		usr.TWequipped = 2
																		usr.FIequipped = 2
																		usr.SWequipped = 2
																		usr.WSequipped = 2
																		usr.CHequipped = 2
																		usr.tempdamagemin += src.DamageMin
																		usr.tempdamagemax += src.DamageMax
																		var/mob/players/M = usr
																		M.attackspeed -= src.wpnspd
																		return
																	//else
																		//usr << "<font color = teal>You have something equipped!"
																else
																	usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																	return
															else
																if ((typi=="SK")&&(twohanded==0))
																	if (usr.tempstr>=src.strreq)
																		//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																		if(usr.SKequipped==2)
																			usr << "Unable to use right now."
																			return
																		else if(usr.SKequipped==0)
																			usr << "You unsheath and wield the Sickle."
																			src.suffix="Equipped"
																			usr.Wequipped = 2
																			usr.Sequipped = 2
																			usr.LSequipped = 2
																			usr.AXequipped = 2
																			usr.WHequipped = 2
																			usr.JRequipped = 2
																			usr.FPequipped = 2
																			usr.PXequipped = 2
																			usr.SHequipped = 2
																			usr.HMequipped = 2
																			usr.SKequipped = 1
																			usr.HOequipped = 2
																			usr.CKequipped = 2
																			//usr.GVequipped = 2
																			usr.FLequipped = 2
																			usr.PYequipped = 2
																			usr.OKequipped = 2
																			usr.SHMequipped = 2
																			usr.UPKequipped = 2
																			usr.TWequipped = 2
																			usr.FIequipped = 2
																			usr.SWequipped = 2
																			usr.WSequipped = 2
																			usr.CHequipped = 2
																			usr.tempdamagemin += src.DamageMin
																			usr.tempdamagemax += src.DamageMax
																			var/mob/players/M = usr
																			M.attackspeed -= src.wpnspd
																			return
																		//else
																			//usr << "<font color = teal>You have something equipped!"
																	else
																		usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																		return
																else
																	if ((typi=="FL")&&(twohanded==0))
																		if (usr.tempstr>=src.strreq)
																			//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																			if(usr.FLequipped==3&&usr.CKequipped==1)
																				goto FLCK
																			if(usr.CKequipped==0&&usr.FLequipped==3)
																				usr.FLequipped=0
																				src.suffix=""
																			if(usr.FLequipped==3&&usr.PYequipped==1)
																				goto FLPY
																			if(usr.PYequipped==0&&usr.FLequipped==3)
																				usr.FLequipped=0
																				src.suffix=""
																			else if(usr.FLequipped==2)
																				usr << "Unable to use right now."
																				return
																			else if(usr.FLequipped==0)
																				usr << "You hold the Flint."
																				src.suffix="Equipped"
																				usr.Wequipped = 2
																				usr.Sequipped = 2
																				usr.LSequipped = 2
																				usr.AXequipped = 2
																				usr.WHequipped = 2
																				usr.JRequipped = 2
																				usr.FPequipped = 2
																				usr.PXequipped = 2
																				usr.SHequipped = 2
																				usr.HMequipped = 2
																				usr.SKequipped = 2
																				usr.HOequipped = 2
																				usr.CKequipped = 3
																				//usr.GVequipped = 2
																				usr.FLequipped = 1
																				usr.PYequipped = 3
																				usr.OKequipped = 2
																				usr.SHMequipped = 2
																				usr.UPKequipped = 2
																				usr.TWequipped = 2
																				usr.FIequipped = 2
																				usr.SWequipped = 2
																				usr.WSequipped = 2
																				usr.CHequipped = 2
																				usr.tempdamagemin += src.DamageMin
																				usr.tempdamagemax += src.DamageMax
																				var/mob/players/M = usr
																				M.attackspeed -= src.wpnspd
																				return

																			FLPY
																			if(usr.FLequipped==3&&usr.PYequipped==1)
																				//usr.HMequipped=3
																				src.suffix="Dual Wield"
																				//usr << "Flint equipped - Dual Wield with Pyrite"
																				usr.Wequipped = 2
																				usr.Sequipped = 2
																				usr.LSequipped = 2
																				usr.AXequipped = 2
																				usr.WHequipped = 2
																				usr.JRequipped = 2
																				usr.FPequipped = 2
																				usr.PXequipped = 2
																				usr.SHequipped = 2
																				usr.HMequipped = 2
																				usr.SKequipped = 2
																				usr.HOequipped = 2
																				usr.CKequipped = 2
																				//usr.GVequipped = 2
																				usr.FLequipped = 1
																				usr.PYequipped = 1
																				usr.OKequipped = 2
																				usr.SHMequipped = 2
																				usr.UPKequipped = 2
																				usr.TWequipped = 2
																				usr.FIequipped = 2
																				usr.SWequipped = 2
																				usr.WSequipped = 2
																				usr.CHequipped = 2
																				return
																			//else if(usr.PYequipped==0&&usr.FLequipped==1)
																				//usr << "Hammer not equipped for some reason"
																				//return
																			FLCK
																			if(usr.FLequipped==3&&usr.CKequipped==1)
																				//usr.CKequipped=3
																				src.suffix="Dual Wield"
																				//usr << "Flint equipped - Dual Wield with Carving Knife"
																				usr.Wequipped = 2
																				usr.Sequipped = 2
																				usr.LSequipped = 2
																				usr.AXequipped = 2
																				usr.WHequipped = 2
																				usr.JRequipped = 2
																				usr.FPequipped = 2
																				usr.PXequipped = 2
																				usr.SHequipped = 2
																				usr.HMequipped = 2
																				usr.SKequipped = 2
																				usr.HOequipped = 2
																				usr.CKequipped = 1
																				//usr.GVequipped = 2
																				usr.FLequipped = 1
																				usr.PYequipped = 2
																				usr.OKequipped = 2
																				usr.SHMequipped = 2
																				usr.UPKequipped = 2
																				usr.CHequipped = 2
																				usr.TWequipped = 2
																				usr.FIequipped = 2
																				usr.SWequipped = 2
																				usr.WSequipped = 2
																				return
																				//else if(usr.FLequipped==0&&usr.CKequipped==1)
																					//usr << "Carving Knife not equipped for some reason."
																					//return
																			//else
																				//usr << "<font color = teal>You must already have Flint equipped!"
																				//usr << "<font color = teal>You have something equipped!"
																		else
																			usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																			return
																	else
																		if ((typi=="PY")&&(twohanded==0))
																			if (usr.tempstr>=src.strreq)
																				//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																				if(usr.PYequipped==3&&usr.FLequipped==1)
																					goto PYFL
																				if(usr.FLequipped==0&&usr.PYequipped==3)
																					usr.PYequipped=0
																					src.suffix=""
																				else if(usr.PYequipped==2)
																					usr << "Unable to use right now."
																					return
																				else if(usr.PYequipped==0)
																					usr << "You hold the Pyrite."
																					src.suffix="Equipped"
																					usr.Wequipped = 2
																					usr.Sequipped = 2
																					usr.LSequipped = 2
																					usr.AXequipped = 2
																					usr.WHequipped = 2
																					usr.JRequipped = 2
																					usr.FPequipped = 2
																					usr.PXequipped = 2
																					usr.SHequipped = 2
																					usr.HMequipped = 2
																					usr.SKequipped = 2
																					usr.HOequipped = 2
																					usr.CKequipped = 2
																					//usr.GVequipped = 2
																					usr.FLequipped = 3
																					usr.PYequipped = 1
																					usr.OKequipped = 2
																					usr.SHMequipped = 2
																					usr.UPKequipped = 2
																					usr.TWequipped = 2
																					usr.FIequipped = 2
																					usr.SWequipped = 2
																					usr.WSequipped = 2
																					usr.CHequipped = 2
																					usr.tempdamagemin += src.DamageMin
																					usr.tempdamagemax += src.DamageMax
																					var/mob/players/M = usr
																					M.attackspeed -= src.wpnspd
																					return
																				PYFL
																				if(usr.PYequipped==3&&usr.FLequipped==1)
																				//usr.HMequipped=3
																					src.suffix="Dual Wield"
																					//usr << "Flint equipped - Dual Wield with Pyrite"
																					usr.Wequipped = 2
																					usr.Sequipped = 2
																					usr.LSequipped = 2
																					usr.AXequipped = 2
																					usr.WHequipped = 2
																					usr.JRequipped = 2
																					usr.FPequipped = 2
																					usr.PXequipped = 2
																					usr.SHequipped = 2
																					usr.HMequipped = 2
																					usr.SKequipped = 2
																					usr.HOequipped = 2
																					usr.CKequipped = 2
																					//usr.GVequipped = 2
																					usr.FLequipped = 1
																					usr.PYequipped = 1
																					usr.OKequipped = 2
																					usr.SHMequipped = 2
																					usr.UPKequipped = 2
																					usr.TWequipped = 2
																					usr.FIequipped = 2
																					usr.SWequipped = 2
																					usr.WSequipped = 2
																					usr.CHequipped = 2
																					return
																				//else
																					//usr << "<font color = teal>You have something equipped!"
																			else
																				usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																				return
																		else
																			if ((typi=="OK")&&(twohanded==0))
																				if (usr.tempstr>=src.strreq)
																					//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																					if(usr.OKequipped==2)
																						usr << "Unable to use right now."
																						return
																					else if(usr.OKequipped==0)
																						usr << "You unsheath and wield the Obsidian Knife."
																						src.suffix="Equipped"
																						usr.Wequipped = 2
																						usr.Sequipped = 2
																						usr.LSequipped = 2
																						usr.AXequipped = 2
																						usr.WHequipped = 2
																						usr.JRequipped = 2
																						usr.FPequipped = 2
																						usr.PXequipped = 2
																						usr.SHequipped = 2
																						usr.HMequipped = 2
																						usr.SKequipped = 2
																						usr.HOequipped = 2
																						usr.CKequipped = 2
																						//usr.GVequipped = 2
																						usr.FLequipped = 2
																						usr.PYequipped = 2
																						usr.OKequipped = 1
																						usr.SHMequipped = 2
																						usr.UPKequipped = 2
																						usr.TWequipped = 2
																						usr.FIequipped = 2
																						usr.SWequipped = 2
																						usr.WSequipped = 2
																						usr.CHequipped = 2
																						usr.tempdamagemin += src.DamageMin
																						usr.tempdamagemax += src.DamageMax
																						var/mob/players/M = usr
																						M.attackspeed -= src.wpnspd
																						return
																					//else
																						//usr << "<font color = teal>You have something equipped!"
																				else
																					usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																					return
																			else
																				if ((typi=="SHM")&&(twohanded==0))
																					if (usr.tempstr>=src.strreq)
																						//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																						if(usr.SHMequipped==2)
																							usr << "Unable to use right now."
																							return
																						else if(usr.SHMequipped==0)
																							usr << "You wield the Stone Hammer."
																							src.suffix="Equipped"
																							usr.Wequipped = 2
																							usr.Sequipped = 2
																							usr.LSequipped = 2
																							usr.AXequipped = 2
																							usr.WHequipped = 2
																							usr.JRequipped = 2
																							usr.FPequipped = 2
																							usr.PXequipped = 2
																							usr.SHequipped = 2
																							usr.HMequipped = 2
																							usr.SKequipped = 2
																							usr.HOequipped = 2
																							usr.CKequipped = 2
																							//usr.GVequipped = 2
																							usr.FLequipped = 2
																							usr.PYequipped = 2
																							usr.OKequipped = 2
																							usr.SHMequipped = 1
																							usr.UPKequipped = 2
																							usr.TWequipped = 2
																							usr.FIequipped = 2
																							usr.SWequipped = 2
																							usr.WSequipped = 2
																							usr.CHequipped = 2
																							usr.tempdamagemin += src.DamageMin
																							usr.tempdamagemax += src.DamageMax
																							var/mob/players/M = usr
																							M.attackspeed -= src.wpnspd
																							return
																						//else
																							//usr << "<font color = teal>You have something equipped!"
																					else
																						usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																						return
																				else
																					if ((typi=="UPK")&&(twohanded==1))
																						if (usr.tempstr>=src.strreq)
																							//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																							if(usr.UPKequipped==2)
																								usr << "Unable to use right now."
																								return
																							else if(usr.UPKequipped==0)
																								usr << "You wield the Ueik Pickaxe."
																								src.suffix="Equipped"
																								usr.Wequipped = 2
																								usr.Sequipped = 2
																								usr.LSequipped = 2
																								usr.AXequipped = 2
																								usr.WHequipped = 2
																								usr.JRequipped = 2
																								usr.FPequipped = 2
																								usr.PXequipped = 2
																								usr.SHequipped = 2
																								usr.HMequipped = 2
																								usr.SKequipped = 2
																								usr.HOequipped = 2
																								usr.CKequipped = 2
																								//usr.GVequipped = 2
																								usr.FLequipped = 2
																								usr.PYequipped = 2
																								usr.OKequipped = 2
																								usr.SHMequipped = 2
																								usr.UPKequipped = 1
																								usr.TWequipped = 2
																								usr.FIequipped = 2
																								usr.SWequipped = 2
																								usr.WSequipped = 2
																								usr.CHequipped = 2
																								usr.tempdamagemin += src.DamageMin
																								usr.tempdamagemax += src.DamageMax
																								var/mob/players/M = usr
																								M.attackspeed -= src.wpnspd
																								return
																							//else
																								//usr << "<font color = teal>You have something equipped!"
																						else
																							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																							return
																					else
																						if ((typi=="TW")&&(twohanded==0))
																							if (usr.tempstr>=src.strreq)
																								//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																								if(usr.TWequipped==2)
																									usr << "Unable to use right now."
																									return
																								else if(usr.TWequipped==0)
																									usr << "You wield the Trowel."
																									src.suffix="Equipped"
																									usr.Wequipped = 2
																									usr.Sequipped = 2
																									usr.LSequipped = 2
																									usr.AXequipped = 2
																									usr.WHequipped = 2
																									usr.JRequipped = 2
																									usr.FPequipped = 2
																									usr.PXequipped = 2
																									usr.SHequipped = 2
																									usr.HMequipped = 2
																									usr.SKequipped = 2
																									usr.HOequipped = 2
																									usr.CKequipped = 2
																									//usr.GVequipped = 2
																									usr.FLequipped = 2
																									usr.PYequipped = 2
																									usr.OKequipped = 2
																									usr.SHMequipped = 2
																									usr.UPKequipped = 2
																									usr.TWequipped = 1
																									usr.FIequipped = 2
																									usr.SWequipped = 2
																									usr.WSequipped = 2
																									usr.CHequipped = 2
																									usr.tempdamagemin += src.DamageMin
																									usr.tempdamagemax += src.DamageMax
																									var/mob/players/M = usr
																									M.attackspeed -= src.wpnspd
																									return
																								//else
																									//usr << "<font color = teal>You have something equipped!"
																							else
																								usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																								return
																						else
																							if ((typi=="weapon")&&(twohanded==0))
																								if (usr.tempstr>=src.strreq)
																									//if(usr.TWequipped==0 && usr.Wequipped==0 /*&& usr.Sequipped==0*/ && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																									if(usr.Wequipped==2)
																										usr << "Unable to use right now."
																										return
																									else if(usr.Wequipped==0)
																										usr << "You wield the [src.name]."
																										src.suffix="Equipped"
																										usr.Wequipped = 1
																										usr.Sequipped = 2
																										usr.LSequipped = 2
																										usr.AXequipped = 2
																										usr.WHequipped = 2
																										usr.JRequipped = 2
																										usr.FPequipped = 2
																										usr.PXequipped = 2
																										usr.SHequipped = 2
																										usr.HMequipped = 2
																										usr.SKequipped = 2
																										usr.HOequipped = 2
																										usr.CKequipped = 2
																										//usr.GVequipped = 2
																										usr.FLequipped = 2
																										usr.PYequipped = 2
																										usr.OKequipped = 2
																										usr.SHMequipped = 2
																										usr.UPKequipped = 2
																										usr.TWequipped = 2
																										usr.FIequipped = 2
																										usr.SWequipped = 2
																										usr.WSequipped = 2
																										usr.CHequipped = 2
																										usr.tempdamagemin += src.DamageMin
																										usr.tempdamagemax += src.DamageMax
																										var/mob/players/M = usr
																										M.attackspeed -= src.wpnspd
																										return
																									//else
																										//usr << "<font color = teal>You have something equipped!"
																								else
																									usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																									return
																							else
																								if ((typi=="weapon")&&(twohanded==1))
																									if (usr.tempstr>=src.strreq)
																										//if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																										if(usr.Wequipped==2)
																											usr << "Unable to use right now."
																											return
																										else if(usr.Wequipped==0)
																											usr << "You wield the [src.name]."
																											src.suffix="Equipped"
																											usr.Wequipped = 1
																											usr.Sequipped = 2
																											usr.LSequipped = 2
																											usr.AXequipped = 2
																											usr.WHequipped = 2
																											usr.JRequipped = 2
																											usr.FPequipped = 2
																											usr.PXequipped = 2
																											usr.SHequipped = 2
																											usr.HMequipped = 2
																											usr.SKequipped = 2
																											usr.HOequipped = 2
																											usr.CKequipped = 2
																											//usr.GVequipped = 2
																											usr.FLequipped = 2
																											usr.PYequipped = 2
																											usr.OKequipped = 2
																											usr.SHMequipped = 2
																											usr.UPKequipped = 2
																											usr.TWequipped = 2
																											usr.FIequipped = 2
																											usr.SWequipped = 2
																											usr.WSequipped = 2
																											usr.CHequipped = 2
																											usr.tempdamagemin += src.DamageMin
																											usr.tempdamagemax += src.DamageMax
																											var/mob/players/M = usr
																											M.attackspeed -= src.wpnspd
																											return
																										//else
																											//usr << "<font color = teal>You have something equipped!"
																									else
																										usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																										return
																								else
																									if ((typi=="CH")&&(twohanded==0))
																										if (usr.tempstr>=src.strreq)
																											//if(usr.CHequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																											if(usr.CHequipped==3&&usr.HMequipped==1)
																												goto HMCH
																											if(usr.HMequipped==0&&usr.CHequipped==3)
																												usr.CHequipped=0
																												src.suffix=""
																											else if(usr.CHequipped==2)
																												usr << "Unable to use right now."
																												return
																											else if(usr.CHequipped==0)
																												usr << "You wield the Chisel."
																												src.suffix="Equipped"
																												usr.Wequipped = 2
																												usr.Sequipped = 2
																												usr.LSequipped = 2
																												usr.AXequipped = 2
																												usr.WHequipped = 2
																												usr.JRequipped = 2
																												usr.FPequipped = 2
																												usr.PXequipped = 2
																												usr.SHequipped = 2
																												usr.HMequipped = 3
																												usr.SKequipped = 2
																												usr.HOequipped = 2
																												usr.CKequipped = 2
																												//usr.GVequipped = 2
																												usr.FLequipped = 2
																												usr.PYequipped = 2
																												usr.OKequipped = 2
																												usr.SHMequipped = 2
																												usr.UPKequipped = 2
																												usr.CHequipped = 1
																												usr.TWequipped = 2
																												usr.FIequipped = 2
																												usr.SWequipped = 2
																												usr.WSequipped = 2
																												usr.tempdamagemin += src.DamageMin
																												usr.tempdamagemax += src.DamageMax
																												var/mob/players/M = usr
																												M.attackspeed -= src.wpnspd
																												return
																											HMCH
																											if(usr.CHequipped==3&&usr.HMequipped==1)
																												//usr.HMequipped=3
																												src.suffix="Dual Wield"
																												//usr << "Chisel equipped - Dual Wield with Hammer"
																												usr.Wequipped = 2
																												usr.Sequipped = 2
																												usr.LSequipped = 2
																												usr.AXequipped = 2
																												usr.WHequipped = 2
																												usr.JRequipped = 2
																												usr.FPequipped = 2
																												usr.PXequipped = 2
																												usr.SHequipped = 2
																												usr.HMequipped = 1
																												usr.SKequipped = 2
																												usr.HOequipped = 2
																												usr.CKequipped = 2
																												//usr.GVequipped = 2
																												usr.FLequipped = 2
																												usr.PYequipped = 2
																												usr.OKequipped = 2
																												usr.SHMequipped = 2
																												usr.UPKequipped = 2
																												usr.TWequipped = 2
																												usr.FIequipped = 2
																												usr.SWequipped = 2
																												usr.WSequipped = 2
																												usr.CHequipped = 1
																												return
																											//else if(usr.HMequipped==0&&usr.CHequipped==1)
																												//usr << "Hammer not equipped for some reason"
																												//return

																											//else
																												//usr << "<font color = teal>You have something equipped!"
																										else
																											usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																											return
																									else
																										if ((typi=="FI")&&(twohanded==0))
																											if (usr.tempstr>=src.strreq)
																												//if(usr.FIequipped==0 && usr.CHequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																												if(usr.FIequipped==2)
																													usr << "Unable to use right now."
																													return
																												else if(usr.FIequipped==0)
																													usr << "You wield the File."
																													src.suffix="Equipped"
																													usr.Wequipped = 2
																													usr.Sequipped = 2
																													usr.LSequipped = 2
																													usr.AXequipped = 2
																													usr.WHequipped = 2
																													usr.JRequipped = 2
																													usr.FPequipped = 2
																													usr.PXequipped = 2
																													usr.SHequipped = 2
																													usr.HMequipped = 2
																													usr.SKequipped = 2
																													usr.HOequipped = 2
																													usr.CKequipped = 2
																													//usr.GVequipped = 2
																													usr.FLequipped = 2
																													usr.PYequipped = 2
																													usr.OKequipped = 2
																													usr.SHMequipped = 2
																													usr.UPKequipped = 2
																													usr.CHequipped = 2
																													usr.TWequipped = 2
																													usr.FIequipped = 1
																													usr.SWequipped = 2
																													usr.WSequipped = 2
																													usr.tempdamagemin += src.DamageMin
																													usr.tempdamagemax += src.DamageMax
																													var/mob/players/M = usr
																													M.attackspeed -= src.wpnspd
																													return
																												//else
																													//usr << "<font color = teal>You have something equipped!"
																											else
																												usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																												return
																										else
																											if ((typi=="SW")&&(twohanded==0))
																												if (usr.tempstr>=src.strreq)
																													//if(usr.SWequipped==0 && usr.FIequipped==0 && usr.CHequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																													if(usr.SWequipped==2)
																														usr << "Unable to use right now."
																														return
																													else if(usr.SWequipped==0)
																														usr << "You wield the Saw."
																														src.suffix="Equipped"
																														usr.Wequipped = 2
																														usr.Sequipped = 2
																														usr.LSequipped = 2
																														usr.AXequipped = 2
																														usr.WHequipped = 2
																														usr.JRequipped = 2
																														usr.FPequipped = 2
																														usr.PXequipped = 2
																														usr.SHequipped = 2
																														usr.HMequipped = 2
																														usr.SKequipped = 2
																														usr.HOequipped = 2
																														usr.CKequipped = 2
																														//usr.GVequipped = 2
																														usr.FLequipped = 2
																														usr.PYequipped = 2
																														usr.OKequipped = 2
																														usr.SHMequipped = 2
																														usr.UPKequipped = 2
																														usr.CHequipped = 2
																														usr.TWequipped = 2
																														usr.FIequipped = 2
																														usr.SWequipped = 1
																														usr.WSequipped = 2
																														usr.tempdamagemin += src.DamageMin
																														usr.tempdamagemax += src.DamageMax
																														var/mob/players/M = usr
																														M.attackspeed -= src.wpnspd
																														return
																													//else
																														//usr << "<font color = teal>You have something equipped!"
																												else
																													usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																													return
																											else
																												if ((typi=="WS")&&(twohanded==0))
																													if (usr.tempstr>=src.strreq)
																														//if(usr.WSequipped==0 && usr.SWequipped==0 && usr.FIequipped==0 && usr.CHequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																														if(usr.WSequipped==2)
																															usr << "Unable to use right now."
																															return
																														else if(usr.WSequipped==0)
																															usr << "You wield the Whetstone."
																															src.suffix="Equipped"
																															usr.Wequipped = 2
																															usr.Sequipped = 2
																															usr.LSequipped = 2
																															usr.AXequipped = 2
																															usr.WHequipped = 2
																															usr.JRequipped = 2
																															usr.FPequipped = 2
																															usr.PXequipped = 2
																															usr.SHequipped = 2
																															usr.HMequipped = 2
																															usr.SKequipped = 2
																															usr.HOequipped = 2
																															usr.CKequipped = 2
																															//usr.GVequipped = 2
																															usr.FLequipped = 2
																															usr.PYequipped = 2
																															usr.OKequipped = 2
																															usr.SHMequipped = 2
																															usr.UPKequipped = 2
																															usr.CHequipped = 2
																															usr.TWequipped = 2
																															usr.FIequipped = 2
																															usr.SWequipped = 2
																															usr.WSequipped = 1
																															usr.tempdamagemin += src.DamageMin
																															usr.tempdamagemax += src.DamageMax
																															var/mob/players/M = usr
																															M.attackspeed -= src.wpnspd
																															return
																														//else
																															//usr << "<font color = teal>You have something equipped!"
																													else
																														usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																														return
																												else
																													if ((typi=="SAX")&&(twohanded==0))
																														if (usr.tempstr>=src.strreq)
																															//if(usr.WSequipped==0 && usr.SWequipped==0 && usr.FIequipped==0 && usr.CHequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																															if(usr.SAXequipped==2)
																																usr << "Unable to use right now."
																																return
																															else if(usr.SAXequipped==0)
																																usr << "You wield the Stone Axe."
																																src.suffix="Equipped"
																																usr.Wequipped = 2
																																usr.Sequipped = 2
																																usr.LSequipped = 2
																																usr.AXequipped = 2
																																usr.WHequipped = 2
																																usr.JRequipped = 2
																																usr.FPequipped = 2
																																usr.PXequipped = 2
																																usr.SHequipped = 2
																																usr.HMequipped = 2
																																usr.SKequipped = 2
																																usr.HOequipped = 2
																																usr.CKequipped = 2
																																//usr.GVequipped = 2
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
																																usr.SAXequipped = 1
																																usr.tempdamagemin += src.DamageMin
																																usr.tempdamagemax += src.DamageMax
																																var/mob/players/M = usr
																																M.attackspeed -= src.wpnspd
																																return
																															//else
																																//usr << "<font color = teal>You have something equipped!"
																														else
																															usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																															return
			proc
				FindCK(mob/players/M)
					for(var/obj/items/tools/CarvingKnife/CK in M.contents)
						if(typi=="CK")
							return CK
				FindHM(mob/players/M)
					for(var/obj/items/tools/Hammer/HM in M.contents)
						if(typi=="HM"||suffix=="Equipped")
							return HM
				FindCH(mob/players/M)
					for(var/obj/items/tools/Chisel/CH in M.contents)
						if(typi=="CH")
							return CH
				FindFL(mob/players/M)
					for(var/obj/items/tools/Flint/FL in M.contents)
						if(typi=="FL")
							return FL
				FindPY(mob/players/M)
					for(var/obj/items/tools/Pyrite/PY in M.contents)
						if(typi=="PY")
							return PY
			verb/Unequip()
				set category=null
				set popup_menu=1
				//set hidden = 1
				set src in usr
				M = usr
				call(/mob/players/proc/UESME)()
				call(/mob/players/proc/UEB)()
				call(/mob/players/proc/UED)()
				call(/mob/players/proc/UETW)()
				if((M.UESME==1)&&(M.GVequipped==1))
					return
				else if((M.UESME==0)&&(M.GVequipped==1)&&(src.typi=="GV"))
					usr.GVequipped = 0
					src.suffix=""
				if((M.UEB==1)&&(M.HMequipped==1))
					return
				if((M.UED==1)&&(M.HMequipped==1))
					return
				if((M.UETW==1)&&(M.TWequipped==1))
					return
				if(usr.HMequipped==3||usr.CKequipped==3||usr.CHequipped==3||usr.FLequipped==3||usr.PYequipped==3)
					var/obj/items/tools/CarvingKnife/CK = locate() in M.contents
					var/obj/items/tools/Hammer/HM = locate() in M.contents
					var/obj/items/tools/Chisel/CH = locate() in M.contents
					var/obj/items/tools/Flint/FL = locate() in M.contents
					var/obj/items/tools/Pyrite/PY = locate() in M.contents
					//usr << "Dual Wield mutil-tool 3 uneqiup check fired"
					if(CK)
						for(CK)
							CK:suffix=""
					if(HM)
						for(HM)
							HM:suffix=""
					if(CH)
						for(CH)
							CH:suffix=""
					if(FL)
						for(FL)
							FL:suffix=""
					if(PY)
						for(PY)
							PY:suffix=""
					src.suffix=""
					usr.Wequipped = 0
					usr.Sequipped = 0
					usr.LSequipped = 0
					usr.AXequipped = 0
					usr.WHequipped = 0
					usr.JRequipped = 0
					usr.FPequipped = 0
					usr.PXequipped = 0
					usr.SHequipped = 0
					usr.HMequipped = 0
					usr.SKequipped = 0
					usr.HOequipped = 0
					usr.CKequipped = 0
					//usr.GVequipped = 2
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
				if(typi=="GV")
					if(usr.GVequipped==1)
						usr.GVequipped = 0
						src.suffix=""
						usr << "You take off the gloves."
				if(typi=="HM"||typi=="CK")
					if(usr.HMequipped==1&&usr.CKequipped==1)
						var/obj/items/tools/CarvingKnife/CK = locate() in M.contents
						var/obj/items/tools/Hammer/HM = locate() in M.contents
						//usr << "HM CK Dual wield unequipped fired."//This needs to tell the other tool that is equipped that it is also unequipped
						//if(src.typi=="HM"||src.typi=="CK")
							//suffix = ""
						//if(typi=="CK")
							//suffix = ""
						//for(CK)
						if(HM)
							for(HM)
								HM:suffix=""
						if(CK)
							for(CK)
								CK:suffix=""
						//CK:suffix=""
						//src.suffix=""
						usr.Wequipped = 0
						usr.Sequipped = 0
						usr.LSequipped = 0
						usr.AXequipped = 0
						usr.WHequipped = 0
						usr.JRequipped = 0
						usr.FPequipped = 0
						usr.PXequipped = 0
						usr.SHequipped = 0
						usr.HMequipped = 0
						usr.SKequipped = 0
						usr.HOequipped = 0
						usr.CKequipped = 0
						//usr.GVequipped = 2
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
						//usr.GVequipped = 2
				if(typi=="HM"||typi=="CH")
					if(usr.HMequipped==1&&usr.CHequipped==1)
						//usr << "HM CH Dual wield unequipped fired."
						var/obj/items/tools/Chisel/CH = locate() in M.contents
						var/obj/items/tools/Hammer/HM = locate() in M.contents
						if(HM)
							for(HM)
								HM:suffix=""
						if(CH)
							for(CH)
								CH:suffix=""
						//CH:suffix=""
						//src.suffix = ""
						usr.Wequipped = 0
						usr.Sequipped = 0
						usr.LSequipped = 0
						usr.AXequipped = 0
						usr.WHequipped = 0
						usr.JRequipped = 0
						usr.FPequipped = 0
						usr.PXequipped = 0
						usr.SHequipped = 0
						usr.HMequipped = 0
						usr.SKequipped = 0
						usr.HOequipped = 0
						usr.CKequipped = 0
						//usr.GVequipped = 2
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
				if(typi=="FL"||typi=="CK")
					if(usr.FLequipped==1&&usr.CKequipped==1)
					//usr << "FL CK Dual wield unequipped fired."
						var/obj/items/tools/Flint/FL = locate() in M.contents
						var/obj/items/tools/CarvingKnife/CK = locate() in M.contents
						if(FL)
							for(FL)
								FL:suffix=""
						if(CK)
							for(CK)
								CK:suffix=""
						src.suffix = ""
						usr.Wequipped = 0
						usr.Sequipped = 0
						usr.LSequipped = 0
						usr.AXequipped = 0
						usr.WHequipped = 0
						usr.JRequipped = 0
						usr.FPequipped = 0
						usr.PXequipped = 0
						usr.SHequipped = 0
						usr.HMequipped = 0
						usr.SKequipped = 0
						usr.HOequipped = 0
						usr.CKequipped = 0
						//usr.GVequipped = 2
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
				if(typi=="FL"||typi=="PY")
					if(typi=="FL"||typi=="PY"||usr.FLequipped==1&&usr.PYequipped==1)
						//usr << "FL PY Dual wield unequipped fired."
						var/obj/items/tools/Flint/FL = locate() in M.contents
						var/obj/items/tools/Pyrite/PY = locate() in M.contents
						if(FL)
							for(FL)
								FL:suffix=""
						if(PY)
							for(PY)
								PY:suffix=""
						src.suffix = ""
						usr.Wequipped = 0
						usr.Sequipped = 0
						usr.LSequipped = 0
						usr.AXequipped = 0
						usr.WHequipped = 0
						usr.JRequipped = 0
						usr.FPequipped = 0
						usr.PXequipped = 0
						usr.SHequipped = 0
						usr.HMequipped = 0
						usr.SKequipped = 0
						usr.HOequipped = 0
						usr.CKequipped = 0
						//usr.GVequipped = 2
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
				if(src.suffix=="Cannot Use")
					src.suffix = ""
					//usr << "Cannot use unequip fired"
					//if(usr.FIequipped==2 || usr.TWequipped==2 || usr.Wequipped==2 || usr.Sequipped==2 || usr.LSequipped==2 || usr.AXequipped==2 || usr.WHequipped==2 || usr.JRequipped==2 || usr.FPequipped==2 || usr.PXequipped==2 || usr.SHequipped==2 || usr.SKequipped==2 || usr.HOequipped==2 || usr.OKequipped==2 || usr.SHMequipped==2 || usr.UPKequipped==2)
					//usr << "Cannot use unequip 2 check fired"
					if(usr.Wequipped == 2)
						usr.Wequipped = 0
					if(usr.Sequipped == 2)
						usr.Sequipped = 0
					if(usr.LSequipped == 2)
						usr.LSequipped = 0
					if(usr.AXequipped == 2)
						usr.AXequipped = 0
					if(usr.WHequipped == 2)
						usr.WHequipped = 0
					if(usr.JRequipped == 2)
						usr.JRequipped = 0
					if(usr.FPequipped == 2)
						usr.FPequipped = 0
					if(usr.PXequipped == 2)
						usr.PXequipped = 0
					if(usr.SHequipped == 2)
						usr.SHequipped = 0
					if(usr.HMequipped == 2)
						usr.HMequipped = 0
					if(usr.SKequipped == 2)
						usr.SKequipped = 0
					if(usr.HOequipped == 2)
						usr.HOequipped = 0
					if(usr.CKequipped == 2)
						usr.CKequipped = 0
					if(usr.GVequipped == 2)
						usr.GVequipped = 0
					if(usr.FLequipped == 2)
						usr.FLequipped = 0
					if(usr.PYequipped == 2)
						usr.PYequipped = 0
					if(usr.OKequipped == 2)
						usr.OKequipped = 0
					if(usr.SHMequipped == 2)
						usr.SHMequipped = 0
					if(usr.UPKequipped == 2)
						usr.UPKequipped = 0
					if(usr.CHequipped == 2)
						usr.CHequipped = 0
					if(usr.TWequipped == 2)
						usr.TWequipped = 0
					if(usr.FIequipped == 2)
						usr.FIequipped = 0
					if(usr.SWequipped == 2)
						usr.SWequipped = 0
					if(usr.WSequipped == 2)
						usr.WSequipped = 0
					//usr << "You realize that there is no reason to use these together."
					//return
				//Process
				if(src.suffix!="")
					//usr << "<font color = teal>[src.name] not equipped!"
					//usr << "Unequip fired src [src]"
				//else
					if (typi=="LS" && twohanded==1)
						if(usr.LSequipped==0)
							usr << "<font color = teal>You don't have [src.name] equipped!"
						else if(usr.LSequipped!=0)
							usr << "You sheath the Longsword."
							src.suffix = ""
							usr.Wequipped = 0
							usr.Sequipped = 0
							usr.LSequipped = 0
							usr.AXequipped = 0
							usr.WHequipped = 0
							usr.JRequipped = 0
							usr.FPequipped = 0
							usr.PXequipped = 0
							usr.SHequipped = 0
							usr.HMequipped = 0
							usr.SKequipped = 0
							usr.HOequipped = 0
							usr.CKequipped = 0
							//usr.GVequipped = 2
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
							if(M.char_class=="Fighter")
								M.attackspeed = 6
							return
							//else
								//M.attackspeed = 1
					else
						if (typi=="AX" && twohanded==1)
							if(usr.AXequipped==0)
								usr << "<font color = teal>You don't have [src.name] equipped!"
							else if(usr.AXequipped!=0)
								//src.verbs-=/obj/items/weapons/proc/Unequip
								//src.verbs+=/obj/items/weapons/verb/Equip
								usr << "You holster the Axe."
								src.suffix = ""
								usr.Wequipped = 0
								usr.Sequipped = 0
								usr.LSequipped = 0
								usr.AXequipped = 0
								usr.WHequipped = 0
								usr.JRequipped = 0
								usr.FPequipped = 0
								usr.PXequipped = 0
								usr.SHequipped = 0
								usr.HMequipped = 0
								usr.SKequipped = 0
								usr.HOequipped = 0
								usr.CKequipped = 0
								//usr.GVequipped = 2
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
								if(M.char_class=="Defender")
									M.attackspeed = 5
								return
								//else
									//M.attackspeed = 1
						else
							if (typi=="HM" && twohanded==0)
								if(usr.HMequipped==0)
									usr << "<font color = teal>You don't have [src.name] equipped!"
								else if(usr.HMequipped!=0)
									//src.verbs-=/obj/items/weapons/proc/Unequip
									//src.verbs+=/obj/items/weapons/verb/Equip
									usr << "You stow the Hammer."
									src.suffix = ""
									usr.Wequipped = 0
									usr.Sequipped = 0
									usr.LSequipped = 0
									usr.AXequipped = 0
									usr.WHequipped = 0
									usr.JRequipped = 0
									usr.FPequipped = 0
									usr.PXequipped = 0
									usr.SHequipped = 0
									usr.HMequipped = 0
									usr.SKequipped = 0
									usr.HOequipped = 0
									usr.CKequipped = 0
									//usr.GVequipped = 2
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
									if(M.char_class=="Defender")
										M.attackspeed = 4
									return
									//else
										//M.attackspeed = 1
							else
								if (typi=="WH" && twohanded==1)
									if(usr.WHequipped==0)
										usr << "<font color = teal>You don't have [src.name] equipped!"
									else if(usr.WHequipped!=0)
										usr << "You harness the Warhammer to your back."
										src.suffix = ""
										usr.Wequipped = 0
										usr.Sequipped = 0
										usr.LSequipped = 0
										usr.AXequipped = 0
										usr.WHequipped = 0
										usr.JRequipped = 0
										usr.FPequipped = 0
										usr.PXequipped = 0
										usr.SHequipped = 0
										usr.HMequipped = 0
										usr.SKequipped = 0
										usr.HOequipped = 0
										usr.CKequipped = 0
										//usr.GVequipped = 2
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
										if(M.char_class=="Defender")
											M.attackspeed = 5
										return
										//else
											//M.attackspeed = 1
								else
									if (typi=="JR" && twohanded==1)
										if(usr.JRequipped==0)
											usr << "<font color = teal>You don't have [src.name] equipped!"
										else if(usr.JRequipped!=0)
											usr << "You stow the Jar."
											src.suffix = ""
											usr.Wequipped = 0
											usr.Sequipped = 0
											usr.LSequipped = 0
											usr.AXequipped = 0
											usr.WHequipped = 0
											usr.JRequipped = 0
											usr.FPequipped = 0
											usr.PXequipped = 0
											usr.SHequipped = 0
											usr.HMequipped = 0
											usr.SKequipped = 0
											usr.HOequipped = 0
											usr.CKequipped = 0
											//usr.GVequipped = 2
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
											if(M.char_class=="Defender")
												M.attackspeed = 6
											return
									else
										if (typi=="SH" && twohanded==1)
											if(usr.SHequipped==0)
												usr << "<font color = teal>You don't have [src.name] equipped!"
											else if(usr.SHequipped!=0)
												usr << "You harness the shovel onto your back."
												src.suffix = ""
												usr.Wequipped = 0
												usr.Sequipped = 0
												usr.LSequipped = 0
												usr.AXequipped = 0
												usr.WHequipped = 0
												usr.JRequipped = 0
												usr.FPequipped = 0
												usr.PXequipped = 0
												usr.SHequipped = 0
												usr.HMequipped = 0
												usr.SKequipped = 0
												usr.HOequipped = 0
												usr.CKequipped = 0
												//usr.GVequipped = 2
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
												if(M.char_class=="Defender")
													M.attackspeed = 6
												return
											//	else
													//M.attackspeed = 1
										else
											if (typi=="FP" && twohanded==1)
												if(usr.FPequipped==0)
													usr << "<font color = teal>You don't have [src.name] equipped!"
												else if(usr.FPequipped!=0)
													usr << "You harness the Fishing Pole onto your back."
													src.suffix = ""
													usr.Wequipped = 0
													usr.Sequipped = 0
													usr.LSequipped = 0
													usr.AXequipped = 0
													usr.WHequipped = 0
													usr.JRequipped = 0
													usr.FPequipped = 0
													usr.PXequipped = 0
													usr.SHequipped = 0
													usr.HMequipped = 0
													usr.SKequipped = 0
													usr.HOequipped = 0
													usr.CKequipped = 0
													//usr.GVequipped = 2
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
													if(M.char_class=="Defender")
														M.attackspeed = 7
													return
												//	else
														//M.attackspeed = 1
											else
												if (typi=="CK" && twohanded==0)
													if(usr.CKequipped==0)
														usr << "<font color = teal>You don't have [src.name] equipped!"
													else if(usr.CKequipped!=0)
														//src.verbs-=/obj/items/weapons/proc/Unequip
														//src.verbs+=/obj/items/weapons/verb/Equip
														usr << "You sheath the Carving Knife."
														src.suffix = ""
														usr.Wequipped = 0
														usr.Sequipped = 0
														usr.LSequipped = 0
														usr.AXequipped = 0
														usr.WHequipped = 0
														usr.JRequipped = 0
														usr.FPequipped = 0
														usr.PXequipped = 0
														usr.SHequipped = 0
														usr.HMequipped = 0
														usr.SKequipped = 0
														usr.HOequipped = 0
														usr.CKequipped = 0
														//usr.GVequipped = 2
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
														if(M.char_class=="Defender")
															M.attackspeed = 6
														return
													//	else
															//M.attackspeed = 1
												else
													if (typi=="PX" && twohanded==1)
														if(usr.PXequipped==0)
															usr << "<font color = teal>You don't have [src.name] equipped!"
														else if(usr.PXequipped!=0)
															usr << "You holster the pickaxe."
															src.suffix = ""
															usr.Wequipped = 0
															usr.Sequipped = 0
															usr.LSequipped = 0
															usr.AXequipped = 0
															usr.WHequipped = 0
															usr.JRequipped = 0
															usr.FPequipped = 0
															usr.PXequipped = 0
															usr.SHequipped = 0
															usr.HMequipped = 0
															usr.SKequipped = 0
															usr.HOequipped = 0
															usr.CKequipped = 0
															//usr.GVequipped = 2
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
															if(M.char_class=="Defender")
																M.attackspeed = 7
															return
															//else
																//M.attackspeed = 1
													else
														if (typi=="GV")
															if(usr.GVequipped==0)
																usr << "<font color = teal>You aren't wearing [src.name]!"
															else if(usr.GVequipped!=0)
																usr << "You take off the gloves."
																src.suffix = ""//uncommented below is to test if you can wear gloves and use all tools/weapons, even two handed -- since you can technically use items when wearing gloves.
																/*usr.Wequipped = 0
																usr.Sequipped = 0
																usr.LSequipped = 0
																usr.AXequipped = 0
																usr.WHequipped = 0
																usr.JRequipped = 0
																usr.FPequipped = 0
																usr.PXequipped = 0
																usr.SHequipped = 0
																usr.HMequipped = 0
																usr.SKequipped = 0
																usr.HOequipped = 0
																usr.CKequipped = 0*/
																usr.GVequipped = 0
																/*usr.FLequipped = 0
																usr.PYequipped = 0
																usr.OKequipped = 0
																usr.SHMequipped = 0
																usr.UPKequipped = 0
																usr.TWequipped = 0*/
																usr.tempdamagemin -= src.DamageMin
																usr.tempdamagemax -= src.DamageMax
																var/mob/players/M = usr
																if(M.char_class=="Defender")
																	M.attackspeed = 7
																return
																//else if(M.char_class=="Defender")
																	//M.attackspeed = 8
																//else
																	//M.attackspeed = 1
														else
															if (typi=="HO" && twohanded==1)
																if(usr.HOequipped==0)
																	usr << "<font color = teal>You don't have [src.name] equipped!"
																else if(usr.HOequipped!=0)
																	usr << "You harness the Hoe onto your back."
																	src.suffix = ""
																	usr.Wequipped = 0
																	usr.Sequipped = 0
																	usr.LSequipped = 0
																	usr.AXequipped = 0
																	usr.WHequipped = 0
																	usr.JRequipped = 0
																	usr.FPequipped = 0
																	usr.PXequipped = 0
																	usr.SHequipped = 0
																	usr.HMequipped = 0
																	usr.SKequipped = 0
																	usr.HOequipped = 0
																	usr.CKequipped = 0
																	//usr.GVequipped = 2
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
																	if(M.char_class=="Defender")
																		M.attackspeed = 8
																	return
																	//else
																		//M.attackspeed = 1
															else
																if (typi=="SK" && twohanded==0)
																	if(usr.SKequipped==0)
																		usr << "<font color = teal>You don't have [src.name] equipped!"
																	else if(usr.SKequipped!=0)
																		//src.verbs-=/obj/items/weapons/proc/Unequip
																		//src.verbs+=/obj/items/weapons/verb/Equip
																		usr << "You sheath the Sickle."
																		src.suffix = ""
																		usr.Wequipped = 0
																		usr.Sequipped = 0
																		usr.LSequipped = 0
																		usr.AXequipped = 0
																		usr.WHequipped = 0
																		usr.JRequipped = 0
																		usr.FPequipped = 0
																		usr.PXequipped = 0
																		usr.SHequipped = 0
																		usr.HMequipped = 0
																		usr.SKequipped = 0
																		usr.HOequipped = 0
																		usr.CKequipped = 0
																		//usr.GVequipped = 2
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
																		if(M.char_class=="Defender")
																			M.attackspeed = 8
																		return
																		//else
																			//M.attackspeed = 1
																else
																	if (typi=="FL" && twohanded==0)
																		if(usr.FLequipped==0)
																			usr << "<font color = teal>You don't have [src.name] equipped!"
																		else if(usr.FLequipped!=0)
																			//src.verbs-=/obj/items/weapons/proc/Unequip
																			//src.verbs+=/obj/items/weapons/verb/Equip
																			usr << "You stow the Flint."
																			src.suffix = ""
																			usr.Wequipped = 0
																			usr.Sequipped = 0
																			usr.LSequipped = 0
																			usr.AXequipped = 0
																			usr.WHequipped = 0
																			usr.JRequipped = 0
																			usr.FPequipped = 0
																			usr.PXequipped = 0
																			usr.SHequipped = 0
																			usr.HMequipped = 0
																			usr.SKequipped = 0
																			usr.HOequipped = 0
																			usr.CKequipped = 0
																			//usr.GVequipped = 2
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
																			if(M.char_class=="Defender")
																				M.attackspeed = 8
																			return
																			//else
																				//M.attackspeed = 1
																	else
																		if (typi=="PY" && twohanded==0)
																			if(usr.PYequipped==0)
																				usr << "<font color = teal>You don't have [src.name] equipped!"
																			else if(usr.PYequipped!=0)
																				//src.verbs-=/obj/items/weapons/proc/Unequip
																				//src.verbs+=/obj/items/weapons/verb/Equip
																				usr << "You stow the Pyrite."
																				src.suffix = ""
																				usr.Wequipped = 0
																				usr.Sequipped = 0
																				usr.LSequipped = 0
																				usr.AXequipped = 0
																				usr.WHequipped = 0
																				usr.JRequipped = 0
																				usr.FPequipped = 0
																				usr.PXequipped = 0
																				usr.SHequipped = 0
																				usr.HMequipped = 0
																				usr.SKequipped = 0
																				usr.HOequipped = 0
																				usr.CKequipped = 0
																				//usr.GVequipped = 2
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
																				if(M.char_class=="Defender")
																					M.attackspeed = 1
																				return
																				//else
																					//M.attackspeed = 1
																		else
																			if (typi=="OK" && twohanded==0)
																				if(usr.OKequipped==0)
																					usr << "<font color = teal>You don't have [src.name] equipped!"
																				else if(usr.OKequipped!=0)
																					//src.verbs-=/obj/items/weapons/proc/Unequip
																					//src.verbs+=/obj/items/weapons/verb/Equip
																					usr << "You sheath the Obsidian Knife."
																					src.suffix = ""
																					usr.Wequipped = 0
																					usr.Sequipped = 0
																					usr.LSequipped = 0
																					usr.AXequipped = 0
																					usr.WHequipped = 0
																					usr.JRequipped = 0
																					usr.FPequipped = 0
																					usr.PXequipped = 0
																					usr.SHequipped = 0
																					usr.HMequipped = 0
																					usr.SKequipped = 0
																					usr.HOequipped = 0
																					usr.CKequipped = 0
																					//usr.GVequipped = 2
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
																					if(M.char_class=="Defender")
																						M.attackspeed = 1
																					return
																					//else
																						//M.attackspeed = 1
																			else
																				if (typi=="SHM" && twohanded==0)
																					if(usr.SHMequipped==0)
																						usr << "<font color = teal>You don't have [src.name] equipped!"
																					else if(usr.SHMequipped!=0)
																						//src.verbs-=/obj/items/weapons/proc/Unequip
																						//src.verbs+=/obj/items/weapons/verb/Equip
																						usr << "You stow the Stone Hammer."
																						src.suffix = ""
																						usr.Wequipped = 0
																						usr.Sequipped = 0
																						usr.LSequipped = 0
																						usr.AXequipped = 0
																						usr.WHequipped = 0
																						usr.JRequipped = 0
																						usr.FPequipped = 0
																						usr.PXequipped = 0
																						usr.SHequipped = 0
																						usr.HMequipped = 0
																						usr.SKequipped = 0
																						usr.HOequipped = 0
																						usr.CKequipped = 0
																						//usr.GVequipped = 2
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
																						if(M.char_class=="Defender")
																							M.attackspeed = 1
																						return
																						//else
																							//M.attackspeed = 1
																				else
																					if (typi=="UPK" && twohanded==1)
																						if(usr.UPKequipped==0)
																							usr << "<font color = teal>You don't have [src.name] equipped!"
																						else if(usr.UPKequipped!=0)
																							usr << "You holster the Ueik Pickaxe."
																							src.suffix = ""
																							usr.Wequipped = 0
																							usr.Sequipped = 0
																							usr.LSequipped = 0
																							usr.AXequipped = 0
																							usr.WHequipped = 0
																							usr.JRequipped = 0
																							usr.FPequipped = 0
																							usr.PXequipped = 0
																							usr.SHequipped = 0
																							usr.HMequipped = 0
																							usr.SKequipped = 0
																							usr.HOequipped = 0
																							usr.CKequipped = 0
																							//usr.GVequipped = 2
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
																							if(M.char_class=="Defender")
																								M.attackspeed = 8
																							return
																							//else
																								//M.attackspeed = 1
																					else
																						if (typi=="TW" && twohanded==0)
																							if(usr.TWequipped==0)
																								usr << "<font color = teal>You don't have [src.name] equipped!"
																							else if(usr.TWequipped!=0)
																								//src.verbs-=/obj/items/weapons/proc/Unequip
																								//src.verbs+=/obj/items/weapons/verb/Equip
																								usr << "You stow the Trowel."
																								src.suffix = ""
																								usr.Wequipped = 0
																								usr.Sequipped = 0
																								usr.LSequipped = 0
																								usr.AXequipped = 0
																								usr.WHequipped = 0
																								usr.JRequipped = 0
																								usr.FPequipped = 0
																								usr.PXequipped = 0
																								usr.SHequipped = 0
																								usr.HMequipped = 0
																								usr.SKequipped = 0
																								usr.HOequipped = 0
																								usr.CKequipped = 0
																								//usr.GVequipped = 2
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
																								if(M.char_class=="Defender")
																									M.attackspeed = 1
																								return
																						else
																							if (typi=="CH" && twohanded==0)
																								if(usr.CHequipped==0)
																									usr << "<font color = teal>You don't have [src.name] equipped!"
																								else if(usr.CHequipped!=0)
																									//src.verbs-=/obj/items/weapons/proc/Unequip
																									//src.verbs+=/obj/items/weapons/verb/Equip
																									usr << "You sheath and stow the Chisel."
																									src.suffix = ""
																									usr.Wequipped = 0
																									usr.Sequipped = 0
																									usr.LSequipped = 0
																									usr.AXequipped = 0
																									usr.WHequipped = 0
																									usr.JRequipped = 0
																									usr.FPequipped = 0
																									usr.PXequipped = 0
																									usr.SHequipped = 0
																									usr.HMequipped = 0
																									usr.SKequipped = 0
																									usr.HOequipped = 0
																									usr.CKequipped = 0
																									//usr.GVequipped = 2
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
																									if(M.char_class=="Defender")
																										M.attackspeed = 1
																									return
																							else
																								if (typi=="FI" && twohanded==0)
																									if(usr.FIequipped==0)
																										usr << "<font color = teal>You don't have [src.name] equipped!"
																									else if(usr.FIequipped!=0)
																										//src.verbs-=/obj/items/weapons/proc/Unequip
																										//src.verbs+=/obj/items/weapons/verb/Equip
																										usr << "You stow the File."
																										src.suffix = ""
																										usr.Wequipped = 0
																										usr.Sequipped = 0
																										usr.LSequipped = 0
																										usr.AXequipped = 0
																										usr.WHequipped = 0
																										usr.JRequipped = 0
																										usr.FPequipped = 0
																										usr.PXequipped = 0
																										usr.SHequipped = 0
																										usr.HMequipped = 0
																										usr.SKequipped = 0
																										usr.HOequipped = 0
																										usr.CKequipped = 0
																										//usr.GVequipped = 2
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
																										if(M.char_class=="Defender")
																											M.attackspeed = 1
																										return
																								else
																									if (typi=="SW" && twohanded==0)
																										if(usr.SWequipped==0)
																											usr << "<font color = teal>You don't have [src.name] equipped!"
																										else if(usr.SWequipped!=0)
																											//src.verbs-=/obj/items/weapons/proc/Unequip
																											//src.verbs+=/obj/items/weapons/verb/Equip
																											usr << "You holster the Saw."
																											src.suffix = ""
																											usr.Wequipped = 0
																											usr.Sequipped = 0
																											usr.LSequipped = 0
																											usr.AXequipped = 0
																											usr.WHequipped = 0
																											usr.JRequipped = 0
																											usr.FPequipped = 0
																											usr.PXequipped = 0
																											usr.SHequipped = 0
																											usr.HMequipped = 0
																											usr.SKequipped = 0
																											usr.HOequipped = 0
																											usr.CKequipped = 0
																											//usr.GVequipped = 2
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
																											if(M.char_class=="Defender")
																												M.attackspeed = 1
																											return
																									else
																										if (typi=="WS" && twohanded==0)
																											if(usr.WSequipped==0)
																												usr << "<font color = teal>You don't have [src.name] equipped!"
																											else if(usr.WSequipped!=0)
																												//src.verbs-=/obj/items/weapons/proc/Unequip
																												//src.verbs+=/obj/items/weapons/verb/Equip
																												usr << "You stow the Whetstone."
																												src.suffix = ""
																												usr.Wequipped = 0
																												usr.Sequipped = 0
																												usr.LSequipped = 0
																												usr.AXequipped = 0
																												usr.WHequipped = 0
																												usr.JRequipped = 0
																												usr.FPequipped = 0
																												usr.PXequipped = 0
																												usr.SHequipped = 0
																												usr.HMequipped = 0
																												usr.SKequipped = 0
																												usr.HOequipped = 0
																												usr.CKequipped = 0
																												//usr.GVequipped = 2
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
																												if(M.char_class=="Defender")
																													M.attackspeed = 1
																												return
																										else
																											if (typi=="weapon" && twohanded==0)
																												if(usr.Wequipped==0)
																													usr << "<font color = teal>You don't have [src.name] equipped!"
																												else if(usr.Wequipped!=0)
																													//src.verbs-=/obj/items/weapons/proc/Unequip
																													//src.verbs+=/obj/items/weapons/verb/Equip
																													usr << "You sheath the [src.name]."
																													src.suffix = ""
																													usr.Wequipped = 0
																													usr.Sequipped = 0
																													usr.LSequipped = 0
																													usr.AXequipped = 0
																													usr.WHequipped = 0
																													usr.JRequipped = 0
																													usr.FPequipped = 0
																													usr.PXequipped = 0
																													usr.SHequipped = 0
																													usr.HMequipped = 0
																													usr.SKequipped = 0
																													usr.HOequipped = 0
																													usr.CKequipped = 0
																													//usr.GVequipped = 2
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
																													if(M.char_class=="Defender")
																														M.attackspeed = 1
																													return
																											else
																												if (typi=="weapon" && twohanded==1)
																													if(usr.Wequipped==0)
																														usr << "<font color = teal>You don't have [src.name] equipped!"
																													else if(usr.Wequipped!=0)
																														//src.verbs-=/obj/items/weapons/proc/Unequip
																														//src.verbs+=/obj/items/weapons/verb/Equip
																														usr << "You sheath the [src.name]."
																														src.suffix = ""
																														usr.Wequipped = 0
																														usr.Sequipped = 0
																														usr.LSequipped = 0
																														usr.AXequipped = 0
																														usr.WHequipped = 0
																														usr.JRequipped = 0
																														usr.FPequipped = 0
																														usr.PXequipped = 0
																														usr.SHequipped = 0
																														usr.HMequipped = 0
																														usr.SKequipped = 0
																														usr.HOequipped = 0
																														usr.CKequipped = 0
																														//usr.GVequipped = 2
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
																														if(M.char_class=="Defender")
																															M.attackspeed = 1
																														return
																												else
																													if (typi=="SAX" && twohanded==0)
																														if(usr.SAXequipped==0)
																															usr << "<font color = teal>You don't have [src.name] equipped!"
																														else if(usr.SAXequipped!=0)
																															//src.verbs-=/obj/items/weapons/proc/Unequip
																															//src.verbs+=/obj/items/weapons/verb/Equip
																															usr << "You holster the [src.name]."
																															src.suffix = ""
																															usr.Wequipped = 0
																															usr.Sequipped = 0
																															usr.LSequipped = 0
																															usr.AXequipped = 0
																															usr.WHequipped = 0
																															usr.JRequipped = 0
																															usr.FPequipped = 0
																															usr.PXequipped = 0
																															usr.SHequipped = 0
																															usr.HMequipped = 0
																															usr.SKequipped = 0
																															usr.HOequipped = 0
																															usr.CKequipped = 0
																															//usr.GVequipped = 2
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
																															usr.SAXequipped = 0
																															usr.tempdamagemin -= src.DamageMin
																															usr.tempdamagemax -= src.DamageMax
																															var/mob/players/M = usr
																															if(M.char_class=="Defender")
																																M.attackspeed = 1
																															return

			/*verb
				Drop()
					set category = null
					set popup_menu=1
					set src in usr
					if(src.suffix == "Equipped")
						usr << "<font color = teal>Un-equip [src] first!"
					else
						src.Move(usr.loc)*/
			Click()
				set src in usr
				if(src in usr.contents)
					if(src.suffix == "Equipped"||src.suffix=="Cannot Use")
						Unequip()
					else
						Equip()
				else
					return

	//Sandbox weapons and tools
			var/mob/players/M
			LongSword
				icon_state="LongSword"
				typi = "weapon"
				strreq = 1
				name = "Long Sword"
				//description = "<font color = #8C7853><center><b>Long Sword:</b><br>3-7 Damage"

				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 7
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"


				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BroadSword
				icon_state="BroadSword"
				typi = "weapon"
				strreq = 1
				name = "Broad Sword"
				//description = "<font color = #8C7853><center><b>Broad Sword:</b><br>2-5 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 2
				twohanded = 0
				DamageMin = 2
				DamageMax = 5
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			WarSword
				icon_state="WarSword"
				typi = "weapon"
				strreq = 1
				name = "War Sword"
				//description = "<font color = #8C7853><center><b>War Sword:</b><br>4-9 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 1
				DamageMin = 4
				DamageMax = 9
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleSword
				icon_state="BattleSword"
				typi = "weapon"
				strreq = 1
				name = "Battle Sword"
				//description = "<font color = #8C7853><center><b>Battle Sword:</b><br>3-6 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 2
				twohanded = 0
				DamageMin = 3
				DamageMax = 6
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*DblClick(mob/players/Defender/M)       //When the mob buenergys into another mob
					if (istype(M,/mob/players/Defender))    //If the mob is a PC...
						Attack(M)
				proc/Attack(mob/players/Defender/M)
					//flick("Giu_attack",src)
					sleep(2)  //This give the animation time to play, and sets the attack  delay for this mob.  Dont put this on PCs or evil little errors will keep popping up.  I can make it different though so just ask me how to make a more advanced attack verb for PCs.
					if (prob(M.tempevade))
						view(src) << "[src] \red misses <font color = gold>[M]"
					else
						HitPlayer(M)*/
			WarAxe
				icon_state="WarAxe"
				typi = "weapon"
				strreq = 1
				name = "War Axe"
				//description = "<font color = #8C7853><center><b>War Axe:</b><br>4-6 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 4
				DamageMax = 6
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleAxe
				icon_state="BattleAxe"
				typi = "weapon"
				strreq = 1
				name = "Battle Axe"
				//description = "<font color = #8C7853><center><b>Battle Axe:</b><br>3-4 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				//DblClick()				//If you double click the tree()
			BattleHammer //name of object
				icon_state = "BattleHammer" //icon state of object
				typi = "weapon"
				strreq = 1
				name = "Battle Hammer"
				//description = "<font color = #8C7853><center><b>Battle Hammer:</b><br>3-4 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 1
				twohanded = 0
				DamageMin = 3
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			WarHammer //name of object
				icon_state = "WarHammer" //icon state of object
				typi = "weapon"
				strreq = 1
				name = "War Hammer"
				description = "<font color = #8C7853><center><b>War Hammer:</b><br>3-8 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 8
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Axe
				icon_state="Axe"
				typi = "AX"
				strreq = 1
				name = "Axe"
				//description = "<font color = #8C7853><center><b>Axe:</b><br>2-4 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 1
				DamageMin = 2
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				//DblClick()				//If you double click the tree()
			WarMaul //name of object
				icon_state = "WarMaul" //icon state of object
				typi = "weapon"
				strreq = 1
				name = "War Maul"
				//description = "<font color = #8C7853><center><b>War Maul:</b><br>3-4 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleMaul //name of object
				icon_state = "BattleMaul" //icon state of object
				typi = "weapon"
				strreq = 1
				name = "Battle Maul"
				//description = "<font color = #8C7853><center><b>Battle Maul:</b><br>2-3 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 2
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Hammer //name of object
				icon_state = "Hammer" //icon state of object
				typi = "HM"
				strreq = 1
				name = "Iron Hammer"
				//description = "<font color = #8C7853><center><b>Iron Hammer:</b><br>1-3 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 1
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			StoneHammer //name of object
				icon_state = "StoneHammer" //icon state of object
				typi = "SHM"
				strreq = 1
				name = "Stone Hammer"
				//description = "<font color = #8C7853><center><b>Stone Hammer:</b><br>1-2 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 1
				DamageMax = 2
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
			StoneAxe //name of object
				icon_state = "StoneAxe" //icon state of object
				typi = "SAX"
				strreq = 1
				name = "Stone Axe"
				//description = "<font color = #8C7853><center><b>Stone Hammer:</b><br>1-2 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 2
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()

			WarScythe //name of object
				icon_state = "WarScythe" //icon state of object
				typi = "weapon"
				strreq = 1
				name = "War Scythe"
				//description = "<font color = #8C7853><center><b>War Scythe:</b><br>5-8 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 5
				DamageMax = 8
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleScythe //name of object
				icon_state = "BattleScythe" //icon state of object
				typi = "weapon"
				strreq = 1
				name = "Battle Scythe"
				//description = "<font color = #8C7853><center><b>Battle Scythe:</b><br>4-7 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 4
				DamageMax = 7
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						//set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.WarHammer=1
					Drop()
						//set category = "Commands"
						set src in usr
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)
							M.WarHammer=0*/

			Gloves //name of object
				icon_state = "gloves" //icon state of object
				typi = "GV"
				strreq = 1
				name = "Gloves"
				//description = "<font color = #8C7853><center><b>Gloves:</b><br>3 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>Worth [Worth]"

			Flint //name of object
				icon_state = "Flint" //icon state of object
				typi = "FL"
				strreq = 1
				name = "Flint"
				//description = "<font color = #8C7853><center><b>Flint:</b><br>0 Damage"
				Worth = 1
				//amount = 1
				wpnspd = 4
				tlvl = 1
				twohanded = 0
				DamageMin = 0
				DamageMax = 0
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Pyrite //name of object
				icon_state = "pyrite" //icon state of object
				typi = "PY"
				strreq = 1
				name = "Pyrite"
				//description = "<font color = #8C7853><center><b>Pyrite:</b><br>0 Damage"
				Worth = 0
				//amount = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 0
				DamageMax = 0
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"


				/*verb //verb for the object (verb it's what you do)
					Get()
						//set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.Gloves=1
					Drop()
						//set category = "Commands"
						set src in usr
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)
							M.Gloves=0*/

			FishingPole //name of object
				icon_state = "546" //icon state of object
				typi = "FP"
				strreq = 1
				name = "Fishing Pole"
				//description = "<font color = #8C7853><center><b>Fishing Pole:</b><br>1-2 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 1
				DamageMax = 2
				//plane = POLE_LAYER
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						//set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.Rod=1
					Drop()
						//set category = "Commands"
						set src in usr
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)
							M.Rod=0*/

			PickAxe //name of object
				icon_state = "PickAxe" //icon state of object
				typi = "PX"
				strreq = 1
				name = "PickAxe"
				//description = "<font color = #8C7853><center><b>Pick Axe:</b><br>1-5 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 1
				DamageMax = 5
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			UeikPickaxe //name of object
				icon_state = "UeikPickAxe" //icon state of object
				typi = "UPK"
				strreq = 1
				name = "Ueik PickAxe"
				//description = "<font color = #8C7853><center><b>Ueik Pick Axe:</b><br>1-3 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 1
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						//set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.PickAxe=1
					Drop()
						//set category = "Commands"
						set src in usr
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)
							M.PickAxe=0*/
			Shovel//name of object
				icon_state = "Shovel" //icon state of object
				typi = "SH"
				strreq = 1
				name = "Shovel"
				//description = "<font color = #8C7853><center><b>Shovel:</b><br>1-4 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 1
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			CarvingKnife//name of object
				icon_state = "CarvingKnife" //icon state of object
				typi = "CK"
				strreq = 1
				name = "Carving Knife"
				//description = "<font color = #8C7853><center><b>Carving Knife:</b><br>3-6 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 3
				DamageMax = 6
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			ObsidianKnife//name of object
				icon_state = "ObsidianKnife" //icon state of object
				typi = "OK"
				strreq = 1
				name = "Obsidian Knife"
				//description = "<font color = #8C7853><center><b>Obsidian Knife:</b><br>1-4 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 1
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Hoe//For gardening/farming
				icon_state = "hoe" //icon state of object
				typi = "HO"
				strreq = 1
				name = "Hoe"
				//description = "<font color = #8C7853><center><b>Hoe:</b><br>1-3 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 1
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Sickle//For harvesting/cutting sprouts
				icon_state = "sickle" //icon state of object
				typi = "SK"
				strreq = 1
				name = "Sickle"
				//description = "<font color = #8C7853><center><b>Sickle:</b><br>4-6 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 4
				DamageMax = 6
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Trowel//For brickwork building, made from steel, hi-lv tool
				icon_state = "trowel" //icon state of object
				typi = "TW"
				strreq = 1
				name = "Trowel"
				//description = "<font color = #8C7853><center><b>Steel Trowel:</b><br>2-4 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 2
				DamageMax = 4
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			Chisel//For stonework, making stone into bricks
				icon_state = "Chisel" //icon state of object
				typi = "CH"
				strreq = 1
				name = "Chisel"
				//description = "<font color = #8C7853><center><b>Iron Chisel:</b><br>1-3 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 0
				DamageMin = 1
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			File//For Smithing, For testing metal hardness after quenching
				icon_state = "File" //icon state of object
				typi = "FI"
				strreq = 1
				name = "File"
				//description = "<font color = #8C7853><center><b>Iron Chisel:</b><br>1-3 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 1
				twohanded = 0
				DamageMin = 1
				DamageMax = 2
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
				New()
					..()
					Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"
//QFSP - File
//Tool Parts "Carving Knife blade","Hammer head","File blade","Axe blade","Pickaxe head","Shovel blade","Hoe blade","Saw blade","Sickle blade","Chisel Blade","Trowel blade"
				proc/FindHMf(mob/players/M)
					for(var/obj/items/Crafting/Created/HammerHead/J in M.contents)//Hammer Head
						locate(J)
						if(J:needsfiled==1)
							return J
				proc/FindCKf(mob/players/M)
					for(var/obj/items/Crafting/Created/CKnifeblade/J1 in M.contents)//Carving Knife
						locate(J1)
						if(J1:needsfiled==1)
							return J1
				proc/FindSBf(mob/players/M)
					for(var/obj/items/Crafting/Created/SickleBlade/J2 in M.contents)//Sickle
						locate(J2)
						if(J2:needsfiled==1)
							return J2
				proc/FindTWBf(mob/players/M)
					for(var/obj/items/Crafting/Created/TrowelBlade/J3 in M.contents)//Trowel
						locate(J3)
						if(J3:needsfiled==1)
							return J3
				proc/FindCBf(mob/players/M)
					for(var/obj/items/Crafting/Created/ChiselBlade/J4 in M.contents)//Chisel
						locate(J4)
						if(J4:needsfiled==1)
							return J4
				proc/FindAHf(mob/players/M)
					for(var/obj/items/Crafting/Created/AxeHead/J5 in M.contents)//Axe
						locate(J5)
						if(J5:needsfiled==1)
							return J5
				proc/FindFBf(mob/players/M)
					for(var/obj/items/Crafting/Created/FileBlade/J6 in M.contents)//File
						locate(J6)
						if(J6:needsfiled==1)
							return J6
				proc/FindSHf(mob/players/M)
					for(var/obj/items/Crafting/Created/ShovelHead/J7 in M.contents)//Shovel
						locate(J7)
						if(J7:needsfiled==1)
							return J7
				proc/FindHOf(mob/players/M)
					for(var/obj/items/Crafting/Created/HoeBlade/J8 in M.contents)//Hoe
						locate(J8)
						if(J8:needsfiled==1)
							return J8
				proc/FindPXf(mob/players/M)
					for(var/obj/items/Crafting/Created/PickaxeHead/J9 in M.contents)//Pickaxe
						locate(J9)
						if(J9:needsfiled==1)
							return J9
				proc/FindSWf(mob/players/M)
					for(var/obj/items/Crafting/Created/SawBlade/J10 in M.contents)//Saw
						locate(J10)
						if(J10:needsfiled==1)
							return J10
//Weapon Check   "Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","Battle Scythe","War Scythe"

				proc/FindBSf(mob/players/M)
					for(var/obj/items/Crafting/Created/Broadswordblade/J11 in M.contents)//Broad Sword
						locate(J11)
						if(J11:needsfiled==1)
							return J11
				proc/FindWSf(mob/players/M)
					for(var/obj/items/Crafting/Created/Warswordblade/J12 in M.contents)//War Sword
						locate(J12)
						if(J12:needsfiled==1)
							return J12
				proc/FindBSWf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battleswordblade/J13 in M.contents)//Battle Sword
						locate(J13)
						if(J13:needsfiled==1)
							return J13
				proc/FindLSf(mob/players/M)
					for(var/obj/items/Crafting/Created/Longswordblade/J14 in M.contents)//Long Sword
						locate(J14)
						if(J14:needsfiled==1)
							return J14
				proc/FindWMf(mob/players/M)
					for(var/obj/items/Crafting/Created/Warmaulhead/J15 in M.contents)//War Maul
						locate(J15)
						if(J15:needsfiled==1)
							return J15
				proc/FindBHf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battlehammersledge/J16 in M.contents)//Battle Hammer
						locate(J16)
						if(J16:needsfiled==1)
							return J16
				proc/FindWXf(mob/players/M)
					for(var/obj/items/Crafting/Created/Waraxeblade/J17 in M.contents)//War Axe
						locate(J17)
						if(J17:needsfiled==1)
							return J17
				proc/FindBXf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battleaxeblade/J18 in M.contents)//Battle Axe
						locate(J18)
						if(J18:needsfiled==1)
							return J18
				proc/FindWSYf(mob/players/M)
					for(var/obj/items/Crafting/Created/Warscytheblade/J19 in M.contents)//War Scythe
						locate(J19)
						if(J19:needsfiled==1)
							return J19
				proc/FindBSYf(mob/players/M)
					for(var/obj/items/Crafting/Created/Battlescytheblade/J20 in M.contents)//Battle Scythe
						locate(J20)
						if(J20:needsfiled==1)
							return J20

//Lamp

				proc/FindILf(mob/players/M)
					for(var/obj/items/Crafting/Created/IronLampHead/J21 in M.contents)//Iron Lamp Head
						locate(J21)
						if(J21:needsfiled==1)
							return J21
				proc/FindCLf(mob/players/M)
					for(var/obj/items/Crafting/Created/CopperLampHead/J22 in M.contents)//Copper Lamp Head
						locate(J22)
						if(J22:needsfiled==1)
							return J22
				proc/FindBRLf(mob/players/M)
					for(var/obj/items/Crafting/Created/BronzeLampHead/J23 in M.contents)//Bronze Lamp Head
						locate(J23)
						if(J23:needsfiled==1)
							return J23
				proc/FindBSLf(mob/players/M)
					for(var/obj/items/Crafting/Created/BrassLampHead/J24 in M.contents)//Brass Lamp Head
						locate(J24)
						if(J24:needsfiled==1)
							return J24
				proc/FindSLf(mob/players/M)
					for(var/obj/items/Crafting/Created/SteelLampHead/J25 in M.contents)//Steel Lamp Head
						locate(J25)
						if(J25:needsfiled==1)
							return J25



				proc/Fle()//working
					set src in usr
					var/mob/players/M
					M = usr
					//var/obj/items/Crafting/Created/Whetstone/S = locate() in M.contents
//Tool Call
					var/obj/items/Crafting/Created/HammerHead/J = call(/obj/items/tools/File/proc/FindHMf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/CKnifeblade/J1 = call(/obj/items/tools/File/proc/FindCKf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/SickleBlade/J2 = call(/obj/items/tools/File/proc/FindSBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/TrowelBlade/J3 = call(/obj/items/tools/File/proc/FindTWBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/ChiselBlade/J4 = call(/obj/items/tools/File/proc/FindCBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/AxeHead/J5 = call(/obj/items/tools/File/proc/FindAHf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/FileBlade/J6 = call(/obj/items/tools/File/proc/FindFBf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/ShovelHead/J7 = call(/obj/items/tools/File/proc/FindSHf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/HoeBlade/J8 = call(/obj/items/tools/File/proc/FindHOf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/PickaxeHead/J9 = call(/obj/items/tools/File/proc/FindPXf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/SawBlade/J10 = call(/obj/items/tools/File/proc/FindSWf)(M)//locate() in M.contents
//Weapon Call

					var/obj/items/Crafting/Created/Broadswordblade/J11 = call(/obj/items/tools/File/proc/FindBSf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Warswordblade/J12 = call(/obj/items/tools/File/proc/FindWSf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battleswordblade/J13 = call(/obj/items/tools/File/proc/FindBSWf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Longswordblade/J14 = call(/obj/items/tools/File/proc/FindLSf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Warmaulhead/J15 = call(/obj/items/tools/File/proc/FindWMf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battlehammersledge/J16 = call(/obj/items/tools/File/proc/FindBHf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Waraxeblade/J17 = call(/obj/items/tools/File/proc/FindWXf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battleaxeblade/J18 = call(/obj/items/tools/File/proc/FindBXf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Warscytheblade/J19 = call(/obj/items/tools/File/proc/FindWSYf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/Battlescytheblade/J20 = call(/obj/items/tools/File/proc/FindBSYf)(M)//locate() in M.contents

//Lamp Call

					var/obj/items/Crafting/Created/IronLampHead/J21 = call(/obj/items/tools/File/proc/FindILf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/CopperLampHead/J22 = call(/obj/items/tools/File/proc/FindCLf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/BronzeLampHead/J23 = call(/obj/items/tools/File/proc/FindBRLf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/BrassLampHead/J24 = call(/obj/items/tools/File/proc/FindBSLf)(M)//locate() in M.contents
					var/obj/items/Crafting/Created/SteelLampHead/J25 = call(/obj/items/tools/File/proc/FindSLf)(M)//locate() in M.contents

//Tool Quench Check
					if(J)
						if(J.needsquenched==1)
							M << "[J] needs to be quenched before testing."
							return
						else if(J.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J1)
						if(J1.needsquenched==1)
							M << "[J1] needs to be quenched before testing."
							return
						else if(J1.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J2)
						if(J2.needsquenched==1)
							M << "[J2] needs to be quenched before testing."
							return
						else if(J2.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J3)
						if(J3.needsquenched==1)
							M << "[J3] needs to be quenched before testing."
							return
						else if(J3.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J4)
						if(J4.needsquenched==1)
							M << "[J4] needs to be quenched before testing."
							return
						else if(J4.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J5)
						if(J5.needsquenched==1)
							M << "[J5] needs to be quenched before testing."
							return
						else if(J5.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J6)
						if(J6.needsquenched==1)
							M << "[J6] needs to be quenched before testing."
							return
						else if(J6.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J7)
						if(J7.needsquenched==1)
							M << "[J7] needs to be quenched before testing."
							return
						else if(J7.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J8)
						if(J8.needsquenched==1)
							M << "[J8] needs to be quenched before testing."
							return
						else if(J8.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J9)
						if(J9.needsquenched==1)
							M << "[J9] needs to be quenched before testing."
							return
						else if(J9.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J10)
						if(J10.needsquenched==1)
							M << "[J10] needs to be quenched before testing."
							return
						else if(J10.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
//Weapon Quench Check
					if(J11)
						if(J11.needsquenched==1)
							M << "[J11] needs to be quenched before testing."
							return
						else if(J11.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J12)
						if(J12.needsquenched==1)
							M << "[J12] needs to be quenched before testing."
							return
						else if(J12.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J13)
						if(J13.needsquenched==1)
							M << "[J13] needs to be quenched before testing."
							return
						else if(J13.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J14)
						if(J14.needsquenched==1)
							M << "[J14] needs to be quenched before testing."
							return
						else if(J14.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J15)
						if(J15.needsquenched==1)
							M << "[J15] needs to be quenched before testing."
							return
						else if(J15.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J16)
						if(J16.needsquenched==1)
							M << "[J16] needs to be quenched before testing."
							return
						else if(J16.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J17)
						if(J17.needsquenched==1)
							M << "[J17] needs to be quenched before testing."
							return
						else if(J17.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J18)
						if(J18.needsquenched==1)
							M << "[J18] needs to be quenched before testing."
							return
						else if(J18.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J19)
						if(J19.needsquenched==1)
							M << "[J19] needs to be quenched before testing."
							return
						else if(J19.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J20)
						if(J20.needsquenched==1)
							M << "[J20] needs to be quenched before testing."
							return
						else if(J20.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
//Lamp Check
					else if(J21)
						if(J21.needsquenched==1)
							M << "[J21] needs to be quenched before testing."
							return
						else if(J21.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J22)
						if(J22.needsquenched==1)
							M << "[J22] needs to be quenched before testing."
							return
						else if(J22.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J23)
						if(J23.needsquenched==1)
							M << "[J23] needs to be quenched before testing."
							return
						else if(J23.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J24)
						if(J24.needsquenched==1)
							M << "[J24] needs to be quenched before testing."
							return
						else if(J24.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
					else if(J25)
						if(J25.needsquenched==1)
							M << "[J25] needs to be quenched before testing."
							return
						else if(J25.needsfiled==0)
							M << "You can tell this item passes the hardness test, it must have been quenched well."
							return
//Tool Process
					if(J)
						if(prob(50))
							M<<"You run the File across the [J]."
							J.needsfiled=0
							sleep(3)
							J.needsquenched=0
							//insert sfx and flick an animation
							M<<"[J] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J] doesn't test well for hardness. Quench Again."
							J.needsquenched=1
							return
					else if(J1)
						if(prob(50))
							M<<"You run the File across the [J1]."
							J1.needsfiled=0
							J1.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J1] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J1]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J1] doesn't test well for hardness. Quench Again."
							J1.needsquenched=1
							return
					else if(J2)
						if(prob(50))
							M<<"You run the File across the [J2]."
							J2.needsfiled=0
							J2.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J2] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J2]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J2] doesn't test well for hardness. Quench Again."
							J2.needsquenched=1
							return
					else if(J3)
						if(prob(50))
							M<<"You run the File across the [J3]."
							J3.needsfiled=0
							J3.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J3] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J3]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J3] doesn't test well for hardness. Quench Again."
							J3.needsquenched=1
							return
					else if(J4)
						if(prob(50))
							M<<"You run the File across the [J4]."
							J4.needsfiled=0
							J4.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J4] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J4]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J4] doesn't test well for hardness. Quench Again."
							J4.needsquenched=1
							return
					else if(J5)
						if(prob(50))
							M<<"You run the File across the [J5]."
							J5.needsfiled=0
							J5.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J5] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J5]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J5] doesn't test well for hardness. Quench Again."
							J5.needsquenched=1
							return
					else if(J6)
						if(prob(50))
							M<<"You run the File across the [J6]."
							J6.needsfiled=0
							J6.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J6] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J6]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J6] doesn't test well for hardness. Quench Again."
							J6.needsquenched=1
							return
					else if(J7)
						if(prob(50))
							M<<"You run the File across the [J7]."
							J7.needsfiled=0
							J7.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J7] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J7]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J7] doesn't test well for hardness. Quench Again."
							J7.needsquenched=1
							return
					else if(J8)
						if(prob(50))
							M<<"You run the File across the [J8]."
							J8.needsfiled=0
							J8.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J8] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J8]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J8] doesn't test well for hardness. Quench Again."
							J8.needsquenched=1
							return
					else if(J9)
						if(prob(50))
							M<<"You run the File across the [J9]."
							J9.needsfiled=0
							J9.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J9] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J9]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J9] doesn't test well for hardness. Quench Again."
							J9.needsquenched=1
							return
					else if(J10)
						if(prob(50))
							M<<"You run the File across the [J10]."
							J10.needsfiled=0
							J10.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J10] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J10]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J10] doesn't test well for hardness. Quench Again."
							J10.needsquenched=1
							return
//Weapon Process
					else if(J11)
						if(prob(50))
							M<<"You run the File across the [J11]."
							J11.needsfiled=0
							J11.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J11] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J11]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J11] doesn't test well for hardness. Quench Again."
							J11.needsquenched=1
							return
					else if(J12)
						if(prob(50))
							M<<"You run the File across the [J12]."
							J12.needsfiled=0
							J12.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J12] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J12]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J12] doesn't test well for hardness. Quench Again."
							J12.needsquenched=1
							return
					else if(J13)
						if(prob(50))
							M<<"You run the File across the [J13]."
							J13.needsfiled=0
							J13.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J13] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J13]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J13] doesn't test well for hardness. Quench Again."
							J13.needsquenched=1
							return
					else if(J14)
						if(prob(50))
							M<<"You run the File across the [J14]."
							J14.needsfiled=0
							J14.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J14] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J14]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J14] doesn't test well for hardness. Quench Again."
							J14.needsquenched=1
							return
					else if(J15)
						if(prob(50))
							M<<"You run the File across the [J15]."
							J15.needsfiled=0
							J15.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J15] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J15]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J15] doesn't test well for hardness. Quench Again."
							J15.needsquenched=1
							return
					else if(J16)
						if(prob(50))
							M<<"You run the File across the [J16]."
							J6.needsfiled=0
							J6.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J16] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J16]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J16] doesn't test well for hardness. Quench Again."
							J16.needsquenched=1
							return
					else if(J17)
						if(prob(50))
							M<<"You run the File across the [J17]."
							J17.needsfiled=0
							J17.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J17] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J17]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J17] doesn't test well for hardness. Quench Again."
							J17.needsquenched=1
							return
					else if(J18)
						if(prob(50))
							M<<"You run the File across the [J18]."
							J18.needsfiled=0
							J18.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J18] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J18]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J18] doesn't test well for hardness. Quench Again."
							J18.needsquenched=1
							return
					else if(J19)
						if(prob(50))
							M<<"You run the File across the [J19]."
							J19.needsfiled=0
							J19.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J19] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J19]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J19] doesn't test well for hardness. Quench Again."
							J19.needsquenched=1
							return
					else if(J20)
						if(prob(50))
							M<<"You run the File across the [J20]."
							J20.needsfiled=0
							J20.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J20] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J20]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J20] doesn't test well for hardness. Quench Again."
							J20.needsquenched=1
							return
//Lamp Process
					else if(J21)
						if(prob(50))
							M<<"You run the File across the [J21]."
							J21.needsfiled=0
							J21.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J21] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J21]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J21] doesn't test well for hardness. Quench Again."
							J21.needsquenched=1
							return
					else if(J22)
						if(prob(50))
							M<<"You run the File across the [J22]."
							J22.needsfiled=0
							J22.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J22] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J22]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J22] doesn't test well for hardness. Quench Again."
							J22.needsquenched=1
							return
					else if(J23)
						if(prob(50))
							M<<"You run the File across the [J23]."
							J23.needsfiled=0
							J23.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J23] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J23]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J23] doesn't test well for hardness. Quench Again."
							J23.needsquenched=1
							return
					else if(J24)
						if(prob(50))
							M<<"You run the File across the [J24]."
							J24.needsfiled=0
							J24.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J24] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J24]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J24] doesn't test well for hardness. Quench Again."
							J24.needsquenched=1
							return
					else if(J25)
						if(prob(50))
							M<<"You run the File across the [J25]."
							J25.needsfiled=0
							J25.needsquenched=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"[J25] has passed the hardness test!"
							return
						else
							M<<"You run the File across the [J25]."
							//J.needsfiled=0
							sleep(3)
							//insert sfx and flick an animation
							M<<"The [J25] doesn't test well for hardness. Quench Again."
							J25.needsquenched=1
							return

			Saw
				icon_state = "Saw" //icon state of object
				typi = "SW"
				strreq = 1
				name = "Saw"
				//description = "<font color = #8C7853><center><b>Iron Chisel:</b><br>1-3 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 1
				twohanded = 0
				DamageMin = 1
				DamageMax = 3
				verb/Description()//Fixes description
					set category=null
					set popup_menu=1
					set src in usr
					//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					//return
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				New()
					..()
					Description()
				/*verb //verb for the object (verb it's what you do)
					Get()
						//set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.PickAxe=2
					Drop()
						//set category = "Commands"
						set src in usr
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)*/
			Containers
				var/volume = 0
				var/volumecap = 0
				var/CType = 0//contents Type 0 empty 1 water 2 tar 3 oil
				var/filled = 0
				FruitPress //name of object
					icon_state = "FruitPress" //icon state of object
					//typi = "JR"
					strreq = 1
					name = "Fruit Press"
					//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
					Worth = 1
					//wpnspd = 1
					CType = "Empty"
					volume = 0
					volumecap = 50
					tlvl = 1
					twohanded = 1
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>A container that can press the liquids out of fruit.<br>Volume% [volume]-[volumecap]<br>Contents [CType]<br>Worth [Worth]"

					proc/FindJ(mob/players/M)
						for(var/obj/items/tools/Containers/J2 in M.contents)
							if(J2)
								return J2
					proc/FindV(mob/players/M)
						for(var/obj/items/tools/Containers/Vessel/J2 in M.contents)
							if(J2)
								return J2
					verb/Fill_Fruit_Press()
						set category=null
						set popup_menu=1
						var/mob/players/M = usr
						var/obj/items/plant/Fruit/olives/J = locate() in M.contents
						if(!J)
							M << "Need Olives to fill the press with."
							return
						else if(J.stack_amount>=5&&volume==0&&src.CType=="Empty"&&src.name=="Fruit Press")
							volume=volumecap
							CType="Olives"
							J.RemoveFromStack(5)
							name="Filled Fruit Press"
							return
						else
							M << "You need more olives."
							return

					verb/Press_Contents()
						set category=null
						set popup_menu=1
						var/mob/players/M = usr
						//var/obj/items/tools/Containers/FruitPress/J = locate() in M.contents
						var/obj/items/tools/Containers/J2 = FindJ(M)
						//if(!J2)
							//M << "Need a container to fill with the result."
							//return
						if(J2.name=="Jar"||J2.name=="Vessel")
							if(name=="Filled Fruit Press"&&src.CType=="Olives")
								//set category = "Commands"
								//overlays -= /obj/vliquid
								name="Pressed Fruit Press"
								M<<"You press the juice out of the contents."
								icon_state="FruitPressPressed"
								//var/obj/items/tools/Containers/J2 = locate() in M.contents
								if(J2.name=="Jar"&&J2.CType=="Empty")
									J2.volume = 25
									J2.CType="Oil"
									J2.icon_state = "Jaro"
									M << "You fill the Jar with the result."
									return
								else if(J2.name=="Vessel"&&J2.CType=="Empty")
									J2.volume = 25
									J2.CType="Oil"
									J2.icon_state = "Vesselohf"
									M << "You fill the Vessel with the result."
									return
								else if(J2.name=="Half Filled Vessel"&&J2.CType=="Oil")
									J2.volume = 50
									J2.icon_state = "Vesselo"
									M << "You fill the Vessel with the result."
									return


							else
								M<<"The Fruit Press must be filled to use."
								return

					verb/Empty()//still need to setup a fill on the water turf and cactus/vine
						set category=null
						set popup_menu=1
						var/mob/players/M = usr
						//var/obj/items/tools/Containers/FruitPress/J = locate() in M.contents
						if(name=="Filled Fruit Press"&&src.CType=="Oil")
							//set category = "Commands"
							//overlays -= /obj/vliquid
							icon_state="FruitPress"
							name="Fruit Press"
							CType="Empty"
							volume=0
							M<<"You empty the Oil in the Fruit Press on to the ground."
							return
						else
							M<<"The Fruit Press is already empty."
							return
					New()
						..()
						Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Volume %[volume]-%[volumecap]<br>Contents [CType]<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"


				UnbakedJar //name of object
					icon = 'dmi/64/inven.dmi'
					icon_state = "UBJar" //icon state of object
					//typi = "JR"
					//strreq = 1
					plane = 4
					name = "Unbaked Jar"
					//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
					Worth = 1
					//wpnspd = 1
					//tlvl = 1
					//twohanded = 1
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>A shapely formed Clay Jar. It is unbaked and needs to be baked in a fire.<br>Worth [Worth]"


				Jar //name of object

					icon_state = "Jar" //icon state of object
					typi = "JR"
					strreq = 1
					name = "Jar"
					//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
					plane = 4
					Worth = 1
					wpnspd = 1
					tlvl = 1
					volume = 0
					volumecap = 25
					filled = 0
					//Description()//description = "<br><font color = #e6e8fa><center><b>Clay Jar</b> A simple clay jar for carrying water."
					CType = "Empty"//Contents Type
					twohanded = 1
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>A Container you can drink from or use to store various liquids.<br>e.[src.suffix]<br>Volume [volume]-[volumecap]<br>Contents [CType]<br>Worth [Worth]"

					verb/Drink()
						var/mob/players/M
						M = usr
						var/obj/items/tools/Containers/Jar/J = FindJar(M)
						//if(J.filled==1)
						//	J.CType="Water"
						//locate(J)
						for(J)//streamlined and working
						//if(suffix=="Equipped"&&M.JRequipped==1&&filled==1&&CType=="Water")
							set category=null
							set popup_menu=1
							usingjar(M,100)
							icon_state = "Jar"
							volume = 0
							//if(volume<0)
							//	volume=0
							//M<<"You drink the contents of the Jar."
							CType="Empty"
							name = "Jar"
							filled=0
							return
						/*else if(J.filled==1&&J.CType=="Tar"||J.filled==1&&J.CType=="Oil"||J.filled==1&&J.CType=="Sand")
							M<<"You don't want to drink that."
							return*/
						//else if(J.filled==1&&J.CType=="Oil")
							//M<<"You don't want to drink that."
							//return
						if(J.filled==0&&M.JRequipped==0)
							M<<"You need to hold and fill the Jar to drink out of it."
							return
						else if(J.filled==0&&M.JRequipped==1)
							M<<"You need to fill the Jar to drink out of it."
							return

					proc/FindJar(mob/players/M)
						for(var/obj/items/tools/Containers/Jar/J in M.contents)
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&J.CType=="Water")
								return J
							else
								//M << "Need to hold a Filled Jar."
								return


					proc/FindVes(mob/players/M)
						for(var/obj/items/tools/Containers/Vessel/J in M.contents)
							if(J.name=="Filled Vessel"||J.name=="Half Filled Vessel")
								return J

					verb/Fill_Jar_with_Vessel()
						set category=null
						set popup_menu=1
						var/mob/players/M = usr
						var/obj/items/tools/Containers/Vessel/J = FindVes(M)
						if(!J)
							M << "Need a Filled Vessel to fill the Jar."
							return
						else if(src.suffix=="Equipped"&&src.name=="Jar"&&src.CType=="Empty"&&src.filled==0)
							if(J.name=="Filled Vessel"&&src.name=="Jar"&&J.CType=="Water"||J.name=="Half Filled Vessel"&&src.name=="Jar"&&J.CType=="Water")
//Water into Jar from Vessel
								if(J.name=="Half Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vessel"
									src.icon_state = "Jarw"
									src.volume = 25
									src.filled = 1
									src.name = "Filled Jar"
									src.CType="Water"
									J.volume = 0
									M<<"The Vessel is empty."
									J.name="Vessel"
									J.CType="Empty"
									return
								else if(J.name=="Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vesselwhf"
									src.icon_state = "Jarw"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Water"
									J.volume = 25
									J.name="Half Filled Vessel"
									if(src.volume>src.volumecap)
										src.volume=src.volumecap
									if(J.volume<0)
										J.volume=0
										M<<"The Vessel is empty."
									return
								else if(J.name=="Vessel")
									M<<"This Vessel is empty."
									return
								else if(src.name=="Filled Jar")
									M<<"This Jar is full."
									return
//Tar into Jar from Vessel
							if(J.name=="Filled Vessel"&&src.name=="Jar"&&J.CType=="Tar"||J.name=="Half Filled Vessel"&&src.name=="Jar"&&J.CType=="Tar")

								if(J.name=="Half Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vessel"
									src.icon_state = "Jart"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Tar"
									J.volume = 0
									M<<"The Vessel is empty."
									J.name="Vessel"
									J.CType="Empty"
									return
								else if(J.name=="Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vesselthf"
									src.icon_state = "Jart"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Tar"
									J.volume = 25
									if(src.volume>src.volumecap)
										src.volume=src.volumecap
									if(J.volume<0)
										J.volume=0
										M<<"The Vessel is empty."
									J.name="Half Filled Vessel"
									return
								else if(J.name=="Vessel")
									M<<"This Vessel is empty."
									return
								else if(src.name=="Filled Jar")
									M<<"This Jar is full."
									return
//Oil into Jar from Vessel
							if(J.name=="Filled Vessel"&&src.name=="Jar"&&J.CType=="Oil"||J.name=="Half Filled Vessel"&&src.name=="Jar"&&J.CType=="Oil")

								if(J.name=="Half Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vessel"
									src.icon_state = "Jaro"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Oil"
									J.volume = 0
									M<<"The Vessel is empty."
									J.name="Vessel"
									J.CType="Empty"
									return
								else if(J.name=="Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vesselohf"
									src.icon_state = "Jaro"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Oil"
									J.volume = 25
									if(src.volume>src.volumecap)
										src.volume=src.volumecap
									if(J.volume<0)
										J.volume=0
										M<<"The Vessel is empty."
									J.name="Half Filled Vessel"
									return
								else if(J.name=="Vessel")
									M<<"This Vessel is empty."
									return
								else if(src.name=="Filled Jar")
									M<<"This Jar is full."
									return
							if(J.name=="Filled Vessel"&&src.name=="Jar"&&J.CType=="Sand"||J.name=="Half Filled Vessel"&&src.name=="Jar"&&J.CType=="Sand")

								if(J.name=="Half Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vessel"
									src.icon_state = "Jars"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Sand"
									J.volume = 0
									M<<"The Vessel is empty."
									J.name="Vessel"
									J.CType="Empty"
									return
								else if(J.name=="Filled Vessel"&&src.name=="Jar"&&src.CType=="Empty")
									J.icon_state = "Vesselshf"
									src.icon_state = "Jars"
									src.volume = 25
									src.name = "Filled Jar"
									src.filled = 1
									src.CType="Sand"
									J.volume = 25
									if(src.volume>src.volumecap)
										src.volume=src.volumecap
									if(J.volume<0)
										J.volume=0
										M<<"The Vessel is empty."
									J.name="Half Filled Vessel"
									return
								else if(J.name=="Vessel")
									M<<"This Vessel is empty."
									return
								else if(src.name=="Filled Jar")
									M<<"This Jar is full."
									return
						else
							M << "Need to hold a Jar to fill it with the Vessel."
							return

					verb/Empty()
						set category=null
						set popup_menu=1
						var/mob/players/M = usr
						//var/obj/items/tools/Containers/Jar/J = locate() in M.contents

						if(src.CType!="Empty")
							icon_state = "Jar"
							src.volume = 0
							src.filled = 0
							src.name="Jar"
							M<<"You empty the contents in the Jar on to the ground."
							src.CType="Empty"
							return
						else if(src.CType=="Empty")
							M<<"The Jar is already empty."
							return

						/*if(src.name=="Filled Jar")
							//set category = "Commands"
							if(src.CType=="Water")
								icon_state = "Jar"
								src.volume = 0
								src.filled = 0
								src.name="Jar"
								M<<"You empty the [CType] in the Jar on to the ground."
								src.CType="Empty"
								return
							else if(src.CType=="Tar")
								icon_state = "Jar"
								src.volume = 0
								src.filled = 0
								src.name="Jar"
								M<<"You empty the [CType] in the Jar on to the ground."
								src.CType="Empty"
								return
							else if(src.CType=="Oil")
								icon_state = "Jar"
								src.volume = 0
								src.filled = 0
								src.name="Jar"
								M<<"You empty the [CType] in the Jar on to the ground."
								src.CType="Empty"
								return*/

					New()
						..()
						Description()

						//description = "<font color = #ffd700><center><b>Water Jar</b>"
					proc/usingjar(var/obj/items/tools/Containers/Jar/J,amount)
						var/mob/players/M = usr
						if (amount > (M.MAXenergy-M.energy))
							amount = (M.MAXenergy-M.energy)
						M.energy += amount
						M << "You drink the water from the Filled Jar; Ahh, Refreshing... <b>[amount] energy recovered."
						return



				Vessel //name of object
					icon_state = "Vessel" //icon state of object
					//typi = "JR"
					strreq = 1
					name = "Vessel"
					//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
					Worth = 1
					//wpnspd = 1
					volume = 0
					volumecap = 50//2 Jars to a vessel, 2 Vessels to a Barrel -- need to make them fill each other.
					tlvl = 1
					CType = "Empty"
					twohanded = 1
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>A container for storing or transfering liquids.<br>Volume% [volume]-[volumecap]<br>Contents [CType]<br>Worth [Worth]"

					proc/FindJar(mob/players/M)
						for(var/obj/items/tools/Containers/Jar/J in M.contents)
							locate(J)
							if(J:suffix=="Equipped")
								return J

							//else
							//	M << "Need to hold a Filled Jar to fill the Vessel."
							//	return
					proc/FindVes(mob/players/M)
						for(var/obj/items/tools/Containers/Vessel/J in M.contents)
							if(J.name=="Filled Vessel"||J.name=="Half Filled Vessel")
								return J
					verb/Fill_Vessel_with_Jar()
						var/mob/players/M
						M = usr
						var/obj/items/tools/Containers/Jar/J = FindJar(M)
						//locate(J)
						//if(!J)
						//	M << "Need to hold a Filled Jar to fill the Vessel."
						//	return
						//if(M.JRequipped==0)
							//M << "You need to hold a Filled Jar to fill the Vessel."
							//return
						locate(J)
						//if(J.suffix=="Equipped"&&J.name=="Jar")
						//if(M.JRequipped==0)
							//M << "You need to hold a Filled Jar to fill the Vessel."
							//return
						if(J.suffix=="Equipped"&&M.JRequipped==1&&J.name=="Filled Jar"&&src.CType=="Empty")
							goto Process
						else
							if(J.suffix=="Equipped"&&J.name=="Jar")
								M << "You need to hold a Filled Jar to fill the Vessel."
								return
						if(J.CType=="Water"&&src.CType=="Tar"||J.CType=="Water"&&src.CType=="Oil"||J.CType=="Water"&&src.CType=="Sand")
							//M<<"You don't need to mix contents."
							return
						else if(J.CType=="Tar"&&src.CType=="Water"||J.CType=="Tar"&&src.CType=="Oil"||J.CType=="Tar"&&src.CType=="Sand")
							//M<<"You don't need to mix contents."
							return
						else if(J.CType=="Oil"&&src.CType=="Tar"||J.CType=="Oil"&&src.CType=="Water"||J.CType=="Oil"&&src.CType=="Sand")
							//M<<"You don't need to mix contents."
							return
						else if(J.CType=="Sand"&&src.CType=="Tar"||J.CType=="Sand"&&src.CType=="Water"||J.CType=="Sand"&&src.CType=="Oil")
							//M<<"You don't need to mix contents."
							return
						else if(name=="Filled Vessel")
							M<<"The Vessel is full."
							return
						Process
//Vessel Empty to Half Fill from Jar for Water, Tar and Oil
						if(src.CType=="Empty")//If the Vessel Contents is empty
							locate(J)
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Vessel"&&J.CType=="Water"&&src.CType=="Empty")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.CType="Empty"
								J.name = "Jar"
								src.name="Half Filled Vessel"
								src.volume=25
								J.volume=0
								src.icon_state = "Vesselwhf"
								src.CType="Water"
								sleep(1)
								M<<"You Filled the Vessel with Water."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
							locate(J)
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Vessel"&&J.CType=="Tar"&&src.CType=="Empty")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.CType="Empty"
								J.name = "Jar"
								src.name="Half Filled Vessel"
								src.volume=25
								J.volume=0
								src.icon_state = "Vesselthf"
								src.CType="Tar"
								sleep(1)
								M<<"You Filled the Vessel with Tar."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
							locate(J)
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Vessel"&&J.CType=="Oil"&&src.CType=="Empty")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.CType="Empty"
								J.name = "Jar"
								src.name="Half Filled Vessel"
								src.volume=25
								J.volume=0
								src.icon_state = "Vesselohf"
								src.CType="Oil"
								sleep(1)
								M<<"You Filled the Vessel with Oil."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Vessel"&&J.CType=="Sand"&&src.CType=="Empty")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.CType="Empty"
								J.name = "Jar"
								src.name="Half Filled Vessel"
								src.volume=25
								J.volume=0
								src.icon_state = "Vesselshf"
								src.CType="Sand"
								sleep(1)
								M<<"You Filled the Vessel with Sand."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
						else if(src.CType!="Empty")
//Vessel Full from Half fill from Jar with Water, Tar, or Oil
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Half Filled Vessel"&&J.CType=="Water"&&src.CType=="Water")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.name = "Jar"
								src.name="Filled Vessel"
								J.CType="Empty"
								src.volume=50
								if(src.volume>=src.volumecap)
									src.volume=src.volumecap
								J.volume=0
								//CType="Water"
								src.icon_state = "Vesselw"
								sleep(1)
								M<<"You Filled the Vessel full with Water."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Half Filled Vessel"&&J.CType=="Tar"&&src.CType=="Tar")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.name = "Jar"
								src.name="Filled Vessel"
								J.CType="Empty"
								src.volume=50
								if(src.volume>=src.volumecap)
									src.volume=src.volumecap
								J.volume=0
								//CType="Tar"
								src.icon_state = "Vesselt"
								sleep(1)
								M<<"You Filled the Vessel full with Tar."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Half Filled Vessel"&&J.CType=="Oil"&&src.CType=="Oil")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.name = "Jar"
								src.name="Filled Vessel"
								J.CType="Empty"
								src.volume=50
								if(src.volume>=src.volumecap)
									src.volume=src.volumecap
								J.volume=0
								//CType="Oil"
								src.icon_state = "Vesselo"
								sleep(1)
								M<<"You Filled the Vessel full with Oil."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return
							if(J.suffix=="Equipped"&&M.JRequipped==1&&J.filled==1&&src.name=="Half Filled Vessel"&&J.CType=="Sand"&&src.CType=="Sand")
								M<<"You begin filling the Vessel with the contents of the Jar."
								sleep(2)
								J.icon_state = "Jar"
								J.filled=0
								J.name = "Jar"
								src.name="Filled Vessel"
								J.CType="Empty"
								src.volume=50
								if(src.volume>=src.volumecap)
									src.volume=src.volumecap
								J.volume=0
								//CType="Oil"
								src.icon_state = "Vessels"
								sleep(1)
								M<<"You Filled the Vessel full with Sand."
								return
							else if(J.suffix=="")
								return
							else if(!J)
								return

					verb/Empty()//still need to setup a fill on the water turf and cactus/vine
						set category=null
						set popup_menu=1
						var/mob/players/M = usr
						set src in view()
						//var/obj/items/tools/Containers/Vessel/J = FindVes(M)

						if(src.CType!="Empty")
							icon_state = "Vessel"
							src.volume = 0
							src.filled = 0
							src.name="Vessel"
							M<<"You empty the contents in the Vessel on to the ground."
							src.CType="Empty"
							return
						else if(src.CType=="Empty")
							M<<"The Vessel is already empty."
							return

						/*if(name=="Filled Vessel"||name=="Half Filled Vessel")
							//set category = "Commands"

							icon_state = "Vessel"
							name="Vessel"
							//J.CType="Empty"
							volume = 0
							M<<"You empty the [CType] in the vessel on to the ground."
							CType="Empty"
							return

						else
							M<<"The Vessel is already empty."
							return*/
					New()
						..()
						Description()
						//Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Volume %[volume]-%[volumecap]<br>Contents [CType]<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				Barrel //name of object
					icon_state = "Barrel" //icon state of object
					//typi = "JR"
					strreq = 3
					name = "Barrel"
					//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
					Worth = 1
					//wpnspd = 1
					density = 1
					volume = 0
					CType = "Empty"
					volumecap = 100
					tlvl = 1
					var/pushing = 0
					blockcarry=1
					//twohanded = 1
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br> A rugged barrel with extra ribbons. Used for Quenching hot objects, among a variety of things including storage.<br>Volume% [volume]-[volumecap]<br>Contents [CType]<br>Worth [Worth]"

					verb/Quench()//working confirmed -- could probably be expanded more
						set src in view()
						var/mob/players/M
						M = usr
						var/mob/players/J = locate() in view(1,src)//call(/obj/items/tools/Containers/QuenchBox/proc/FindQB)(M)
						//var/obj/items/tools/Containers/Barrel/J2 = locate() in view(1,M)
						if(J.GVequipped==1)//testing
							if(src.CType!="Empty")
								//M << "[J] [J.name] check Filled Barrel"
								Qench()
								return
							else
								M << "Barrel must be filled to quench."
								return
								//M << "src[src] CType[CType] src.CType[src.CType]"
						else
							M << "Need to use gloves."
							return
						//if(J2)
							//M << "Barrel"
							//call(/obj/items/tools/Containers/Barrel/proc/Qench)(src)

					proc/FindHMf(mob/players/M)
						for(var/obj/items/Crafting/Created/HammerHead/J in M.contents)//Hammer Head
							locate(J)
							if(J:needsquenched==1)
								return J
					proc/FindCKf(mob/players/M)
						for(var/obj/items/Crafting/Created/CKnifeblade/J1 in M.contents)//Carving Knife
							locate(J1)
							if(J1:needsquenched==1)
								return J1
					proc/FindSBf(mob/players/M)
						for(var/obj/items/Crafting/Created/SickleBlade/J2 in M.contents)//Sickle
							locate(J2)
							if(J2:needsquenched==1)
								return J2
					proc/FindTWBf(mob/players/M)
						for(var/obj/items/Crafting/Created/TrowelBlade/J3 in M.contents)//Trowel
							locate(J3)
							if(J3:needsquenched==1)
								return J3
					proc/FindCBf(mob/players/M)
						for(var/obj/items/Crafting/Created/ChiselBlade/J4 in M.contents)//Chisel
							locate(J4)
							if(J4:needsquenched==1)
								return J4
					proc/FindAHf(mob/players/M)
						for(var/obj/items/Crafting/Created/AxeHead/J5 in M.contents)//Axe
							locate(J5)
							if(J5:needsquenched==1)
								return J5
					proc/FindFBf(mob/players/M)
						for(var/obj/items/Crafting/Created/FileBlade/J6 in M.contents)//File
							locate(J6)
							if(J6:needsquenched==1)
								return J6
					proc/FindSHf(mob/players/M)
						for(var/obj/items/Crafting/Created/ShovelHead/J7 in M.contents)//Shovel
							locate(J7)
							if(J7:needsquenched==1)
								return J7
					proc/FindHOf(mob/players/M)
						for(var/obj/items/Crafting/Created/HoeBlade/J8 in M.contents)//Hoe
							locate(J8)
							if(J8:needsquenched==1)
								return J8
					proc/FindPXf(mob/players/M)
						for(var/obj/items/Crafting/Created/PickaxeHead/J9 in M.contents)//Pickaxe
							locate(J9)
							if(J9:needsquenched==1)
								return J9
					proc/FindSWf(mob/players/M)
						for(var/obj/items/Crafting/Created/SawBlade/J10 in M.contents)//Saw
							locate(J10)
							if(J10:needsquenched==1)
								return J10
		//Weapon Check   "Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","Battle Scythe","War Scythe"

					proc/FindBSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Broadswordblade/J11 in M.contents)//Broad Sword
							locate(J11)
							if(J11:needsquenched==1)
								return J11
					proc/FindWSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warswordblade/J12 in M.contents)//War Sword
							locate(J12)
							if(J12:needsquenched==1)
								return J12
					proc/FindBSWf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battleswordblade/J13 in M.contents)//Battle Sword
							locate(J13)
							if(J13:needsquenched==1)
								return J13
					proc/FindLSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Longswordblade/J14 in M.contents)//Long Sword
							locate(J14)
							if(J14:needsquenched==1)
								return J14
					proc/FindWMf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warmaulhead/J15 in M.contents)//War Maul
							locate(J15)
							if(J15:needsquenched==1)
								return J15
					proc/FindBHf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battlehammersledge/J16 in M.contents)//Battle Hammer
							locate(J16)
							if(J16:needsquenched==1)
								return J16
					proc/FindWXf(mob/players/M)
						for(var/obj/items/Crafting/Created/Waraxeblade/J17 in M.contents)//War Axe
							locate(J17)
							if(J17:needsquenched==1)
								return J17
					proc/FindBXf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battleaxeblade/J18 in M.contents)//Battle Axe
							locate(J18)
							if(J18:needsquenched==1)
								return J18
					proc/FindWSYf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warscytheblade/J19 in M.contents)//War Scythe
							locate(J19)
							if(J19:needsquenched==1)
								return J19
					proc/FindBSYf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battlescytheblade/J20 in M.contents)//Battle Scythe
							locate(J20)
							if(J20:needsquenched==1)
								return J20

		//Lamp

					proc/FindILf(mob/players/M)
						for(var/obj/items/Crafting/Created/IronLampHead/J21 in M.contents)//Iron Lamp Head
							locate(J21)
							if(J21:needsquenched==1)
								return J21
					proc/FindCLf(mob/players/M)
						for(var/obj/items/Crafting/Created/CopperLampHead/J22 in M.contents)//Copper Lamp Head
							locate(J22)
							if(J22:needsquenched==1)
								return J22
					proc/FindBRLf(mob/players/M)
						for(var/obj/items/Crafting/Created/BronzeLampHead/J23 in M.contents)//Bronze Lamp Head
							locate(J23)
							if(J23:needsquenched==1)
								return J23
					proc/FindBSLf(mob/players/M)
						for(var/obj/items/Crafting/Created/BrassLampHead/J24 in M.contents)//Brass Lamp Head
							locate(J24)
							if(J24:needsquenched==1)
								return J24
					proc/FindSLf(mob/players/M)
						for(var/obj/items/Crafting/Created/SteelLampHead/J25 in M.contents)//Steel Lamp Head
							locate(J25)
							if(J25:needsquenched==1)
								return J25
		//Misc Parts
					/*proc/FindAVf(mob/players/M)
						for(var/obj/items/Crafting/Created/AnvilHead/J26 in M.contents)//Iron Anvil Head
							locate(J26)
							if(J26:needsquenched==1)
								return J26*/



					proc/Qench()//working
						//set src in usr
						var/mob/players/M
						M = usr
						//var/obj/items/Crafting/Created/Whetstone/S = locate() in M.contents
//Tool Call
						var/obj/items/Crafting/Created/HammerHead/J = call(/obj/items/tools/Containers/Barrel/proc/FindHMf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/CKnifeblade/J1 = call(/obj/items/tools/Containers/Barrel/proc/FindCKf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SickleBlade/J2 = call(/obj/items/tools/Containers/Barrel/proc/FindSBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/TrowelBlade/J3 = call(/obj/items/tools/Containers/Barrel/proc/FindTWBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/ChiselBlade/J4 = call(/obj/items/tools/Containers/Barrel/proc/FindCBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/AxeHead/J5 = call(/obj/items/tools/Containers/Barrel/proc/FindAHf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/FileBlade/J6 = call(/obj/items/tools/Containers/Barrel/proc/FindFBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/ShovelHead/J7 = call(/obj/items/tools/Containers/Barrel/proc/FindSHf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/HoeBlade/J8 = call(/obj/items/tools/Containers/Barrel/proc/FindHOf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/PickaxeHead/J9 = call(/obj/items/tools/Containers/Barrel/proc/FindPXf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SawBlade/J10 = call(/obj/items/tools/Containers/Barrel/proc/FindSWf)(M)//locate() in M.contents
//Weapon Call

						var/obj/items/Crafting/Created/Broadswordblade/J11 = call(/obj/items/tools/Containers/Barrel/proc/FindBSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warswordblade/J12 = call(/obj/items/tools/Containers/Barrel/proc/FindWSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battleswordblade/J13 = call(/obj/items/tools/Containers/Barrel/proc/FindBSWf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Longswordblade/J14 = call(/obj/items/tools/Containers/Barrel/proc/FindLSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warmaulhead/J15 = call(/obj/items/tools/Containers/Barrel/proc/FindWMf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battlehammersledge/J16 = call(/obj/items/tools/Containers/Barrel/proc/FindBHf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Waraxeblade/J17 = call(/obj/items/tools/Containers/Barrel/proc/FindWXf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battleaxeblade/J18 = call(/obj/items/tools/Containers/Barrel/proc/FindBXf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warscytheblade/J19 = call(/obj/items/tools/Containers/Barrel/proc/FindWSYf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battlescytheblade/J20 = call(/obj/items/tools/Containers/Barrel/proc/FindBSYf)(M)//locate() in M.contents

//Lamp Call

						var/obj/items/Crafting/Created/IronLampHead/J21 = call(/obj/items/tools/Containers/Barrel/proc/FindILf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/CopperLampHead/J22 = call(/obj/items/tools/Containers/Barrel/proc/FindCLf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/BronzeLampHead/J23 = call(/obj/items/tools/Containers/Barrel/proc/FindBRLf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/BrassLampHead/J24 = call(/obj/items/tools/Containers/Barrel/proc/FindBSLf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SteelLampHead/J25 = call(/obj/items/tools/Containers/Barrel/proc/FindSLf)(M)//locate() in M.contents
//Misc Parts
						//var/obj/items/Crafting/Created/AnvilHead/J26 = call(/obj/items/tools/Containers/Barrel/proc/FindSLf)(M)//locate() in M.contents

//Water Tool part Quench Check
						if(src:CType=="Empty")
							M << "Need to fill the Barrel to Quench!"
							return
						if(src:CType=="Sand")
							M << "You can't use Sand to Quench!"
							return
						if(src:CType=="Water")
							if(J&&J.Tname!="Cool")
								if(J.Tname=="Hot")
									M<<"You submerge the [J.Tname] [J] into the water."
									J.needsquenched=0
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"You have quenched [J]! Test it for hardness with a File."
									return
								else if(J.Tname=="Warm")
									M<<"You submerge the [J.Tname] [J] into the water."
									J.needsquenched=1
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J] wasn't hot enough."
									return
							else if(!J)
								return
							else if(J.Tname=="Cool")
								M << "Heat the [J] before quenching."
								return
							if(J1&&J1.Tname!="Cool")
								if(J1.Tname=="Hot")
									M<<"You submerge the [J1.Tname] [J1] into the water."
									J1.needsquenched=0
									sleep(3)
									J1.Tname="Cool"
									M<<"You have quenched [J1]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J1.Tname=="Warm")
									M<<"You submerge the [J1.Tname] [J1] into the water."
									J1.needsquenched=1
									sleep(3)
									J1.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J1] wasn't hot enough."
									return
							else if(!J1)
								return
							else if(J1.Tname=="Cool")
								M << "Heat the [J1] before quenching."
								return
							if(J2&&J2.Tname!="Cool")
								if(J2.Tname=="Hot")
									M<<"You submerge the [J2.Tname] [J2] into the water."
									J2.needsquenched=0
									sleep(3)
									J2.Tname="Cool"
									M<<"You have quenched [J2]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J2.Tname=="Warm")
									M<<"You submerge the [J2.Tname] [J2] into the water."
									J2.needsquenched=1
									sleep(3)
									J2.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J2] wasn't hot enough."
									return
							else if(!J2)
								return
							else if(J2.Tname=="Cool")
								M << "Heat the [J2] before quenching."
								return
							if(J3&&J3.Tname!="Cool")
								if(J3.Tname=="Hot")
									M<<"You submerge the [J3.Tname] [J3] into the water."
									J3.needsquenched=0
									sleep(3)
									J3.Tname="Cool"
									M<<"You have quenched [J3]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J3.Tname=="Warm")
									M<<"You submerge the [J3.Tname] [J3] into the water."
									J3.needsquenched=1
									sleep(3)
									J3.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J3] wasn't hot enough."
									return
							else if(!J3)
								return
							else if(J3.Tname=="Cool")
								M << "Heat the [J3] before quenching."
								return
							if(J4&&J4.Tname!="Cool")
								if(J4.Tname=="Hot")
									M<<"You submerge the [J4.Tname] [J4] into the water."
									J4.needsquenched=0
									sleep(3)
									J4.Tname="Cool"
									M<<"You have quenched [J4]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J4.Tname=="Warm")
									M<<"You submerge the [J4.Tname] [J4] into the water."
									J4.needsquenched=1
									sleep(3)
									J4.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J4] wasn't hot enough."
									return
							else if(!J4)
								return
							else if(J4.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J5&&J5.Tname!="Cool")
								if(J5.Tname=="Hot")
									M<<"You submerge the [J5.Tname] [J5] into the water."
									J5.needsquenched=0
									sleep(3)
									J5.Tname="Cool"
									M<<"You have quenched [J5]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J5.Tname=="Warm")
									M<<"You submerge the [J5.Tname] [J5] into the water."
									J5.needsquenched=1
									sleep(3)
									J5.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J5] wasn't hot enough."
									return
							else if(!J5)
								return
							else if(J5.Tname=="Cool")
								M << "Heat the [J5] before quenching."
								return
							if(J6&&J6.Tname!="Cool")
								if(J6.Tname=="Hot")
									M<<"You submerge the [J6.Tname] [J6] into the water."
									J6.needsquenched=0
									sleep(3)
									J6.Tname="Cool"
									M<<"You have quenched [J6]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J6.Tname=="Warm")
									M<<"You submerge the [J6.Tname] [J6] into the water."
									J6.needsquenched=1
									sleep(3)
									J6.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J6] wasn't hot enough."
									return
							else if(!J6)
								return
							else if(J6.Tname=="Cool")
								M << "Heat the [J6] before quenching."
								return
							if(J7&&J7.Tname!="Cool")
								if(J7.Tname=="Hot")
									M<<"You submerge the [J7.Tname] [J7] into the water."
									J7.needsquenched=0
									sleep(3)
									J7.Tname="Cool"
									M<<"You have quenched [J7]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J7.Tname=="Warm")
									M<<"You submerge the [J7.Tname] [J7] into the water."
									J7.needsquenched=1
									sleep(3)
									J7.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J7] wasn't hot enough."
									return
							else if(!J7)
								return
							else if(J7.Tname=="Cool")
								M << "Heat the [J7] before quenching."
								return
							if(J8&&J8.Tname!="Cool")
								if(J8.Tname=="Hot")
									M<<"You submerge the [J8.Tname] [J8] into the water."
									J8.needsquenched=0
									sleep(3)
									J8.Tname="Cool"
									M<<"You have quenched [J8]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J8.Tname=="Warm")
									M<<"You submerge the [J8.Tname] [J8] into the water."
									J8.needsquenched=1
									sleep(3)
									J8.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J8] wasn't hot enough."
									return
							else if(!J8)
								return
							else if(J8.Tname=="Cool")
								M << "Heat the [J8] before quenching."
								return
							if(J9&&J9.Tname!="Cool")
								if(J9.Tname=="Hot")
									M<<"You submerge the [J9.Tname] [J9] into the water."
									J9.needsquenched=0
									sleep(3)
									J9.Tname="Cool"
									M<<"You have quenched [J9]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J9.Tname=="Warm")
									M<<"You submerge the [J9.Tname] [J9] into the water."
									J9.needsquenched=1
									sleep(3)
									J9.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J9] wasn't hot enough."
									return
							else if(!J9)
								return
							else if(J9.Tname=="Cool")
								M << "Heat the [J9] before quenching."
								return
							if(J10&&J10.Tname!="Cool")
								if(J10.Tname=="Hot")
									M<<"You submerge the [J10.Tname] [J10] into the water."
									J10.needsquenched=0
									sleep(3)
									J10.Tname="Cool"
									M<<"You have quenched [J10]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J10.Tname=="Warm")
									M<<"You submerge the [J10.Tname] [J10] into the water."
									J10.needsquenched=1
									sleep(3)
									J10.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J10] wasn't hot enough."
									return
							else if(!J10)
								return
							else if(J10.Tname=="Cool")
								M << "Heat the [J10] before quenching."
								return

//Water Weapon part Quench Process
							if(J11&&J11.Tname!="Cool")
								if(J11.Tname=="Hot")
									M<<"You submerge the [J11.Tname] [J11] into the water."
									J11.needsquenched=0
									sleep(3)
									J11.Tname="Cool"
									M<<"You have quenched [J11]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J11.Tname=="Warm")
									M<<"You submerge the [J11.Tname] [J11] into the water."
									J11.needsquenched=1
									sleep(3)
									J11.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J11] wasn't hot enough."
									return
							else if(!J11)
								return
							else if(J11.Tname=="Cool")
								M << "Heat the [J11] before quenching."
								return
							if(J12&&J12.Tname!="Cool")
								if(J12.Tname=="Hot")
									M<<"You submerge the [J12.Tname] [J12] into the water."
									J12.needsquenched=0
									sleep(3)
									J12.Tname="Cool"
									M<<"You have quenched [J12]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J12.Tname=="Warm")
									M<<"You submerge the [J12.Tname] [J12] into the water."
									J12.needsquenched=1
									sleep(3)
									J12.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J12] wasn't hot enough."
									return
							else if(!J12)
								return
							else if(J12.Tname=="Cool")
								M << "Heat the [J12] before quenching."
								return
							if(J13&&J13.Tname!="Cool")
								if(J13.Tname=="Hot")
									M<<"You submerge the [J13.Tname] [J13] into the water."
									J13.needsquenched=0
									sleep(3)
									J13.Tname="Cool"
									M<<"You have quenched [J13]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J13.Tname=="Warm")
									M<<"You submerge the [J13.Tname] [J13] into the water."
									J13.needsquenched=1
									sleep(3)
									J13.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J13] wasn't hot enough."
									return
							else if(!J13)
								return
							else if(J13.Tname=="Cool")
								M << "Heat the [J13] before quenching."
								return
							if(J14&&J14.Tname!="Cool")
								if(J14.Tname=="Hot")
									M<<"You submerge the [J14.Tname] [J14] into the water."
									J14.needsquenched=0
									sleep(3)
									J14.Tname="Cool"
									M<<"You have quenched [J14]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J14.Tname=="Warm")
									M<<"You submerge the [J14.Tname] [J14] into the water."
									J14.needsquenched=1
									sleep(3)
									J14.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J14] wasn't hot enough."
									return
							else if(!J14)
								return
							else if(J14.Tname=="Cool")
								M << "Heat the [J14] before quenching."
								return
							if(J15&&J15.Tname!="Cool")
								if(J15.Tname=="Hot")
									M<<"You submerge the [J15.Tname] [J15] into the water."
									J15.needsquenched=0
									sleep(3)
									J15.Tname="Cool"
									M<<"You have quenched [J15]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J15.Tname=="Warm")
									M<<"You submerge the [J15.Tname] [J15] into the water."
									J15.needsquenched=1
									sleep(3)
									J15.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J15] wasn't hot enough."
									return
							else if(!J15)
								return
							else if(J15.Tname=="Cool")
								M << "Heat the [J15] before quenching."
								return
							if(J16&&J16.Tname!="Cool")
								if(J16.Tname=="Hot")
									M<<"You submerge the [J16.Tname] [J16] into the water."
									J16.needsquenched=0
									sleep(3)
									J16.Tname="Cool"
									M<<"You have quenched [J16]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J16.Tname=="Warm")
									M<<"You submerge the [J16.Tname] [J16] into the water."
									J16.needsquenched=1
									sleep(3)
									J16.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J16] wasn't hot enough."
									return
							else if(!J16)
								return
							else if(J16.Tname=="Cool")
								M << "Heat the [J16] before quenching."
								return
							if(J17&&J17.Tname!="Cool")
								if(J17.Tname=="Hot")
									M<<"You submerge the [J17.Tname] [J17] into the water."
									J17.needsquenched=0
									sleep(3)
									J17.Tname="Cool"
									M<<"You have quenched [J17]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J17.Tname=="Warm")
									M<<"You submerge the [J17.Tname] [J17] into the water."
									J17.needsquenched=1
									sleep(3)
									J17.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J17] wasn't hot enough."
									return
							else if(!J17)
								return
							else if(J17.Tname=="Cool")
								M << "Heat the [J17] before quenching."
								return
							if(J18&&J18.Tname!="Cool")
								if(J18.Tname=="Hot")
									M<<"You submerge the [J18.Tname] [J18] into the water."
									J18.needsquenched=0
									sleep(3)
									J18.Tname="Cool"
									M<<"You have quenched [J18]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J18.Tname=="Warm")
									M<<"You submerge the [J18.Tname] [J18] into the water."
									J18.needsquenched=1
									sleep(3)
									J18.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J18] wasn't hot enough."
									return
							else if(!J18)
								return
							else if(J18.Tname=="Cool")
								M << "Heat the [J18] before quenching."
								return
							if(J19&&J19.Tname!="Cool")
								if(J19.Tname=="Hot")
									M<<"You submerge the [J19.Tname] [J19] into the water."
									J19.needsquenched=0
									sleep(3)
									J19.Tname="Cool"
									M<<"You have quenched [J19]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J19.Tname=="Warm")
									M<<"You submerge the [J19.Tname] [J19] into the water."
									J19.needsquenched=1
									sleep(3)
									J19.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J19] wasn't hot enough."
									return
							else if(!J19)
								return
							else if(J19.Tname=="Cool")
								M << "Heat the [J19] before quenching."
								return
							if(J20&&J20.Tname!="Cool")
								if(J20.Tname=="Hot")
									M<<"You submerge the [J20.Tname] [J20] into the water."
									J20.needsquenched=0
									sleep(3)
									J20.Tname="Cool"
									M<<"You have quenched [J20]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J20.Tname=="Warm")
									M<<"You submerge the [J20.Tname] [J20] into the water."
									J20.needsquenched=1
									sleep(3)
									J20.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J20] wasn't hot enough."
									return
							else if(!J20)
								return
							else if(J20.Tname=="Cool")
								M << "Heat the [J20] before quenching."
								return


//Water Lamp part Quench Process
							if(J21&&J21.Tname!="Cool")
								if(J21.Tname=="Hot")
									M<<"You submerge the [J21.Tname] [J21] into the water."
									J21.needsquenched=0
									sleep(3)
									J21.Tname="Cool"
									M<<"You have quenched [J21]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J21.Tname=="Warm")
									M<<"You submerge the [J21.Tname] [J21] into the water."
									J21.needsquenched=1
									sleep(3)
									J21.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J21] wasn't hot enough."
									return
							else if(!J21)
								return
							else if(J21.Tname=="Cool")
								M << "Heat the [J21] before quenching."
								return
							if(J22&&J22.Tname!="Cool")
								if(J22.Tname=="Hot")
									M<<"You submerge the [J22.Tname] [J22] into the water."
									J22.needsquenched=0
									sleep(3)
									J22.Tname="Cool"
									M<<"You have quenched [J22]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J22.Tname=="Warm")
									M<<"You submerge the [J22.Tname] [J22] into the water."
									J22.needsquenched=1
									sleep(3)
									J22.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J22] wasn't hot enough."
									return
							else if(!J22)
								return
							else if(J22.Tname=="Cool")
								M << "Heat the [J22] before quenching."
								return
							if(J23&&J23.Tname!="Cool")
								if(J23.Tname=="Hot")
									M<<"You submerge the [J23.Tname] [J23] into the water."
									J23.needsquenched=0
									sleep(3)
									J23.Tname="Cool"
									M<<"You have quenched [J23]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J23.Tname=="Warm")
									M<<"You submerge the [J23.Tname] [J23] into the water."
									J23.needsquenched=1
									sleep(3)
									J23.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J23] wasn't hot enough."
									return
							else if(!J23)
								return
							else if(J23.Tname=="Cool")
								M << "Heat the [J23] before quenching."
								return
							if(J24&&J24.Tname!="Cool")
								if(J24.Tname=="Hot")
									M<<"You submerge the [J24.Tname] [J24] into the water."
									J24.needsquenched=0
									sleep(3)
									J24.Tname="Cool"
									M<<"You have quenched [J24]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J24.Tname=="Warm")
									M<<"You submerge the [J24.Tname] [J24] into the water."
									J24.needsquenched=1
									sleep(3)
									J24.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J24] wasn't hot enough."
									return
							else if(!J24)
								return
							else if(J24.Tname=="Cool")
								M << "Heat the [J24] before quenching."
								return
							if(J25&&J25.Tname!="Cool")
								if(J25.Tname=="Hot")
									M<<"You submerge the [J25.Tname] [J25] into the water."
									J25.needsquenched=0
									sleep(3)
									J25.Tname="Cool"
									M<<"You have quenched [J25]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J25.Tname=="Warm")
									M<<"You submerge the [J25.Tname] [J25] into the water."
									J25.needsquenched=1
									sleep(3)
									J25.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J25] wasn't hot enough."
									return
							else if(!J25)
								return
							else if(J25.Tname=="Cool")
								M << "Heat the [J25] before quenching."
								return

//Tar Tool Quench Process
						if(src:CType=="Tar")
							if(J&&J.Tname!="Cool")
								if(J.Tname=="Hot")
									M<<"You submerge the [J.Tname] [J] into the tar."
									J.needsquenched=0
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"You have quenched [J]! Test it for hardness with a File."
									return
								else if(J.Tname=="Warm")
									M<<"You submerge the [J.Tname] [J] into the tar."
									J.needsquenched=1
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J] wasn't hot enough."
									return
							else if(!J)
								return
							else if(J.Tname=="Cool")
								M << "Heat the [J] before quenching."
								return
							if(J1&&J1.Tname!="Cool")
								if(J1.Tname=="Hot")
									M<<"You submerge the [J1.Tname] [J1] into the tar."
									J1.needsquenched=0
									sleep(3)
									J1.Tname="Cool"
									M<<"You have quenched [J1]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J1.Tname=="Warm")
									M<<"You submerge the [J1.Tname] [J1] into the tar."
									J1.needsquenched=1
									sleep(3)
									J1.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J1] wasn't hot enough."
									return
							else if(!J1)
								return
							else if(J1.Tname=="Cool")
								M << "Heat the [J1] before quenching."
								return
							if(J2&&J2.Tname!="Cool")
								if(J2.Tname=="Hot")
									M<<"You submerge the [J2.Tname] [J2] into the tar."
									J2.needsquenched=0
									sleep(3)
									J2.Tname="Cool"
									M<<"You have quenched [J2]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J2.Tname=="Warm")
									M<<"You submerge the [J2.Tname] [J2] into the tar."
									J2.needsquenched=1
									sleep(3)
									J2.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J2] wasn't hot enough."
									return
							else if(!J2)
								return
							else if(J2.Tname=="Cool")
								M << "Heat the [J2] before quenching."
								return
							if(J3&&J3.Tname!="Cool")
								if(J3.Tname=="Hot")
									M<<"You submerge the [J3.Tname] [J3] into the tar."
									J3.needsquenched=0
									sleep(3)
									J3.Tname="Cool"
									M<<"You have quenched [J3]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J3.Tname=="Warm")
									M<<"You submerge the [J3.Tname] [J3] into the tar."
									J3.needsquenched=1
									sleep(3)
									J3.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J3] wasn't hot enough."
									return
							else if(!J3)
								return
							else if(J3.Tname=="Cool")
								M << "Heat the [J3] before quenching."
								return
							if(J4&&J4.Tname!="Cool")
								if(J4.Tname=="Hot")
									M<<"You submerge the [J4.Tname] [J4] into the tar."
									J4.needsquenched=0
									sleep(3)
									J4.Tname="Cool"
									M<<"You have quenched [J4]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J4.Tname=="Warm")
									M<<"You submerge the [J4.Tname] [J4] into the tar."
									J4.needsquenched=1
									sleep(3)
									J4.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J4] wasn't hot enough."
									return
							else if(!J4)
								return
							else if(J4.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J5&&J5.Tname!="Cool")
								if(J5.Tname=="Hot")
									M<<"You submerge the [J5.Tname] [J5] into the tar."
									J5.needsquenched=0
									sleep(3)
									J5.Tname="Cool"
									M<<"You have quenched [J5]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J5.Tname=="Warm")
									M<<"You submerge the [J5.Tname] [J5] into the tar."
									J5.needsquenched=1
									sleep(3)
									J5.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J5] wasn't hot enough."
									return
							else if(!J5)
								return
							else if(J5.Tname=="Cool")
								M << "Heat the [J5] before quenching."
								return
							if(J6&&J6.Tname!="Cool")
								if(J6.Tname=="Hot")
									M<<"You submerge the [J6.Tname] [J6] into the tar."
									J6.needsquenched=0
									sleep(3)
									J6.Tname="Cool"
									M<<"You have quenched [J6]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J6.Tname=="Warm")
									M<<"You submerge the [J6.Tname] [J6] into the tar."
									J6.needsquenched=1
									sleep(3)
									J6.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J6] wasn't hot enough."
									return
							else if(!J6)
								return
							else if(J6.Tname=="Cool")
								M << "Heat the [J6] before quenching."
								return
							if(J7&&J7.Tname!="Cool")
								if(J7.Tname=="Hot")
									M<<"You submerge the [J7.Tname] [J7] into the tar."
									J7.needsquenched=0
									sleep(3)
									J7.Tname="Cool"
									M<<"You have quenched [J7]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J7.Tname=="Warm")
									M<<"You submerge the [J7.Tname] [J7] into the tar."
									J7.needsquenched=1
									sleep(3)
									J7.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J7] wasn't hot enough."
									return
							else if(!J7)
								return
							else if(J7.Tname=="Cool")
								M << "Heat the [J7] before quenching."
								return
							if(J8&&J8.Tname!="Cool")
								if(J8.Tname=="Hot")
									M<<"You submerge the [J8.Tname] [J8] into the tar."
									J8.needsquenched=0
									sleep(3)
									J8.Tname="Cool"
									M<<"You have quenched [J8]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J8.Tname=="Warm")
									M<<"You submerge the [J8.Tname] [J8] into the tar."
									J8.needsquenched=1
									sleep(3)
									J8.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J8] wasn't hot enough."
									return
							else if(!J8)
								return
							else if(J8.Tname=="Cool")
								M << "Heat the [J8] before quenching."
								return
							if(J9&&J9.Tname!="Cool")
								if(J9.Tname=="Hot")
									M<<"You submerge the [J9.Tname] [J9] into the tar."
									J9.needsquenched=0
									sleep(3)
									J9.Tname="Cool"
									M<<"You have quenched [J9]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J9.Tname=="Warm")
									M<<"You submerge the [J9.Tname] [J9] into the tar."
									J9.needsquenched=1
									sleep(3)
									J9.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J9] wasn't hot enough."
									return
							else if(!J9)
								return
							else if(J9.Tname=="Cool")
								M << "Heat the [J9] before quenching."
								return
							if(J10&&J10.Tname!="Cool")
								if(J10.Tname=="Hot")
									M<<"You submerge the [J10.Tname] [J10] into the tar."
									J10.needsquenched=0
									sleep(3)
									J10.Tname="Cool"
									M<<"You have quenched [J10]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J10.Tname=="Warm")
									M<<"You submerge the [J10.Tname] [J10] into the tar."
									J10.needsquenched=1
									sleep(3)
									J10.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J10] wasn't hot enough."
									return
							else if(!J10)
								return
							else if(J10.Tname=="Cool")
								M << "Heat the [J10] before quenching."
								return

//Tar Weapon Quench Process
							if(J11&&J11.Tname!="Cool")
								if(J11.Tname=="Hot")
									M<<"You submerge the [J11.Tname] [J11] into the tar."
									J11.needsquenched=0
									sleep(3)
									J11.Tname="Cool"
									M<<"You have quenched [J11]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J11.Tname=="Warm")
									M<<"You submerge the [J11.Tname] [J11] into the tar."
									J11.needsquenched=1
									sleep(3)
									J11.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J11] wasn't hot enough."
									return
							else if(!J11)
								return
							else if(J11.Tname=="Cool")
								M << "Heat the [J11] before quenching."
								return
							if(J12&&J12.Tname!="Cool")
								if(J12.Tname=="Hot")
									M<<"You submerge the [J12.Tname] [J12] into the tar."
									J12.needsquenched=0
									sleep(3)
									J12.Tname="Cool"
									M<<"You have quenched [J12]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J12.Tname=="Warm")
									M<<"You submerge the [J12.Tname] [J12] into the tar."
									J12.needsquenched=1
									sleep(3)
									J12.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J12] wasn't hot enough."
									return
							else if(!J12)
								return
							else if(J12.Tname=="Cool")
								M << "Heat the [J12] before quenching."
								return
							if(J13&&J13.Tname!="Cool")
								if(J13.Tname=="Hot")
									M<<"You submerge the [J13.Tname] [J13] into the tar."
									J13.needsquenched=0
									sleep(3)
									J13.Tname="Cool"
									M<<"You have quenched [J13]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J13.Tname=="Warm")
									M<<"You submerge the [J13.Tname] [J13] into the tar."
									J13.needsquenched=1
									sleep(3)
									J13.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J13] wasn't hot enough."
									return
							else if(!J13)
								return
							else if(J13.Tname=="Cool")
								M << "Heat the [J13] before quenching."
								return
							if(J14&&J14.Tname!="Cool")
								if(J14.Tname=="Hot")
									M<<"You submerge the [J14.Tname] [J14] into the tar."
									J14.needsquenched=0
									sleep(3)
									J14.Tname="Cool"
									M<<"You have quenched [J14]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J14.Tname=="Warm")
									M<<"You submerge the [J14.Tname] [J14] into the tar."
									J14.needsquenched=1
									sleep(3)
									J14.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J14] wasn't hot enough."
									return
							else if(!J14)
								return
							else if(J14.Tname=="Cool")
								M << "Heat the [J14] before quenching."
								return
							if(J15&&J15.Tname!="Cool")
								if(J15.Tname=="Hot")
									M<<"You submerge the [J15.Tname] [J15] into the tar."
									J15.needsquenched=0
									sleep(3)
									J15.Tname="Cool"
									M<<"You have quenched [J15]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J15.Tname=="Warm")
									M<<"You submerge the [J15.Tname] [J15] into the tar."
									J15.needsquenched=1
									sleep(3)
									J15.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J15] wasn't hot enough."
									return
							else if(!J15)
								return
							else if(J15.Tname=="Cool")
								M << "Heat the [J15] before quenching."
								return
							if(J16&&J16.Tname!="Cool")
								if(J16.Tname=="Hot")
									M<<"You submerge the [J16.Tname] [J16] into the tar."
									J16.needsquenched=0
									sleep(3)
									J16.Tname="Cool"
									M<<"You have quenched [J16]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J16.Tname=="Warm")
									M<<"You submerge the [J16.Tname] [J16] into the tar."
									J16.needsquenched=1
									sleep(3)
									J16.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J16] wasn't hot enough."
									return
							else if(!J16)
								return
							else if(J16.Tname=="Cool")
								M << "Heat the [J16] before quenching."
								return
							if(J17&&J17.Tname!="Cool")
								if(J17.Tname=="Hot")
									M<<"You submerge the [J17.Tname] [J17] into the tar."
									J17.needsquenched=0
									sleep(3)
									J17.Tname="Cool"
									M<<"You have quenched [J17]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J17.Tname=="Warm")
									M<<"You submerge the [J17.Tname] [J17] into the tar."
									J17.needsquenched=1
									sleep(3)
									J17.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J17] wasn't hot enough."
									return
							else if(!J17)
								return
							else if(J17.Tname=="Cool")
								M << "Heat the [J17] before quenching."
								return
							if(J18&&J18.Tname!="Cool")
								if(J18.Tname=="Hot")
									M<<"You submerge the [J18.Tname] [J18] into the tar."
									J18.needsquenched=0
									sleep(3)
									J18.Tname="Cool"
									M<<"You have quenched [J18]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J18.Tname=="Warm")
									M<<"You submerge the [J18.Tname] [J18] into the tar."
									J18.needsquenched=1
									sleep(3)
									J18.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J18] wasn't hot enough."
									return
							else if(!J18)
								return
							else if(J18.Tname=="Cool")
								M << "Heat the [J18] before quenching."
								return
							if(J19&&J19.Tname!="Cool")
								if(J19.Tname=="Hot")
									M<<"You submerge the [J19.Tname] [J19] into the tar."
									J19.needsquenched=0
									sleep(3)
									J19.Tname="Cool"
									M<<"You have quenched [J19]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J19.Tname=="Warm")
									M<<"You submerge the [J19.Tname] [J19] into the tar."
									J19.needsquenched=1
									sleep(3)
									J19.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J19] wasn't hot enough."
									return
							else if(!J19)
								return
							else if(J19.Tname=="Cool")
								M << "Heat the [J19] before quenching."
								return
							if(J20&&J20.Tname!="Cool")
								if(J20.Tname=="Hot")
									M<<"You submerge the [J20.Tname] [J20] into the tar."
									J20.needsquenched=0
									sleep(3)
									J20.Tname="Cool"
									M<<"You have quenched [J20]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J20.Tname=="Warm")
									M<<"You submerge the [J20.Tname] [J20] into the tar."
									J20.needsquenched=1
									sleep(3)
									J20.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J20] wasn't hot enough."
									return
							else if(!J20)
								return
							else if(J20.Tname=="Cool")
								M << "Heat the [J20] before quenching."
								return


//Tar Lamp part Quench Process
							if(J21&&J21.Tname!="Cool")
								if(J21.Tname=="Hot")
									M<<"You submerge the [J21.Tname] [J21] into the tar."
									J21.needsquenched=0
									sleep(3)
									J21.Tname="Cool"
									M<<"You have quenched [J21]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J21.Tname=="Warm")
									M<<"You submerge the [J21.Tname] [J21] into the tar."
									J21.needsquenched=1
									sleep(3)
									J21.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J21] wasn't hot enough."
									return
							else if(!J21)
								return
							else if(J21.Tname=="Cool")
								M << "Heat the [J21] before quenching."
								return
							if(J22&&J22.Tname!="Cool")
								if(J22.Tname=="Hot")
									M<<"You submerge the [J22.Tname] [J22] into the tar."
									J22.needsquenched=0
									sleep(3)
									J22.Tname="Cool"
									M<<"You have quenched [J22]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J22.Tname=="Warm")
									M<<"You submerge the [J22.Tname] [J22] into the tar."
									J22.needsquenched=1
									sleep(3)
									J22.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J22] wasn't hot enough."
									return
							else if(!J22)
								return
							else if(J22.Tname=="Cool")
								M << "Heat the [J22] before quenching."
								return
							if(J23&&J23.Tname!="Cool")
								if(J23.Tname=="Hot")
									M<<"You submerge the [J23.Tname] [J23] into the tar."
									J23.needsquenched=0
									sleep(3)
									J23.Tname="Cool"
									M<<"You have quenched [J23]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J23.Tname=="Warm")
									M<<"You submerge the [J23.Tname] [J23] into the tar."
									J23.needsquenched=1
									sleep(3)
									J23.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J23] wasn't hot enough."
									return
							else if(!J23)
								return
							else if(J23.Tname=="Cool")
								M << "Heat the [J23] before quenching."
								return
							if(J24&&J24.Tname!="Cool")
								if(J24.Tname=="Hot")
									M<<"You submerge the [J24.Tname] [J24] into the tar."
									J24.needsquenched=0
									sleep(3)
									J24.Tname="Cool"
									M<<"You have quenched [J24]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J24.Tname=="Warm")
									M<<"You submerge the [J24.Tname] [J24] into the tar."
									J24.needsquenched=1
									sleep(3)
									J24.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J24] wasn't hot enough."
									return
							else if(!J24)
								return
							else if(J24.Tname=="Cool")
								M << "Heat the [J24] before quenching."
								return
							if(J25&&J25.Tname!="Cool")
								if(J25.Tname=="Hot")
									M<<"You submerge the [J25.Tname] [J25] into the tar."
									J25.needsquenched=0
									sleep(3)
									J25.Tname="Cool"
									M<<"You have quenched [J25]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J25.Tname=="Warm")
									M<<"You submerge the [J25.Tname] [J25] into the tar."
									J25.needsquenched=1
									sleep(3)
									J25.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J25] wasn't hot enough."
									return
							else if(!J25)
								return
							else if(J25.Tname=="Cool")
								M << "Heat the [J25] before quenching."
								return


//Oil Tool part Quench Process
						if(src:CType=="Oil")
							if(J&&J.Tname!="Cool")
								M<<"You submerge the [J.Tname] [J] into the oil."
								J.needsquenched=0
								sleep(3)
								J.Tname="Cool"
								//insert sfx and flick an animation
								M<<"You have quenched [J]! Test it for hardness with a File."
								return
							else if(!J)
								return
							else if(J.Tname=="Cool")
								M << "Heat the [J] before quenching."
								return
							if(J1&&J1.Tname!="Cool")
								M<<"You submerge the [J1.Tname] [J1] into the oil."
								J1.needsquenched=0
								sleep(3)
								J1.Tname="Cool"
								M<<"You have quenched [J1]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J1)
								return
							else if(J1.Tname=="Cool")
								M << "Heat the [J1] before quenching."
								return
							if(J2&&J2.Tname!="Cool")
								M<<"You submerge the [J2.Tname] [J2] into the oil."
								J2.needsquenched=0
								sleep(3)
								J2.Tname="Cool"
								M<<"You have quenched [J2]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J2)
								return
							else if(J2.Tname=="Cool")
								M << "Heat the [J2] before quenching."
								return
							if(J3&&J3.Tname!="Cool")
								M<<"You submerge the [J3.Tname] [J3] into the oil."
								J3.needsquenched=0
								sleep(3)
								J3.Tname="Cool"
								M<<"You have quenched [J3]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J3)
								return
							else if(J3.Tname=="Cool")
								M << "Heat the [J3] before quenching."
								return
							if(J4&&J4.Tname!="Cool")
								M<<"You submerge the [J4.Tname] [J4] into the oil."
								J4.needsquenched=0
								sleep(3)
								J4.Tname="Cool"
								M<<"You have quenched [J4]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J4)
								return
							else if(J4.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J5&&J5.Tname!="Cool")
								M<<"You submerge the [J5.Tname] [J5] into the oil."
								J5.needsquenched=0
								sleep(3)
								J5.Tname="Cool"
								M<<"You have quenched [J5]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J5)
								return
							else if(J5.Tname=="Cool")
								M << "Heat the [J5] before quenching."
								return
							if(J6&&J6.Tname!="Cool")
								M<<"You submerge the [J6.Tname] [J6] into the oil."
								J6.needsquenched=0
								sleep(3)
								J6.Tname="Cool"
								M<<"You have quenched [J6]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J6)
								return
							else if(J6.Tname=="Cool")
								M << "Heat the [J6] before quenching."
								return
							if(J7&&J7.Tname!="Cool")
								M<<"You submerge the [J7.Tname] [J7] into the oil."
								J7.needsquenched=0
								sleep(3)
								J7.Tname="Cool"
								M<<"You have quenched [J7]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J7)
								return
							else if(J7.Tname=="Cool")
								M << "Heat the [J7] before quenching."
								return
							if(J8&&J8.Tname!="Cool")
								M<<"You submerge the [J8.Tname] [J8] into the oil."
								J8.needsquenched=0
								sleep(3)
								J8.Tname="Cool"
								M<<"You have quenched [J8]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J8)
								return
							else if(J8.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J9&&J9.Tname!="Cool")
								M<<"You submerge the [J9.Tname] [J9] into the oil."
								J9.needsquenched=0
								sleep(3)
								J9.Tname="Cool"
								M<<"You have quenched [J9]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J9)
								return
							else if(J9.Tname=="Cool")
								M << "Heat the [J9] before quenching."
								return
							if(J10&&J10.Tname!="Cool")
								M<<"You submerge the [J10.Tname] [J10] into the oil."
								J10.needsquenched=0
								sleep(3)
								J10.Tname="Cool"
								M<<"You have quenched [J10]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J10)
								return
							else if(J10.Tname=="Cool")
								M << "Heat the [J10] before quenching."
								return

//Oil Weapon part Quench Process
							if(J11&&J11.Tname!="Cool")
								M<<"You submerge the [J11.Tname] [J11] into the oil."
								J11.needsquenched=0
								sleep(3)
								J11.Tname="Cool"
								M<<"You have quenched [J11]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J11)
								return
							else if(J11.Tname=="Cool")
								M << "Heat the [J11] before quenching."
								return
							if(J12&&J12.Tname!="Cool")
								M<<"You submerge the [J12.Tname] [J12] into the oil."
								J12.needsquenched=0
								sleep(3)
								J12.Tname="Cool"
								M<<"You have quenched [J12]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J12)
								return
							else if(J12.Tname=="Cool")
								M << "Heat the [J12] before quenching."
								return
							if(J13&&J13.Tname!="Cool")
								M<<"You submerge the [J13.Tname] [J13] into the oil."
								J13.needsquenched=0
								sleep(3)
								J13.Tname="Cool"
								M<<"You have quenched [J13]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J13)
								return
							else if(J13.Tname=="Cool")
								M << "Heat the [J13] before quenching."
								return
							if(J14&&J14.Tname!="Cool")
								M<<"You submerge the [J14.Tname] [J14] into the oil."
								J14.needsquenched=0
								sleep(3)
								J14.Tname="Cool"
								M<<"You have quenched [J14]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J14)
								return
							else if(J14.Tname=="Cool")
								M << "Heat the [J14] before quenching."
								return
							if(J15&&J15.Tname!="Cool")
								M<<"You submerge the [J15.Tname] [J15] into the oil."
								J15.needsquenched=0
								sleep(3)
								J15.Tname="Cool"
								M<<"You have quenched [J15]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J15)
								return
							else if(J15.Tname=="Cool")
								M << "Heat the [J15] before quenching."
								return
							if(J16&&J16.Tname!="Cool")
								M<<"You submerge the [J16.Tname] [J16] into the oil."
								J16.needsquenched=0
								sleep(3)
								J16.Tname="Cool"
								M<<"You have quenched [J16]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J16)
								return
							else if(J16.Tname=="Cool")
								M << "Heat the [J16] before quenching."
								return
							if(J17&&J17.Tname!="Cool")
								M<<"You submerge the [J17.Tname] [J17] into the oil."
								J17.needsquenched=0
								sleep(3)
								J17.Tname="Cool"
								M<<"You have quenched [J17]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J17)
								return
							else if(J17.Tname=="Cool")
								M << "Heat the [J17] before quenching."
								return
							if(J18&&J18.Tname!="Cool")
								M<<"You submerge the [J18.Tname] [J18] into the oil."
								J18.needsquenched=0
								sleep(3)
								J18.Tname="Cool"
								M<<"You have quenched [J18]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J18)
								return
							else if(J18.Tname=="Cool")
								M << "Heat the [J18] before quenching."
								return
							if(J19&&J19.Tname!="Cool")
								M<<"You submerge the [J19.Tname] [J19] into the oil."
								J19.needsquenched=0
								sleep(3)
								J19.Tname="Cool"
								M<<"You have quenched [J19]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J19)
								return
							else if(J19.Tname=="Cool")
								M << "Heat the [J19] before quenching."
								return
							if(J20&&J20.Tname!="Cool")
								M<<"You submerge the [J20.Tname] [J20] into the oil."
								J20.needsquenched=0
								sleep(3)
								J20.Tname="Cool"
								M<<"You have quenched [J20]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J20)
								return
							else if(J20.Tname=="Cool")
								M << "Heat the [J20] before quenching."
								return


//Oil Lamp part Quench Process
							if(J21&&J21.Tname!="Cool")
								M<<"You submerge the [J21.Tname] [J21] into the oil."
								J21.needsquenched=0
								sleep(3)
								J21.Tname="Cool"
								M<<"You have quenched [J21]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J21)
								return
							else if(J21.Tname=="Cool")
								M << "Heat the [J21] before quenching."
								return
							if(J22&&J22.Tname!="Cool")
								M<<"You submerge the [J22.Tname] [J22] into the oil."
								J22.needsquenched=0
								sleep(3)
								J22.Tname="Cool"
								M<<"You have quenched [J22]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J22)
								return
							else if(J22.Tname=="Cool")
								M << "Heat the [J22] before quenching."
								return
							if(J23&&J23.Tname!="Cool")
								M<<"You submerge the [J23.Tname] [J23] into the oil."
								J23.needsquenched=0
								sleep(3)
								J23.Tname="Cool"
								M<<"You have quenched [J23]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J23)
								return
							else if(J23.Tname=="Cool")
								M << "Heat the [J23] before quenching."
								return
							if(J24&&J24.Tname!="Cool")
								M<<"You submerge the [J24.Tname] [J24] into the oil."
								J24.needsquenched=0
								sleep(3)
								J24.Tname="Cool"
								M<<"You have quenched [J24]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J24)
								return
							else if(J24.Tname=="Cool")
								M << "Heat the [J24] before quenching."
								return
							if(J25&&J25.Tname!="Cool")
								M<<"You submerge the [J25.Tname] [J25] into the oil."
								J25.needsquenched=0
								sleep(3)
								J25.Tname="Cool"
								M<<"You have quenched [J25]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J25)
								return
							else if(J25.Tname=="Cool")
								M << "Heat the [J25] before quenching."
								return


					verb/Push()//works -- the only issue is it will move multiple barrels
						set src in view()
						//var/turf/t = get_step(src,dir)
						M << "You push the barrel."
						locate(usr in oview(src))
						src.pushing=1
						//FindB(M)
						if(src in range(1, usr))
							for(src)
								if(usr.dir==EAST)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x+1,src.y,src.z)
								else if(usr.dir==WEST)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x-1,src.y,src.z)
								if(usr.dir==NORTH)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x,src.y+1,src.z)
								else if(usr.dir==SOUTH)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x,src.y-1,src.z)
								//locate(src)
								return
					/*proc/FindB(var/obj/items/tools/Containers/Barrel/B = src)
						for(B in range(1, usr))

							if(B.pushing==1)

								return B
							else
								return*/
					proc/FindJar(mob/players/M)
						for(var/obj/items/tools/Containers/Jar/J in M.contents)
							if(suffix=="Equipped")
								return J
					proc/FindVes(mob/players/M)
						for(var/obj/items/tools/Containers/Vessel/J2 in M.contents)
							if(J2.name=="Filled Vessel"||J2.name=="Half Filled Vessel")
								return J2

					verb/Fill_Barrel()//fixed, I know it works
						set waitfor = 0
						set src in view()
						set popup_menu = 1
						var/mob/players/M
						M = usr
						var/obj/items/tools/Containers/Jar/J = locate() in M.contents
						var/obj/items/tools/Containers/Vessel/J2 = locate() in M.contents
//Jar
						//if(!J||!J2)
							//M << "Need a Jar or Vessel to fill the Barrel with."
						//M << "[J]"
						if(name=="Filled Barrel")
							M<<"The Barrel is Full."
							return
						if(J.suffix=="Equipped"&&J.CType=="Empty")
							M << "You need to hold a Filled Jar to fill the Barrel."
							return
						if(J.suffix=="Equipped"&&J.CType!="Empty"||J2.name=="Filled Vessel"||J2.name=="Half Filled Vessel")
							goto Process

						if(J:CType=="Water"&&CType=="Tar"||J:CType=="Water"&&CType=="Oil"||J2:CType=="Water"&&CType=="Tar"||J2:CType=="Water"&&CType=="Oil")
							//M<<"You don't need to mix contents."
							return
						else if(J:CType=="Sand"&&CType=="Water"||J:CType=="Sand"&&CType=="Oil"||J2:CType=="Sand"&&CType=="Water"||J2:CType=="Sand"&&CType=="Oil")
							//M<<"You don't need to mix contents."
							return
						else if(J:CType=="Tar"&&CType=="Water"||J:CType=="Tar"&&CType=="Oil"||J2:CType=="Tar"&&CType=="Water"||J2:CType=="Tar"&&CType=="Oil")
							//M<<"You don't need to mix contents."
							return
						else if(J:CType=="Oil"&&CType=="Tar"||J:CType=="Oil"&&CType=="Water"||J2:CType=="Oil"&&CType=="Tar"||J2:CType=="Oil"&&CType=="Water")
							//M<<"You don't need to mix contents."
							return

						Process
						if(M.JRequipped==1)
		//Water Jar
							if(J.CType=="Water")
								if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Water"&&src.name=="Barrel"&&src.CType=="Empty")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Quarter Filled Barrel"
									src.volume=25
									J.volume=0
									J.name="Jar"
									J.CType="Empty"
									CType="Water"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Water"&&src.name=="Quarter Filled Barrel"&&src.CType=="Water")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Half Filled Barrel"
									src.volume=50
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Water"&&src.name=="Half Filled Barrel"&&src.CType=="Water")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="ThreeQuarters Filled Barrel"
									src.volume=75
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Water"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Water")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Filled Barrel"
									src.volume=100
									J.volume=0
									J.name="Jar"
									J.CType="Empty"
									if(src.volume>src.volumecap)
										src.volume = src.volumecap
									icon_state = "Barrelw"
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return

		//Tar Jar
							if(J.CType=="Tar")
								if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Tar"&&src.name=="Barrel"&&src.CType=="Empty")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Quarter Filled Barrel"
									src.volume=25
									J.volume=0
									J.name="Jar"
									J.CType="Empty"
									CType="Tar"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Tar"&&src.name=="Quarter Filled Barrel"&&src.CType=="Tar")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Half Filled Barrel"
									src.volume=50
									J.volume=0
									J.name="Jar"
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Tar"&&src.name=="Half Filled Barrel"&&src.CType=="Tar")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="ThreeQuarters Filled Barrel"
									src.volume=75
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Tar"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Tar")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Filled Barrel"
									src.volume=100
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									if(src.volume>src.volumecap)
										src.volume = src.volumecap
									icon_state = "Barrelt"
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
		//Oil Jar
							if(J.CType=="Oil")
								if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Oil"&&src.name=="Barrel"&&src.CType=="Empty")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Quarter Filled Barrel"
									src.volume=25
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									CType="Oil"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Oil"&&src.name=="Quarter Filled Barrel"&&src.CType=="Oil")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Half Filled Barrel"
									src.volume=50
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Oil"&&src.name=="Half Filled Barrel"&&src.CType=="Oil")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="ThreeQuarters Filled Barrel"
									src.volume=75
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Oil"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Oil")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									J.name="Jar"
									src.name="Filled Barrel"
									src.volume=100
									J.volume=0
									J.CType="Empty"
									if(src.volume>src.volumecap)
										src.volume = src.volumecap
									src.icon_state = "Barrelo"
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
		//Sand Jar
							if(J.CType=="Sand")
								if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Sand"&&src.name=="Barrel"&&src.CType=="Empty")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Quarter Filled Barrel"
									src.volume=25
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									CType="Sand"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Sand"&&src.name=="Quarter Filled Barrel"&&src.CType=="Sand")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Half Filled Barrel"
									src.volume=50
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Sand"&&src.name=="Half Filled Barrel"&&src.CType=="Sand")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="ThreeQuarters Filled Barrel"
									src.volume=75
									J.name="Jar"
									J.volume=0
									J.CType="Empty"
									//overlays += /obj/bliquid
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
								else if(M.JRequipped==1&&J.volume==J.volumecap&&J.filled==1&&J.CType=="Sand"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Sand")
									M<<"You begin filling the Barrel with the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									J.name="Jar"
									src.name="Filled Barrel"
									src.volume=100
									J.volume=0
									J.CType="Empty"
									if(src.volume>src.volumecap)
										src.volume = src.volumecap
									src.icon_state = "Barrels"
									sleep(1)
									M<<"You Filled the Barrel with [CType]."
									return
//vessel
						else
							goto Vessel

		//Water Vessel
						Vessel
					//Full Vessel Empty Barrel
						if(J2.CType=="Water")
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								J2.CType="Empty"
								src.name="Half Filled Barrel"
								src.volume+=J2.volumecap
								J2.volume=0
								CType="Water"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Quarter Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Water")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Half Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Water")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								icon_state = "Barrelw"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel ThreeQuarters Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Water")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselwhf"
								J2.name="Half Filled Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=25
								icon_state = "Barrelw"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel Empty Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Quarter Filled Barrel"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								CType = "Water"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Quarter Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Water")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Barrel"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Half Fill Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Water")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel ThreeQuarters Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Water")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselwhf"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								icon_state = "Barrelw"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
		//Tar Vessel
						if(J2.CType=="Tar")
					//Full Vessel Empty Barrel
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								J2.CType="Empty"
								src.name="Half Filled Barrel"
								src.volume+=J2.volumecap
								J2.volume=0
								CType="Tar"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Quarter Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Tar")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Half Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Tar")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								icon_state = "Barrelt"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel ThreeQuarters Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Tar")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselthf"
								J2.name="Half Filled Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=25
								icon_state = "Barrelt"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel Empty Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Quarter Filled Barrel"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								CType = "Tar"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Quarter Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Tar")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Barrel"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Half Fill Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Tar")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel ThreeQuarters Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Tar")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								icon_state = "Barrelt"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
		//Oil Vessel
						if(J2.CType=="Oil")
							//Full Vessel Empty Barrel
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								J2.CType="Empty"
								src.name="Half Filled Barrel"
								src.volume+=J2.volumecap
								J2.volume=0
								CType="Oil"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Quarter Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Oil")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Half Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Oil")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								icon_state = "Barrelo"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel ThreeQuarters Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Oil")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselohf"
								J2.name="Half Filled Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=25
								icon_state = "Barrelo"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel Empty Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Quarter Filled Barrel"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								CType = "Oil"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Quarter Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Oil")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Barrel"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Half Fill Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Oil")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel ThreeQuarters Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Oil")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								icon_state = "Barrelo"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
		//Sand Vessel
						if(J2.CType=="Sand")
							//Full Vessel Empty Barrel
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								J2.CType="Empty"
								src.name="Half Filled Barrel"
								src.volume+=J2.volumecap
								J2.volume=0
								CType="Sand"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Quarter Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Sand")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel Half Fill Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Sand")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								icon_state = "Barrels"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Full Vessel ThreeQuarters Barrel
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Sand")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselshf"
								J2.name="Half Filled Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=25
								icon_state = "Barrels"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel Empty Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Barrel"&&src.CType=="Empty")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Quarter Filled Barrel"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								CType = "Sand"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Quarter Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Quarter Filled Barrel"&&src.CType=="Sand")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Barrel"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return
					//Half Fill Vessel Half Fill Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Barrel"&&src.CType=="Sand")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="ThreeQuarters Filled Barrel"
								src.volume=75
								J2.volume=0
								J2.CType="Empty"
								//overlays += /obj/bliquid
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					//Half Fill Vessel ThreeQuarters Barrel
							else if(J2.volume==25&&J2.name=="Half Filled Vessel"&&src.name=="ThreeQuarters Filled Barrel"&&src.CType=="Sand")
								M<<"You begin filling the Barrel with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Barrel"
								src.volume=volumecap
								J2.volume=0
								J2.CType="Empty"
								//CType = "Water"
								icon_state = "Barrels"
								sleep(1)
								M<<"You Filled the Barrel with [CType]."
								return

					verb/Empty()
						set category=null
						set src in view()
						set popup_menu=1
						var/mob/players/M = usr
						//var/obj/items/tools/Containers/Vessel/J = locate() in M.contents
						if(name=="Filled Barrel"||name=="ThreeQuarters Filled Barrel"||name=="Half Filled Barrel"||name=="Quarter Filled Barrel")
							//set category = "Commands"
							icon_state = "Barrel"
							name="Barrel"
							volume=0
							CType="Empty"
							M<<"You empty the [CType] in the Barrel on to the ground."
							return

						else
							M<<"The Barrel is already empty."
							return
					New()
						..()
						Description()
						//Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Volume %[volume]-%[volumecap]<br>Contents [CType]<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				QuenchBox //name of object
					icon_state = "QuenchBox" //icon state of object
					//typi = "JR"
					strreq = 3
					name = "Quench Box"
					//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
					Worth = 1
					//wpnspd = 1
					density = 1
					volume = 0
					volumecap = 50
					CType = "Empty"
					tlvl = 1
					var/pushing=1
					blockcarry=1
					//twohanded = 1
					verb/Description()//Fixes description
						set category=null
						set popup_menu=1
						set src in usr
						//usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
						//return
						usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'><br><font color = #e6e8fa><center><b>[name]</b><br>Volume% [volume]-[volumecap]<br>Contents [CType]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					verb/Quench()//working confirmed -- could probably be expanded more
						set src in view()
						var/mob/players/M
						M = usr
						var/mob/players/J = locate() in view(1,src)//call(/obj/items/tools/Containers/QuenchBox/proc/FindQB)(M)
						//var/obj/items/tools/Containers/Quench Box/J2 = locate() in view(1,M)
						if(J.GVequipped==1)//testing
							if(src.CType!="Empty")
								//M << "[J] [J.name] check Filled Quench Box"
								Qench()
								return
							else
								M << "Quench Box must be filled to quench."
								return
								//M << "src[src] CType[CType] src.CType[src.CType]"
						else
							M << "Need to use gloves."
							return
						//if(J2)
							//M << "Quench Box"
							//call(/obj/items/tools/Containers/Quench Box/proc/Qench)(src)

					proc/FindHMf(mob/players/M)
						for(var/obj/items/Crafting/Created/HammerHead/J in M.contents)//Hammer Head
							locate(J)
							if(J:needsquenched==1)
								return J
					proc/FindCKf(mob/players/M)
						for(var/obj/items/Crafting/Created/CKnifeblade/J1 in M.contents)//Carving Knife
							locate(J1)
							if(J1:needsquenched==1)
								return J1
					proc/FindSBf(mob/players/M)
						for(var/obj/items/Crafting/Created/SickleBlade/J2 in M.contents)//Sickle
							locate(J2)
							if(J2:needsquenched==1)
								return J2
					proc/FindTWBf(mob/players/M)
						for(var/obj/items/Crafting/Created/TrowelBlade/J3 in M.contents)//Trowel
							locate(J3)
							if(J3:needsquenched==1)
								return J3
					proc/FindCBf(mob/players/M)
						for(var/obj/items/Crafting/Created/ChiselBlade/J4 in M.contents)//Chisel
							locate(J4)
							if(J4:needsquenched==1)
								return J4
					proc/FindAHf(mob/players/M)
						for(var/obj/items/Crafting/Created/AxeHead/J5 in M.contents)//Axe
							locate(J5)
							if(J5:needsquenched==1)
								return J5
					proc/FindFBf(mob/players/M)
						for(var/obj/items/Crafting/Created/FileBlade/J6 in M.contents)//File
							locate(J6)
							if(J6:needsquenched==1)
								return J6
					proc/FindSHf(mob/players/M)
						for(var/obj/items/Crafting/Created/ShovelHead/J7 in M.contents)//Shovel
							locate(J7)
							if(J7:needsquenched==1)
								return J7
					proc/FindHOf(mob/players/M)
						for(var/obj/items/Crafting/Created/HoeBlade/J8 in M.contents)//Hoe
							locate(J8)
							if(J8:needsquenched==1)
								return J8
					proc/FindPXf(mob/players/M)
						for(var/obj/items/Crafting/Created/PickaxeHead/J9 in M.contents)//Pickaxe
							locate(J9)
							if(J9:needsquenched==1)
								return J9
					proc/FindSWf(mob/players/M)
						for(var/obj/items/Crafting/Created/SawBlade/J10 in M.contents)//Saw
							locate(J10)
							if(J10:needsquenched==1)
								return J10
		//Weapon Check   "Broad Sword","War Sword","Battle Sword","Long Sword","War Maul","Battle Hammer","War Axe","Battle Axe","Battle Scythe","War Scythe"

					proc/FindBSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Broadswordblade/J11 in M.contents)//Broad Sword
							locate(J11)
							if(J11:needsquenched==1)
								return J11
					proc/FindWSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warswordblade/J12 in M.contents)//War Sword
							locate(J12)
							if(J12:needsquenched==1)
								return J12
					proc/FindBSWf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battleswordblade/J13 in M.contents)//Battle Sword
							locate(J13)
							if(J13:needsquenched==1)
								return J13
					proc/FindLSf(mob/players/M)
						for(var/obj/items/Crafting/Created/Longswordblade/J14 in M.contents)//Long Sword
							locate(J14)
							if(J14:needsquenched==1)
								return J14
					proc/FindWMf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warmaulhead/J15 in M.contents)//War Maul
							locate(J15)
							if(J15:needsquenched==1)
								return J15
					proc/FindBHf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battlehammersledge/J16 in M.contents)//Battle Hammer
							locate(J16)
							if(J16:needsquenched==1)
								return J16
					proc/FindWXf(mob/players/M)
						for(var/obj/items/Crafting/Created/Waraxeblade/J17 in M.contents)//War Axe
							locate(J17)
							if(J17:needsquenched==1)
								return J17
					proc/FindBXf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battleaxeblade/J18 in M.contents)//Battle Axe
							locate(J18)
							if(J18:needsquenched==1)
								return J18
					proc/FindWSYf(mob/players/M)
						for(var/obj/items/Crafting/Created/Warscytheblade/J19 in M.contents)//War Scythe
							locate(J19)
							if(J19:needsquenched==1)
								return J19
					proc/FindBSYf(mob/players/M)
						for(var/obj/items/Crafting/Created/Battlescytheblade/J20 in M.contents)//Battle Scythe
							locate(J20)
							if(J20:needsquenched==1)
								return J20

		//Lamp

					proc/FindILf(mob/players/M)
						for(var/obj/items/Crafting/Created/IronLampHead/J21 in M.contents)//Iron Lamp Head
							locate(J21)
							if(J21:needsquenched==1)
								return J21
					proc/FindCLf(mob/players/M)
						for(var/obj/items/Crafting/Created/CopperLampHead/J22 in M.contents)//Copper Lamp Head
							locate(J22)
							if(J22:needsquenched==1)
								return J22
					proc/FindBRLf(mob/players/M)
						for(var/obj/items/Crafting/Created/BronzeLampHead/J23 in M.contents)//Bronze Lamp Head
							locate(J23)
							if(J23:needsquenched==1)
								return J23
					proc/FindBSLf(mob/players/M)
						for(var/obj/items/Crafting/Created/BrassLampHead/J24 in M.contents)//Brass Lamp Head
							locate(J24)
							if(J24:needsquenched==1)
								return J24
					proc/FindSLf(mob/players/M)
						for(var/obj/items/Crafting/Created/SteelLampHead/J25 in M.contents)//Steel Lamp Head
							locate(J25)
							if(J25:needsquenched==1)
								return J25
		//Misc Parts
					/*proc/FindAVf(mob/players/M)
						for(var/obj/items/Crafting/Created/AnvilHead/J26 in M.contents)//Iron Anvil Head
							locate(J26)
							if(J26:needsquenched==1)
								return J26*/



					proc/Qench()//working
						//set src in usr
						var/mob/players/M
						M = usr
						//var/obj/items/Crafting/Created/Whetstone/S = locate() in M.contents
//Tool Call
						var/obj/items/Crafting/Created/HammerHead/J = call(/obj/items/tools/Containers/QuenchBox/proc/FindHMf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/CKnifeblade/J1 = call(/obj/items/tools/Containers/QuenchBox/proc/FindCKf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SickleBlade/J2 = call(/obj/items/tools/Containers/QuenchBox/proc/FindSBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/TrowelBlade/J3 = call(/obj/items/tools/Containers/QuenchBox/proc/FindTWBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/ChiselBlade/J4 = call(/obj/items/tools/Containers/QuenchBox/proc/FindCBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/AxeHead/J5 = call(/obj/items/tools/Containers/QuenchBox/proc/FindAHf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/FileBlade/J6 = call(/obj/items/tools/Containers/QuenchBox/proc/FindFBf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/ShovelHead/J7 = call(/obj/items/tools/Containers/QuenchBox/proc/FindSHf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/HoeBlade/J8 = call(/obj/items/tools/Containers/QuenchBox/proc/FindHOf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/PickaxeHead/J9 = call(/obj/items/tools/Containers/QuenchBox/proc/FindPXf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SawBlade/J10 = call(/obj/items/tools/Containers/QuenchBox/proc/FindSWf)(M)//locate() in M.contents
//Weapon Call

						var/obj/items/Crafting/Created/Broadswordblade/J11 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warswordblade/J12 = call(/obj/items/tools/Containers/QuenchBox/proc/FindWSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battleswordblade/J13 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBSWf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Longswordblade/J14 = call(/obj/items/tools/Containers/QuenchBox/proc/FindLSf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warmaulhead/J15 = call(/obj/items/tools/Containers/QuenchBox/proc/FindWMf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battlehammersledge/J16 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBHf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Waraxeblade/J17 = call(/obj/items/tools/Containers/QuenchBox/proc/FindWXf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battleaxeblade/J18 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBXf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Warscytheblade/J19 = call(/obj/items/tools/Containers/QuenchBox/proc/FindWSYf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/Battlescytheblade/J20 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBSYf)(M)//locate() in M.contents

//Lamp Call

						var/obj/items/Crafting/Created/IronLampHead/J21 = call(/obj/items/tools/Containers/QuenchBox/proc/FindILf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/CopperLampHead/J22 = call(/obj/items/tools/Containers/QuenchBox/proc/FindCLf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/BronzeLampHead/J23 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBRLf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/BrassLampHead/J24 = call(/obj/items/tools/Containers/QuenchBox/proc/FindBSLf)(M)//locate() in M.contents
						var/obj/items/Crafting/Created/SteelLampHead/J25 = call(/obj/items/tools/Containers/QuenchBox/proc/FindSLf)(M)//locate() in M.contents
//Misc Parts
						//var/obj/items/Crafting/Created/AnvilHead/J26 = call(/obj/items/tools/Containers/QuenchBox/proc/FindSLf)(M)//locate() in M.contents

//Water Tool part Quench Check
						if(src:CType=="Empty")
							M << "Need to fill the Quench Box to Quench!"
							return
						if(src:CType=="Sand")
							M << "You can't use Sand to Quench!"
							return
						if(src:CType=="Water")
							if(J&&J.Tname!="Cool")
								if(J.Tname=="Hot")
									M<<"You submerge the [J.Tname] [J] into the water."
									J.needsquenched=0
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"You have quenched [J]! Test it for hardness with a File."
									return
								else if(J.Tname=="Warm")
									M<<"You submerge the [J.Tname] [J] into the water."
									J.needsquenched=1
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J] wasn't hot enough."
									return
							else if(!J)
								return
							else if(J.Tname=="Cool")
								M << "Heat the [J] before quenching."
								return
							if(J1&&J1.Tname!="Cool")
								if(J1.Tname=="Hot")
									M<<"You submerge the [J1.Tname] [J1] into the water."
									J1.needsquenched=0
									sleep(3)
									J1.Tname="Cool"
									M<<"You have quenched [J1]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J1.Tname=="Warm")
									M<<"You submerge the [J1.Tname] [J1] into the water."
									J1.needsquenched=1
									sleep(3)
									J1.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J1] wasn't hot enough."
									return
							else if(!J1)
								return
							else if(J1.Tname=="Cool")
								M << "Heat the [J1] before quenching."
								return
							if(J2&&J2.Tname!="Cool")
								if(J2.Tname=="Hot")
									M<<"You submerge the [J2.Tname] [J2] into the water."
									J2.needsquenched=0
									sleep(3)
									J2.Tname="Cool"
									M<<"You have quenched [J2]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J2.Tname=="Warm")
									M<<"You submerge the [J2.Tname] [J2] into the water."
									J2.needsquenched=1
									sleep(3)
									J2.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J2] wasn't hot enough."
									return
							else if(!J2)
								return
							else if(J2.Tname=="Cool")
								M << "Heat the [J2] before quenching."
								return
							if(J3&&J3.Tname!="Cool")
								if(J3.Tname=="Hot")
									M<<"You submerge the [J3.Tname] [J3] into the water."
									J3.needsquenched=0
									sleep(3)
									J3.Tname="Cool"
									M<<"You have quenched [J3]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J3.Tname=="Warm")
									M<<"You submerge the [J3.Tname] [J3] into the water."
									J3.needsquenched=1
									sleep(3)
									J3.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J3] wasn't hot enough."
									return
							else if(!J3)
								return
							else if(J3.Tname=="Cool")
								M << "Heat the [J3] before quenching."
								return
							if(J4&&J4.Tname!="Cool")
								if(J4.Tname=="Hot")
									M<<"You submerge the [J4.Tname] [J4] into the water."
									J4.needsquenched=0
									sleep(3)
									J4.Tname="Cool"
									M<<"You have quenched [J4]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J4.Tname=="Warm")
									M<<"You submerge the [J4.Tname] [J4] into the water."
									J4.needsquenched=1
									sleep(3)
									J4.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J4] wasn't hot enough."
									return
							else if(!J4)
								return
							else if(J4.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J5&&J5.Tname!="Cool")
								if(J5.Tname=="Hot")
									M<<"You submerge the [J5.Tname] [J5] into the water."
									J5.needsquenched=0
									sleep(3)
									J5.Tname="Cool"
									M<<"You have quenched [J5]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J5.Tname=="Warm")
									M<<"You submerge the [J5.Tname] [J5] into the water."
									J5.needsquenched=1
									sleep(3)
									J5.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J5] wasn't hot enough."
									return
							else if(!J5)
								return
							else if(J5.Tname=="Cool")
								M << "Heat the [J5] before quenching."
								return
							if(J6&&J6.Tname!="Cool")
								if(J6.Tname=="Hot")
									M<<"You submerge the [J6.Tname] [J6] into the water."
									J6.needsquenched=0
									sleep(3)
									J6.Tname="Cool"
									M<<"You have quenched [J6]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J6.Tname=="Warm")
									M<<"You submerge the [J6.Tname] [J6] into the water."
									J6.needsquenched=1
									sleep(3)
									J6.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J6] wasn't hot enough."
									return
							else if(!J6)
								return
							else if(J6.Tname=="Cool")
								M << "Heat the [J6] before quenching."
								return
							if(J7&&J7.Tname!="Cool")
								if(J7.Tname=="Hot")
									M<<"You submerge the [J7.Tname] [J7] into the water."
									J7.needsquenched=0
									sleep(3)
									J7.Tname="Cool"
									M<<"You have quenched [J7]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J7.Tname=="Warm")
									M<<"You submerge the [J7.Tname] [J7] into the water."
									J7.needsquenched=1
									sleep(3)
									J7.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J7] wasn't hot enough."
									return
							else if(!J7)
								return
							else if(J7.Tname=="Cool")
								M << "Heat the [J7] before quenching."
								return
							if(J8&&J8.Tname!="Cool")
								if(J8.Tname=="Hot")
									M<<"You submerge the [J8.Tname] [J8] into the water."
									J8.needsquenched=0
									sleep(3)
									J8.Tname="Cool"
									M<<"You have quenched [J8]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J8.Tname=="Warm")
									M<<"You submerge the [J8.Tname] [J8] into the water."
									J8.needsquenched=1
									sleep(3)
									J8.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J8] wasn't hot enough."
									return
							else if(!J8)
								return
							else if(J8.Tname=="Cool")
								M << "Heat the [J8] before quenching."
								return
							if(J9&&J9.Tname!="Cool")
								if(J9.Tname=="Hot")
									M<<"You submerge the [J9.Tname] [J9] into the water."
									J9.needsquenched=0
									sleep(3)
									J9.Tname="Cool"
									M<<"You have quenched [J9]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J9.Tname=="Warm")
									M<<"You submerge the [J9.Tname] [J9] into the water."
									J9.needsquenched=1
									sleep(3)
									J9.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J9] wasn't hot enough."
									return
							else if(!J9)
								return
							else if(J9.Tname=="Cool")
								M << "Heat the [J9] before quenching."
								return
							if(J10&&J10.Tname!="Cool")
								if(J10.Tname=="Hot")
									M<<"You submerge the [J10.Tname] [J10] into the water."
									J10.needsquenched=0
									sleep(3)
									J10.Tname="Cool"
									M<<"You have quenched [J10]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J10.Tname=="Warm")
									M<<"You submerge the [J10.Tname] [J10] into the water."
									J10.needsquenched=1
									sleep(3)
									J10.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J10] wasn't hot enough."
									return
							else if(!J10)
								return
							else if(J10.Tname=="Cool")
								M << "Heat the [J10] before quenching."
								return

//Water Weapon part Quench Process
							if(J11&&J11.Tname!="Cool")
								if(J11.Tname=="Hot")
									M<<"You submerge the [J11.Tname] [J11] into the water."
									J11.needsquenched=0
									sleep(3)
									J11.Tname="Cool"
									M<<"You have quenched [J11]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J11.Tname=="Warm")
									M<<"You submerge the [J11.Tname] [J11] into the water."
									J11.needsquenched=1
									sleep(3)
									J11.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J11] wasn't hot enough."
									return
							else if(!J11)
								return
							else if(J11.Tname=="Cool")
								M << "Heat the [J11] before quenching."
								return
							if(J12&&J12.Tname!="Cool")
								if(J12.Tname=="Hot")
									M<<"You submerge the [J12.Tname] [J12] into the water."
									J12.needsquenched=0
									sleep(3)
									J12.Tname="Cool"
									M<<"You have quenched [J12]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J12.Tname=="Warm")
									M<<"You submerge the [J12.Tname] [J12] into the water."
									J12.needsquenched=1
									sleep(3)
									J12.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J12] wasn't hot enough."
									return
							else if(!J12)
								return
							else if(J12.Tname=="Cool")
								M << "Heat the [J12] before quenching."
								return
							if(J13&&J13.Tname!="Cool")
								if(J13.Tname=="Hot")
									M<<"You submerge the [J13.Tname] [J13] into the water."
									J13.needsquenched=0
									sleep(3)
									J13.Tname="Cool"
									M<<"You have quenched [J13]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J13.Tname=="Warm")
									M<<"You submerge the [J13.Tname] [J13] into the water."
									J13.needsquenched=1
									sleep(3)
									J13.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J13] wasn't hot enough."
									return
							else if(!J13)
								return
							else if(J13.Tname=="Cool")
								M << "Heat the [J13] before quenching."
								return
							if(J14&&J14.Tname!="Cool")
								if(J14.Tname=="Hot")
									M<<"You submerge the [J14.Tname] [J14] into the water."
									J14.needsquenched=0
									sleep(3)
									J14.Tname="Cool"
									M<<"You have quenched [J14]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J14.Tname=="Warm")
									M<<"You submerge the [J14.Tname] [J14] into the water."
									J14.needsquenched=1
									sleep(3)
									J14.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J14] wasn't hot enough."
									return
							else if(!J14)
								return
							else if(J14.Tname=="Cool")
								M << "Heat the [J14] before quenching."
								return
							if(J15&&J15.Tname!="Cool")
								if(J15.Tname=="Hot")
									M<<"You submerge the [J15.Tname] [J15] into the water."
									J15.needsquenched=0
									sleep(3)
									J15.Tname="Cool"
									M<<"You have quenched [J15]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J15.Tname=="Warm")
									M<<"You submerge the [J15.Tname] [J15] into the water."
									J15.needsquenched=1
									sleep(3)
									J15.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J15] wasn't hot enough."
									return
							else if(!J15)
								return
							else if(J15.Tname=="Cool")
								M << "Heat the [J15] before quenching."
								return
							if(J16&&J16.Tname!="Cool")
								if(J16.Tname=="Hot")
									M<<"You submerge the [J16.Tname] [J16] into the water."
									J16.needsquenched=0
									sleep(3)
									J16.Tname="Cool"
									M<<"You have quenched [J16]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J16.Tname=="Warm")
									M<<"You submerge the [J16.Tname] [J16] into the water."
									J16.needsquenched=1
									sleep(3)
									J16.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J16] wasn't hot enough."
									return
							else if(!J16)
								return
							else if(J16.Tname=="Cool")
								M << "Heat the [J16] before quenching."
								return
							if(J17&&J17.Tname!="Cool")
								if(J17.Tname=="Hot")
									M<<"You submerge the [J17.Tname] [J17] into the water."
									J17.needsquenched=0
									sleep(3)
									J17.Tname="Cool"
									M<<"You have quenched [J17]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J17.Tname=="Warm")
									M<<"You submerge the [J17.Tname] [J17] into the water."
									J17.needsquenched=1
									sleep(3)
									J17.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J17] wasn't hot enough."
									return
							else if(!J17)
								return
							else if(J17.Tname=="Cool")
								M << "Heat the [J17] before quenching."
								return
							if(J18&&J18.Tname!="Cool")
								if(J18.Tname=="Hot")
									M<<"You submerge the [J18.Tname] [J18] into the water."
									J18.needsquenched=0
									sleep(3)
									J18.Tname="Cool"
									M<<"You have quenched [J18]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J18.Tname=="Warm")
									M<<"You submerge the [J18.Tname] [J18] into the water."
									J18.needsquenched=1
									sleep(3)
									J18.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J18] wasn't hot enough."
									return
							else if(!J18)
								return
							else if(J18.Tname=="Cool")
								M << "Heat the [J18] before quenching."
								return
							if(J19&&J19.Tname!="Cool")
								if(J19.Tname=="Hot")
									M<<"You submerge the [J19.Tname] [J19] into the water."
									J19.needsquenched=0
									sleep(3)
									J19.Tname="Cool"
									M<<"You have quenched [J19]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J19.Tname=="Warm")
									M<<"You submerge the [J19.Tname] [J19] into the water."
									J19.needsquenched=1
									sleep(3)
									J19.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J19] wasn't hot enough."
									return
							else if(!J19)
								return
							else if(J19.Tname=="Cool")
								M << "Heat the [J19] before quenching."
								return
							if(J20&&J20.Tname!="Cool")
								if(J20.Tname=="Hot")
									M<<"You submerge the [J20.Tname] [J20] into the water."
									J20.needsquenched=0
									sleep(3)
									J20.Tname="Cool"
									M<<"You have quenched [J20]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J20.Tname=="Warm")
									M<<"You submerge the [J20.Tname] [J20] into the water."
									J20.needsquenched=1
									sleep(3)
									J20.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J20] wasn't hot enough."
									return
							else if(!J20)
								return
							else if(J20.Tname=="Cool")
								M << "Heat the [J20] before quenching."
								return


//Water Lamp part Quench Process
							if(J21&&J21.Tname!="Cool")
								if(J21.Tname=="Hot")
									M<<"You submerge the [J21.Tname] [J21] into the water."
									J21.needsquenched=0
									sleep(3)
									J21.Tname="Cool"
									M<<"You have quenched [J21]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J21.Tname=="Warm")
									M<<"You submerge the [J21.Tname] [J21] into the water."
									J21.needsquenched=1
									sleep(3)
									J21.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J21] wasn't hot enough."
									return
							else if(!J21)
								return
							else if(J21.Tname=="Cool")
								M << "Heat the [J21] before quenching."
								return
							if(J22&&J22.Tname!="Cool")
								if(J22.Tname=="Hot")
									M<<"You submerge the [J22.Tname] [J22] into the water."
									J22.needsquenched=0
									sleep(3)
									J22.Tname="Cool"
									M<<"You have quenched [J22]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J22.Tname=="Warm")
									M<<"You submerge the [J22.Tname] [J22] into the water."
									J22.needsquenched=1
									sleep(3)
									J22.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J22] wasn't hot enough."
									return
							else if(!J22)
								return
							else if(J22.Tname=="Cool")
								M << "Heat the [J22] before quenching."
								return
							if(J23&&J23.Tname!="Cool")
								if(J23.Tname=="Hot")
									M<<"You submerge the [J23.Tname] [J23] into the water."
									J23.needsquenched=0
									sleep(3)
									J23.Tname="Cool"
									M<<"You have quenched [J23]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J23.Tname=="Warm")
									M<<"You submerge the [J23.Tname] [J23] into the water."
									J23.needsquenched=1
									sleep(3)
									J23.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J23] wasn't hot enough."
									return
							else if(!J23)
								return
							else if(J23.Tname=="Cool")
								M << "Heat the [J23] before quenching."
								return
							if(J24&&J24.Tname!="Cool")
								if(J24.Tname=="Hot")
									M<<"You submerge the [J24.Tname] [J24] into the water."
									J24.needsquenched=0
									sleep(3)
									J24.Tname="Cool"
									M<<"You have quenched [J24]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J24.Tname=="Warm")
									M<<"You submerge the [J24.Tname] [J24] into the water."
									J24.needsquenched=1
									sleep(3)
									J24.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J24] wasn't hot enough."
									return
							else if(!J24)
								return
							else if(J24.Tname=="Cool")
								M << "Heat the [J24] before quenching."
								return
							if(J25&&J25.Tname!="Cool")
								if(J25.Tname=="Hot")
									M<<"You submerge the [J25.Tname] [J25] into the water."
									J25.needsquenched=0
									sleep(3)
									J25.Tname="Cool"
									M<<"You have quenched [J25]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J25.Tname=="Warm")
									M<<"You submerge the [J25.Tname] [J25] into the water."
									J25.needsquenched=1
									sleep(3)
									J25.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J25] wasn't hot enough."
									return
							else if(!J25)
								return
							else if(J25.Tname=="Cool")
								M << "Heat the [J25] before quenching."
								return

//Tar Tool Quench Process
						if(src:CType=="Tar")
							if(J&&J.Tname!="Cool")
								if(J.Tname=="Hot")
									M<<"You submerge the [J.Tname] [J] into the tar."
									J.needsquenched=0
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"You have quenched [J]! Test it for hardness with a File."
									return
								else if(J.Tname=="Warm")
									M<<"You submerge the [J.Tname] [J] into the tar."
									J.needsquenched=1
									sleep(3)
									J.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J] wasn't hot enough."
									return
							else if(!J)
								return
							else if(J.Tname=="Cool")
								M << "Heat the [J] before quenching."
								return
							if(J1&&J1.Tname!="Cool")
								if(J1.Tname=="Hot")
									M<<"You submerge the [J1.Tname] [J1] into the tar."
									J1.needsquenched=0
									sleep(3)
									J1.Tname="Cool"
									M<<"You have quenched [J1]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J1.Tname=="Warm")
									M<<"You submerge the [J1.Tname] [J1] into the tar."
									J1.needsquenched=1
									sleep(3)
									J1.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J1] wasn't hot enough."
									return
							else if(!J1)
								return
							else if(J1.Tname=="Cool")
								M << "Heat the [J1] before quenching."
								return
							if(J2&&J2.Tname!="Cool")
								if(J2.Tname=="Hot")
									M<<"You submerge the [J2.Tname] [J2] into the tar."
									J2.needsquenched=0
									sleep(3)
									J2.Tname="Cool"
									M<<"You have quenched [J2]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J2.Tname=="Warm")
									M<<"You submerge the [J2.Tname] [J2] into the tar."
									J2.needsquenched=1
									sleep(3)
									J2.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J2] wasn't hot enough."
									return
							else if(!J2)
								return
							else if(J2.Tname=="Cool")
								M << "Heat the [J2] before quenching."
								return
							if(J3&&J3.Tname!="Cool")
								if(J3.Tname=="Hot")
									M<<"You submerge the [J3.Tname] [J3] into the tar."
									J3.needsquenched=0
									sleep(3)
									J3.Tname="Cool"
									M<<"You have quenched [J3]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J3.Tname=="Warm")
									M<<"You submerge the [J3.Tname] [J3] into the tar."
									J3.needsquenched=1
									sleep(3)
									J3.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J3] wasn't hot enough."
									return
							else if(!J3)
								return
							else if(J3.Tname=="Cool")
								M << "Heat the [J3] before quenching."
								return
							if(J4&&J4.Tname!="Cool")
								if(J4.Tname=="Hot")
									M<<"You submerge the [J4.Tname] [J4] into the tar."
									J4.needsquenched=0
									sleep(3)
									J4.Tname="Cool"
									M<<"You have quenched [J4]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J4.Tname=="Warm")
									M<<"You submerge the [J4.Tname] [J4] into the tar."
									J4.needsquenched=1
									sleep(3)
									J4.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J4] wasn't hot enough."
									return
							else if(!J4)
								return
							else if(J4.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J5&&J5.Tname!="Cool")
								if(J5.Tname=="Hot")
									M<<"You submerge the [J5.Tname] [J5] into the tar."
									J5.needsquenched=0
									sleep(3)
									J5.Tname="Cool"
									M<<"You have quenched [J5]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J5.Tname=="Warm")
									M<<"You submerge the [J5.Tname] [J5] into the tar."
									J5.needsquenched=1
									sleep(3)
									J5.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J5] wasn't hot enough."
									return
							else if(!J5)
								return
							else if(J5.Tname=="Cool")
								M << "Heat the [J5] before quenching."
								return
							if(J6&&J6.Tname!="Cool")
								if(J6.Tname=="Hot")
									M<<"You submerge the [J6.Tname] [J6] into the tar."
									J6.needsquenched=0
									sleep(3)
									J6.Tname="Cool"
									M<<"You have quenched [J6]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J6.Tname=="Warm")
									M<<"You submerge the [J6.Tname] [J6] into the tar."
									J6.needsquenched=1
									sleep(3)
									J6.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J6] wasn't hot enough."
									return
							else if(!J6)
								return
							else if(J6.Tname=="Cool")
								M << "Heat the [J6] before quenching."
								return
							if(J7&&J7.Tname!="Cool")
								if(J7.Tname=="Hot")
									M<<"You submerge the [J7.Tname] [J7] into the tar."
									J7.needsquenched=0
									sleep(3)
									J7.Tname="Cool"
									M<<"You have quenched [J7]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J7.Tname=="Warm")
									M<<"You submerge the [J7.Tname] [J7] into the tar."
									J7.needsquenched=1
									sleep(3)
									J7.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J7] wasn't hot enough."
									return
							else if(!J7)
								return
							else if(J7.Tname=="Cool")
								M << "Heat the [J7] before quenching."
								return
							if(J8&&J8.Tname!="Cool")
								if(J8.Tname=="Hot")
									M<<"You submerge the [J8.Tname] [J8] into the tar."
									J8.needsquenched=0
									sleep(3)
									J8.Tname="Cool"
									M<<"You have quenched [J8]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J8.Tname=="Warm")
									M<<"You submerge the [J8.Tname] [J8] into the tar."
									J8.needsquenched=1
									sleep(3)
									J8.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J8] wasn't hot enough."
									return
							else if(!J8)
								return
							else if(J8.Tname=="Cool")
								M << "Heat the [J8] before quenching."
								return
							if(J9&&J9.Tname!="Cool")
								if(J9.Tname=="Hot")
									M<<"You submerge the [J9.Tname] [J9] into the tar."
									J9.needsquenched=0
									sleep(3)
									J9.Tname="Cool"
									M<<"You have quenched [J9]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J9.Tname=="Warm")
									M<<"You submerge the [J9.Tname] [J9] into the tar."
									J9.needsquenched=1
									sleep(3)
									J9.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J9] wasn't hot enough."
									return
							else if(!J9)
								return
							else if(J9.Tname=="Cool")
								M << "Heat the [J9] before quenching."
								return
							if(J10&&J10.Tname!="Cool")
								if(J10.Tname=="Hot")
									M<<"You submerge the [J10.Tname] [J10] into the tar."
									J10.needsquenched=0
									sleep(3)
									J10.Tname="Cool"
									M<<"You have quenched [J10]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J10.Tname=="Warm")
									M<<"You submerge the [J10.Tname] [J10] into the tar."
									J10.needsquenched=1
									sleep(3)
									J10.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J10] wasn't hot enough."
									return
							else if(!J10)
								return
							else if(J10.Tname=="Cool")
								M << "Heat the [J10] before quenching."
								return

//Tar Weapon Quench Process
							if(J11&&J11.Tname!="Cool")
								if(J11.Tname=="Hot")
									M<<"You submerge the [J11.Tname] [J11] into the tar."
									J11.needsquenched=0
									sleep(3)
									J11.Tname="Cool"
									M<<"You have quenched [J11]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J11.Tname=="Warm")
									M<<"You submerge the [J11.Tname] [J11] into the tar."
									J11.needsquenched=1
									sleep(3)
									J11.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J11] wasn't hot enough."
									return
							else if(!J11)
								return
							else if(J11.Tname=="Cool")
								M << "Heat the [J11] before quenching."
								return
							if(J12&&J12.Tname!="Cool")
								if(J12.Tname=="Hot")
									M<<"You submerge the [J12.Tname] [J12] into the tar."
									J12.needsquenched=0
									sleep(3)
									J12.Tname="Cool"
									M<<"You have quenched [J12]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J12.Tname=="Warm")
									M<<"You submerge the [J12.Tname] [J12] into the tar."
									J12.needsquenched=1
									sleep(3)
									J12.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J12] wasn't hot enough."
									return
							else if(!J12)
								return
							else if(J12.Tname=="Cool")
								M << "Heat the [J12] before quenching."
								return
							if(J13&&J13.Tname!="Cool")
								if(J13.Tname=="Hot")
									M<<"You submerge the [J13.Tname] [J13] into the tar."
									J13.needsquenched=0
									sleep(3)
									J13.Tname="Cool"
									M<<"You have quenched [J13]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J13.Tname=="Warm")
									M<<"You submerge the [J13.Tname] [J13] into the tar."
									J13.needsquenched=1
									sleep(3)
									J13.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J13] wasn't hot enough."
									return
							else if(!J13)
								return
							else if(J13.Tname=="Cool")
								M << "Heat the [J13] before quenching."
								return
							if(J14&&J14.Tname!="Cool")
								if(J14.Tname=="Hot")
									M<<"You submerge the [J14.Tname] [J14] into the tar."
									J14.needsquenched=0
									sleep(3)
									J14.Tname="Cool"
									M<<"You have quenched [J14]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J14.Tname=="Warm")
									M<<"You submerge the [J14.Tname] [J14] into the tar."
									J14.needsquenched=1
									sleep(3)
									J14.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J14] wasn't hot enough."
									return
							else if(!J14)
								return
							else if(J14.Tname=="Cool")
								M << "Heat the [J14] before quenching."
								return
							if(J15&&J15.Tname!="Cool")
								if(J15.Tname=="Hot")
									M<<"You submerge the [J15.Tname] [J15] into the tar."
									J15.needsquenched=0
									sleep(3)
									J15.Tname="Cool"
									M<<"You have quenched [J15]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J15.Tname=="Warm")
									M<<"You submerge the [J15.Tname] [J15] into the tar."
									J15.needsquenched=1
									sleep(3)
									J15.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J15] wasn't hot enough."
									return
							else if(!J15)
								return
							else if(J15.Tname=="Cool")
								M << "Heat the [J15] before quenching."
								return
							if(J16&&J16.Tname!="Cool")
								if(J16.Tname=="Hot")
									M<<"You submerge the [J16.Tname] [J16] into the tar."
									J16.needsquenched=0
									sleep(3)
									J16.Tname="Cool"
									M<<"You have quenched [J16]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J16.Tname=="Warm")
									M<<"You submerge the [J16.Tname] [J16] into the tar."
									J16.needsquenched=1
									sleep(3)
									J16.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J16] wasn't hot enough."
									return
							else if(!J16)
								return
							else if(J16.Tname=="Cool")
								M << "Heat the [J16] before quenching."
								return
							if(J17&&J17.Tname!="Cool")
								if(J17.Tname=="Hot")
									M<<"You submerge the [J17.Tname] [J17] into the tar."
									J17.needsquenched=0
									sleep(3)
									J17.Tname="Cool"
									M<<"You have quenched [J17]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J17.Tname=="Warm")
									M<<"You submerge the [J17.Tname] [J17] into the tar."
									J17.needsquenched=1
									sleep(3)
									J17.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J17] wasn't hot enough."
									return
							else if(!J17)
								return
							else if(J17.Tname=="Cool")
								M << "Heat the [J17] before quenching."
								return
							if(J18&&J18.Tname!="Cool")
								if(J18.Tname=="Hot")
									M<<"You submerge the [J18.Tname] [J18] into the tar."
									J18.needsquenched=0
									sleep(3)
									J18.Tname="Cool"
									M<<"You have quenched [J18]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J18.Tname=="Warm")
									M<<"You submerge the [J18.Tname] [J18] into the tar."
									J18.needsquenched=1
									sleep(3)
									J18.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J18] wasn't hot enough."
									return
							else if(!J18)
								return
							else if(J18.Tname=="Cool")
								M << "Heat the [J18] before quenching."
								return
							if(J19&&J19.Tname!="Cool")
								if(J19.Tname=="Hot")
									M<<"You submerge the [J19.Tname] [J19] into the tar."
									J19.needsquenched=0
									sleep(3)
									J19.Tname="Cool"
									M<<"You have quenched [J19]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J19.Tname=="Warm")
									M<<"You submerge the [J19.Tname] [J19] into the tar."
									J19.needsquenched=1
									sleep(3)
									J19.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J19] wasn't hot enough."
									return
							else if(!J19)
								return
							else if(J19.Tname=="Cool")
								M << "Heat the [J19] before quenching."
								return
							if(J20&&J20.Tname!="Cool")
								if(J20.Tname=="Hot")
									M<<"You submerge the [J20.Tname] [J20] into the tar."
									J20.needsquenched=0
									sleep(3)
									J20.Tname="Cool"
									M<<"You have quenched [J20]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J20.Tname=="Warm")
									M<<"You submerge the [J20.Tname] [J20] into the tar."
									J20.needsquenched=1
									sleep(3)
									J20.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J20] wasn't hot enough."
									return
							else if(!J20)
								return
							else if(J20.Tname=="Cool")
								M << "Heat the [J20] before quenching."
								return


//Tar Lamp part Quench Process
							if(J21&&J21.Tname!="Cool")
								if(J21.Tname=="Hot")
									M<<"You submerge the [J21.Tname] [J21] into the tar."
									J21.needsquenched=0
									sleep(3)
									J21.Tname="Cool"
									M<<"You have quenched [J21]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J21.Tname=="Warm")
									M<<"You submerge the [J21.Tname] [J21] into the tar."
									J21.needsquenched=1
									sleep(3)
									J21.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J21] wasn't hot enough."
									return
							else if(!J21)
								return
							else if(J21.Tname=="Cool")
								M << "Heat the [J21] before quenching."
								return
							if(J22&&J22.Tname!="Cool")
								if(J22.Tname=="Hot")
									M<<"You submerge the [J22.Tname] [J22] into the tar."
									J22.needsquenched=0
									sleep(3)
									J22.Tname="Cool"
									M<<"You have quenched [J22]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J22.Tname=="Warm")
									M<<"You submerge the [J22.Tname] [J22] into the tar."
									J22.needsquenched=1
									sleep(3)
									J22.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J22] wasn't hot enough."
									return
							else if(!J22)
								return
							else if(J22.Tname=="Cool")
								M << "Heat the [J22] before quenching."
								return
							if(J23&&J23.Tname!="Cool")
								if(J23.Tname=="Hot")
									M<<"You submerge the [J23.Tname] [J23] into the tar."
									J23.needsquenched=0
									sleep(3)
									J23.Tname="Cool"
									M<<"You have quenched [J23]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J23.Tname=="Warm")
									M<<"You submerge the [J23.Tname] [J23] into the tar."
									J23.needsquenched=1
									sleep(3)
									J23.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J23] wasn't hot enough."
									return
							else if(!J23)
								return
							else if(J23.Tname=="Cool")
								M << "Heat the [J23] before quenching."
								return
							if(J24&&J24.Tname!="Cool")
								if(J24.Tname=="Hot")
									M<<"You submerge the [J24.Tname] [J24] into the tar."
									J24.needsquenched=0
									sleep(3)
									J24.Tname="Cool"
									M<<"You have quenched [J24]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J24.Tname=="Warm")
									M<<"You submerge the [J24.Tname] [J24] into the tar."
									J24.needsquenched=1
									sleep(3)
									J24.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J24] wasn't hot enough."
									return
							else if(!J24)
								return
							else if(J24.Tname=="Cool")
								M << "Heat the [J24] before quenching."
								return
							if(J25&&J25.Tname!="Cool")
								if(J25.Tname=="Hot")
									M<<"You submerge the [J25.Tname] [J25] into the tar."
									J25.needsquenched=0
									sleep(3)
									J25.Tname="Cool"
									M<<"You have quenched [J25]! Test it for hardness with a File."
									//insert sfx and flick an animation
									return
								else if(J25.Tname=="Warm")
									M<<"You submerge the [J25.Tname] [J25] into the tar."
									J25.needsquenched=1
									sleep(3)
									J25.Tname="Cool"
									//insert sfx and flick an animation
									M<<"The quench failed, [J25] wasn't hot enough."
									return
							else if(!J25)
								return
							else if(J25.Tname=="Cool")
								M << "Heat the [J25] before quenching."
								return


//Oil Tool part Quench Process
						if(src:CType=="Oil")
							if(J&&J.Tname!="Cool")
								M<<"You submerge the [J.Tname] [J] into the oil."
								J.needsquenched=0
								sleep(3)
								J.Tname="Cool"
								//insert sfx and flick an animation
								M<<"You have quenched [J]! Test it for hardness with a File."
								return
							else if(!J)
								return
							else if(J.Tname=="Cool")
								M << "Heat the [J] before quenching."
								return
							if(J1&&J1.Tname!="Cool")
								M<<"You submerge the [J1.Tname] [J1] into the oil."
								J1.needsquenched=0
								sleep(3)
								J1.Tname="Cool"
								M<<"You have quenched [J1]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J1)
								return
							else if(J1.Tname=="Cool")
								M << "Heat the [J1] before quenching."
								return
							if(J2&&J2.Tname!="Cool")
								M<<"You submerge the [J2.Tname] [J2] into the oil."
								J2.needsquenched=0
								sleep(3)
								J2.Tname="Cool"
								M<<"You have quenched [J2]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J2)
								return
							else if(J2.Tname=="Cool")
								M << "Heat the [J2] before quenching."
								return
							if(J3&&J3.Tname!="Cool")
								M<<"You submerge the [J3.Tname] [J3] into the oil."
								J3.needsquenched=0
								sleep(3)
								J3.Tname="Cool"
								M<<"You have quenched [J3]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J3)
								return
							else if(J3.Tname=="Cool")
								M << "Heat the [J3] before quenching."
								return
							if(J4&&J4.Tname!="Cool")
								M<<"You submerge the [J4.Tname] [J4] into the oil."
								J4.needsquenched=0
								sleep(3)
								J4.Tname="Cool"
								M<<"You have quenched [J4]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J4)
								return
							else if(J4.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J5&&J5.Tname!="Cool")
								M<<"You submerge the [J5.Tname] [J5] into the oil."
								J5.needsquenched=0
								sleep(3)
								J5.Tname="Cool"
								M<<"You have quenched [J5]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J5)
								return
							else if(J5.Tname=="Cool")
								M << "Heat the [J5] before quenching."
								return
							if(J6&&J6.Tname!="Cool")
								M<<"You submerge the [J6.Tname] [J6] into the oil."
								J6.needsquenched=0
								sleep(3)
								J6.Tname="Cool"
								M<<"You have quenched [J6]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J6)
								return
							else if(J6.Tname=="Cool")
								M << "Heat the [J6] before quenching."
								return
							if(J7&&J7.Tname!="Cool")
								M<<"You submerge the [J7.Tname] [J7] into the oil."
								J7.needsquenched=0
								sleep(3)
								J7.Tname="Cool"
								M<<"You have quenched [J7]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J7)
								return
							else if(J7.Tname=="Cool")
								M << "Heat the [J7] before quenching."
								return
							if(J8&&J8.Tname!="Cool")
								M<<"You submerge the [J8.Tname] [J8] into the oil."
								J8.needsquenched=0
								sleep(3)
								J8.Tname="Cool"
								M<<"You have quenched [J8]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J8)
								return
							else if(J8.Tname=="Cool")
								M << "Heat the [J4] before quenching."
								return
							if(J9&&J9.Tname!="Cool")
								M<<"You submerge the [J9.Tname] [J9] into the oil."
								J9.needsquenched=0
								sleep(3)
								J9.Tname="Cool"
								M<<"You have quenched [J9]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J9)
								return
							else if(J9.Tname=="Cool")
								M << "Heat the [J9] before quenching."
								return
							if(J10&&J10.Tname!="Cool")
								M<<"You submerge the [J10.Tname] [J10] into the oil."
								J10.needsquenched=0
								sleep(3)
								J10.Tname="Cool"
								M<<"You have quenched [J10]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J10)
								return
							else if(J10.Tname=="Cool")
								M << "Heat the [J10] before quenching."
								return

//Oil Weapon part Quench Process
							if(J11&&J11.Tname!="Cool")
								M<<"You submerge the [J11.Tname] [J11] into the oil."
								J11.needsquenched=0
								sleep(3)
								J11.Tname="Cool"
								M<<"You have quenched [J11]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J11)
								return
							else if(J11.Tname=="Cool")
								M << "Heat the [J11] before quenching."
								return
							if(J12&&J12.Tname!="Cool")
								M<<"You submerge the [J12.Tname] [J12] into the oil."
								J12.needsquenched=0
								sleep(3)
								J12.Tname="Cool"
								M<<"You have quenched [J12]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J12)
								return
							else if(J12.Tname=="Cool")
								M << "Heat the [J12] before quenching."
								return
							if(J13&&J13.Tname!="Cool")
								M<<"You submerge the [J13.Tname] [J13] into the oil."
								J13.needsquenched=0
								sleep(3)
								J13.Tname="Cool"
								M<<"You have quenched [J13]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J13)
								return
							else if(J13.Tname=="Cool")
								M << "Heat the [J13] before quenching."
								return
							if(J14&&J14.Tname!="Cool")
								M<<"You submerge the [J14.Tname] [J14] into the oil."
								J14.needsquenched=0
								sleep(3)
								J14.Tname="Cool"
								M<<"You have quenched [J14]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J14)
								return
							else if(J14.Tname=="Cool")
								M << "Heat the [J14] before quenching."
								return
							if(J15&&J15.Tname!="Cool")
								M<<"You submerge the [J15.Tname] [J15] into the oil."
								J15.needsquenched=0
								sleep(3)
								J15.Tname="Cool"
								M<<"You have quenched [J15]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J15)
								return
							else if(J15.Tname=="Cool")
								M << "Heat the [J15] before quenching."
								return
							if(J16&&J16.Tname!="Cool")
								M<<"You submerge the [J16.Tname] [J16] into the oil."
								J16.needsquenched=0
								sleep(3)
								J16.Tname="Cool"
								M<<"You have quenched [J16]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J16)
								return
							else if(J16.Tname=="Cool")
								M << "Heat the [J16] before quenching."
								return
							if(J17&&J17.Tname!="Cool")
								M<<"You submerge the [J17.Tname] [J17] into the oil."
								J17.needsquenched=0
								sleep(3)
								J17.Tname="Cool"
								M<<"You have quenched [J17]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J17)
								return
							else if(J17.Tname=="Cool")
								M << "Heat the [J17] before quenching."
								return
							if(J18&&J18.Tname!="Cool")
								M<<"You submerge the [J18.Tname] [J18] into the oil."
								J18.needsquenched=0
								sleep(3)
								J18.Tname="Cool"
								M<<"You have quenched [J18]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J18)
								return
							else if(J18.Tname=="Cool")
								M << "Heat the [J18] before quenching."
								return
							if(J19&&J19.Tname!="Cool")
								M<<"You submerge the [J19.Tname] [J19] into the oil."
								J19.needsquenched=0
								sleep(3)
								J19.Tname="Cool"
								M<<"You have quenched [J19]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J19)
								return
							else if(J19.Tname=="Cool")
								M << "Heat the [J19] before quenching."
								return
							if(J20&&J20.Tname!="Cool")
								M<<"You submerge the [J20.Tname] [J20] into the oil."
								J20.needsquenched=0
								sleep(3)
								J20.Tname="Cool"
								M<<"You have quenched [J20]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J20)
								return
							else if(J20.Tname=="Cool")
								M << "Heat the [J20] before quenching."
								return


//Oil Lamp part Quench Process
							if(J21&&J21.Tname!="Cool")
								M<<"You submerge the [J21.Tname] [J21] into the oil."
								J21.needsquenched=0
								sleep(3)
								J21.Tname="Cool"
								M<<"You have quenched [J21]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J21)
								return
							else if(J21.Tname=="Cool")
								M << "Heat the [J21] before quenching."
								return
							if(J22&&J22.Tname!="Cool")
								M<<"You submerge the [J22.Tname] [J22] into the oil."
								J22.needsquenched=0
								sleep(3)
								J22.Tname="Cool"
								M<<"You have quenched [J22]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J22)
								return
							else if(J22.Tname=="Cool")
								M << "Heat the [J22] before quenching."
								return
							if(J23&&J23.Tname!="Cool")
								M<<"You submerge the [J23.Tname] [J23] into the oil."
								J23.needsquenched=0
								sleep(3)
								J23.Tname="Cool"
								M<<"You have quenched [J23]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J23)
								return
							else if(J23.Tname=="Cool")
								M << "Heat the [J23] before quenching."
								return
							if(J24&&J24.Tname!="Cool")
								M<<"You submerge the [J24.Tname] [J24] into the oil."
								J24.needsquenched=0
								sleep(3)
								J24.Tname="Cool"
								M<<"You have quenched [J24]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J24)
								return
							else if(J24.Tname=="Cool")
								M << "Heat the [J24] before quenching."
								return
							if(J25&&J25.Tname!="Cool")
								M<<"You submerge the [J25.Tname] [J25] into the oil."
								J25.needsquenched=0
								sleep(3)
								J25.Tname="Cool"
								M<<"You have quenched [J25]! Test it for hardness with a File."
								//insert sfx and flick an animation
								return
							else if(!J25)
								return
							else if(J25.Tname=="Cool")
								M << "Heat the [J25] before quenching."
								return
						//else if(QB:CType=="Empty")
						//	M << "Need to fill the Quench Box to Quench!"
							//return

					verb/Push()//works -- the only issue is it will move multiple barrels
						set src in view()
						//var/turf/t = get_step(src,dir)
						M << "You push the barrel."
						locate(usr in oview(src))
						src.pushing=1
						//FindB(M)
						if(src in range(1, usr))
							for(src)
								if(usr.dir==EAST)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x+1,src.y,src.z)
								else if(usr.dir==WEST)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x-1,src.y,src.z)
								if(usr.dir==NORTH)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x,src.y+1,src.z)
								else if(usr.dir==SOUTH)
									for(src in view(1,usr.loc))
										src.loc=locate(src.x,src.y-1,src.z)
								//locate(src)
								return
					proc/FindJar(mob/players/M)
						for(var/obj/items/tools/Containers/Jar/J in M.contents)
							if(J.suffix=="Equipped")
								return J
					proc/FindVes(mob/players/M)
						for(var/obj/items/tools/Containers/Vessel/J2 in M.contents)
							if(J2.name=="Filled Vessel"||J2.name=="Half Filled Vessel")
								return J2
					verb/Fill_Quench_Box()
						var/mob/players/M = usr
						set waitfor = 0
						set src in view()
						set popup_menu = 1
						var/obj/items/tools/Containers/Jar/J = FindJar(M)
						var/obj/items/tools/Containers/Vessel/J2 = FindVes(M)

//Fill Quench Box
						//if(!J||!J2)
							//M << "Need a Jar or Vessel to fill the Quench Box with."
						if(CType=="Empty")
							goto Process
						else if(J.CType=="Water"&&src.CType=="Tar"||J.CType=="Water"&&src.CType=="Oil"||J2.CType=="Water"&&src.CType=="Tar"||J2.CType=="Water"&&src.CType=="Oil")
							//M<<"You don't need to mix contents."
							return
						else if(J.CType=="Tar"&&src.CType=="Water"||J.CType=="Tar"&&src.CType=="Oil"||J2.CType=="Tar"&&src.CType=="Water"||J2.CType=="Tar"&&src.CType=="Oil")
							//M<<"You don't need to mix contents."
							return
						else if(J.CType=="Oil"&&src.CType=="Tar"||J.CType=="Oil"&&src.CType=="Water"||J2.CType=="Oil"&&src.CType=="Tar"||J2.CType=="Oil"&&src.CType=="Water")
							//M<<"You don't need to mix contents."
							return
						else if(name=="Filled Quench Box")
							M<<"You already filled the Quench Box."
							return
						Process
						if(M.JRequipped==1)
			//Water Jar
							if(J.CType=="Water")
								if(M.JRequipped==1&&J.volume==J.volumecap&&src.name=="Quench Box"&&src.CType=="Empty")
									M<<"You begin filling the Quench Box with the contents of the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Half Filled Quench Box"
									src.volume=25
									J.volume=0
									J.name = "Jar"
									J.CType="Empty"
									src.CType="Water"
									//overlays += /obj/qbliquid
									sleep(1)
									M<<"You Filled the Quench Box with Water."
									return

								else if(M.JRequipped==1&&J.volume==J.volumecap&&src.name=="Half Filled Quench Box"&&src.CType=="Water")
									M<<"You begin filling the Quench Box with the contents of the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Filled Quench Box"
									J.name = "Jar"
									src.volume=50
									if(src.volume>=src.volumecap)
										src.volume=src.volumecap
									J.volume=0
									J.CType="Empty"
									src.CType="Water"
									icon_state = "QuenchBoxw"
									sleep(1)
									M<<"You Filled the Quench Box full with Water."
									return
			//Tar Jar
							if(J.CType=="Tar")
								if(M.JRequipped==1&&J.volume==J.volumecap&&src.name=="Quench Box"&&src.CType=="Empty")
									M<<"You begin filling the Quench Box with the contents of the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.name = "Jar"
									J.filled=0
									src.name="Half Filled Quench Box"
									src.volume=25
									J.volume=0
									J.CType="Empty"
									src.CType="Tar"
									//overlays += /obj/qbliquid
									sleep(1)
									M<<"You Filled the Quench Box with Tar."
									return

								else if(M.JRequipped==1&&J.volume==J.volumecap&&src.name=="Half Filled Quench Box"&&src.CType=="Tar")
									M<<"You begin filling the Quench Box with the contents of the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.name = "Jar"
									J.filled=0
									src.name="Filled Quench Box"
									src.volume=50
									if(src.volume>=src.volumecap)
										src.volume=src.volumecap
									J.volume=0
									J.CType="Empty"
									src.CType="Tar"
									icon_state = "QuenchBoxt"
									sleep(1)
									M<<"You Filled the Quench Box full with Tar."
									return

			//Oil Jar
							if(J.CType=="Oil")
								if(M.JRequipped==1&&J.volume==J.volumecap&&src.name=="Quench Box"&&src.CType=="Empty")
									M<<"You begin filling the Quench Box with the contents of the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.name = "Jar"
									J.filled=0
									src.name="Half Filled Quench Box"
									src.volume=25
									J.volume=0
									J.CType="Empty"
									src.CType="Oil"
									//overlays += /obj/qbliquid
									sleep(1)
									M<<"You Filled the Quench Box with Oil."
									return

								else if(M.JRequipped==1&&J.volume==J.volumecap&&src.name=="Half Filled Quench Box"&&src.CType=="Oil")
									M<<"You begin filling the Quench Box with the contents of the Jar."
									sleep(2)
									J.icon_state = "Jar"
									J.filled=0
									src.name="Filled Quench Box"
									J.name = "Jar"
									src.volume=50
									if(src.volume>=src.volumecap)
										src.volume=src.volumecap
									J.volume=0
									J.CType="Empty"
									src.CType="Oil"
									icon_state = "QuenchBoxo"
									sleep(1)
									M<<"You Filled the Quench Box full with Oil."
									return

						else
							goto V

//Fill Quench Box with Vessel of Water
						V
			//Water Vessel
						if(J2.CType=="Water")//throwing errors for some reason
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quench Box"&&src.CType=="Empty")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								src.CType="Water"
								icon_state = "QuenchBoxw"
								sleep(1)
								M<<"You Filled the Quench Box full with Water."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Quench Box"&&src.CType=="Water")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselwhf"
								J2.name="Half Filled Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.volume=25
								src.CType="Water"
								icon_state = "QuenchBoxw"
								sleep(1)
								M<<"You Filled the Quench Box full with Water."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Quench Box"&&src.CType=="Water")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.CType="Empty"
								src.CType="Water"
								J2.volume=0
								icon_state = "QuenchBoxw"
								sleep(1)
								M<<"You Filled the Quench Box full with Water."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Half Filled Vessel"&&src.name=="Quench Box")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Quench Box"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								src.CType="Water"
								//overlays += /obj/qbliquid
								sleep(1)
								M<<"You Filled the Quench Box with Water."
								return
			//Tar Vessel
						if(J2.CType=="Tar")
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quench Box"&&src.CType=="Empty")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								src.CType="Tar"
								icon_state = "QuenchBoxt"
								sleep(1)
								M<<"You Filled the Quench Box full with Tar."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Quench Box"&&src.CType=="Tar")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselthf"
								J2.name="Half Filled Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.volume=25
								src.CType="Tar"
								icon_state = "QuenchBoxt"
								sleep(1)
								M<<"You Filled the Quench Box full with Tar."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Quench Box"&&src.CType=="Tar")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.CType="Empty"
								J2.volume=0
								src.CType="Tar"
								icon_state = "QuenchBoxt"
								sleep(1)
								M<<"You Filled the Quench Box full with Tar."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Half Filled Vessel"&&src.name=="Quench Box")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Quench Box"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								src.CType="Tar"
								//overlays += /obj/qbliquid
								sleep(1)
								M<<"You Filled the Quench Box with Tar."
								return

			//Oil Vessel
						if(J2.CType=="Oil")
							if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Quench Box"&&src.CType=="Empty")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.volume=0
								J2.CType="Empty"
								src.CType="Oil"
								icon_state = "QuenchBoxo"
								sleep(1)
								M<<"You Filled the Quench Box full with Water."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Filled Vessel"&&src.name=="Half Filled Quench Box"&&src.CType=="Oil")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vesselohf"
								J2.name="Half Filled Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.volume=25
								icon_state = "QuenchBoxo"
								sleep(1)
								M<<"You Filled the Quench Box full with Oil."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Half Filled Vessel"&&src.name=="Half Filled Quench Box"&&src.CType=="Oil")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Filled Quench Box"
								src.volume=50
								J2.CType="Empty"
								J2.volume=0
								icon_state = "QuenchBoxo"
								sleep(1)
								M<<"You Filled the Quench Box full with Oil."
								return
							else if(J2.volume==J2.volumecap&&J2.name=="Half Filled Vessel"&&src.name=="Quench Box")
								M<<"You begin filling the Quench Box with the Vessel."
								sleep(2)
								J2.icon_state = "Vessel"
								J2.name="Vessel"
								src.name="Half Filled Quench Box"
								src.volume=25
								J2.volume=0
								J2.CType="Empty"
								src.CType="Oil"
								//overlays += /obj/qbliquid
								sleep(1)
								M<<"You Filled the Quench Box with Oil."
								return


					verb/Empty()//need to make it so the barrel can be filled by jar/bucket in 1/10 increments to a volume %
						set category=null
						set src in view()
						set popup_menu=1
						var/mob/players/M = usr
						//var/obj/items/tools/Containers/QuenchBox/J = locate() in M.contents
						if(name=="Filled Quench Box"||name=="Half Filled Quench Box")
							//set category = "Commands"
							icon_state = "QuenchBox"
							name="Quench Box"
							volume = 0
							CType="Empty"
							M<<"You empty the Quench Box on to the ground."
							return

						else
							M<<"The Quench Box is already empty."
							return
					New()
						..()
						Description()
						//Description()//description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Volume %[volume]-%[volumecap]<br>Contents [CType]<br>[strreq] Strength-Req<br>[twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"


					//M.contents+=new Jar
			/*FilledJar //name of object
				icon_state = "Jar" //icon state of object
				typi = "tool"
				strreq = 1
				name = "Jar"
				description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				var/liquid = 10
				New()
				proc/Fill()*/
		proc/HitPlayer(mob/players/M) // hitting the player
			var/dmgreduced // you reduce your damage based on defense
			var/Strength
			if(M.tempdefense<=1050)
				dmgreduced = (((M.tempdefense)/10 * (1.05-(0.0005*(M.tempdefense))))/100) // calculation for dmg reduced
			else if(M.tempdefense>1050)
				var/resroll = M.tempdefense-1050
				dmgreduced = 0.55 + 0.55*(((resroll)/10 * (1.05-(0.0005*(resroll))))/100) // another calculation for dmg reduced because the first one is negative parabolic, and we dont want the dmg reduced to be decreased with high defense ratings
			var/damage = round(((rand(Strength/2,Strength))*(1-dmgreduced)),1) // calculate damage
			M.HP -= damage // take damage
			M.affinity -= 0.1
			s_damage(M, damage, "red") // show the damage taken
			checkdeadplayerPVP(M,src) // see if the enemy killed the player
		proc/checkdeadplayerPVP(var/mob/players/M,var/mob/players/E=usr)
			if(M.HP <= 0&&M.affinity<=-0.1) // if you have less than or equal to 0 HP, you are dead
				world << "<font color = red><b>[M] died to [E] and went to Sheol"
				var/G = round((M.lucre/4),1)
				M << "<font color = lucre>Your pouch slipped and spilled [G] Lucre!"
				M.lucre-=G
				M.poisonD=0
				M.poisoned=0
				M.poisonDMG=0
				M.overlays = null
				M.loc = locate(16,9,12)//locate(rand(100,157),rand(113,46),12)
				M.location = "Sheol"
				//usr << sound('mus.ogg',1, 0, 1024)
				M.HP = M.MAXHP
			else if(M.HP <= 0&&M.affinity>=0)
				world << "<font color = red><b>[M] died to [E] and went to the Holy Light"
				var/G = round((M.lucre/4),1)
				M << "<font color = lucre>Your pouch slipped and spilled [G] Lucre!"
				M.lucre-=G
				M.poisonD=0
				M.poisoned=0
				M.poisonDMG=0
				M.overlays = null
				M.loc = locate(101,159,12)//locate(rand(100,157),rand(113,46),12)
				M.location = "Holy Light"
				//usr << sound('mus.ogg',1, 0, 1024)
				M.HP = M.MAXHP

/*var/const
	POLE_LAYER = FLOAT_LAYER+1

obj/overlay
	FPN
		icon = 'dmi/64/creation.dmi'
		icon_state = "1"
		plane = POLE_LAYER
	FPS
		icon = 'dmi/64/creation.dmi'
		icon_state = "2"
		plane = POLE_LAYER
	FPE
		icon = 'dmi/64/creation.dmi'
		icon_state = "4"
		plane = POLE_LAYER
	FPW
		icon = 'dmi/64/creation.dmi'
		icon_state = "8"
		plane = POLE_LAYER*/

obj
	/*Rocks
		name = "Rock"
		density = 1
		plane = MOB_LAYER+1
		icon = 'dmi/64/creation.dmi'
		icon_state = "rock"
		var/mob/players/M
		verb //...
			Mine() //...
				//set category = "Commands"
				set src in oview(1) //...
				Mining(M) //calls the mining proc
	*/
	Buildable
		Smithing
			Forge//working
				name = "Empty Forge"
				density = 1
				plane = MOB_LAYER+1
				icon = 'dmi/64/creation.dmi'
				icon_state = "forge"
				var/spawntime = "5000"
				var/soundmob/s
				var/mob/players/M
				light = /light/directional
				New()
					..()
				Click()
					if(usr in orange(5,src))
						for(usr in orange(5,src))
							winset(usr,"default.Smelt","is-visible=true")
					else if(!usr in orange(5,src))
						winset(usr,"default.Smelt","is-visible=false")
						return
					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//new /light/circle(src, 2)
					//new /light/directional(src, 7)
					//light.on = 0
				proc/FindI()
					for(var/obj/items/Ingots/J)// Ingot
						locate(J)
						if(J:Tname=="Cool")
							return J
				proc/FindS()
					for(var/obj/items/Ingots/Scraps/J)// Scraps
						locate(J)
						if(J:Tname=="Cool")
							return J
				verb //...
					Smelt()//works
						set category=null
						set popup_menu = 1
						var/mob/players/M
						//set hidden = 1
						set src in oview(1) //...
						M = usr
						if(M.SMEopen==1)
							return
						else
							//M << "You begin to smelt ore..."
							Smelting(M) //calls the mining proc
					Heat()//works
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						//set category = "Commands"
						var/mob/players/M
						M = usr
						var/list/CC1 = list()
						var/obj/items/Ingots/I = FindI(M)

						if(I in M)
						//for(C in M)
							//if(I.Tname=="Hot")
								//M << "This ingot is already Hot!"
								//return
							if(I.Tname!="Hot")
								CC1.Add("Ingots")
						else
							CC1.Remove("Ingots")
						var/obj/items/Crafting/Created/C = locate() in M

						if(C in M)
							//if(C.Tname=="Hot")
								//M << "This part is already Hot!"
								//return
						//for(C in M)
							if(C.Tname!="Hot")
								CC1.Add("Tool Parts")
						else
							CC1.Remove("Tool Parts")

						var/obj/items/Ingots/Scraps/S = FindS(M)

						if(S in M)
							//if(S.Tname=="Hot")
								//M << "This scrap is already Hot!"
								//return
						//for(C in M)
							if(S.Tname!="Hot")
								CC1.Add("Scraps")
						else
							CC1.Remove("Scraps")
						if(!C&&!I&&!S)
							M << "Need items to heat"
							return
						if(CC1.len >= 1)
							CC1.Add("Back")
						else
							CC1.Remove("Back")
						Start
						switch(input("What would you like to heat?","Heat") in CC1)//list("Tool Parts","Ingots","Scraps"))
							if("Back")
								goto Start
							if("Tool Parts")
								var/list/options = list()
								var/obj/items/Crafting/Created/CC
								for(CC in M)
								      // show a pretty list of options with prices included
									options["[CC]"] = CC
								var/choice = input("Which item would you like to heat?","Ingots") as null|anything in options
								CC = options[choice]
								//switch(input("Which item would you like to heat?","Tool Parts") in CC)
								if(CC)
									if((CC in M.contents)&&(src.name=="Lit Forge"))
										//var/obj/items/Kindling/J = locate() in M.contents
										if(CC.Tname!="Hot")
											M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[CC.icon] ICONSTATE='[CC.icon_state]'> [CC]."
											sleep(30)
											//J.RemoveFromStack(1)
											//src.overlays -= overlays
											//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
											//light.off()
											CC:Tname="Hot"
											M<<"\  <IMG CLASS=icon SRC=\ref[CC.icon] ICONSTATE='[CC.icon_state]'> [CC] is hot."
										//else
											//M<<"[J] is already Hot"
											//call(proc/Temp)(J)
											return

							if("Ingots")
								var/list/options = list()
								var/obj/items/Ingots/CC
								for(CC in M)
								      // show a pretty list of options with prices included
									options["[CC]"] = CC
								var/choice = input("Which item would you like to heat?","Tool Parts") as null|anything in options
								CC = options[choice]
								//switch(input("Which item would you like to heat?","Tool Parts") in CC)
								if(CC)
									if((CC in M.contents)&&(src.name=="Lit Forge"))
										//var/obj/items/Kindling/J = locate() in M.contents
										if(CC.Tname!="Hot")
											M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[CC.icon] ICONSTATE='[CC.icon_state]'> [CC.ingot_type]."
											sleep(30)
											//J.RemoveFromStack(1)
											//src.overlays -= overlays
											//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
											//light.off()
											CC:Tname="Hot"
											CC:name="[CC.ingot_type] Ingot (Hot)"
											//CC:name="[CC.ingot_type] Ingot (Hot)"
											//call(/obj/items/Ingots/proc/Temp)(locate(CC))
											//CC:suffix="Hot"
											M<<"\  <IMG CLASS=icon SRC=\ref[CC.icon] ICONSTATE='[CC.icon_state]'> [CC.ingot_type] is hot."
										//else
											//M<<"[J] is already Hot"
											//call(proc/Temp)(J)
											return
							if("Scraps")
								var/list/options = list()
								var/obj/items/Ingots/Scraps/CC
								for(CC in M)
								      // show a pretty list of options with prices included
									options["[CC]"] = CC
								var/choice = input("Which item would you like to heat?","Metal Scraps") as null|anything in options
								CC = options[choice]
								//switch(input("Which item would you like to heat?","Tool Parts") in CC)
								if(CC)
									if((CC in M.contents)&&(src.name=="Lit Forge"))
										//var/obj/items/Kindling/J = locate() in M.contents
										if(CC.Tname!="Hot")
											M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[CC.icon] ICONSTATE='[CC.icon_state]'> [CC.ingot_type]."
											sleep(30)
											//J.RemoveFromStack(1)
											//src.overlays -= overlays
											//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
											//light.off()
											CC:Tname="Hot"
											CC:name="[CC.ingot_type] Ingot (Hot)"
											M<<"\  <IMG CLASS=icon SRC=\ref[CC.icon] ICONSTATE='[CC.icon_state]'> [CC.ingot_type] is hot."
										//else
											//M<<"[J] is already Hot"
											//call(proc/Temp)(J)
											return

					Snuff_Forge()
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						//set category = "Commands"
						var/mob/players/M
						M = usr
						if(src in oview(1))
							//var/obj/items/Kindling/J = locate() in M.contents
							if(src.name=="Lit Forge")
								M<<"You snuff the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge."
								sleep(5)
								//J.RemoveFromStack(1)
								//src.overlays -= overlays
								//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
								src.icon_state="forgeD"
								src:light.off()
								M.unlistenSoundmob(s)
								src:name="Unlit Forge"
								return
					Prepare_Forge()//works
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						//set category = "Commands"
						var/mob/players/M
						M = usr
						if(src in oview(1))
							var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
							if((J in M.contents)&&(src.name=="Empty Forge")&&(J.stack_amount>=1))
								M<<"You add the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] into the empty \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge."
								sleep(5)
								J.RemoveFromStack(1)
								src.icon_state="forgeF"//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
								src:name="Unlit Forge"
								return
							else
								M<<"Need at least one \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>kindling to add to an empty <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>forge."
								return
					Light_Forge()//works, sound and light need adjustment
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						//set category = "Commands"
						//src.s = new/soundmob(src, 20, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						var/mob/players/M
						M = locate(usr) in oview(src,10)
					//	if(src.name=="Lit Forge")
						//	M<<"Forge already Lit."
					//		return 0
						//if(src.name=="Empty Forge")
						//	M<<"Add kindling to light the Forge."
						//	return 0
						//if((M.CKequipped!=1) && (M.FLequipped!=1))
						//	return 0
						if(M.Doing==0)
							if((M.CKequipped==1) && (M.FLequipped==1) && (src.name=="Unlit Forge")||(M.PYequipped==1) && (M.FLequipped==1) && (src.name=="Unlit Forge"))
								//var/obj/items/tools/Flint/J = locate() in M.contents
								M<<"You start to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='forgeF'>Forge."
								M.Doing=1
								sleep(5)
								//J.RemoveFromStack(1)

								M<<"You light the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='forgeL'>Forge."

								//if(src.name=="Dead Forge") M.unlistenSoundmob(s)
								if((M.CKequipped==1) && (M.FLequipped==1) ||(M.PYequipped==1) && (M.FLequipped==1))
									light = new/light/directional(src,3)
									src:name="Lit Forge"
									src.s = new/soundmob(src, 20, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
									src.light.on()
									M.listenSoundmob(src.s)
									//if(src.dir=="South")//TestStamp -- Need to test if this works
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeF")//These overlays need to be changed
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")//WorkStamp -- These overlays only work for one direction - South
									src.icon_state="forgeL"
									//sleep(spawntime)
									M.Doing=0
									sleep(5000)
									//flick('fire.dmi',src)
									src.icon_state="forgeD"
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeF")
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
									M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='forgeD'>Forge is dying"
									//if(src.dir=="South")
									src.light.off()
									//light.off(src)
									//light.off()
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeD")
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
									src.icon_state="forgeO"
									//src:name="Unfueled Fire"
									//src.light.off()
									M<<"The \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge dies"
									//if(src.dir=="South")
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
									//src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
									//src:name="Dead Forge"
									//if(src.name=="Dead Forge")
									//src.light.off()
									M.unlistenSoundmob(src.s)
									src:name="Empty Forge"

									//del light
									return
								//new /light/circle(src, 9)

							else
								usr << "Need to use the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife with the <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='flint'>Flint on an Unlit <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge to Light it!"
								return
						else
							usr << "Already lighting the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge..."
							return

			Anvil
				name = "Anvil"
				density = 1
				plane = 5
				icon = 'dmi/64/creation.dmi'
				icon_state = "anvil"
				var/mob/players/M
				New()
					..()

				Click()
					if(usr in orange(5,src))
						for(usr in orange(5,src))
							winset(usr,"default.Smith","is-visible=true")
					else if(!usr in orange(5,src))
						winset(usr,"default.Smith","is-visible=false")
						return
				verb
					Smith() //works
						set category=null
						set popup_menu = 1
						//set hidden = 1
						set src in oview(1) //...
						M = usr
						call(/proc/smithingunlock)()
						call(/proc/smithinglevel)()
						//if(M.SMIopen==1)
							//M << "Smithing menu is currently open"
							//return
						//else
							//M << "Select what to smith"
						//var/soundmob/s = new/soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						Smithing(M) //calls the mining proc				M.PickAxe=0 ---- uncomment lines after getting anvil hammer sfx
						//M.listenSoundmob(s)
						//if(M.Doing==0)
							//M.unlistenSoundmob(s)
