/**
 * Client Extensions - UI management
 */

client
	var
		list/ui_list = list()  // List to track UI elements
	
	proc/add_ui(obj/screen/element)
		if(!element) return
		if(!(element in ui_list))
			ui_list += element
		screen += element
	
	proc/remove_ui(obj/screen/element)
		if(!element) return
		if(element in ui_list)
			ui_list -= element
		screen -= element
