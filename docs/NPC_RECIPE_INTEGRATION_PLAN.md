# NPC System Refactor & Recipe Discovery Integration

**Date**: December 6, 2025  
**Status**: Planning Phase  
**Priority**: HIGH (foundation for crafting pipeline)  
**Estimated Effort**: 12-16 hours across 3 subtasks

---

## Current NPC System Assessment

### Files Involved
- `dm/npcs.dm` (1165 lines) - Main NPC definitions and dialogue
- `dm/Spawn.dm` (500+ lines) - NPC spawner system
- Related: `dm/FishingSystem.dm`, `dm/Enemies.dm`, dialogue scattered throughout

### Current Architecture
```
/mob/npcs
  - Basic dialogue via hardcoded switch statements
  - NPC wandering (NPCWander proc) - basic movement pattern
  - No recipe discovery integration
  - No skill-gated dialogue options
  - No NPC memory/state tracking
  - Dialogue outcomes not linked to player progression
```

### Dialogue System Analysis

**Current Pattern** (from npcs.dm):
```dm
switch(M.key)
  if("MasterTrader")
    M << "Welcome adventurer!"  // Static message, no recipe award
    // Dialogue continues but doesn't trigger recipe discovery
```

**Issues**:
1. No recipe discovery on dialogue completion
2. No skill-level gating (all NPCs same dialogue for all players)
3. No dialogue memory (repeats same info every interaction)
4. No XP reward tracking
5. NPC state not saved (should persist who you've talked to)

---

## Objective: NPC-Driven Recipe Discovery

### Goal
Enable NPCs to teach recipes through dialogue interactions, respecting skill gates and player progression.

### Design Pattern

```dm
// When NPC dialogue completes with recipe outcome:

if(M.character && M.character.recipe_state)
  // Check if player has prerequisite skills
  if(M.character.recipe_state.skill_smithing >= 2)
    // Player meets requirements
    M.character.recipe_state.DiscoverRecipe("iron_hammer")
    M << "<font color=lime>You learned to craft: Iron Hammer"
    M.character.recipe_state.AddExperience("smithing", 50)
  else
    // Player lacks skills
    npc << "You're not ready to learn this yet. Improve your smithing."
```

---

## Subtask 1: NPC Knowledge Datum (4-5 hours)

### Create `dm/NPCState.dm`

**Purpose**: Track NPC-specific dialogue state and player interaction history

```dm
datum/npc_state
  var
    // === NPC IDENTITY ===
    npc_name                    // "Master Trader", "Blacksmith", etc.
    npc_type                    // Classifier for NPC category
    
    // === DIALOGUE RECIPES ===
    // Which recipes this NPC teaches (list of recipe names)
    var/list/teaches_recipes = list()
    
    // === DIALOGUE GATES ===
    // Skill requirements per recipe
    var/teaches_recipe_prereq[]/skill_name = 0  // e.g. "iron_hammer" -> 2
    
    // === PLAYER INTERACTION TRACKING ===
    var/list/players_talked_to = list()        // Players who've conversed
    var/players_recipes_learned[]/key = list() // Track per-player discoveries
    
    // === DIALOGUE OPTIONS ===
    // Linked to recipe discovery outcomes
    var/list/dialogue_branches = list()
    
    proc/InitializeNPC(name, type)
      npc_name = name
      npc_type = type
      teaches_recipes = list()
      players_talked_to = list()
    
    proc/RegisterRecipe(recipe_name, skill_gate=0)
      teaches_recipes += recipe_name
      teaches_recipe_prereq[recipe_name] = skill_gate
    
    proc/TeachRecipe(mob/players/player, recipe_name)
      if(!player.character) return FALSE
      if(!player.character.recipe_state) return FALSE
      
      var/req_skill = teaches_recipe_prereq[recipe_name]
      // Check skill gate
      if(req_skill > 0)  // TODO: determine which skill applies
        // Handle gating
      
      player.character.recipe_state.DiscoverRecipe(recipe_name)
      player << "<font color=lime>Learned: [recipe_name]"
      return TRUE
    
    proc/CanTeach(mob/players/player, recipe_name)
      if(!player.character) return FALSE
      if(!teaches_recipe_prereq[recipe_name]) return TRUE
      // Implement skill check based on recipe category
      return TRUE  // TODO
```

**Integration Point**: Create instance per NPC, populate during NPC mob creation

---

## Subtask 2: NPC Dialogue System Enhancement (5-6 hours)

### Refactor `dm/npcs.dm` Dialogue

**Current**: Hardcoded switch statements, no recipe integration

**Target**: Skill-gated dialogue with recipe discovery outcomes

**Pattern**:
```dm
mob/npcs/blacksmith/Topic(href, href_list)
  var/mob/players/M = usr
  
  // Handle dialogue option selection
  switch(href_list["choice"])
    if("learn_iron_hammer")
      // Check skill level
      if(M.character && M.character.recipe_state)
        if(M.character.recipe_state.skill_smithing >= 2)
          // Teach recipe
          src.knowledge_state.TeachRecipe(M, "iron_hammer")
          M << "Master Blacksmith: Strike while iron is hot..."
        else
          M << "Master Blacksmith: Return when you understand ore better."
```

### Key Changes
1. Add NPC instances of `npc_state` datum
2. Link dialogue menu options to recipe discovery
3. Gate options based on `recipe_state.skill_*` levels
4. Award XP on successful recipe discovery
5. Track which players have learned which recipes

---

## Subtask 3: NPC-to-Crafting System Link (3-5 hours)

### Enable Recipe-to-Crafting Workflow

**Flow**:
```
NPC teaches recipe
  ↓
recipe_state.DiscoverRecipe() called
  ↓
Recipe becomes available in crafting UI
  ↓
Player attempts craft
  ↓
Crafting system checks IsRecipeDiscovered()
  ↓
Allow craft if discovered + materials available
```

### Required Changes
1. **Crafting UI** (`dm/CustomUI.dm` or new `dm/CraftingUI.dm`)
   - Display only discovered recipes
   - Show material requirements
   - Show XP rewards

2. **Crafting Verification** (add to relevant procs)
   - Before allowing craft: `if(!player.character.recipe_state.IsRecipeDiscovered(recipe))`
   - Award XP after successful craft: `player.character.recipe_state.AddExperience(type, amount)`

3. **Recipe Requirements Definition**
   - Create `/proc/GetRecipeRequirements(recipe_name)` 
   - Returns: materials_needed[], stamina_cost, XP_reward

---

## Implementation Order

### Phase 1 (Week 1)
1. Create NPCState.dm datum (4-5 hours)
2. Test datum serialization/validation
3. Commit & document

### Phase 2 (Week 2)
1. Refactor npcs.dm dialogue system (5-6 hours)
2. Link recipes to NPC dialogue outcomes
3. Implement skill gating
4. Test NPC → recipe discovery flow
5. Commit & document

### Phase 3 (Week 3)
1. Build crafting UI integration (3-5 hours)
2. Link recipe discovery to crafting system
3. Implement recipe verification checks
4. End-to-end testing
5. Commit & document

---

## Design Decisions

### NPC Knowledge Persistence
**Option A**: Serialize NPCState with each NPC (new/npcs/instance_id.sav)
- ✅ Per-instance tracking, scalable to many NPCs
- ❌ Separate savefile per NPC instance

**Option B**: Track in PlayerState only (which recipes player learned from which NPC)
- ✅ Single savefile per player
- ❌ Doesn't track which NPC taught what (NPC-centric view)

**Decision**: Option A with lazy-loading (only save NPCs that have player interaction history)

### Dialogue Gating Strategy
**Option A**: Hard gates (player cannot see option if skill too low)
- ✅ Clean, prevents invalid selections
- ❌ Confusing (missing dialogue options with no explanation)

**Option B**: Soft gates (option visible but fails with explanation)
- ✅ Player understands why they can't learn yet
- ❌ More complex UI

**Decision**: Option B (soft gates) - better UX

### Recipe XP Awards
- Basic recipes (stone hammer, carving knife): 25-50 XP
- Intermediate recipes (iron tools): 75-100 XP
- Advanced recipes (steel tools, forge/anvil): 150-200 XP
- Skill threshold for next rank: 500 XP (variable per rank)

---

## Testing Strategy

### Unit Tests
1. NPCState.DiscoverRecipe() - verify flag set
2. NPCState.TeachRecipe() - verify skill gate logic
3. recipe_state.AddExperience() - verify XP added
4. recipe_state.IsRecipeDiscovered() - verify flag check

### Integration Tests
1. NPC dialogue → recipe discovery flow
2. Skill gate blocks/allows recipe discovery
3. Recipe discovery → crafting UI update
4. Crafting system respects IsRecipeDiscovered()
5. Save/load cycle preserves recipe state & NPC state

### Manual Tests
1. Talk to NPC, learn recipe, restart server, verify recipe persists
2. Try to learn recipe with insufficient skill, verify soft gate
3. Gain skill ranks, re-talk to NPC, recipe now teachable
4. Learn recipe, try crafting, verify UI shows recipe

---

## Risk Assessment

### Technical Risks
1. **Dialogue system complexity**: Many dialogue branches could become unmaintainable
   - **Mitigation**: Use data-driven recipe tables, not hardcoded switches

2. **NPC state serialization**: Serializing complex NPC instances
   - **Mitigation**: Use simple datum structure, leverage BYOND savefile system

3. **Skill gate edge cases**: Off-by-one errors in skill comparisons
   - **Mitigation**: Comprehensive unit test coverage

### Design Risks
1. **Dialogue not intuitive**: Players don't understand how to learn recipes
   - **Mitigation**: Clear UI feedback, tutorial dialogue

2. **NPC recipes become bottleneck**: Players need specific NPC to progress
   - **Mitigation**: Multiple NPCs teach same recipe, or fallback discovery methods

---

## Next Phase Kickoff

When ready to start Subtask 1, will need:
- [ ] Code review of persistent pipeline (phases 1-4)
- [ ] Approval of NPC design pattern
- [ ] Decision on dialogue gating (soft vs hard)
- [ ] Approval of XP award values

Current build status: ✅ **CLEAN** (ready for NPC work)
