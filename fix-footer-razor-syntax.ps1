# Fix @ symbol in footer copyright
$files = Get-ChildItem -Path "Views" -Filter "*.cshtml" -Recurse | 
    Where-Object { (Get-Content $_.FullName -Raw) -match "© All Rights Reserved @2025" }

Write-Host "Found $($files.Count) files to fix"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace "© All Rights Reserved @2025", "© All Rights Reserved @@2025"
    Set-Content -Path $file.FullName -Value $content -NoNewline
    Write-Host "Fixed: $($file.Name)"
}

Write-Host "Done!"
