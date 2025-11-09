# PowerShell script to fix department mismatch issue

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   FIX DEPARTMENT MISMATCH" -ForegroundColor Cyan
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
    
    Write-Host "Checking for department mismatches..." -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    # Check Students departments
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = "SELECT DISTINCT Department FROM [dbo].[Students]"
    $reader = $cmd.ExecuteReader()
    Write-Host "Student Departments:" -ForegroundColor Yellow
    while ($reader.Read()) {
        Write-Host "  - $($reader['Department'])" -ForegroundColor White
    }
    $reader.Close()
    Write-Host ""
    
    # Check AssignedSubjects departments
    $cmd.CommandText = "SELECT DISTINCT Department FROM [dbo].[AssignedSubjects]"
    $reader = $cmd.ExecuteReader()
    Write-Host "AssignedSubjects Departments:" -ForegroundColor Yellow
    while ($reader.Read()) {
        Write-Host "  - $($reader['Department'])" -ForegroundColor White
    }
    $reader.Close()
    Write-Host ""
    
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
    $affectedStudents = @()
    while ($reader.Read()) {
        $affectedStudents += [PSCustomObject]@{
            Id = $reader["Id"]
            FullName = $reader["FullName"]
            Department = $reader["StudentDept"]
        }
    }
    $reader.Close()
    
    if ($affectedStudents.Count -eq 0) {
        Write-Host "No mismatch issues found!" -ForegroundColor Green
        $connection.Close()
        exit 0
    }
    
    Write-Host "Students with NO available subjects (department mismatch):" -ForegroundColor Red
    foreach ($student in $affectedStudents) {
        Write-Host "  - $($student.FullName) (Department: $($student.Department))" -ForegroundColor Yellow
    }
    Write-Host ""
    
    Write-Host "Fix Options:" -ForegroundColor Cyan
    Write-Host "1. Update Students to use 'CSEDS'" -ForegroundColor White
    Write-Host "2. Update AssignedSubjects to use 'CSE(DS)'" -ForegroundColor White
    Write-Host "3. Make both use 'CSEDS' (recommended)" -ForegroundColor Green
    Write-Host "4. Cancel" -ForegroundColor Yellow
    Write-Host ""
    
    $choice = Read-Host "Enter your choice (1-4)"
    
    switch ($choice) {
        "1" {
            Write-Host ""
            Write-Host "Updating Students department to 'CSEDS'..." -ForegroundColor Yellow
            $cmd.CommandText = "UPDATE [dbo].[Students] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated student record(s)" -ForegroundColor Green
        }
        "2" {
            Write-Host ""
            Write-Host "Updating AssignedSubjects department to 'CSE(DS)'..." -ForegroundColor Yellow
            $cmd.CommandText = "UPDATE [dbo].[AssignedSubjects] SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated AssignedSubject record(s)" -ForegroundColor Green
            
            $cmd.CommandText = "UPDATE [dbo].[Subjects] SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated Subject record(s)" -ForegroundColor Green
            
            $cmd.CommandText = "UPDATE [dbo].[Faculties] SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated Faculty record(s)" -ForegroundColor Green
        }
        "3" {
            Write-Host ""
            Write-Host "Standardizing all departments to 'CSEDS'..." -ForegroundColor Yellow
            
            $cmd.CommandText = "UPDATE [dbo].[Students] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated student record(s)" -ForegroundColor Green
            
            $cmd.CommandText = "UPDATE [dbo].[AssignedSubjects] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated AssignedSubject record(s)" -ForegroundColor Green
            
            $cmd.CommandText = "UPDATE [dbo].[Subjects] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated Subject record(s)" -ForegroundColor Green
            
            $cmd.CommandText = "UPDATE [dbo].[Faculties] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated Faculty record(s)" -ForegroundColor Green
            
            $cmd.CommandText = "UPDATE [dbo].[FacultySelectionSchedules] SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'"
            $updated = $cmd.ExecuteNonQuery()
            Write-Host "Updated $updated FacultySelectionSchedule record(s)" -ForegroundColor Green
        }
        "4" {
            Write-Host ""
            Write-Host "Operation cancelled." -ForegroundColor Yellow
            $connection.Close()
            exit 0
        }
        default {
            Write-Host ""
            Write-Host "Invalid choice. Operation cancelled." -ForegroundColor Red
            $connection.Close()
            exit 1
        }
    }
    
    Write-Host ""
    Write-Host "Verifying fix..." -ForegroundColor Cyan
    
    # Check again
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
"@
    
    $reader = $cmd.ExecuteReader()
    Write-Host ""
    Write-Host "Students and their available subjects:" -ForegroundColor Green
    while ($reader.Read()) {
        Write-Host "  - $($reader['FullName']): $($reader['AvailableSubjects']) subjects available" -ForegroundColor White
    }
    $reader.Close()
    
    # Close connection
    $connection.Close()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   FIX COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Students should now see available subjects!" -ForegroundColor Green
    Write-Host "Refresh the browser page to see the changes." -ForegroundColor Yellow
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
