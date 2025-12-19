# Modern HUD Login System - Implementation Plan

**Date:** December 15, 2025  
**Status:** PLANNING PHASE  
**Priority:** HIGH - Replace legacy alert()/input() dialogs

---

## PROBLEM STATEMENT

The Pondera login flow currently uses legacy BYOND dialogs:
- `alert()` - Modal dialog with buttons (blocks gameplay)
- `input()` - Text input dialog (blocks gameplay)
- These are not modern for a survival MMO with real-time gameplay

**Current Login Flow (All Using Legacy Dialogs)**:
```
Player Login
  ↓
show_mode_selection_menu() → alert("Single/Multi")
  ↓
show_instance_selection_menu() → alert("Sandbox/Story")
  ↓
show_class_selection_menu() → alert("Class Selection")
  ↓
show_gender_selection_menu() → alert("Gender")
  ↓
show_character_name_input() → input("Name") [blocks gameplay]
  ↓
show_character_confirmation() → alert("Confirm")
  ↓
create_character() [character created]
```

---

## SOLUTION: ON-SCREEN HUD MENU SYSTEM

**Goal**: Replace all dialogs with screen-based menu elements that don't block gameplay.

**Technology**: BYOND `obj/screen` system already implemented in `CustomUI.dm`

### Files to Create/Modify

| File | Purpose | Status |
|------|---------|--------|
| `dm/CharacterCreationHUD.dm` | Modern HUD menus | TO CREATE |
| `dm/CharacterCreationUI.dm` | Update to use new HUD | TO MODIFY |
| `dm/HUDManager.dm` | Hook new HUD into login | TO MODIFY |
| `dm/CustomUI.dm` | Extend with menu classes | TO MODIFY |

---

## ARCHITECTURE: HUD MENU SYSTEM

### 1. Base Menu Class (obj/screen/hud_menu)

```dm
/obj/screen/hud_menu
	var/menu_id = 0
	var/title = "Menu"
	var/callback_proc = null
	var/owner = null
	var/list/options = list()
	var/selected_index = 1
	
	proc/render()           // Display menu visually
	proc/on_key(key)        // Handle key input (up/down/enter)
	proc/on_select(choice)  // Execute selection callback
```

### 2. Specific Menu Types

#### a) Button Menu (Multi-choice alert replacement)
```dm
/obj/screen/button_menu
	// Example: "Single Player" vs "Multi-Player"
	// Displays as horizontal buttons
	// Up/Down to navigate, Enter to select
```

#### b) List Menu (Multiple options)
```dm
/obj/screen/list_menu
	// Example: Class selection
	// Displays as vertical list
	// Up/Down to navigate, Enter to select
```

#### c) Text Input Menu (Input() replacement)
```dm
/obj/screen/text_input_menu
	var/input_text = ""
	var/max_length = 15
	var/min_length = 3
	// Character-by-character input
	// Enter to submit, Escape to cancel
```

#### d) Info Panel (Display only)
```dm
/obj/screen/info_panel
	var/content = ""
	// Static display with next/back buttons
```

---

## MODERN LOGIN FLOW

```
Player Connects
  ↓
HUDManager.dm detects login
  ↓
ShowCharacterCreationHUD()
  ↓
[MODE SELECTION HUD]
  Single Player | Multi-Player
  (Player navigates with arrow keys, presses Enter)
  ↓
[INSTANCE SELECTION HUD]
  Sandbox | Story
  ↓
[CLASS SELECTION HUD]
  Landscaper | Smithy | Builder
  (Shows description below each)
  ↓
[GENDER SELECTION HUD]
  Male | Female
  ↓
[NAME INPUT HUD]
  Text input field with validation
  (Shows live character count)
  ↓
[CONFIRMATION PANEL]
  Shows all selections
  "Create" | "Go Back"
  ↓
Character Created
(All non-blocking, player can move around while menus open)
```

---

## HUD MENU INTERACTION MODEL

### Input Handling

**Keyboard**:
- `↑` / `W` - Move selection up
- `↓` / `S` - Move selection down
- `Enter` - Confirm selection
- `Escape` - Cancel / Go back
- `A-Z` / `0-9` - Text input (if text field)
- `Backspace` - Delete character (if text field)

### Visual Design

All menus use:
- **Position**: Centered on screen (screen_loc = "ABSOLUTE")
- **Size**: Scalable (recommend 50% of screen width)
- **Background**: Semi-transparent overlay
- **Colors**: Gold/silver accent colors (Pondera theme)
- **Font**: Maptext rendering (built into BYOND)

### Example UI Layout

```
┌─────────────────────────────────────┐
│       CHARACTER CLASS SELECTION      │
├─────────────────────────────────────┤
│ ► Landscaper - Terraform & farm    │
│   Smithy - Master metalworking     │
│   Builder - Construct structures   │
└─────────────────────────────────────┘
[Arrow keys: Navigate | Enter: Select | Esc: Cancel]
```

