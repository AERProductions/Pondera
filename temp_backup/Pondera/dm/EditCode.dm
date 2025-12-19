mob/players/Special1
	verb
		Edit(Z as mob|obj|turf in world)
			set category=null
			var/atom/O=Z
			again
			var/variable = input(src,"Which var?","Editing [Z]") as null|anything in O.vars
			if(variable)
				if(!O)return

				var/valueatual=O.vars[variable]
				var/valuep=initial(O.vars[variable])
				if(isnull(valuep))valuep="null"

				var/default
				if(isnull(O.vars[variable]))
					default = valuep="null"
				else if(isnum(O.vars[variable]))
					default = "Number"
					valueatual=num2text(valueatual,9)
					valuep=num2text(valuep,9)
				else if(istext(O.vars[variable]))
					default = "Text"
				else if(isloc(O.vars[variable]))
					default = "Reference"
				else if(isicon(O.vars[variable]))
					default = "Icon"
				else if(islist(O.vars[variable]))
					default = "List"
					if(O.vars[variable].len>1)
						valueatual=jointext(valueatual,", ")
					else if(O.vars[variable].len==1)
						valueatual=pick(O.vars[variable])
					else
						valueatual="empty list"
					if(islist(valuep)&&valuep:len>1)
						valuep=jointext(valuep,", ")
						if(!valuep)valuep="empty list"
					else
						valuep="empty list"
				else if(isfile(O.vars[variable]))
					default = "File"
				else if(istype(O.vars[variable],/atom))
					default = "Reference"

				again2

				var/class = input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editing [Z]") as null|anything in list("Change","Restore","Nullify","Return")
				switch(class)
					if("Return")
						goto again
					if("Restore")
						if(O)
							O:vars[variable] = initial(O:vars[variable])
//							if(ismob(O)&&O in players)
//								O:SaveChar()
					if("Nullify")
						if(O)
							if(islist(O:vars[variable]))
								O:vars[variable] = new
							else if(isnum(O:vars[variable]))
								O:vars[variable]=0
							else if(istext(O:vars[variable]))
								O:vars[variable]=""
							else
								O:vars[variable] = null
//							if(ismob(O)&&O in players)
//								O:SaveChar()
					if("Change")
						if(O)
							var/list/optionslist=list("Text","Number","Reference","Icon","File","Return")
							if(default == "Reference")
								optionslist+="Edit Ref."
							var/tipo=input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editting [Z]. Choose a Category:",default) as null|anything in optionslist
							var/value=0
							if(O)
								switch(tipo)
									if(null)return
									if("Text")
										value = input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editting [Z]. Choose a new value:",valueatual) as null|text
									if("Number")
										value = input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editting [Z]. Choose a new value:",valueatual) as null|num
									if("Reference")
										value = input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editting [Z]. Choose a new value:",valueatual) as null|anything in world
									if("File")
										value = input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editting [Z]. Choose a new value:",valueatual) as null|file
									if("Icon")
										value = input(src,"Var: [variable]\nCurrent Category: [default]\nCurrent Value: [valueatual]\nDefault Value: [valuep]","Editting [Z]. Choose a new value:",valueatual) as null|icon
									if("Return")
										goto again2
									if("Edit Ref.")
										src.Edit(valueatual)
										return
								if(value||(tipo=="Text"&&value=="")||(tipo=="Number"&&value==0))
									O:vars[variable] = value