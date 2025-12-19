#include "implementation.dm"

/////////////////////////////////////
// WELCOME TO BASECAMP: EVENT LOOP //
/////////////////////////////////////
/*
 This event loop library is a part of the BaseCamp suite,
 Deadron's game infrastructure system.  This library handles
 an event loop for the game, allowing any object to
 receive a base_EventCycle() call every tick of the game.

 For a fully working example using this library, download:

 byond://Deadron.SimpleLoop

 To include this library, use this line in your code:

#include <deadron/eventloop>


 Why to use it
 -------------
 Using an event loop gives you great power over your game.
 You can control when things happen through it.  For example,
 if the game is lagging, you can slow down the event loop
 and everything in your game using it will slow down. If
 you were handling everything through spawn() or sleep()
 calls, you wouldn't have this kind of control.

 Or you could override GameController.EventCycle() and only
 let a limited number of NPCs move each tick to reduce CPU
 hit.


 What it does
 ------------
 The library uses the BaseCamp global GameController to
 keep a list of event cycle receivers.  Each tick (or
 however often you specify), the library calls the base_EventCycle()
 proc for each event cycle receiver. This allows objects
 to wake up and consider doing something every 1/10th of
 a second.

 You can put whatever objects you want in the loop. By
 default, mobs add themselves to the loop (you can turn that
 off, as specified below).
*/


datum/proc/base_EventCycle(world_time)
	/*
	 An object's event cycle proc
	 ----------------------------
	 For any object that has been added to GameController's
	 event cycle receivers, this proc is called each tick,
	 or however often is specified by GameController.cycle_delay.
	 The current world.time is passed as an argument.

	 The key to using the event loop library is overriding this
	 proc for an object.  For example:

	 mob/base_EventCycle(world_time)
	 	src << "Hey the game has been running for [world_time] ticks,
	 	        and you got another chance to do something!"
	*/
	return


/*
 Automatic mob event cycle
 -------------------------
 By default mobs add themselves to the event cycle.
 If you don't want this to happen, set the mob's
 base_event_cycle variable to 0, like so:

 mob/base_event_cycle = 0

 Why you might turn this off:  You might want to control
 how many mobs move each cycle to keep lag down.
 To do this, create something like a "zone" or "players"
 object and add that to GameControllers event cycle receivers.
 Then each cycle, decide which mobs will get a cycle and
 call the mob's base_EventCycle() function yourself.
*/
mob/base_event_cycle = 1


/*
 Setting the event cycle delay
 -----------------------------
 You can specify how many ticks between each event cycle
 by setting the GameController's cycle_delay variable
 like so:

 GameController.cycle_delay = 3
*/
BaseCamp/GameController/cycle_delay = 1


/*
 Turning the event cycle on and off
 ----------------------------------
 You can turn the event cycle on or off by setting
 GameController's cycle_active variable like so:

 GameController.cycle_active = 0
*/
BaseCamp/GameController/cycle_active = 1


BaseCamp/GameController/AddEventCycleReceiver(receiver)
	/*
	 Adding an object to the event loop
	 ----------------------------------
	 Call this function to add an object to the event loop,
	 like so:

	 GameController.AddEventCycleReceiver(src)

	 After being added, the object's base_EventLoop()
	 function will be called every tick (or longer if you
	 specify a cycle_delay). The current world.time
	 is passed as an argument to the event loop function.

	 By default, mobs automatically call this function
	 to add themselves to the event loop.
	*/
	return ..()


BaseCamp/GameController/RemoveEventCycleReceiver(receiver)
	/*
	 Remove an object from the event loop
	 ------------------------------------
	 By default, mobs automatically remove themselves.
	*/
	return ..()


BaseCamp/GameController/EventCycle()
	/*
	 The global event cycle
	 ----------------------
	 This function calls itself every cycle_delay ticks.
	 For each event cycle receiver this calls
	 base_EventCycle(), passing the world.time as an argument.

	 If you want to add special behavior -- like slowing things
	 down if lag is bad, then override this function and add
	 your lag check.
	*/
	return ..()





