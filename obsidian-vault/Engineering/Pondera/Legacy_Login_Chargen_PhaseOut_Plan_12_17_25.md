# Legacy Login & CharGen System Phase-Out Plan

**Date**: December 17, 2025  
**Target**: Replace alert-based UI with HudGroups-based modern system  
**Timeline**: 2-3 weeks  
**Status**: Ready to plan

## Current Legacy Systems

### 1. **CharacterCreationUI.dm** (ALERT-BASED - REMOVE)
- **Issue**: Uses old BYOND `alert()` function
- **Status**: Removed from .dme but file still exists
- **Location**: `dm/CharacterCreationUI.dm`
- **Issue #1**: Alert boxes are not user-friendly
- **Issue #2**: Can't style or customize
- **Issue #3**: Blocks gameplay until dismissed

### 2. **CharacterCreationGUI.dm** (SCREEN-BASED - KEEP & REFACTOR)
- **Status**: Currently active in .dme
- **Type**: /obj/ChargenHud/... (screen objects)
- **Location**: `dm/CharacterCreationGUI.dm`
- **Advantage**: Better than alerts, screen-based
- **Issue**: Not using HudGroups (separate system)
- **Plan**: Rewrite using HudGroups for consistency

### 3. **LoginGateway.dm** (INITIALIZATION - KEEP)
- **Status**: Active, handles login gating
- **Location**: `dm/LoginGateway.dm`
- **Role**: Create player character on first login
- **Plan**: Update to use new HudGroups-based chargen

### 4. **Basics.dm** - `/mob/players/Login()`
- **Status**: Active, sets up player
- **Location**: `dm/Basics.dm` line ~2021
- **Role**: Initialize player on login
- **Plan**: No changes needed, works with new chargen

## What Needs to Change

### Phase 1: Create Modern CharGen UI (Days 1-2)

#### New File: `dm/ChargenHudGroups.dm`
```dm
/proc/CreateCharacterCreationUI(client/C)
    // Create HudGroup-based UI
    var/HudGroup/chargen_group = new()
    
    // Form elements (from interface-demo pattern)
    chargen_group.add(/ChargenLabel, "title", text="Create Character")
    chargen_group.add(/ChargenInput, "name_input", max_length=20)
    chargen_group.add(/ChargenOptionGroup, "class_select", list_of_classes)
    chargen_group.add(/ChargenOptionGroup, "gender_select", list("Male", "Female"))
    chargen_group.add(/ChargenButton, "submit", "Create Character")
    chargen_group.add(/ChargenButton, "cancel", "Cancel")
    
    // Handle form submission
    chargen_group.on_submit = /proc/OnChargenSubmit
    chargen_group.on_cancel = /proc/OnChargenCancel
    
    return chargen_group
```

#### UI Components Needed
| Component | Purpose | Based On |
|-----------|---------|----------|
| ChargenLabel | Display text | interface-demo label.dm |
| ChargenInput | Character name | interface-demo input.dm |
| ChargenOptionGroup | Class/Gender selection | interface-demo option-group.dm |
| ChargenButton | Submit/Cancel actions | interface-demo demo-form.dm |

### Phase 2: Update LoginGateway (Days 2-3)

#### Current Flow
```
1. Player connects
2. LoginGateway.start_character_creation() called
3. Show CharacterCreationGUI screen objects
4. Wait for user interaction
5. Create character on selection
```

#### New Flow
```
1. Player connects
2. LoginGateway.start_character_creation() called
3. Call CreateCharacterCreationUI(client)
4. HudGroup displayed to client
5. Client fills form and submits
6. OnChargenSubmit() creates character
7. ChargenHudGroup hidden/removed
8. Character login proceeds
```

#### Code Changes in LoginGateway.dm
**Before**:
```dm
// Old way - direct GUI
var/obj/screen/chargen = new /obj/ChargenHud(client)
client.screen += chargen
```

**After**:
```dm
// New way - HudGroups
var/HudGroup/chargen_ui = CreateCharacterCreationUI(client)
chargen_ui.show_to(client)
```

