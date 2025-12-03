-- QUICK CHECK: What's in the database RIGHT NOW for ML subject

PRINT '1. ML SUBJECT IN SUBJECTS TABLE'
PRINT '================================'
SELECT 
    SubjectId,
    Name,
    Department,
    Year,
    Semester,
    SubjectType,
    MaxEnrollments
FROM Subjects
WHERE Name = 'ML';

PRINT ''
PRINT '2. ML ASSIGNMENTS IN ASSIGNEDSUBJECTS TABLE'
PRINT '============================================'
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    a.Year,
    a.SelectedCount,
    s.Name AS SubjectName,
    s.Department AS SubjectDept,
    f.Name AS FacultyName,
    f.Department AS FacultyDept
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Name = 'ML';

PRINT ''
PRINT '3. YEAR 3 CSE(DS) STUDENTS'
PRINT '=========================='
SELECT TOP 5
    Id,
    FullName,
    Department,
    Year
FROM Students
WHERE Year LIKE '%III%'
  AND (Department = 'CSE(DS)' OR Department = 'CSEDS')
ORDER BY Id;

PRINT ''
PRINT '4. ALL YEAR 3 ASSIGNED SUBJECTS (For comparison)'
PRINT '================================================'
SELECT 
    s.Name AS SubjectName,
    s.Department AS SubjectDept,
    s.SubjectType,
    a.Department AS AssignedDept,
    f.Name AS Faculty
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3
ORDER BY s.SubjectType, s.Name;

PRINT ''
PRINT '5. DEPARTMENT VALUES COMPARISON'
PRINT '================================'
SELECT DISTINCT Department, 'Students' AS TableName FROM Students WHERE Department LIKE '%CSE%'
UNION
SELECT DISTINCT Department, 'Subjects' AS TableName FROM Subjects WHERE Department LIKE '%CSE%'
UNION
SELECT DISTINCT Department, 'Faculties' AS TableName FROM Faculties WHERE Department LIKE '%CSE%'
UNION
SELECT DISTINCT Department, 'AssignedSubjects' AS TableName FROM AssignedSubjects WHERE Department LIKE '%CSE%'
ORDER BY TableName, Department;
