# Final Fix: Copyright Symbol with Proper Razor Escaping
# Format: &copy; All Rights Reserved @@2025

$rootPath = "Views"
$targetFiles = Get-ChildItem -Path $rootPath -Filter "*.cshtml" -Recurse

$filesModified = 0

Write-Host "Applying final Razor escaping fix..." -ForegroundColor Cyan

foreach ($file in $targetFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $modified = $false

    # Fix @2025 to @@2025 (keep &copy; but escape the @)
    if ($content -match '&copy;\s*All Rights Reserved\s+@2025(?!@)') {
        $content = $content -replace '(&copy;\s*All Rights Reserved\s+)@2025', '$1@@2025'
        $modified = $true
        Write-Host "Fixed: $($file.Name)" -ForegroundColor Green
    }

    if ($modified) {
        $content | Set-Content -Path $file.FullName -Encoding UTF8 -NoNewline
        $filesModified++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "   Final Copyright Fix Complete!" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Green
Write-Host "`n? Final Format: &copy; All Rights Reserved @@2025" -ForegroundColor Green
Write-Host "   (Renders as: © All Rights Reserved @2025)" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan
