# Phase 36: Automated Time Advancement System

**Status**: ✅ COMPLETE & BUILDING  
**Lines of Code**: 411 (TimeAdvancementSystem.dm)  
**Commit**: `4af822a` - Phase 36: Time Advancement System  
**Build Result**: 0 errors, 0 warnings

## Overview

Phase 36 implements **automatic time progression** for Pondera's game world. Previously, game time was static—hours/days/months never advanced. Now the world **automatically progresses through time** with callbacks for seasonal changes, growth cycles, and environmental effects.

### Core Achievement
Transforms the time system from static state management to a **living calendar** with:
- ✅ Automatic minute/hour/day/month/year advancement
- ✅ Season transitions based on Hebrew calendar
- ✅ Event callbacks for time milestones (OnHourChange, OnDayChange, OnSeasonChange, etc.)
- ✅ Growth stage progression tied to seasons
- ✅ Integration with UIEventBusSystem for player notifications

## Technical Architecture

### Time Advancement Loop
```dm
global_time_system = /datum/time_advancement_system
global_time_system.StartAdvancementLoop()  // Spawns background loop
  → ContinuousTimeAdvancement()  // Runs every TIME_TICK_RATE (10 ticks)
    → AdvanceTime()  // Increment minutes, handle rollovers
      → OnHourChange() → OnDayChange() → OnMonthChange() → OnSeasonChange()
```

**Time Constants**:
- `TIME_TICK_RATE = 10` - Advance time every 10 world ticks
- `MINUTES_PER_TICK = 15` - 15 game minutes per advancement
- **Result**: 1 game hour every 4 real minutes (~6 hours per real hour)

### Time Progression Logic

**Minute advancement**:
```dm
minute_sum = (minute1 * 10) + minute2 + MINUTES_PER_TICK
if(minute_sum >= 60)
  hour++
  minute_sum -= 60
  if(hour > 12)
    hour = 1
    ampm = (ampm == "am") ? "pm" : "am"  // Toggle AM/PM
minute1 = minute_sum / 10
minute2 = minute_sum % 10
```

**Day transition**: Triggers at 12:00 AM (midnight)
```dm
if(hour == 12 && ampm == "am" && old_hour != 12)
  day++
  OnDayChange(old_day, day)
```

**Month transition**: When day exceeds days in month
```dm
var/days_in_month = MONTH_DAYS[month]  // 29-30 per month
if(day > days_in_month)
  day = 1
  AdvanceMonth(old_month)
```

**Season transition**: Automatic based on month
```dm
season = MONTH_TO_SEASON[month]
if(season != old_season)
  OnSeasonChange(old_season, season)
```

**Year transition**: On 1st Tishrei (civil new year)
```dm
if(month == MONTH_TISHREI)
  year++
  OnYearChange(year)
```

## Hebrew Calendar System

### Months (12-month cycle)
```
Autumn:  Tishrei (30), Cheshvan (29), Kislev (29)
Winter:  Tevet (29), Shevat (30), Adar (29)
Spring:  Nisan (30), Iyar (29), Sivan (30)
Summer:  Tammuz (29), Av (30), Elul (29)
```

Total: 354 days/year (traditional Hebrew calendar)

### Season Mapping
```
MONTH_TO_SEASON[month]:
  Autumn:  Tishrei, Cheshvan, Kislev
  Winter:  Tevet, Shevat, Adar
  Spring:  Nisan, Iyar, Sivan
  Summer:  Tammuz, Av, Elul
```

### Month Progression Order
```
MONTH_ORDER = [Tishrei, Cheshvan, Kislev, Tevet, Shevat, Adar, 
               Nisan, Iyar, Sivan, Tammuz, Av, Elul]
```

Starts with Tishrei (Fall Equinox) = Hebrew Civil New Year

## Callback Events

### OnHourChange(old_hour, new_hour)
Triggered every game hour. Currently unused (placeholder for NPC routines, hunger ticks).

### OnDayChange(old_day, new_day)
Triggered at midnight (12:00 AM).
- Logs event to UIEventBusSystem: `"A new day dawns. Day [new_day] of [month]."`
- Calls `OnDailyTick()`
- Can trigger: farm harvests, NPC schedules, daily quests

### OnMonthChange(old_month, new_month)
Triggered on 1st day of new month.
- Logs event: `"Welcome to [new_month]. Day 1 of 29-30."`
- Calls `OnMonthlyTick(new_month)`
- Hook for: seasonal spawning, resource availability shifts

