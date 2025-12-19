# SQLite 3.51.1 Setup for Pondera

## Directory Structure
```
Pondera/
├── db/
│   ├── lib/                      # SQLite DLLs go here
│   │   ├── sqlite3.dll          # Main SQLite DLL
│   │   └── sqlite3.def          # (optional) export definitions
│   ├── pondera.db               # Main database file (auto-created)
│   ├── schema.sql               # Database schema
│   ├── migrations/              # Schema change scripts
│   └── SQLITE_SETUP_GUIDE.md    # This file
├── dm/
│   ├── SQLitePersistenceLayer.dm
│   ├── SQLiteIntegration.dm
│   └── ...
└── Pondera.dme
```

## Step 1: Download SQLite 3.51.1

**Option A: Official SQLite Website (Manual)**
1. Visit: https://www.sqlite.org/download.html
2. Look for "Precompiled Binaries for Windows"
3. Download: `sqlite-dll-win32-x86-3510100.zip` (or latest available)
4. Extract to `db/lib/`

**Option B: GitHub Releases**
1. Visit: https://github.com/sqlite/sqlite/releases
2. Find version 3.51.0 or closest available
3. Download the Windows DLL package
4. Extract to `db/lib/`

**Option C: Chocolatey (if you have it)**
```powershell
choco install sqlite
# Then copy DLL to db/lib/
```

## Step 2: Extract Files

After downloading the ZIP, extract to `db/lib/`:
```
db/lib/
├── sqlite3.dll
├── sqlite3.def (optional)
└── [other files]
```

**Minimum required**: `sqlite3.dll`

## Step 3: BYOND DLL Integration

BYOND can call DLLs using the `call_ext()` function. However, BYOND has limitations:

### Current Approach for Pondera

Since BYOND's native DLL integration is limited, we'll use **SQLite CLI** instead:

```dm
// In dm/SQLitePersistenceLayer.dm
proc/ExecuteSQLiteCommand(command, arguments[])
    // Run: sqlite3.exe db/pondera.db "SELECT ..."
    // Capture output and parse results
```

## Step 4: SQLite CLI Setup

1. Download: `sqlite-tools-win32-x86-3510100.zip` from https://www.sqlite.org/download.html
2. Extract `sqlite3.exe` to: `db/lib/sqlite3.exe`
3. Test:
```powershell
cd c:\Users\ABL\Desktop\Pondera\db\lib
.\sqlite3.exe --version
```

## Step 5: Create Database Schema

Create `db/schema.sql`:

```sql
-- Character data tables
CREATE TABLE IF NOT EXISTS players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    ckey TEXT UNIQUE NOT NULL,
    char_name TEXT NOT NULL,
    game_mode TEXT DEFAULT 'story',
    current_continent TEXT DEFAULT 'story',
    level INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    last_logout TIMESTAMP,
    online_status BOOLEAN DEFAULT 0,
    ascension_mode BOOLEAN DEFAULT 0,
    death_count INTEGER DEFAULT 0
);

CREATE TABLE IF NOT EXISTS character_skills (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL,
    skill_name TEXT NOT NULL,
    rank_level INTEGER DEFAULT 0,
    current_exp INTEGER DEFAULT 0,
    max_exp_threshold INTEGER DEFAULT 100,
    FOREIGN KEY(player_id) REFERENCES players(id),
    UNIQUE(player_id, skill_name)
);

CREATE TABLE IF NOT EXISTS currency_accounts (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_id INTEGER NOT NULL UNIQUE,
    lucre INTEGER DEFAULT 0,
    stone INTEGER DEFAULT 0,
    metal INTEGER DEFAULT 0,
    timber INTEGER DEFAULT 0,
    banked_lucre INTEGER DEFAULT 0,
    FOREIGN KEY(player_id) REFERENCES players(id)
);

-- Add more tables as needed...
```

## Step 6: Initialize Database on World Boot

The `InitializeSQLiteDatabase()` proc will:
1. Check if `db/pondera.db` exists
2. If not, create it and run `schema.sql`
3. Verify schema integrity

## File Layout After Setup

```
Pondera/
├── db/
│   ├── lib/
│   │   ├── sqlite3.exe              ← CLI executable
│   │   ├── sqlite3.dll              ← DLL library
│   │   └── sqlite3.def              ← (optional)
│   ├── pondera.db                   ← Auto-created on first run
│   ├── schema.sql                   ← Schema definitions
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_add_reputation.sql
│   │   └── [etc.]
│   └── SQLITE_SETUP_GUIDE.md
├── dm/
│   ├── SQLitePersistenceLayer.dm    ← Core CRUD + CLI wrapper
│   ├── SQLiteIntegration.dm         ← Integration with login/logout
│   └── Pondera.dme (updated)
└── [rest of project]
```

## Testing the Setup

### Manual Test (PowerShell):
```powershell
cd c:\Users\ABL\Desktop\Pondera\db\lib
.\sqlite3.exe -version

# If needed, initialize database:
# .\sqlite3.exe ../pondera.db < ../schema.sql
```

### In-Game Test (After DM implementation):
```dm
// In a debug verb or on boot
var/result = ExecuteSQLite("SELECT COUNT(*) FROM players;")
world.log << "Players in database: [result]"
```

## BYOND Integration Strategy

Since BYOND's `call_ext()` doesn't work well with SQLite DLL directly, we'll use **CLI + shell piping**:

```dm
// dm/SQLitePersistenceLayer.dm

proc/ExecuteSQLite(query)
    // Write query to temp file
    var/tmpfile = "temp_query_[rand(1,99999)].sql"
    var/file/F = file(tmpfile)
    F << query
    F.close()
    
    // Run sqlite3.exe and capture output
    var/cmd = "sqlite3.exe db/pondera.db < [tmpfile]"
    var/output = shell(cmd)  // BYOND's shell() function
    
    // Delete temp file
    fdel(tmpfile)
    
    return output
```

## Next Steps

1. **Download SQLite** from official source
2. **Extract to `db/lib/`**
3. **Create `db/schema.sql`** (schema provided above)
4. **Implement `dm/SQLitePersistenceLayer.dm`** with CLI wrapper
5. **Wire into login/logout** in `dm/SQLiteIntegration.dm`
6. **Test** character save/load cycle

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `sqlite3.exe` not found | Verify path: `db/lib/sqlite3.exe` |
| Database locked error | Check if another process is accessing `pondera.db` |
| Schema creation failed | Run manually: `sqlite3 db/pondera.db < db/schema.sql` |
| DLL not loading | Ensure `sqlite3.dll` is in `db/lib/` or system PATH |

## Resources

- SQLite Official: https://www.sqlite.org
- CLI Documentation: https://www.sqlite.org/cli.html
- SQL Tutorial: https://www.tutorialrepublic.com/sql-tutorial/
