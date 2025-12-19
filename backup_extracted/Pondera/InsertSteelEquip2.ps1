$ErrorActionPreference = "Stop"

# Read tools.dm as raw bytes to preserve encoding exactly
$rawBytes = [System.IO.File]::ReadAllBytes('dm/tools.dm')
$content = [System.Text.Encoding]::UTF8.GetString($rawBytes)
$lines = $content -split "`n"

# Find SAX handler index
$saxIndex = $null
for($i = 0; $i -lt $lines.Count; $i++) {
    if($lines[$i] -match 'if \(\(typi=="SAX"\)&&\(twohanded==0\)\)') {
        $saxIndex = $i
        break
    }
}

if($null -eq $saxIndex) {
    Write-Error "Could not find SAX handler"
    exit 1
}

Write-Host "Found SAX at line $($saxIndex + 1)"

# Get indentation from SAX line
$saxLine = $lines[$saxIndex]
$indent = ''
if($saxLine -match '^(\s+)') {
    $indent = $Matches[1]
}
Write-Host "Indentation: $($indent.Length) characters"

# Read steel equip code
$steelEquip = [System.IO.File]::ReadAllText('dm/SteelToolsEquip.dm')
$steelLines = $steelEquip -split "`n"

# Indent each line
$indentedLines = @()
foreach($line in $steelLines) {
    if($line.Trim() -and $line.Trim().StartsWith('//')) {
        # Comment lines
        $indentedLines += $indent + $line
    } elseif($line.Trim()) {
        # Code lines  
        $indentedLines += $indent + $line
    } else {
        # Blank lines
        $indentedLines += ''
    }
}

Write-Host "Prepared $($indentedLines.Count) indented lines"

# Insert before SAX
$newLines = @($lines[0..($saxIndex-1)]) + $indentedLines + @($lines[$saxIndex..($lines.Count-1)])

# Join and write back with exact same encoding
$newContent = $newLines -join "`n"
[System.IO.File]::WriteAllText('dm/tools.dm', $newContent, [System.Text.Encoding]::UTF8)

Write-Host "Successfully inserted steel tool equip handlers"
Write-Host "New file has $($newLines.Count) total lines"
