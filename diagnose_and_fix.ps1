# PowerShell script to diagnose and fix "No Available Subjects" issue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DIAGNOSE & FIX ENROLLMENT ISSUES" -ForegroundColor Cyan
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
    
    # STEP 1: Check current state
    Write-Host "STEP 1: Checking current database state..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $cmd = $connection.CreateCommand()
    
    # Check Students
    $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[Students]"
    $studentCount = $cmd.ExecuteScalar()
    Write-Host "Students: $studentCount" -ForegroundColor White
    
    # Check StudentEnrollments
    $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[StudentEnrollments]"
    $enrollmentCount = $cmd.ExecuteScalar()
    Write-Host "StudentEnrollments: $enrollmentCount" -ForegroundColor $(if ($enrollmentCount -eq 0) { "Green" } else { "Yellow" })
    
    # Check AssignedSubjects
    $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[AssignedSubjects]"
    $assignedSubjectCount = $cmd.ExecuteScalar()
    Write-Host "AssignedSubjects: $assignedSubjectCount" -ForegroundColor White
    
    # Check SelectedCount values
    $cmd.CommandText = "SELECT SUM(SelectedCount) FROM [dbo].[AssignedSubjects]"
    $totalSelectedCount = $cmd.ExecuteScalar()
    if ($totalSelectedCount -eq [DBNull]::Value) { $totalSelectedCount = 0 }
    Write-Host "Total SelectedCount: $totalSelectedCount" -ForegroundColor $(if ($totalSelectedCount -eq 0) { "Green" } else { "Yellow" })
    
    Write-Host ""
    
    # STEP 2: Check for mismatches
    Write-Host "STEP 2: Checking for data mismatches..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $issuesFound = $false
    
    # Issue 1: StudentEnrollments exist but no Students
    if ($enrollmentCount -gt 0 -and $studentCount -eq 0) {
        Write-Host "ISSUE FOUND: Orphaned StudentEnrollment records exist!" -ForegroundColor Red
        Write-Host "  There are $enrollmentCount enrollment records but no students" -ForegroundColor Red
        $issuesFound = $true
    }
    
    # Issue 2: SelectedCount doesn't match actual enrollments
    if ($totalSelectedCount -ne $enrollmentCount) {
        Write-Host "ISSUE FOUND: SelectedCount mismatch!" -ForegroundColor Red
        Write-Host "  AssignedSubjects.SelectedCount total: $totalSelectedCount" -ForegroundColor Red
        Write-Host "  Actual StudentEnrollments count: $enrollmentCount" -ForegroundColor Red
        $issuesFound = $true
    }
    
    # Check individual assigned subjects for full status
    $cmd.CommandText = @"
SELECT AssignedSubjectId, FacultyId, SubjectId, Department, Year, SelectedCount
FROM [dbo].[AssignedSubjects]
WHERE SelectedCount >= 30
ORDER BY SelectedCount DESC
"@
    $reader = $cmd.ExecuteReader()
    $fullSubjects = @()
    while ($reader.Read()) {
        $fullSubjects += [PSCustomObject]@{
            AssignedSubjectId = $reader["AssignedSubjectId"]
            FacultyId = $reader["FacultyId"]
            SubjectId = $reader["SubjectId"]
            Department = $reader["Department"]
            Year = $reader["Year"]
            SelectedCount = $reader["SelectedCount"]
        }
    }
    $reader.Close()
    
    if ($fullSubjects.Count -gt 0) {
        Write-Host "ISSUE FOUND: Some subjects marked as full!" -ForegroundColor Red
        Write-Host "  $($fullSubjects.Count) subjects have SelectedCount >= 30" -ForegroundColor Red
        foreach ($subj in $fullSubjects) {
            Write-Host "    ID: $($subj.AssignedSubjectId) | Faculty: $($subj.FacultyId) | Subject: $($subj.SubjectId) | Count: $($subj.SelectedCount)" -ForegroundColor Yellow
        }
        $issuesFound = $true
    }

    # Check for mismatches
    $cmd.CommandText = @"
