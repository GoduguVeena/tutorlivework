# PowerShell script to urgently fix "No Available Subjects" issue

Write-Host "========================================" -ForegroundColor Red
Write-Host "   URGENT FIX: No Available Subjects" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

# Get the connection string from appsettings.json
$appsettingsPath = Join-Path $PSScriptRoot "appsettings.json"

if (-not (Test-Path $appsettingsPath)) {
    Write-Host "ERROR: appsettings.json not found at: $appsettingsPath" -ForegroundColor Red
    exit 1
}

try {
    $appsettings = Get-Content $appsettingsPath -Raw | ConvertFrom-Json
    $connectionString = $appsettings.ConnectionStrings.DefaultConnection
    
    Write-Host "Connection string found." -ForegroundColor Green
    Write-Host ""
    
    # Load System.Data assembly
    Add-Type -AssemblyName "System.Data"
    
    # Create connection
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    
    Write-Host "Connecting to database..." -ForegroundColor Yellow
    $connection.Open()
    Write-Host "Connected successfully!" -ForegroundColor Green
    Write-Host ""
    
    # STEP 1: Show current department naming
    Write-Host "STEP 1: Checking department names..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $cmd = $connection.CreateCommand()
    
    # Check Students departments
    $cmd.CommandText = "SELECT DISTINCT Department, COUNT(*) as Count FROM [dbo].[Students] GROUP BY Department"
    $reader = $cmd.ExecuteReader()
    Write-Host "Student Departments:" -ForegroundColor Yellow
    $studentDepts = @()
    while ($reader.Read()) {
        $dept = $reader['Department']
        $count = $reader['Count']
        $studentDepts += $dept
        Write-Host "  - $dept ($count students)" -ForegroundColor White
    }
    $reader.Close()
    Write-Host ""
    
    # Check AssignedSubjects departments
    $cmd.CommandText = "SELECT DISTINCT Department, COUNT(*) as Count FROM [dbo].[AssignedSubjects] GROUP BY Department"
    $reader = $cmd.ExecuteReader()
    Write-Host "Available Subject Departments:" -ForegroundColor Yellow
    $subjectDepts = @()
    while ($reader.Read()) {
        $dept = $reader['Department']
        $count = $reader['Count']
        $subjectDepts += $dept
        Write-Host "  - $dept ($count subjects)" -ForegroundColor White
    }
    $reader.Close()
    Write-Host ""
    
    # STEP 2: Find students with NO available subjects
    Write-Host "STEP 2: Finding affected students..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $cmd.CommandText = @"
SELECT 
    s.Id,
    s.FullName,
    s.Department AS StudentDept,
    s.Year,
    COUNT(DISTINCT asub.AssignedSubjectId) AS AvailableSubjects
FROM [dbo].[Students] s
LEFT JOIN [dbo].[AssignedSubjects] asub 
    ON s.Department = asub.Department 
    AND asub.Year = CASE 
        WHEN s.Year = 'I Year' THEN 1
        WHEN s.Year = 'II Year' THEN 2
        WHEN s.Year = 'III Year' THEN 3
        WHEN s.Year = 'IV Year' THEN 4
    END
    AND asub.SelectedCount < 30
LEFT JOIN [dbo].[StudentEnrollments] se ON s.Id = se.StudentId
WHERE se.StudentId IS NULL  -- Not enrolled in anything yet
GROUP BY s.Id, s.FullName, s.Department, s.Year
HAVING COUNT(DISTINCT asub.AssignedSubjectId) = 0
"@
    
    $reader = $cmd.ExecuteReader()
    $affectedStudents = @()
    while ($reader.Read()) {
        $affectedStudents += [PSCustomObject]@{
            Id = $reader["Id"]
            FullName = $reader["FullName"]
            Department = $reader["StudentDept"]
            Year = $reader["Year"]
            AvailableSubjects = $reader["AvailableSubjects"]
        }
    }
    $reader.Close()
    
    if ($affectedStudents.Count -eq 0) {
        Write-Host "No affected students found! All students can see subjects." -ForegroundColor Green
        $connection.Close()
        exit 0
    }
    
    Write-Host "PROBLEM FOUND! $($affectedStudents.Count) students cannot see subjects:" -ForegroundColor Red
    foreach ($student in $affectedStudents) {
        Write-Host "  - $($student.FullName) | Year: $($student.Year) | Dept: $($student.Department)" -ForegroundColor Yellow
    }
    Write-Host ""
    
    # STEP 3: Automatic Fix
    Write-Host "STEP 3: Applying automatic fix..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $totalFixed = 0
    
    # Fix CSE(DS) -> CSEDS
    Write-Host "Fixing CSE(DS) -> CSEDS..." -ForegroundColor Yellow
    
    $cmd.CommandText = "UPDATE [dbo].[Students] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated student record(s)" -ForegroundColor Green
        $totalFixed += $updated
    }
    
    $cmd.CommandText = "UPDATE [dbo].[AssignedSubjects] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated AssignedSubject record(s)" -ForegroundColor Green
    }
    
    $cmd.CommandText = "UPDATE [dbo].[Subjects] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated Subject record(s)" -ForegroundColor Green
    }
    
    $cmd.CommandText = "UPDATE [dbo].[Faculties] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated Faculty record(s)" -ForegroundColor Green
    }
    
    $cmd.CommandText = "UPDATE [dbo].[FacultySelectionSchedules] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated FacultySelectionSchedule record(s)" -ForegroundColor Green
    }
    
    # Also fix CSDS -> CSEDS (another variant)
    Write-Host ""
    Write-Host "Fixing CSDS -> CSEDS..." -ForegroundColor Yellow
    
    $cmd.CommandText = "UPDATE [dbo].[Students] SET Department = 'CSEDS' WHERE Department = 'CSDS'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated student record(s)" -ForegroundColor Green
        $totalFixed += $updated
    }
    
    # Fix CSE-DS -> CSEDS (another variant)
    Write-Host ""
    Write-Host "Fixing CSE-DS -> CSEDS..." -ForegroundColor Yellow
    
    $cmd.CommandText = "UPDATE [dbo].[Students] SET Department = 'CSEDS' WHERE Department = 'CSE-DS'"
    $updated = $cmd.ExecuteNonQuery()
    if ($updated -gt 0) {
        Write-Host "  Fixed $updated student record(s)" -ForegroundColor Green
        $totalFixed += $updated
    }
    
    Write-Host ""
    Write-Host "Total students fixed: $totalFixed" -ForegroundColor Green
    Write-Host ""
    
    # STEP 4: Verify Fix
    Write-Host "STEP 4: Verifying fix..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    # Check all students now
    $cmd.CommandText = @"
