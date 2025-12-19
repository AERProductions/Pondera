////////////////////////////
// DON'T TOUCH THIS FILE! //
////////////////////////////
/*
 Unless you are a BYOND guru who is curious how this works,
 there is no point in reading this file.  It's just the gritty
 code, and you NEVER need to touch it or even read it.

 See eventloop.dm for full library documentation.

 If you touch this file and then your event loop breaks,
 don't bug me about it, it's not my problem.
*/


///////////////////////////////////
// GRITTY IMPLEMENTATION DETAILS //
///////////////////////////////////
// You probably don't care about this stuff and you probably don't need to touch it.
#include <deadron/basecamp>

/***
world
	New()
		var/result = ..()
		if (!GameController)
			GameController = new()
		return result
***/

BaseCamp/GameController
	// Runs the game event loop.
	var/tmp
//		name = "GameController"
//		initialized = 0

		cycle_delay = 1
		cycle_active = 1

//		track_players = 1
//		list/online_clients					// All the clients currently online.

		list/_event_cycle_receivers			// Objects that want to be notified each event cycle.

	Initialize()
		if (!_event_cycle_receivers)
			_event_cycle_receivers = new()

			spawn()
				EventCycle()
		return ..()

	proc
		AddEventCycleReceiver(receiver)
			if (!initialized)
				Initialize()

			_event_cycle_receivers += receiver
			return

		RemoveEventCycleReceiver(receiver)
			if (!initialized)
				Initialize()

			_event_cycle_receivers -= receiver

		EventCycle()
			/* This cycle runs the game.
			   Everything happens through here to give control and analysis capability.
			   If things are taking too long, this method can react. */
			if (cycle_active)
				var/world_time = world.time
				var/receiver
				for (receiver in _event_cycle_receivers)
					if (receiver)
						receiver:base_EventCycle(world_time)

			// Give up control and call self next tick.
			spawn(cycle_delay)
				EventCycle()

/***
		ClientLoggedIn(client/Client)
			if (!initialized)
				Initialize()
				Client.base_is_game_creator = 1

			if (!online_clients)
				online_clients = new()

			online_clients += Client

		ClientLoggedOut(client/Client)
			if (online_clients)
				online_clients -= Client

		GlobalMessage(message)
			PlayerMobs() << message

		PlayerMobs()
			var/list/player_mobs = new()
			if (!online_clients)
				return player_mobs

			var/client/Client
			for (Client in online_clients)
				player_mobs += Client.mob
			return player_mobs

	Write()
		GlobalMessage("\red BaseCamp: Illegal attempt to write GameController to savefile!")
		world.log << "BaseCamp: Illegal attempt to write GameController to savefile!"
		return
***/

/***
client
//	var/tmp/base_is_game_creator

	New()
		if (!GameController)
			GameController = new()

		if (GameController.track_players)
			GameController.ClientLoggedIn(src)
		return ..()

	Del()
		GameController.ClientLoggedOut(src)
		return ..()
***/

mob
	var/tmp
		base_event_cycle = 1		// By default, mobs add themselves to GameController's event_cycle_receivers list.

	New()
		var/result = ..()
		if (base_event_cycle)
			if (!GameController)
				GameController = new()
			GameController.AddEventCycleReceiver(src)
		return result

	Del()
		GameController.RemoveEventCycleReceiver(src)
		..()


