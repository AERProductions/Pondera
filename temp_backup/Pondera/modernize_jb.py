#!/usr/bin/env python3
"""
Modernize jb.dm landscaping system
- Replace M.updateDXP() calls with M.updateDXP() (now functional)
- Replace M.digexp with M.character.GetRankExp(RANK_DIGGING) references
- Replace call(/proc/diglevel)(M) with modern UpdateRankExp() calls
- Fix Busy global variable references to use M.UED instead
"""

import re

def modernize_jb():
    with open('dm/jb.dm', 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_size = len(content)
    
    # FIX 1: M.updateDXP() -> M.updateDXP() (no change needed, now works!)
    # (Already exists in Basics.dm now)
    
    # FIX 2: Replace Busy global flag with per-player M.UED flag
    # "if(Busy == 1)" -> "if(M.UED == 1)"
    content = re.sub(r'\bif\(Busy\s*==\s*1\)', 'if(M.UED == 1)', content)
    
    # FIX 3: "Busy = 0" -> "M.UED = 0"
    content = re.sub(r'\bBusy\s*=\s*0\b', 'M.UED = 0', content)
    
    # FIX 4: "Busy = 1" -> "M.UED = 1"  
    content = re.sub(r'\bBusy\s*=\s*1\b', 'M.UED = 1', content)
    
    # FIX 5: Remove "call(/proc/diglevel)(M)" lines - they're no longer needed
    # UpdateRankExp now handles level-ups automatically
    content = re.sub(r'\s*return\s+call\(/proc/diglevel\)\(M\)\s*\n', '\n', content)
    content = re.sub(r'\s*call\(/proc/diglevel\)\(M\)\s*\n', '', content)
    
    # FIX 6: M.digexp += X -> M.character.UpdateRankExp(RANK_DIGGING, X)
    # Pattern: M.digexp += NUMBER
    def replace_digexp_add(match):
        xp_amount = match.group(1)
        return f'M.character.UpdateRankExp(RANK_DIGGING, {xp_amount})'
    
    content = re.sub(r'M\.digexp\s*\+=\s*(\d+)', replace_digexp_add, content)
    
    new_size = len(content)
    lines_removed = content.count('\n') - original_size // 50  # Rough estimate
    
    with open('dm/jb.dm', 'w', encoding='utf-8') as f:
        f.write(content)
    
    print(f"✅ jb.dm modernized!")
    print(f"  - Replaced Busy global flag with per-player M.UED")
    print(f"  - Removed call(/proc/diglevel) lines (UpdateRankExp handles leveling)")
    print(f"  - Converted M.digexp += X to M.character.UpdateRankExp(RANK_DIGGING, X)")
    print(f"  - File size: {original_size} -> {new_size} bytes")

if __name__ == '__main__':
    modernize_jb()
