#!/usr/bin/env python3

with open(r'c:\Users\ABL\Desktop\Pondera\dm\DeedAntiGriefingSystem.dm', 'r') as f:
    lines = f.readlines()

stack = []
for i, line in enumerate(lines, 1):
    for j, char in enumerate(line):
        if char == '{':
            stack.append((i, j, 'OPEN'))
            if i >= 240 and i <= 260:
                print(f"Line {i}: Found {{ at position {j}")
        elif char == '}':
            if stack:
                stack.pop()
            else:
                print(f"ERROR at line {i}: unmatched }}")
            if i >= 240 and i <= 260:
                print(f"Line {i}: Found }} at position {j}, stack depth now: {len(stack)}")

print(f"\nFinal stack depth: {len(stack)}")
if stack:
    print("Unmatched open braces at:")
    for line, pos, _ in stack[-5:]:  # Show last 5
        print(f"  Line {line}, position {pos}")
