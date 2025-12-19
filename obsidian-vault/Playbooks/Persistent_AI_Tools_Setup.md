# Persistent AI Tools Configuration
**Established:** 12/19/2025  
**Duration:** Forever (all future sessions)  
**Tools:** Memoripilot 24/7, Memory Bank, Obsidian Brain

---

## Why These Tools

### 1. Obsidian Brain (Global Knowledge Vault)
**Purpose:** Permanent project knowledge persistence across ALL workspaces  
**Location:** `C:\Users\ABL\Desktop\Pondera\obsidian-vault`  
**Directories:**
- `/Engineering/` - Project-specific notes & decisions
- `/Playbooks/` - Procedures & how-to guides
- `/Decisions/` - Architecture Decision Records (ADRs)
- `/Snippets/` - Reusable code patterns

**Session Protocol:**
1. **Start Session:** Search brain for relevant project context
2. **During Session:** Append important decisions/learnings to existing notes
3. **End Session:** Record session summary in `/Engineering/`
4. **Next Session:** Read latest session summary first

### 2. Memory Bank (Structured Context)
**Purpose:** Indexed, templated context for quick lookup  
**Files Used:**
- `activeContext.md` - Current working focus & status
- `progress.md` - Done/Doing/Next tasks (always update)
- `productContext.md` - Project architecture & tech stack
- `decisionLog.md` - Major decisions with rationale
- `systemPatterns.md` - Coding conventions & patterns

**Session Protocol:**
1. Read `activeContext.md` at session start
2. Update `progress.md` at session end
3. Update `activeContext.md` with new focus
4. Log decisions in `decisionLog.md` if strategic

### 3. Memoripilot (24/7 Continuity)
**Purpose:** Automatic context preservation across chat sessions  
**Capability:** Maintains conversation state across new threads  
**Setup:** Permanently enabled (no manual action needed)

**Session Protocol:**
1. Each new chat thread automatically inherits previous context
2. User can explicitly request "from memory bank"
3. Tools automatically search brain on large context changes

---

## Standard Initialization (Every Session)

### Step 1: Brain Search (5 minutes)
```
Search Obsidian brain for:
- Latest session summary
- Project status
- Recent decisions
- Architecture notes
```

### Step 2: Memory Bank Review (2 minutes)
```
Read:
- activeContext.md (current focus)
- progress.md (what's done/next)
- decisionLog.md (recent decisions)
```

### Step 3: Contextualize (2 minutes)
```
Ask: What was the last session about?
Ask: What are current blockers?
Ask: What's the top priority?
```

### Step 4: Work (Main session time)
```
- Execute work items
- Record progress in brain
- Log decisions
- Update memory bank
```

### Step 5: Archive Session (5 minutes)
```
1. Create session summary note in `/Engineering/`
2. Update progress.md
3. Update activeContext.md
4. Commit important findings to brain
```

---

## Example: Session Initialization Template

```markdown
# Session [DATE] - [TOPIC]
**Duration:** [Est. hours]  
**Goals:** [3-5 items]  
**Status:** In Progress

## Starting Context
- Read activeContext.md ✓
- Read latest session ✓
- Identified blockers: [list]

## Work Log
[During session]

## Completion
- Updated progress.md ✓
- Archived session ✓
- Ready for next session ✓
```

---

## When to Use Brain vs Memory Bank

### Brain (Obsidian) - For:
- Long-term project knowledge
- Decisions with rationale
- Architecture design notes
- Complex procedures
- Technical deep dives
- Session summaries
- Cross-workspace context

### Memory Bank - For:
- Quick status checks (activeContext)
- Task tracking (progress)
- Current focus (activeContext)
- Todo management (progress)
- Quick decision lookup (decisionLog)

### Memoripilot - For:
- Automatic thread-to-thread continuity
- Implicit context passing
- No manual invocation needed

---

## Integration with Daily Workflow

### Morning Session Start
1. `obsidian_brain: search "latest session"`
2. `memory_bank_show_memory: activeContext.md`
3. `memory_bank_show_memory: progress.md`
4. Read top 3 items from search results

### Afternoon Session Start
1. Same as morning (context is continuous)
2. Optionally review recent decisions
3. Search for specific technical topics if needed

### Session End (Every 2-3 hours or job completion)
1. `memory_bank_update_progress: done/next items`
2. `obsidian_brain: append session summary`
3. `memory_bank_update_context: new focus area`

### Major Milestone
1. Create detailed session summary in `/Engineering/`
2. Update `/Engineering/Pondera_Codebase_Architecture.md`
3. Add decision to decisionLog
4. Commit to source control if code changes

---

## Pondera Project Context (Always Available)

### Current Phase
- Phase 2-3: Boot optimization (current)
- Previous: Phase 13 integration complete
- Next: Comprehensive testing & validation

### Architecture Overview
```
World → Initialization Manager → 25+ phases → Boot complete
         ├─ Phase 1: Time system
         ├─ Phase 2: Infrastructure (continents, weather, map)
         ├─ Phase 3: Lighting (day/night cycle)
         ├─ Phase 4: Special worlds (story, sandbox, pvp)
         ├─ Phase 5: NPC/recipes/market systems
         └─ Phase 6+: Economy & advanced systems
```

### Build Status
- **Current:** 0 errors, 48 warnings ✅
- **Branch:** recomment-cleanup
- **Deployable:** Yes (Phase 13 fully integrated)

### Key Files
- `dm/InitializationManager.dm` - Boot orchestration (1004 lines)
- `dm/BootSequenceManager.dm` - Loop registry (298 lines)
- `dm/BootTimingAnalyzer.dm` - Timing metrics (270 lines)
- `Pondera.dme` - Compiler definition & includes

---

## Reminders for Consistency

1. **Always check brain first** before starting work
2. **Always update progress at end** of session
3. **Always record decisions** with rationale
4. **Always test before committing** to source control
5. **Always document in brain** what you did and why
6. **Always use specific dates** in session notes (YYYY-MM-DD)
7. **Always tag decisions** with implementation status

---

## Tools Quick Reference

| Tool | Command | Purpose |
|------|---------|---------|
| Brain | `obsidian_brain: search "topic"` | Find project knowledge |
| Brain | `obsidian_brain: read "/Engineering/filename.md"` | Read specific note |
| Brain | `obsidian_brain: write "/Engineering/filename.md"` | Create new note |
| Bank | `memory_bank_show_memory: activeContext.md` | Check current focus |
| Bank | `memory_bank_show_memory: progress.md` | Check task status |
| Bank | `memory_bank_update_progress: ...` | Update tasks |
| Bank | `memory_bank_update_context: "new focus"` | Update current focus |
| Bank | `memory_bank_log_decision: ...` | Log decision |

---

**Configuration Status:** ✅ ACTIVE FOREVER  
**Last Updated:** 2025-12-19  
**Review Frequency:** Every session start
