# Phase 0.5: NPC Interaction System Refactor

## Objective
Refactor NPC interaction from right-click `Click()` dialogs to HUD-based macro key system for consistency and better UX.

## Current State Analysis

### What Works (Phase 9)
- ✅ `/mob/npcs/Click()` right-click handler opens dialogue menu
- ✅ Recipe teaching procs: `GreetPlayer()`, `ShowRecipeTeaching()`, `TeachRecipeToPlayer()`
- ✅ Recipes stored in RECIPES registry and discoverable
- ✅ NPC types determine available recipes

### Problems with Click() Approach
1. **Inconsistent UX**: Click() is unusual for NPC interaction in MMOs; macros/hotkeys are standard
2. **Mobile unfriendly**: Right-click menus don't work well on touch devices
3. **Accessibility**: Players might not discover right-click mechanic
4. **Design inconsistency**: Other systems (crafting, trading) use HUD or explicit verbs
5. **Code duplication**: Similar dialogue logic scattered across multiple Click() handlers

## Refactor Strategy

### Phase 0.5a: Create NPC-Targeting System
**Goal**: Allow players to target NPCs and interact via macro keys

**Implementation**:
1. Add `targeted_npc` variable to `/mob/players`
2. Create `/proc/SetTargetNPC(npc)` proc
3. Create `/proc/ClearTargetNPC()` proc
4. Modify NPC Click() to set target instead of opening menu
5. Add visual feedback (HUD overlay showing targeted NPC)

### Phase 0.5b: Create Macro Key System
**Goal**: Bind interaction functions to macro keys

**Macro Keys**:
- `K` - Greet current target NPC
- `L` - Learn recipe from current target NPC
- `Shift+K` - Cancel NPC target

**Implementation**:
1. Create `/datum/macro/npc_greet` - Calls `GreetTargetNPC()`
2. Create `/datum/macro/npc_learn` - Calls `ShowRecipeTeachingMenu()`
3. Create `/datum/macro/npc_untarget` - Calls `ClearTargetNPC()`
4. Integrate into player login macro setup

### Phase 0.5c: Create NPC HUD Display
**Goal**: Show targeted NPC info on screen

**HUD Elements**:
- Targeted NPC name and type in corner
- List of available recipes/actions
- Distance to NPC (if out of range, show "Too far away")

**Implementation**:
1. Create NPC HUD screen object
2. Update on every tick (check if still in range)
3. Hide if NPC dies or player moves away

### Phase 0.5d: Remove Click()-Based Interaction
**Goal**: Disable old dialogue menu system

**Changes**:
1. Comment out dialogue input() calls in `ShowRecipeTeaching()`
2. Replace with HUD-based selection
3. Keep NPC Click() but only for targeting (no menu)

## File Changes

### New Files
- `dm/NPCTargetingSystem.dm` - NPC targeting procs and player var integration
- `dm/NPCInteractionHUD.dm` - HUD display and macro key handlers
- `dm/NPCMacroKeysIntegration.dm` - Macro key setup and bindings

### Modified Files
- `dm/NPCCharacterIntegration.dm` - Remove Click() menu, keep teaching procs
- `dm/Basics.dm` - Add `targeted_npc` var to `/mob/players`
- `dm/CharacterData.dm` - Add `npc_target_ckey` to persistent data
- `Pondera.dme` - Include new files BEFORE InitializationManager

## Integration Checklist

- [ ] Add `targeted_npc` variable to player
- [ ] Create NPC targeting system
- [ ] Create macro key handlers (K, L, Shift+K)
- [ ] Create NPC HUD display
- [ ] Modify NPC Click() to set target
- [ ] Update recipe teaching to use HUD selection
- [ ] Test: Target NPC → press K → see greeting
- [ ] Test: Target NPC → press L → see recipe menu
- [ ] Test: Press Shift+K → clear target
- [ ] Test: NPCs in different zones work correctly
- [ ] Verify old Click() menu is disabled

## Success Criteria

1. Players can click on NPC to target it
2. Macro keys K and L trigger NPC interactions
3. HUD shows targeted NPC name and available actions
4. Recipe teaching works via macro key (no Click() dialogs)
5. No Click()-based menus appear
6. All 5 warnings in build eliminated (next phase)

## Estimated Work Time
- Phase 0.5a (targeting): 15 min
- Phase 0.5b (macros): 20 min
- Phase 0.5c (HUD): 25 min
- Phase 0.5d (cleanup): 10 min
- Testing: 15 min
- **Total: ~85 minutes**

## Next Phases

After Phase 0.5:
- **Phase 1**: Eliminate 5 unused variable warnings
- **Phase 2**: Review all Click() uses and document which are appropriate
- **Phase 3**: Refactor inappropriate Click() handlers to use HUD/macros
- **Phase 4**: Final testing and documentation
