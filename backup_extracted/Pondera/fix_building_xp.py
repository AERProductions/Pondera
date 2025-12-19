#!/usr/bin/env python3
"""
Fix Building XP system - convert from M.buildexp += N to M.character.UpdateRankExp(RANK_BUILDING, N)
"""
import re

# Read the file
with open('dm/jb.dm', 'r') as f:
    content = f.read()

# Pattern to match: M.character.UpdateRankExp(RANK_BUILDING, NUMBER
# We need to add the closing parenthesis after the number
pattern = r'M\.character\.UpdateRankExp\(RANK_BUILDING,\s+(\d+)'
replacement = r'M.character.UpdateRankExp(RANK_BUILDING, \1)'

content = re.sub(pattern, replacement, content)

# Write back
with open('dm/jb.dm', 'w') as f:
    f.write(content)

print("✓ Fixed all building XP calls in jb.dm")
