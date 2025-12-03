# Test the exact login flow for student 23091A32D4
# This simulates what happens when the student logs in and goes to SelectSubject

$connectionString = "Server=(localdb)\mssqllocaldb;Database=TutorLiveMentorDb;Trusted_Connection=True;MultipleActiveResultSets=true"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "SIMULATING STUDENT LOGIN & SELECT SUBJECT" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Student Credentials:" -ForegroundColor Yellow
Write-Host "  Email: 23091a32d4@rgmcet.edu.in"
Write-Host "  Password: Student@123"
Write-Host ""

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    # Step 1: Login
    Write-Host "STEP 1: LOGGING IN" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    $query = @"
SELECT 
    Id,
    FullName,
    Department,
    Year,
    Email
FROM Students
WHERE Email = '23091a32d4@rgmcet.edu.in' AND Password = 'Student@123';
"@
    
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = $query
    $reader = $cmd.ExecuteReader()
    
    if (!$reader.Read()) {
        Write-Host "LOGIN FAILED - Invalid credentials!" -ForegroundColor Red
        $reader.Close()
        $connection.Close()
        exit
    }
    
    $studentId = $reader["Id"]
    $studentName = $reader["FullName"]
    $studentDept = $reader["Department"]
    $studentYear = $reader["Year"]
    
    Write-Host "Login successful!" -ForegroundColor Green
    Write-Host "  Student ID: $studentId"
    Write-Host "  Name: $studentName"
    Write-Host "  Department: '$studentDept'"
    Write-Host "  Year: $studentYear"
    $reader.Close()
    Write-Host ""
    
    # Step 2: Parse Year
    Write-Host "STEP 2: PARSING YEAR" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    
    $yearKey = $studentYear -replace " Year", "" | ForEach-Object { $_.Trim() }
    $yearNumber = switch ($yearKey) {
        "I" { 1 }
        "II" { 2 }
        "III" { 3 }
        "IV" { 4 }
        default { 0 }
    }
    
    Write-Host "  Year String: '$studentYear'"
    Write-Host "  Year Key: '$yearKey'"
    Write-Host "  Year Number: $yearNumber"
    Write-Host ""
    
    # Step 3: Normalize Department
    Write-Host "STEP 3: NORMALIZING DEPARTMENT" -ForegroundColor Cyan
    Write-Host "===============================" -ForegroundColor Cyan
    
    function Normalize-Department {
        param($dept)
        if ([string]::IsNullOrWhiteSpace($dept)) { return $dept }
        $upper = $dept.Trim().ToUpper()
        if ($upper -in @('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)')) {
            return 'CSE(DS)'
        }
        return $dept.Trim()
    }
    
    $normalizedStudentDept = Normalize-Department $studentDept
    
    Write-Host "  Raw Department: '$studentDept'"
    Write-Host "  Normalized: '$normalizedStudentDept'"
    Write-Host ""
    
    # Step 4: Get ALL subjects for the year
    Write-Host "STEP 4: FETCHING ALL YEAR $yearNumber SUBJECTS" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    
    $query2 = @"
SELECT 
    a.AssignedSubjectId,
    s.SubjectId,
    s.Name AS SubjectName,
    s.Department AS SubjectDept,
    s.SubjectType,
    f.Name AS FacultyName,
    a.SelectedCount,
    s.MaxEnrollments
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = $yearNumber
ORDER BY s.SubjectType, s.Name;
"@
    
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = $query2
    $reader2 = $cmd2.ExecuteReader()
    
    $allSubjects = @()
    while ($reader2.Read()) {
        $allSubjects += [PSCustomObject]@{
            AssignedSubjectId = $reader2["AssignedSubjectId"]
            SubjectId = $reader2["SubjectId"]
            SubjectName = $reader2["SubjectName"]
            SubjectDept = $reader2["SubjectDept"]
            SubjectType = $reader2["SubjectType"]
            FacultyName = $reader2["FacultyName"]
            SelectedCount = $reader2["SelectedCount"]
            MaxEnrollments = if ($reader2["MaxEnrollments"] -is [DBNull]) { $null } else { $reader2["MaxEnrollments"] }
        }
    }
    $reader2.Close()
    
    Write-Host "  Found $($allSubjects.Count) total subjects for Year $yearNumber"
    Write-Host ""
    
    if ($allSubjects.Count -eq 0) {
        Write-Host "  NO SUBJECTS FOUND!" -ForegroundColor Red
        Write-Host "  This is why student sees nothing!" -ForegroundColor Yellow
        $connection.Close()
        exit
    }
    
    # Show each subject
    foreach ($subj in $allSubjects) {
        $subjNormalized = Normalize-Department $subj.SubjectDept
        $match = if ($subjNormalized -eq $normalizedStudentDept) { "MATCH" } else { "NO MATCH" }
        $color = if ($match -eq "MATCH") { "Green" } else { "Red" }
        
        Write-Host "  - $($subj.SubjectName) | Dept: '$($subj.SubjectDept)' -> '$subjNormalized' | $match" -ForegroundColor $color
    }
    Write-Host ""
    
    # Step 5: Filter by department
    Write-Host "STEP 5: FILTERING BY DEPARTMENT" -ForegroundColor Cyan
    Write-Host "================================" -ForegroundColor Cyan
    
    $matchingSubjects = $allSubjects | Where-Object {
        (Normalize-Department $_.SubjectDept) -eq $normalizedStudentDept
    }
    
    Write-Host "  After department filter: $($matchingSubjects.Count) subjects"
    Write-Host ""
    
    if ($matchingSubjects.Count -eq 0) {
        Write-Host "  DEPARTMENT MISMATCH!" -ForegroundColor Red
        Write-Host "  Student Dept: '$normalizedStudentDept'"
        Write-Host "  Available Depts: " -ForegroundColor Yellow
        $allSubjects | ForEach-Object { 
            Write-Host "    - '$($_.SubjectDept)' -> '$(Normalize-Department $_.SubjectDept)'"
        } | Select-Object -Unique
        $connection.Close()
        exit
    }
    
    # Step 6: Check enrollments
    Write-Host "STEP 6: CHECKING EXISTING ENROLLMENTS" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
    
    $query3 = @"
