# Deed Freeze Anti-Abuse System

**Date**: December 7, 2025, 12:54 PM  
**Status**: ✅ Implemented & Tested  
**Build Status**: 0 errors (1 pre-existing unrelated)  

---

## Overview

The anti-abuse system for deed payment freezes prevents exploitation while preserving legitimate vacation use cases. It uses a **hybrid approach combining:**

1. **Monthly Freeze Limit**: Max 2 freezes per calendar month
2. **Early Unfreeze Cooldown**: 7-day cooldown if unfreezing before duration expires
3. **Visible Tracking**: Players see freeze usage and reset dates

---

## Core Mechanics

### Freeze Limit: 2 Per Calendar Month

| Freeze Count | Status | Can Freeze? |
|--------------|--------|-------------|
| 0/2 | Available | ✅ Yes |
| 1/2 | Limited | ✅ Yes (1 left) |
| 2/2 | Maxed Out | ❌ No (wait for reset) |

**Reset**: Automatic on the 1st of each month (uses real calendar)

### Early Unfreeze Penalty: 7-Day Cooldown

```
Timeline:
Day 1  → Freeze for 30 days
Day 5  → Unfreeze early
Day 5  → Cooldown starts (can't re-freeze for 7 days)
Day 12 → Cooldown ends, can freeze again

Cost of early unfreeze:
- Maintenance due in 23 days (instead of 30)
- Can't freeze again for 7 days
- Discourages casual toggling
```

---

## Player Experience Examples

### Example 1: Planned Vacation (No Abuse)

```
Dec 1  → Owner freezes for 14 days (1/2 freezes used)
Dec 15 → Freeze auto-expires, fresh 30-day timer
Jan 15 → Payment due
Jan 1  → Monthly reset, freezes back to 0/2

Result: Normal, healthy use case ✅
```

### Example 2: Extended Break (Stacking Freezes)

```
Dec 1  → Owner freezes for 30 days (1/2 freezes used)
Dec 31 → Freeze expires, fresh 30-day payment timer
Jan 1  → Monthly reset, freezes back to 0/2
Jan 1  → Owner freezes again for 30 days (1/2 freezes used)
Jan 31 → Freeze expires, fresh 30-day timer
Feb 28 → Payment due

Result: Full 60-day vacation coverage with smart planning ✅
```

### Example 3: Early Return - Legitimate Cost

```
Dec 1  → Owner freezes for 30 days (1/2 freezes used)
Dec 8  → Plans change, returns early, unfreezes
Dec 8  → 7-day cooldown starts
Dec 15 → Cooldown ends, can freeze again if needed
        → But maintenance now due in 23 days (instead of 30)

Cost Analysis:
- Lost 7 days of maintenance buffer
- Can't freeze again for 7 days
- Still have 23 days + 7-day grace period = 30 days total safety

Result: Flexibility with consequences ✅
```

### Example 4: Attempted Abuse - Prevented

```
Dec 1  → Freeze for 7 days (1/2 freezes used)
Dec 4  → Unfreeze immediately (7-day cooldown applied)
Dec 4  → Try to freeze again
        → ERROR: Cooldown active, 6 days remaining

Dec 10 → Cooldown ends, try to freeze
        → Freezes for 7 days (2/2 freezes used)
Dec 13 → Unfreeze immediately (7-day cooldown applied)
Dec 13 → Try to freeze again
        → ERROR: Freezes maxed out (2/2 this month)
Dec 20 → Cooldown ends
        → Still can't freeze - limit reached
Jan 1  → Monthly reset, 0/2 freezes available

Result: Abuse prevented, costs real time/delays ✅
```

---

## Implementation Details

### Variables Added (3)

```dm
freezes_used_this_month = 0   // Tracks 0-2 freeze usage
last_freeze_month = 0         // Which month was counted (1-12)
cooldown_end = 0              // world.time when cooldown expires (0=none)
```

### Procedures Added (3)

**CheckMonthlyReset()**
- Compares current calendar month to `last_freeze_month`
- Resets `freezes_used_this_month` to 0 if month changed
- Called before every freeze menu access
- Uses real calendar (not game time)

