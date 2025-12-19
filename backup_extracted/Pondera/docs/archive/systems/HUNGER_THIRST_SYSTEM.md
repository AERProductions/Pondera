# Hunger & Thirst System - Implementation Complete

## Overview
A comprehensive environmental metabolic simulation that makes survival meaningful through hunger and thirst mechanics deeply integrated with the game's:
- Temperature system (extreme cold/heat increases consumption)
- Weather effects (dehydration in deserts, exhaustion in rain)
- Elevation changes (thin air exhaustion at peaks, swimming fatigue in water)
- Biome types (desert = rapid dehydration, arctic = cold metabolism)
- Dynamic zone transitions (zone effects apply immediately)

## Architecture

### Core System (HungerThirstSystem.dm)
- **Timer-based ticking** instead of goto-heavy loops
- **Environment-aware consumption** multipliers (1.0 = baseline)
- **Per-tick damage** applied based on hunger/thirst state
- **Message queuing** at configurable intervals
- **Clean API** for food/drink integration

### Player Integration (Basics.dm)
Added variables to `mob/players`:
```dm
hunger_level = 0                    // 0-1000 scale (0=fed, 1000=starving)
thirst_level = 0                    // 0-1000 scale (0=hydrated, 1000=parched)
hunger_state = null                 // Reference to active system (flag: 0 or 1)
last_move_time = 0                  // Tracks movement for activity modifiers
```

### Login Integration (HUDManager.dm)
Automatically initializes hunger/thirst system during player Login():
```dm
InitializeHungerThirstSystem()  // Starts background tick loop
```

## Consumption Modifiers

### Temperature Effects
- **< 5°C (Extreme Cold)**: +0.5x consumption (peaks, arctic)
- **< 10°C (Cold)**: +0.2x consumption (mountains)
- **> 30°C (Hot)**: +0.4x consumption (deserts - dehydration)
- **> 35°C (Extreme Heat)**: +0.7x consumption

### Elevation Effects
- **Peaks (>= 2.5)**: +0.3x consumption (thin air metabolism)
- **Mountains (>= 2.0)**: +0.15x consumption  
- **Water (< 1.0)**: +0.2x consumption (swimming fatigue)

### Biome Effects
- **Desert**: +0.3x consumption (rapid dehydration)
- **Arctic**: +0.25x consumption (cold metabolism)
- **Water/Swamp**: +0.2x consumption (fatigue)

### Weather Effects
- **Thunderstorm**: +0.15x consumption (dodging exertion)
- **Rain**: +0.1x consumption (slight exhaustion)
- **Dust Storm**: +0.2x consumption (dehydration from dust)

## Condition System

### Active Conditions
Tracked in real-time based on current state:

| Condition | Trigger | Effect |
|-----------|---------|--------|
| Minor Cold | Elev > 2.5, Temp < 5°C | Flavor text in status |
| Exhaustion | Stamina < 100 | Reduced effectiveness |
| Weakness | HP < 50 | Lower combat power |
| Dehydration | Thirst > 750 | Stamina penalties |
| Starvation | Hunger > 750 | HP penalties |

## Message System

### Hunger Messages (per 100 ticks)
- **0-50**: Recently fed (no message)
- **51-150**: "You are getting a bit peckish..."
- **151-300**: "Your stomach is rumbling. You should find something to eat."
- **301-500**: "You are quite hungry. Food would be nice."
- **501-750**: "You are very hungry! Your hunger is affecting your performance."
- **751-1000**: "**YOU ARE STARVING! You must eat immediately!**"

### Thirst Messages (per 100 ticks)
- **0-50**: Recently hydrated (no message)
- **51-150**: "You could use a drink..."
- **151-300**: "Your mouth is dry. You should find something to drink."
- **301-500**: "You are quite thirsty. Water would be nice."
- **501-750**: "You are very thirsty! Your thirst is sapping your stamina."
- **751-1000**: "**YOU ARE PARCHED! You must drink immediately!**"

## Food/Drink Integration API

### ConsumeFoodItem()
Modern interface for consuming food/drink:

```dm
// Example: Eating bread (250 nutrition, 50 hydration, 20 stamina recovery)
usr.ConsumeFoodItem("bread", 250, 50, 0, 20)

// Example: Drinking water (no nutrition, 350 hydration)
usr.ConsumeFoodItem("water", 0, 350, 0, 0)

// Signature:
proc/ConsumeFoodItem(food_name, nutrition_amount, hydration_amount=0, 
                     recovery_hp=0, recovery_stamina=0)
```

Parameters:
- `food_name`: Item name for messaging
- `nutrition_amount`: 0-1000 scale (reduces hunger)
- `hydration_amount`: 0-1000 scale (reduces thirst)  
- `recovery_hp`: HP restored (immediate healing)
- `recovery_stamina`: Stamina restored (immediate boost)

### GetHungerThirstStatus()
Returns formatted status string:
```dm
usr << usr.GetHungerThirstStatus()
// Output:
// Hunger Level: 450/1000
// Thirst Level: 320/1000
// Conditions: Chilled. Weak.
```

## Backward Compatibility

