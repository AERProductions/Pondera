#!/usr/bin/env python3
"""
Insert steel tool equip handlers into tools.dm with proper indentation matching.
Reads from SteelToolsEquip.dm template and inserts before SAX handler.
"""

import re

# Read the template file
with open('dm/SteelToolsEquip.dm', 'r') as f:
    template_content = f.read()

# Read the tools.dm file
with open('dm/tools.dm', 'r') as f:
    tools_content = f.read()

# Find SAX handler location
sax_match = re.search(r'(\s+)if \(\(typi=="SAX"\)\&\&\(twohanded==0\)\)', tools_content)
if not sax_match:
    print("ERROR: Could not find SAX handler")
    exit(1)

sax_pos = sax_match.start()
base_indent = sax_match.group(1)
print(f"Found SAX at position {sax_pos}")
print(f"Base indent level: {len(base_indent)} chars")

# Extract individual tool handlers from template, removing comment lines
lines = template_content.split('\n')
tool_handlers = []
current_handler = []
skip_next_comment = True

for line in lines:
    # Skip initial comments
    if skip_next_comment and line.strip().startswith('//'):
        continue
    skip_next_comment = False
    
    # Skip empty lines and comment headers
    if not line.strip() or (line.strip().startswith('//') and 'Handler' in line):
        continue
    
    # Collect handler lines
    if line.strip():
        current_handler.append(line)
    elif current_handler:
        # End of handler (blank line after content)
        tool_handlers.append('\n'.join(current_handler))
        current_handler = []

# Don't forget last handler
if current_handler:
    tool_handlers.append('\n'.join(current_handler))

print(f"Extracted {len(tool_handlers)} tool handlers")

# Re-indent handlers to match SAX base indentation
reindented_handlers = []
for handler in tool_handlers:
    handler_lines = handler.split('\n')
    reindented_lines = []
    
    for line in handler_lines:
        if line.strip():
            # Count tabs in original
            original_indent = len(line) - len(line.lstrip('\t'))
            # Remove original indent and apply new base indent
            content = line.lstrip('\t')
            # Add 1 tab per original tab level, then add base indent
            new_line = base_indent + '\t' * original_indent + content
            reindented_lines.append(new_line)
        else:
            reindented_lines.append(line)
    
    reindented_handlers.append('\n'.join(reindented_lines))

# Combine all handlers with spacing
combined_handlers = '\n\n'.join(reindented_handlers)

# Change first handler from "if" to "else if" to maintain chain
if combined_handlers:
    combined_handlers = combined_handlers.replace(
        combined_handlers.split('\n')[0],
        combined_handlers.split('\n')[0].replace('if ((typi==', 'else if ((typi=='),
        1
    )

# Insert before SAX handler
new_content = tools_content[:sax_pos] + combined_handlers + '\n\n' + tools_content[sax_pos:]

# Write back
with open('dm/tools.dm', 'w') as f:
    f.write(new_content)

print("Successfully inserted steel tool equip handlers!")
print(f"First handler changed to 'else if' for proper chaining")
print(f"All handlers re-indented to match SAX base level")