**GetCooldownDaysRemaining()**
- Returns days remaining in 7-day early unfreeze cooldown
- Returns 0 if no cooldown active
- Used in freeze menu display

**GetNextMonthReset()**
- Returns human-readable date of next month reset
- Example: "January 1st"
- Used in freeze menu info display

### Procedures Enhanced (2)

**OpenFreezeMenu()**
- Added CheckMonthlyReset() call
- Shows freeze count: "Freezes available: 1/2 this month"
- Shows reset date: "Resets: January 1st"
- Shows cooldown if active: "7 day(s) remaining in cooldown"
- Displays status on freeze menu prompts

**ActivateFreeze()**
- Checks cooldown before allowing freeze
- Checks monthly limit before allowing freeze
- Increments `freezes_used_this_month` when freeze activated
- Clears cooldown (only applies on early unfreeze)
- Shows "Freezes used this month: X/2" in confirmation

---

## Player Visibility

### Not In Cooldown, Freezes Available

```
Menu shows:
┌─────────────────────────────────┐
│ Freeze Payments                 │
├─────────────────────────────────┤
│ Freezes available: 2/2          │
│ Resets: January 1st             │
│                                 │
│ [Freeze for 7 Days]             │
│ [Freeze for 14 Days]            │
│ [Freeze for 30 Days]            │
│ [View Info]                     │
│ [Back]                          │
└─────────────────────────────────┘
```

### In Cooldown

```
Menu shows:
┌─────────────────────────────────┐
│ Freeze Payments                 │
├─────────────────────────────────┤
│ 5 day(s) remaining in cooldown  │
│ Freezes available: 1/2          │
│ Resets: January 1st             │
│                                 │
│ [Freeze for 7 Days]             │
│   (BLOCKED - cooldown active)   │
│ ...                             │
└─────────────────────────────────┘
```

### At Monthly Limit

```
Menu shows:
┌─────────────────────────────────┐
│ Freeze Payments                 │
├─────────────────────────────────┤
│ You have reached your freeze    │
│ limit for this month (2 max).   │
│ Try again when the month        │
│ resets on the 1st.              │
└─────────────────────────────────┘
```

### Frozen Deed with Unfreeze Info

```
Menu shows:
┌─────────────────────────────────┐
│ Freeze Status                   │
├─────────────────────────────────┤
│ Payments frozen for 12 more days│
│ Options:                        │
│                                 │
│ [View Status]                   │
│ [Unfreeze Now]                  │
│   (Will trigger 7-day cooldown) │
│ [Back]                          │
└─────────────────────────────────┘
```

---

## Cooldown vs Limit - Why Both?

### Limit Alone Insufficient
```
2 freezes/month = 60 days protection max
Problem: Player unfreezes day 30, re-freezes immediately
Result: Effectively infinite protection
```

### Cooldown Alone Insufficient
```
7-day cooldown = Prevents toggling
Problem: Just do one 30-day freeze, wait 7 days, freeze again
Result: Can still stack freezes indefinitely
```

### Combined = Optimal Balance
```
2 freezes/month + 7-day cooldown = 
- Max 60 days direct freeze protection
- Early unfreeze costs 7-day delay
- Can't exceed limit even with waiting
- Self-limiting through real calendar
= Fair to casual players, prevents abuse
```

---

## Edge Cases Handled

### Case 1: Freeze Expires During Cooldown

```
Dec 1  → Freeze for 7 days (1/2 used)
Dec 4  → Unfreeze early (cooldown until Dec 11)
Dec 8  → Freeze naturally expires (if it wasn't unfrozen)
Result: No issue - IsMaintenanceDue() auto-unfreezes anyway
        Cooldown still applies (7 days from Dec 4)
```

### Case 2: Monthly Reset During Active Cooldown

```
Dec 28 → Unfreeze early (cooldown until Jan 4)
Jan 1  → Monthly reset happens
        Freezes reset to 0/2
        Cooldown still active until Jan 4
Result: Correct - reset doesn't bypass cooldown penalty
```

### Case 3: Multiple Deeds Per Player

```
Player owns 2 village deeds
Each deed tracks independently:
- Deed A: 1/2 freezes used, no cooldown
- Deed B: 0/2 freezes used, 5-day cooldown

Result: Correct - each zone manages independently
```

---

## Anti-Abuse Effectiveness

### Attack Vector 1: Toggle Freezes Every Day
```
Player tries: Freeze → Unfreeze → Freeze → Unfreeze
Protection:
- 1st freeze: Allowed (1/2 used)
- 1st unfreeze: Allowed, 7-day cooldown applied
- 2nd freeze attempt: BLOCKED (cooldown active)
Result: ❌ Blocked for 7 days
```

### Attack Vector 2: Max Out Monthly Then Unfreeze
```
Player tries: Freeze (1) → Freeze (2) → Unfreeze → Freeze (3)
Protection:
- Freeze 1: Allowed (1/2)
- Freeze 2: Allowed (2/2)
- Unfreeze: Allowed, cooldown applied
- Freeze 3: BLOCKED (limit reached, cooldown active)
Result: ❌ Can't freeze more this month
```

### Attack Vector 3: Wait Exactly 7 Days
```
Player tries: Unfreeze → Wait 7 days → Freeze
Protection:
- Day 0: Unfreeze, cooldown applied (until day 7)
- Day 7: Cooldown expires, can freeze
- But: Already used 1-2 freezes that month
- If used 2: Can't freeze (limit reached)
- If used 1: Can freeze 1 more (2/2 this month)
Result: ❌ Limited by monthly cap
```

### Attack Vector 4: Exploit Month Boundaries
```
Player tries: Dec 30 unfreeze → Jan 1 freeze exploit
Protection:
- Dec 30: Unfreeze, cooldown until Jan 6
- Jan 1: Monthly reset happens
- Jan 1: 0/2 freezes available
- Jan 1: Cooldown still active until Jan 6
- Jan 6: Cooldown expires, can freeze again
Result: ❌ Cooldown applies regardless of month reset
```

---

## Performance Impact

**Negligible**:
- Monthly reset check: Single integer comparison (O(1))
- Cooldown check: Single integer comparison (O(1))
- Freeze count increment: Single addition (O(1))
- Month detection: Uses BYOND's time2text (already optimized)

**No background loops added**
- All checks happen on-demand (freeze menu access)
- No persistent timers running

---

## Future Enhancements

🔮 **Progressive Penalties**: Increase cooldown per repeated unfreezes in month
🔮 **Unfreeze Notifications**: Alert player before auto-unfreeze
🔮 **Freeze History**: Log when deeds were frozen/unfrozen
🔮 **Vacation Announcements**: Let members know village frozen
🔮 **Council Approval**: For guild-owned deeds, require vote to unfreeze

---

## Configuration Guide

To adjust limits, modify constants in ImprovedDeedSystem.dm:

```dm
// Max freezes per calendar month
#define MAX_FREEZES_PER_MONTH 2

// Days for early unfreeze cooldown
#define EARLY_UNFREEZE_COOLDOWN 7

// Example: Change to 3 freezes max
#define MAX_FREEZES_PER_MONTH 3

// Example: Change to 14-day cooldown
#define EARLY_UNFREEZE_COOLDOWN 14
```

---

## Testing Verification

✅ Monthly reset triggers on month change  
✅ Freeze count increments correctly  
✅ Limit prevents 3rd freeze attempt  
✅ Cooldown blocks re-freeze for 7 days  
✅ Visible feedback shows count and reset date  
✅ Multiple deeds track independently  
✅ Cooldown persists through month boundaries  
✅ Build compiles with 0 errors  

---

## Summary

The **hybrid anti-abuse system** provides:

- **2 freezes per month** = Legitimate vacation coverage
- **7-day cooldown on early unfreeze** = Prevents casual toggling
- **Visible tracking** = Transparent to players
- **Self-limiting** = No admin intervention needed
- **Fair** = Protects casual players, stops abuse

Result: Players can vacation worry-free, but abuse becomes expensive in time.

---

**Feature Complete**: December 7, 2025, 12:54 PM
