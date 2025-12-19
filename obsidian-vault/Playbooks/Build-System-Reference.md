# Build System Reference

**Last Updated**: 2025-12-16  
**Build Tool**: DreamMaker 516.1673 (BYOND)  
**Target**: Pondera.dme → Pondera.dmb

## Quick Build
```powershell
cd 'c:\Users\ABL\Desktop\Pondera'
& 'C:\Program Files (x86)\BYOND\bin\dm.exe' 'Pondera.dme'
```

## Current Build Status
```
✅ Status: CLEAN (0 errors, 20 warnings)
📦 Output: Pondera.dmb
⏱️  Time: ~1 second
🔧 Version: DM 516.1673
📅 Date: 2025-12-16
```

## .dme Include Order (CRITICAL)
The order matters - later includes can override earlier ones!

### Structure
```
1. Defines & Interfaces
   - !defines.dm
   - Interfacemini.dmf

2. Core Libraries
   - libs/Fl_ElevationSystem.dm
   - libs/Fl_AtomSystem.dm
   - (other core libs)

3. Foundation Systems
   - dm/movement.dm
   - dm/damage.dm
   - dm/time.dm
   - dm/persistence.dm

4. Specialized Systems
   - dm/CookingSystem.dm
   - dm/FarmingSystem.dm
   - dm/deed.dm
   - dm/equipment/*

5. UI & Display
   - dm/HUDManager.dm
   - dm/CharacterCreationGUI.dm
   - dm/CharacterCreationIntegration.dm
   - (NO CharacterCreationUI.dm ✅)

6. Initialization LAST
   - dm/InitializationManager.dm
   - mapgen/backend.dm
   - mapgen/biome_*.dm
```

## Common Errors & Fixes

| Error | Cause | Fix |
|-------|-------|-----|
| `undefined proc` | Missing include or typo | Check .dme order, verify file exists |
| Circular dependency | A includes B, B includes A | Reorder to break cycle |
| Variable type mismatch | Savefile format changed | Bump SavefileVersioning.dm version |
| `set waitfor` issues | Background proc in wrong place | Move initialization to phases |

## Adding New Systems
1. Create file in `dm/` folder
2. Add `#include` **BEFORE** mapgen block
3. Define `RegisterInitComplete()` if needed
4. Rebuild: `dm.exe Pondera.dme`
5. Verify: 0 errors

## Integration Checklist
- [ ] File created in appropriate folder
- [ ] Added to Pondera.dme BEFORE mapgen
- [ ] Compiles with 0 errors
- [ ] `/proc/` or `/datum/` properly typed
- [ ] Initialization gated on `world_initialization_complete`
- [ ] Documentation added to Engineering/ notes

## Performance Notes
- **Compilation Time**: ~1 sec (watch for increases)
- **Warnings**: 20 (mostly unused vars, acceptable)
- **Binary Size**: ~500KB (watch for bloat)
- **Runtime FPS**: 40 TPS (world.fps setting)

## Quick Reference Commands
```powershell
# Full build
dm.exe Pondera.dme

# Start server (testing)
dreamdaemon.exe Pondera.dmb 5900 -trusted

# View errors only
dm.exe Pondera.dme 2>&1 | findstr error

# View warnings
dm.exe Pondera.dme 2>&1 | findstr warning
```

## Version History
| Date | Status | Changes |
|------|--------|---------|
| 2025-12-16 | ✅ Clean | Removed CharacterCreationUI.dm (251→0 errors) |
| 2025-12-15 | ✅ Clean | Final build after audit |
| Earlier | Various | See git history |

## Related Notes
- [[Project-Overview]]
- [[Character-Creation-UI-Fix]]
- [[Initialization-Manager]]
