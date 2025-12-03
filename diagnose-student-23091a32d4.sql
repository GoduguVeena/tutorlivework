-- COMPREHENSIVE DIAGNOSTIC FOR STUDENT 23091A32D4
-- This will show EVERYTHING about this student and why subjects might not be showing

DECLARE @StudentId NVARCHAR(50) = '23091A32D4';

PRINT '========================================';
PRINT 'STUDENT INFORMATION';
PRINT '========================================';
SELECT 
    Id,
    FullName,
    Department,
    Year,
    Email,
    RegdNumber
FROM Students
WHERE Id = @StudentId OR UPPER(Email) = UPPER('23091a32d4@rgmcet.edu.in');

PRINT '';
PRINT '========================================';
PRINT 'STUDENT DEPARTMENT (RAW vs NORMALIZED)';
PRINT '========================================';
SELECT 
    Department AS [Raw Department],
    LEN(Department) AS [Length],
    CASE 
        WHEN UPPER(Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
        ELSE Department
    END AS [Normalized Department]
FROM Students
WHERE Id = @StudentId;

PRINT '';
PRINT '========================================';
PRINT 'STUDENT YEAR PARSING';
PRINT '========================================';
DECLARE @StudentYear NVARCHAR(20);
SELECT @StudentYear = Year FROM Students WHERE Id = @StudentId;

SELECT 
    @StudentYear AS [Year String],
    REPLACE(@StudentYear, ' Year', '') AS [After Remove Year],
    LTRIM(RTRIM(REPLACE(@StudentYear, ' Year', ''))) AS [After Trim],
    CASE LTRIM(RTRIM(REPLACE(@StudentYear, ' Year', '')))
        WHEN 'I' THEN 1
        WHEN 'II' THEN 2
        WHEN 'III' THEN 3
        WHEN 'IV' THEN 4
        ELSE 0
    END AS [Parsed Year Number];

DECLARE @YearNumber INT;
SET @YearNumber = CASE LTRIM(RTRIM(REPLACE(@StudentYear, ' Year', '')))
    WHEN 'I' THEN 1
    WHEN 'II' THEN 2
    WHEN 'III' THEN 3
    WHEN 'IV' THEN 4
    ELSE 0
END;

PRINT '';
PRINT '========================================';
PRINT 'ALL ASSIGNED SUBJECTS FOR THIS YEAR';
PRINT '========================================';
SELECT 
    a.AssignedSubjectId,
    s.Name AS [Subject Name],
    s.Department AS [Subject Dept],
    s.SubjectType,
    a.Department AS [Assigned Dept],
    a.Year,
    f.Name AS [Faculty Name],
    a.SelectedCount AS [Enrolled Count],
    CASE 
        WHEN UPPER(s.Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
        ELSE s.Department
    END AS [Normalized Subject Dept]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = @YearNumber
ORDER BY s.SubjectType, s.Name;

PRINT '';
PRINT '========================================';
PRINT 'DEPARTMENT MATCH CHECK';
PRINT '========================================';
DECLARE @StudentDept NVARCHAR(100);
SELECT @StudentDept = Department FROM Students WHERE Id = @StudentId;

SELECT 
    @StudentDept AS [Student Dept],
    CASE 
        WHEN UPPER(@StudentDept) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
        ELSE @StudentDept
    END AS [Student Normalized],
    s.Name AS [Subject],
    s.Department AS [Subject Dept],
    CASE 
        WHEN UPPER(s.Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
        ELSE s.Department
    END AS [Subject Normalized],
    CASE 
        WHEN (
            CASE 
                WHEN UPPER(@StudentDept) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
                ELSE @StudentDept
            END
        ) = (
            CASE 
                WHEN UPPER(s.Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
                ELSE s.Department
            END
        ) THEN 'MATCH' 
        ELSE 'NO MATCH'
    END AS [Match Status]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE a.Year = @YearNumber;

PRINT '';
PRINT '========================================';
PRINT 'STUDENT ENROLLMENTS (ALREADY SELECTED)';
PRINT '========================================';
SELECT 
    s.Name AS [Subject Name],
    s.SubjectType,
    f.Name AS [Faculty],
    e.EnrolledAt
FROM StudentEnrollments e
INNER JOIN AssignedSubjects a ON e.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE e.StudentId = @StudentId
ORDER BY e.EnrolledAt;

PRINT '';
PRINT '========================================';
PRINT 'SUBJECTS STUDENT SHOULD SEE (FILTERED)';
PRINT '========================================';
-- This simulates what the C# code does
WITH MatchedSubjects AS (
    SELECT 
        a.AssignedSubjectId,
        s.SubjectId,
        s.Name AS SubjectName,
        s.SubjectType,
        s.Department AS SubjectDept,
        f.Name AS FacultyName,
        a.SelectedCount,
        s.MaxEnrollments,
        CASE 
            WHEN UPPER(s.Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
            ELSE s.Department
        END AS NormalizedSubjectDept,
        CASE 
            WHEN UPPER(@StudentDept) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
            ELSE @StudentDept
        END AS NormalizedStudentDept
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
    WHERE a.Year = @YearNumber
)
SELECT 
    SubjectName,
    SubjectType,
    FacultyName,
    SelectedCount,
    MaxEnrollments,
    SubjectDept AS [Raw Subject Dept],
    NormalizedSubjectDept AS [Normalized],
    CASE 
        WHEN NormalizedSubjectDept = NormalizedStudentDept THEN 'YES - Dept Match'
        ELSE 'NO - Dept Mismatch'
    END AS [Show to Student?],
    CASE 
        WHEN EXISTS (
            SELECT 1 FROM StudentEnrollments e
            INNER JOIN AssignedSubjects a2 ON e.AssignedSubjectId = a2.AssignedSubjectId
            WHERE e.StudentId = @StudentId AND a2.SubjectId = SubjectId
        ) THEN 'ALREADY ENROLLED'
        ELSE 'AVAILABLE'
    END AS [Enrollment Status]
FROM MatchedSubjects
WHERE NormalizedSubjectDept = NormalizedStudentDept
ORDER BY SubjectType, SubjectName;

PRINT '';
PRINT '========================================';
PRINT 'FINAL COUNT: SUBJECTS STUDENT SHOULD SEE';
PRINT '========================================';
WITH MatchedSubjects AS (
    SELECT 
        s.SubjectId,
        s.Name AS SubjectName,
        s.SubjectType,
        CASE 
            WHEN UPPER(s.Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
            ELSE s.Department
        END AS NormalizedSubjectDept,
        CASE 
            WHEN UPPER(@StudentDept) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
            ELSE @StudentDept
        END AS NormalizedStudentDept
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    WHERE a.Year = @YearNumber
      AND NOT EXISTS (
          SELECT 1 FROM StudentEnrollments e
          INNER JOIN AssignedSubjects a2 ON e.AssignedSubjectId = a2.AssignedSubjectId
          WHERE e.StudentId = @StudentId AND a2.SubjectId = s.SubjectId
      )
)
SELECT 
    COUNT(*) AS [Total Available Subjects],
    SUM(CASE WHEN SubjectType = 'Core' THEN 1 ELSE 0 END) AS [Core Subjects],
    SUM(CASE WHEN SubjectType = 'ProfessionalElective1' THEN 1 ELSE 0 END) AS [PE1 Subjects],
    SUM(CASE WHEN SubjectType = 'ProfessionalElective2' THEN 1 ELSE 0 END) AS [PE2 Subjects],
    SUM(CASE WHEN SubjectType = 'ProfessionalElective3' THEN 1 ELSE 0 END) AS [PE3 Subjects]
FROM MatchedSubjects
WHERE NormalizedSubjectDept = NormalizedStudentDept;

PRINT '';
PRINT '========================================';
PRINT 'DIAGNOSIS';
PRINT '========================================';

DECLARE @TotalSubjects INT;
SELECT @TotalSubjects = COUNT(*)
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE a.Year = @YearNumber
  AND (
      CASE 
          WHEN UPPER(s.Department) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
          ELSE s.Department
      END
  ) = (
      CASE 
          WHEN UPPER(@StudentDept) IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') THEN 'CSE(DS)'
          ELSE @StudentDept
      END
  );

IF @TotalSubjects = 0
BEGIN
    PRINT 'ISSUE: No subjects assigned for Year ' + CAST(@YearNumber AS VARCHAR(10)) + ' in CSE(DS) department';
    PRINT 'FIX: Admin needs to assign subjects to faculty for this year';
END
ELSE
BEGIN
    PRINT 'Found ' + CAST(@TotalSubjects AS VARCHAR(10)) + ' subjects available';
    PRINT 'Student should see subjects on SelectSubject page';
END
