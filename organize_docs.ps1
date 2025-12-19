# PowerShell script to organize and move markdown files
# Usage: Run from Pondera root directory

$root = 'c:\Users\ABL\Desktop\Pondera'
$docs = Join-Path $root 'docs'

# Define categorization rules
$categories = @{
    'Sessions' = @{
        pattern = '^SESSION_.*|^RUNTIME_ERROR_.*|^FINAL_LOGIN.*'
        target = 'Sessions\Session_Logs'
    }
    'BuildStatus' = @{
        pattern = '^BUILD_|^READY_FOR_|^FINAL_STATUS'
        target = 'Status\Build_Reports'
    }
    'Audits' = @{
        pattern = '^COMPREHENSIVE|^LEGACY_|^CODEBASE_AUDIT|^AUDIT_'
        target = 'Status\System_Audits'
    }
    'HUD' = @{
        pattern = 'HUD|TOOLBELT|HOTBAR'
        target = 'Systems\HUD'
    }
    'Climbing' = @{
        pattern = 'CLIMBING'
        target = 'Systems\Climbing'
    }
    'Fishing' = @{
        pattern = 'FISHING|RANK_SYSTEM'
        target = 'Systems\Fishing'
    }
    'Crafting' = @{
        pattern = 'CRAFT|COOKING|RECIPE|SMELTING|SMITHING'
        target = 'Systems\Crafting'
    }
    'Equipment' = @{
        pattern = 'EQUIPMENT|DURABILITY|ARMOR|WEAPON'
        target = 'Systems\Equipment'
    }
    'Deeds' = @{
        pattern = 'DEED'
        target = 'Systems\Deeds'
    }
    'Farming' = @{
        pattern = 'FARM|SOIL|GROWTH|PLANT|GARDENING'
        target = 'Systems\Farming'
    }
    'Tools' = @{
        pattern = 'TOOL|GATHERING|PICKAXE|SHOVEL|MINING|DIGGING'
        target = 'Systems\Tools'
    }
    'Market' = @{
        pattern = 'MARKET|ECONOMY|MATERIAL|PRICE'
        target = 'Systems\Market'
    }
    'NPCs' = @{
        pattern = 'NPC|QUEST'
        target = 'Systems\NPCs'
    }
    'Combat' = @{
        pattern = 'COMBAT|DAMAGE|ATTACK|ENEMY|MONSTER'
        target = 'Systems\Combat'
    }
    'Login' = @{
        pattern = 'LOGIN|CHARGEN|CHARACTER_CREATION|LOBBY'
        target = 'Integration'
    }
    'Documentation' = @{
        pattern = 'DOCUMENTATION|REFERENCE|QUICK_REFERENCE'
        target = 'Playbooks'
    }
}

# Early phase files to archive (before Dec-15)
$archiveEarly = @(
    'ADDITIONAL_IMPROVEMENTS_SESSION_12_13',
    'BUILDING_MODERNIZATION_STRATEGY',
    'CLIMBING_SYSTEM_COMPLETION',
    'COMPREHENSIVE_VARIABLE_AUDIT_PHASE2_DECEMBER_13_2025',
    'CODEBASE_AUDIT_COMPREHENSIVE_12_16_25',
    'DEED_PERMISSION_SYSTEM_AUDIT',
    'DIGGING_SYSTEM_AUDIT_PHASE_A',
    'EQUIPMENT_SYSTEMS_ANALYSIS',
    'LEGACY_CLEANUP_FINAL_DECEMBER_13_2025',
    'LEGACY_SYSTEM_AUDIT_DECEMBER_2025',
    'NAMING_AUDIT_DECEMBER_13_2025'
)

Write-Host "=== MARKDOWN FILE ORGANIZATION SCRIPT ===" -ForegroundColor Cyan
Write-Host "Root: $root"
Write-Host "Docs: $docs`n"

$moved = 0
$archived = 0

# Get all root .md files
Get-ChildItem -Path (Join-Path $root '*.md') -File | ForEach-Object {
    $fileName = $_.Name
    $baseName = $_.BaseName
    $moved_this = $false
    
    # Check if should archive to early phase
    foreach($archivePattern in $archiveEarly) {
        if($baseName -match $archivePattern) {
            $target = Join-Path $docs "Archive\2025-12-Early\$fileName"
            Move-Item -Path $_.FullName -Destination $target -Force
            Write-Host "📦 Archived (Early): $fileName" -ForegroundColor Yellow
            $archived++
            $moved_this = $true
            break
        }
    }
    
    if(-not $moved_this) {
        # Check categorization rules
        foreach($category in $categories.GetEnumerator()) {
            if($baseName -match $category.Value.pattern) {
                $target = Join-Path $docs ($category.Value.target + '\' + $fileName)
                Move-Item -Path $_.FullName -Destination $target -Force
                Write-Host "✓ Moved ($($category.Name)): $fileName"
                $moved++
                $moved_this = $true
                break
            }
        }
    }
    
    # If not categorized, move to Archive/2025-12-Mid
    if(-not $moved_this) {
        $target = Join-Path $docs "Archive\2025-12-Mid\$fileName"
        Move-Item -Path $_.FullName -Destination $target -Force
        Write-Host "📦 Archived (Uncategorized): $fileName" -ForegroundColor Gray
        $archived++
    }
}

Write-Host "`n=== RESULTS ===" -ForegroundColor Green
Write-Host "✓ Moved: $moved files"
Write-Host "📦 Archived: $archived files"
Write-Host "Total: $($moved + $archived) files organized"
