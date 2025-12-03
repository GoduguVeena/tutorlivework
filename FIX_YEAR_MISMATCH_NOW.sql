-- ========================================
-- FIX: CSE(DS) Students Cannot See Subjects
-- ========================================
-- Problem: AssignedSubjects has Year=2, but students are in Year=3 (III Year)
-- Solution: Update AssignedSubjects.Year to match student year

PRINT '========================================';
PRINT 'FIXING YEAR MISMATCH';
PRINT '========================================';
PRINT '';

-- 1. Show the current problem
PRINT '1. CURRENT PROBLEM:';
PRINT '-------------------';
SELECT 
    'Student Year' AS Source,
    Year AS Value
FROM Students 
WHERE Id = '23091A32D4'
UNION ALL
SELECT 
    'AssignedSubjects Year',
    CAST(a.Year AS VARCHAR)
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE s.Department = 'CSE(DS)';

PRINT '';
PRINT '2. SUBJECTS AFFECTED:';
PRINT '---------------------';
SELECT 
    a.AssignedSubjectId,
    s.Name AS SubjectName,
    s.Department,
    a.Year AS CurrentYear,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department = 'CSE(DS)';

PRINT '';
PRINT '3. APPLYING FIX...';
PRINT '------------------';

-- Update AssignedSubjects Year from 2 to 3
UPDATE a
SET a.Year = 3
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE s.Department = 'CSE(DS)' AND a.Year = 2;

PRINT 'Updated AssignedSubjects.Year to 3';
PRINT '';

-- 4. Verify the fix
PRINT '4. VERIFICATION:';
PRINT '----------------';
SELECT 
    a.AssignedSubjectId,
    s.Name AS SubjectName,
    s.Department,
    a.Year AS UpdatedYear,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department = 'CSE(DS)';

PRINT '';
PRINT '========================================';
PRINT 'FIX COMPLETE!';
PRINT '========================================';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Restart your application (Shift+F5, then F5)';
PRINT '2. Login as: shahid afrid';
PRINT '3. Click: Select Subject';
PRINT '4. You should now see ML and other subjects!';
PRINT '';
PRINT '========================================';