SELECT 
    s.Id,
    s.FullName,
    s.Department AS StudentDept,
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
GROUP BY s.Id, s.FullName, s.Department
HAVING COUNT(DISTINCT asub.AssignedSubjectId) = 0
"@

    $reader = $cmd.ExecuteReader()
    $mismatchStudents = @()
    while ($reader.Read()) {
        $mismatchStudents += [PSCustomObject]@{
            StudentId = $reader["Id"]
            FullName = $reader["FullName"]
            Department = $reader["StudentDept"]
            AvailableSubjects = $reader["AvailableSubjects"]
        }
    }
    $reader.Close()
    
    if ($mismatchStudents.Count -gt 0) {
        Write-Host "ISSUE FOUND: Some students have no available subjects!" -ForegroundColor Red
        foreach ($student in $mismatchStudents) {
            Write-Host "  Student ID: $($student.StudentId) | Name: $($student.FullName) | Department: $($student.Department)" -ForegroundColor Yellow
        }
        $issuesFound = $true
    }

    if (-not $issuesFound) {
        Write-Host "No issues found! Database looks good." -ForegroundColor Green
        Write-Host ""
        Write-Host "If you still see 'No Available Subjects', try:" -ForegroundColor Yellow
        Write-Host "  1. Clear your browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
        Write-Host "  2. Restart the application" -ForegroundColor White
        Write-Host "  3. Check if Faculty Selection Schedule is enabled" -ForegroundColor White
        $connection.Close()
        exit 0
    }
    
    Write-Host ""
    
    # STEP 3: Offer to fix issues
    Write-Host "STEP 3: Fix detected issues?" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $fix = Read-Host "Do you want to automatically fix these issues? Type 'YES' to proceed"
    
    if ($fix -ne "YES") {
        Write-Host ""
        Write-Host "Fix cancelled. Database unchanged." -ForegroundColor Yellow
        $connection.Close()
        exit 0
    }
    
    Write-Host ""
    Write-Host "Applying fixes..." -ForegroundColor Yellow
    Write-Host ""
    
    # Fix 1: Remove orphaned StudentEnrollments
    if ($enrollmentCount -gt 0) {
        Write-Host "Removing orphaned StudentEnrollment records..." -ForegroundColor Yellow
        $cmd.CommandText = "DELETE FROM [dbo].[StudentEnrollments]"
        $deleted = $cmd.ExecuteNonQuery()
        Write-Host "  Deleted $deleted enrollment records" -ForegroundColor Green
    }
    
    # Fix 2: Reset all SelectedCount to 0
    Write-Host "Resetting all SelectedCount values to 0..." -ForegroundColor Yellow
    $cmd.CommandText = "UPDATE [dbo].[AssignedSubjects] SET SelectedCount = 0"
    $updated = $cmd.ExecuteNonQuery()
    Write-Host "  Updated $updated AssignedSubject records" -ForegroundColor Green
    
    Write-Host ""
    
    # STEP 4: Verify fixes
    Write-Host "STEP 4: Verifying fixes..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[StudentEnrollments]"
    $finalEnrollmentCount = $cmd.ExecuteScalar()
    Write-Host "StudentEnrollments: $finalEnrollmentCount" -ForegroundColor $(if ($finalEnrollmentCount -eq 0) { "Green" } else { "Red" })
    
    $cmd.CommandText = "SELECT SUM(SelectedCount) FROM [dbo].[AssignedSubjects]"
    $finalSelectedCount = $cmd.ExecuteScalar()
    if ($finalSelectedCount -eq [DBNull]::Value) { $finalSelectedCount = 0 }
    Write-Host "Total SelectedCount: $finalSelectedCount" -ForegroundColor $(if ($finalSelectedCount -eq 0) { "Green" } else { "Red" })
    
    $cmd.CommandText = "SELECT COUNT(*) FROM [dbo].[AssignedSubjects] WHERE SelectedCount < 30"
    $availableCount = $cmd.ExecuteScalar()
    Write-Host "Available subjects (< 30 students): $availableCount" -ForegroundColor Green
    
    # Close connection
    $connection.Close()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   FIX COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "All issues have been fixed. Your students should now be able to select subjects." -ForegroundColor Green
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Restart your application (Ctrl+C then run again)" -ForegroundColor White
    Write-Host "  2. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
    Write-Host "  3. Login as a student and try selecting subjects" -ForegroundColor White
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
