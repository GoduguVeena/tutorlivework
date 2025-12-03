# Fix Copyright Symbol with Proper Razor Escaping
# The correct format should be: © All Rights Reserved @@2025
# The @@ is needed because @ is a special character in Razor

$rootPath = "Views"
$targetFiles = Get-ChildItem -Path $rootPath -Filter "*.cshtml" -Recurse

$filesModified = 0

Write-Host "Fixing Razor escaping for copyright symbols..." -ForegroundColor Cyan

foreach ($file in $targetFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $modified = $false

    # Fix @2025 to @@2025 (Razor requires @@ to escape @)
    if ($content -match '©\s*All Rights Reserved\s+@2025(?!@)') {
        $content = $content -replace '(©\s*All Rights Reserved\s+)@2025', '$1@@2025'
        $modified = $true
        Write-Host "Fixed Razor syntax in: $($file.Name)" -ForegroundColor Green
    }

    if ($modified) {
        $content | Set-Content -Path $file.FullName -Encoding UTF8 -NoNewline
        $filesModified++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Razor Escaping Fix Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Green
Write-Host "`n? Format: © All Rights Reserved @@2025" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan
