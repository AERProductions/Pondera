# Deed Freeze Anti-Abuse System - Quick Reference

**Status**: ✅ Production Ready  
**Build**: 0 errors (1 pre-existing unrelated)  
**Deployment Date**: December 7, 2025, 12:54 PM  

---

## The System at a Glance

| Aspect | Rule | Enforcement |
|--------|------|-------------|
| **Freeze Limit** | Max 2 per calendar month | Blocked if limit reached |
| **Early Unfreeze Cost** | 7-day cooldown applied | Can't re-freeze during cooldown |
| **Cooldown Reset** | Automatic after 7 days | No admin action needed |
| **Monthly Reset** | Automatic on month change | Uses real calendar date |
| **Visibility** | Player sees limits and reset date | In-game UI displays info |

---

## How It Prevents Abuse

### Toggle Protection
```
Freeze → Unfreeze → Freeze
         ↓
    7-day cooldown blocks next freeze
    = Prevents daily toggling
```

### Limit Protection
```
2 freezes max per month
= Even with cooldown cycling, limited to 2 real freeze periods
= Can't indefinitely extend freeze coverage
```

### Calendar Protection
```
Resets on 1st of month (real calendar)
= Automatic, no admin needed
= Players know exactly when reset happens
= Self-regulating system
```

---

## Player Impact

**Casual Vacations**: Unaffected ✅
- Plan vacation → Freeze once → Enjoy
- Auto-unfreeze → Resume normal gameplay

**Extended Breaks**: Still supported ✅
- Freeze for 30 days in month 1
- Auto-unfreeze, restart 30-day timer
- Freeze again next month if needed

**Flexibility**: Available with cost ✅
- Need to return early? Unfreeze anytime
- But: 7-day waiting period before re-freezing
- Encourages honest freeze planning

**Abuse**: Prevented ✅
- Can't toggle on/off daily
- Can't accumulate infinite freeze periods
- Limited to 2 freezes per month

---

## Code Implementation Summary

**File**: `dm/ImprovedDeedSystem.dm`

**Variables Added** (3):
```dm
freezes_used_this_month = 0   // 0-2 counter
last_freeze_month = 0         // Month number for reset
cooldown_end = 0              // Expiration time (0 if none)
```

**Procedures Added** (3):
```dm
CheckMonthlyReset()           // Auto-reset counter
GetCooldownDaysRemaining()    // Get display value
GetNextMonthReset()           // Get reset date text
```

**Procedures Enhanced** (2):
```dm
OpenFreezeMenu()              // Show limits and status
ActivateFreeze()              // Check limits before activating
```

**Total Code**: ~120 lines added

---

## Key Messages Players See

### When Freezing (Success)
```
"Deed payments are now frozen for X days!"
"Freezes used this month: 1/2"
```

### When Freezing (Blocked - Cooldown)
```
"You cannot freeze yet! Early unfreeze cooldown active."
"Try again in 5 day(s)."
```

### When Freezing (Blocked - Limit)
```
"You have reached your freeze limit for this month (2 max)."
"Try again when the month resets on the 1st."
```

### When Unfreezing (Early)
```
"Unfreeze deed payments now?"
"This will trigger a 7-day cooldown before you can freeze again."
```

### After Early Unfreeze
```
"Deed payments unfrozen! You can re-freeze in 7 days."
```

### Status Check
```
"Freezes available: 1/2 this month"
"Resets: January 1st"
```

---

## Testing Scenarios

✅ **Basic Freeze**: Works normally
✅ **Auto-Unfreeze**: Triggers on timer expiration
✅ **Manual Unfreeze**: Applies 7-day cooldown
✅ **Cooldown Block**: Prevents freeze during cooldown
✅ **Limit Block**: Prevents 3rd freeze in month
✅ **Month Reset**: Clears counter on month change
✅ **Cooldown Through Reset**: Survives month boundary
✅ **Multiple Deeds**: Track independently

---

## Admin Configuration

To modify limits, edit constants:

```dm
// Current: 2 freezes per month, 7-day cooldown

// To increase freezes to 3/month:
// In OpenFreezeMenu(): change "2 -" to "3 -"
// In ActivateFreeze(): change ">= 2" to ">= 3"

// To increase cooldown to 14 days:
// In OpenFreezeMenu(): change "7 * 24" to "14 * 24"
// In ActivateFreeze(): change "7 * 24" to "14 * 24"
```

---

## Abuse Prevention Effectiveness

| Attack | Method | Result |
|--------|--------|--------|
| Daily toggle | Freeze/unfreeze each day | ❌ Blocked by 7-day cooldown |
| Max then cycle | Use 2, unfreeze, try 3rd | ❌ Blocked by monthly limit |
| Wait out cooldown | Unfreeze, wait 7 days, freeze | ❌ Limited by monthly cap |
| Exploit reset | Time unfreeze near month end | ❌ Cooldown persists through reset |
| Multiple accounts | Different deeds per account | ✅ Allowed (intended) |

---

## Performance Impact

**Negligible**:
- Monthly check: O(1) integer comparison
- Cooldown check: O(1) integer comparison
- No background loops
- Only runs on freeze menu access

---

## What Works As Designed

✅ Players can freeze 2x per month for vacations  
✅ Can extend freeze using month boundaries strategically  
✅ Early unfreezing available with 7-day consequence  
✅ System self-regulates without admin intervention  
✅ Monthly reset automatic and transparent  
✅ Multiple deeds tracked independently  
✅ Prevents casual abuse effectively  
✅ Visible feedback helps player understanding  

---

## Monitoring Notes

**Watch For**:
- Players hitting cooldown frequently (might indicate abuse attempts)
- Patterns of 2 freezes every month (might indicate systematic exploiting)
- Complaints about 7-day cooldown (gauge player satisfaction)

**Expected Behavior**:
- Most players: 0-1 freezes per month
- Travelers/casual breaks: 1 freeze per month
- Extended breaks: Up to 2 freezes spread across months

---

## Summary

The anti-abuse system uses **2 independent protection layers**:

1. **Monthly Limit (2/month)** = Hard cap on freezes per calendar period
2. **Early Unfreeze Cooldown (7 days)** = Cost for flexibility

Together they:
- Allow legitimate vacation use
- Prevent exploitation patterns
- Self-regulate without admin input
- Remain transparent to players
- Add negligible performance cost

**Result**: Balanced system that protects both fair gameplay and genuine vacation needs.

---

**Implemented**: December 7, 2025, 12:54 PM  
**Status**: Production Ready  
**Testing**: Complete
