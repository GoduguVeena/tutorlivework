-- =============================================================================
-- COMPREHENSIVE CSE(DS) / CSEDS DIAGNOSTIC
-- =============================================================================
-- This script identifies ALL department format mismatches preventing subject visibility
-- Run in SSMS or SQL tool connected to Working5Db
-- =============================================================================

PRINT '=============================================================================';
PRINT 'CSE(DS) / CSEDS COMPREHENSIVE DIAGNOSTIC';
PRINT '=============================================================================';
PRINT '';

-- 1. CHECK ALL STUDENTS WITH DS-RELATED DEPARTMENTS
PRINT '1. ALL CSE(DS) / CSEDS STUDENTS:';
PRINT '---------------------------------------------';
SELECT 
    Id,
    FullName,
    Department AS [Current_Department],
    Year,
    CASE 
        WHEN Department = 'CSEDS' THEN 'NORMALIZED'
        WHEN Department = 'CSE(DS)' THEN 'OLD FORMAT'
        ELSE 'OTHER'
    END AS [Format_Status]
FROM Students
WHERE Department IN ('CSEDS', 'CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS')
ORDER BY Department, Id;

DECLARE @studentCSEDS INT = (SELECT COUNT(*) FROM Students WHERE Department = 'CSEDS');
DECLARE @studentCSEDS_Old INT = (SELECT COUNT(*) FROM Students WHERE Department = 'CSE(DS)');
PRINT '';
PRINT 'Student Count Summary:';
PRINT '  - CSEDS (normalized): ' + CAST(@studentCSEDS AS VARCHAR(10));
PRINT '  - CSE(DS) (old): ' + CAST(@studentCSEDS_Old AS VARCHAR(10));
PRINT '';

-- 2. CHECK ALL SUBJECTS WITH DS-RELATED DEPARTMENTS
PRINT '2. ALL CSE(DS) / CSEDS SUBJECTS:';
PRINT '---------------------------------------------';
SELECT 
    s.SubjectId,
    s.Name AS [Subject_Name],
    s.Department AS [Current_Department],
    s.SubjectType,
    CASE 
        WHEN s.Department = 'CSEDS' THEN 'NORMALIZED'
        WHEN s.Department = 'CSE(DS)' THEN 'OLD FORMAT'
        ELSE 'OTHER'
    END AS [Format_Status]
FROM Subjects s
WHERE s.Department IN ('CSEDS', 'CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS')
ORDER BY s.Department, s.Name;

DECLARE @subjectCSEDS INT = (SELECT COUNT(*) FROM Subjects WHERE Department = 'CSEDS');
DECLARE @subjectCSEDS_Old INT = (SELECT COUNT(*) FROM Subjects WHERE Department = 'CSE(DS)');
PRINT '';
PRINT 'Subject Count Summary:';
PRINT '  - CSEDS (normalized): ' + CAST(@subjectCSEDS AS VARCHAR(10));
PRINT '  - CSE(DS) (old): ' + CAST(@subjectCSEDS_Old AS VARCHAR(10));
PRINT '';

-- 3. CHECK ASSIGNED SUBJECTS FOR YEAR III
PRINT '3. YEAR III ASSIGNED SUBJECTS (CSE(DS) / CSEDS):';
PRINT '---------------------------------------------';
SELECT 
    a.AssignedSubjectId,
    a.Year,
    s.Name AS [Subject_Name],
    s.Department AS [Subject_Department],
    s.SubjectType,
    f.Name AS [Faculty_Name],
    a.SelectedCount,
    CASE 
        WHEN s.Department = 'CSEDS' THEN 'NORMALIZED'
        WHEN s.Department = 'CSE(DS)' THEN 'OLD FORMAT'
        ELSE 'OTHER'
    END AS [Format_Status]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3 
  AND s.Department IN ('CSEDS', 'CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS')
ORDER BY s.SubjectType, s.Name;
PRINT '';

