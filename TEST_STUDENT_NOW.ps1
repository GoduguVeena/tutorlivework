# COMPREHENSIVE DIAGNOSTIC - Run this ONE script to check everything!
# Student: 23091A32D4 (23091a32d4@rgmcet.edu.in / Student@123)

$ErrorActionPreference = "Stop"

Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "  COMPREHENSIVE STUDENT DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Testing student: 23091A32D4" -ForegroundColor Yellow
Write-Host "Email: 23091a32d4@rgmcet.edu.in" -ForegroundColor Yellow
Write-Host "Password: Student@123" -ForegroundColor Yellow
Write-Host ""

$connectionString = "Server=(localdb)\mssqllocaldb;Database=Working5Db;Trusted_Connection=True;MultipleActiveResultSets=true"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "? Connected to database (Working5Db)" -ForegroundColor Green
    Write-Host ""
    
    # ===== STEP 1: Login Test =====
    Write-Host "STEP 1: LOGIN TEST" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    $loginQuery = @"
SELECT Id, FullName, Department, Year, Email
FROM Students
WHERE Email = '23091a32d4@rgmcet.edu.in' AND Password = 'Student@123';
"@
    
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = $loginQuery
    $reader = $cmd.ExecuteReader()
    
    if (!$reader.Read()) {
        Write-Host "? LOGIN FAILED - Invalid credentials!" -ForegroundColor Red
        Write-Host "Check if student exists in database." -ForegroundColor Yellow
        $reader.Close()
        $connection.Close()
        exit 1
    }
    
    $studentId = $reader["Id"]
    $studentName = $reader["FullName"]
    $studentDept = $reader["Department"]
    $studentYear = $reader["Year"]
    
    Write-Host "? Login successful!" -ForegroundColor Green
    Write-Host "  ID: $studentId" -ForegroundColor White
    Write-Host "  Name: $studentName" -ForegroundColor White
    Write-Host "  Department: '$studentDept'" -ForegroundColor Yellow
    Write-Host "  Year: $studentYear" -ForegroundColor White
    $reader.Close()
    Write-Host ""
    
    # ===== STEP 2: Year Parsing =====
    Write-Host "STEP 2: YEAR PARSING" -ForegroundColor Cyan
    Write-Host "====================" -ForegroundColor Cyan
    
    $yearKey = $studentYear -replace " Year", "" | ForEach-Object { $_.Trim() }
    $yearNumber = switch ($yearKey) {
        "I" { 1 }
        "II" { 2 }
        "III" { 3 }
        "IV" { 4 }
        default { 0 }
    }
    
    Write-Host "  Year String: '$studentYear'" -ForegroundColor White
    Write-Host "  Parsed to: $yearNumber" -ForegroundColor Yellow
    
    if ($yearNumber -eq 0) {
        Write-Host "  ? PARSING FAILED!" -ForegroundColor Red
        $connection.Close()
        exit 1
    }
    
    Write-Host "  ? Parsing successful" -ForegroundColor Green
    Write-Host ""
    
    # ===== STEP 3: Department Normalization =====
    Write-Host "STEP 3: DEPARTMENT NORMALIZATION" -ForegroundColor Cyan
    Write-Host "=================================" -ForegroundColor Cyan
    
    function Normalize-Dept {
        param($dept)
        if ([string]::IsNullOrWhiteSpace($dept)) { return $dept }
        $upper = $dept.Trim().ToUpper()
        if ($upper -in @('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)')) {
            return 'CSE(DS)'
        }
        return $dept.Trim()
    }
    
    $normalizedStudentDept = Normalize-Dept $studentDept
    
    Write-Host "  Raw: '$studentDept'" -ForegroundColor White
    Write-Host "  Normalized: '$normalizedStudentDept'" -ForegroundColor Yellow
    Write-Host ""
    
    # ===== STEP 4: Fetch All Year 3 Subjects =====
    Write-Host "STEP 4: ALL ASSIGNED SUBJECTS FOR YEAR $yearNumber" -ForegroundColor Cyan
    Write-Host "=======================================" -ForegroundColor Cyan
    
    $subjectsQuery = @"
