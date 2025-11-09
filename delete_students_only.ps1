# Delete Student Records Only - Keep Faculty & Admin
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   DELETE STUDENT RECORDS ONLY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "This will delete:" -ForegroundColor Yellow
Write-Host "  - All Student records" -ForegroundColor Yellow
Write-Host "  - All StudentEnrollment records" -ForegroundColor Yellow
Write-Host ""
Write-Host "This will KEEP:" -ForegroundColor Green
Write-Host "  - All Faculty records" -ForegroundColor Green
Write-Host "  - All Admin records" -ForegroundColor Green
Write-Host "  - All Subject records" -ForegroundColor Green
Write-Host "  - All AssignedSubject records" -ForegroundColor Green
Write-Host "  - All FacultySelectionSchedule records" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "Are you sure you want to delete all student records? (Y/N)"
if ($confirm -ne "Y" -and $confirm -ne "y") {
    Write-Host ""
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit
}

Write-Host ""
Write-Host "[STEP 1] Stopping any running application..." -ForegroundColor Cyan
Stop-Process -Name "dotnet" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

Write-Host "[STEP 2] Connecting to database..." -ForegroundColor Cyan

# Connection string
$serverName = "localhost"
$databaseName = "Working2Db"
$connectionString = "Server=$serverName;Database=$databaseName;Integrated Security=True;TrustServerCertificate=True"

try {
    # Load SQL Server assembly
    Add-Type -AssemblyName "System.Data"
    
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    $connection.Open()
    
    Write-Host "[STEP 3] Deleting StudentEnrollment records..." -ForegroundColor Cyan
    $command = $connection.CreateCommand()
    $command.CommandText = "DELETE FROM StudentEnrollments"
    $enrollmentCount = $command.ExecuteNonQuery()
    Write-Host "  ? Deleted $enrollmentCount enrollment records" -ForegroundColor Green
    
    Write-Host "[STEP 4] Deleting Student records..." -ForegroundColor Cyan
    $command = $connection.CreateCommand()
    $command.CommandText = "DELETE FROM Students"
    $studentCount = $command.ExecuteNonQuery()
    Write-Host "  ? Deleted $studentCount student records" -ForegroundColor Green
    
    $connection.Close()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   SUCCESS!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Summary:" -ForegroundColor White
    Write-Host "  - Deleted $studentCount students" -ForegroundColor White
    Write-Host "  - Deleted $enrollmentCount enrollments" -ForegroundColor White
    Write-Host "  - Faculty and Admin records intact ?" -ForegroundColor Green
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Red
    Write-Host "   ERROR!" -ForegroundColor Red
    Write-Host "========================================" -ForegroundColor Red
    Write-Host ""
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Make sure SQL Server is running and the database exists." -ForegroundColor Yellow
    Write-Host ""
}

Write-Host ""
Read-Host "Press Enter to exit"
