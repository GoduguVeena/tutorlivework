# Fix Copyright Symbol Using HTML Entity
# Use &copy; HTML entity to avoid Razor parsing issues

$rootPath = "Views"
$targetFiles = Get-ChildItem -Path $rootPath -Filter "*.cshtml" -Recurse

$filesModified = 0

Write-Host "Converting to HTML entity &copy;..." -ForegroundColor Cyan

foreach ($file in $targetFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $modified = $false

    # Replace © with &copy; HTML entity
    if ($content -match '©\s*All Rights Reserved\s+@@2025') {
        $content = $content -replace '©\s*All Rights Reserved\s+@@2025', '&copy; All Rights Reserved @2025'
        $modified = $true
        Write-Host "Fixed: $($file.Name)" -ForegroundColor Green
    }

    if ($modified) {
        $content | Set-Content -Path $file.FullName -Encoding UTF8 -NoNewline
        $filesModified++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   HTML Entity Conversion Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Green
Write-Host "`n? Format: &copy; All Rights Reserved @2025" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
