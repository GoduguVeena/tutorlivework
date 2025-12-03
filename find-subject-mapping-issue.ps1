# FIND THE EXACT PROBLEM - Why subjects not showing
# This script will show the exact mismatch

Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host "SUBJECT MAPPING DIAGNOSTIC - Finding Department Mismatch" -ForegroundColor Cyan
Write-Host "====================================================================" -ForegroundColor Cyan
Write-Host ""

# Get connection string from appsettings.json
$appsettings = Get-Content "appsettings.json" | ConvertFrom-Json
$connectionString = $appsettings.ConnectionStrings.DefaultConnection

Write-Host "Connecting to database..." -ForegroundColor Yellow
Write-Host ""

# Create SQL query to check department values
$query = @"
-- Show actual department values in each table
SELECT 'Students' AS TableName, Department, COUNT(*) AS Count
FROM Students
WHERE Year LIKE '%III%'
GROUP BY Department
UNION ALL
SELECT 'Subjects' AS TableName, Department, COUNT(*) AS Count
FROM Subjects
WHERE Year = 3
GROUP BY Department
UNION ALL
SELECT 'AssignedSubjects' AS TableName, Department, COUNT(*) AS Count
FROM AssignedSubjects
WHERE Year = 3
GROUP BY Department
ORDER BY TableName, Department;

PRINT '';
PRINT 'SPECIFIC VALUES:';
PRINT '================';

-- Get one student
DECLARE @StudentDept NVARCHAR(100) = (SELECT TOP 1 Department FROM Students WHERE Year LIKE '%III%' AND Department LIKE '%CSE%');
PRINT 'Student Department: [' + ISNULL(@StudentDept, 'NULL') + ']';
PRINT 'Student Dept Length: ' + CAST(LEN(@StudentDept) AS NVARCHAR);
PRINT 'Student Dept HEX: 0x' + CAST(CAST(@StudentDept AS VARBINARY(100)) AS NVARCHAR(MAX));

-- Get one subject
DECLARE @SubjectDept NVARCHAR(100) = (SELECT TOP 1 Department FROM Subjects WHERE Year = 3 AND Name = 'ML');
PRINT 'ML Subject Department: [' + ISNULL(@SubjectDept, 'NULL') + ']';
PRINT 'Subject Dept Length: ' + CAST(LEN(@SubjectDept) AS NVARCHAR);
PRINT 'Subject Dept HEX: 0x' + CAST(CAST(@SubjectDept AS VARBINARY(100)) AS NVARCHAR(MAX));

-- Check if they match
IF @StudentDept = @SubjectDept
    PRINT 'EXACT MATCH: YES';
ELSE
    PRINT 'EXACT MATCH: NO - THIS IS THE PROBLEM!';

PRINT '';
PRINT 'After normalization would they match?';
PRINT '-------------------------------------';

-- Show what normalization would do
PRINT 'CSE(DS) -> CSE(DS)';
PRINT 'CSEDS -> CSE(DS)';
PRINT 'CSE-DS -> CSE(DS)';
PRINT '';
PRINT 'Current values need to match AFTER normalization in C# code.';
"@

try {
    # Execute query using sqlcmd
    Write-Host "Executing diagnostic query..." -ForegroundColor Yellow
    $result = & sqlcmd -S "(localdb)\MSSQLLocalDB" -d "TutorLiveMentor" -Q $query -W

    Write-Host ""
    Write-Host "DIAGNOSTIC RESULTS:" -ForegroundColor Green
    Write-Host "===================" -ForegroundColor Green
    Write-Host $result
    Write-Host ""

    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "ANALYSIS:" -ForegroundColor Cyan
    Write-Host "====================================================================" -ForegroundColor Cyan
    Write-Host "1. Check if department values in different tables have different formats" -ForegroundColor White
    Write-Host "   (e.g., 'CSE(DS)' vs 'CSEDS' vs 'CSE-DS')" -ForegroundColor White
    Write-Host ""
    Write-Host "2. The DepartmentNormalizer.Normalize() is supposed to fix this" -ForegroundColor White
    Write-Host "   But it only works if it's called correctly in the code" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Line 742 in StudentController.cs DOES call Normalize():" -ForegroundColor White
    Write-Host "   .Where(a => DepartmentNormalizer.Normalize(a.Subject.Department) == normalizedStudentDept)" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "4. So the issue must be one of:" -ForegroundColor White
    Write-Host "   a) Department values have special characters/spaces" -ForegroundColor Gray
    Write-Host "   b) Normalize() doesn't handle the specific variant" -ForegroundColor Gray
    Write-Host "   c) The query returns 0 subjects before filtering" -ForegroundColor Gray
    Write-Host ""

    Write-Host "Next step: Check console logs when student accesses SelectSubject page" -ForegroundColor Magenta
    Write-Host "Look for these lines:" -ForegroundColor Magenta
    Write-Host "  'SelectSubject GET - Found X total subjects for Year=3'" -ForegroundColor Gray
    Write-Host "  'SelectSubject GET - After department filter: X subjects'" -ForegroundColor Gray
    Write-Host ""
}
catch {
    Write-Host "ERROR: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Alternative: Run diagnose-subject-mapping-issue.sql directly in SQL Server Management Studio" -ForegroundColor Yellow
}

Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
