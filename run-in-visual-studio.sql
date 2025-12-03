-- RUN THIS IN VISUAL STUDIO SQL SERVER OBJECT EXPLORER
-- Right-click on Working5Db database ? New Query ? Paste this ? Execute

-- Student to test
DECLARE @StudentId NVARCHAR(50) = '23091A32D4';
DECLARE @StudentEmail NVARCHAR(255) = '23091a32d4@rgmcet.edu.in';

PRINT '========================================';
PRINT '1. STUDENT LOGIN TEST';
PRINT '========================================';
SELECT 
    Id,
    FullName,
    Department,
    Year,
    Email
FROM Students
WHERE Email = @StudentEmail AND Password = 'Student@123';

PRINT '';
PRINT '========================================';
PRINT '2. STUDENT DEPARTMENT & YEAR';
PRINT '========================================';
SELECT 
    Department AS [Raw Department],
    Year AS [Raw Year],
    REPLACE(Year, ' Year', '') AS [Year Key],
    LTRIM(RTRIM(REPLACE(Year, ' Year', ''))) AS [Trimmed Year Key],
    CASE LTRIM(RTRIM(REPLACE(Year, ' Year', '')))
        WHEN 'I' THEN 1
        WHEN 'II' THEN 2
        WHEN 'III' THEN 3
        WHEN 'IV' THEN 4
        ELSE 0
    END AS [Year Number]
FROM Students
WHERE Id = @StudentId;

PRINT '';
PRINT '========================================';
PRINT '3. ALL YEAR 3 ASSIGNED SUBJECTS';
PRINT '========================================';
SELECT 
    a.AssignedSubjectId,
    s.Name AS [Subject],
    s.Department AS [Subject Dept],
    s.SubjectType,
    f.Name AS [Faculty],
    a.SelectedCount
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3
ORDER BY s.SubjectType, s.Name;

PRINT '';
PRINT '========================================';
PRINT '4. DEPARTMENT MATCH TEST';
PRINT '========================================';
-- This simulates the C# normalization
DECLARE @StudentDept NVARCHAR(100);
SELECT @StudentDept = Department FROM Students WHERE Id = @StudentId;

SELECT 
    s.Name AS [Subject],
    @StudentDept AS [Student Dept],
    s.Department AS [Subject Dept],
    CASE 
        WHEN @StudentDept IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') 
        THEN 'CSE(DS)' ELSE @StudentDept 
    END AS [Student Normalized],
    CASE 
        WHEN s.Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') 
        THEN 'CSE(DS)' ELSE s.Department 
    END AS [Subject Normalized],
    CASE 
        WHEN (
            CASE 
                WHEN @StudentDept IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') 
                THEN 'CSE(DS)' ELSE @StudentDept 
            END
        ) = (
            CASE 
                WHEN s.Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') 
                THEN 'CSE(DS)' ELSE s.Department 
            END
        ) THEN 'MATCH' ELSE 'NO MATCH'
    END AS [Match Status]
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE a.Year = 3;

PRINT '';
PRINT '========================================';
PRINT '5. FINAL COUNT';
PRINT '========================================';
WITH MatchedSubjects AS (
    SELECT 
        s.Name,
        s.SubjectType,
        CASE 
            WHEN s.Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') 
            THEN 'CSE(DS)' ELSE s.Department 
        END AS NormalizedSubjectDept,
        CASE 
            WHEN @StudentDept IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSE(DS)') 
            THEN 'CSE(DS)' ELSE @StudentDept 
        END AS NormalizedStudentDept
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    WHERE a.Year = 3
)
SELECT 
    COUNT(*) AS [Total Matching],
    SUM(CASE WHEN SubjectType = 'Core' THEN 1 ELSE 0 END) AS [Core],
    SUM(CASE WHEN SubjectType = 'ProfessionalElective1' THEN 1 ELSE 0 END) AS [PE1],
    SUM(CASE WHEN SubjectType = 'ProfessionalElective2' THEN 1 ELSE 0 END) AS [PE2],
    SUM(CASE WHEN SubjectType = 'ProfessionalElective3' THEN 1 ELSE 0 END) AS [PE3]
FROM MatchedSubjects
WHERE NormalizedSubjectDept = NormalizedStudentDept;
