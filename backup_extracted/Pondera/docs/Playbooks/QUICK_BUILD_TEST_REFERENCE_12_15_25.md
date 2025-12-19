# Quick Build & Test Reference - December 15, 2025

## Current Status ✅

**Build**: CLEAN (0 errors, 13 warnings)  
**Binary**: Pondera.dmb ready  
**Time**: 12/15/25 3:28 PM  

---

## To Run the Game

```powershell
cd "c:\Users\ABL\Desktop\Pondera"
& "Pondera.dmb"
```

## What to Expect

### Startup Sequence
1. **Phase 1** (0 ticks): Time system loads
2. **Phase 1B** (5 ticks): Crash recovery
3. **Phase 2** (50 ticks): Infrastructure - **MAP GENERATION STARTS**
4. **Phase 2B** (55 ticks): Lobby portals placed
5. **Phase 3** (100 ticks): Day/night cycles
6. **Phase 4** (300 ticks): Special world systems
7. **Phase 5** (400 ticks): NPC & recipes
8. **✓ READY** (T+400): World initialization complete

### Character Creation Flow
1. Player joins → Spawns in lobby at (10,10,1) on story continent
2. On-screen GUI appears with character creation
3. **Step 1**: Select class (Landscaper/Smithy/Builder)
4. **Step 2**: Select gender (Male/Female)
5. **Step 3**: Enter name (auto-generates currently)
6. **Step 4**: Confirm selections
7. Character created → GUI closes → Player sees map
8. Player clicks portal to select continent

### Portals in Lobby
- **Story Gate** (LEFT): Kingdom of Freedom (story continent)
- **Sandbox Gate** (CENTER): Creative Sandbox (peaceful)
- **PvP Gate** (RIGHT): Battlelands (combat)

---

## What Was Fixed

| Error | Fix | Status |
|-------|-----|--------|
| InitializeLobbyHub "bad loc" | Rewrite lobby spawn logic | ✅ |
| Black screen on login | Place player on map turf | ✅ |
| String + int concatenation | Use maptext interpolation | ✅ |
| Named params in new() | Use property assignment | ✅ |
| AnimationManager crash | Safe variable checking | ✅ |
| Missing CanCraftRecipe | Disabled/stub | ✅ |
| Missing GetRecipesByTier | Disabled/stub | ✅ |

---

## Known Limitations

1. **Name Input**: Currently auto-generated (needs proper input implementation)
2. **Character Appearance**: Based on gender only (no customization)
3. **KnowledgeBase System**: Disabled (named param syntax issue - needs refactoring)
4. **Recipe Discovery**: Disabled (stub functions)

---

## Files to Reference

- **Lobby System**: dm/ContinentLobbyHub.dm (60 lines)
- **Character Creation GUI**: dm/CharacterCreationGUI.dm (289 lines)
- **Portal Routing**: dm/Portals.dm (portal Click handlers)
- **World System**: dm/WorldSystem.dm (continent definitions)
- **Initialization**: dm/InitializationManager.dm (boot phases)

---

## Test Checklist

- [ ] Game starts without errors
- [ ] Player sees lobby map
- [ ] GUI appears on-screen
- [ ] Can click buttons in GUI
- [ ] Character gets created
- [ ] Can see portals in lobby
- [ ] Can click portal
- [ ] Routes to correct continent
- [ ] Player spawns on continent map

---

## Build Command

If you need to rebuild:
```powershell
cd "c:\Users\ABL\Desktop\Pondera"
& "C:\Program Files (x86)\BYOND\bin\dm.exe" Pondera.dme
```

Expected output: `Pondera.dmb - 0 errors, X warnings`

---

## Next Session Tasks

1. **Test in-game** - Verify full lobby→continent flow
2. **Fix KnowledgeBase.dm** - Refactor named params
3. **Implement CanCraftRecipe()** and **GetRecipesByTier()**
4. **Player portal visibility** - Make sure portals render visually
5. **Name input** - Add real text input for character name

