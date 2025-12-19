# Phase 5: Deed System SQLite Persistence - COMPLETE ✅

**Date**: 12/17/25 3:20 pm  
**Status**: Build successful - 0 errors, 22 warnings  
**Commits**: 1 (b6cd4c2)  
**Session Time**: ~2 hours  

## Objective
Migrate deed system from in-memory storage to SQLite persistence, enabling:
- Full deed state persistence across server reboots
- Deed restoration on world boot from database
- Maintenance status and freeze state syncing
- Player deed creation/modification updates to database

## Schema Design (db/schema.sql)

### deeds Table
20-column table for complete deed state persistence:

```sql
deed_id           INT PRIMARY KEY  -- Unique deed identifier
owner_id          INT NOT NULL     -- Foreign key to players table
zone_name         TEXT NOT NULL    -- Deed name
zone_tier         TEXT NOT NULL    -- 'small', 'medium', or 'large'
center_x/y/z      INT              -- Center turf coordinates
size_x/y          INT              -- Zone dimensions in turfs
allowed_players   TEXT             -- JSON list of allowed player ckeys
maintenance_cost  INT              -- Monthly upkeep fee
maintenance_due   INT              -- Timestamp when payment due
founded_date      INT              -- Deed creation timestamp
grace_period_end  INT              -- When grace period expires (if unpaid)
payment_frozen    INT              -- 1=frozen, 0=not frozen
frozen_start      INT              -- When freeze activated
freeze_duration   INT              -- Days of freeze grace period
freezes_used_this_month INT        -- Count of freezes used
last_freeze_month INT              -- Month of last freeze
cooldown_end      INT              -- When cooldown expires
created_at        TIMESTAMP        -- Record creation
updated_at        TIMESTAMP        -- Record last update
```

### Indexes (4)
- `idx_deed_owner` - owner_id lookups
- `idx_deed_maintenance` - maintenance_due queries (for processor)
- `idx_deed_frozen` - Find frozen deeds
- `idx_deed_zone` - zone_name searches

## Implementation: SQLitePersistenceLayer.dm

### 7 CRUD Operations (Lines 990-1195)

#### 1. SaveDeedToSQLite(obj/DeedToken_Zone/deed, owner_ckey)
Persist deed to database on creation or modification.
```dm
proc/SaveDeedToSQLite(obj/DeedToken_Zone/deed, owner_ckey)
  // Get owner_id from ckey
  var/owner_id = GetPlayerIDFromSQLite(owner_ckey)
  
  // Extract turf coordinates safely
  var/turf/ct = deed.center_turf
  var/center_x/y/z = (ct ? ct.x/y/z : 0)
  
  // Serialize allowed_players to JSON
  var/allowed_json = json_encode(deed.allowed_players)
  
  // INSERT OR REPLACE with parameter binding
  ExecuteSQLiteQuery(query, list(...20 parameters...))
```
**Key**: Uses parameter binding for SQL injection safety. Converts allowed_players list to JSON for storage.

#### 2. LoadDeedFromSQLite(deed_id)
Recreate deed object from database row.
```dm
proc/LoadDeedFromSQLite(deed_id)
  // SELECT * FROM deeds WHERE deed_id = ?
  var/row = ExecuteSQLiteQuery(...)[1]
  
  // Create new DeedToken_Zone and restore all properties
  var/obj/DeedToken_Zone/new_deed = new()
  new_deed.zone_id = row["deed_id"]
  new_deed.zone_name = row["zone_name"]
  // ... restore 20+ properties from row ...
  
  // Restore allowed_players from JSON
  new_deed.allowed_players = json_decode(row["allowed_players"])
  
  return new_deed
```
**Key**: Full deserialization including list JSON parsing. Finds center turf by coordinates.

#### 3. GetAllDeedsFromSQLite()
Load all deeds from database on world boot.
```dm
proc/GetAllDeedsFromSQLite()
  var/query = "SELECT deed_id FROM deeds"
  var/rows = ExecuteSQLiteQuery(query, , return_rows=1)
  
  for(var/row in rows)
    LoadDeedFromSQLite(row["deed_id"])
    
  world.log << "DEED BOOT: Loaded [rows.len] deeds from database"
```
**Key**: Loads all deeds and recreates objects in game world.

#### 4. DeleteDeedFromSQLite(deed_id)
Remove deed from database on deed destruction.

#### 5. UpdateDeedMaintenanceStatus(zone_id, maintenance_due, grace_period_end)
Sync maintenance payment state to database.
```dm
UPDATE deeds SET maintenance_due=?, grace_period_end=? WHERE deed_id=?
```

#### 6. UpdateDeedFreezeStatus(zone_id, payment_frozen, frozen_start, freeze_duration, freezes_used_this_month)
Sync payment freeze state to database.
```dm
UPDATE deeds SET payment_frozen=?, frozen_start=?, freeze_duration=?, freezes_used_this_month=? WHERE deed_id=?
```

#### 7. ConvertTierNameToConstant(tier_name)
Helper to convert tier name string to tier constant (1/2/3).

## Integration: ImprovedDeedSystem.dm

### Three New Procs (Moved Before InitializeTier)

#### SaveToDatabase()
Called after InitializeTier() and modifications:
```dm
proc/SaveToDatabase()
  if(owner_key && length(owner_key) > 0)
    SaveDeedToSQLite(src, owner_key)  // Save this deed to SQLite
```

#### UpdateMaintenanceDatabase()
Called in OnMaintenanceFailure() and ProcessMaintenance():
```dm
proc/UpdateMaintenanceDatabase()
  UpdateDeedMaintenanceStatus(zone_id, maintenance_due, grace_period_end)
```

