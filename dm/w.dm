turf
	Building
		Foundations
			Hfoundation
				icon = 'dmi/64/build.dmi'
				icon_state = "Hfoundation"
				layer = 1
				density = 0
				Entered(O)
					if(ismob(O) && O:client)
						for(var/obj/Buildable/Roofing/Roof/R in oview(3))
							R.plane = -10
					..()
				Exited(O)
					if(ismob(O) && O:client)
						for(var/obj/Buildable/Roofing/Roof/R in range(12,O))
							R:plane = 10
					..()
			Cfoundation
				icon = 'dmi/64/build.dmi'
				icon_state = "foundation"
				layer = 1
				density = 0
				Entered(O)
					if(ismob(O) && O:client)
						for(var/obj/Buildable/Roofing/INTRoof/R in oview(3))
							R.plane = -10
					..()
				Exited(O)
					if(ismob(O) && O:client)
						for(var/obj/Buildable/Roofing/INTRoof/R in range(12,O))
							R:plane = 10
					..()
			Pfoundation
				icon = 'dmi/64/build.dmi'
				icon_state = "pfoundation"
				layer = 1
				density = 0
				Entered(O)
					if(ismob(O) && O:client)
						for(var/obj/Buildable/Roofing/HINTRoof/R in oview(3))
							R.plane = -10
					..()
				Exited(O)
					if(ismob(O) && O:client)
						for(var/obj/Buildable/Roofing/HINTRoof/R in range(12,O))
							R:plane = 10
					..()

obj
	Buildable
		Roofing
			Roof
				icon = 'dmi/64/whroof.dmi'
				plane = 10
				mouse_opacity = 0
			HINTRoof
				icon = 'dmi/64/hroof.dmi'
				plane = 10
				mouse_opacity = 0
			INTRoof
				icon = 'dmi/64/introof.dmi'
				plane = 10
				mouse_opacity = 0
			woodfloor
				icon = 'dmi/64/build.dmi'
				icon_state = "woodfloor"
				plane = 3
				mouse_opacity = 0