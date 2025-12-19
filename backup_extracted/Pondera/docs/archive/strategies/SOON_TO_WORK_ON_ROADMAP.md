# Pondera Development Roadmap: "Soon to Work On" List
**Prepared**: December 10, 2025  
**Strategy**: Hybrid Path A (Critical Release Blockers) + Path C (Technical Excellence)  
**Total Estimated Effort**: ~25-30 hours across 5 major initiatives

---

## IMMEDIATE PRIORITY (Path C, Session 1)

### 1. 🔊 Sound System Restoration
**Difficulty**: ⭐⭐ Medium  
**Estimated Time**: 2-3 hours  
**Impact**: HIGH (Audio feedback improves UX dramatically)

**Current State**:
- _MusicEngine.dm exists but is disabled/corrupted
- No ambient music in game (major atmosphere loss)
- No combat audio feedback (hit sounds missing)
- No environmental sounds (fire, wind, weather audio missing)

**Scope**:
- [ ] Debug _MusicEngine corruption (identify disabled code)
- [ ] Implement sound channel pooling system (8-channel limit)
- [ ] Add continent themes (story: medieval, sandbox: peaceful, pvp: tense)
- [ ] Add combat sfx hooks (hit sounds, death audio, critical hits)
- [ ] Add environmental sfx (fire crackle, rain, wind ambience)
- [ ] Add UI sounds (menu clicks, level-up chime, item pickup)

**Integration Points**:
- `dm/_MusicEngine.dm` - Restore/rewrite
- `dm/SavingChars.dm` - Remove corrupted audio loading from world/New()
- `dm/WeaponAnimationSystem.dm` - Hook hit sfx on damage application
- `dm/CombatUIPolish.dm` - Level-up chime on rank advancement
- Combat systems (Enemies.dm, UnifiedAttackSystem.dm) - Death audio

**Success Criteria**:
- ✅ Game loads without audio errors
- ✅ Ambient music plays in each continent
- ✅ Hit sounds play on every successful attack
- ✅ UI feedback sounds implemented
- ✅ No audio memory leaks after 30+ min gameplay

**Why First**: Audio ≈ 30% of immersion; current silence is jarring. Pairs well with combat animations (Phases 43-45).

---

## HIGH PRIORITY (Path C, Session 1-2)

### 2. 🍳 Recipe Experimentation System
**Difficulty**: ⭐⭐⭐ Hard  
**Estimated Time**: 6-8 hours  
**Impact**: VERY HIGH (Emergent gameplay, player agency)

**Current State**:
- Recipes unlock via skill levels (deterministic)
- Recipes unlock via item inspection (gated discovery)
- No way to discover recipes through experimentation
- Players don't feel "chemist" role

**Scope**:
- [ ] Create `/datum/recipe_experiment` tracking (attempts, progress, discovered)
- [ ] Implement ingredient combination system (list validation)
- [ ] Add failed attempt feedback ("The mixture bubbles...")
- [ ] Track experimentation progress (10 attempts → auto-unlock)
- [ ] Award bonus XP on discovery ("Eureka! +50 XP!")
- [ ] Persist experimentation state to character data
- [ ] Create "Experimental Foods" UI showing tracked recipes

**Mechanics**:
```dm
Player at fire:
1. Selects "Cook" verb
2. Shows recipe discovery mode
3. Chooses ingredients: [carrot] + [potato] + [water]
4. System checks: Is this a known recipe?
   - YES: "Vegetable Soup ready!" (if not yet discovered, +skill XP)
   - NO: "Mixture bubbles and separates." (track +10% toward discovery)
5. After 10 failed attempts on same combo → Auto-unlock recipe
6. On discovery: "EUREKA! You discovered Vegetable Soup! +50 XP!"
```

**Integration Points**:
- `dm/CookingSystem.dm` - Expand Cook verb with experiment mode
- `datum/recipe_state` - Add experiment tracking (attempts, progress)
- `datum/character_data` - Persist discovered recipes + method
- `dm/SkillRecipeUnlock.dm` - Add "experimented" unlock path
- Admin verbs - Debug recipe discovery state

