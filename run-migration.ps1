# Run the CSEDS to CSE(DS) Migration Script
# This script connects to your local database and updates all department names

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "CSEDS to CSE(DS) Migration Script" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Database connection details
$serverName = "localhost"
$databaseName = "Working5Db"

Write-Host "Target Database: $databaseName on $serverName" -ForegroundColor Yellow
Write-Host ""

# Ask for confirmation
Write-Host "WARNING: This will update all department names from CSEDS to CSE(DS)" -ForegroundColor Red
Write-Host "Make sure you have a backup of your database before proceeding!" -ForegroundColor Red
Write-Host ""
$confirmation = Read-Host "Do you want to proceed? (yes/no)"

if ($confirmation -ne "yes") {
    Write-Host "Migration cancelled." -ForegroundColor Yellow
    exit
}

Write-Host ""
Write-Host "Starting migration..." -ForegroundColor Green

# Path to the SQL migration script
$scriptPath = ".\Migrations\UpdateCSEDSToCseDsStandard.sql"

# Check if SQL script exists
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: Migration script not found at: $scriptPath" -ForegroundColor Red
    exit
}

try {
    # Execute the SQL script using sqlcmd
    Write-Host "Executing SQL migration script..." -ForegroundColor Yellow
    
    $result = sqlcmd -S $serverName -d $databaseName -E -i $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "======================================" -ForegroundColor Green
        Write-Host "Migration completed successfully!" -ForegroundColor Green
        Write-Host "======================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Results:" -ForegroundColor Cyan
        Write-Host $result
        Write-Host ""
        Write-Host "Next Steps:" -ForegroundColor Yellow
        Write-Host "1. Restart your application" -ForegroundColor White
        Write-Host "2. Test student login and dashboard" -ForegroundColor White
        Write-Host "3. Verify department shows as 'CSE(DS)' not 'CSEDS'" -ForegroundColor White
    }
    else {
        Write-Host "ERROR: Migration failed with exit code: $LASTEXITCODE" -ForegroundColor Red
        Write-Host $result
    }
}
catch {
    Write-Host "ERROR: Failed to execute migration script" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Possible solutions:" -ForegroundColor Yellow
    Write-Host "1. Make sure SQL Server is running" -ForegroundColor White
    Write-Host "2. Make sure sqlcmd is installed (comes with SQL Server)" -ForegroundColor White
    Write-Host "3. Check your connection permissions" -ForegroundColor White
    Write-Host ""
    Write-Host "Alternative: Run the migration manually in SQL Server Management Studio" -ForegroundColor Cyan
    Write-Host "File location: $scriptPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
