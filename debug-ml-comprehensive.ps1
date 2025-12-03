# COMPREHENSIVE DEBUG: Why ML Subject Not Showing
# This script will check EVERYTHING and tell you exactly what's wrong

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  COMPREHENSIVE ML SUBJECT DEBUG TOOL" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Get student ID
$studentId = Read-Host "Enter student Registration Number (e.g., 23091A32D4)"

if ([string]::IsNullOrWhiteSpace($studentId)) {
    Write-Host "Error: Student ID required!" -ForegroundColor Red
    exit
}

# Database connection
$connectionString = "Server=(localdb)\mssqllocaldb;Database=TutorLiveMentorDb;Trusted_Connection=True;MultipleActiveResultSets=true"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "Connected to database" -ForegroundColor Green
    Write-Host ""
    
    # ===== STEP 1: Get student info =====
    Write-Host "STEP 1: STUDENT INFORMATION" -ForegroundColor Yellow
    Write-Host "============================" -ForegroundColor Yellow
    
    $query1 = "SELECT Id, FullName, Department, Year FROM Students WHERE Id = '$studentId'"
    $cmd1 = $connection.CreateCommand()
    $cmd1.CommandText = $query1
    $reader1 = $cmd1.ExecuteReader()
    
    if (!$reader1.Read()) {
        Write-Host "ERROR: Student not found!" -ForegroundColor Red
        $reader1.Close()
        $connection.Close()
        exit
    }
    
    $studentDept = $reader1["Department"]
    $studentYear = $reader1["Year"]
    $studentName = $reader1["FullName"]
    
    Write-Host "  Name: $studentName" -ForegroundColor White
    Write-Host "  Department: '$studentDept'" -ForegroundColor Cyan
    Write-Host "  Year: $studentYear" -ForegroundColor White
    $reader1.Close()
    Write-Host ""
    
    # Parse year to number
    $yearNum = 0
    switch -Regex ($studentYear) {
        "^I\s" { $yearNum = 1 }
        "^II\s" { $yearNum = 2 }
        "^III\s" { $yearNum = 3 }
        "^IV\s" { $yearNum = 4 }
    }
    
    Write-Host "  Parsed Year Number: $yearNum" -ForegroundColor White
    Write-Host ""
    
    # ===== STEP 2: Get ALL AssignedSubjects for this year =====
    Write-Host "STEP 2: ALL ASSIGNED SUBJECTS FOR YEAR $yearNum" -ForegroundColor Yellow
    Write-Host "=======================================" -ForegroundColor Yellow
    
    $query2 = @"
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    a.Year AS AssignedYear,
    s.SubjectId,
    s.Name AS SubjectName,
    s.Department AS SubjectDept,
    s.SubjectType,
    s.Year AS SubjectYear,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = $yearNum