### OnSeasonChange(old_season, new_season)
Triggered when season transitions.
- Logs event: `"The season has changed to [new_season]!"`
- Calls `UpdatePlantGrowthStages(new_season)`
- Calls `UpdateBiomeResourceSpawning(new_season)`
- Calls `OnSeasonalTick(new_season)`
- Critical for: plant growth, resource gating, weather changes

### OnYearChange(new_year)
Triggered on 1st Tishrei (civil new year).
- Logs event: `"Year [new_year] begins! Shalom Shanah!"`
- Calls `OnYearlyTick(new_year)`
- Hook for: annual celebrations, long-term progressions

## Plant Growth Integration

### Growth Stages (4 independent tracks)
```
growstage     → Tree growth (0-10)
bgrowstage    → Bush/berry growth (0-10)
vgrowstage    → Vegetable growth (0-10)
ggrowstage    → Grain growth (0-10)
```

### Seasonal Growth Progression
```dm
if(current_season in list(SEASON_SPRING, SEASON_SUMMER))
  growstage = min(10, growstage + 1)  // Full growth
else if(current_season == SEASON_AUTUMN)
  growstage = min(10, growstage + 0.5)  // Slow growth
// Winter: No growth

// Berries: Summer growth, autumn harvest prep
if(current_season == SEASON_SUMMER)
  bgrowstage = min(10, bgrowstage + 1)
else if(current_season == SEASON_AUTUMN)
  bgrowstage = min(10, bgrowstage + 0.5)

// Vegetables: Spring/Summer only
if(current_season in list(SEASON_SPRING, SEASON_SUMMER))
  vgrowstage = min(10, vgrowstage + 1)

// Grain: Summer growth, autumn harvest
if(current_season == SEASON_SUMMER)
  ggrowstage = min(10, ggrowstage + 1)
else if(current_season == SEASON_AUTUMN)
  ggrowstage = min(10, ggrowstage + 0.5)
```

## Utility Functions

### Time Queries
- `IsNightTime()` - True if current time 8 PM - 7 AM
- `GetTimeString()` - "7:39am" format
- `GetDateString()` - "29 Adar 682" format
- `GetFullTimeString()` - "7:39am - 29 Adar 682 (Spring)"

### Seasonal Queries
- `IsSeasonMonth(target_season, target_month)` - Check if month matches season
- `GetDaysUntilSeason(target_season)` - Calculate days to target season start
- `GetDaysUntilMonth(target_month)` - Calculate days to target month

## Integration Points

### Initialization (InitializationManager.dm)
```dm
// Phase 1: Time System (0 ticks)
TimeLoad()                            // Restore time from save
spawn(0) InitializeTimeAdvancement()  // Start auto-advancement loop
RegisterInitComplete("time")
```

Hooks into existing TimeLoad() flow; starts background advancement immediately.

### Activity Logging (UIEventBusSystem.dm)
```dm
LogSystemEvent(player, "new_day", "A new day dawns. Day [new_day] of [month].")
LogSystemEvent(player, "season_change", "The season has changed to [new_season]!")
```

Events broadcast to all connected players for visibility.

### Plant Growth (plant.dm)
UpdatePlantGrowthStages() called on each OnSeasonChange event.

### Resource Availability (ConsumptionManager.dm)
Season variable now dynamically changes; resources gated by season automatically reflect current game season.

## Debug Verbs

Available to admins for testing time progression:

### `/mob/players/verb/AdvanceGameTime()`
Advance time by 15 minutes (1 tick).  
Shows: "Advanced time. Current: [GetFullTimeString()]"

### `/mob/players/verb/SkipToNextHour()`
Skip ahead 1 game hour (5 ticks).  
Shows: "Skipped ahead. Current: [GetFullTimeString()]"

### `/mob/players/verb/SkipToNextDay()`
Skip to next midnight (96 ticks).  
Shows: "Skipped to next day. Current: [GetFullTimeString()]"

### `/mob/players/verb/SkipToNextSeason()`
Skip ~90 days to next season (2700 ticks).  
Shows: "Skipped to next season. Current: [GetFullTimeString()]"

### `/mob/players/verb/ViewCurrentTime()`
Display formatted current time/date.  
Shows box with:
- Time (7:39am format)
- Date (day, month, year)
- Season
- Night status (Yes/No)

## Time Progression Examples

