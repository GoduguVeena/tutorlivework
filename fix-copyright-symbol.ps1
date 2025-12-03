# Fix Copyright Symbol in All Footer Files
# This script replaces corrupted copyright symbols with the correct © symbol

$rootPath = "Views"
$targetFiles = Get-ChildItem -Path $rootPath -Filter "*.cshtml" -Recurse

$replacements = @(
    @{ Pattern = '? All Rights Reserved @@2025'; Replacement = '© All Rights Reserved @2025' }
    @{ Pattern = '? All Rights Reserved @@2025'; Replacement = '© All Rights Reserved @2025' }
    @{ Pattern = '? All Rights Reserved @2025'; Replacement = '© All Rights Reserved @2025' }
    @{ Pattern = '? All Rights Reserved @2025'; Replacement = '© All Rights Reserved @2025' }
)

$filesModified = 0

foreach ($file in $targetFiles) {
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $modified = $false

    foreach ($replacement in $replacements) {
        if ($content -match [regex]::Escape($replacement.Pattern)) {
            $content = $content -replace [regex]::Escape($replacement.Pattern), $replacement.Replacement
            $modified = $true
            Write-Host "Fixed in: $($file.FullName)" -ForegroundColor Green
        }
    }

    if ($modified) {
        $content | Set-Content -Path $file.FullName -Encoding UTF8 -NoNewline
        $filesModified++
    }
}

Write-Host "`n==================================" -ForegroundColor Cyan
Write-Host "Copyright Symbol Fix Complete!" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Files modified: $filesModified" -ForegroundColor Green
Write-Host "`nAll footers now have consistent © symbol" -ForegroundColor Yellow