ORDER BY s.Name;
"@
    
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = $query2
    $reader2 = $cmd2.ExecuteReader()
    
    $allAssignedSubjects = @()
    while ($reader2.Read()) {
        $allAssignedSubjects += [PSCustomObject]@{
            AssignedSubjectId = $reader2["AssignedSubjectId"]
            SubjectName = $reader2["SubjectName"]
            SubjectDept = $reader2["SubjectDept"]
            AssignedDept = $reader2["AssignedDept"]
            SubjectType = $reader2["SubjectType"]
            FacultyName = $reader2["FacultyName"]
        }
    }
    $reader2.Close()
    
    Write-Host "  Found $($allAssignedSubjects.Count) assigned subjects for Year $yearNum" -ForegroundColor White
    Write-Host ""
    
    if ($allAssignedSubjects.Count -eq 0) {
        Write-Host "  NO SUBJECTS ASSIGNED FOR YEAR $yearNum!" -ForegroundColor Red
        Write-Host "  This is why students see nothing." -ForegroundColor Yellow
        $connection.Close()
        exit
    }
    
    # Show all subjects
    foreach ($subj in $allAssignedSubjects) {
        Write-Host "  - $($subj.SubjectName) | Dept: '$($subj.SubjectDept)' | Type: $($subj.SubjectType) | Faculty: $($subj.FacultyName)" -ForegroundColor Gray
    }
    Write-Host ""
    
    # ===== STEP 3: Apply normalization filter =====
    Write-Host "STEP 3: APPLY DEPARTMENT NORMALIZATION" -ForegroundColor Yellow
    Write-Host "=======================================" -ForegroundColor Yellow
    
    function Normalize-Department {
        param($dept)
        if ([string]::IsNullOrWhiteSpace($dept)) { return $dept }
        $upper = $dept.Trim().ToUpper()
        if ($upper -eq "CSEDS" -or $upper -eq "CSDS" -or $upper -eq "CSE-DS" -or
            $upper -eq "CSE (DS)" -or $upper -eq "CSE_DS" -or $upper -eq "CSE(DS)") {
            return "CSE(DS)"
        }
        return $dept.Trim()
    }
    
    $normalizedStudentDept = Normalize-Department $studentDept
    Write-Host "  Student Dept: '$studentDept' -> Normalized: '$normalizedStudentDept'" -ForegroundColor Cyan
    Write-Host ""
    
    $matchingSubjects = @()
    foreach ($subj in $allAssignedSubjects) {
        $normalizedSubjDept = Normalize-Department $subj.SubjectDept
        
        if ($normalizedSubjDept -eq $normalizedStudentDept) {
            $matchingSubjects += $subj
            Write-Host "  MATCH: $($subj.SubjectName) | '$($subj.SubjectDept)' -> '$normalizedSubjDept'" -ForegroundColor Green
        } else {
            Write-Host "  NO MATCH: $($subj.SubjectName) | '$($subj.SubjectDept)' -> '$normalizedSubjDept' != '$normalizedStudentDept'" -ForegroundColor Red
        }
    }
    Write-Host ""
    
    Write-Host "  After department filter: $($matchingSubjects.Count) subjects" -ForegroundColor White
    Write-Host ""
    
    if ($matchingSubjects.Count -eq 0) {
        Write-Host "  CRITICAL ISSUE: NO SUBJECTS MATCH AFTER DEPARTMENT FILTER!" -ForegroundColor Red
        Write-Host ""
        Write-Host "  Diagnosis:" -ForegroundColor Yellow
        Write-Host "  - Student department: '$studentDept' (normalized: '$normalizedStudentDept')" -ForegroundColor White
        Write-Host "  - Available subject departments:" -ForegroundColor White
        foreach ($subj in $allAssignedSubjects | Select-Object -Unique SubjectDept) {
            $norm = Normalize-Department $subj.SubjectDept
            Write-Host "    - '$($subj.SubjectDept)' (normalized: '$norm')" -ForegroundColor White
        }
        Write-Host ""
        Write-Host "  FIX: Run this SQL to standardize all department names:" -ForegroundColor Yellow
        Write-Host "  UPDATE Students SET Department = 'CSE(DS)' WHERE Id = '$studentId';" -ForegroundColor Cyan
        Write-Host "  UPDATE Subjects SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%';" -ForegroundColor Cyan
        Write-Host "  UPDATE AssignedSubjects SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%';" -ForegroundColor Cyan
        $connection.Close()
        exit
    }
    
    # ===== STEP 4: Check if already enrolled =====
    Write-Host "STEP 4: CHECK STUDENT ENROLLMENTS" -ForegroundColor Yellow
    Write-Host "==================================" -ForegroundColor Yellow
    
    $query4 = @"
SELECT 
    s.Name AS SubjectName,
    s.SubjectId