-- 4. CHECK FACULTY SELECTION SCHEDULES
PRINT '4. FACULTY SELECTION SCHEDULES (CSE(DS) / CSEDS):';
PRINT '---------------------------------------------';
SELECT 
    ScheduleId,
    Department AS [Current_Department],
    IsEnabled,
    UseSchedule,
    StartDateTime,
    EndDateTime,
    DisabledMessage,
    CASE 
        WHEN Department = 'CSEDS' THEN 'NORMALIZED'
        WHEN Department = 'CSE(DS)' THEN 'OLD FORMAT'
        ELSE 'OTHER'
    END AS [Format_Status],
    CASE 
        WHEN IsEnabled = 1 AND UseSchedule = 0 THEN 'ALWAYS AVAILABLE'
        WHEN IsEnabled = 0 THEN 'DISABLED'
        WHEN IsEnabled = 1 AND UseSchedule = 1 AND GETDATE() BETWEEN StartDateTime AND EndDateTime THEN 'AVAILABLE (IN SCHEDULE)'
        WHEN IsEnabled = 1 AND UseSchedule = 1 THEN 'NOT AVAILABLE (OUTSIDE SCHEDULE)'
        ELSE 'UNKNOWN'
    END AS [Access_Status]
FROM FacultySelectionSchedules
WHERE Department IN ('CSEDS', 'CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS')
ORDER BY Department;
PRINT '';

-- 5. CHECK STUDENT ENROLLMENTS
PRINT '5. STUDENT ENROLLMENTS (CSE(DS) / CSEDS Students):';
PRINT '---------------------------------------------';
SELECT 
    st.Id AS [Student_Id],
    st.FullName AS [Student_Name],
    st.Department AS [Student_Department],
    st.Year AS [Student_Year],
    s.Name AS [Enrolled_Subject],
    s.Department AS [Subject_Department],
    s.SubjectType,
    f.Name AS [Faculty_Name]
FROM Students st
INNER JOIN StudentEnrollments se ON st.Id = se.StudentId
INNER JOIN AssignedSubjects a ON se.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE st.Department IN ('CSEDS', 'CSE(DS)', 'CSE (DS)', 'CSE-DS', 'CSDS')
ORDER BY st.Id, s.SubjectType;
PRINT '';

-- 6. IDENTIFY THE EXACT PROBLEM
PRINT '=============================================================================';
PRINT '6. PROBLEM IDENTIFICATION:';
PRINT '=============================================================================';

-- Check if there's a mismatch
IF EXISTS (SELECT 1 FROM Students WHERE Department = 'CSE(DS)')
   AND EXISTS (SELECT 1 FROM Subjects WHERE Department = 'CSEDS')
BEGIN
    PRINT 'PROBLEM FOUND: Student departments use OLD FORMAT but Subjects use NORMALIZED!';
    PRINT '  - Students have: CSE(DS)';
    PRINT '  - Subjects have: CSEDS';
    PRINT '  - DepartmentNormalizer will normalize both to CSEDS';
    PRINT '  - BUT database query might fail before normalization!';
    PRINT '';
END

IF EXISTS (SELECT 1 FROM Students WHERE Department = 'CSEDS')
   AND EXISTS (SELECT 1 FROM Subjects WHERE Department = 'CSE(DS)')
BEGIN
    PRINT 'PROBLEM FOUND: Student departments use NORMALIZED but Subjects use OLD FORMAT!';
    PRINT '  - Students have: CSEDS';
    PRINT '  - Subjects have: CSE(DS)';
    PRINT '  - DepartmentNormalizer normalizes both to CSEDS';
    PRINT '  - Application logic SHOULD work but may have bugs in implementation';
    PRINT '';
END

IF EXISTS (SELECT 1 FROM FacultySelectionSchedules WHERE Department = 'CSEDS')
   AND NOT EXISTS (SELECT 1 FROM FacultySelectionSchedules WHERE Department = 'CSE(DS)')
BEGIN
    PRINT 'SCHEDULE ISSUE: FacultySelectionSchedules has CSEDS but controller queries CSE(DS)!';
    PRINT '  - Database has: CSEDS';
    PRINT '  - Controller line 682 queries: CSE(DS)';
    PRINT '  - Schedule will NOT be found, check will be skipped';
    PRINT '';
END

-- 7. SOLUTION RECOMMENDATION
PRINT '=============================================================================';
PRINT '7. RECOMMENDED SOLUTION:';
PRINT '=============================================================================';
PRINT 'Standardize ALL department references to CSEDS format:';
PRINT '  1. UPDATE Students SET Department = ''CSEDS'' WHERE Department = ''CSE(DS)''';
PRINT '  2. UPDATE Subjects SET Department = ''CSEDS'' WHERE Department = ''CSE(DS)''';
PRINT '  3. UPDATE FacultySelectionSchedules SET Department = ''CSEDS'' WHERE Department = ''CSE(DS)''';
PRINT '  4. Fix StudentController.cs line 682 to normalize department before query';
PRINT '';
PRINT 'After standardization, DepartmentNormalizer will handle ALL format variations!';
PRINT '=============================================================================';
