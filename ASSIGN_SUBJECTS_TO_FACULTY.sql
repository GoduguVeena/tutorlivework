-- ========================================
-- ASSIGN FSD AND JAVA TO FACULTY
-- ========================================

PRINT '========================================';
PRINT 'ASSIGNING SUBJECTS TO FACULTY';
PRINT '========================================';
PRINT '';

-- Check current assignments
PRINT '1. BEFORE:';
SELECT 
    s.SubjectId,
    s.Name,
    s.SubjectType,
    CASE 
        WHEN a.AssignedSubjectId IS NULL THEN 'NOT ASSIGNED'
        ELSE 'Assigned to: ' + f.Name
    END AS Status
FROM Subjects s
LEFT JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
LEFT JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department = 'CSE(DS)'
ORDER BY s.SubjectType, s.Name;

PRINT '';
PRINT '2. ASSIGNING SUBJECTS...';
PRINT '------------------------';

-- Assign FSD to penchala prasad (FacultyId = 1)
IF NOT EXISTS (SELECT 1 FROM AssignedSubjects WHERE SubjectId = 4)
BEGIN
    INSERT INTO AssignedSubjects (SubjectId, FacultyId, Year)
    VALUES (4, 1, 3);
    PRINT '? FSD assigned to penchala prasad';
END
ELSE
    PRINT '? FSD already assigned';

-- Assign java to penchala prasad (FacultyId = 1)
IF NOT EXISTS (SELECT 1 FROM AssignedSubjects WHERE SubjectId = 5)
BEGIN
    INSERT INTO AssignedSubjects (SubjectId, FacultyId, Year)
    VALUES (5, 1, 3);
    PRINT '? java assigned to penchala prasad';
END
ELSE
    PRINT '? java already assigned';

PRINT '';
PRINT '3. AFTER:';
SELECT 
    s.SubjectId,
    s.Name,
    s.SubjectType,
    f.Name AS FacultyName,
    a.Year
FROM Subjects s
INNER JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department = 'CSE(DS)'
ORDER BY s.SubjectType, s.Name;

PRINT '';
PRINT '========================================';
PRINT 'ALL SUBJECTS NOW ASSIGNED!';
PRINT '========================================';
PRINT '';
PRINT 'STUDENTS WILL NOW SEE:';
PRINT '- Core Subjects: ML, FSD, java';
PRINT '- All assigned to: penchala prasad';
PRINT '';
PRINT 'NEXT STEP:';
PRINT '1. Restart your application';
PRINT '2. Login as shahid afrid';
PRINT '3. Go to Select Subject';
PRINT '4. You will see 3 Core subjects now!';
PRINT '';
PRINT '========================================';
