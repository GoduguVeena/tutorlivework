-- Comprehensive diagnostic query to find ML subject mismatch
-- Run this to see EXACTLY what's in the database

PRINT '===================================='
PRINT '1. CHECK STUDENT DEPARTMENT'
PRINT '===================================='
SELECT 
    Id,
    FullName,
    Department AS StudentDepartment,
    Year
FROM Students
WHERE Id = '23091A32D4'  -- Replace with your student RegdNumber
ORDER BY Id;

PRINT ''
PRINT '===================================='
PRINT '2. CHECK ML SUBJECT DETAILS'
PRINT '===================================='
SELECT 
    SubjectId,
    Name,
    Department AS SubjectDepartment,
    Year,
    Semester,
    SubjectType,
    MaxEnrollments
FROM Subjects
WHERE Name = 'ML';

PRINT ''
PRINT '===================================='
PRINT '3. CHECK ML FACULTY ASSIGNMENTS'
PRINT '===================================='
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedSubjectDepartment,
    a.Year AS AssignedYear,
    a.SelectedCount,
    s.SubjectId,
    s.Name AS SubjectName,
    s.Department AS SubjectDepartment,
    s.Year AS SubjectYear,
    s.SubjectType,
    f.FacultyId,
    f.Name AS FacultyName,
    f.Department AS FacultyDepartment
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Name = 'ML';

PRINT ''
PRINT '===================================='
PRINT '4. CHECK ALL YEAR 3 CSE(DS) SUBJECTS'
PRINT '===================================='
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    a.Year,
    s.Name,
    s.Department AS SubjectDept,
    s.SubjectType,
    f.Name AS Faculty
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3
  AND (
    s.Department = 'CSE(DS)' OR 
    s.Department = 'CSEDS' OR
    a.Department = 'CSE(DS)' OR
    a.Department = 'CSEDS'
  )
ORDER BY s.SubjectType, s.Name;

PRINT ''
PRINT '===================================='
PRINT '5. DEPARTMENT COMPARISON'
PRINT '===================================='
SELECT 
    'Student Dept' AS Source,
    Department AS DepartmentValue,
    UPPER(Department) AS UpperCase,
    LEN(Department) AS Length,
    ASCII(SUBSTRING(Department, 1, 1)) AS FirstCharASCII
FROM Students
WHERE Id = '23091A32D4'  -- Replace with your student RegdNumber

UNION ALL

SELECT 
    'Subject Dept' AS Source,
    Department AS DepartmentValue,
    UPPER(Department) AS UpperCase,
    LEN(Department) AS Length,
    ASCII(SUBSTRING(Department, 1, 1)) AS FirstCharASCII
FROM Subjects
WHERE Name = 'ML'

UNION ALL

SELECT 
    'AssignedSubject Dept' AS Source,
    a.Department AS DepartmentValue,
    UPPER(a.Department) AS UpperCase,
    LEN(a.Department) AS Length,
    ASCII(SUBSTRING(a.Department, 1, 1)) AS FirstCharASCII
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE s.Name = 'ML';

PRINT ''
PRINT '===================================='
PRINT '6. EXPECTED MATCH TEST'
PRINT '===================================='
DECLARE @StudentDept NVARCHAR(100)
DECLARE @SubjectDept NVARCHAR(100)
DECLARE @AssignedDept NVARCHAR(100)

SELECT @StudentDept = Department FROM Students WHERE Id = '23091A32D4';  -- Replace
SELECT @SubjectDept = Department FROM Subjects WHERE Name = 'ML';
SELECT @AssignedDept = a.Department 
FROM AssignedSubjects a 
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId 
WHERE s.Name = 'ML';

SELECT 
    @StudentDept AS Student_Dept,
    @SubjectDept AS Subject_Dept,
    @AssignedDept AS AssignedSubject_Dept,
    CASE 
        WHEN @StudentDept = @SubjectDept THEN 'MATCH ?'
        ELSE 'MISMATCH ?'
    END AS Student_vs_Subject,
    CASE 
        WHEN @StudentDept = @AssignedDept THEN 'MATCH ?'
        ELSE 'MISMATCH ?'
    END AS Student_vs_AssignedSubject;
