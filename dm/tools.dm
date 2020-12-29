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
			verb
				Description()
					set category=null
					set popup_menu=1
					set src in usr
					usr << "\  <center><IMG CLASS=bigicon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>[src.description]"//cool little line that links item images with text to provide a better understanding of what to use and what it looks like
					return
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
				if(src.suffix=="Equipped")
					Unequip()
				else
					Equip()
			verb/Equip()
				set category=null
				set popup_menu=1
				//set hidden = 1
				set src in usr
				if(usr.TWequipped==2 && usr.Wequipped==2 && usr.Sequipped==2 && usr.LSequipped==2 && usr.AXequipped==2 && usr.WHequipped==2 && usr.JRequipped==2 && usr.FPequipped==2 && usr.PXequipped==2 && usr.SHequipped==2 && usr.HMequipped==2 && usr.SKequipped==2 && usr.HOequipped==2 && usr.CKequipped==2 && usr.GVequipped==2 && usr.FLequipped==2 && usr.PYequipped==2 && usr.OKequipped==2 && usr.SHMequipped==2 && usr.UPKequipped==2)
					src.suffix="Cannot Use"
					usr << "<font color = teal>Something is already equipped!"
				if(src.suffix=="Equipped")
					usr << "<font color = teal>That's already equipped!"
				else
					if ((typi=="LS")&&(twohanded==1))
						if (usr.tempstr>=src.strreq)
							if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
								usr.tempdamagemin += src.DamageMin
								usr.tempdamagemax += src.DamageMax
								var/mob/players/M = usr
								M.attackspeed -= src.wpnspd
							else
								usr << "<font color = teal>You have something equipped!"
						else
							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
					else
						if ((typi=="AX")&&(twohanded==1))
							if (usr.tempstr>=src.strreq)
								if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
									usr.tempdamagemin += src.DamageMin
									usr.tempdamagemax += src.DamageMax
									var/mob/players/M = usr
									M.attackspeed -= src.wpnspd
								else
									usr << "<font color = teal>You have something equipped!"
							else
								usr << "<font color = teal>You do not meet or exceed the strength requirements!"
						else
							if ((typi=="HM")&&(twohanded==0))
								if (usr.tempstr>=src.strreq)
									if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
										src.suffix="Equipped"
										usr.HMequipped = 1
										usr.tempdamagemin += src.DamageMin
										usr.tempdamagemax += src.DamageMax
										var/mob/players/M = usr
										M.attackspeed -= src.wpnspd
									else
										usr << "<font color = teal>You have something equipped!"
								else
									usr << "<font color = teal>You do not meet or exceed the strength requirements!"
							else
								if ((typi=="WH")&&(twohanded==1))
									if (usr.tempstr>=src.strreq)
										if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
											usr.tempdamagemin += src.DamageMin
											usr.tempdamagemax += src.DamageMax
											var/mob/players/M = usr
											M.attackspeed -= src.wpnspd
										else
											usr << "<font color = teal>You have something equipped!"
									else
										usr << "<font color = teal>You do not meet or exceed the strength requirements!"
								else
									if ((typi=="JR")&&(twohanded==1))
										if (usr.tempstr>=src.strreq)
											if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
												usr.tempdamagemin += src.DamageMin
												usr.tempdamagemax += src.DamageMax
												var/mob/players/M = usr
												M.attackspeed -= src.wpnspd
											else
												usr << "<font color = teal>You have something equipped!"
										else
											usr << "<font color = teal>You do not meet or exceed the strength requirements!"
									else
										if ((typi=="SH")&&(twohanded==1))
											if (usr.tempstr>=src.strreq)
												if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
													usr.tempdamagemin += src.DamageMin
													usr.tempdamagemax += src.DamageMax
													var/mob/players/M = usr
													M.attackspeed -= src.wpnspd
												else
													usr << "<font color = teal>You have something equipped!"
											else
												usr << "<font color = teal>You do not meet or exceed the strength requirements!"
										else
											if ((typi=="FP")&&(twohanded==1))
												if (usr.tempstr>=src.strreq)
													if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
														usr.tempdamagemin += src.DamageMin
														usr.tempdamagemax += src.DamageMax
														var/mob/players/M = usr
														M.attackspeed -= src.wpnspd
													else
														usr << "<font color = teal>You have something equipped!"
												else
													usr << "<font color = teal>You do not meet or exceed the strength requirements!"
											else
												if ((typi=="CK")&&(twohanded==0))
													if (usr.tempstr>=src.strreq)
														if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
															src.suffix="Equipped"
															usr.CKequipped = 1
															usr.tempdamagemin += src.DamageMin
															usr.tempdamagemax += src.DamageMax
															var/mob/players/M = usr
															M.attackspeed -= src.wpnspd
														else
															usr << "<font color = teal>You have something equipped!"
													else
														usr << "<font color = teal>You do not meet or exceed the strength requirements!"
												else
													if ((typi=="PX")&&(twohanded==1))
														if (usr.tempstr>=src.strreq)
															if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																usr.tempdamagemin += src.DamageMin
																usr.tempdamagemax += src.DamageMax
																var/mob/players/M = usr
																M.attackspeed -= src.wpnspd
															else
																usr << "<font color = teal>You have something equipped!"
														else
															usr << "<font color = teal>You do not meet or exceed the strength requirements!"
													else
														if ((typi=="GV")&&(twohanded==1))
															if (usr.tempstr>=src.strreq)
																if(/*usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0 && */usr.GVequipped==0/* && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0*/)//testing uncommenting so you can use gloves with everything
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
																else
																	usr << "<font color = teal>You must already be wearing gloves!"
															else
																usr << "<font color = teal>You do not meet or exceed the strength requirements!"
														else
															if ((typi=="HO")&&(twohanded==1))
																if (usr.tempstr>=src.strreq)
																	if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																		usr.tempdamagemin += src.DamageMin
																		usr.tempdamagemax += src.DamageMax
																		var/mob/players/M = usr
																		M.attackspeed -= src.wpnspd
																	else
																		usr << "<font color = teal>You have something equipped!"
																else
																	usr << "<font color = teal>You do not meet or exceed the strength requirements!"
															else
																if ((typi=="SK")&&(twohanded==0))
																	if (usr.tempstr>=src.strreq)
																		if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																			src.suffix="Equipped"
																			usr.SKequipped = 1
																			usr.tempdamagemin += src.DamageMin
																			usr.tempdamagemax += src.DamageMax
																			var/mob/players/M = usr
																			M.attackspeed -= src.wpnspd
																		else
																			usr << "<font color = teal>You have something equipped!"
																	else
																		usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																else
																	if ((typi=="FL")&&(twohanded==0))
																		if (usr.tempstr>=src.strreq)
																			if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																				src.suffix="Equipped"
																				usr.FLequipped = 1
																				usr.tempdamagemin += src.DamageMin
																				usr.tempdamagemax += src.DamageMax
																				var/mob/players/M = usr
																				M.attackspeed -= src.wpnspd
																			else
																				usr << "<font color = teal>You have something equipped!"
																		else
																			usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																	else
																		if ((typi=="PY")&&(twohanded==0))
																			if (usr.tempstr>=src.strreq)
																				if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																					src.suffix="Equipped"
																					usr.PYequipped = 1
																					usr.tempdamagemin += src.DamageMin
																					usr.tempdamagemax += src.DamageMax
																					var/mob/players/M = usr
																					M.attackspeed -= src.wpnspd
																				else
																					usr << "<font color = teal>You have something equipped!"
																			else
																				usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																		else
																			if ((typi=="OK")&&(twohanded==0))
																				if (usr.tempstr>=src.strreq)
																					if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																						src.suffix="Equipped"
																						usr.OKequipped = 1
																						usr.tempdamagemin += src.DamageMin
																						usr.tempdamagemax += src.DamageMax
																						var/mob/players/M = usr
																						M.attackspeed -= src.wpnspd
																					else
																						usr << "<font color = teal>You have something equipped!"
																				else
																					usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																			else
																				if ((typi=="SHM")&&(twohanded==0))
																					if (usr.tempstr>=src.strreq)
																						if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
																							src.suffix="Equipped"
																							usr.SHMequipped = 1
																							usr.tempdamagemin += src.DamageMin
																							usr.tempdamagemax += src.DamageMax
																							var/mob/players/M = usr
																							M.attackspeed -= src.wpnspd
																						else
																							usr << "<font color = teal>You have something equipped!"
																					else
																						usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																				else
																					if ((typi=="UPK")&&(twohanded==1))
																						if (usr.tempstr>=src.strreq)
																							if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																								usr.tempdamagemin += src.DamageMin
																								usr.tempdamagemax += src.DamageMax
																								var/mob/players/M = usr
																								M.attackspeed -= src.wpnspd
																							else
																								usr << "<font color = teal>You have something equipped!"
																						else
																							usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																					else
																						if ((typi=="TW")&&(twohanded==0))
																							if (usr.tempstr>=src.strreq)
																								if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																									//usr.HMequipped = 2
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
																									usr.tempdamagemin += src.DamageMin
																									usr.tempdamagemax += src.DamageMax
																									var/mob/players/M = usr
																									M.attackspeed -= src.wpnspd
																								else
																									usr << "<font color = teal>You have something equipped!"
																							else
																								usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																						else
																							if ((typi=="weapon")&&(twohanded==0))
																								if (usr.tempstr>=src.strreq)
																									if(usr.TWequipped==0 && usr.Wequipped==0 /*&& usr.Sequipped==0*/ && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																										usr.TWequipped = 1
																										usr.tempdamagemin += src.DamageMin
																										usr.tempdamagemax += src.DamageMax
																										var/mob/players/M = usr
																										M.attackspeed -= src.wpnspd
																									else
																										usr << "<font color = teal>You have something equipped!"
																								else
																									usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																							else
																								if ((typi=="weapon")&&(twohanded==1))
																									if (usr.tempstr>=src.strreq)
																										if(usr.TWequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.HMequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																											usr.tempdamagemin += src.DamageMin
																											usr.tempdamagemax += src.DamageMax
																											var/mob/players/M = usr
																											M.attackspeed -= src.wpnspd
																										else
																											usr << "<font color = teal>You have something equipped!"
																									else
																										usr << "<font color = teal>You do not meet or exceed the strength requirements!"
																								else
																									if ((typi=="CH")&&(twohanded==0))
																										if (usr.tempstr>=src.strreq)
																											if(usr.CHequipped==0 && usr.Wequipped==0 && usr.Sequipped==0 && usr.LSequipped==0 && usr.AXequipped==0 && usr.WHequipped==0 && usr.JRequipped==0 && usr.FPequipped==0 && usr.PXequipped==0 && usr.SHequipped==0 && usr.SKequipped==0 && usr.HOequipped==0 && usr.CKequipped==0/* && usr.GVequipped==0*/ && usr.FLequipped==0 && usr.PYequipped==0 && usr.OKequipped==0 && usr.SHMequipped==0 && usr.UPKequipped==0)
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
																												//usr.HMequipped = 2
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
																												usr.tempdamagemin += src.DamageMin
																												usr.tempdamagemax += src.DamageMax
																												var/mob/players/M = usr
																												M.attackspeed -= src.wpnspd
																											else
																												usr << "<font color = teal>You have something equipped!"
																										else
																											usr << "<font color = teal>You do not meet or exceed the strength requirements!"

			verb/Unequip()
				//set hidden = 1
				set src in usr
				M = usr
				call(/mob/players/proc/UESME)()
				call(/mob/players/proc/UEB)()
				call(/mob/players/proc/UED)()
				call(/mob/players/proc/UETW)()
				if((M.UESME==1)&&(M.GVequipped==1))
					return
				if((M.UEB==1)&&(M.HMequipped==1))
					return
				if((M.UED==1)&&(M.HMequipped==1))
					return
				if((M.UETW==1)&&(M.TWequipped==1))
					return
				if(src.suffix!="Equipped")
					usr << "<font color = teal>[src.name] not equipped!"
				else
					if (typi=="LS" && twohanded==1)
						if(usr.LSequipped==0)
							usr << "<font color = teal>You don't have [src.name] equipped!"
						else
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
							usr.GVequipped = 0
							usr.FLequipped = 0
							usr.PYequipped = 0
							usr.OKequipped = 0
							usr.SHMequipped = 0
							usr.UPKequipped = 0
							usr.TWequipped = 0
							usr.tempdamagemin -= src.DamageMin
							usr.tempdamagemax -= src.DamageMax
							var/mob/players/M = usr
							if(M.char_class=="Fighter")
								M.attackspeed = 6
							//else
								//M.attackspeed = 1
					else
						if (typi=="AX" && twohanded==1)
							if(usr.AXequipped==0)
								usr << "<font color = teal>You don't have [src.name] equipped!"
							else
								//src.verbs-=/obj/items/weapons/proc/Unequip
								//src.verbs+=/obj/items/weapons/verb/Equip
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
								usr.GVequipped = 0
								usr.FLequipped = 0
								usr.PYequipped = 0
								usr.OKequipped = 0
								usr.SHMequipped = 0
								usr.UPKequipped = 0
								usr.TWequipped = 0
								usr.tempdamagemin -= src.DamageMin
								usr.tempdamagemax -= src.DamageMax
								var/mob/players/M = usr
								if(M.char_class=="Defender")
									M.attackspeed = 5
								//else
									//M.attackspeed = 1
						else
							if (typi=="HM" && twohanded==0)
								if(usr.HMequipped==0)
									usr << "<font color = teal>You don't have [src.name] equipped!"
								else
									//src.verbs-=/obj/items/weapons/proc/Unequip
									//src.verbs+=/obj/items/weapons/verb/Equip
									src.suffix = ""
									usr.HMequipped = 0
									usr.tempdamagemin -= src.DamageMin
									usr.tempdamagemax -= src.DamageMax
									var/mob/players/M = usr
									if(M.char_class=="Defender")
										M.attackspeed = 4
									//else
										//M.attackspeed = 1
							else
								if (typi=="WH" && twohanded==1)
									if(usr.WHequipped==0)
										usr << "<font color = teal>You don't have [src.name] equipped!"
									else
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
										usr.GVequipped = 0
										usr.FLequipped = 0
										usr.PYequipped = 0
										usr.SHMequipped = 0
										usr.UPKequipped = 0
										usr.OKequipped = 0
										usr.TWequipped = 0
										usr.tempdamagemin -= src.DamageMin
										usr.tempdamagemax -= src.DamageMax
										var/mob/players/M = usr
										if(M.char_class=="Defender")
											M.attackspeed = 5
										//else
											//M.attackspeed = 1
								else
									if (typi=="JR" && twohanded==1)
										if(usr.JRequipped==0)
											usr << "<font color = teal>You don't have [src.name] equipped!"
										else
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
											usr.GVequipped = 0
											usr.FLequipped = 0
											usr.PYequipped = 0
											usr.SHMequipped = 0
											usr.UPKequipped = 0
											usr.OKequipped = 0
											usr.TWequipped = 0
											usr.tempdamagemin -= src.DamageMin
											usr.tempdamagemax -= src.DamageMax
											var/mob/players/M = usr
											if(M.char_class=="Defender")
												M.attackspeed = 6
											/*else if(M.char_class=="Defender")
												M.attackspeed = 7
											else if(M.char_class=="Defender")
												M.attackspeed = 5
											else if(M.char_class=="Defender")
												M.attackspeed = 8
											else
												M.attackspeed = 1*/
									else
										if (typi=="SH" && twohanded==1)
											if(usr.SHequipped==0)
												usr << "<font color = teal>You don't have [src.name] equipped!"
											else
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
												usr.GVequipped = 0
												usr.FLequipped = 0
												usr.PYequipped = 0
												usr.SHMequipped = 0
												usr.UPKequipped = 0
												usr.OKequipped = 0
												usr.TWequipped = 0
												usr.tempdamagemin -= src.DamageMin
												usr.tempdamagemax -= src.DamageMax
												var/mob/players/M = usr
												if(M.char_class=="Defender")
													M.attackspeed = 6
											//	else
													//M.attackspeed = 1
										else
											if (typi=="FP" && twohanded==1)
												if(usr.FPequipped==0)
													usr << "<font color = teal>You don't have [src.name] equipped!"
												else
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
													usr.GVequipped = 0
													usr.FLequipped = 0
													usr.PYequipped = 0
													usr.OKequipped = 0
													usr.SHMequipped = 0
													usr.UPKequipped = 0
													usr.TWequipped = 0
													usr.tempdamagemin -= src.DamageMin
													usr.tempdamagemax -= src.DamageMax
													var/mob/players/M = usr
													if(M.char_class=="Defender")
														M.attackspeed = 7
												//	else
														//M.attackspeed = 1
											else
												if (typi=="CK" && twohanded==0)
													if(usr.CKequipped==0)
														usr << "<font color = teal>You don't have [src.name] equipped!"
													else
														//src.verbs-=/obj/items/weapons/proc/Unequip
														//src.verbs+=/obj/items/weapons/verb/Equip
														src.suffix = ""
														usr.CKequipped = 0
														usr.tempdamagemin -= src.DamageMin
														usr.tempdamagemax -= src.DamageMax
														var/mob/players/M = usr
														if(M.char_class=="Defender")
															M.attackspeed = 6
													//	else
															//M.attackspeed = 1
												else
													if (typi=="PX" && twohanded==1)
														if(usr.PXequipped==0)
															usr << "<font color = teal>You don't have [src.name] equipped!"
														else
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
															usr.GVequipped = 0
															usr.FLequipped = 0
															usr.PYequipped = 0
															usr.OKequipped = 0
															usr.SHMequipped = 0
															usr.UPKequipped = 0
															usr.TWequipped = 0
															usr.tempdamagemin -= src.DamageMin
															usr.tempdamagemax -= src.DamageMax
															var/mob/players/M = usr
															if(M.char_class=="Defender")
																M.attackspeed = 7
															//else
																//M.attackspeed = 1
													else
														if (typi=="GV" && twohanded==1)
															if(usr.GVequipped==0)
																usr << "<font color = teal>You aren't wearing [src.name]!"
															else
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
																//else if(M.char_class=="Defender")
																	//M.attackspeed = 8
																//else
																	//M.attackspeed = 1
														else
															if (typi=="HO" && twohanded==1)
																if(usr.HOequipped==0)
																	usr << "<font color = teal>You don't have [src.name] equipped!"
																else
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
																	usr.GVequipped = 0
																	usr.FLequipped = 0
																	usr.PYequipped = 0
																	usr.OKequipped = 0
																	usr.SHMequipped = 0
																	usr.UPKequipped = 0
																	usr.TWequipped = 0
																	usr.tempdamagemin -= src.DamageMin
																	usr.tempdamagemax -= src.DamageMax
																	var/mob/players/M = usr
																	if(M.char_class=="Defender")
																		M.attackspeed = 8
																	//else
																		//M.attackspeed = 1
															else
																if (typi=="SK" && twohanded==0)
																	if(usr.SKequipped==0)
																		usr << "<font color = teal>You don't have [src.name] equipped!"
																	else
																		//src.verbs-=/obj/items/weapons/proc/Unequip
																		//src.verbs+=/obj/items/weapons/verb/Equip
																		src.suffix = ""
																		usr.SKequipped = 0
																		usr.tempdamagemin -= src.DamageMin
																		usr.tempdamagemax -= src.DamageMax
																		var/mob/players/M = usr
																		if(M.char_class=="Defender")
																			M.attackspeed = 8
																		//else
																			//M.attackspeed = 1
																else
																	if (typi=="FL" && twohanded==0)
																		if(usr.FLequipped==0)
																			usr << "<font color = teal>You don't have [src.name] equipped!"
																		else
																			//src.verbs-=/obj/items/weapons/proc/Unequip
																			//src.verbs+=/obj/items/weapons/verb/Equip
																			src.suffix = ""
																			usr.FLequipped = 0
																			usr.tempdamagemin -= src.DamageMin
																			usr.tempdamagemax -= src.DamageMax
																			var/mob/players/M = usr
																			if(M.char_class=="Defender")
																				M.attackspeed = 8
																			//else
																				//M.attackspeed = 1
																	else
																		if (typi=="PY" && twohanded==0)
																			if(usr.PYequipped==0)
																				usr << "<font color = teal>You don't have [src.name] equipped!"
																			else
																				//src.verbs-=/obj/items/weapons/proc/Unequip
																				//src.verbs+=/obj/items/weapons/verb/Equip
																				src.suffix = ""
																				usr.PYequipped = 0
																				usr.tempdamagemin -= src.DamageMin
																				usr.tempdamagemax -= src.DamageMax
																				var/mob/players/M = usr
																				if(M.char_class=="Defender")
																					M.attackspeed = 1
																				//else
																					//M.attackspeed = 1
																		else
																			if (typi=="OK" && twohanded==0)
																				if(usr.OKequipped==0)
																					usr << "<font color = teal>You don't have [src.name] equipped!"
																				else
																					//src.verbs-=/obj/items/weapons/proc/Unequip
																					//src.verbs+=/obj/items/weapons/verb/Equip
																					src.suffix = ""
																					usr.OKequipped = 0
																					usr.tempdamagemin -= src.DamageMin
																					usr.tempdamagemax -= src.DamageMax
																					var/mob/players/M = usr
																					if(M.char_class=="Defender")
																						M.attackspeed = 1
																					//else
																						//M.attackspeed = 1
																			else
																				if (typi=="SHM" && twohanded==0)
																					if(usr.SHMequipped==0)
																						usr << "<font color = teal>You don't have [src.name] equipped!"
																					else
																						//src.verbs-=/obj/items/weapons/proc/Unequip
																						//src.verbs+=/obj/items/weapons/verb/Equip
																						src.suffix = ""
																						usr.SHMequipped = 0
																						usr.tempdamagemin -= src.DamageMin
																						usr.tempdamagemax -= src.DamageMax
																						var/mob/players/M = usr
																						if(M.char_class=="Defender")
																							M.attackspeed = 1
																						//else
																							//M.attackspeed = 1
																				else
																					if (typi=="UPK" && twohanded==1)
																						if(usr.UPKequipped==0)
																							usr << "<font color = teal>You don't have [src.name] equipped!"
																						else
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
																							usr.GVequipped = 0
																							usr.FLequipped = 0
																							usr.PYequipped = 0
																							usr.OKequipped = 0
																							usr.SHMequipped = 0
																							usr.UPKequipped = 0
																							usr.TWequipped = 0
																							usr.tempdamagemin -= src.DamageMin
																							usr.tempdamagemax -= src.DamageMax
																							var/mob/players/M = usr
																							if(M.char_class=="Defender")
																								M.attackspeed = 8
																							//else
																								//M.attackspeed = 1
																					else
																						if (typi=="TW" && twohanded==0)
																							if(usr.TWequipped==0)
																								usr << "<font color = teal>You don't have [src.name] equipped!"
																							else
																								//src.verbs-=/obj/items/weapons/proc/Unequip
																								//src.verbs+=/obj/items/weapons/verb/Equip
																								src.suffix = ""
																								usr.TWequipped = 0
																								usr.tempdamagemin -= src.DamageMin
																								usr.tempdamagemax -= src.DamageMax
																								var/mob/players/M = usr
																								if(M.char_class=="Defender")
																									M.attackspeed = 1
																						else
																							if (typi=="CH" && twohanded==0)
																								if(usr.CHequipped==0)
																									usr << "<font color = teal>You don't have [src.name] equipped!"
																								else
																									//src.verbs-=/obj/items/weapons/proc/Unequip
																									//src.verbs+=/obj/items/weapons/verb/Equip
																									src.suffix = ""
																									usr.CHequipped = 0
																									usr.tempdamagemin -= src.DamageMin
																									usr.tempdamagemax -= src.DamageMax
																									var/mob/players/M = usr
																									if(M.char_class=="Defender")
																										M.attackspeed = 1

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
				if(src.suffix == "Equipped")
					Unequip()
				else
					Equip()

	//Sandbox weapons and tools
			var/mob/players/M
			LongSword
				icon_state="LongSword"
				typi = "LS"
				strreq = 1
				name = "Long Sword"
				//description = "<font color = #8C7853><center><b>Long Sword:</b><br>3-7 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 7
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BroadSword
				icon_state="BroadSword"
				typi = "BS"
				strreq = 1
				name = "Broad Sword"
				//description = "<font color = #8C7853><center><b>Broad Sword:</b><br>2-5 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 2
				twohanded = 0
				DamageMin = 2
				DamageMax = 5
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			WarSword
				icon_state="WarSword"
				typi = "WS"
				strreq = 1
				name = "War Sword"
				//description = "<font color = #8C7853><center><b>War Sword:</b><br>4-9 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 1
				DamageMin = 4
				DamageMax = 9
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleSword
				icon_state="BattleSword"
				typi = "BAS"
				strreq = 1
				name = "Battle Sword"
				//description = "<font color = #8C7853><center><b>Battle Sword:</b><br>3-6 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 2
				twohanded = 0
				DamageMin = 3
				DamageMax = 6
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				typi = "WAX"
				strreq = 1
				name = "War Axe"
				//description = "<font color = #8C7853><center><b>War Axe:</b><br>4-6 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 4
				DamageMax = 6
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleAxe
				icon_state="BattleAxe"
				typi = "BAX"
				strreq = 1
				name = "Battle Axe"
				//description = "<font color = #8C7853><center><b>Battle Axe:</b><br>3-4 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 4
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				//DblClick()				//If you double click the tree()
			BattleHammer //name of object
				icon_state = "BattleHammer" //icon state of object
				typi = "BHM"
				strreq = 1
				name = "Battle Hammer"
				//description = "<font color = #8C7853><center><b>Battle Hammer:</b><br>3-4 Damage"
				Worth = 1
				wpnspd = 4
				tlvl = 1
				twohanded = 0
				DamageMin = 3
				DamageMax = 4
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			WarHammer //name of object
				icon_state = "WarHammer" //icon state of object
				typi = "WH"
				strreq = 1
				name = "War Hammer"
				description = "<font color = #8C7853><center><b>War Hammer:</b><br>3-8 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 8
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				//DblClick()				//If you double click the tree()
			WarMaul //name of object
				icon_state = "WarMaul" //icon state of object
				typi = "WM"
				strreq = 1
				name = "War Maul"
				//description = "<font color = #8C7853><center><b>War Maul:</b><br>3-4 Damage"
				Worth = 1
				wpnspd = 2
				tlvl = 1
				twohanded = 1
				DamageMin = 3
				DamageMax = 4
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleMaul //name of object
				icon_state = "BattleMaul" //icon state of object
				typi = "BM"
				strreq = 1
				name = "Battle Maul"
				//description = "<font color = #8C7853><center><b>Battle Maul:</b><br>2-3 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 2
				DamageMax = 3
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			WarScythe //name of object
				icon_state = "WarScythe" //icon state of object
				typi = "WS"
				strreq = 1
				name = "War Scythe"
				//description = "<font color = #8C7853><center><b>War Scythe:</b><br>5-8 Damage"
				Worth = 1
				wpnspd = 3
				tlvl = 1
				twohanded = 0
				DamageMin = 5
				DamageMax = 8
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

			BattleScythe //name of object
				icon_state = "BattleScythe" //icon state of object
				typi = "BS"
				strreq = 1
				name = "Battle Scythe"
				//description = "<font color = #8C7853><center><b>Battle Scythe:</b><br>4-7 Damage"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				DamageMin = 4
				DamageMax = 7
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.WarHammer=1
					Drop()
						set category = "Commands"
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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.Gloves=1
					Drop()
						set category = "Commands"
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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.Rod=1
					Drop()
						set category = "Commands"
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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.PickAxe=1
					Drop()
						set category = "Commands"
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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

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
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

				/*verb //verb for the object (verb it's what you do)
					Get()
						set category = "Commands"
						set src in oview(0)
						src.Move(usr)
						M.PickAxe=2
					Drop()
						set category = "Commands"
						set src in usr
						if(src.suffix == "Equipped")
							usr << "<font color = teal>Un-equip [src] first!"
						else
							src.Move(usr.loc)*/
			UnbakedJar //name of object
				icon = 'dmi/64/inven.dmi'
				icon_state = "UBJar" //icon state of object
				//typi = "JR"
				//strreq = 1
				name = "Unbaked Jar"
				//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
				Worth = 1
				//wpnspd = 1
				//tlvl = 1
				//twohanded = 1
			Jar //name of object
				icon_state = "Jar" //icon state of object
				typi = "JR"
				strreq = 1
				name = "Jar"
				//description = "<font color = #8C7853><center><b>Jar:</b><br>2-4 Damage,<br>1 Strength-Req<br>liquid"
				Worth = 1
				wpnspd = 1
				tlvl = 1
				twohanded = 1
				verb/Drink()
					var/mob/players/M = usr
					var/obj/items/tools/Jar/J = locate() in M.contents
					if(J.name=="Filled Jar")
						set category=null
						set popup_menu=1
						usingjar(M,100)
						J.overlays -= /obj/liquid
						J.name="Jar"
						return
					else
						M<<"You need to fill the Jar to drink out of it."
						return
				verb/Empty()
					set category=null
					set popup_menu=1
					var/mob/players/M = usr
					var/obj/items/tools/Jar/J = locate() in M.contents
					if(J.name=="Filled Jar")
						set category = "Commands"
						overlays -= /obj/liquid
						J.name="Jar"
						M<<"You empty the contents of the Jar on to the ground."
					else
						M<<"The Jar is Already empty."
				New()
					description = "<br><font color = #e6e8fa><center><b>[name]</b><br>Tool Level [tlvl]<br>[DamageMin]-[DamageMax] Damage<br>[wpnspd] Speed<br>[strreq] Strength-Req<br>[src.twohanded?"Two Handed":"One Handed"]<br>Worth [Worth]"

					//description = "<font color = #ffd700><center><b>Water Jar</b>"
				proc/usingjar(var/obj/items/tools/Jar/J,amount)
					var/mob/players/M = usr
					if (amount > (M.MAXenergy-M.energy))
						amount = (M.MAXenergy-M.energy)
					M.energy += amount
					M << "You drank the water from the Filled Jar; Ahh, Refreshing...The Jar is now empty. <b>[amount] energy recovered."

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
				M.loc = locate(16,40,1)//locate(rand(100,157),rand(113,46),12)
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
				M.loc = locate(50,50,1)//locate(rand(100,157),rand(113,46),12)
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
				set category = "Commands"
				set src in oview(1) //...
				Mining(M) //calls the mining proc
	*/
	Buildable
		Smithing
			Forge
				name = "Empty Forge"
				density = 1
				plane = MOB_LAYER+1
				icon = 'dmi/64/creation.dmi'
				icon_state = "forge"
				var/spawntime = "5000"
				var/soundmob/s
				light = /light/directional
				New()
					..()

					// we make the lamps have directional light sources,
					// the /light/directional object is defined at the
					// top of this file.
					//light = new /light/circle(src, 2)
					//light = new /light/directional(src, 7)
					//light.on = 0
				verb //...
					Smelt() //...
						set category=null
						set popup_menu = 1
						var/mob/players/M
						//set hidden = 1
						set src in oview(1) //...
						Smelting(M) //calls the mining proc
					Heat()
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						set category = "Commands"
						var/mob/players/M
						M = usr
						for(var/obj/items/Ingots/J in M.contents)
							if((J in M.contents)&&(src.name=="Lit Forge"))
								//var/obj/items/Kindling/J = locate() in M.contents
								if(J.Tname!="Hot")
									M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]."
									sleep(10)
									//J.RemoveFromStack(1)
									//src.overlays -= overlays
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
									//light.off()
									J:Tname="Hot"
									M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is hot."
								//else
									//M<<"[J] is already Hot"
									//call(proc/Temp)(J)
									return
						for(var/obj/items/Ingots/Scraps/J in M.contents)
							if((J in M.contents)&&(src.name=="Lit Forge"))
								//var/obj/items/Kindling/J = locate() in M.contents
								if(J.Tname!="Hot")
									M<<"You begin to heat \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J]."
									sleep(5)
									//J.RemoveFromStack(1)
									//src.overlays -= overlays
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
									//light.off()
									J:Tname="Hot"
									M<<"\  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] is hot."
								//else
								//	M<<"[J] is already Hot"
									return
					Snuff_Forge()
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						set category = "Commands"
						var/mob/players/M
						M = usr
						if(src in oview(1))
							//var/obj/items/Kindling/J = locate() in M.contents
							if(src.name=="Lit Forge")
								M<<"You snuff the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge."
								sleep(5)
								//J.RemoveFromStack(1)
								src.overlays -= overlays
								src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
								src:light.off()
								M.unlistenSoundmob(s)
								src:name="Unlit Forge"
								return
					Prepare_Forge()
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						set category = "Commands"
						var/mob/players/M
						M = usr
						if(src in oview(1))
							var/obj/items/Kindling/ueikkindling/J = locate() in M.contents
							if((J in M.contents)&&(src.name=="Empty Forge")&&(J.stack_amount>=1))
								M<<"You add the \  <IMG CLASS=icon SRC=\ref[J.icon] ICONSTATE='[J.icon_state]'>[J] into the empty \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge."
								sleep(5)
								J.RemoveFromStack(1)
								src.overlays += image('dmi/64/creation.dmi',icon_state="forgeF")
								src:name="Unlit Forge"
								return
							else
								M<<"Need at least one \  <IMG CLASS=icon SRC=\ref'dmi/64/tree.dmi' ICONSTATE='kind1'>kindling to add to an empty <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>forge."
								return
					Light_Forge()
						set waitfor = 0
						set category=null
						set popup_menu = 1
						set src in oview(1)
						set category = "Commands"
						src.s = new/soundmob(src, 20, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						var/mob/players/M
						M = usr
					//	if(src.name=="Lit Forge")
						//	M<<"Forge already Lit."
					//		return 0
						//if(src.name=="Empty Forge")
						//	M<<"Add kindling to light the Forge."
						//	return 0
						//if((M.CKequipped!=1) && (M.FLequipped!=1))
						//	return 0
						if(M.Doing==0)
							if((M.CKequipped==1) && (M.FLequipped==1) && (src.name=="Unlit Forge"))
								//var/obj/items/tools/Flint/J = locate() in M.contents
								M<<"You start to light the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='forgeF'>Forge."
								M.Doing=1
								sleep(5)
								//J.RemoveFromStack(1)
								src:name="Lit Forge"
								M<<"You light the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='forgeL'>Forge."
								M.listenSoundmob(s)
								if(src.name=="Dead Forge") M.unlistenSoundmob(s)
								if((M.CKequipped==1) && (M.FLequipped==1) && (src.name=="Lit Forge"))
									light = new /light/directional(src, 4)
									src.light.on()
									src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeF")
									src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
									//sleep(spawntime)
									M.Doing=0
									sleep(5000)
									//flick('fire.dmi',src)
									//src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeF")
									//src.overlays += image('dmi/64/creation.dmi',icon_state="forgeL")
									M<<"The \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='forgeD'>Forge is dying"
									src.overlays += image('dmi/64/creation.dmi',icon_state="forgeD")
									src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeL")
									//src:name="Unfueled Fire"
									//src.light.off()
									M<<"The \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge dies"
									src.overlays -= image('dmi/64/creation.dmi',icon_state="forgeD")
									//src.overlays += icon('dmi/64/fire.dmi',icon_state="outfire")
									src:name="Dead Forge"
									if(src.name=="Dead Forge") M.unlistenSoundmob(s)
									src:name="Empty Forge"
									src.light.off()
								//new /light/circle(src, 9)

							else
								usr << "Need to use the \  <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='CarvingKnife'>Carving Knife with the <IMG CLASS=icon SRC=\ref'dmi/64/creation.dmi' ICONSTATE='flint'>Flint on an Unlit <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge to Light it!"
						else
							usr << "Already lighting the \  <IMG CLASS=icon SRC=\ref[src.icon] ICONSTATE='[src.icon_state]'>Forge..."

			Anvil
				name = "Anvil"
				density = 1
				plane = 5
				icon = 'dmi/64/creation.dmi'
				icon_state = "anvil"
				var/mob/players/M
				verb
					Smith() //...
						set category=null
						set popup_menu = 1
						//set hidden = 1
						set src in oview(1) //...
						//var/soundmob/s = new/soundmob(src, 15, 'snd/cleaned/fire2.ogg', TRUE, 0, 60, FALSE)
						Smithing(M) //calls the mining proc				M.PickAxe=0 ---- uncomment lines after getting anvil hammer sfx
						//M.listenSoundmob(s)
						//if(M.Doing==0)
							//M.unlistenSoundmob(s)