---

## IMPLEMENTATION ROADMAP

### Phase 1: Foundation (NEW FILE)
**File**: `dm/CharacterCreationHUD.dm` (500+ lines)

Create base menu classes:
1. `/obj/screen/hud_menu_base` - Abstract base class
2. `/obj/screen/button_menu` - Multi-choice button layout
3. `/obj/screen/list_menu` - Vertical selection list
4. `/obj/screen/text_input_menu` - Text field with validation
5. `/obj/screen/info_panel` - Static info display

### Phase 2: Mode Selection (1/6)
**File**: `dm/CharacterCreationHUD.dm`

Implement first screen:
- `ShowModeSelectionHUD(player)`
- Displays: "Single Player", "Multi-Player"
- Stores selection in `client.char_creation_data["mode"]`
- Advances to next screen on Enter

### Phase 3: Instance Selection (2/6)
**File**: `dm/CharacterCreationHUD.dm`

Implement second screen:
- `ShowInstanceSelectionHUD(player)`
- Displays: "Sandbox", "Story"
- Advances on Enter

### Phase 4: Class Selection (3/6)
**File**: `dm/CharacterCreationHUD.dm`

Implement class menu:
- `ShowClassSelectionHUD(player)`
- Displays: "Landscaper", "Smithy", "Builder"
- **Shows description below** (Landscaper: "Terraform and farm" etc.)
- Advances on Enter

### Phase 5: Gender Selection (4/6)
**File**: `dm/CharacterCreationHUD.dm`

Implement gender menu:
- `ShowGenderSelectionHUD(player)`
- Displays: "Male", "Female"
- Advances on Enter

### Phase 6: Name Input (5/6)
**File**: `dm/CharacterCreationHUD.dm`

Implement text input:
- `ShowNameInputHUD(player)`
- Character-by-character input
- Validates: 3-15 chars, letters only
- Shows validation feedback
- Advances on Enter

### Phase 7: Confirmation (6/6)
**File**: `dm/CharacterCreationHUD.dm`

Implement review screen:
- `ShowConfirmationHUD(player)`
- Displays summary of all choices
- Options: "Create" | "Go Back"
- "Create" → `create_character()`
- "Go Back" → Returns to name input

### Phase 8: Integration (MODIFY)
**Files**: 
- `dm/CharacterCreationUI.dm` - Update to call new HUD procs
- `dm/HUDManager.dm` - Hook into Login() flow
- `dm/CustomUI.dm` - Add menu rendering helpers

---

## KEY DESIGN DECISIONS

### 1. Non-Blocking
- Menus render on `obj/screen` (player can move during menus)
- No `alert()` / `input()` blocking
- Enables immersive login experience

### 2. Keyboard-First
- Arrow keys for navigation
- Enter/Escape for confirm/cancel
- No mouse required (but could add later)

### 3. Validation Feedback
- Real-time character count display
- Error messages displayed inline
- "Go Back" option if validation fails

### 4. Persistent State
- All selections stored in `client.char_creation_data`
- If user cancels/goes back, selections preserved

### 5. Themeable
- Uses Pondera colors (gold/silver accents)
- Font-based UI (maptext) for performance
- Scalable to different screen resolutions

---

## TECHNICAL IMPLEMENTATION DETAILS

### Input Handling Architecture

Each menu registers key handlers:

```dm
/client/proc/handle_hud_key(key)
	// Check if we're currently in a HUD menu
	for(var/obj/screen/hud_menu/menu in screen)
		if(!menu.hidden)
			menu.on_key(key)
			return
```

This is hooked into existing key handler (to be determined).

### Rendering System

All menus use `maptext` for rendering:

```dm
proc/render_menu_frame(title, options, selected)
	var/html = "<div style='width: 400px; border: 2px solid gold;'>"
	html += "<h3 style='text-align: center; color: gold;'>[title]</h3>"
	html += "<hr style='border-color: silver;'>"
	
	for(var/i = 1; i <= options.len; i++)
		var/opt = options[i]
		if(i == selected)
			html += "<div style='background-color: rgba(255,200,0,0.3);'><b>► [opt]</b></div>"
		else
			html += "<div>  [opt]</div>"
	
	html += "</div>"
	return html
```

### State Machine

Login flow uses state machine:

```dm
client/var/login_state = "MODE_SELECTION"  // Current menu
client/var/login_state_stack = list()      // For "Back" navigation
```

---

## DATA FLOW

### Client Variables

```dm
/client/var
	char_creation_data = list(
		"mode" = null,        // "Single Player" or "Multi-Player"
		"instance" = null,    // "Sandbox" or "Story"
		"class" = null,       // "Landscaper", "Smithy", or "Builder"
		"gender" = null,      // "Male" or "Female"
		"name" = null         // Character name
	)
	
	login_hud_current = null  // Current HUD menu object
	login_state = "INITIAL"   // State tracker
```

### Flow Through Procs

