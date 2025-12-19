# 🔧 Cappy Integrated Filesystem Tool - Reference Guide

**Status**: ✅ NOW AVAILABLE  
**Tool**: `integrated_filesystem`  
**Version**: Full-featured file operations  
**Update**: Complementary to existing tools

---

## 🎯 What is Cappy?

Cappy is the **integrated filesystem tool** built directly into VS Code. It provides fast, reliable file operations without requiring external MCP server configuration. All paths are validated against allowed directories for security.

---

## 📋 Available Operations

### 1. **read_file** - Read file contents
```
Read single file with optional head/tail for large files
Parameters:
  - path (required): File path
  - head (optional): Read first N lines
  - tail (optional): Read last N lines
```

**Example**:
```
Read first 50 lines of Pondera.dme
→ integrated_filesystem(read_file, c:\...\Pondera.dme, head=50)

Read last 20 lines of character creation file
→ integrated_filesystem(read_file, ...\CharacterCreationUI.dm, tail=20)
```

### 2. **read_multiple_files** - Parallel reads
```
Read multiple files simultaneously (faster than sequential)
Parameters:
  - paths (required): Array of file paths
```

**Example**:
```
Read multiple system files at once
→ integrated_filesystem(read_multiple_files, paths=[...HUDManager.dm, ...LoginGateway.dm, ...CharacterCreationGUI.dm])
```

### 3. **write_file** - Create/overwrite files
```
Create new file or overwrite existing
Parameters:
  - path (required): File path
  - content (required): Content to write
```

**Example**:
```
Create new documentation file
→ integrated_filesystem(write_file, path=...\NEW_SYSTEM.md, content="# System Docs...")
```

### 4. **list_directory** - List directory contents
```
List files and folders in a directory
Parameters:
  - path (required): Directory path
```

**Example**:
```
See what's in dm folder
→ integrated_filesystem(list_directory, c:\...\Pondera\dm)
```

**Output Format**:
```
[DIR]  subfolder/
[FILE] document.md
[FILE] code.dm
```

### 5. **directory_tree** - Recursive JSON tree
```
Get full directory structure as JSON tree
Parameters:
  - path (required): Directory path
```

**Example**:
```
See complete obsidian vault structure
→ integrated_filesystem(directory_tree, c:\...\obsidian-vault)

Returns JSON with nested structure (folders and files)
```

### 6. **move_file** - Move/rename files
```
Move file to new location or rename
Parameters:
  - source (required): Current path
  - destination (required): New path
```

**Example**:
```
Move file to archive
→ integrated_filesystem(move_file, source=...\OLD_FILE.md, destination=...\archive\OLD_FILE.md)

Rename file
→ integrated_filesystem(move_file, source=...\Oldname.dm, destination=...\Newname.dm)
```

### 7. **search_files** - Glob pattern search
```
Search for files matching pattern
Parameters:
  - path (required): Starting directory
  - pattern (required): Glob pattern
```

**Example**:
```
Find all DM files in dm folder
→ integrated_filesystem(search_files, path=...\Pondera\dm, pattern=*.dm)

Find all markdown docs
→ integrated_filesystem(search_files, path=..., pattern=**/*.md)

Find session logs
→ integrated_filesystem(search_files, path=...\obsidian-vault, pattern=Session-Log*.md)
```

### 8. **create_directory** - Create directories
```
Create new directory (recursively)
Parameters:
  - path (required): Directory path
```

**Example**:
```
Create new project folder
→ integrated_filesystem(create_directory, path=c:\...\Pondera\new_system)
```

### 9. **get_file_info** - File metadata
```
Get detailed information about file
Parameters:
  - path (required): File path
```

**Example**:
```
Check compiled binary size and timestamp
→ integrated_filesystem(get_file_info, c:\...\Pondera.dmb)

Returns: Name, Path, Type, Size, Created, Modified
```

---

## 💡 Advantages Over Other Tools

| Feature | Cappy | grep_search | file_search | read_file |
|---------|-------|-------------|------------|-----------|
| **Fast reads** | ✅ | - | - | ✅ |
| **Parallel ops** | ✅ | - | - | ❌ |
| **Write files** | ✅ | ❌ | ❌ | ❌ |
| **Move/rename** | ✅ | ❌ | ❌ | ❌ |
| **Directory tree** | ✅ | ❌ | ❌ | ❌ |
| **File info** | ✅ | ❌ | ❌ | ❌ |
| **Search patterns** | ✅ | Limited | Limited | N/A |
| **No external MCP** | ✅ | ✅ | ✅ | ✅ |

---

## 🚀 Real-World Use Cases

### Quick File Discovery
```
Find all session logs
→ search_files(pattern="Session-Log*.md")

Get directory structure
→ directory_tree(path)

List system files
→ list_directory(path="dm/")
```

### Fast Content Reading
```
Read large file headers only
→ read_file(path, head=50)

Read multiple files in parallel
→ read_multiple_files(paths=[file1, file2, file3])
```

### File Operations
```
Create new documentation
→ write_file(path, content)

Archive old files
→ move_file(source, destination="archive/")

Add new system folder
→ create_directory(path)

Check build artifact size
→ get_file_info(path="Pondera.dmb")
```

