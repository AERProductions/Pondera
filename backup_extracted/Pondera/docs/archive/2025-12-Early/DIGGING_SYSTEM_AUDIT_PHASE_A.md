# Digging/Landscaping System - Comprehensive Audit & Modernization Strategy

**Status:** PHASE A (Audit) - IN PROGRESS  
**Files Analyzed:**
- `dm/jb.dm` - 8794 lines (legacy system, mostly dead code)
- `dm/LandscapingSystem.dm` - 262 lines (modern system)

---

## Quick Findings

### jb.dm Composition
- **Total lines:** 8794
- **Commented lines:** ~673 (7.6%)
- **Blank lines:** ~227 (2.6%)
- **Active code:** ~7900 lines (90%)

**Problem:** The file is mostly active legacy code that duplicates functionality already implemented in LandscapingSystem.dm

### Syntax Errors Found

1. **Line 11:** `var/M.UED = 0` 
   - INVALID: Should be `var` on separate line or just in verb
   - Causes compilation error
   - Needs immediate fix

### Modern Code Already Exists

✅ **LandscapingSystem.dm** has modern implementations of:
- CreateLandscapeObject() - unified object creation
- Rank progression using UnifiedRankSystem
- Permission checking via CanPlayerBuildAtLocation()
- Stamina cost deduction
- XP awards via UpdateRankExp()

---

## Strategic Approach

### Phase A-1: Immediate Syntax Fix (5 mins)

Fix line 11 in jb.dm to allow compilation:
```dm
// CURRENT (BROKEN):
var/M.UED = 0

// FIX:
var/global/M_UED = 0  // Or just delete if unused
```

**Action:** Search for references to this variable and remove if unused

### Phase A-2: Dead Code Identification (1-2 hours)

Scan jb.dm for:
1. Commented-out code blocks (estimate: 500-700 lines)
2. Deprecated proc definitions (estimate: 100-200 lines)
3. Duplicate verb/proc code (cross-reference with LandscapingSystem.dm)
4. Unused variable declarations (estimate: 50-100 lines)

### Phase A-3: Dependency Mapping (1-2 hours)

Find all references to jb.dm code:
- Which objects depend on it?
- Which verbs are actually called?
- What is `Dig()` verb used for vs LandscapingSystem.dm?
- Are there competing implementations?

### Phase B: Modern Integration (4-6 hours)

Once Phase A complete:
1. Consolidate all working code into LandscapingSystem.dm
2. Delete jb.dm entirely (move any unique code first)
3. Update all references to point to modern system
4. Add E-key support via UseObject() handlers

---

## Key Questions to Answer

1. **Are jb.dm and LandscapingSystem.dm both active?**
   - If yes: Which takes precedence?
   - If both: Why the duplication?

2. **What is the Dig() verb in jb.dm doing vs the landscaping in LandscapingSystem.dm?**
   - Same functionality?
   - Different use cases?

3. **What are the deprecated proc calls?**
   - `digunlock()` - Still used?
   - `digcheck()` - Still used?
   - `exp2lvl()` - Still used? (This caused an error in plant.dm)

4. **Can we safely delete jb.dm or is it still needed for some functionality?**

---

## Recommendations

### Immediate (Next 30 mins):
1. Fix line 11 syntax error - allows clean build
2. Document which code is actually used vs dead

### Short-term (1-2 hours):
1. Complete Phase A audit
2. Identify deprecated procs across codebase
3. Create detailed migration plan

### Medium-term (4-6 hours - Dedicated session):
1. Consolidate active code into LandscapingSystem.dm
2. Delete jb.dm
3. Test all digging mechanics
4. Add E-key support

---

## Expected Outcome

- **Before:** 8794 lines in jb.dm + 262 in LandscapingSystem.dm = 9056 lines
- **After:** ~300-400 lines in LandscapingSystem.dm (consolidated)
- **Savings:** 8500+ lines removed (90%+ reduction)
- **Benefit:** Clean, modern, maintainable code

---

**Next Step:** Fix line 11 syntax error and begin Phase A detailed audit
