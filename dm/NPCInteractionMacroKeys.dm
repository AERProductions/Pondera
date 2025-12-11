// NPC INTERACTION MACRO KEYS - Phase 0.5b
// Binds K, L, and Shift+K to NPC interaction functions via verb/macro system
// ============================================================================

/**
 * NPC_Greet() - Macro key handler for greeting NPC (K key)
 * Called when player presses K with targeted NPC
 */
/mob/players/proc/NPC_Greet()
	var/mob/npcs/target = GetTargetNPC()
	if(!target)
		src << "<span class='warning'>No NPC targeted. Click on an NPC to target it.</span>"
		return
	
	// Call the greeting proc from NPCCharacterIntegration.dm
	target.GreetPlayer(src)


/**
 * NPC_LearnRecipes() - Macro key handler for learning recipes (L key)
 * Called when player presses L with targeted NPC
 */
/mob/players/proc/NPC_LearnRecipes()
	var/mob/npcs/target = GetTargetNPC()
	if(!target)
		src << "<span class='warning'>No NPC targeted. Click on an NPC to target it.</span>"
		return
	
	// Call the recipe teaching proc from NPCCharacterIntegration.dm
	target.ShowRecipeTeachingHUD(src)


// ============================================================================
// VERB DEFINITIONS - Provide macro key bindings via /mob/players/verb
// ============================================================================

/**
 * npc_greet_verb - K key binding for greeting targeted NPC
 */
/mob/players/verb/npc_greet_verb()
	set name = "NPC Greet"
	set desc = "Greet your targeted NPC (K)"
	set hidden = 1  // Hidden from verb menu, only accessible via macro
	
	NPC_Greet()


/**
 * npc_learn_verb - L key binding for learning recipes from targeted NPC
 */
/mob/players/verb/npc_learn_verb()
	set name = "NPC Learn"
	set desc = "Learn recipes from your targeted NPC (L)"
	set hidden = 1
	
	NPC_LearnRecipes()


/**
 * npc_untarget_verb - Shift+K binding for clearing NPC target
 */
/mob/players/verb/npc_untarget_verb()
	set name = "NPC Untarget"
	set desc = "Clear your NPC target (Shift+K)"
	set hidden = 1
	
	ClearTargetNPC()


// ============================================================================
// INTEGRATION: Macro key bindings
// These need to be added to player macro setup during login
// The bindings will be:
// - K = npc_greet_verb
// - L = npc_learn_verb
// - Shift+K = npc_untarget_verb
//
// NOTE: BYOND macro binding is typically done in .dme via #include directive
// or via client.macro_set assignment. For now, rely on players manually
// binding these verbs to their preferred keys via DMF or macro files.
// ============================================================================