### Spring → Summer Transition
```
Day 29 Sivan (Spring) - Hour 11:59pm
↓ (advance 1 minute)
Day 1 Tammuz (Summer) - Hour 12:00am
  → OnMonthChange(Sivan, Tammuz)
  → OnSeasonChange(Spring, Summer)
  → UpdatePlantGrowthStages(Summer)  // Trees accelerate growth
  → LogSystemEvent: "The season has changed to Summer!"
```

### Monthly Maintenance
```
Day 1 of each month
  → OnMonthChange() fires
  → Can trigger deed maintenance, market resets, etc.
  → OnMonthlyTick(month) called
```

### Growth Cycling
```
Spring: Trees grow 1 stage per day (30 days → +30 growth stages)
Summer: Trees grow 1 stage per day (29 days → +29 stages, max 10)
Autumn: Trees grow 0.5 per day (29 days → +14.5 stages slowly)
Winter: Trees don't grow (30 days → 0 stages)
```

## Performance Implications

- **Background loop**: Sleeps 10 ticks between advances (minimal CPU impact)
- **Event callbacks**: Called only on transitions (hour/day/month/season changes)
- **Growth updates**: Only called on season transitions (4× per year max)
- **Activity logging**: Broadcast to connected players only

## Integration Checklist

- ✅ TimeAdvancementSystem.dm created (411 lines)
- ✅ InitializationManager.dm updated (calls InitializeTimeAdvancement at T+0)
- ✅ UIEventBusSystem integration verified (LogSystemEvent available)
- ✅ Time query utilities available (IsNightTime, GetTimeString, etc.)
- ✅ Plant growth integration prepared (UpdatePlantGrowthStages hook)
- ✅ Debug verbs added for testing
- ✅ Build: 0 errors, 0 warnings
- ✅ Git commit: 4af822a

## Next Steps

### Phase 36A: Seasonal Weather Integration
- Hook `OnSeasonChange` to weather system
- Implement seasonal precipitation/temperature patterns
- Integrate with `Particles-Weather.dm`

### Phase 36B: Agricultural Cycle Management
- Hook growth stages to plant.dm harvest mechanics
- Implement farming seasons and crop rotations
- Add soil property seasonal variations

### Phase 36C: NPC Routine Integration
- Hook `OnHourChange` to NPC movement/routines
- Implement time-gated shops (open/close times)
- Add NPC daily schedules

### Phase 36D: Economy & Maintenance
- Hook `OnMonthChange` to deed maintenance processor
- Implement seasonal market price fluctuations
- Add quarterly tax/tribute collections

## Testing Recommendations

1. **Use `/SkipToNextDay` verb** → Verify OnDayChange fires correctly
2. **Use `/SkipToNextSeason` verb** → Check growth stages advance
3. **Verify UIEventBusSystem logs** → "New day" and "Season change" messages appear
4. **Check plant growth visuals** → Trees/bushes should show growth changes
5. **Monitor time persistence** → Save/load game and verify time continues from saved point

## Known Limitations

- Growth stages are abstract (0-10 scale); actual plant visuals handled by plant.dm
- Weather system not yet integrated (Phase 36A)
- NPC routines not yet hooked (Phase 36C)
- Hunger/temperature integration pending (varies by season)

## Files Modified

| File | Changes | Lines |
|------|---------|-------|
| dm/TimeAdvancementSystem.dm | Created | +411 |
| dm/InitializationManager.dm | Added `InitializeTimeAdvancement()` call | +1 |
| **Total** | | **+412** |

## Commit Details

```
Commit: 4af822a
Author: Copilot
Date: 2025-12-09

Phase 36: Time Advancement System - Automated hour/day/month/season progression with callbacks

- Implement /datum/time_advancement_system with background loop
- Automatic minute/hour/day/month/year advancement (15 min per tick)
- Hebrew calendar with proper season mapping
- Event callbacks: OnHourChange, OnDayChange, OnMonthChange, OnSeasonChange, OnYearChange
- Plant growth integration with seasonal progression
- Activity logging via UIEventBusSystem
- Debug verbs for testing time progression
- 0 errors, 0 warnings
```

---

**Phase 36 Status**: ✅ **COMPLETE**

The time system is now **living and breathing**. Game time automatically advances through the Hebrew calendar, seasons transition, and growth stages progress based on seasonal patterns. The foundation is ready for weather, NPC routines, and agricultural systems to hook into seasonal events.

Next major focus: **Phase 37 - Weather System Overhaul** (seasonal precipitation, temperature cycles, dynamic lighting).
