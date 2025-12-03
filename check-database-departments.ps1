# Quick Database Check - What do we have right now?

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "Database Department Check" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

$serverName = "localhost"
$databaseName = "Working5Db"

Write-Host "Checking database: $databaseName on $serverName" -ForegroundColor Yellow
Write-Host ""

$query = @"
-- Check all tables for department values
PRINT 'Students Table:';
SELECT DISTINCT Department, COUNT(*) AS Count 
FROM Students 
GROUP BY Department;

PRINT '';
PRINT 'Faculty Table:';
SELECT DISTINCT Department, COUNT(*) AS Count 
FROM Faculty 
GROUP BY Department;

PRINT '';
PRINT 'Subjects Table:';
SELECT DISTINCT Department, COUNT(*) AS Count 
FROM Subjects 
GROUP BY Department;

PRINT '';
PRINT 'AssignedSubjects Table:';
SELECT DISTINCT Department, COUNT(*) AS Count 
FROM AssignedSubjects 
GROUP BY Department;

PRINT '';
PRINT 'FacultySelectionSchedules Table:';
SELECT DISTINCT Department, COUNT(*) AS Count 
FROM FacultySelectionSchedules 
GROUP BY Department;

PRINT '';
PRINT '======================================';
PRINT 'Summary:';
SELECT 
    CASE 
        WHEN Department = 'CSE(DS)' THEN '? CORRECT: CSE(DS)'
        WHEN Department = 'CSEDS' THEN '? NEEDS UPDATE: CSEDS'
        ELSE '? UNKNOWN: ' + Department
    END AS Status,
    COUNT(*) AS TotalRecords
FROM (
    SELECT Department FROM Students
    UNION ALL
    SELECT Department FROM Faculty
    UNION ALL
    SELECT Department FROM Subjects
    UNION ALL
    SELECT Department FROM AssignedSubjects
    UNION ALL
    SELECT Department FROM FacultySelectionSchedules
) AS AllDepartments
WHERE Department LIKE '%CSE%DS%'
GROUP BY Department;
"@

try {
    Write-Host "Running diagnostic query..." -ForegroundColor Yellow
    Write-Host ""
    
    $result = sqlcmd -S $serverName -d $databaseName -E -Q $query -W
    
    Write-Host $result
    Write-Host ""
    
    if ($result -like "*CSEDS*") {
        Write-Host "? FOUND 'CSEDS' in database!" -ForegroundColor Red
        Write-Host "   You NEED to run the migration." -ForegroundColor Red
        Write-Host ""
        Write-Host "   Run: .\run-migration.ps1" -ForegroundColor Yellow
    }
    elseif ($result -like "*CSE(DS)*") {
        Write-Host "? Database is correct! All departments are 'CSE(DS)'" -ForegroundColor Green
        Write-Host "   If you still see issues, restart your application." -ForegroundColor Yellow
    }
    else {
        Write-Host "??  Could not determine database state." -ForegroundColor Yellow
        Write-Host "   Check the output above." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "ERROR: Could not connect to database" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Check in SQL Server Management Studio" -ForegroundColor Yellow
    Write-Host "Query:" -ForegroundColor Cyan
    Write-Host $query -ForegroundColor White
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
