-- ============================================
-- COMPREHENSIVE CSE(DS) SUBJECT MAPPING DIAGNOSTIC
-- ============================================
-- Run this in SQL Server Management Studio or Azure Data Studio
-- to diagnose why CSE(DS) students can't see assigned subjects

PRINT '========================================';
PRINT '1. CHECK STUDENT DEPARTMENT VALUES';
PRINT '========================================';
SELECT 
    Id,
    FullName,
    RegdNumber,
    Department AS [Student Department],
    Year,
    Email
FROM Students 
WHERE Department LIKE '%CSE%DS%' 
   OR Department LIKE '%CSEDS%'
   OR Department = 'CSE(DS)'
ORDER BY Year, FullName;

PRINT '';
PRINT '========================================';
PRINT '2. CHECK SUBJECT DEPARTMENT VALUES';
PRINT '========================================';
SELECT 
    SubjectId,
    Name AS [Subject Name],
    Department AS [Subject Department],
    Year,
    SubjectType,
    MaxEnrollments
FROM Subjects
WHERE Department LIKE '%CSE%DS%' 
   OR Department LIKE '%CSEDS%'
   OR Department = 'CSE(DS)'
ORDER BY Year, SubjectType, Name;

PRINT '';
PRINT '========================================';
PRINT '3. CHECK ASSIGNED SUBJECTS (Faculty Assignments)';
PRINT '========================================';
SELECT 
    a.AssignedSubjectId,
    s.Name AS [Subject Name],
    s.Department AS [Subject Department],
    s.SubjectType,
    a.Year AS [Assigned Year],
    f.Name AS [Faculty Name],
    f.Department AS [Faculty Department],
    a.SelectedCount AS [Current Enrollments],
    s.MaxEnrollments
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Department LIKE '%CSE%DS%' 
   OR s.Department LIKE '%CSEDS%'
   OR s.Department = 'CSE(DS)'
ORDER BY a.Year, s.SubjectType, s.Name;

PRINT '';
PRINT '========================================';
PRINT '4. CHECK YEAR III CSE(DS) STUDENTS SPECIFICALLY';
PRINT '========================================';
SELECT 
    Id,
    FullName,
    Department,
    Year,
    Email,
    (SELECT COUNT(*) FROM StudentEnrollments WHERE StudentId = Students.Id) AS [Enrolled Subjects Count]
FROM Students
WHERE Year = 'III Year'
  AND (Department LIKE '%CSE%DS%' OR Department LIKE '%CSEDS%' OR Department = 'CSE(DS)');

PRINT '';
PRINT '========================================';
PRINT '5. CHECK YEAR III ASSIGNED SUBJECTS';
PRINT '========================================';
SELECT 
    s.Name AS [Subject Name],
    s.Department AS [Subject Department],
    s.SubjectType,
    f.Name AS [Faculty],
    a.SelectedCount AS [Enrollments]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3
ORDER BY s.SubjectType, s.Name;

PRINT '';
PRINT '========================================';
PRINT '6. DEPARTMENT MISMATCH ANALYSIS';
PRINT '========================================';
PRINT 'Checking for department value mismatches...';

-- Students using different variations
SELECT 
    'STUDENT DEPARTMENTS' AS [Source],
    Department AS [Department Value],
    COUNT(*) AS [Count]
FROM Students
WHERE Department LIKE '%CSE%DS%' OR Department LIKE '%CSEDS%' OR Department = 'CSE(DS)'
GROUP BY Department

UNION ALL

-- Subjects using different variations
SELECT 
    'SUBJECT DEPARTMENTS' AS [Source],
    Department AS [Department Value],
    COUNT(*) AS [Count]
FROM Subjects
WHERE Department LIKE '%CSE%DS%' OR Department LIKE '%CSEDS%' OR Department = 'CSE(DS)'
GROUP BY Department

UNION ALL

-- Faculty using different variations
SELECT 
    'FACULTY DEPARTMENTS' AS [Source],
    Department AS [Department Value],
    COUNT(*) AS [Count]
FROM Faculties
WHERE Department LIKE '%CSE%DS%' OR Department LIKE '%CSEDS%' OR Department = 'CSE(DS)'
GROUP BY Department
ORDER BY [Source], [Department Value];

PRINT '';
PRINT '========================================';
PRINT '7. STUDENT ENROLLMENTS CHECK';
PRINT '========================================';
SELECT 
    st.FullName AS [Student],
    st.Department AS [Student Dept],
    st.Year,
    s.Name AS [Enrolled Subject],
    s.Department AS [Subject Dept],
    s.SubjectType,
    f.Name AS [Faculty]
FROM StudentEnrollments se
INNER JOIN Students st ON se.StudentId = st.Id
INNER JOIN AssignedSubjects a ON se.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE st.Department LIKE '%CSE%DS%' OR st.Department LIKE '%CSEDS%' OR st.Department = 'CSE(DS)'
ORDER BY st.FullName, s.Name;

PRINT '';
PRINT '========================================';
PRINT 'DIAGNOSTIC COMPLETE';
PRINT '========================================';
PRINT '';
PRINT 'NEXT STEPS:';
PRINT '1. Check if Student Department values match Subject Department values';
PRINT '2. If mismatched (e.g., Students have "CSEDS" but Subjects have "CSE(DS)"), run the FIX script';
PRINT '3. Look for the file: fix-cseds-department-standardization.sql';
