-- ========================================
-- COMPREHENSIVE FIX: Core Subjects Not Showing
-- ========================================
-- Issues:
-- 1. ML has wrong SubjectType (ProfessionalElective1 should be Core)
-- 2. FSD and java are not assigned to any faculty
-- 3. Department names inconsistent (CSE(DS) vs CSEDS)
-- ========================================

PRINT '========================================';
PRINT 'FIXING CORE SUBJECTS VISIBILITY';
PRINT '========================================';
PRINT '';

-- STEP 1: Show current problems
PRINT '1. CURRENT PROBLEMS:';
PRINT '-------------------';
SELECT 
    s.SubjectId,
    s.Name,
    s.Department,
    s.Year,
    s.SubjectType,
    CASE 
        WHEN a.AssignedSubjectId IS NULL THEN 'NOT ASSIGNED'
        ELSE 'ASSIGNED TO: ' + f.Name
    END AS AssignmentStatus
FROM Subjects s
LEFT JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
LEFT JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department IN ('CSE(DS)', 'CSEDS')
ORDER BY s.SubjectId;

PRINT '';
PRINT '2. FIXING ISSUES...';
PRINT '-------------------';

-- FIX 1: Change ML from ProfessionalElective1 to Core
PRINT 'Fixing ML SubjectType...';
UPDATE Subjects
SET SubjectType = 'Core'
WHERE SubjectId = 1 AND Name = 'ML';

-- FIX 2: Standardize all departments to CSE(DS)
PRINT 'Standardizing department names to CSE(DS)...';
UPDATE Subjects
SET Department = 'CSE(DS)'
WHERE Department = 'CSEDS';

-- FIX 3: Update AssignedSubjects department if needed
UPDATE a
SET a.Department = s.Department
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE s.Department = 'CSE(DS)';

PRINT '';
PRINT '3. CHECKING FACULTY ASSIGNMENT...';
PRINT '-----------------------------------';

-- Check if FSD and java need faculty assignment
DECLARE @fsdAssigned INT = (SELECT COUNT(*) FROM AssignedSubjects WHERE SubjectId = 4);
DECLARE @javaAssigned INT = (SELECT COUNT(*) FROM AssignedSubjects WHERE SubjectId = 5);

IF @fsdAssigned = 0
BEGIN
    PRINT '? FSD is NOT assigned to any faculty!';
    PRINT '  ? You need to assign FSD to a faculty member in Admin panel';
END
ELSE
BEGIN
    PRINT '? FSD is assigned to faculty';
END

IF @javaAssigned = 0
BEGIN
    PRINT '? java is NOT assigned to any faculty!';
    PRINT '  ? You need to assign java to a faculty member in Admin panel';
END
ELSE
BEGIN
    PRINT '? java is assigned to faculty';
END

PRINT '';
PRINT '4. VERIFICATION:';
PRINT '----------------';
SELECT 
    s.SubjectId,
    s.Name,
    s.Department,
    s.Year,
    s.SubjectType,
    CASE 
        WHEN a.AssignedSubjectId IS NULL THEN 'NOT ASSIGNED ?'
        ELSE 'ASSIGNED TO: ' + f.Name + ' ?'
    END AS AssignmentStatus
FROM Subjects s
LEFT JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
LEFT JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department = 'CSE(DS)'
ORDER BY s.SubjectId;

PRINT '';
PRINT '========================================';
PRINT 'PARTIAL FIX COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'WHAT WAS FIXED:';
PRINT '? ML SubjectType changed to Core';
PRINT '? All departments standardized to CSE(DS)';
PRINT '';
PRINT 'WHAT YOU NEED TO DO:';
PRINT '1. Assign FSD to a faculty member';
PRINT '2. Assign java to a faculty member';
PRINT '';
PRINT 'HOW TO ASSIGN:';
PRINT '- Go to Admin ? Manage CSEDS Subjects';
PRINT '- Click on FSD ? Assign Faculty';
PRINT '- Click on java ? Assign Faculty';
PRINT '';
PRINT 'OR use this SQL:';
PRINT 'INSERT INTO AssignedSubjects (SubjectId, FacultyId, Year)';
PRINT 'VALUES (4, [FacultyId], 3), (5, [FacultyId], 3)';
PRINT '';
PRINT '========================================';