SELECT 
    s.Id,
    s.FullName,
    s.Department AS StudentDept,
    s.Year,
    COUNT(DISTINCT asub.AssignedSubjectId) AS AvailableSubjects
FROM [dbo].[Students] s
LEFT JOIN [dbo].[AssignedSubjects] asub 
    ON s.Department = asub.Department 
    AND asub.Year = CASE 
        WHEN s.Year = 'I Year' THEN 1
        WHEN s.Year = 'II Year' THEN 2
        WHEN s.Year = 'III Year' THEN 3
        WHEN s.Year = 'IV Year' THEN 4
    END
    AND asub.SelectedCount < 30
GROUP BY s.Id, s.FullName, s.Department, s.Year
ORDER BY s.FullName
"@
    
    $reader = $cmd.ExecuteReader()
    Write-Host "All students and their available subjects:" -ForegroundColor Green
    $studentsWithSubjects = 0
    $studentsWithoutSubjects = 0
    
    while ($reader.Read()) {
        $fullName = $reader['FullName']
        $year = $reader['Year']
        $dept = $reader['StudentDept']
        $count = $reader['AvailableSubjects']
        
        if ($count -gt 0) {
            Write-Host "  ? $fullName | Year: $year | Dept: $dept | $count subjects available" -ForegroundColor Green
            $studentsWithSubjects++
        } else {
            Write-Host "  ? $fullName | Year: $year | Dept: $dept | 0 subjects available" -ForegroundColor Red
            $studentsWithoutSubjects++
        }
    }
    $reader.Close()
    
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor Cyan
    Write-Host "  Students with subjects: $studentsWithSubjects" -ForegroundColor Green
    Write-Host "  Students without subjects: $studentsWithoutSubjects" -ForegroundColor $(if ($studentsWithoutSubjects -eq 0) { "Green" } else { "Red" })
    Write-Host ""
    
    # STEP 5: Show what subjects are available for each year
    Write-Host "STEP 5: Available subjects by year..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    for ($year = 1; $year -le 4; $year++) {
        $yearName = @("", "I Year", "II Year", "III Year", "IV Year")[$year]
        $cmd.CommandText = @"
SELECT 
    s.Name AS SubjectName,
    f.Name AS FacultyName,
    asub.SelectedCount,
    asub.Department
FROM [dbo].[AssignedSubjects] asub
JOIN [dbo].[Subjects] s ON asub.SubjectId = s.SubjectId
JOIN [dbo].[Faculties] f ON asub.FacultyId = f.FacultyId
WHERE asub.Year = $year AND asub.SelectedCount < 30
ORDER BY s.Name, f.Name
"@
        
        $reader = $cmd.ExecuteReader()
        $hasSubjects = $false
        Write-Host "$yearName (Year $year):" -ForegroundColor Yellow
        
        while ($reader.Read()) {
            $hasSubjects = $true
            $subjectName = $reader['SubjectName']
            $facultyName = $reader['FacultyName']
            $selectedCount = $reader['SelectedCount']
            $dept = $reader['Department']
            Write-Host "  - $subjectName ($facultyName) - $selectedCount/30 enrolled - Dept: $dept" -ForegroundColor White
        }
        
        if (-not $hasSubjects) {
            Write-Host "  No available subjects for this year!" -ForegroundColor Red
        }
        
        $reader.Close()
        Write-Host ""
    }
    
    # Close connection
    $connection.Close()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   FIX COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    
    if ($studentsWithoutSubjects -eq 0) {
        Write-Host "SUCCESS! All students can now see subjects!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Cyan
        Write-Host "  1. Tell students to REFRESH their browser (Ctrl+F5)" -ForegroundColor White
        Write-Host "  2. Students should now see available subjects!" -ForegroundColor White
    } else {
        Write-Host "WARNING: $studentsWithoutSubjects students still cannot see subjects." -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible reasons:" -ForegroundColor Yellow
        Write-Host "  1. No subjects assigned for their year/department" -ForegroundColor White
        Write-Host "  2. All subjects are full (30/30 students)" -ForegroundColor White
        Write-Host "  3. Different department that needs subjects assigned" -ForegroundColor White
        Write-Host ""
        Write-Host "Action Required:" -ForegroundColor Red
        Write-Host "  Admin needs to assign subjects for affected students!" -ForegroundColor White
    }
    
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
    exit 1
}
