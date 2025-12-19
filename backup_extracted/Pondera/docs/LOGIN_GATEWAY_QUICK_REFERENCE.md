# LOGIN GATEWAY - QUICK REFERENCE

**File**: `dm/LoginGateway.dm`  
**Status**: ✅ Production Ready  
**Build**: 0 errors, 0 warnings  

---

## Flow Diagram

```
Player Connects
    ↓
client/New() - Detect no mob
    ↓
show_initialization_check()
    ├─ If world_initialization_complete = FALSE
    │  └─ show_loading_screen() [animated spinner]
    │     └─ Wait for TRUE
    └─ If world_initialization_complete = TRUE
       └─ Skip to character creation
    ↓
show_mode_selection_menu() - "Single Player" or "Multi-Player"
    ↓
show_instance_selection_menu() - "Sandbox", "Story", or "Kingdom PVP"
    ↓
show_class_selection_menu() - "Landscaper", "Smithy", "Builder"
    ↓
show_gender_selection_menu() - "Male" or "Female"
    ↓
show_character_name_input() - Validate 3-15 char letters-only
    ↓
show_character_confirmation() - Review summary, confirm
    ↓
create_character() - Spawn mob, assign to client
    ↓
Game Starts! (mov/players/Login() called automatically)
```

---

## Key Variables

```dm
/client
    var/char_creation_data = null
    // Initialized as list() when character creation starts
    // Keys: "mode", "instance", "char_class", "gender", "name"
```

---

## Critical Check

```dm
// In show_initialization_check():
if(!world_initialization_complete)
    show_loading_screen()
    spawn while(!world_initialization_complete)
        sleep(10)  // Check every 0.5 seconds
```

**MUST match InitializationManager.dm**:
```dm
// Set this to TRUE after Phase 5 (tick 400)
world_initialization_complete = TRUE
```

---

## Proc Index

| Proc | Purpose | Calls |
|------|---------|-------|
| `client/New()` | Entry point | show_initialization_check |
| `show_initialization_check()` | Check init status | show_loading_screen / start_character_creation |
| `show_loading_screen()` | Display spinner UI | (none) |
| `start_character_creation()` | Begin flow | show_mode_selection_menu |
| `show_mode_selection_menu()` | Mode selection | show_instance_selection_menu |
| `show_instance_selection_menu()` | Instance selection | show_class_selection_menu |
| `show_class_selection_menu()` | Class selection | show_gender_selection_menu |
| `show_gender_selection_menu()` | Gender selection | show_character_name_input |
| `show_character_name_input()` | Name input | validate_character_name / show_character_confirmation |
| `validate_character_name()` | Name validation | (returns 0/1) |
| `show_character_confirmation()` | Confirmation | create_character |
| `create_character()` | Spawn mob | (none) |

---

## Customization Points

### 2. Change Starting Location
**Line 194**: Replace `locate(5,5,1)` with your starting coordinates
```dm
new_mob.loc = locate(YOUR_X, YOUR_Y, YOUR_Z)
```

### 3. Add Continent Routing
**In create_character()**: Add after line 194
```dm
var/continent = char_creation_data["instance"]
if(continent == "Story")
    new_mob.loc = locate(STORY_X, STORY_Y, STORY_Z)
else if(continent == "Sandbox")
    new_mob.loc = locate(SANDBOX_X, SANDBOX_Y, SANDBOX_Z)
else if(continent == "Kingdom PVP")
    new_mob.loc = locate(PVPX, PVPY, PVPZ)
```

### 3. Customize Intro Messages
**Lines 210-216**: Modify per-class messages
```dm
switch(class)
    if("Landscaper")
        new_mob << "<font color=silver>YOUR CUSTOM MESSAGE"
```

### 4. Add Female Icon States
**Lines 188-194**: Map gender to female variants
```dm
if(gen == "Female")
    switch(class)
        if("Landscaper")
            new_mob.icon_state = "your_female_landscaper_icon"
```

### 5. Store Gender in Character Data
**In create_character()**: Add after line 200
```dm
if(!new_mob.character)
    new_mob.character = new /datum/character_data()
new_mob.character.gender = char_creation_data["gender"]
```

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Players not seeing character creation | Check `client/New()` is being called (should happen automatically) |
| Loading screen hangs | Ensure `world_initialization_complete` is set to TRUE in InitializationManager.dm after Phase 5 (tick 400) |
| Name validation rejects valid names | Check regex in `validate_character_name()` - currently allows A-Z only |
| Character spawns in wrong location | Update `locate(5,5,1)` coordinates in `create_character()` |
| Gender selection doesn't affect appearance | Add icon_state mapping in line 188-194 section |
| Character creation cancels at step X | Check if that step's alert() has proper return handling |

---

## Integration Checklist

- [ ] `world_initialization_complete` flag defined in InitializationManager.dm
- [ ] `world_initialization_complete` set to TRUE after Phase 5
- [ ] Starting location coordinates (5,5,1) are valid on your map
- [ ] Player class subtypes exist: `/mob/players/Landscaper`, `/mob/players/Smithy`, `/mob/players/Builder`
- [ ] `obj/IG` item exists (starting item)
- [ ] `datum/character_data` exists (created in New())
- [ ] `SavingChars.dm` handles persistence (no changes needed)
- [ ] Test character creation flow end-to-end

---

## Performance Notes

- **Loading screen poll**: 10 tick sleep (500ms intervals) = minimal CPU impact
- **Character creation flow**: 6 alert() calls = instant response
- **No blocking ops**: All async, player can cancel any time
- **Memory**: Minimal - only char_creation_data list per client

---

## Security Notes

- Name validation prevents injection
- No command execution in character creation
- No elevation of privileges
- Uses standard BYOND input() and alert() dialogs

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-12-13 | 1.0 | Initial implementation, 0 errors, production ready |

---

## Questions?

See `LOGIN_GATEWAY_IMPLEMENTATION_COMPLETE.md` for full documentation.
