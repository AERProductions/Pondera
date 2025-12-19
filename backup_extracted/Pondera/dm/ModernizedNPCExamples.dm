// ============================================================================
// MODERNIZED NPC INTERACTION EXAMPLES
// ============================================================================
/**
 * This file shows how to convert legacy Click()-based NPCs to the new
 * HUD-based interaction system.
 * 
 * These are examples of what converted NPCs look like.
 * Once validated, this pattern applies to all 14+ NPCs.
 */

// ============================================================================
// EXAMPLE 1: BELIEF > ADVENTURER (Simple dialogue NPC)
// ============================================================================

/mob/npc/BeliefAdventurer
	name = "Adventurer"
	density = 1
	icon = 'dmi/64/npcs.dmi'
	icon_state = "adv"
	var/Speed = 13
	
	proc/GetInteractionOptions()
		/**
		 * Return list of interaction options for this NPC
		 * New system calls this when player interacts
		 */
		return list(
			new /datum/npc_interaction_option("Talk", "talk"),
			new /datum/npc_interaction_option("Ask for Advice", "advice"),
			new /datum/npc_interaction_option("Leave", "leave")
		)
	
	proc/Interact_talk(mob/players/M, datum/NPC_Interaction/session)
		/**
		 * Handler for "Talk" interaction
		 * Called when player selects "Talk" from menu
		 */
		session.SetResponse("So you've made it this far, be wary about going further unless prepared... You won't be able to return!")
	
	proc/Interact_advice(mob/players/M, datum/NPC_Interaction/session)
		/**
		 * Handler for "Ask for Advice" interaction
		 * Shows dialogue response and keeps menu open for follow-up
		 */
		session.SetResponse("Well, at a certain point, to the west, there are holes that you can fall into and you cannot climb out of them.\n\nI'm a foreigner here so I don't really know what's on the other side, but I have heard rumors that certain folk have been cast away via those holes.")
	
	Click()
		set hidden = 1
		set src in oview(1)
		// Validate distance BEFORE showing menu
		if (!(src in range(1, usr)))
			usr << "You're too far away!"
			return
		
		// NEW: Show HUD-based interaction menu
		var/datum/NPC_Interaction/menu = new(src, usr)
		menu.Show()
	
	New()
		.=..()
		spawn(60)
			NPCWander(Speed)
	
	proc/NPCWander(Speed)
		var/mob/players/P
		while(src)
			for(P in oview(src))
				break
			sleep(Speed)
			step_rand(src)
		spawn(260)
			NPCWander(Speed)


// ============================================================================
// EXAMPLE 2: BELIEF > TRAVELER (Complex with teaching mechanic)
// ============================================================================

/mob/npc/BeliefTraveler
	name = "Traveler"
	density = 1
	icon = 'dmi/64/npcs.dmi'
	icon_state = "adv"
	var/Speed = 13
	
	proc/GetInteractionOptions()
		/**
		 * This NPC has multiple options including teaching recipes
		 */
		return list(
			new /datum/npc_interaction_option("Ask About Work", "work"),
			new /datum/npc_interaction_option("Learn Recipes", "teach"),
			new /datum/npc_interaction_option("Leave", "leave")
		)
	
	proc/Interact_work(mob/players/M, datum/NPC_Interaction/session)
		session.SetResponse("I go back and forth between these two principalities, trading and offering my services.\n\nI've carved planks for house building, cut stone for walls, gathered food and spice. I've also distributed random goods like Hand Made Blankets to the masses.")
	
	proc/Interact_teach(mob/players/M, datum/NPC_Interaction/session)
		/**
		 * Teaching recipes requires opening a separate dialog
		 * For complex interactions, close HUD and handle separately
		 */
		session.Close()  // Close the HUD
		TravelerRecipeDialogUnified(M, src)  // Call existing teaching system
	
	Click()
		set hidden = 1
		set src in oview(1)
		if (!(src in range(1, usr)))
			usr << "You're too far away!"
			return
		
		var/datum/NPC_Interaction/menu = new(src, usr)
		menu.Show()
	
	New()
		.=..()
		spawn(60)
			NPCWander(Speed)
	
	proc/NPCWander(Speed)
		var/mob/players/P
		while(src)
			for(P in oview(src))
				break
			sleep(Speed)
			step_rand(src)
		spawn(260)
			NPCWander(Speed)