### Phase 3: Remove Alert-Based UI (Days 3-4)

#### File: `dm/CharacterCreationUI.dm`
**Action**: DELETE (entirely unused)
- Already removed from .dme
- No dependencies
- Alert-based approach obsolete

#### Verification
```dm
// Before deletion, verify no references:
grep -r "CharacterCreationUI" *.dm
grep -r "alert(" dm/*.dm | grep -v "//.*alert"
```

### Phase 4: Clean Up Old GUI Files (Days 4-5)

#### Files to Refactor
1. **CharacterCreationGUI.dm** - Rewrite using HudGroups
2. **Interfacemini.dmf** - May need updates for fonts/assets

#### Files to Keep (No Changes)
- LoginGateway.dm (update calls)
- Basics.dm (player initialization)
- InitializationManager.dm (boot sequence)

### Phase 5: Integration & Testing (Days 5-6)

#### Test Checklist
- [ ] HudGroups library compiles cleanly
- [ ] Character creation UI appears on login
- [ ] Can input character name
- [ ] Can select class/gender
- [ ] Submit creates character correctly
- [ ] Cancel returns to login
- [ ] Character data persists (SQLite)
- [ ] Multiple characters can be created
- [ ] Build stays at 0 errors

#### Regression Testing
- [ ] Existing characters can still log in
- [ ] Existing HUD system still works
- [ ] No performance degradation
- [ ] No memory leaks with UI objects

## Implementation Sequence

### Step 1: Copy HudGroups to Pondera
```
Copy: lib/forum_account/hudgroups/hud-groups.dm → dm/HudGroups.dm
Copy: lib/forum_account/hudgroups/fonts.dm → dm/HudGroupsFonts.dm
Copy: All needed demos to reference
Add to .dme: Before LoginGateway.dm
```

### Step 2: Create Wrapper Classes
```dm
// dm/ChargenHudGroups.dm
/proc/CreateCharacterCreationUI(client/C)
    // ...see above
```

### Step 3: Update LoginGateway
```dm
// Update start_character_creation() in LoginGateway.dm
start_character_creation()
    var/HudGroup/ui = CreateCharacterCreationUI(src.client)
    ui.show_to(src.client)
```

### Step 4: Test Build
```
- Compile with new files
- Verify 0 errors
- Launch test server
- Test complete login → chargen → character flow
```

### Step 5: Commit Changes
```
git add dm/HudGroups.dm dm/HudGroupsFonts.dm dm/ChargenHudGroups.dm
git commit -m "feat: Replace alert-based chargen with HudGroups modern UI"
```

## Benefits of Migration

| Aspect | Old System | New System |
|--------|-----------|-----------|
| **User Experience** | Alert boxes | Modern HUD UI |
| **Customization** | None | Full styling control |
| **Accessibility** | Limited | Keyboard navigation |
| **Consistency** | Mixed systems | Unified HudGroups |
| **Maintenance** | Alert code | Well-documented library |
| **Extensibility** | Hard to enhance | Easy to add features |

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|-----------|
| HudGroups doesn't compile | Build breaks | Test demos first |
| UI doesn't match Pondera aesthetic | Poor UX | Custom styling layer |
| Legacy code still referenced | Build fails | Search and remove |
| Performance with UI objects | Slowdown | Profile and optimize |
| SQLite chargen data lost | Data corruption | Backup before changes |

## Timeline

```
Day 1: Audit & Planning ✅ (12/17)
Day 2: Create wrapper UI (12/18)
Day 3: Update LoginGateway (12/19)
Day 4: Remove old files (12/20)
Day 5: Testing & debugging (12/21)
Day 6: Commit & document (12/22)
```

## Success Criteria

- ✅ New UI appears on login screen
- ✅ Character creation works end-to-end
- ✅ No build errors
- ✅ No performance regression
- ✅ Old UI files removed
- ✅ All tests passing
- ✅ Committed to git

---

**Status**: READY TO IMPLEMENT  
**Confidence**: HIGH  
**Effort**: 5-6 days (with daily commits)
