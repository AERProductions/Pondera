/**
 * HUD Manager - Initialize and manage player UI
 */

mob/players/Login()
	world.log << "\[LOGIN\] mob/players/Login() called for [src.name] at ([src.x],[src.y],[src.z])"
	
	// Set appearance
	if(!icon)
		src.icon = 'dmi/64/char.dmi'
	if(!icon_state)
		src.icon_state = "Ffriar"
	
	// Hide stat panel
	if(client)
		client.statpanel = ""
		client.eye = src
	
	// Validate world initialization
	if(!CanPlayersLogin())
		world.log << "\[LOGIN\] Player [src.name] rejected - initialization incomplete"
		src << "⚠️ Server is initializing systems. Please reconnect in a moment."
		del(src)
		return
	
	// Mark player as online
	MarkPlayerOnline(src)
	world.log << "\[LOGIN\] Player marked as online"
	
	// Call parent Login() - standard login hooks (this triggers HUD creation in Basics.dm)
	..()
	world.log << "\[LOGIN\] Parent Login() called"
	
	// Initialize survival systems
	InitializeHungerThirstSystem()
	IntegrateMarketBoardOnLogin(src)
	world.log << "\[LOGIN\] Systems initialized - player ready on map"


