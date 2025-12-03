-- IMMEDIATE DIAGNOSIS: What does student 23091A32D4 see?
-- Run this in SQL Server to see EXACTLY what's in the database

PRINT '===================================================================';
PRINT 'IMMEDIATE DIAGNOSIS FOR STUDENT 23091A32D4';
PRINT '===================================================================';
PRINT '';

-- 1. Student Info
PRINT '1. STUDENT INFORMATION';
PRINT '======================';
SELECT 
    Id,
    FullName,
    Department AS StudentDepartment,
    Year
FROM Students
WHERE Id = '23091A32D4';

PRINT '';
PRINT '2. WHAT SUBJECTS EXIST FOR YEAR 3?';
PRINT '===================================';
SELECT 
    s.SubjectId,
    s.Name,
    s.Department AS SubjectDepartment,
    s.Year,
    s.SubjectType,
    s.MaxEnrollments,
    COUNT(a.AssignedSubjectId) AS TimesAssigned
FROM Subjects s
LEFT JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
WHERE s.Year = 3
GROUP BY s.SubjectId, s.Name, s.Department, s.Year, s.SubjectType, s.MaxEnrollments
ORDER BY s.SubjectType, s.Name;

PRINT '';
PRINT '3. ASSIGNED SUBJECTS FOR YEAR 3 (What SelectSubject query returns)';
PRINT '====================================================================';
SELECT 
    a.AssignedSubjectId,
    s.Name AS SubjectName,
    s.Department AS SubjectDepartment,
    s.SubjectType,
    f.Name AS FacultyName,
    a.SelectedCount,
    s.MaxEnrollments
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3
ORDER BY s.SubjectType, s.Name, f.Name;

PRINT '';
PRINT '4. DEPARTMENT COMPARISON';
PRINT '========================';
DECLARE @StudentDept NVARCHAR(100) = (SELECT Department FROM Students WHERE Id = '23091A32D4');
PRINT 'Student Department: [' + ISNULL(@StudentDept, 'NULL') + ']';

SELECT DISTINCT 
    'Subject' AS Source,
    s.Department,
    CASE 
        WHEN s.Department = @StudentDept THEN 'EXACT MATCH'
        WHEN s.Department LIKE '%CSE%' AND @StudentDept LIKE '%CSE%' THEN 'PARTIAL MATCH'
        ELSE 'NO MATCH'
    END AS MatchStatus
FROM Subjects s
WHERE s.Year = 3;

PRINT '';
PRINT '5. DIAGNOSIS';
PRINT '============';
DECLARE @SubjectCount INT = (SELECT COUNT(*) FROM AssignedSubjects WHERE Year = 3);
DECLARE @SubjectDept NVARCHAR(100) = (SELECT TOP 1 Department FROM Subjects WHERE Year = 3);

IF @SubjectCount = 0
BEGIN
    PRINT 'PROBLEM: No AssignedSubjects for Year 3!';
    PRINT 'FIX: Admin needs to assign subjects to faculty.';
END
ELSE IF @StudentDept != @SubjectDept
BEGIN
    PRINT 'PROBLEM: Department mismatch!';
    PRINT 'Student has: [' + @StudentDept + ']';
    PRINT 'Subjects have: [' + @SubjectDept + ']';
    PRINT 'FIX: Either update student department or subject departments to match.';
END
ELSE
BEGIN
    PRINT 'Departments match! Problem is somewhere else.';
    PRINT 'Check: 1) Student already enrolled? 2) View not rendering?';
END

PRINT '';
PRINT '===================================================================';
