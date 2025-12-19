# Pondera Project Overview

**Project**: Pondera - Open-source BYOND survival MMO  
**Repository**: AERProductions/Pondera  
**Current Branch**: recomment-cleanup  
**Status**: Active Development (Phase 5)  
**Last Updated**: 2025-12-16

## Quick Facts
- **Size**: 150KB+ DM code across 85+ system files
- **Build System**: DreamMaker (BYOND)
- **Game Modes**: Story (PvE), Sandbox (Creative), PvP (Competitive)
- **Architecture**: Procedural terrain, elevation system, deed-based territory control
- **Persistence**: Binary chunk saves + character data savefiles

## Key Systems (Active)
1. **Initialization Manager** - 5-phase boot sequence (~400 ticks)
2. **Elevation System** - Multi-level vertical gameplay (decimal elevals)
3. **Procedural Map Generation** - Infinite terrain via 10x10 chunk lazy loading
4. **Movement & Sprint** - Direction-based with double-tap activation
5. **Deed System** - Territory control with permission enforcement
6. **Consumption Ecosystem** - Survival mechanics linked to seasons/biomes
7. **Unified Rank System** - 12 skill types with progression (1-5)
8. **Recipes & Crafting** - Dual unlock via skill + inspection
9. **Equipment System** - Real-time overlay rendering
10. **Three-Continent Architecture** - Story/Sandbox/PvP with distinct rules
11. **NPC & Recipe Teaching** - Dialogue-based learning
12. **Market & Economy** - Supply/demand pricing, dual currency

## Build Configuration
- **Main File**: Pondera.dme
- **Output**: Pondera.dmb (deployable binary)
- **Compile Order Critical**: New systems go BEFORE mapgen and InitializationManager
- **Current Status**: ✅ Compiles to 0 errors, 20 warnings
- **Latest Build**: 2025-12-16 (Fixed character creation UI)

## Recent Fixes (This Session)
| Fix | Status | Impact |
|-----|--------|--------|
| Removed alert-based character creation UI | ✅ Complete | Screen-only GUI now used |
| Consolidated LoginGateway flow | ✅ Complete | Clean initialization sequence |
| Fixed CharacterCreationIntegration references | ✅ Complete | No undefined proc calls |

## Next Steps
- [ ] Runtime testing: World initialization
- [ ] Runtime testing: Player login and character load
- [ ] Runtime testing: Toolbelt and HUD systems
- [ ] Market board UI refinement (Phase 5 focus)
- [ ] Recipe discovery rate balancing

## Repository Links
- **Main Repo**: https://github.com/AERProductions/Pondera
- **Recoded Branch**: https://github.com/AERProductions/Pondera-Recoded
- **Docs**: See `/Engineering/Pondera/` for detailed system docs

## Related Notes
- [[Architecture-Decisions]]
- [[Build-System-Reference]]
- [[Character-Creation-UI-Fix]]
