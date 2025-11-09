# PowerShell script to check available subjects for a specific student

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CHECK AVAILABLE SUBJECTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
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
    
    # Get all students
    Write-Host "Available Students:" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "SELECT Id, FullName, Year, Department FROM [dbo].[Students] ORDER BY FullName"
    $reader = $cmd.ExecuteReader()
    $students = @()
    $index = 1
    while ($reader.Read()) {
        $student = [PSCustomObject]@{
            Index = $index
            Id = $reader["Id"]
            FullName = $reader["FullName"]
            Year = $reader["Year"]
            Department = $reader["Department"]
        }
        $students += $student
        Write-Host "$index. $($student.FullName) - Year: $($student.Year), Dept: $($student.Department)" -ForegroundColor White
        $index++
    }
    $reader.Close()
    
    if ($students.Count -eq 0) {
        Write-Host "No students found in database." -ForegroundColor Red
        $connection.Close()
        exit 0
    }
    
    Write-Host ""
    $selection = Read-Host "Enter student number to check (or press Enter for student #1)"
    if ([string]::IsNullOrWhiteSpace($selection)) {
        $selection = "1"
    }
    
    $selectedIndex = [int]$selection - 1
    if ($selectedIndex -lt 0 -or $selectedIndex -ge $students.Count) {
        Write-Host "Invalid selection." -ForegroundColor Red
        $connection.Close()
        exit 1
    }
    
    $selectedStudent = $students[$selectedIndex]
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Student: $($selectedStudent.FullName)" -ForegroundColor Yellow
    Write-Host "Year: $($selectedStudent.Year)" -ForegroundColor White
    Write-Host "Department: $($selectedStudent.Department)" -ForegroundColor White
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Convert year to number
    $yearMap = @{ "I Year" = 1; "II Year" = 2; "III Year" = 3; "IV Year" = 4 }
    $studentYearNumber = $yearMap[$selectedStudent.Year]
    
    if ($null -eq $studentYearNumber) {
        Write-Host "ERROR: Could not parse student year: $($selectedStudent.Year)" -ForegroundColor Red
        $connection.Close()
        exit 1
    }
    
    Write-Host "Looking for subjects with:" -ForegroundColor Cyan
    Write-Host "  Year = $studentYearNumber" -ForegroundColor White
    Write-Host "  Department = $($selectedStudent.Department)" -ForegroundColor White
    Write-Host ""
    
    # Get already enrolled subjects
    $cmd.CommandText = @"
SELECT DISTINCT s.SubjectId, s.Name
FROM [dbo].[StudentEnrollments] se
INNER JOIN [dbo].[AssignedSubjects] asub ON se.AssignedSubjectId = asub.AssignedSubjectId
INNER JOIN [dbo].[Subjects] s ON asub.SubjectId = s.SubjectId
WHERE se.StudentId = @StudentId
"@
    $cmd.Parameters.Clear()
    $cmd.Parameters.AddWithValue("@StudentId", $selectedStudent.Id) | Out-Null
    $reader = $cmd.ExecuteReader()
    $enrolledSubjects = @()
    while ($reader.Read()) {
        $enrolledSubjects += $reader["SubjectId"]
    }
    $reader.Close()
    
    Write-Host "Already Enrolled In: $($enrolledSubjects.Count) subject(s)" -ForegroundColor Yellow
    if ($enrolledSubjects.Count -gt 0) {
        $cmd.CommandText = @"
SELECT s.Name
FROM [dbo].[StudentEnrollments] se
INNER JOIN [dbo].[AssignedSubjects] asub ON se.AssignedSubjectId = asub.AssignedSubjectId
INNER JOIN [dbo].[Subjects] s ON asub.SubjectId = s.SubjectId
WHERE se.StudentId = @StudentId
"@
        $reader = $cmd.ExecuteReader()
        while ($reader.Read()) {
            Write-Host "  - $($reader['Name'])" -ForegroundColor Magenta
        }
        $reader.Close()
    }
    Write-Host ""
    
    # Get available subjects
    Write-Host "Available Subjects for Selection:" -ForegroundColor Green
    Write-Host "----------------------------------------" -ForegroundColor Green
    
    $enrolledSubjectFilter = if ($enrolledSubjects.Count -gt 0) {
        "AND asub.SubjectId NOT IN (" + ($enrolledSubjects -join ",") + ")"
    } else {
        ""
    }
    
    $cmd.CommandText = @"
