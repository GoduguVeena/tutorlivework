# Fix @media to @@media in all view files
$files = Get-ChildItem -Path "Views" -Filter "*.cshtml" -Recurse | 
    Where-Object { (Get-Content $_.FullName -Raw) -match "@media" -and (Get-Content $_.FullName -Raw) -notmatch "@@media" }

Write-Host "Found $($files.Count) files with @media to fix"

foreach ($file in $files) {
    $content = Get-Content $file.FullName -Raw
    $content = $content -replace "(\s)@media\s", '$1@@media '
    Set-Content -Path $file.FullName -Value $content -NoNewline
    Write-Host "Fixed: $($file.Name)"
}

Write-Host "Done!"
