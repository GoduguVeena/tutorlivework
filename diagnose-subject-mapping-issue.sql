-- COMPREHENSIVE SUBJECT MAPPING DIAGNOSTIC
-- Find out WHY subjects are not showing for students

PRINT '====================================================================='
PRINT 'SUBJECT MAPPING DIAGNOSTIC - Finding the Root Cause'
PRINT '====================================================================='
PRINT ''

-- Step 1: Check what departments exist in each table
PRINT '1. DEPARTMENT VALUES IN EACH TABLE'
PRINT '===================================='
PRINT 'Students Table:'
SELECT DISTINCT Department, COUNT(*) AS StudentCount 
FROM Students 
GROUP BY Department
ORDER BY Department;

PRINT ''
PRINT 'Subjects Table:'
SELECT DISTINCT Department, COUNT(*) AS SubjectCount 
FROM Subjects 
GROUP BY Department
ORDER BY Department;

PRINT ''
PRINT 'AssignedSubjects Table:'
SELECT DISTINCT Department, COUNT(*) AS AssignmentCount 
FROM AssignedSubjects 
GROUP BY Department
ORDER BY Department;

PRINT ''
PRINT 'Faculties Table:'
SELECT DISTINCT Department, COUNT(*) AS FacultyCount 
FROM Faculties 
GROUP BY Department
ORDER BY Department;

PRINT ''
PRINT '====================================================================='
PRINT '2. SPECIFIC CHECK: CSE(DS) vs CSEDS MISMATCH'
PRINT '====================================================================='

DECLARE @StudentDept NVARCHAR(50) = (SELECT TOP 1 Department FROM Students WHERE Year LIKE '%III%' AND (Department LIKE '%CSE%DS%' OR Department LIKE '%CSEDS%'));
DECLARE @SubjectDept NVARCHAR(50) = (SELECT TOP 1 Department FROM Subjects WHERE Year = 3 AND Name = 'ML');
DECLARE @AssignedDept NVARCHAR(50) = (SELECT TOP 1 Department FROM AssignedSubjects WHERE Year = 3);

PRINT 'Student Department (Year III): ' + ISNULL(@StudentDept, 'NULL');
PRINT 'ML Subject Department: ' + ISNULL(@SubjectDept, 'NULL');
PRINT 'AssignedSubjects Department (Year 3): ' + ISNULL(@AssignedDept, 'NULL');

IF @StudentDept != @SubjectDept OR @StudentDept != @AssignedDept
BEGIN
    PRINT ''
    PRINT '*** MISMATCH DETECTED! ***'
    PRINT 'The department names are NOT matching between tables!'
    PRINT 'This is why subjects are not showing up for students.'
END
ELSE
BEGIN
    PRINT ''
    PRINT 'Department names match across tables.'
END

PRINT ''
PRINT '====================================================================='
PRINT '3. YEAR 3 SUBJECTS AVAILABILITY CHECK'
PRINT '====================================================================='

-- Check what Year 3 subjects exist
SELECT 
    s.SubjectId,
    s.Name,
    s.Department AS SubjectDepartment,
    s.Year,
    s.SubjectType,
    COUNT(a.AssignedSubjectId) AS AssignmentCount,
    STRING_AGG(CAST(a.Department AS NVARCHAR(MAX)), ', ') AS AssignedToDepartments
FROM Subjects s
LEFT JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
WHERE s.Year = 3
GROUP BY s.SubjectId, s.Name, s.Department, s.Year, s.SubjectType
ORDER BY s.SubjectType, s.Name;

PRINT ''
PRINT '====================================================================='
PRINT '4. WHAT WOULD A STUDENT SEE? (Simulating SelectSubject Logic)'
PRINT '====================================================================='

-- Simulate the query in SelectSubject GET method
DECLARE @TestStudentId NVARCHAR(50) = (SELECT TOP 1 Id FROM Students WHERE Year LIKE '%III%' AND (Department LIKE '%CSE%DS%' OR Department LIKE '%CSEDS%'));
DECLARE @TestStudentDept NVARCHAR(50) = (SELECT Department FROM Students WHERE Id = @TestStudentId);
DECLARE @TestStudentYear INT = 3;

PRINT 'Test Student ID: ' + ISNULL(@TestStudentId, 'NULL');
PRINT 'Test Student Department: ' + ISNULL(@TestStudentDept, 'NULL');
PRINT 'Test Student Year: ' + CAST(@TestStudentYear AS NVARCHAR);

PRINT ''
PRINT 'Query 1: Get ALL Year 3 subjects (no department filter):'
SELECT 
    s.SubjectId,
    s.Name,
    s.Department AS SubjectDept,
    s.SubjectType,
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = @TestStudentYear;

PRINT ''
PRINT 'Query 2: After filtering by EXACT department match (what student sees):'
SELECT 
    s.SubjectId,
    s.Name,
    s.Department AS SubjectDept,
    s.SubjectType,
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = @TestStudentYear
  AND s.Department = @TestStudentDept;  -- EXACT MATCH

PRINT ''
PRINT 'Query 3: If we use LIKE instead of = (flexible match):'
SELECT 
    s.SubjectId,
    s.Name,
    s.Department AS SubjectDept,
    s.SubjectType,
    a.AssignedSubjectId,
    a.Department AS AssignedDept,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = @TestStudentYear
  AND (s.Department = @TestStudentDept 
       OR s.Department = 'CSEDS' 
       OR s.Department = 'CSE(DS)');  -- FLEXIBLE MATCH

PRINT ''
PRINT '====================================================================='
PRINT '5. THE FIX NEEDED'
PRINT '====================================================================='

IF @StudentDept != @SubjectDept OR @StudentDept != @AssignedDept
BEGIN
    PRINT 'PROBLEM: Department names in different tables use different formats.'
    PRINT ''
    PRINT 'SOLUTION OPTIONS:'
    PRINT '1. UPDATE all department values to use the same format (CSE(DS) or CSEDS)'
    PRINT '2. MODIFY the code to normalize departments BEFORE comparing'
    PRINT '3. Use IN-MEMORY filtering with DepartmentNormalizer.Normalize()'
    PRINT ''
    PRINT 'RECOMMENDED: Option 3 - The code already loads all Year 3 subjects,'
    PRINT 'then filters in memory using DepartmentNormalizer.Normalize().'
    PRINT 'But there might be a bug in the filtering logic.'
END
ELSE
BEGIN
    PRINT 'Department names match. The issue might be in the code logic.'
    PRINT 'Check the SelectSubject GET method filtering logic.'
END

PRINT ''
PRINT 'DIAGNOSTIC COMPLETE'
PRINT '====================================================================='