SELECT 
    a.AssignedSubjectId,
    s.SubjectId,
    s.Name AS SubjectName,
    s.Department AS SubjectDept,
    s.SubjectType,
    f.Name AS FacultyName,
    a.SelectedCount
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = $yearNumber
ORDER BY s.SubjectType, s.Name;
"@
    
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = $subjectsQuery
    $reader2 = $cmd2.ExecuteReader()
    
    $allSubjects = @()
    while ($reader2.Read()) {
        $allSubjects += [PSCustomObject]@{
            SubjectName = $reader2["SubjectName"]
            SubjectDept = $reader2["SubjectDept"]
            SubjectType = $reader2["SubjectType"]
            FacultyName = $reader2["FacultyName"]
            SelectedCount = $reader2["SelectedCount"]
        }
    }
    $reader2.Close()
    
    Write-Host "  Found $($allSubjects.Count) total subjects" -ForegroundColor White
    Write-Host ""
    
    if ($allSubjects.Count -eq 0) {
        Write-Host "  ? NO SUBJECTS FOUND!" -ForegroundColor Red
        Write-Host "  FIX: Assign subjects to faculty for Year $yearNumber" -ForegroundColor Yellow
        $connection.Close()
        exit 1
    }
    
    # ===== STEP 5: Department Filtering =====
    Write-Host "STEP 5: DEPARTMENT FILTERING" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    
    $matchCount = 0
    $mismatchCount = 0
    
    foreach ($subj in $allSubjects) {
        $subjNormalized = Normalize-Dept $subj.SubjectDept
        $match = $subjNormalized -eq $normalizedStudentDept
        
        if ($match) {
            $matchCount++
            Write-Host "  ? $($subj.SubjectName) | '$($subj.SubjectDept)' ? '$subjNormalized' | Type: $($subj.SubjectType)" -ForegroundColor Green
        } else {
            $mismatchCount++
            Write-Host "  ? $($subj.SubjectName) | '$($subj.SubjectDept)' ? '$subjNormalized' != '$normalizedStudentDept'" -ForegroundColor Red
        }
    }
    
    Write-Host ""
    Write-Host "  Matching: $matchCount subjects" -ForegroundColor Green
    Write-Host "  Not matching: $mismatchCount subjects" -ForegroundColor $(if ($mismatchCount -gt 0) { "Red" } else { "Gray" })
    Write-Host ""
    
    if ($matchCount -eq 0) {
        Write-Host "  ? DEPARTMENT MISMATCH!" -ForegroundColor Red
        Write-Host "  Student Dept: '$normalizedStudentDept'" -ForegroundColor Yellow
        Write-Host "  Subject Depts: " -ForegroundColor Yellow
        $allSubjects | ForEach-Object { "    - '$($_.SubjectDept)'" } | Select-Object -Unique | ForEach-Object { Write-Host $_ }
        Write-Host ""
        Write-Host "  FIX: Standardize department names to 'CSE(DS)'" -ForegroundColor Yellow
        $connection.Close()
        exit 1
    }
    
    # ===== STEP 6: Check Enrollments =====
    Write-Host "STEP 6: EXISTING ENROLLMENTS" -ForegroundColor Cyan
    Write-Host "=============================" -ForegroundColor Cyan
    
    $enrollQuery = @"
