# Pondera Obsidian Vault - Index

**Vault Created**: 2025-12-16  
**Purpose**: Central knowledge repository for Pondera development  
**Accessibility**: Cross-workspace, persistent across all sessions  
**Update Frequency**: After each work session

## 🎯 Start Here

### For Developers Just Getting Started
1. Read [[Pondera-Developer-Guide]] (quick reference)
2. Check [[Project-Overview]] (architecture)
3. Review [[Build-System-Reference]] (how to build)

### For Bug Fixing
1. Check [[Architecture-Decisions-Log]] (why things are designed this way)
2. Review [[DM-Code-Patterns]] (common patterns)
3. Look at recent [[Session-Log-2025-12-16]] (what was just fixed)

### For New Features
1. Check [[Pondera-Developer-Guide]] (integration checklist)
2. Review [[DM-Code-Patterns]] (code to follow)
3. Update [[Architecture-Decisions-Log]] (document your decision)

---

## 📁 Vault Structure

### /Engineering/Pondera/
**Project Documentation & Technical Details**

- **Project-Overview.md** - High-level project status, systems list, build config
- **Session-Log-2025-12-16.md** - This session's work, findings, and learnings
- More session logs added after future work

### /Decisions/
**Architecture Decision Records (ADRs)**

- **Architecture-Decisions-Log.md** - All major decisions (12 ADRs documented)
- **Character-Creation-UI-Fix-12-16-2025.md** - Decision to remove alert-based UI
- Future: Add ADR for each major decision

### /Playbooks/
**Procedures & How-To Guides**

- **Build-System-Reference.md** - How to build, troubleshoot compilation
- **Pondera-Developer-Guide.md** - Quick reference for common tasks
- Future: Add checklists for common procedures

### /Snippets/
**Reusable Code Patterns**

- **DM-Code-Patterns.md** - Common patterns for initialization, backgrounds, gates, etc.
- Future: Add more language-specific patterns

---

## 🔍 Search Index

### By System
- **Initialization**: Architecture-Decisions-Log (ADR-001)
- **Elevation**: Architecture-Decisions-Log (ADR-002)
- **Map Generation**: Architecture-Decisions-Log (ADR-003)
- **Continents**: Architecture-Decisions-Log (ADR-004)
- **Deeds**: Architecture-Decisions-Log (ADR-005), Pondera-Developer-Guide
- **Character Creation**: Character-Creation-UI-Fix, Pondera-Developer-Guide
- **Consumables**: Architecture-Decisions-Log (ADR-007), DM-Code-Patterns
- **Ranks**: Architecture-Decisions-Log (ADR-008), Pondera-Developer-Guide
- **Economy**: Architecture-Decisions-Log (ADR-009, ADR-010)
- **NPCs**: Architecture-Decisions-Log (ADR-011)
- **Recipes**: Architecture-Decisions-Log (ADR-012)

### By File
- **Build**: Build-System-Reference, Project-Overview
- **Login**: Character-Creation-UI-Fix, Session-Log-2025-12-16
- **UI**: Character-Creation-UI-Fix, Pondera-Developer-Guide
- **Code Quality**: DM-Code-Patterns, Build-System-Reference

### By Problem Type
- **Compilation Errors**: Build-System-Reference
- **Include Order Issues**: Build-System-Reference, Session-Log-2025-12-16
- **Runtime Errors**: Pondera-Developer-Guide (Debugging section)
- **Design Questions**: Architecture-Decisions-Log

---

## 📊 Session History

| Date | Type | Focus | Outcome |
|------|------|-------|---------|
| 2025-12-16 | Bug Fix | Character Creation UI | ✅ Fixed (0 errors) |
| 2025-12-16 | Infrastructure | Documentation Setup | ✅ Vault created |

---

## 🚀 Quick Commands

### Navigation
```
Search for topic: Use Obsidian search (Ctrl+Shift+F)
See all files: View /Playbooks/, /Decisions/, /Engineering/
```

### Common Lookups
| Need | Look In |
|------|----------|
| How to build? | Build-System-Reference |
| What code pattern to use? | DM-Code-Patterns |
| Why is something designed this way? | Architecture-Decisions-Log |
| What just got fixed? | Session-Log-* (most recent) |
| Quick reference while coding? | Pondera-Developer-Guide |

---

## 📝 How to Update This Vault

### After Each Work Session
1. Create new Session-Log-YYYY-MM-DD.md in /Engineering/Pondera/
2. Document: objectives, work done, findings, what's next
3. Update memory_bank_update_progress() with current status
4. Add any new ADRs to /Decisions/ if major decisions made

### When Making Architectural Decisions
1. Create new ADR in /Decisions/ folder (use ADR-NNN template)
2. Document: context, decision, alternatives, consequences
3. Link from Architecture-Decisions-Log.md
4. Reference in relevant system files

### When Adding Code Patterns
1. Add to DM-Code-Patterns.md (under appropriate section)
2. Include: pattern name, code sample, key points
3. Link related ADRs and system docs

### Regular Maintenance
- [ ] Review Architecture-Decisions-Log monthly (still valid?)
- [ ] Archive old session logs (> 3 months to archive/)
- [ ] Update Project-Overview when major changes occur
- [ ] Refresh Pondera-Developer-Guide if new patterns emerge

---

## 💡 Why This Matters

**Before**: Knowledge scattered in chat history, hard to find later  
**Now**: Centralized vault accessible across all workspaces and sessions  
**Benefit**: Never lose context, faster onboarding, better decision tracking

**Memoripilot Note**: Use memory_bank tools regularly to sync progress with this vault.

---

## 🔗 Related Resources

- **GitHub**: https://github.com/AERProductions/Pondera
- **Build Tool**: BYOND DreamMaker 516.1673
- **Language**: DM (BYOND scripting language)
- **Current Focus**: Phase 5 - Economy/Market Systems

---

## 🎓 Learning Resources Within Vault

### For Understanding Pondera Architecture
1. Read Project-Overview (big picture)
2. Read Architecture-Decisions-Log (why each choice)
3. Read Pondera-Developer-Guide (how to work with it)
4. Check DM-Code-Patterns (code examples)

### For Building Confidence
1. Review Build-System-Reference (understand the build)
2. Look at recent Session-Log (see recent work)
3. Study a simple system in Architecture-Decisions-Log
4. Follow integration checklist in Pondera-Developer-Guide

---

**Last Sync**: 2025-12-16  
**Next Review**: After next work session  
**Vault Maintainer**: Development Team
