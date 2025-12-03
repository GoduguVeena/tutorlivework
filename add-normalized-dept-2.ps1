# Add normalizedDept to GetSubjectsWithAssignments
$file = "Controllers\AdminController.cs"
$lines = Get-Content $file

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match 'private async Task<List<SubjectDetailDto>> GetSubjectsWithAssignments\(\)') {
        # Insert after the opening brace
        $lines[$i+2] = "            var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");`n" + $lines[$i+2]
        break
    }
}

Set-Content $file $lines
Write-Host "Added normalizedDept to GetSubjectsWithAssignments"
