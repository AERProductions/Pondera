// SkillLevelUpIntegration.dm - Skill System Recipe Unlock Hooks
// Integrates skill-based recipe discovery into existing skill level-up systems

// ============================================================================
// BUILDING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnBuildingLevelUp(mob/players/player, new_level)
	// Called when player's building rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "building", new_level)

// ============================================================================
// MINING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnMiningLevelUp(mob/players/player, new_level)
	// Called when player's mining rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "mining", new_level)

// ============================================================================
// HARVESTING/WOODCUTTING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnHarvestingLevelUp(mob/players/player, new_level)
	// Called when player's harvesting/woodcutting rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "harvesting", new_level)

// ============================================================================
// SMITHING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnSmithingLevelUp(mob/players/player, new_level)
	// Called when player's smithing rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "smithing", new_level)

// ============================================================================
// SMELTING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnSmeltingLevelUp(mob/players/player, new_level)
	// Called when player's smelting rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "smelting", new_level)

// ============================================================================
// GARDENING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnGardeningLevelUp(mob/players/player, new_level)
	// Called when player's gardening rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "gardening", new_level)

// ============================================================================
// FISHING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnFishingLevelUp(mob/players/player, new_level)
	// Called when player's fishing rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "fishing", new_level)

// ============================================================================
// CRAFTING SKILL LEVEL UP HOOK
// ============================================================================

/proc/OnCraftingLevelUp(mob/players/player, new_level)
	// Called when player's crafting rank increases
	if(!player || !player.character) return
	
	CheckAndUnlockRecipeBySkill(player, "crafting", new_level)

// ============================================================================
// INTEGRATION INSTRUCTIONS
// ============================================================================

/*
To integrate these hooks into existing skill level-up code:

1. BUILDING (in jb.dm buildlevel() proc):
   When: M.brank += 1
   Add: OnBuildingLevelUp(M, M.brank)
   
   Example:
   if((M.brank == 1)&&(M.buildexp >= 100))
       M.brank += 1
       M.mbuildexp = 150
       OnBuildingLevelUp(M, M.brank)  // ADD THIS LINE
       M << "<b><font color=yellow>You've grown to understand more..."
   
2. MINING (in mining.dm MNLvl() proc):
   When: mrank += 1
   Add: OnMiningLevelUp(src, mrank)
   
   Example:
   if(mrankEXP>=mrankMAXEXP)
       mrankMAXEXP+=exp2lvl(mrank)
       mrank++
       OnMiningLevelUp(src, mrank)  // ADD THIS LINE
       src << "<font color=gold>You gain Mining Acuity!</font>"
   
3. HARVESTING (in WC.dm WCLvl() and related procs):
   When: hrank += 1
   Add: OnHarvestingLevelUp(src, hrank)
   
   Example:
   if(hrankEXP>=hrankMAXEXP)
       hrankMAXEXP+=exp2lvl(hrank)
       hrank++
       OnHarvestingLevelUp(src, hrank)  // ADD THIS LINE
       src << "<font color=gold>You gain Harvesting Acuity!</font>"
   
4. SMITHING (in jb.dm or similar):
   When: smirank += 1
   Add: OnSmithingLevelUp(M, M.smirank)
   
5. SMELTING (in jb.dm or similar):
   When: smerank += 1
   Add: OnSmeltingLevelUp(M, M.smerank)
   
6. GARDENING (in plant.dm GNLvl() proc):
   When: grank += 1
   Add: OnGardeningLevelUp(src, grank)
   
   Example:
   if(grankEXP >= grankMAXEXP)
       grankEXP = 0
       grank++
       OnGardeningLevelUp(usr, usr.grank)  // ADD THIS LINE
       usr << "<font color=green>You gain Gardening Acuity!</font>"
   
7. FISHING (in FishingSystem.dm or similar):
   When: frank += 1
   Add: OnFishingLevelUp(M, M.frank)
   
8. CRAFTING (in WC.dm or jb.dm):
   When: crank += 1
   Add: OnCraftingLevelUp(src, crank)
*/

// ============================================================================
// SYSTEM INITIALIZATION
// ============================================================================

/proc/InitializeSkillLevelUpIntegration()
	world << "SKILLHOOK Skill Level-Up Integration Initialized - Recipe hooks ready"
