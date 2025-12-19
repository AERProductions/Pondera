# Documentation Cleanup & HudGroups Integration Plan
**Date**: December 17, 2025  
**Status**: In Progress  
**Target**: Clean root directory, consolidate docs, complete HudGroups implementation

## Markdown File Inventory

### Current State
- **Root**: 107 markdown files (cluttered)
- **docs/**: 59 markdown files (organized)
- **Total**: 166 markdown files to organize

### Categories Found
- **Session Logs**: ~12 files (SESSION_*.md)
- **Status Reports**: ~7 files (BUILD_*, READY_*, FINAL_*)
- **Audits**: ~8 files (COMPREHENSIVE_*, LEGACY_*, AUDIT_*)
- **System Docs**: ~80 files (CLIMBING_*, FISHING_*, CRAFTING_*, etc.)

## Organization Plan

### Target Hierarchy
```
docs/
├── Archive/
│   ├── 2025-12-Early/          (Pre-Dec-15 files)
│   └── 2025-12-Mid/            (Dec-15 to Dec-17)
├── Sessions/                   (Session logs & summaries)
│   ├── Session_Logs/
│   └── Daily_Progress/
├── Status/                     (Build reports, verification, audits)
│   ├── Build_Reports/
│   ├── System_Audits/
│   └── Verification/
├── Systems/                    (Feature documentation)
│   ├── Climbing/
│   ├── Fishing/
│   ├── Crafting/
│   ├── Equipment/
│   ├── Deeds/
│   ├── HUD/
│   └── (etc.)
├── Architecture/               (Design decisions, ADRs)
└── Integration/                (Cross-system guides)
```

## HudGroups Library Analysis

### Current Location
`lib/forum_account/hudgroups/`

### Components Found
- **Core**: hud-groups.dm, hud-groups.dme, fonts.dm
- **Demos**: chat-demo/, flyout-menu-demo/, health-bar-demo/, interface-demo/, inventory-demo/, menu-demo/, message-box-demo/, minimap-demo/, party-demo/, text-demo/
- **Assets**: *.dmi, *.dmb, *.rsc files

### Integration Status
- ❓ Not yet integrated into Pondera.dme
- ❓ Login/CharGen systems still legacy (alert-based, needs HudGroups replacement)
- ✅ HUD system exists (PonderaHUDSystem.dm, HUDManager.dm)
- ⚠️ HudGroups demos available but not wired to actual gameplay

## Migration Strategy

### Phase 1: Documentation Cleanup (This Session)
1. Create docs/ subdirectory structure
2. Move 107 root .md files to appropriate folders
3. Archive pre-Dec-15 files
4. Update memory bank with key decisions from docs

### Phase 2: HudGroups Full Integration (Next Session)
1. Study hudgroups demos (especially interface-demo/, inventory-demo/)
2. Create modern character creation UI using HudGroups
3. Replace legacy alert-based character creation
4. Integrate HudGroups into Pondera.dme
5. Test end-to-end login/chargen flow

### Phase 3: Phase Out Legacy (Future)
1. Remove old CharacterCreationUI.dm (alert-based)
2. Remove old character creation procs
3. Update LoginGateway to use HudGroups-based flow
4. Test and verify clean build

## Quick Wins

1. **Move 107 files** → 15 minutes (scripted move)
2. **Archive old files** → 5 minutes (identify by date)
3. **Index to obsidian** → 30 minutes (read key docs)
4. **Update memory bank** → Continuous as we work

## Next Steps
1. ✅ (In progress) Index markdown content
2. Create docs/ subdirectories
3. Move/organize files
4. Git commit
5. Begin HudGroups deep dive

## Key Decisions to Track
- [ ] Keep vs Archive threshold (pre-Dec-15 = archive)
- [ ] HudGroups integration approach (phased vs immediate)
- [ ] Legacy login/chargen replacement timeline
- [ ] Build verification after each major change
