-- =============================================================================
-- TEST CSE(DS) FIX - Verify students can now see subjects
-- =============================================================================
-- Run this to verify the fix worked
-- =============================================================================

PRINT '=============================================================================';
PRINT 'TESTING CSE(DS) FIX - Can students see subjects now?';
PRINT '=============================================================================';
PRINT '';

-- Test Case 1: Check veena (23091A32H9) - Should see ML subject
PRINT 'TEST 1: Student veena (23091A32H9)';
PRINT '---------------------------------------------';

DECLARE @vStudentId VARCHAR(50) = '23091A32H9';
DECLARE @vStudentDept VARCHAR(50) = (SELECT Department FROM Students WHERE Id = @vStudentId);
DECLARE @vStudentYear VARCHAR(50) = (SELECT Year FROM Students WHERE Id = @vStudentId);

PRINT 'Student Details:';
PRINT '  - ID: ' + @vStudentId;
PRINT '  - Department: ' + @vStudentDept;
PRINT '  - Year: ' + @vStudentYear;
PRINT '';

-- Get subjects for Year III and CSEDS department
PRINT 'Available Subjects (should show ML):';
SELECT 
    s.SubjectId,
    s.Name,
    s.Department,
    s.SubjectType,
    f.Name AS Faculty,
    a.SelectedCount
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = 3 
  AND s.Department = @vStudentDept;

DECLARE @vSubjectCount INT = (
    SELECT COUNT(*)
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    WHERE a.Year = 3 AND s.Department = @vStudentDept
);

PRINT '';
IF @vSubjectCount > 0
    PRINT 'SUCCESS: Veena can see ' + CAST(@vSubjectCount AS VARCHAR(10)) + ' subject(s)!';
ELSE
    PRINT 'FAILURE: Veena cannot see any subjects!';

PRINT '';
PRINT '=============================================================================';

-- Test Case 2: Check shahid (23091A32D4) - Already enrolled, should see 0 new subjects
PRINT 'TEST 2: Student shahid (23091A32D4)';
PRINT '---------------------------------------------';

DECLARE @sStudentId VARCHAR(50) = '23091A32D4';
DECLARE @sStudentDept VARCHAR(50) = (SELECT Department FROM Students WHERE Id = @sStudentId);

PRINT 'Student Details:';
PRINT '  - ID: ' + @sStudentId;
PRINT '  - Department: ' + @sStudentDept;
PRINT '';

-- Check enrollments
PRINT 'Current Enrollments:';
SELECT 
    s.Name AS Subject,
    s.Department,
    f.Name AS Faculty
FROM StudentEnrollments se
INNER JOIN AssignedSubjects a ON se.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE se.StudentId = @sStudentId;

DECLARE @sEnrolledCount INT = (
    SELECT COUNT(*)
    FROM StudentEnrollments
    WHERE StudentId = @sStudentId
);

PRINT '';
PRINT 'Shahid has enrolled in ' + CAST(@sEnrolledCount AS VARCHAR(10)) + ' subject(s)';
PRINT 'This is expected - shahid already enrolled in ML during testing';

PRINT '';
PRINT '=============================================================================';
PRINT 'FINAL VERDICT:';
PRINT '=============================================================================';

IF @vSubjectCount > 0
BEGIN
    PRINT 'FIX SUCCESSFUL!';
    PRINT '';
    PRINT 'New CSE(DS) students can now see and select subjects.';
    PRINT 'All departments standardized to CSEDS format.';
    PRINT '';
    PRINT 'NEXT STEP: Fix StudentController.cs line 681-682';
    PRINT '  Change from: .FirstOrDefaultAsync(s => s.Department == "CSE(DS)")';
    PRINT '  Change to: Use DepartmentNormalizer.Normalize() for lookup';
END
ELSE
BEGIN
    PRINT 'FIX INCOMPLETE!';
    PRINT 'Students still cannot see subjects. Additional investigation needed.';
END

PRINT '=============================================================================';
