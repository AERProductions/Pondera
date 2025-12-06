#!/usr/bin/env python3
import re

# Read the tools.dm file
with open('dm/tools.dm', 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.split('\n')

# Find the line with SAX handler opening
target_line = None
for i, line in enumerate(lines):
    if 'if ((typi=="SAX")&&(twohanded==0))' in line:
        target_line = i
        break

if target_line is None:
    print("ERROR: Could not find SAX handler")
    exit(1)

print(f"Found SAX handler at line {target_line + 1}")

# Get indentation from SAX line
sax_line = lines[target_line]
indent_match = re.match(r'^(\s+)', sax_line)
indent = indent_match.group(1) if indent_match else ''
print(f"Indentation level: {len(indent)} characters")

# Read the steel tools equip handlers
with open('dm/SteelToolsEquip.dm', 'r', encoding='utf-8') as f:
    steel_equip = f.read()

# Process and indent the steel equip code
steel_lines = steel_equip.split('\n')
indented_lines = []
for line in steel_lines:
    if line.strip() and not line.strip().startswith('//'):
        # Add indent to non-comment lines
        indented_lines.append(indent + line)
    elif line.strip().startswith('//'):
        # Keep comment indentation
        indented_lines.append(indent + line)
    else:
        # Keep blank lines
        indented_lines.append('')

# Insert the indented steel tools before SAX
insert_text = '\n'.join(indented_lines)
before_sax = '\n'.join(lines[:target_line])
from_sax = '\n'.join(lines[target_line:])

# Combine
new_content = before_sax + '\n' + insert_text + '\n' + from_sax

# Write back
with open('dm/tools.dm', 'w', encoding='utf-8') as f:
    f.write(new_content)

print(f"Successfully inserted {len(indented_lines)} lines before SAX handler")
print("tools.dm has been updated")
