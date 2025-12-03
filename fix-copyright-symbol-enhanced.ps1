# Fix Copyright Symbol in All Footer Files - Enhanced Version
# This script replaces corrupted/missing copyright symbols with the correct © symbol

$rootPath = "Views"
$targetFiles = Get-ChildItem -Path $rootPath -Filter "*.cshtml" -Recurse

$filesModified = 0
$filesProcessed = 0

Write-Host "Starting copyright symbol fix..." -ForegroundColor Cyan
Write-Host "Scanning files in: $rootPath`n" -ForegroundColor Yellow

foreach ($file in $targetFiles) {
    $filesProcessed++
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $modified = $false

    # Pattern 1: Fix corrupted symbols (?, ?, or any non-ASCII character) before "All Rights Reserved"
    if ($content -match '[^\x20-\x7E\r\n\t]+\s*All Rights Reserved\s+@@?2025') {
        $content = $content -replace '[^\x20-\x7E\r\n\t]+\s*All Rights Reserved\s+@@2025', '© All Rights Reserved @2025'
        $content = $content -replace '[^\x20-\x7E\r\n\t]+\s*All Rights Reserved\s+@2025', '© All Rights Reserved @2025'
        $modified = $true
        Write-Host "Fixed corrupted symbol in: $($file.Name)" -ForegroundColor Green
    }

    # Pattern 2: Fix missing copyright symbol (space before "All Rights Reserved")
    if ($content -match '\s{2,}All Rights Reserved\s+@@2025') {
        $content = $content -replace '\s{2,}All Rights Reserved\s+@@2025', ' © All Rights Reserved @2025'
        $modified = $true
        Write-Host "Added missing symbol in: $($file.Name)" -ForegroundColor Green
    }

    # Pattern 3: Fix @@2025 to @2025 (Razor syntax)
    if ($content -match '©\s*All Rights Reserved\s+@@2025') {
        $content = $content -replace '(©\s*All Rights Reserved\s+)@@2025', '$1@2025'
        $modified = $true
        Write-Host "Fixed Razor syntax in: $($file.Name)" -ForegroundColor Green
    }

    # Pattern 4: Fix @DateTime.Now.Year to @2025
    if ($content -match '©?\s*All Rights Reserved\s+@DateTime\.Now\.Year') {
        $content = $content -replace '(©?)\s*All Rights Reserved\s+@DateTime\.Now\.Year', '© All Rights Reserved @2025'
        $modified = $true
        Write-Host "Fixed dynamic year in: $($file.Name)" -ForegroundColor Green
    }

    if ($modified) {
        $content | Set-Content -Path $file.FullName -Encoding UTF8 -NoNewline
        $filesModified++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Copyright Symbol Fix Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Files processed: $filesProcessed" -ForegroundColor Yellow
Write-Host "Files modified: $filesModified" -ForegroundColor Green
Write-Host "`n? All footers now use: © All Rights Reserved @2025" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
