-- FIX: Standardize all department names to CSE(DS)
-- This ensures CSEDS and CSE(DS) match correctly

BEGIN TRANSACTION;

PRINT '===================================='
PRINT 'STANDARDIZING DEPARTMENT NAMES'
PRINT '===================================='
PRINT ''

-- 1. Update Students table
PRINT '1. Updating Students table...'
UPDATE Students 
SET Department = 'CSE(DS)' 
WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE DATA SCIENCE');

PRINT '   ? Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' student records'
PRINT ''

-- 2. Update Subjects table
PRINT '2. Updating Subjects table...'
UPDATE Subjects 
SET Department = 'CSE(DS)' 
WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE DATA SCIENCE');

PRINT '   ? Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' subject records'
PRINT ''

-- 3. Update Faculties table
PRINT '3. Updating Faculties table...'
UPDATE Faculties 
SET Department = 'CSE(DS)' 
WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE DATA SCIENCE');

PRINT '   ? Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' faculty records'
PRINT ''

-- 4. Update AssignedSubjects table
PRINT '4. Updating AssignedSubjects table...'
UPDATE AssignedSubjects 
SET Department = 'CSE(DS)' 
WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE DATA SCIENCE');

PRINT '   ? Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' assigned subject records'
PRINT ''

-- 5. Update FacultySelectionSchedules table
PRINT '5. Updating FacultySelectionSchedules table...'
UPDATE FacultySelectionSchedules 
SET Department = 'CSE(DS)' 
WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE DATA SCIENCE');

PRINT '   ? Updated ' + CAST(@@ROWCOUNT AS VARCHAR(10)) + ' schedule records'
PRINT ''

-- 6. Verification
PRINT '===================================='
PRINT 'VERIFICATION'
PRINT '===================================='
PRINT ''

PRINT '6. Department values after update:'
SELECT 'Students' AS TableName, Department, COUNT(*) AS Count
FROM Students
WHERE Department LIKE '%CSE%'
GROUP BY Department

UNION ALL

SELECT 'Subjects' AS TableName, Department, COUNT(*) AS Count
FROM Subjects
WHERE Department LIKE '%CSE%'
GROUP BY Department

UNION ALL

SELECT 'Faculties' AS TableName, Department, COUNT(*) AS Count
FROM Faculties
WHERE Department LIKE '%CSE%'
GROUP BY Department

UNION ALL

SELECT 'AssignedSubjects' AS TableName, Department, COUNT(*) AS Count
FROM AssignedSubjects
WHERE Department LIKE '%CSE%'
GROUP BY Department

UNION ALL

SELECT 'FacultySelectionSchedules' AS TableName, Department, COUNT(*) AS Count
FROM FacultySelectionSchedules
WHERE Department LIKE '%CSE%'
GROUP BY Department;

PRINT ''
PRINT 'All department names should now be CSE(DS)'
PRINT ''
PRINT 'Commit this transaction? (Y/N)'
PRINT ''
PRINT '-- To commit: COMMIT TRANSACTION;'
PRINT '-- To rollback: ROLLBACK TRANSACTION;'

-- Uncomment to auto-commit
-- COMMIT TRANSACTION;
