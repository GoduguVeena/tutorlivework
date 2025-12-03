# Remove all emoji and special characters from view files

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "REMOVING EMOJI & SPECIAL CHARACTERS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Define replacements
$replacements = @(
    @{ Pattern = '(\?\?|\?|\?\?\?) Back to Home'; Replacement = '? Back to Home' }
    @{ Pattern = '(\?\?|\?|\?\?\?) Back to Student'; Replacement = '? Back to Student' }
    @{ Pattern = '(\?\?|\?|\?\?\?) Back to Faculty'; Replacement = '? Back to Faculty' }
    @{ Pattern = '(\?\?|\?|\?\?\?) Back to Admin'; Replacement = '? Back to Admin' }
    @{ Pattern = '(\?\?|\?|\?\?\?) Back to Dashboard'; Replacement = '? Back to Dashboard' }
    @{ Pattern = 'console\.log\(''(\?+|\?+)'; Replacement = "console.log('" }
    @{ Pattern = "console\.log\(`"(\?+|\?+)"; Replacement = 'console.log("' }
    @{ Pattern = '\?\?\?'; Replacement = '' }
    @{ Pattern = '\?\?'; Replacement = '' }
    @{ Pattern = '?'; Replacement = '©' }
    @{ Pattern = '×'; Replacement = '×' }
)

# Get all cshtml files
$files = Get-ChildItem -Path "Views" -Filter "*.cshtml" -Recurse

$totalFixed = 0
$filesModified = 0

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileFixed = 0
    
    foreach ($replacement in $replacements) {
        $matches = [regex]::Matches($content, $replacement.Pattern)
        if ($matches.Count -gt 0) {
            $content = $content -replace $replacement.Pattern, $replacement.Replacement
            $fileFixed += $matches.Count
        }
    }
    
    # Check for any remaining non-ASCII characters in console.log statements
    $content = $content -replace "console\.log\('(?:[^\x00-\x7F])+", "console.log('"
    $content = $content -replace 'console\.log\("(?:[^\x00-\x7F])+', 'console.log("'
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline -Encoding UTF8
        Write-Host "? Fixed: $($file.Name) - $fileFixed replacements" -ForegroundColor Green
        $totalFixed += $fileFixed
        $filesModified++
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Files Modified: $filesModified" -ForegroundColor Yellow
Write-Host "Total Fixes: $totalFixed" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan
