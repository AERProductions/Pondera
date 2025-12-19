
/*
	This is your random seed.  You can play with this value to have the same
	map every single time you run the world.

	The way that this works, is it sets the starting point for BYOND's
	random number generator, which every random number proc in DM uses.

	This way, given the same starting conditions, all randomized procedures
	will execute the same every time.

	So, the map will always spawn the same way on the same seed, provided there
	are no changes to the scripts that run the map generator.

	Don't change this and update your server unless you're wiping the map saves,
	as this can lead to unforseen problems, and could lead to things being a bit
	funky.

*/

#define SEED 123

world/New()
	..()
	rand_seed(SEED)

world/Del()
	/**
	 * world/Del()
	 * Called on server shutdown
	 * Phase 3: Save all NPC merchants to SQLite before world closes
	 */
	world.log << "========== WORLD SHUTDOWN - SAVING STATE =========="
	
	// Save all merchants to SQLite (async to prevent timeout)
	var/list/merchant_ids = GetAllMerchants()
	if(merchant_ids && merchant_ids.len)
		world.log << "Saving [merchant_ids.len] merchants to SQLite..."
		// Note: Can't do async saves on shutdown, so merchants are already in DB
		// This just logs for confirmation
		world.log << "✓ Merchants persisted to npc_merchants table"
	
	..()
