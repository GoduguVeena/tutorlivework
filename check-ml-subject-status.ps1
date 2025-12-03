# Verify ML Subject and Faculty Assignment Status
# This script helps diagnose why students can't see the ML subject

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "ML SUBJECT DIAGNOSTIC TOOL" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Database connection string (update if different)
$connectionString = "Server=(localdb)\mssqllocaldb;Database=TutorLiveMentorDb;Trusted_Connection=True;MultipleActiveResultSets=true"

Write-Host "Connecting to database..." -ForegroundColor Yellow

try {
    # Load SQL Server module
    Import-Module SqlServer -ErrorAction SilentlyContinue
    
    # If module not available, use .NET classes
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "? Connected successfully!" -ForegroundColor Green
    Write-Host ""
    
    # Query 1: Check if ML subject exists
    Write-Host "1. CHECKING ML SUBJECT IN SUBJECTS TABLE" -ForegroundColor Cyan
    Write-Host "=========================================" -ForegroundColor Cyan
    
    $query1 = @"
SELECT 
    SubjectId,
    Name,
    Department,
    Year,
    Semester,
    SubjectType,
    MaxEnrollments
FROM Subjects
WHERE Name = 'ML';
"@
    
    $command1 = $connection.CreateCommand()
    $command1.CommandText = $query1
    $reader1 = $command1.ExecuteReader()
    
    $mlExists = $false
    $mlSubjectId = 0
    
    if ($reader1.HasRows) {
        while ($reader1.Read()) {
            $mlExists = $true
            $mlSubjectId = $reader1["SubjectId"]
            Write-Host "? ML Subject Found!" -ForegroundColor Green
            Write-Host "  - Subject ID: $($reader1['SubjectId'])" -ForegroundColor White
            Write-Host "  - Name: $($reader1['Name'])" -ForegroundColor White
            Write-Host "  - Department: $($reader1['Department'])" -ForegroundColor White
            Write-Host "  - Year: $($reader1['Year'])" -ForegroundColor White
            Write-Host "  - Semester: $($reader1['Semester'])" -ForegroundColor White
            Write-Host "  - Type: $($reader1['SubjectType'])" -ForegroundColor White
            Write-Host "  - Max Enrollments: $($reader1['MaxEnrollments'])" -ForegroundColor White
        }
    } else {
        Write-Host "? ML Subject NOT FOUND in Subjects table!" -ForegroundColor Red
        Write-Host "  Action: Go to Admin > Manage CSEDS Subjects and add ML subject first." -ForegroundColor Yellow
    }
    $reader1.Close()
    Write-Host ""
    
    if ($mlExists) {
        # Query 2: Check faculty assignments
        Write-Host "2. CHECKING FACULTY ASSIGNMENTS FOR ML" -ForegroundColor Cyan
        Write-Host "========================================" -ForegroundColor Cyan
        
        $query2 = @"
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    a.Year,
    a.SelectedCount,
    s.Name AS SubjectName,
    s.Department AS SubjectDept,
    f.FacultyId,
    f.Name AS FacultyName,
    f.Email AS FacultyEmail,
    f.Department AS FacultyDept
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.SubjectId = $mlSubjectId;
"@
        
        $command2 = $connection.CreateCommand()
        $command2.CommandText = $query2
        $reader2 = $command2.ExecuteReader()
        
        $assignmentCount = 0
        if ($reader2.HasRows) {
            while ($reader2.Read()) {
                $assignmentCount++
                Write-Host "? Assignment #$assignmentCount Found!" -ForegroundColor Green
                Write-Host "  - Faculty: $($reader2['FacultyName']) ($($reader2['FacultyEmail']))" -ForegroundColor White
                Write-Host "  - Faculty Dept: $($reader2['FacultyDept'])" -ForegroundColor White
                Write-Host "  - Students Enrolled: $($reader2['SelectedCount'])" -ForegroundColor White
                Write-Host ""
            }
            Write-Host "? ML is assigned to $assignmentCount faculty member(s)" -ForegroundColor Green
            Write-Host "  Students SHOULD see this subject!" -ForegroundColor Green
        } else {
            Write-Host "? ML is NOT assigned to any faculty!" -ForegroundColor Red
            Write-Host "  This is why students can't see it!" -ForegroundColor Yellow
            Write-Host ""
            Write-Host "  SOLUTION:" -ForegroundColor Yellow
            Write-Host "  1. Go to: localhost:5000/Admin/ManageCSEDSFaculty" -ForegroundColor White
            Write-Host "  2. Click 'Assign Subjects' button for a faculty member" -ForegroundColor White
            Write-Host "  3. Check the box next to 'ML' subject" -ForegroundColor White
            Write-Host "  4. Click 'Save Assignment'" -ForegroundColor White
        }
        $reader2.Close()
        Write-Host ""
        
        # Query 3: Check CSE(DS) faculty availability
        Write-Host "3. AVAILABLE CSE(DS) FACULTY MEMBERS" -ForegroundColor Cyan
        Write-Host "=====================================" -ForegroundColor Cyan
        
        $query3 = @"
SELECT 
    FacultyId,
    Name,
    Email,
    Department
FROM Faculties
WHERE Department IN ('CSE(DS)', 'CSEDS')
ORDER BY Name;
"@
        
        $command3 = $connection.CreateCommand()
        $command3.CommandText = $query3
        $reader3 = $command3.ExecuteReader()
        
        $facultyCount = 0
        if ($reader3.HasRows) {
            while ($reader3.Read()) {
                $facultyCount++
                Write-Host "  $facultyCount. $($reader3['Name']) - $($reader3['Email']) ($($reader3['Department']))" -ForegroundColor White
            }
            Write-Host ""
            Write-Host "? $facultyCount faculty member(s) available" -ForegroundColor Green
        } else {
            Write-Host "? No CSE(DS) faculty found!" -ForegroundColor Red
            Write-Host "  Add faculty first before assigning subjects." -ForegroundColor Yellow
        }
        $reader3.Close()
        Write-Host ""
        
        # Query 4: Check Year 3 CSE(DS) students
        Write-Host "4. YEAR 3 CSE(DS) STUDENTS" -ForegroundColor Cyan
        Write-Host "==========================" -ForegroundColor Cyan
        
        $query4 = @"
SELECT 
    Id,
    FullName,
    Email,
    Department,
    Year
FROM Students
WHERE Department IN ('CSE(DS)', 'CSEDS')
  AND Year = 'III Year'
ORDER BY FullName;
"@
        
        $command4 = $connection.CreateCommand()
        $command4.CommandText = $query4
        $reader4 = $command4.ExecuteReader()
        
        $studentCount = 0
        if ($reader4.HasRows) {
            while ($reader4.Read()) {
                $studentCount++
                Write-Host "  $studentCount. $($reader4['FullName']) - $($reader4['Email'])" -ForegroundColor White
            }
            Write-Host ""
            Write-Host "? $studentCount Year 3 student(s) found" -ForegroundColor Green
        } else {
            Write-Host "? No Year 3 CSE(DS) students found!" -ForegroundColor Yellow
        }
        $reader4.Close()
    }
    
    Write-Host ""
    Write-Host "==================================" -ForegroundColor Cyan
    Write-Host "DIAGNOSTIC COMPLETE" -ForegroundColor Cyan
    Write-Host "==================================" -ForegroundColor Cyan
    
    $connection.Close()
    
} catch {
    Write-Host "? Error connecting to database!" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure:" -ForegroundColor Yellow
    Write-Host "  1. SQL Server LocalDB is running" -ForegroundColor White
    Write-Host "  2. Database name is correct (TutorLiveMentorDb)" -ForegroundColor White
    Write-Host "  3. Connection string is valid" -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
