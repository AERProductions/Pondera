///////////////////////////////////////////////////////////////////////////////////////////////

mob/players

//=============================================================================================

	// Creating new variables for the new mob definition
	var
		// Constant values that determine the method of movement
		const/MOVE_NORMAL = 0 as num
		const/MOVE_STRAFE = 1 as num
		const/MOVE_FACE = 2 as num

		// The current method of movement
		moveMode_ = MOVE_NORMAL as num

//=============================================================================================
//---------------------------------------------------------------------------------------------

	// A derived definition to replace the default Move() proc
	Move(NewLoc,Dir=0)
		if (moveMode_ == MOVE_FACE)
			// Change the direction
			dir = Dir
			// The mob did not change locations
			return FALSE

		if (moveMode_ == MOVE_NORMAL)
			// Use the default Move() proc in the direction of movement
			return ..(NewLoc,Dir)


		if (moveMode_ == MOVE_STRAFE)
			// Use the default Move() proc in the same direction the mob is already in
			return ..(NewLoc,dir)

		// Not moving for unknown modes of movement
		return FALSE

//========================================================================================

	// Creating commands for the player to enter
	verb
		Jump()//doesn't work, needs figuring out
			set waitfor = 0
			set hidden = 1
			//moveMode_ = MOVE_FACE
			//usr.density = 0
			if(char_class=="Landscaper")
				if(gender=="Male")
					flick('dmi/64/blank.dmi', usr)
					moveMode_ = MOVE_FACE
					density = 0
					sleep(10)
					density = 1
					moveMode_ = MOVE_NORMAL
					return
				else if(usr.gender=="Female")
					flick('dmi/64/blank.dmi', usr)
			if(char_class=="Smithy")
				if(usr.gender=="Male")
					flick('dmi/64/blank.dmi', usr)
				else if(usr.gender=="Female")
					flick('dmi/64/blank.dmi', usr)
			if(char_class=="Builder")
				if(usr.gender=="Male")
					flick('dmi/64/blank.dmi', usr)
				else if(usr.gender=="Female")
					flick('dmi/64/blank.dmi', usr)
			if(char_class=="Magus")
				if(usr.gender=="Male")
					flick('dmi/64/blank.dmi', usr)
				else if(usr.gender=="Female")
					flick('dmi/64/blank.dmi', usr)
			if(char_class=="Feline")
				if(usr.gender=="Male")
					flick('dmi/64/blank.dmi', usr)
				else if(usr.gender=="Female")
					flick('dmi/64/blank.dmi', usr)
			if(char_class=="GM")
				flick('dmi/64/blank.dmi', usr)

//----------------------------------------------------------------------------------------

		Stance_Hold_Position()
			set hidden = 1
			moveMode_ = MOVE_FACE
			usr << "You've changed your stance to Hold Position."

//----------------------------------------------------------------------------------------

		Stance_Sprint_Mode()
			set hidden = 1
			moveMode_ = MOVE_NORMAL
			usr << "You've changed your stance to Free Sprint."

//----------------------------------------------------------------------------------------

		Stance_Strafe_Mode()
			set hidden = 1
			moveMode_ = MOVE_STRAFE
			usr << "You've changed your stance to Strafe."

///////////////////////////////////////////////////////////////////////////////////////////////