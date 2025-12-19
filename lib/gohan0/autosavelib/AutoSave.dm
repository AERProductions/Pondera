client
	verb
		AutoSave()
			set category = "Index"
			usr << "<I><B>Currently Saving Characters Profile.</B></I>"
			sleep(20)
			usr << "<I><B>Save Complete</B></I>"
			spawn(900)
			src.AutoSave()
