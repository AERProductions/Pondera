# Cappy - Integrated Filesystem Tool

**Tool Name**: `integrated_filesystem` (Cappy)  
**Added**: 2025-12-16  
**Status**: ✅ Available and integrated  
**Type**: File operations utility

---

## Quick Overview

Cappy is an **integrated filesystem tool** that provides comprehensive file operations directly in VS Code without requiring external MCP server configuration.

## Available Operations

| Operation | Purpose | Example |
|-----------|---------|---------|
| `read_file` | Read file contents | Read Pondera.dme first 50 lines |
| `read_multiple_files` | Parallel reads | Read 5 related files at once |
| `write_file` | Create/overwrite | Create new documentation |
| `list_directory` | List contents | See what's in dm/ folder |
| `directory_tree` | Full structure (JSON) | Get complete vault structure |
| `move_file` | Move/rename | Archive old files |
| `search_files` | Find by pattern | Find all Session-Log*.md files |
| `create_directory` | Create folders | Add new system directory |
| `get_file_info` | File metadata | Check .dmb size and timestamp |

---

## Key Advantages

✅ No external MCP servers needed  
✅ Fast and efficient  
✅ Supports parallel operations  
✅ Great for discovery tasks  
✅ Built-in path validation  
✅ Perfect for batch operations  

---

## Best Practices

1. **Use parallel reads** - `read_multiple_files` for 3+ files
2. **Use head/tail** - Avoid reading huge files entirely
3. **Use directory_tree** - Better than 50 list_directory calls
4. **Use search_files** - Quick pattern-based discovery
5. **Cache metadata** - Avoid repeated `get_file_info` calls

---

## Pondera Project Examples

```
# Check build artifact
get_file_info("Pondera.dmb") → 3.07 MB, Last modified today

# See vault structure
directory_tree("obsidian-vault") → Full nested JSON

# Find all session logs
search_files(pattern="Session-Log*.md")

# Read multiple system files in parallel
read_multiple_files([HUDManager.dm, LoginGateway.dm, CharacterCreationGUI.dm])

# Archive old documentation
move_file(source="OLD_DOC.md", destination="archive/OLD_DOC.md")

# Create new system folder
create_directory("dm/new_system")
```

---

## Integration with Other Tools

| With Tool | Use |
|-----------|-----|
| **grep_search** | Find files, then search content |
| **file_search** | Similar but Cappy more flexible |
| **read_file** | Cappy good for head/tail, parallel |
| **replace_string_in_file** | Read with Cappy, edit with replace tool |
| **obsidian_brain** | Use Cappy to verify vault structure |
| **memory_bank** | Read memory files with Cappy |

---

## When to Use Cappy

✅ Reading/writing files  
✅ Moving or renaming files  
✅ Checking file size/metadata  
✅ Getting directory structure  
✅ Searching files by pattern  
✅ Batch/parallel file operations  
✅ Bulk migrations  

---

## Related Documentation
- [[Pondera-Developer-Guide]]
- [[Build-System-Reference]]
- [[Project-Overview]]



---

## Added to Vault

This document added to vault on 2025-12-16 after Cappy tool became available.

**Integration Points**:
- Use with grep_search for comprehensive code discovery
- Use with file_search for pattern matching
- Use with read_file for sequential operations
- Complement obsidian_brain with file metadata
- Support memory_bank with file organization