// ============================================================================
// EXAMPLE 3: HONOR > ELDER (Teaching + Multiple Dialogue Branches)
// ============================================================================

/mob/npc/HonorElder
	name = "Elder"
	density = 1
	icon = 'dmi/64/npcs.dmi'
	icon_state = "adv"
	var/Speed = 13
	
	proc/GetInteractionOptions()
		return list(
			new /datum/npc_interaction_option("Ask About Your Journey", "journey"),
			new /datum/npc_interaction_option("Ask About Your Age", "age"),
			new /datum/npc_interaction_option("Learn Recipes", "teach"),
			new /datum/npc_interaction_option("Leave", "leave")
		)
	
	proc/Interact_journey(mob/players/M, datum/NPC_Interaction/session)
		session.SetResponse("You are a survivor are you not? You've made it this far and I've seen many days pass where not a single soul has arrived to these steps.")
	
	proc/Interact_age(mob/players/M, datum/NPC_Interaction/session)
		session.SetResponse("Yes, compared to me you are young as I am an Elder. But it is not an insult; rather just a compliment or even envy of your remaining days over mine.")
	
	proc/Interact_teach(mob/players/M, datum/NPC_Interaction/session)
		session.Close()
		ElderRecipeDialogUnified(M, src)
	
	Click()
		set hidden = 1
		set src in oview(1)
		if (!(src in range(1, usr)))
			usr << "You're too far away!"
			return
		
		var/datum/NPC_Interaction/menu = new(src, usr)
		menu.Show()
	
	New()
		.=..()
		spawn(60)
			NPCWander(Speed)
	
	proc/NPCWander(Speed)
		var/mob/players/P
		while(src)
			for(P in oview(src))
				break
			sleep(Speed)
			step_rand(src)
		spawn(260)
			NPCWander(Speed)


// ============================================================================
// CONVERSION PATTERN & GUIDELINES
// ============================================================================

/**
 * TO CONVERT AN NPC FROM OLD SYSTEM TO NEW:
 * 
 * 1. REMOVE the old Click() proc entirely (or keep it for now, just call new system)
 * 
 * 2. ADD GetInteractionOptions() proc:
 *    - Returns list of /datum/npc_interaction_option objects
 *    - Each option is (title, action_id, stay_open=1)
 * 
 * 3. ADD Interact_[action] procs:
 *    - One proc per interaction option
 *    - Takes (mob/players/M, datum/NPC_Interaction/session) parameters
 *    - Call session.SetResponse(text) to display response
 *    - Call session.Close() for final responses
 * 
 * 4. UPDATE Click():
 *    - Keep distance validation
 *    - Replace input/alert calls with:
 *      var/datum/NPC_Interaction/menu = new(src, usr)
 *      menu.Show()
 * 
 * EXAMPLE CONVERSION (Before → After):
 * 
 * OLD CODE:
 * --------
 * Click()
 *     if (!(src in range(1, usr))) return
 *     var/K = input("Hello!", "Title") in list("Opt1", "Opt2")
 *     switch(K)
 *         if("Opt1") alert("Response1")
 *         if("Opt2") alert("Response2")
 * 
 * NEW CODE:
 * --------
 * proc/GetInteractionOptions()
 *     return list(
 *         new /datum/npc_interaction_option("Opt1", "opt1"),
 *         new /datum/npc_interaction_option("Opt2", "opt2")
 *     )
 * 
 * proc/Interact_opt1(M, session)
 *     session.SetResponse("Response1")
 * 
 * proc/Interact_opt2(M, session)
 *     session.SetResponse("Response2")
 * 
 * Click()
 *     if (!(src in range(1, usr)))
 *         usr << "Too far away!"
 *         return
 *     var/datum/NPC_Interaction/menu = new(src, usr)
 *     menu.Show()
 * 
 * BENEFITS:
 * - No input dialogs (non-blocking)
 * - Keyboard accessible (/npc_respond 1, /npc_respond 2)
 * - Consistent across all NPCs
 * - Easy to extend with new options
 * - Mobile friendly
 */
