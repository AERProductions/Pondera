/*
	CHARACTER CREATION INTEGRATION
	
	Bridges the new character creation UI with the existing BaseCamp system.
	Handles the login flow and character creation dispatch.
*/

/mob/BaseCamp/proc/start_character_creation_ui()
	/*
	   Start the new screen-based character creation UI.
	   Called from FirstTimePlayer() when a new character needs to be created.
	*/
	client.start_character_creation()


/mob/BaseCamp/proc/use_old_character_creation()
	/*
	   Fallback to old form system if new UI is not available.
	   Kept for compatibility with existing code.
	*/
	src.mode_form.DisplayForm()
