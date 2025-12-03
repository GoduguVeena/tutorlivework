-- ============================================
-- FIX CSE(DS) DEPARTMENT STANDARDIZATION
-- ============================================
-- This script standardizes all CSE(DS) department variations to "CSEDS"
-- Run this AFTER you've run the diagnostic script

PRINT '========================================';
PRINT 'CSE(DS) DEPARTMENT STANDARDIZATION FIX';
PRINT '========================================';
PRINT '';

-- Begin Transaction for safety
BEGIN TRANSACTION;

PRINT 'Starting standardization...';
PRINT '';

-- ============================================
-- 1. STANDARDIZE STUDENTS TABLE
-- ============================================
PRINT '1. Updating Students table...';

UPDATE Students
SET Department = 'CSEDS'
WHERE Department IN ('CSE(DS)', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSDS', 'CSE DATA SCIENCE', 'CSEDATASCIENCE');

DECLARE @studentsUpdated INT = @@ROWCOUNT;
PRINT '   Students updated: ' + CAST(@studentsUpdated AS VARCHAR(10));

-- ============================================
-- 2. STANDARDIZE SUBJECTS TABLE
-- ============================================
PRINT '';
PRINT '2. Updating Subjects table...';

UPDATE Subjects
SET Department = 'CSEDS'
WHERE Department IN ('CSE(DS)', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSDS', 'CSE DATA SCIENCE', 'CSEDATASCIENCE');

DECLARE @subjectsUpdated INT = @@ROWCOUNT;
PRINT '   Subjects updated: ' + CAST(@subjectsUpdated AS VARCHAR(10));

-- ============================================
-- 3. STANDARDIZE FACULTIES TABLE
-- ============================================
PRINT '';
PRINT '3. Updating Faculties table...';

UPDATE Faculties
SET Department = 'CSEDS'
WHERE Department IN ('CSE(DS)', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSDS', 'CSE DATA SCIENCE', 'CSEDATASCIENCE');

DECLARE @facultiesUpdated INT = @@ROWCOUNT;
PRINT '   Faculties updated: ' + CAST(@facultiesUpdated AS VARCHAR(10));

-- ============================================
-- 4. VERIFY THE CHANGES
-- ============================================
PRINT '';
PRINT '========================================';
PRINT 'VERIFICATION';
PRINT '========================================';

-- Check Students
DECLARE @csedsstudents INT = (SELECT COUNT(*) FROM Students WHERE Department = 'CSEDS');
PRINT 'Students with CSEDS department: ' + CAST(@csedsstudents AS VARCHAR(10));

-- Check Subjects
DECLARE @csedssubjects INT = (SELECT COUNT(*) FROM Subjects WHERE Department = 'CSEDS');
PRINT 'Subjects with CSEDS department: ' + CAST(@csedssubjects AS VARCHAR(10));

-- Check Faculties
DECLARE @csedsfaculty INT = (SELECT COUNT(*) FROM Faculties WHERE Department = 'CSEDS');
PRINT 'Faculty with CSEDS department: ' + CAST(@csedsfaculty AS VARCHAR(10));

-- Check for any remaining variations
PRINT '';
PRINT 'Checking for remaining variations...';

DECLARE @variations TABLE (Source VARCHAR(50), Department VARCHAR(50), Count INT);

INSERT INTO @variations
SELECT 'Students' AS Source, Department, COUNT(*) AS Count
FROM Students
WHERE Department LIKE '%CSE%DS%' OR Department LIKE '%CSE(DS)%'
GROUP BY Department

UNION ALL

SELECT 'Subjects' AS Source, Department, COUNT(*) AS Count
FROM Subjects
WHERE Department LIKE '%CSE%DS%' OR Department LIKE '%CSE(DS)%'
GROUP BY Department

UNION ALL

SELECT 'Faculties' AS Source, Department, COUNT(*) AS Count
FROM Faculties
WHERE Department LIKE '%CSE%DS%' OR Department LIKE '%CSE(DS)%'
GROUP BY Department;

IF EXISTS (SELECT 1 FROM @variations WHERE Department != 'CSEDS')
BEGIN
    PRINT '';
    PRINT 'WARNING: Found remaining variations:';
    SELECT * FROM @variations WHERE Department != 'CSEDS' ORDER BY Source, Department;
END
ELSE
BEGIN
    PRINT 'SUCCESS: All CSE(DS) variations have been standardized to CSEDS';
END

-- ============================================
-- 5. COMMIT OR ROLLBACK
-- ============================================
PRINT '';
PRINT '========================================';
PRINT 'TRANSACTION STATUS';
PRINT '========================================';

-- Review the changes before committing
PRINT '';
PRINT 'Review the changes above.';
PRINT 'If everything looks correct, the transaction will be committed.';
PRINT 'If you want to rollback, press Ctrl+C now and run: ROLLBACK TRANSACTION;';
PRINT '';
PRINT 'Committing transaction in 5 seconds...';

WAITFOR DELAY '00:00:05';

COMMIT TRANSACTION;

PRINT '';
PRINT '========================================';
PRINT 'SUCCESS!';
PRINT '========================================';
PRINT 'All CSE(DS) departments have been standardized to CSEDS';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Restart your application (IIS/Kestrel)';
PRINT '2. Clear browser cache';
PRINT '3. Login as a CSE(DS) student';
PRINT '4. Navigate to Select Subject page';
PRINT '5. You should now see the available subjects!';
PRINT '';
PRINT '========================================';

-- Show sample of updated records
PRINT '';
PRINT 'Sample of Year III CSE(DS) Students:';
SELECT TOP 5 
    Id, 
    FullName, 
    Department, 
    Year, 
    Email 
FROM Students 
WHERE Department = 'CSEDS' AND Year = 'III Year';

PRINT '';
PRINT 'Sample of CSE(DS) Subjects:';
SELECT TOP 5 
    SubjectId, 
    Name, 
    Department, 
    Year, 
    SubjectType 
FROM Subjects 
WHERE Department = 'CSEDS'
ORDER BY Year, Name;

PRINT '';
PRINT 'Sample of Assigned Subjects for Year III CSE(DS):';
SELECT TOP 5
    s.Name AS [Subject],
    s.Department,
    s.SubjectType,
    f.Name AS [Faculty],
    a.SelectedCount AS [Enrollments]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3 AND s.Department = 'CSEDS'
ORDER BY s.SubjectType, s.Name;