### Old Drinking Code
Existing water sources in terrain still work via direct variable modification:
```dm
// Old style (still works):
M.stamina += amount
M.hydrated = 1

// New style (recommended):
M.ConsumeFoodItem("water", 0, 350, 0, amount)
```

### Transition Strategy
Gradually replace old food/drink verbs with `ConsumeFoodItem()` calls:
1. Find all instances of `M.hydrated = 1` + stamina/HP modification
2. Replace with `M.ConsumeFoodItem("item_name", nutrition, hydration, hp, stam)`
3. Test zones with extreme conditions to verify

## Environmental Examples

### Desert Scenario
- Ambient temp: 35°C (extreme heat)
- Biome: "desert"  
- Consumption modifier: 1.0 + 0.7 (heat) + 0.3 (biome) = 2.0x
- **Result**: Twice as much hunger AND thirst damage per tick
- **Gameplay**: Players need water within 5 minutes or face crisis

### Mountain Peak Scenario
- Elevel: 2.7 (peak)
- Ambient temp: 2°C (extreme cold)
- Biome: "arctic"
- Consumption modifier: 1.0 + 0.5 (cold) + 0.3 (altitude) + 0.25 (biome) = 2.05x
- **Result**: Thin air exhaustion + cold metabolism = rapid starvation
- **Gameplay**: Mountaineering requires food preparation

### Water Scenario
- Elevel: 0.8 (submerged)
- Consumption modifier: 1.0 + 0.2 (water) = 1.2x
- **Result**: Slight stamina drain from swimming
- **Gameplay**: Can't swim indefinitely, need shore breaks

## Persistence Integration

### Save System
Currently tracked via:
- `mob.hunger_level` and `mob.thirst_level` (on-character)
- `vital_state.hungry` and `vital_state.thirsty` (legacy booleans)

### Future Enhancement
Update `VitalState.dm` to track full hunger/thirst states:
```dm
/datum/vital_state
    var
        hunger_level = 0        // Replace hungry boolean
        thirst_level = 0        // Replace thirsty boolean
```

## Testing Checklist

### Zone Transitions
- [ ] Player enters hot desert → messages increase hunger
- [ ] Player climbs to peak → thin air exhaustion visible
- [ ] Player enters water → swimming fatigue kicks in
- [ ] Zone change applies ambient_temp immediately

### Conditions
- [ ] Starvation (hunger > 750) deals HP damage
- [ ] Dehydration (thirst > 750) deals stamina damage
- [ ] Cold condition applies at peaks in winter
- [ ] Weakness displays when HP < 50

### Food/Drink Integration
- [ ] ConsumeFoodItem() reduces hunger_level
- [ ] Water sources hydrate players
- [ ] Recovery values (HP/stamina) apply correctly
- [ ] Messages scale based on nutrition/hydration amounts

### Backward Compatibility
- [ ] Old hydrated=1 code still works
- [ ] Existing stamina/HP recovery still functions
- [ ] No conflicts with old hungry/thirsty flags

## Future Enhancements

### Phase 2: Health Effects
- Minor cold → mild fever damage
- Dehydration → reduced movement speed
- Starvation → reduced damage output
- Hypothermia → freezing status effect

### Phase 3: Food Quality Tiers
- Rations (low nutrition): 50 points, fills slow
- Meals (medium): 250 points, satisfying
- Feast (high): 500 points, very satisfying
- Luxury: 750 points + buffs

### Phase 4: Environmental Survival
- Crafting shelter (reduces temperature effects)
- Building campfires (warmth buff)
- Foraging by biome (find water/food)
- Cooking system (combine raw + heat = meals)

### Phase 5: Economy Integration
- Food prices vary by biome availability
- Wealthy players buy meals, poor forage
- Taverns/inns provide rest + food
- Hunting/fishing sustains adventurers

## Performance Notes

- **Tick interval**: 10ms (100 ticks/second), updates every 1 second
- **Zone lookup**: Every 10 ticks (1x per second)
- **Message frequency**: Every 100 ticks (~10 seconds)
- **Memory overhead**: Minimal (3 integers + 1 flag per player)

## File Modifications

### Created
- `dm/HungerThirstSystem.dm` (328 lines) - Complete system

### Modified
- `dm/Basics.dm` - Added hunger_level, thirst_level, hunger_state, last_move_time to mob/players
- `dm/HUDManager.dm` - Added InitializeHungerThirstSystem() call to Login()
- `Pondera.dme` - Added #include for HungerThirstSystem.dm

### Unchanged (Compatible)
- `dm/VitalState.dm` - Legacy hungry/thirsty booleans still work
- All food/drink items - Can transition gradually
- All water sources - Continue to function

## Status
✅ **BUILD**: 0 errors, 3 warnings (system compiled successfully)  
✅ **INTEGRATED**: Connected to DynamicZoneManager, TemperatureSystem, WeatherParticles  
✅ **BACKWARD COMPATIBLE**: Old code continues to work  
⏳ **TESTING**: Ready for gameplay testing with extreme biomes  

---

**Next Steps**: 
1. Test zone transitions with extreme temperatures
2. Verify conditions apply correctly 
3. Add health effect modifiers (Phase 2)
4. Integrate with crafting for survival recipes
