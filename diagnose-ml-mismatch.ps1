Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ML SUBJECT DEPARTMENT MISMATCH DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Prompt for student ID
$studentId = Read-Host "Enter student Registration Number (e.g., 23091A32D4)"

if ([string]::IsNullOrWhiteSpace($studentId)) {
    Write-Host "Error: Student ID is required!" -ForegroundColor Red
    exit
}

# Database connection
$connectionString = "Server=(localdb)\mssqllocaldb;Database=TutorLiveMentorDb;Trusted_Connection=True;MultipleActiveResultSets=true"

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "? Connected to database" -ForegroundColor Green
    Write-Host ""
    
    # 1. Check student department
    Write-Host "1. STUDENT DEPARTMENT" -ForegroundColor Cyan
    Write-Host "=====================" -ForegroundColor Cyan
    
    $query1 = @"
SELECT 
    Id,
    FullName,
    Department AS StudentDepartment,
    Year
FROM Students
WHERE Id = '$studentId';
"@
    
    $cmd1 = $connection.CreateCommand()
    $cmd1.CommandText = $query1
    $reader1 = $cmd1.ExecuteReader()
    
    $studentDept = $null
    $studentYear = $null
    
    if ($reader1.Read()) {
        $studentDept = $reader1["StudentDepartment"]
        $studentYear = $reader1["Year"]
        Write-Host "  Student: $($reader1['FullName'])" -ForegroundColor White
        Write-Host "  Department: '$studentDept'" -ForegroundColor Yellow
        Write-Host "  Year: $studentYear" -ForegroundColor White
    } else {
        Write-Host "  ? Student not found!" -ForegroundColor Red
        $reader1.Close()
        $connection.Close()
        exit
    }
    $reader1.Close()
    Write-Host ""
    
    # 2. Check ML subject
    Write-Host "2. ML SUBJECT IN DATABASE" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    
    $query2 = @"
SELECT 
    SubjectId,
    Name,
    Department AS SubjectDepartment,
    Year,
    SubjectType
