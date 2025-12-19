# SQLite 3.51.1 Quick Setup - Pondera

## 📋 What's Been Created

✅ **Directory Structure**
```
Pondera/
├── db/
│   ├── lib/              ← SQLite DLLs go here
│   ├── pondera.db        ← Will be auto-created
│   ├── schema.sql        ← Created ✅
│   └── SQLITE_SETUP_GUIDE.md ← Created ✅
├── dm/
│   ├── SQLitePersistenceLayer.dm ← Created ✅
│   ├── InitializationManager.dm   ← Needs update
│   └── ...
└── Pondera.dme           ← Needs update
```

✅ **Files Created**
| File | Purpose | Status |
|------|---------|--------|
| `db/schema.sql` | Database tables & views | ✅ Ready |
| `dm/SQLitePersistenceLayer.dm` | CRUD operations | ✅ Ready |
| `db/SQLITE_SETUP_GUIDE.md` | Installation guide | ✅ Ready |

---

## 🚀 Installation Steps

### Step 1: Download SQLite 3.51.1

**Manual Download (Recommended)**:
1. Go to: https://www.sqlite.org/download.html
2. Find "Precompiled Binaries for Windows"
3. Download: `sqlite-dll-win32-x86-3510100.zip` (or latest)

**OR use Chocolatey** (if installed):
```powershell
choco install sqlite
```

### Step 2: Extract to Pondera

```powershell
# Navigate to project
cd c:\Users\ABL\Desktop\Pondera

# Extract contents of the ZIP to db/lib/
# Expected files:
# - db/lib/sqlite3.exe     (CLI tool)
# - db/lib/sqlite3.dll     (Library)
# - db/lib/[other files]
```

### Step 3: Verify Installation

```powershell
cd c:\Users\ABL\Desktop\Pondera\db\lib
.\sqlite3.exe --version

# Should output: 3.51.1 2025-... (or similar)
```

### Step 4: Initialize Database

```powershell
# From Pondera root directory
cd c:\Users\ABL\Desktop\Pondera

# Option A: Automatic (via DM code)
# - Build Pondera
# - Login to trigger InitializeSQLiteDatabase()

# Option B: Manual
.\db\lib\sqlite3.exe db\pondera.db < db\schema.sql
```

**Verify it worked**:
```powershell
.\db\lib\sqlite3.exe db\pondera.db "SELECT COUNT(name) FROM sqlite_master WHERE type='table';"
# Should return: 9 (tables created)
```

---

## 📝 Next: Update Pondera.dme

Add this to your `Pondera.dme` **before mapgen block**:

```dm
#include "dm/SQLitePersistenceLayer.dm"
```

---

## 🧪 Testing

### Test 1: Database Creation
```powershell
.\db\lib\sqlite3.exe db\pondera.db "SELECT name FROM sqlite_master WHERE type='table' ORDER BY name;"
```

Expected output:
```
character_appearance
character_recipes
character_skills
currency_accounts
faction_allegiance
knowledge_topics
market_board
market_history
npc_reputation
player_deeds
player_stats
players
schema_migrations
```

### Test 2: Query Players Table
```powershell
.\db\lib\sqlite3.exe db\pondera.db "SELECT COUNT(*) FROM players;"
```

Expected: `0` (empty initially)

### Test 3: Insert Test Data
```powershell
.\db\lib\sqlite3.exe db\pondera.db "INSERT INTO players (ckey, char_name) VALUES ('testuser', 'Test Character'); SELECT * FROM players;"
```

---

## 🎯 Integration Checklist

- [ ] Downloaded SQLite 3.51.1
- [ ] Extracted to `db/lib/`
- [ ] Verified `sqlite3.exe` runs
- [ ] Ran `db/schema.sql` to create database
- [ ] Verified 9 tables created
- [ ] Added `#include "dm/SQLitePersistenceLayer.dm"` to Pondera.dme
- [ ] Added `InitializeSQLiteDatabase()` call to InitializationManager.dm
- [ ] Built Pondera successfully
- [ ] Logged in and verified database auto-initialization
- [ ] Tested character save/load cycle

---

## ⚙️ Configuration

### File Paths (in SQLitePersistenceLayer.dm)
```dm
var/global/sqlite_db_path = "db/pondera.db"
var/global/sqlite_exe_path = "db/lib/sqlite3.exe"
var/global/sqlite_schema_path = "db/schema.sql"
```

If you move files, update these paths!

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| `sqlite3.exe not found` | Verify extraction to `db/lib/` |
| `Error: database is locked` | Close other SQLite clients |
| `Table already exists` | OK - schema uses `IF NOT EXISTS` |
| `No such table` | Run schema: `db\lib\sqlite3.exe db\pondera.db < db\schema.sql` |
| `Permission denied` | Ensure Pondera has write access to `db/` directory |

---

## 📚 Key Procs in SQLitePersistenceLayer.dm

| Proc | Purpose |
|------|---------|
| `InitializeSQLiteDatabase()` | Boot-time initialization |
| `SavePlayerToSQLite(mob/players/P)` | Export character on logout |
| `LoadPlayerFromSQLite(ckey)` | Import character on login |
| `ExecuteSQLiteQuery(query)` | Run any SQL query |
| `SavePlayerSkillsToSQLite()` | Backup skills |
| `LoadPlayerSkillsFromSQLite()` | Restore skills |

---

## 🔄 Data Flow

```
Player Login:
  1. client/New() called
  2. Character creation UI
  3. LoadPlayerFromSQLite(ckey) ← Restore from DB
  4. Apply skills, currency, appearance
  5. Player joins world

Player Logout:
  1. mob/Del() or disconnection
  2. SavePlayerToSQLite(mob) ← Backup to DB
  3. Character data persisted
```

---

## 📞 Next Steps

1. **Download and extract SQLite** → See Step 1-3 above
2. **Update Pondera.dme** → Add include
3. **Update InitializationManager.dm** → Call initialization
4. **Build and test** → Verify database creation
5. **Test save/load cycle** → Character data round-trip

---

**Status**: Ready for SQLite installation  
**Files Required**: SQLite 3.51.1 DLL from official source  
**Estimated Time**: 10 minutes (download) + 5 minutes (setup)
