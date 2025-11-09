# PowerShell script to reset all SelectedCount values to zero in AssignedSubjects table

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   RESET SELECTED COUNTS TO ZERO" -ForegroundColor Cyan
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
    
    # Load Microsoft.Data.SqlClient assembly
    Add-Type -AssemblyName "System.Data"
    
    # Create connection
    $connection = New-Object System.Data.SqlClient.SqlConnection
    $connection.ConnectionString = $connectionString
    
    Write-Host "Connecting to database..." -ForegroundColor Yellow
    $connection.Open()
    Write-Host "Connected successfully!" -ForegroundColor Green
    Write-Host ""
    
    # First, show current counts
    Write-Host "Current SelectedCount values:" -ForegroundColor Yellow
    $selectCmd = $connection.CreateCommand()
    $selectCmd.CommandText = "SELECT AssignedSubjectId, FacultyId, SubjectId, Department, Year, SelectedCount FROM [dbo].[AssignedSubjects] ORDER BY AssignedSubjectId"
    
    $reader = $selectCmd.ExecuteReader()
    $hasData = $false
    while ($reader.Read()) {
        $hasData = $true
        Write-Host ("ID: {0,-3} | Faculty: {1,-3} | Subject: {2,-3} | Dept: {3,-6} | Year: {4} | Count: {5}" -f `
            $reader["AssignedSubjectId"], `
            $reader["FacultyId"], `
            $reader["SubjectId"], `
            $reader["Department"], `
            $reader["Year"], `
            $reader["SelectedCount"]) -ForegroundColor White
    }
    $reader.Close()
    
    if (-not $hasData) {
        Write-Host "No records found in AssignedSubjects table." -ForegroundColor Yellow
        $connection.Close()
        exit 0
    }
    
    Write-Host ""
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    # Update all SelectedCount to 0
    Write-Host "Resetting all SelectedCount values to 0..." -ForegroundColor Yellow
    $updateCmd = $connection.CreateCommand()
    $updateCmd.CommandText = "UPDATE [dbo].[AssignedSubjects] SET SelectedCount = 0"
    
    $rowsAffected = $updateCmd.ExecuteNonQuery()
    
    Write-Host "Successfully updated $rowsAffected records!" -ForegroundColor Green
    Write-Host ""
    
    # Show updated counts
    Write-Host "Updated SelectedCount values (all should be 0):" -ForegroundColor Yellow
    $verifyCmd = $connection.CreateCommand()
    $verifyCmd.CommandText = "SELECT AssignedSubjectId, FacultyId, SubjectId, Department, Year, SelectedCount FROM [dbo].[AssignedSubjects] ORDER BY AssignedSubjectId"
    
    $reader2 = $verifyCmd.ExecuteReader()
    while ($reader2.Read()) {
        Write-Host ("ID: {0,-3} | Faculty: {1,-3} | Subject: {2,-3} | Dept: {3,-6} | Year: {4} | Count: {5}" -f `
            $reader2["AssignedSubjectId"], `
            $reader2["FacultyId"], `
            $reader2["SubjectId"], `
            $reader2["Department"], `
            $reader2["Year"], `
            $reader2["SelectedCount"]) -ForegroundColor Green
    }
    $reader2.Close()
    
    # Close connection
    $connection.Close()
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "   RESET COMPLETE!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
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
