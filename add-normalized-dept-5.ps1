# Add normalizedDept to AddCSEDSFaculty
$file = "Controllers\AdminController.cs"
$lines = Get-Content $file

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'public async Task<IActionResult> AddCSEDSFaculty\(\[FromBody\] CSEDSFacultyViewModel model\)') {
        # Find the first line after ModelState check
        for ($j = $i; $j -lt $i + 20; $j++) {
            if ($lines[$j] -match 'var existingFaculty = await _context\.Faculties') {
                $lines = $lines[0..$($j-1)] + "            var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");" + "" + $lines[$j..($lines.Count-1)]
                break
            }
        }
        break
    }
}

Set-Content $file $lines
Write-Host "Added normalizedDept to AddCSEDSFaculty"
