# Simple fix - add normalizedDept to GetDashboardStats
$file = "Controllers\AdminController.cs"
$lines = Get-Content $file

for ($i = 0; $i -lt $lines.Count; $i++) {
    if ($lines[$i] -match '^\s+try\s*$' -and $lines[$i+1] -match '^\s+\{\s*$' -and $lines[$i+2] -match '^\s+var studentsCount') {
        # Insert after the opening brace
        $lines = $lines[0..$($i+1)] + "                var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");" + "" + $lines[($i+2)..($lines.Count-1)]
        break
    }
}

Set-Content $file $lines
Write-Host "Added normalizedDept to GetDashboardStats"