#### UpdateFreezeDatabase()
Called in ActivateFreeze():
```dm
proc/UpdateFreezeDatabase()
  UpdateDeedFreezeStatus(zone_id, payment_frozen, frozen_start, freeze_duration, freezes_used_this_month)
```

### Integration Points
1. **InitializeTier(tier)** - Line 96: Calls SaveToDatabase() at end
2. **OnMaintenanceFailure()** - Line 166: Calls UpdateMaintenanceDatabase()
3. **ProcessMaintenance()** - Line 211: Calls UpdateMaintenanceDatabase()
4. **ActivateFreeze()** - Line 423: Calls UpdateFreezeDatabase()

## Boot Initialization: InitializationManager.dm

### LoadAllDeeds() Proc (Line ~250)
```dm
proc/LoadAllDeeds()
  world.log << "DEED BOOT: Starting deed restoration..."
  GetAllDeedsFromSQLite()
  world.log << "DEED BOOT: Deed restoration complete"
```

### Spawn Schedule
```dm
spawn(51) LoadAllDeeds()  // Tick 51 (255ms after boot)
```
**Timing**: After SQLite ready (tick 2-3), right after DeedDataManager lazy init (tick 50).

## Type System Solution

**Challenge**: BYOND DM's lack of strong type inference prevented untyped proc parameters from accessing object properties.

**Error Examples**:
```
dm/SQLitePersistenceLayer.dm:1026:error: deed.center_turf.x: undefined var
dm/ImprovedDeedSystem.dm:67:error: owner_key.len: undefined var
```

**Solutions Applied**:
1. **Explicit Parameter Typing**: `proc/SaveDeedToSQLite(obj/DeedToken_Zone/deed, owner_ckey)`
   - Compiler now knows `deed` is `/obj/DeedToken_Zone` type
   - Can resolve property access like `deed.zone_id`

2. **Turf Property Extraction**: Extract turf into typed variable
   ```dm
   var/turf/ct = deed.center_turf
   if(ct)
     center_x = ct.x  // Safe now
   ```
   - Avoids chained property access on potentially untyped objects

3. **String Length Function**: `length(owner_key)` instead of `owner_key.len`
   - `.len` is only for lists/arrays in BYOND
   - `length()` works for strings

## Test Plan

### Phase 5 Verification Checklist
1. **Deed Creation**: Create new deed, verify appears in deeds table
2. **Deed Loading**: Check server logs for "DEED BOOT: Loaded X deeds from database"
3. **Maintenance Update**: Modify deed maintenance_due, verify UPDATE query executes
4. **Freeze Update**: Activate freeze on deed, verify UpdateDeedFreezeStatus() called
5. **Restoration**: Restart world, verify all deeds recreated from database
6. **Data Integrity**: Check deed properties match pre-restart values

### Manual Test Commands
```dm
// Check if deeds loaded from database
GetAllDeeds()

// Verify deed in database
SELECT COUNT(*) FROM deeds;

// Check deed specific entry
SELECT * FROM deeds WHERE deed_id=1;
```

## Architecture Summary

### Deed Persistence Flow
```
Deed Creation (InitializeTier)
    ↓
SaveToDatabase() called
    ↓
SaveDeedToSQLite(src, owner_key)
    ↓
INSERT/REPLACE into deeds table
    ↓
[STATE PERSISTED]

On Modification (maintenance, freeze)
    ↓
UpdateMaintenanceDatabase() / UpdateFreezeDatabase()
    ↓
UPDATE deeds SET ... WHERE deed_id=?
    ↓
[STATE SYNCED]

On World Boot
    ↓
LoadAllDeeds() at tick 51
    ↓
GetAllDeedsFromSQLite() - SELECT all deed_ids
    ↓
LoadDeedFromSQLite(deed_id) for each
    ↓
Create DeedToken_Zone objects in world
    ↓
[FULL STATE RESTORED]
```

## Build Status
✅ **Compilation**: 0 errors, 22 warnings  
✅ **All Procs**: Type-safe with explicit parameter typing  
✅ **Integration**: Hooked into all deed lifecycle events  
✅ **Boot Loading**: Scheduled at correct tick (51)  

## Related Phases
- [[Phase 4: HUD State Persistence]] - Completed 12/17/25
- [[Phase 3: NPC Merchant Persistence]] - Completed
- [[Phase 2: Market Board Persistence]] - Completed
- [[Phase 1: DM Compilation Fixes]] - Completed

## Lessons Learned

### BYOND Type System
- **Explicit typing required**: Untyped parameters can't resolve object properties
- **Proper syntax**: `proc/name(obj/Type/param)` not `proc/name(param as obj/Type)`
- **Turf property access**: Extract into typed variable to avoid chained access errors

### SQLite Patterns
- **JSON serialization**: Use `json_encode(list)` for complex types, `json_decode(text)` to restore
- **Parameter binding**: Always use `?` placeholders and pass list separately for safety
- **Boot timing**: Load deeds after SQLite ready (tick 2-3) but coordinate with other subsystems

### Integration Points
- New systems should call persisten persistence funcs at all state-change points
- Keep boot loading scheduled early but after dependencies (tick 50-100 range safe)
- Always log boot loading for debugging ("DEED BOOT: Loaded X deeds from database")

## Next Phase: Phase 6 (Pending)
**Market Price Dynamic Updates**
- Implement real-time price adjustments based on supply/demand
- Persist price history to SQLite
- Update market board UI with live price changes
- Expected: 1-2 hour implementation

---

**Session Completed**: 12/17/25 3:20 pm  
**Total Commits This Phase**: 1 (b6cd4c2)  
**Next Action**: Begin Phase 6 (Market Price Dynamic Updates) or User Request
