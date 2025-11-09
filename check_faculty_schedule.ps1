# PowerShell script to check Faculty Selection Schedule status

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   CHECK FACULTY SELECTION SCHEDULE" -ForegroundColor Cyan
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
    
    # Check Faculty Selection Schedules
    Write-Host "Faculty Selection Schedules:" -ForegroundColor Cyan
    Write-Host "----------------------------------------" -ForegroundColor Cyan
    Write-Host ""
    
    $cmd = $connection.CreateCommand()
    $cmd.CommandText = @"
SELECT ScheduleId, Department, StartDateTime, EndDateTime, IsEnabled, UseSchedule
FROM [dbo].[FacultySelectionSchedules]
ORDER BY Department
"@
    
    $reader = $cmd.ExecuteReader()
    $hasSchedules = $false
    $blockingSchedules = @()
    
    while ($reader.Read()) {
        $hasSchedules = $true
        $scheduleId = $reader["ScheduleId"]
        $department = $reader["Department"]
        $startDateTime = $reader["StartDateTime"]
        $endDateTime = $reader["EndDateTime"]
        $isEnabled = $reader["IsEnabled"]
        $useSchedule = $reader["UseSchedule"]
        
        $now = Get-Date
        $isCurrentlyActive = $false
        $status = "Inactive"
        
        if ($useSchedule -eq $true) {
            if ($isEnabled -eq $false) {
                $status = "BLOCKED (Disabled by Admin)"
                $blockingSchedules += $department
            }
            elseif ($now -lt $startDateTime) {
                $status = "Not Started Yet"
            }
            elseif ($now -gt $endDateTime) {
                $status = "Ended"
            }
            else {
                $status = "Active (Selection Allowed)"
                $isCurrentlyActive = $true
            }
        }
        else {
            $status = "Always Available"
            $isCurrentlyActive = $true
        }
        
        $color = "White"
        if ($status -like "*BLOCKED*") {
            $color = "Red"
        }
        elseif ($isCurrentlyActive) {
            $color = "Green"
        }
        elseif ($status -like "*Always Available*") {
            $color = "Green"
        }
        else {
            $color = "Yellow"
        }
        
        Write-Host "Department: $department" -ForegroundColor Cyan
        Write-Host "  Schedule ID: $scheduleId" -ForegroundColor White
        Write-Host "  Use Schedule: $useSchedule" -ForegroundColor White
        Write-Host "  Is Enabled: $isEnabled" -ForegroundColor White
        Write-Host "  Start: $startDateTime" -ForegroundColor White
        Write-Host "  End: $endDateTime" -ForegroundColor White
        Write-Host "  Status: $status" -ForegroundColor $color
        Write-Host ""
    }
    $reader.Close()
    
    if (-not $hasSchedules) {
        Write-Host "No schedules found - Faculty selection is ALWAYS AVAILABLE" -ForegroundColor Green
    }
    elseif ($blockingSchedules.Count -gt 0) {
        Write-Host "========================================" -ForegroundColor Red
        Write-Host "   WARNING: SELECTION IS BLOCKED!" -ForegroundColor Red
        Write-Host "========================================" -ForegroundColor Red
        Write-Host ""
        Write-Host "The following departments have faculty selection DISABLED:" -ForegroundColor Yellow
        foreach ($dept in $blockingSchedules) {
            Write-Host "  - $dept" -ForegroundColor Red
        }
        Write-Host ""
        Write-Host "To enable selection:" -ForegroundColor Yellow
        Write-Host "  1. Login as Admin" -ForegroundColor White
        Write-Host "  2. Go to 'Manage Faculty Selection Schedule'" -ForegroundColor White
        Write-Host "  3. Enable or set schedule to 'Always Available'" -ForegroundColor White
        Write-Host ""
        Write-Host "Or run: enable_faculty_selection.bat" -ForegroundColor Cyan
    }
    else {
        Write-Host "All schedules are allowing faculty selection." -ForegroundColor Green
    }
    
    # Close connection
    $connection.Close()
    
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
