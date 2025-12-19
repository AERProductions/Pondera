# Lighting System Clarification (2025-12-19)

**Status**: ✅ RESOLVED  
**Issue**: Two Fl_LightingCore.dm files - Do we need both?  
**Answer**: NO - Only libs/ version is used. dm/ was dead code.  

---

## The Investigation

### What We Found
| File | Included in .dme? | Used? | Size | Status |
|------|-------------------|-------|------|--------|
| **libs/Fl_LightingCore.dm** | ✅ YES (line 337) | ✅ YES | 185 lines | **ACTIVE** |
| **dm/Fl_LightingCore.dm** | ❌ NO | ❌ NO | 270 lines | **DEAD CODE** |

### Proof
- Only `libs/Fl_LightingCore.dm` appears in Pondera.dme
- `dm/Fl_LightingCore.dm` is **never loaded**
- `dm/Fl_LightingCore.dm` ends mid-code (incomplete draft)
- Boot calls `InitUnifiedLighting()` which exists in libs/ version

### Dependency Chain
```
Pondera.dme (line 337):
├─ #include "libs/Fl_LightingCore.dm" ✅ Active
│  └─ Defines: datum/light_emitter, ACTIVE_LIGHT_EMITTERS, InitUnifiedLighting()
│
dm/Fl_LightingIntegration.dm (line 121):
├─ Calls: InitUnifiedLighting()
│  └─ Uses: libs/Fl_LightingCore version only
```

---

## Resolution

### Action Taken
✅ **Deleted** dm/Fl_LightingCore.dm (270 lines of dead code)

### Verification
- Build: **0 errors, 43 warnings** ✅
- Binary size: 510K (slightly smaller)
- Commit: c167470

---

## Clarification: Lighting System Architecture

**Single Lighting Core** (now clear):
- **libs/Fl_LightingCore.dm** (185 lines)
  - Global registry: `ACTIVE_LIGHT_EMITTERS`, `ACTIVE_SPELL_LIGHTS`, `ACTIVE_WEATHER_LIGHTS`
  - Base class: `datum/light_emitter` with pulse, falloff, expiration
  - Procs: `create_light_emitter()`, `set_global_lighting()`, `cleanup_*`

**Integration Layer**:
- **dm/Fl_LightingIntegration.dm** 
  - Calls `InitUnifiedLighting()` on boot
  - Manages day/night cycle (color, intensity, darkness)
  - Starts background loop for cycle updates

**Additional Lighting Features** (complementary, not duplicates):
- **Lighting.dm** - Spotlight/cone overlays
- **DirectionalLighting.dm** - Directional light cones with rotation
- **ShadowLighting.dm** - Dynamic shadow overlays

---

## Conclusion

**We don't need two lighting cores.**  
Only the libs/ version is active. The dm/ version was an abandoned draft.

This resolves the confusion from the previous session where we thought both were needed.

---

**Build Status**: ✅ CLEAN  
**Codebase**: ✅ SIMPLIFIED  
**Ready**: ✅ YES