FROM StudentEnrollments e
INNER JOIN AssignedSubjects a ON e.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE e.StudentId = '$studentId';
"@
    
    $cmd4 = $connection.CreateCommand()
    $cmd4.CommandText = $query4
    $reader4 = $cmd4.ExecuteReader()
    
    $enrolledSubjectIds = @()
    $enrolledSubjects = @()
    while ($reader4.Read()) {
        $enrolledSubjectIds += $reader4["SubjectId"]
        $enrolledSubjects += $reader4["SubjectName"]
    }
    $reader4.Close()
    
    if ($enrolledSubjects.Count -gt 0) {
        Write-Host "  Student already enrolled in:" -ForegroundColor White
        foreach ($subj in $enrolledSubjects) {
            Write-Host "    - $subj" -ForegroundColor Gray
        }
    } else {
        Write-Host "  Student has NOT enrolled in any subjects yet" -ForegroundColor White
    }
    Write-Host ""
    
    # Filter out enrolled subjects
    $availableSubjects = @()
    foreach ($subj in $matchingSubjects) {
        $subjId = ($allAssignedSubjects | Where-Object { $_.SubjectName -eq $subj.SubjectName })[0].SubjectName
        
        # Get actual SubjectId
        $query5 = "SELECT SubjectId FROM Subjects WHERE Name = '$($subj.SubjectName)'"
        $cmd5 = $connection.CreateCommand()
        $cmd5.CommandText = $query5
        $actualSubjId = $cmd5.ExecuteScalar()
        
        if ($enrolledSubjectIds -notcontains $actualSubjId) {
            $availableSubjects += $subj
        }
    }
    
    Write-Host "  After filtering enrolled: $($availableSubjects.Count) subjects available" -ForegroundColor White
    Write-Host ""
    
    # ===== STEP 5: Separate by type =====
    Write-Host "STEP 5: SUBJECTS BY TYPE (WHAT STUDENT SHOULD SEE)" -ForegroundColor Yellow
    Write-Host "===================================================" -ForegroundColor Yellow
    
    $coreSubjects = $availableSubjects | Where-Object { $_.SubjectType -eq "Core" }
    $pe1 = $availableSubjects | Where-Object { $_.SubjectType -eq "ProfessionalElective1" }
    $pe2 = $availableSubjects | Where-Object { $_.SubjectType -eq "ProfessionalElective2" }
    $pe3 = $availableSubjects | Where-Object { $_.SubjectType -eq "ProfessionalElective3" }
    
    Write-Host ""
    Write-Host "  CORE SUBJECTS: $($coreSubjects.Count)" -ForegroundColor Cyan
    foreach ($subj in $coreSubjects) {
        Write-Host "    - $($subj.SubjectName) | Faculty: $($subj.FacultyName)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  PROFESSIONAL ELECTIVE 1: $($pe1.Count)" -ForegroundColor Cyan
    foreach ($subj in $pe1) {
        Write-Host "    - $($subj.SubjectName) | Faculty: $($subj.FacultyName)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  PROFESSIONAL ELECTIVE 2: $($pe2.Count)" -ForegroundColor Cyan
    foreach ($subj in $pe2) {
        Write-Host "    - $($subj.SubjectName) | Faculty: $($subj.FacultyName)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "  PROFESSIONAL ELECTIVE 3: $($pe3.Count)" -ForegroundColor Cyan
    foreach ($subj in $pe3) {
        Write-Host "    - $($subj.SubjectName) | Faculty: $($subj.FacultyName)" -ForegroundColor White
    }
    
    Write-Host ""
    
    # ===== STEP 6: Check for ML specifically =====
    Write-Host "STEP 6: ML SUBJECT STATUS" -ForegroundColor Yellow
    Write-Host "=========================" -ForegroundColor Yellow
    
    $mlInAll = $allAssignedSubjects | Where-Object { $_.SubjectName -eq "ML" }
    $mlInMatching = $matchingSubjects | Where-Object { $_.SubjectName -eq "ML" }
    $mlInAvailable = $availableSubjects | Where-Object { $_.SubjectName -eq "ML" }
    
    if ($mlInAll) {
        Write-Host "  ML found in ALL Year $yearNum subjects" -ForegroundColor Green
        Write-Host "    - Subject Dept: '$($mlInAll.SubjectDept)'" -ForegroundColor White
        Write-Host "    - Assigned Dept: '$($mlInAll.AssignedDept)'" -ForegroundColor White
        Write-Host "    - Subject Type: $($mlInAll.SubjectType)" -ForegroundColor White
    } else {
        Write-Host "  ML NOT found in Year $yearNum AssignedSubjects!" -ForegroundColor Red
        Write-Host "  FIX: Assign ML to a faculty member for Year $yearNum" -ForegroundColor Yellow
        $connection.Close()
        exit
    }
    
    if ($mlInMatching) {
        Write-Host "  ML PASSED department filter" -ForegroundColor Green
    } else {
        Write-Host "  ML FAILED department filter!" -ForegroundColor Red
        $normalizedML = Normalize-Department $mlInAll.SubjectDept
        Write-Host "  ML Dept: '$($mlInAll.SubjectDept)' -> Normalized: '$normalizedML'" -ForegroundColor White
        Write-Host "  Student: '$studentDept' -> Normalized: '$normalizedStudentDept'" -ForegroundColor White
        Write-Host ""
        Write-Host "  FIX: Update ML subject department to match student:" -ForegroundColor Yellow
        Write-Host "  UPDATE Subjects SET Department = 'CSE(DS)' WHERE Name = 'ML';" -ForegroundColor Cyan
        $connection.Close()
        exit
    }
    
    if ($mlInAvailable) {
        Write-Host "  ML is AVAILABLE to select" -ForegroundColor Green
        Write-Host ""
        Write-Host "  SUCCESS: ML should be visible on the SelectSubject page!" -ForegroundColor Green
        Write-Host "  If not showing, check:" -ForegroundColor Yellow
        Write-Host "  - Faculty selection schedule (might be disabled)" -ForegroundColor White
        Write-Host "  - Browser cache (Ctrl+F5)" -ForegroundColor White
        Write-Host "  - Check Visual Studio Output window for console logs" -ForegroundColor White
    } else {
        Write-Host "  ML filtered out (already enrolled)" -ForegroundColor Yellow
    }
    
    $connection.Close()
    
} catch {
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