SELECT 
    asub.AssignedSubjectId,
    s.Name AS SubjectName,
    f.Name AS FacultyName,
    asub.SelectedCount,
    asub.Year,
    asub.Department
FROM [dbo].[AssignedSubjects] asub
INNER JOIN [dbo].[Subjects] s ON asub.SubjectId = s.SubjectId
INNER JOIN [dbo].[Faculties] f ON asub.FacultyId = f.FacultyId
WHERE asub.Year = @Year
  AND asub.Department = @Department
  AND asub.SelectedCount < 30
  $enrolledSubjectFilter
ORDER BY s.Name, f.Name
"@
    $cmd.Parameters.Clear()
    $cmd.Parameters.AddWithValue("@Year", $studentYearNumber) | Out-Null
    $cmd.Parameters.AddWithValue("@Department", $selectedStudent.Department) | Out-Null
    
    $reader = $cmd.ExecuteReader()
    $availableCount = 0
    while ($reader.Read()) {
        $availableCount++
        $subjectName = $reader["SubjectName"]
        $facultyName = $reader["FacultyName"]
        $selectedCount = $reader["SelectedCount"]
        $availableSlots = 30 - $selectedCount
        
        Write-Host "$availableCount. $subjectName" -ForegroundColor Cyan
        Write-Host "   Faculty: $facultyName" -ForegroundColor White
        Write-Host "   Enrolled: $selectedCount/30 (Available: $availableSlots)" -ForegroundColor Green
        Write-Host ""
    }
    $reader.Close()
    
    if ($availableCount -eq 0) {
        Write-Host "NO AVAILABLE SUBJECTS FOUND!" -ForegroundColor Red
        Write-Host ""
        Write-Host "Possible reasons:" -ForegroundColor Yellow
        Write-Host "  1. No subjects assigned for Year=$studentYearNumber, Dept=$($selectedStudent.Department)" -ForegroundColor White
        Write-Host "  2. All subjects are full (30/30 students)" -ForegroundColor White
        Write-Host "  3. Student already enrolled in all available subjects" -ForegroundColor White
        Write-Host ""
        Write-Host "Debugging Info:" -ForegroundColor Cyan
        
        # Count all assigned subjects for this year/dept
        $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[AssignedSubjects] WHERE Year = @Year AND Department = @Department"
        $cmd.Parameters.Clear()
        $cmd.Parameters.AddWithValue("@Year", $studentYearNumber) | Out-Null
        $cmd.Parameters.AddWithValue("@Department", $selectedStudent.Department) | Out-Null
        $totalAssigned = $cmd.ExecuteScalar()
        Write-Host "  Total AssignedSubjects for this year/dept: $totalAssigned" -ForegroundColor White
        
        # Count full subjects
        $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[AssignedSubjects] WHERE Year = @Year AND Department = @Department AND SelectedCount >= 30"
        $fullSubjects = $cmd.ExecuteScalar()
        Write-Host "  Full subjects (>= 30): $fullSubjects" -ForegroundColor White
        
        # Show all assigned subjects
        Write-Host ""
        Write-Host "All Assigned Subjects (regardless of availability):" -ForegroundColor Magenta
        $cmd.CommandText = @"
SELECT 
    s.Name AS SubjectName,
    f.Name AS FacultyName,
    asub.SelectedCount,
    asub.Year,
    asub.Department
FROM [dbo].[AssignedSubjects] asub
INNER JOIN [dbo].[Subjects] s ON asub.SubjectId = s.SubjectId
INNER JOIN [dbo].[Faculties] f ON asub.FacultyId = f.FacultyId
WHERE asub.Year = @Year AND asub.Department = @Department
ORDER BY s.Name
"@
        $reader2 = $cmd.ExecuteReader()
        $count = 0
        while ($reader2.Read()) {
            $count++
            Write-Host "  $count. $($reader2['SubjectName']) - $($reader2['FacultyName']) ($($reader2['SelectedCount'])/30)" -ForegroundColor White
        }
        $reader2.Close()
    }
    else {
        Write-Host "Found $availableCount available subject(s) for enrollment!" -ForegroundColor Green
    }
    
    # Close connection
    $connection.Close()
    
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "ERROR: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Stack Trace: $($_.Exception.StackTrace)" -ForegroundColor Red
    Write-Host ""
    if ($connection -and $connection.State -eq 'Open') {
        $connection.Close()
    }
    exit 1
}
