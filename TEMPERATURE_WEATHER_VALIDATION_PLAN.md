# Temperature & Weather Systems - Validation Plan

**Status**: All systems implemented, ready for testing
**Build**: ✅ 0 errors, 2 warnings (unrelated)
**Effort**: ~60 minutes testing + validation

---

## Test 1: Elevation-Based Ambient Temperature

**Objective**: Verify that ambient temperature varies correctly by elevation level

**Setup**:
1. Create a map with terrains at elevations: 0.5, 1.2, 1.8, 2.3, 2.7
2. Spawn player at each elevation
3. Add debug logging to see GetAmbientTemperature() values

**Steps**:
1. Move player to elevation < 1.0 (water level)
2. Check GetAmbientTemperature() returns 18 ✓
3. Move to elevation 1.2 (lowlands)
4. Check GetAmbientTemperature() returns 16 ✓
5. Move to elevation 1.8 (highlands)
6. Check GetAmbientTemperature() returns 14 ✓
7. Move to elevation 2.3 (mountains)
8. Check GetAmbientTemperature() returns 10 ✓
9. Move to elevation 2.7+ (peaks)
10. Check GetAmbientTemperature() returns 5 ✓

**Expected Result**: Temperature decreases as elevation increases (realistic)

---

## Test 2: Forge Heating with Temperature States

**Objective**: Verify forge can heat items through temperature states

**Setup**:
1. Create test ingot (obj/items/thermable)
2. Create forge object in world
3. Add ingot to player inventory

**Steps**:
1. Right-click forge → "Heat_Item_Dialog()"
2. Select ingot from list
3. Wait for heating (30 ticks)
4. Check ingot.temperature_stage == TEMP_HOT ✓
5. Check ingot name shows temperature color (red) ✓
6. Wait for cooling (background process)
7. Verify ingot transitions: HOT → WARM (30s) → COOL (60s) ✓
8. Check ingot name changes colors as it cools ✓

**Expected Result**: Item heats to HOT, then gradually cools with color feedback

---

## Test 3: Elevation-Based Cooling Rates

**Objective**: Verify that cooling rates vary by elevation

**Setup**:
1. Create two hot ingots
2. Place one forge at elevation 2.7 (peaks - should cool fast)
3. Place one forge at elevation 0.5 (water - should cool slow)
4. Heat ingots at same time, record cooling duration

**Steps**:
1. Heat ingot at peaks (elevel 2.7)
2. Note time when reaches WARM state
3. Heat ingot at water level (elevel 0.5)
4. Note time when reaches WARM state
5. Calculate ratio: water_time / peaks_time
6. Should be approximately 1.3 / 0.7 = ~1.86x slower at water level

**Expected Result**: High elevation cooling is ~1.9x faster than low elevation

---

## Test 4: Music Changes with Weather

**Objective**: Verify music theme updates when weather changes

**Setup**:
1. Player in world
2. Weather controller running
3. Check current music_system.current_theme

**Steps**:
1. Start with clear weather
2. Verify music_system.current_theme = "peaceful" ✓
3. Force weather to "fog"
4. Verify music_system.current_theme = "peaceful" (should stay) ✓
5. Force weather to "dust_storm"
6. Verify music_system.current_theme = "exploration" ✓
7. Force weather to "thunderstorm"
8. Verify music_system.current_theme = "boss" ✓
9. Force weather back to "clear"
10. Verify music_system.current_theme = "peaceful" ✓

**Expected Result**: Music theme changes appropriately with weather type

---

## Test 5: Lightning in Thunderstorms

**Objective**: Verify lightning spawns during thunderstorms and damages mobs

**Setup**:
1. Player in world at ground level
2. Multiple test mobs nearby
3. Force weather to "thunderstorm"

**Steps**:
1. Wait for weather update cycle (10 ticks)
2. Check if lightning_strike objects appear (25% chance) ✓
3. Verify strikes spawn within 15 turfs of player ✓
4. Verify lightning particles display ✓
5. Check nearby mobs take damage (35 HP base) ✓
6. Check mobs get stunned for 4 ticks ✓
7. Repeat multiple cycles to ensure probability works ✓