SELECT s.SubjectId
FROM StudentEnrollments e
INNER JOIN AssignedSubjects a ON e.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE e.StudentId = '$studentId';
"@
    
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = $query3
    $reader3 = $cmd3.ExecuteReader()
    
    $enrolledSubjectIds = @()
    while ($reader3.Read()) {
        $enrolledSubjectIds += $reader3["SubjectId"]
    }
    $reader3.Close()
    
    Write-Host "  Student enrolled in $($enrolledSubjectIds.Count) subjects"
    Write-Host ""
    
    # Filter out enrolled subjects
    $availableSubjects = $matchingSubjects | Where-Object { $enrolledSubjectIds -notcontains $_.SubjectId }
    
    Write-Host "  After filtering enrolled: $($availableSubjects.Count) subjects available"
    Write-Host ""
    
    # Step 7: Separate by type
    Write-Host "STEP 7: SUBJECTS BY TYPE" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    $coreSubjects = $availableSubjects | Where-Object { $_.SubjectType -eq "Core" -and $_.SelectedCount -lt 70 }
    $pe1 = $availableSubjects | Where-Object { $_.SubjectType -eq "ProfessionalElective1" }
    $pe2 = $availableSubjects | Where-Object { $_.SubjectType -eq "ProfessionalElective2" }
    $pe3 = $availableSubjects | Where-Object { $_.SubjectType -eq "ProfessionalElective3" }
    
    Write-Host "  Core Subjects: $($coreSubjects.Count)"
    foreach ($s in $coreSubjects) {
        Write-Host "    - $($s.SubjectName) | Faculty: $($s.FacultyName) | Count: $($s.SelectedCount)/70"
    }
    Write-Host ""
    
    Write-Host "  Professional Elective 1: $($pe1.Count)"
    foreach ($s in $pe1) {
        $max = if ($s.MaxEnrollments) { $s.MaxEnrollments } else { "No limit" }
        Write-Host "    - $($s.SubjectName) | Faculty: $($s.FacultyName) | Count: $($s.SelectedCount)/$max"
    }
    Write-Host ""
    
    Write-Host "  Professional Elective 2: $($pe2.Count)"
    foreach ($s in $pe2) {
        $max = if ($s.MaxEnrollments) { $s.MaxEnrollments } else { "No limit" }
        Write-Host "    - $($s.SubjectName) | Faculty: $($s.FacultyName) | Count: $($s.SelectedCount)/$max"
    }
    Write-Host ""
    
    Write-Host "  Professional Elective 3: $($pe3.Count)"
    foreach ($s in $pe3) {
        $max = if ($s.MaxEnrollments) { $s.MaxEnrollments } else { "No limit" }
        Write-Host "    - $($s.SubjectName) | Faculty: $($s.FacultyName) | Count: $($s.SelectedCount)/$max"
    }
    Write-Host ""
    
    # Final diagnosis
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "FINAL DIAGNOSIS" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    $totalAvailable = $coreSubjects.Count + $pe1.Count + $pe2.Count + $pe3.Count
    
    if ($totalAvailable -eq 0) {
        Write-Host "ISSUE: Student should see 0 subjects" -ForegroundColor Red
        Write-Host "Possible causes:" -ForegroundColor Yellow
        Write-Host "  1. All subjects already enrolled"
        Write-Host "  2. No subjects assigned for Year $yearNumber in CSE(DS)"
        Write-Host "  3. Department mismatch in database"
    } else {
        Write-Host "SUCCESS: Student should see $totalAvailable subjects" -ForegroundColor Green
        Write-Host "  - Core: $($coreSubjects.Count)"
        Write-Host "  - PE1: $($pe1.Count)"
        Write-Host "  - PE2: $($pe2.Count)"
        Write-Host "  - PE3: $($pe3.Count)"
        Write-Host ""
        Write-Host "If student doesn't see these subjects, check:" -ForegroundColor Yellow
        Write-Host "  1. Visual Studio Output window logs"
        Write-Host "  2. Faculty selection schedule (might be disabled)"
        Write-Host "  3. Browser cache (Ctrl+F5)"
    }
    
    $connection.Close()
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
