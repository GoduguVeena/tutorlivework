-- =============================================================================
-- FIX CSE(DS) DEPARTMENT STANDARDIZATION - COMPLETE SOLUTION
-- =============================================================================
-- This script standardizes ALL CSE(DS) references to CSEDS format
-- Run in SSMS or SQL tool connected to Working5Db
-- =============================================================================

PRINT '=============================================================================';
PRINT 'STARTING CSE(DS) TO CSEDS STANDARDIZATION';
PRINT '=============================================================================';
PRINT '';

-- STEP 1: Update Students table
PRINT 'STEP 1: Updating Students table...';
UPDATE Students 
SET Department = 'CSEDS' 
WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS');

DECLARE @studentsUpdated INT = @@ROWCOUNT;
PRINT '  - Updated ' + CAST(@studentsUpdated AS VARCHAR(10)) + ' student records';
PRINT '';

-- STEP 2: Update Subjects table
PRINT 'STEP 2: Updating Subjects table...';
UPDATE Subjects 
SET Department = 'CSEDS' 
WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS)', 'CSDS');

DECLARE @subjectsUpdated INT = @@ROWCOUNT;
PRINT '  - Updated ' + CAST(@subjectsUpdated AS VARCHAR(10)) + ' subject records';
PRINT '';

-- STEP 3: Update FacultySelectionSchedules table
PRINT 'STEP 3: Updating FacultySelectionSchedules table...';
UPDATE FacultySelectionSchedules 
SET Department = 'CSEDS' 
WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS');

DECLARE @schedulesUpdated INT = @@ROWCOUNT;
PRINT '  - Updated ' + CAST(@schedulesUpdated AS VARCHAR(10)) + ' schedule records';
PRINT '';

-- STEP 4: Update Faculties table (if any CSE(DS) faculty exist)
PRINT 'STEP 4: Updating Faculties table...';
UPDATE Faculties 
SET Department = 'CSEDS' 
WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS');

DECLARE @facultiesUpdated INT = @@ROWCOUNT;
PRINT '  - Updated ' + CAST(@facultiesUpdated AS VARCHAR(10)) + ' faculty records';
PRINT '';

-- VERIFICATION
PRINT '=============================================================================';
PRINT 'VERIFICATION:';
PRINT '=============================================================================';

-- Check Students
DECLARE @studentCSEDS_After INT = (SELECT COUNT(*) FROM Students WHERE Department = 'CSEDS');
DECLARE @studentOldFormat_After INT = (SELECT COUNT(*) FROM Students WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS'));
PRINT 'Students:';
PRINT '  - CSEDS format: ' + CAST(@studentCSEDS_After AS VARCHAR(10));
PRINT '  - Old formats remaining: ' + CAST(@studentOldFormat_After AS VARCHAR(10));

-- Check Subjects  
DECLARE @subjectCSEDS_After INT = (SELECT COUNT(*) FROM Subjects WHERE Department = 'CSEDS');
DECLARE @subjectOldFormat_After INT = (SELECT COUNT(*) FROM Subjects WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS'));
PRINT 'Subjects:';
PRINT '  - CSEDS format: ' + CAST(@subjectCSEDS_After AS VARCHAR(10));
PRINT '  - Old formats remaining: ' + CAST(@subjectOldFormat_After AS VARCHAR(10));

-- Check Schedules
DECLARE @scheduleCSEDS_After INT = (SELECT COUNT(*) FROM FacultySelectionSchedules WHERE Department = 'CSEDS');
DECLARE @scheduleOldFormat_After INT = (SELECT COUNT(*) FROM FacultySelectionSchedules WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS'));
PRINT 'Schedules:';
PRINT '  - CSEDS format: ' + CAST(@scheduleCSEDS_After AS VARCHAR(10));
PRINT '  - Old formats remaining: ' + CAST(@scheduleOldFormat_After AS VARCHAR(10));

-- Check Faculties
DECLARE @facultyCSEDS_After INT = (SELECT COUNT(*) FROM Faculties WHERE Department = 'CSEDS');
DECLARE @facultyOldFormat_After INT = (SELECT COUNT(*) FROM Faculties WHERE Department IN ('CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS'));
PRINT 'Faculties:';
PRINT '  - CSEDS format: ' + CAST(@facultyCSEDS_After AS VARCHAR(10));
PRINT '  - Old formats remaining: ' + CAST(@facultyOldFormat_After AS VARCHAR(10));

PRINT '';

-- Final status
IF (@studentOldFormat_After = 0 AND @subjectOldFormat_After = 0 AND @scheduleOldFormat_After = 0 AND @facultyOldFormat_After = 0)
BEGIN
    PRINT '=============================================================================';
    PRINT 'SUCCESS! ALL DEPARTMENTS STANDARDIZED TO CSEDS';
    PRINT '=============================================================================';
    PRINT 'Next step: Fix StudentController.cs line 682';
    PRINT '  Change: .FirstOrDefaultAsync(s => s.Department == "CSE(DS)")';
    PRINT '  To: Use DepartmentNormalizer.Normalize() for comparison';
END
ELSE
BEGIN
    PRINT '=============================================================================';
    PRINT 'WARNING: Some old format records still remain!';
    PRINT '=============================================================================';
    PRINT 'Review the verification results above and re-run if needed.';
END

PRINT '';
PRINT '=============================================================================';
PRINT 'DATABASE UPDATE COMPLETE';
PRINT '=============================================================================';