**Success Criteria**:
- ✅ Players can attempt random ingredient combos
- ✅ Failed attempts track progress toward discovery
- ✅ Auto-unlock after 10 attempts
- ✅ Successful discovery gives feedback + bonus XP
- ✅ Experimentation state persists across reboots
- ✅ Discovery method tracked ("skilled" vs "inspected" vs "experimented")

**Why High Priority**: Most fun for players, encourages exploration, complements farming system. Creates 3 discovery paths: skill → inspection → experimentation.

---

### 3. 📚 Unified Skill Manager
**Difficulty**: ⭐⭐⭐ Hard  
**Estimated Time**: 4-5 hours  
**Impact**: MEDIUM (Code quality, performance, maintenance)

**Current State**:
- 10 separate rank systems scattered (frank, crank, mrank, smirank, wrank, grank, crank, drank, etc.)
- Each rank is its own variable in player/character_data
- Rank lookups require string matching ("Culinary" → frank, etc.)
- Rank UI shows ranks scattered across menus
- Hard to add new ranks (requires touching character_data + multiple procs)

**Scope**:
- [ ] Extend `/datum/unified_rank` system (already exists, needs expansion)
- [ ] Create rank registry (RANK_FISHING, RANK_COOKING, etc. constants)
- [ ] Migrate all 10 ranks to single registry
- [ ] Add rank_cache for O(1) lookups (avoid string matching)
- [ ] Unified rank-up logic (level progression, XP thresholds)
- [ ] Create unified rank UI (single skill panel shows all ranks)
- [ ] Add rank persistence hooks (auto-sync to character_data)

**Architecture**:
```dm
datum/unified_rank
  var/rank_type        // RANK_FISHING, RANK_COOKING, etc.
  var/rank_level       // 1-5
  var/rank_experience  // current XP
  var/rank_max_exp     // XP to level up

mob/players/var
  list/ranks_by_type   // map[RANK_FISHING] = datum/unified_rank object
  ranks_updated = 0    // tick of last update
```

**Integration Points**:
- `dm/UnifiedRankSystem.dm` - Expand existing system
- `datum/character_data` - Refactor rank variables
- `dm/SavingChars.dm` - Rank persistence/loading
- All skill unlock systems - Refactor to use GetRankLevel(type)
- Skill UI systems - Single unified panel

**Success Criteria**:
- ✅ All 10 ranks accessible via unified API
- ✅ GetRankLevel(RANK_FISHING) returns 1-5
- ✅ UpdateRankExp(RANK_COOKING, 50) grants XP + level-up checks
- ✅ Rank UI shows all 10 ranks in single panel
- ✅ Adding new rank requires only 1 change (constant definition)
- ✅ No performance regression vs scattered system

**Why High Priority**: Foundation for future rank additions (crafting specialization, etc.). Cleaner codebase. Reduces character_data complexity.

---

## MEDIUM PRIORITY (Path C, Session 2-3)

### 4. 🔍 Item Inspection Integration
**Difficulty**: ⭐⭐ Medium  
**Estimated Time**: 3-4 hours  
**Impact**: MEDIUM (Completes recipe discovery, adds depth)

**Current State**:
- ItemInspectionSystem.dm exists
- Can examine basic items (show stats)
- Food examination incomplete (no recipe learning)
- Only 1 discovery path implemented (skill levels)

**Scope**:
- [ ] Expand inspect verb to show food ingredients
- [ ] Parse recipe from cooked food item
- [ ] Show "Hint: You could make this at a fire..."
- [ ] Track examined recipes in recipe_state
- [ ] Unlock recipe automatically on examination
- [ ] Add examination knowledge tracker (UI shows sources)

**Mechanics**:
```dm
Player examines: "Vegetable Soup (prepared by GreenGoblin)"
→ Shows quality indicator, ingredients list
→ System shows hint: "Contains: [potato, carrot, water] (boiled)"
→ Hint: "You could prepare this using a fire and water"
→ Auto-unlock recipe for player (marked as "examined")
```