SELECT s.Name AS SubjectName
FROM StudentEnrollments e
INNER JOIN AssignedSubjects a ON e.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE e.StudentId = '$studentId';
"@
    
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = $enrollQuery
    $reader3 = $cmd3.ExecuteReader()
    
    $enrolledSubjects = @()
    while ($reader3.Read()) {
        $enrolledSubjects += $reader3["SubjectName"]
    }
    $reader3.Close()
    
    if ($enrolledSubjects.Count -gt 0) {
        Write-Host "  Enrolled in $($enrolledSubjects.Count) subjects:" -ForegroundColor White
        foreach ($subj in $enrolledSubjects) {
            Write-Host "    - $subj" -ForegroundColor Gray
        }
    } else {
        Write-Host "  No enrollments yet" -ForegroundColor Gray
    }
    Write-Host ""
    
    # ===== FINAL SUMMARY =====
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "  FINAL DIAGNOSIS" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    
    $availableAfterFilter = $matchCount - $enrolledSubjects.Count
    
    if ($availableAfterFilter -le 0) {
        Write-Host "? ISSUE: No subjects available to select!" -ForegroundColor Red
        Write-Host ""
        if ($enrolledSubjects.Count -gt 0) {
            Write-Host "  Reason: Student already enrolled in all matching subjects" -ForegroundColor Yellow
        } else {
            Write-Host "  Reason: All subjects filtered out by department mismatch" -ForegroundColor Yellow
        }
    } else {
        Write-Host "? SUCCESS: Student should see $availableAfterFilter subjects!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Expected on SelectSubject page:" -ForegroundColor White
        
        $coreCount = 0
        $pe1Count = 0
        $pe2Count = 0
        $pe3Count = 0
        
        foreach ($subj in $allSubjects) {
            $subjNorm = Normalize-Dept $subj.SubjectDept
            if ($subjNorm -eq $normalizedStudentDept -and $subj.SubjectName -notin $enrolledSubjects) {
                switch ($subj.SubjectType) {
                    "Core" { $coreCount++ }
                    "ProfessionalElective1" { $pe1Count++ }
                    "ProfessionalElective2" { $pe2Count++ }
                    "ProfessionalElective3" { $pe3Count++ }
                }
            }
        }
        
        Write-Host "  Core Subjects: $coreCount" -ForegroundColor Cyan
        Write-Host "  Professional Elective 1: $pe1Count" -ForegroundColor Cyan
        Write-Host "  Professional Elective 2: $pe2Count" -ForegroundColor Cyan
        Write-Host "  Professional Elective 3: $pe3Count" -ForegroundColor Cyan
        Write-Host ""
        
        if ($coreCount + $pe1Count + $pe2Count + $pe3Count -eq 0) {
            Write-Host "  ? WARNING: No subjects in any category!" -ForegroundColor Yellow
            Write-Host "  Possible issues:" -ForegroundColor Yellow
            Write-Host "    - All subjects already enrolled" -ForegroundColor White
            Write-Host "    - All subjects full (70 students)" -ForegroundColor White
            Write-Host "    - All professional electives full" -ForegroundColor White
        } else {
            Write-Host "  ? Subjects should appear on the page!" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "  NEXT STEPS" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    
    if ($availableAfterFilter -gt 0) {
        Write-Host "1. Stop your app (Shift+F5)" -ForegroundColor White
        Write-Host "2. Rebuild (Ctrl+Shift+B)" -ForegroundColor White
        Write-Host "3. Run (F5)" -ForegroundColor White
        Write-Host "4. Login and go to Select Faculty page" -ForegroundColor White
        Write-Host "5. Check Visual Studio Output window for logs" -ForegroundColor White
        Write-Host ""
        Write-Host "Look for these logs:" -ForegroundColor Yellow
        Write-Host "  SelectSubject GET - Found X total subjects" -ForegroundColor Gray
        Write-Host "  SelectSubject GET - After department filter: X subjects" -ForegroundColor Gray
    } else {
        Write-Host "Fix the issues above first!" -ForegroundColor Red
    }
    
    $connection.Close()
    
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Stack Trace:" -ForegroundColor Yellow
    Write-Host $_.Exception.StackTrace -ForegroundColor Gray
    exit 1
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
