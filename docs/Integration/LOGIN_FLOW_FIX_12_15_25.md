# Login Flow Fix - December 15, 2025 (3:37 PM)

**Status**: ✅ COMPLETE - Build Clean, Ready for Testing

---

## The Problem

Player logged in but:
- Black screen (no map visible)
- No GUI overlay
- No portals to click
- System just initialized but didn't show anything playable

**Root Cause**: **Player mob was never created**. The login gateway system was trying to show dialog-based character creation, but the player had no mob to attach the client to.

---

## Technical Analysis

### What Was Happening

1. Client connects → `client/New()` called
2. `show_initialization_check()` waits for world to initialize
3. `start_character_creation()` called
4. System tried to show `alert()` dialogs
5. **BUT**: No player mob existed yet, so `usr` was null
6. Player saw black screen indefinitely

### Why GUI Didn't Show

For on-screen GUI to render in BYOND:
- Player must be connected to a **mob** (player entity)
- Mob must be on a **valid turf** (map location)
- Client must be assigned to the mob
- THEN screen objects render on top of the map

**In this case**: No mob existed, so no map, so no GUI could show.

---

## The Fix

### 1. Create Player Mob Immediately

```dm
// OLD (WRONG):
/client/New()
    if(!mob)
        show_initialization_check()  // Never creates mob!

// NEW (CORRECT):
/client/proc/start_character_creation()
    // Create a default player mob immediately
    var/mob/players/new_player = new /mob/players/Landscaper()
    new_player.client = src
    src.mob = new_player
    
    // NOW player has a mob to attach to
    spawn(3)
        if(src && src.mob)
            SpawnPlayerInLobby(src.mob)
```

### 2. Connect to Lobby Spawn

```dm
// Calls SpawnPlayerInLobby() which:
// 1. Places player at (10,10,1) - a valid turf on story continent
// 2. Shows welcome messages
// 3. Calls ShowCharacterCreationGUI() after 2-tick delay
```

### 3. Remove Old Dialog System

- Deleted all `alert()` and `input()` calls from LoginGateway
- Removed: `show_mode_selection_menu()`, `show_instance_selection_menu()`, `show_class_selection_menu()`, `show_gender_selection_menu()`, `show_character_name_input()`, `validate_character_name()`, `show_character_confirmation()`, `create_character()`
- Marked as "DEPRECATED - replaced by GUI system"

---

## Flow Now

```
Player connects (client connects)
  ↓
client/New() called
  ↓
start_character_creation()
  ├─ Create mob: new /mob/players/Landscaper()
  ├─ Connect: new_player.client = src
  ├─ Assign: src.mob = new_player
  └─ spawn(3): Call SpawnPlayerInLobby()
  
SpawnPlayerInLobby(mob/players/player)
  ├─ Get turf: locate(10, 10, 1)
  ├─ Place player: player.loc = spawn_turf
  ├─ Send messages
  └─ spawn(2): ShowCharacterCreationGUI(player)
  
ShowCharacterCreationGUI(player)
  ├─ Create /obj/screen/character_creation_gui
  ├─ Add to client.screen
  ├─ Render maptext buttons
  └─ Wait for player clicks
  
Player clicks button
  ↓
OnButtonClick() processes selection
  ↓
[Advance through steps or create character]
```

---

## Files Modified

| File | Changes | Status |
|------|---------|--------|
| dm/LoginGateway.dm | Rewrite client/New(), remove dialogs | ✅ |
| dm/HUDManager.dm | Fix login check to detect new characters | ✅ |

---

## Build Status

```
Pondera.dmb - 0 errors, 13 warnings (12/15/25 3:37 pm)
Build time: 0:01
Status: CLEAN - READY TO RUN
```

---

## Next Test

Run the game with these expected outcomes:

1. ✓ Client connects
2. ✓ Player mob created (Landscaper by default)
3. ✓ Player placed on map at (10,10,1)
4. ✓ On-screen GUI appears (maptext buttons)
5. ✓ Can click buttons to select class/gender/name
6. ✓ Can confirm character
7. ✓ Can click portal to route to continent

---

## Key Lessons

- **BYOND requires**: Player must have mob → mob must be on turf → client attached → GUI renders
- **Login flow**: Create mob first, place on map second, show UI third
- **Dialog vs GUI**: Dialogs (`alert()`) don't work without player already in-game; GUI overlays require player on map

