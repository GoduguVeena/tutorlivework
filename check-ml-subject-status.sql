-- Check the ML subject in Subjects table
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

-- Check if ML has been assigned to any faculty
SELECT 
    a.AssignedSubjectId,
    a.Department AS AssignedSubjectDepartment,
    a.Year,
    a.SelectedCount,
    s.Name AS SubjectName,
    s.Department AS SubjectDepartment,
    s.SubjectType,
    f.Name AS FacultyName,
    f.Department AS FacultyDepartment
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Name = 'ML';

-- Check all CSE(DS) students
SELECT 
    Id,
    FullName,
    Department,
    Year
FROM Students
WHERE Department IN ('CSE(DS)', 'CSEDS')
ORDER BY Year;