FROM Subjects
WHERE Name = 'ML';
"@
    
    $cmd2 = $connection.CreateCommand()
    $cmd2.CommandText = $query2
    $reader2 = $cmd2.ExecuteReader()
    
    $mlSubjectId = 0
    $subjectDept = $null
    $subjectYear = 0
    
    if ($reader2.Read()) {
        $mlSubjectId = $reader2["SubjectId"]
        $subjectDept = $reader2["SubjectDepartment"]
        $subjectYear = $reader2["Year"]
        Write-Host "  ? ML Subject found!" -ForegroundColor Green
        Write-Host "  Subject ID: $mlSubjectId" -ForegroundColor White
        Write-Host "  Department: '$subjectDept'" -ForegroundColor Yellow
        Write-Host "  Year: $subjectYear" -ForegroundColor White
        Write-Host "  Type: $($reader2['SubjectType'])" -ForegroundColor White
    } else {
        Write-Host "  ? ML Subject not found!" -ForegroundColor Red
        $reader2.Close()
        $connection.Close()
        exit
    }
    $reader2.Close()
    Write-Host ""
    
    # 3. Check assignments
    Write-Host "3. ML FACULTY ASSIGNMENTS" -ForegroundColor Cyan
    Write-Host "=========================" -ForegroundColor Cyan
    
    $query3 = @"
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    a.Year AS AssignedYear,
    f.Name AS FacultyName,
    f.Department AS FacultyDept
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.SubjectId = $mlSubjectId;
"@
    
    $cmd3 = $connection.CreateCommand()
    $cmd3.CommandText = $query3
    $reader3 = $cmd3.ExecuteReader()
    
    $assignmentCount = 0
    $assignedDept = $null
    
    if ($reader3.HasRows) {
        while ($reader3.Read()) {
            $assignmentCount++
            $assignedDept = $reader3["AssignedDept"]
            Write-Host "  Assignment #$assignmentCount" -ForegroundColor Green
            Write-Host "    Faculty: $($reader3['FacultyName'])" -ForegroundColor White
            Write-Host "    AssignedSubject.Department: '$assignedDept'" -ForegroundColor Yellow
            Write-Host "    AssignedSubject.Year: $($reader3['AssignedYear'])" -ForegroundColor White
            Write-Host "    Faculty.Department: '$($reader3['FacultyDept'])'" -ForegroundColor Yellow
            Write-Host ""
        }
    } else {
        Write-Host "  ? No faculty assignments found!" -ForegroundColor Red
    }
    $reader3.Close()
    Write-Host ""
    
    # 4. DEPARTMENT COMPARISON
    Write-Host "4. DEPARTMENT COMPARISON" -ForegroundColor Cyan
    Write-Host "========================" -ForegroundColor Cyan
    
    Write-Host "  Student.Department:        '$studentDept'" -ForegroundColor Yellow
    Write-Host "  Subject.Department:        '$subjectDept'" -ForegroundColor Yellow
    Write-Host "  AssignedSubject.Department: '$assignedDept'" -ForegroundColor Yellow
    Write-Host ""
    
    # Normalize using C# logic
    function Normalize-Department {
        param($dept)
        
        if ([string]::IsNullOrWhiteSpace($dept)) {
            return $dept
        }
        
        $upper = $dept.Trim().ToUpper()
        
        if ($upper -eq "CSEDS" -or $upper -eq "CSDS" -or $upper -eq "CSE-DS" -or
            $upper -eq "CSE (DS)" -or $upper -eq "CSE_DS" -or $upper -eq "CSE(DS)") {
            return "CSE(DS)"
        }
        
        return $dept.Trim()
    }
    
    $normalizedStudentDept = Normalize-Department $studentDept
    $normalizedSubjectDept = Normalize-Department $subjectDept
    $normalizedAssignedDept = Normalize-Department $assignedDept
    
    Write-Host "  After normalization:" -ForegroundColor Cyan
    Write-Host "    Student:        '$normalizedStudentDept'" -ForegroundColor Yellow
    Write-Host "    Subject:        '$normalizedSubjectDept'" -ForegroundColor Yellow
    Write-Host "    AssignedSubject: '$normalizedAssignedDept'" -ForegroundColor Yellow
    Write-Host ""
    
    # 5. MATCH ANALYSIS
    Write-Host "5. MATCH ANALYSIS" -ForegroundColor Cyan
    Write-Host "=================" -ForegroundColor Cyan
    
    if ($normalizedStudentDept -eq $normalizedSubjectDept) {
        Write-Host "  ? Student dept matches Subject dept after normalization" -ForegroundColor Green
    } else {
        Write-Host "  ? MISMATCH: Student dept vs Subject dept" -ForegroundColor Red
        Write-Host "    Student: '$normalizedStudentDept' != Subject: '$normalizedSubjectDept'" -ForegroundColor Yellow
    }
    
    # Parse year
    $studentYearNum = switch -Regex ($studentYear) {
        "I" { 1 }
        "II" { 2 }
        "III" { 3 }
        "IV" { 4 }
        default { 0 }
    }
    
    if ($studentYearNum -eq $subjectYear) {
        Write-Host "  ? Student year matches Subject year" -ForegroundColor Green
    } else {
        Write-Host "  ? MISMATCH: Student year ($studentYearNum) vs Subject year ($subjectYear)" -ForegroundColor Red
    }
    Write-Host ""
    
    # 6. DIAGNOSIS
    Write-Host "6. DIAGNOSIS & FIX" -ForegroundColor Cyan
    Write-Host "==================" -ForegroundColor Cyan
    
    if ($assignmentCount -eq 0) {
        Write-Host "  ? ISSUE: ML subject is NOT assigned to any faculty!" -ForegroundColor Red
        Write-Host "  FIX: Assign ML to faculty in Admin > Faculty Management" -ForegroundColor Yellow
    }
    elseif ($normalizedStudentDept -ne $normalizedSubjectDept) {
        Write-Host "  ? ISSUE: Department mismatch after normalization!" -ForegroundColor Red
        Write-Host "  Student: '$studentDept' ? '$normalizedStudentDept'" -ForegroundColor Yellow
        Write-Host "  Subject: '$subjectDept' ? '$normalizedSubjectDept'" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "  FIX: Update database to use consistent department names" -ForegroundColor Yellow
        Write-Host "  Run this SQL:" -ForegroundColor White
        Write-Host "  UPDATE Subjects SET Department = 'CSE(DS)' WHERE Name = 'ML';" -ForegroundColor Cyan
        Write-Host "  UPDATE AssignedSubjects SET Department = 'CSE(DS)' WHERE SubjectId = $mlSubjectId;" -ForegroundColor Cyan
        Write-Host "  UPDATE Students SET Department = 'CSE(DS)' WHERE Id = '$studentId';" -ForegroundColor Cyan
    }
    elseif ($studentYearNum -ne $subjectYear) {
        Write-Host "  ? ISSUE: Year mismatch!" -ForegroundColor Red
        Write-Host "  Student is in year $studentYearNum but ML is for year $subjectYear" -ForegroundColor Yellow
    }
    else {
        Write-Host "  ? Everything looks correct!" -ForegroundColor Green
        Write-Host "  Subject should be visible to the student." -ForegroundColor Green
        Write-Host ""
        Write-Host "  If still not showing, check:" -ForegroundColor Yellow
        Write-Host "  - Faculty selection schedule (might be disabled)" -ForegroundColor White
        Write-Host "  - Student already enrolled in ML" -ForegroundColor White
        Write-Host "  - Browser cache (try Ctrl+F5)" -ForegroundColor White
    }
    
    $connection.Close()
    
} catch {
    Write-Host "? Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
