# Phase 38 Quick Reference: NPC Routines

## TL;DR

Phase 38 adds 24-hour daily schedules to NPCs. NPCs wake, work, sleep, and socialize on predictable schedules synced with game time from Phase 36.

## NPC Types (At a Glance)

| Type | Hours | Sleep | Personality |
|------|-------|-------|-------------|
| **Blacksmith** | 7 AM - 6 PM | 10 PM - 6 AM | Early worker |
| **Merchant** | 8 AM - 8 PM | 11 PM - 7 AM | Late nights |
| **Herbalist** | 9 AM - 5 PM | 9 PM - 7 AM | Early riser |
| **Innkeeper** | 5 AM - 11 PM | 2 AM - 5 AM | Night owl |
| **Fisher** | 6 AM - 3 PM | 8 PM - 5 AM | Morning person |
| **Baker** | 5 AM - 7 PM | 9 PM - 4 AM | Very early riser |

## Core APIs

### Register an NPC
```dm
RegisterNPCRoutine(npc_mob, "blacksmith")  // Adds daily schedule
```

### Check NPC Availability
```dm
if(CanTalkToNPC(npc))          // True if awake
if(CanBuyFromNPC(npc))         // True if shop open (Phase 38B)
```

### Manually Test
```dm
/ViewNPCRoutineStatus          // See all NPC states
/SimulateNPCRoutineUpdate      // Force state check
/TestNPCDialogue               // See time/season dialogue
/AdvanceGameTime               // Skip ahead (from Phase 36)
```

## File Changes

1. **NPCRoutineSystem.dm** (479 lines) - NEW
   - Created with 6 NPC type definitions, state machine, routines

2. **Pondera.dme** (line 157)
   - Added: `#include "dm\NPCRoutineSystem.dm"` after npcs.dm

3. **TimeAdvancementSystem.dm** (line 168)
   - Modified: OnHourChange() now calls `OnHourlyNPCCheck()`

4. **InitializationManager.dm** (Phase 5, T+355)
   - Added: `spawn(355) InitializeNPCRoutineSystem()`

## NPC States

| State | Example | Duration |
|-------|---------|----------|
| WANDERING | Walking around | Default |
| WORKING | At shop/work | 7 AM - 6 PM |
| SLEEPING | In bed | 10 PM - 6 AM |
| EATING | Having meal | ~2.5 sec |
| SOCIALIZING | Chatting | Variable |
| IDLE | Waiting | Variable |

## Time Integration

- **Phase 36** provides: 15 min/tick, Hebrew calendar, 4 seasons
- **Phase 38** uses: Hourly callbacks from Phase 36 to update NPC states
- **Sync**: Game hour changes → OnHourlyNPCCheck() → All NPC routines update

## What's Next?

**Phase 38A**: NPC combat affected by weather  
**Phase 38B**: Shop hours gate NPC interactions  
**Phase 38C**: NPC dialogue tied to routine state  
**Phase 39**: NPC events, relationships, quests

## Build Status

✅ **Clean Build**: 0 errors, 0 warnings  
✅ **Integration**: All 3 systems connected  
✅ **Testing**: Debug verbs available  

Last built: 12/9/25 7:56 PM