```
HUDManager.dm/Login()
  ↓
ShowCharacterCreationHUD(player)
  ↓
ShowModeSelectionHUD(player)
  Creates: obj/screen/list_menu with ["Single", "Multi"]
  Registers: on_select callback → ShowInstanceSelectionHUD()
  ↓
[Player presses Up/Down/Enter]
  ↓
on_key() handles input → on_select() triggers callback
```

---

## ERROR HANDLING & EDGE CASES

### 1. Player Disconnects Mid-Login
- Destroy any open HUD menus
- Don't create character if incomplete

### 2. Name Validation Fails
- Display error message on menu
- Keep menu open, player can retry
- Don't advance to next screen

### 3. Menu State Corrupted
- Always check `login_hud_current` exists
- Fall back to text input dialog if HUD fails
- Log error for debugging

### 4. Player Click/Input Conflicts
- Menu has higher priority than normal input
- Disable movement/combat during critical menus
- Re-enable after character created

---

## FUTURE ENHANCEMENTS

### Phase 2 Features (After Initial Implementation)
- [ ] Mouse support (click menu options)
- [ ] Animations (fade in/out menus)
- [ ] Sound effects (beep on selection)
- [ ] Appearance customization HUD (colors, tattoos)
- [ ] Tutorial tooltips showing game basics
- [ ] "Load Character" menu for returning players

---

## TESTING CHECKLIST

- [ ] Mode selection displays correctly
- [ ] Navigation (up/down) works
- [ ] Enter key selects option
- [ ] Escape key cancels / goes back
- [ ] All 6 screens appear in sequence
- [ ] Character creation succeeds at end
- [ ] Character data saved correctly
- [ ] Player spawns in correct location
- [ ] No blocking/lag during menus
- [ ] Error messages display for invalid input

---

## FILES TO CREATE

### NEW: `dm/CharacterCreationHUD.dm` (Estimated 600+ lines)

**Classes to define**:
```dm
/obj/screen/hud_menu_base
	proc/render()
	proc/on_key(key)
	proc/on_select(choice)

/obj/screen/button_menu (extends hud_menu_base)
	// Multi-choice button display

/obj/screen/list_menu (extends hud_menu_base)
	// Vertical list selection

/obj/screen/text_input_menu (extends hud_menu_base)
	// Text input field

/obj/screen/info_panel (extends hud_menu_base)
	// Static info display

/proc/ShowModeSelectionHUD(mob/players/player)
/proc/ShowInstanceSelectionHUD(mob/players/player)
/proc/ShowClassSelectionHUD(mob/players/player)
/proc/ShowGenderSelectionHUD(mob/players/player)
/proc/ShowNameInputHUD(mob/players/player)
/proc/ShowConfirmationHUD(mob/players/player)
```

---

## FILES TO MODIFY

### 1. `dm/CharacterCreationUI.dm`
- Replace `alert()` calls with new HUD procs
- Remove legacy dialog code
- Keep validation logic
- Update `create_character()` proc if needed

### 2. `dm/HUDManager.dm`
- Add call to `ShowCharacterCreationHUD()` in `Login()`
- Should be called AFTER world initialization gates
- Pass `src` (player mob) to HUD proc

### 3. `dm/CustomUI.dm`
- Add helper procs for menu rendering
- Add key input handler registration
- Add client UI tracking for HUD menus

### 4. `Pondera.dme`
- Add `#include "dm/CharacterCreationHUD.dm"` (NEW FILE)
- Should be placed BEFORE MapGen and InitializationManager

---

## NOTES FOR IMPLEMENTATION

1. **Color Scheme**: Use Pondera gold (#FFD700) and silver (#C0C0C0) for accents
2. **Font Size**: Large enough to read from distance (recommend 16-20pt)
3. **Animation**: Fade-in/fade-out on menu transitions (0.5 second)
4. **Accessibility**: Ensure high contrast for visibility
5. **Performance**: All rendering done with maptext (efficient)
6. **State Persistence**: Save all selections so user can go back

---

## ROLLBACK PLAN

If new HUD system has issues:
1. Keep legacy CharacterCreationUI.dm as backup
2. Add flag: `USE_LEGACY_LOGIN = 1` to disable new HUD
3. Can be toggled in InitializationManager.dm

---

## SUCCESS CRITERIA

✅ All 6 login screens replaced with HUD menus  
✅ No `alert()` or `input()` dialogs during login  
✅ Player can navigate with keyboard  
✅ Character created successfully  
✅ Build compiles with 0 errors  
✅ No blocking/lag during character creation  
✅ New players experience immersive login flow

---

## ESTIMATED EFFORT

- **Phase 1-7 (Core Implementation)**: 4-6 hours
- **Phase 8 (Integration & Testing)**: 2-3 hours
- **Total**: 6-9 hours of development

---

**Status**: Ready for implementation  
**Next Step**: Begin Phase 1 - Create base menu classes