### Bulk Operations
```
Search for all DM files with specific pattern
→ search_files(pattern="**/*.dm")

List everything in obsidian vault
→ directory_tree(path)

Parallel read of related files
→ read_multiple_files(paths=[...multiple related docs])
```

---

## 🎯 Best Practices

### 1. **Use Parallel Reads for Related Files**
```
❌ BAD: Read 5 files sequentially
✅ GOOD: read_multiple_files with all 5 paths at once
```

### 2. **Use head/tail for Large Files**
```
❌ BAD: read_file(huge_file) - wastes tokens
✅ GOOD: read_file(huge_file, head=100) - first 100 lines
```

### 3. **Use directory_tree for Structure**
```
❌ BAD: list_directory 50 times for nested structure
✅ GOOD: directory_tree(root) - one call gets everything
```

### 4. **Use search_files for Discovery**
```
❌ BAD: Manual listing to find files
✅ GOOD: search_files(pattern="Session-*.md")
```

### 5. **Cache File Info**
```
Store result of get_file_info to check timestamps
Avoid repeated calls for same file
```

---

## 🔗 Integration with Other Tools

### With grep_search
```
1. Use search_files to find candidates
2. Use grep_search within found files
3. Very efficient for targeted searches
```

### With file_search
```
1. Use search_files (broader, faster)
2. Or use file_search (glob patterns)
3. Cappy's glob is more flexible
```

### With read_file
```
Cappy read_file: Better for existing workflows
Can use head/tail efficiently
read_file tool: Still good for sequential reads
```

### With replace_string_in_file
```
1. Use Cappy to read file contents
2. Plan replacements
3. Use replace_string_in_file to apply changes
```

---

## 📊 Performance Characteristics

| Operation | Speed | Use Case |
|-----------|-------|----------|
| read_file | Fast | Single file reads, any size |
| read_multiple_files | Very Fast | 3+ related files (parallel) |
| write_file | Fast | Create/overwrite |
| list_directory | Fast | Shallow directory listing |
| directory_tree | Very Fast | Full structure (returns JSON) |
| move_file | Very Fast | Rename/archive |
| search_files | Fast | Pattern-based discovery |
| create_directory | Very Fast | Folder creation |
| get_file_info | Very Fast | Metadata lookup |

---

## 🎨 Pondera Project Examples

### Check Build Status
```
get_file_info(c:\...\Pondera.dmb)
→ Returns: Size (3.07 MB), Last Modified (today), etc.
```

### List Vault Structure
```
directory_tree(c:\...\obsidian-vault)
→ Returns: Full nested structure with all docs
```

### Find All Session Logs
```
search_files(path=obsidian-vault, pattern=Session-Log*.md)
→ Returns: All session log paths
```

### Read Multiple Config Files
```
read_multiple_files([Pondera.dme, !defines.dm, Interfacemini.dmf])
→ Returns: All 3 files' contents in parallel
```

### Archive Documentation
```
move_file(source=SESSION_COMPLETE_SUMMARY.md, 
          destination=archive/SESSION_COMPLETE_SUMMARY.md)
```

### Create New System Folder
```
create_directory(c:\...\Pondera\dm\new_system)
```

### Check File First Lines
```
read_file(c:\...\Pondera.dme, head=50)
→ Returns: First 50 lines only (not whole file)
```

---

## 🔒 Security Features

- ✅ All paths validated against allowed directories
- ✅ Cannot access system files outside workspace
- ✅ Safe for production use
- ✅ No external dependencies required
- ✅ Integrated directly into VS Code

---

## 📝 When to Use Cappy vs Other Tools

### Use Cappy When:
- ✅ Need to read/write files
- ✅ Moving or renaming files
- ✅ Checking file metadata/size
- ✅ Listing directory contents
- ✅ Getting full directory structure
- ✅ Searching for files by pattern
- ✅ Need parallel file operations

### Use grep_search When:
- ✅ Searching within file contents (regex)
- ✅ Finding specific code patterns
- ✅ Need to filter search results

### Use file_search When:
- ✅ Glob pattern file search
- ✅ Finding all matches quickly

### Use read_file When:
- ✅ Sequential reading workflow
- ✅ Single file operations

---

## 🎓 Quick Command Reference

```
# Read operations
read_file(path, head=50, tail=20)
read_multiple_files(paths=[...])
get_file_info(path)

# Write operations
write_file(path, content)

# Directory operations
list_directory(path)
directory_tree(path)
create_directory(path)

# Search/move operations
search_files(path, pattern)
move_file(source, destination)
```

---

## ✨ Summary

Cappy (integrated_filesystem) is your **comprehensive file operations toolkit**:
- ✅ Read, write, move, delete files
- ✅ List and structure directories
- ✅ Search files by pattern
- ✅ Check file metadata
- ✅ All without external MCP servers
- ✅ Fast and efficient

**Use it alongside other tools for maximum productivity!**

---

**Added to Toolkit**: 2025-12-16  
**Status**: ✅ READY TO USE  
**Integration**: Seamless with existing tools  

🚀 **Enhance your workflow with Cappy today!**
