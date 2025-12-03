-- ============================================
-- QUICK CHECK: Why can't shahid afrid see subjects?
-- ============================================
-- Run this in SSMS to see the exact problem

PRINT '========================================';
PRINT 'QUICK DIAGNOSIS FOR SHAHID AFRID';
PRINT '========================================';
PRINT '';

-- 1. Check the student
PRINT '1. Student Details:';
SELECT 
    Id,
    FullName,
    RegdNumber,
    Department AS [Student_Department],
    Year
FROM Students
WHERE Id = '23091A32D4';

PRINT '';

-- 2. Check what subjects exist for Year III
PRINT '2. Year III Subjects:';
SELECT 
    s.SubjectId,
    s.Name AS [Subject_Name],
    s.Department AS [Subject_Department],
    s.SubjectType,
    f.Name AS [Faculty]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3;

PRINT '';

-- 3. Show the mismatch
PRINT '3. Department Mismatch Check:';
DECLARE @studentDept VARCHAR(50) = (SELECT Department FROM Students WHERE Id = '23091A32D4');
DECLARE @subjectDepts TABLE (Dept VARCHAR(50));

INSERT INTO @subjectDepts
SELECT DISTINCT s.Department
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE a.Year = 3;

PRINT 'Student Department: ' + ISNULL(@studentDept, 'NULL');
PRINT 'Subject Departments:';
SELECT Dept FROM @subjectDepts;

PRINT '';

-- 4. The problem
IF NOT EXISTS (
    SELECT 1 
    FROM @subjectDepts 
    WHERE Dept = @studentDept
)
BEGIN
    PRINT '========================================';
    PRINT 'PROBLEM FOUND!';
    PRINT '========================================';
    PRINT 'Student department: ' + @studentDept;
    PRINT 'Does NOT match any subject departments!';
    PRINT '';
    PRINT 'SOLUTION:';
    PRINT 'Run: fix-cseds-department-standardization.sql';
    PRINT '========================================';
END
ELSE
BEGIN
    PRINT '========================================';
    PRINT 'NO MISMATCH FOUND';
    PRINT '========================================';
    PRINT 'Departments match - problem might be elsewhere';
    PRINT 'Check if student is already enrolled in all subjects';
    PRINT '========================================';
END

-- 5. Check student enrollments
PRINT '';
PRINT '4. Student Current Enrollments:';
SELECT 
    s.Name AS [Enrolled_Subject],
    s.Department AS [Subject_Dept],
    f.Name AS [Faculty]
FROM StudentEnrollments se
INNER JOIN AssignedSubjects a ON se.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE se.StudentId = '23091A32D4';

DECLARE @enrolledCount INT = (
    SELECT COUNT(*) 
    FROM StudentEnrollments 
    WHERE StudentId = '23091A32D4'
);

PRINT '';
PRINT 'Total enrolled: ' + CAST(@enrolledCount AS VARCHAR(10));