**Expected Result**: Thunderstorms become dangerous with random lightning strikes

---

## Test 6: Temperature-Aware Forge UI

**Objective**: Verify forge verbs display correct temperature information

**Setup**:
1. Player with multiple items at different temperatures
2. Forge in view range

**Steps**:
1. Create test items: one TEMP_HOT, one TEMP_WARM, one TEMP_COOL
2. Right-click forge → "Check_Forge_Status()"
3. Check output includes:
   - Forge active/dormant status ✓
   - List of workable items (TEMP_HOT/WARM) ✓
   - List of quenchable items (TEMP_HOT only) ✓
   - Temperature colors displayed correctly ✓
   - Tips for using forge ✓
4. Right-click forge → "Heat_Item_Dialog()"
5. Check dialog shows:
   - Only items that need heating ✓
   - Current temperature of each item ✓
   - Allows selection without error ✓

**Expected Result**: UI verbs work and show correct information

---

## Test 7: Quenching System

**Objective**: Verify items can be properly quenched in water trough

**Setup**:
1. Hot ingot (TEMP_HOT)
2. Water trough in world

**Steps**:
1. Verify ingot.IsQuenchable() returns TRUE ✓
2. Click water trough → "Quench_Item_Dialog()"
3. Select hot ingot
4. Check water trough.QuenchItem() executes ✓
5. Verify ingot temperature_stage becomes TEMP_COOL ✓
6. Check message displays "hiss of steam" ✓
7. Verify ingot is now ready for refinement ✓

**Expected Result**: Hot items can be quenched to cool state

---

## Test 8: FilteringLibrary Integration

**Objective**: Verify temperature filters work correctly

**Setup**:
1. Player with items at different temperature states

**Steps**:
1. Check get_hot_items(inventory) returns only TEMP_HOT items ✓
2. Check get_workable_items(inventory) returns TEMP_HOT + TEMP_WARM items ✓
3. Check is_hot_item(item) for each item ✓
4. Check is_workable_item(item) for each item ✓
5. Verify list operations don't error ✓

**Expected Result**: Filter procs correctly identify items by temperature state

---

## Failure Conditions to Watch For

- ❌ Items not changing temperature over time
- ❌ Cooling rates not varying by elevation
- ❌ Music not updating when weather changes
- ❌ Lightning not spawning during thunderstorms
- ❌ Forge verbs crashing or showing wrong items
- ❌ Temperature colors not updating in UI
- ❌ Filters returning wrong items
- ❌ Stun effect not applied to lightning damage

---

## Success Criteria

✅ All 8 tests pass without errors
✅ No console errors or warnings related to temperature/weather
✅ Forge workflow: Heat → Cool → Quench complete
✅ Music responds to weather changes
✅ Lightning creates dynamic hazards
✅ UI displays temperature information clearly
✅ Elevation affects all systems consistently

---

## Test Timeline

| Test | Effort | Notes |
|------|--------|-------|
| #1: Ambient Temp | 5 min | Quick elevation checks |
| #2: Forge Heating | 10 min | Full heating cycle |
| #3: Cooling Rates | 15 min | Comparative timing |
| #4: Music Weather | 5 min | Theme switching |
| #5: Lightning | 10 min | Damage + stun check |
| #6: Forge UI | 5 min | Verb functionality |
| #7: Quenching | 5 min | State transitions |
| #8: Filtering | 5 min | Filter procs |

**Total**: ~60 minutes

---

## Bug Reporting Format

If issues found, report as:

**Bug**: [Brief title]
**Severity**: [HIGH/MEDIUM/LOW]
**Steps to Reproduce**:
1. ...
2. ...
**Expected**: [What should happen]
**Actual**: [What actually happened]
**File**: [File with issue]
**Line**: [Line number if known]

---

**Status**: Ready to validate. All systems built and compiled.