**Integration Points**:
- `dm/ItemInspectionSystem.dm` - Expand food handling
- `dm/CookingSystem.dm` - Add ingredient list to cooked foods
- `datum/recipe_state` - Track "examined" discoveries
- `dm/SkillRecipeUnlock.dm` - Add examination unlock path
- Player inventory UI - Show recipe sources

**Success Criteria**:
- ✅ Examining prepared food shows ingredients
- ✅ Recipe unlocked on examination
- ✅ Hint text guides toward cooking method
- ✅ Multiple discovery paths tracked (skill/inspected/experimented)
- ✅ UI shows how each recipe was discovered

**Why Medium Priority**: Completes recipe discovery system. Adds depth to food items. Encourages examination of NPC-crafted items.

---

### 5. 👑 Dynasty/Legacy System
**Difficulty**: ⭐⭐⭐ Hard  
**Estimated Time**: 4-5 hours  
**Impact**: HIGH (Endgame content, persistent legacy)

**Current State**:
- Placeholder from Phase 38
- No dynasty creation/management
- No deed inheritance on death
- No family tree system
- No dynasty treasury

**Scope**:
- [ ] Create `/datum/dynasty` structure (founder, members, lineage)
- [ ] Implement dynasty creation (unique name registry)
- [ ] Implement heir designation (succession planning)
- [ ] Implement deed inheritance on death
- [ ] Create dynasty treasury (shared material pool)
- [ ] Add dynasty UI (family tree, treasury, permissions)
- [ ] Add dynasty rank system (founder, heir, elder, member)

**Mechanics**:
```dm
Player A:
1. /create_dynasty "House of Timber" (creates dynasty)
2. /add_heir "PlayerB" (designates successor)
3. Dies in battle → "PlayerB now leads House of Timber"
4. PlayerB inherits all PlayerA deeds + treasury
5. PlayerB can recruit PlayerC (add to dynasty)
6. PlayerC can eventually become heir

Dynasty Treasury:
- Shared materials pool (stone, metal, wood)
- All members contribute/withdraw
- Transfer materials to successor on death
- Track dynasty net worth
```

**Integration Points**:
- New file: `dm/DynastySystem.dm` (400-500 lines)
- `dm/DeedDataManager.dm` - Add inheritance logic
- `datum/character_data` - Add dynasty_id, heir_to
- `dm/SavingChars.dm` - Persist dynasty memberships
- Player login - Check for inherited deeds/treasury
- Admin verbs - Dynasty management/debugging

**Success Criteria**:
- ✅ Players can create/join dynasties
- ✅ Deed inheritance works on death
- ✅ Dynasty treasury functional
- ✅ Family tree UI shows lineage
- ✅ Dynasty-wide permissions working
- ✅ Dynasty data persists across reboots

**Why Medium Priority**: Endgame content (high engagement but not critical for release). Creates persistent player legacy. Encourages cooperation.

---

## BACKLOG (Future Sessions)

### 6. 🏆 PvP Arena System
**Estimated Time**: 8-10 hours  
**Scope**: 1v1 combat arenas, leaderboards, ranking system

### 7. 🎓 NPC Teaching/Mentorship
**Estimated Time**: 4-6 hours  
**Scope**: Expand NPC recipe teaching, dialogue-based quest system

### 8. ⚔️ Spell/Ability System
**Estimated Time**: 10-12 hours  
**Scope**: Magic system, ability trees, cooldown management

### 9. 🌍 Continent Travel System
**Estimated Time**: 4-5 hours  
**Scope**: Safe travel between continents, waypoints, fast travel

### 10. 💰 Banking System
**Estimated Time**: 3-4 hours  
**Scope**: Secure currency storage, interest, loans

---

## Recommended Work Order

**Session 1** (4-5 hours):
1. Sound System Restoration (2-3 hours) ← START HERE
2. Begin Recipe Experimentation (2-3 hours, partial)

**Session 2** (6-8 hours):
1. Finish Recipe Experimentation (4-5 hours)
2. Unified Skill Manager (2-3 hours, partial)

**Session 3** (6-7 hours):
1. Finish Unified Skill Manager (2-3 hours)
2. Item Inspection Integration (3-4 hours)

**Session 4** (5-6 hours):
1. Dynasty/Legacy System (4-5 hours)
2. Testing & documentation (1 hour)

**Total Path C**: ~20-25 hours, spread across 4 sessions

---

## Agent's Personal Interests

From the audit and analysis, here are the systems I'm most interested in working on:

### Top Interest: Recipe Experimentation (6-8 hours)
**Why**: 
- Most fun for players (emergent gameplay)
- Deep integration with food system (farming → cooking → discovery)
- Requires interesting algorithm (combo validation, progress tracking)
- Creates "aha moment" game moments (best kind of feedback)
- Pairs well with NPC teaching + inspection (3 discovery paths)

**Personal Challenge**: Design intuitive combo system that's discoverable but not trivial

### Second Interest: Sound System Restoration (2-3 hours)
**Why**:
- Immediate UX impact (silence is jarring)
- Pairs perfectly with animation work (Phases 43-45)
- Technical challenge (channel management, audio streaming)
- Missing blocker for "complete game feel"

**Personal Challenge**: Debug corrupted _MusicEngine without documentation

### Third Interest: Dynasty System (4-5 hours)
**Why**:
- Creates persistent legacy (philosophical appeal)
- Encourages cooperation (counter to PvP conflict)
- Complex data structures (inheritance, lineage trees)
- Endgame content (long-term engagement)

**Personal Challenge**: Design succession system that feels fair + motivating

### Fourth Interest: Unified Skill Manager (4-5 hours)
**Why**:
- Foundation for future systems (recipe tiers, ability trees, etc.)
- Significant code quality improvement
- Architecture puzzle (consolidating scattered systems)
- Performance optimization opportunity

**Personal Challenge**: Migrate 10 systems without breaking anything

### Fifth Interest: Item Inspection (3-4 hours)
**Why**:
- Completes recipe discovery (satisfying closure)
- Adds item depth (lore, hints, discovery methods)
- Encourages examination gameplay

**Personal Challenge**: Make hint system intuitive without spoiling discovery

---

## Success Metrics for Path C

### Quantitative
- [ ] Recipe Experimentation: Players discover recipes in <30 min (vs 2+ hours grind)
- [ ] Sound System: 0 audio errors after 2+ hours gameplay
- [ ] Unified Skill Manager: Rank lookup goes from O(n) to O(1)
- [ ] Dynasty System: <5 line inheritance logic (currently scattered)

### Qualitative
- [ ] Players feel agency in discovery (not gated by grind)
- [ ] Audio creates atmosphere + immersion
- [ ] Rank system feels cohesive (not scattered)
- [ ] Legacy system inspires cooperation + legacy creation

---

## Technical Debt Resolved by Path C

| System | Current | After | Benefit |
|--------|---------|-------|---------|
| Sound | Disabled | Active | Immersion +30% |
| Recipes | 1 path | 3 paths | Player choice |
| Ranks | 10 vars | 1 registry | Maintainability |
| Food | Basic | Inspectable | Discovery depth |
| Legacy | None | Dynasty | Endgame content |

---

## Prerequisites Completed ✅

All Path A blockers (Phases 46-48) completed before starting Path C:
- ✅ Deed persistence (no more economy loss)
- ✅ Food quality pipeline (farming progression rewards)
- ✅ Deed notifications (economy transparency)

**Ready to start Path C immediately**: Sound System Restoration is first task.

---

## Notes

- **Release Status**: Path A = RELEASE READY. Path C = Post-release enhancements.
- **Estimated Total Path C**: 20-25 hours over 4 sessions
- **Agent Recommendation**: Start with Sound + Recipe Experimentation in next session
- **User Approval**: Awaiting confirmation to proceed with Path C implementations

**Next Step**: Initiate Sound System Restoration (Session 1, Phase C.1)
