-- ============================================
-- VERIFY CSE(DS) FIX IS WORKING
-- ============================================
-- Run this AFTER applying the fix to verify everything is working

PRINT '========================================';
PRINT 'CSE(DS) FIX VERIFICATION';
PRINT '========================================';
PRINT '';

-- ============================================
-- 1. CHECK ALL DEPARTMENTS ARE CSEDS
-- ============================================
PRINT '1. Checking for standardized department names...';
PRINT '';

DECLARE @allStandardized BIT = 1;

-- Check Students
IF EXISTS (SELECT 1 FROM Students WHERE Department LIKE '%CSE%DS%' AND Department != 'CSEDS')
BEGIN
    PRINT 'FAIL: Found non-standard departments in Students table:';
    SELECT DISTINCT Department, COUNT(*) AS Count 
    FROM Students 
    WHERE Department LIKE '%CSE%DS%' AND Department != 'CSEDS'
    GROUP BY Department;
    SET @allStandardized = 0;
END
ELSE
BEGIN
    PRINT 'PASS: All CSE(DS) students use CSEDS department';
END

-- Check Subjects
IF EXISTS (SELECT 1 FROM Subjects WHERE Department LIKE '%CSE%DS%' AND Department != 'CSEDS')
BEGIN
    PRINT 'FAIL: Found non-standard departments in Subjects table:';
    SELECT DISTINCT Department, COUNT(*) AS Count 
    FROM Subjects 
    WHERE Department LIKE '%CSE%DS%' AND Department != 'CSEDS'
    GROUP BY Department;
    SET @allStandardized = 0;
END
ELSE
BEGIN
    PRINT 'PASS: All CSE(DS) subjects use CSEDS department';
END

-- Check Faculties
IF EXISTS (SELECT 1 FROM Faculties WHERE Department LIKE '%CSE%DS%' AND Department != 'CSEDS')
BEGIN
    PRINT 'FAIL: Found non-standard departments in Faculties table:';
    SELECT DISTINCT Department, COUNT(*) AS Count 
    FROM Faculties 
    WHERE Department LIKE '%CSE%DS%' AND Department != 'CSEDS'
    GROUP BY Department;
    SET @allStandardized = 0;
END
ELSE
BEGIN
    PRINT 'PASS: All CSE(DS) faculty use CSEDS department';
END

PRINT '';

-- ============================================
-- 2. CHECK YEAR III CSEDS SUBJECTS ARE ASSIGNED
-- ============================================
PRINT '2. Checking Year III CSE(DS) subject assignments...';
PRINT '';

DECLARE @year3Subjects INT = (
    SELECT COUNT(DISTINCT a.AssignedSubjectId)
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    WHERE a.Year = 3 AND s.Department = 'CSEDS'
);

IF @year3Subjects = 0
BEGIN
    PRINT 'FAIL: No subjects assigned for Year III CSEDS';
    PRINT 'ACTION: Admin needs to assign subjects to faculty members';
END
ELSE
BEGIN
    PRINT 'PASS: Found ' + CAST(@year3Subjects AS VARCHAR(10)) + ' assigned subjects for Year III CSEDS';
    
    -- Show breakdown by type
    SELECT 
        s.SubjectType,
        COUNT(*) AS [Assigned Count]
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    WHERE a.Year = 3 AND s.Department = 'CSEDS'
    GROUP BY s.SubjectType
    ORDER BY s.SubjectType;
END

PRINT '';

-- ============================================
-- 3. CHECK SAMPLE STUDENT CAN SEE SUBJECTS
-- ============================================
PRINT '3. Simulating subject selection for a Year III CSEDS student...';
PRINT '';

-- Get a sample Year III CSEDS student
DECLARE @sampleStudentId VARCHAR(50) = (
    SELECT TOP 1 Id 
    FROM Students 
    WHERE Department = 'CSEDS' AND Year = 'III Year'
);

IF @sampleStudentId IS NULL
BEGIN
    PRINT 'WARNING: No Year III CSEDS students found in database';
    PRINT 'Cannot test subject visibility';
END
ELSE
BEGIN
    DECLARE @studentName VARCHAR(255) = (SELECT FullName FROM Students WHERE Id = @sampleStudentId);
    PRINT 'Testing with student: ' + @studentName + ' (ID: ' + @sampleStudentId + ')';
    PRINT '';
    
    -- Get subjects they're already enrolled in
    DECLARE @enrolledCount INT = (
        SELECT COUNT(*)
        FROM StudentEnrollments
        WHERE StudentId = @sampleStudentId
    );
    
    PRINT 'Currently enrolled in ' + CAST(@enrolledCount AS VARCHAR(10)) + ' subjects';
    
    IF @enrolledCount > 0
    BEGIN
        SELECT 
            s.Name AS [Enrolled Subject],
            s.SubjectType,
            f.Name AS [Faculty]
        FROM StudentEnrollments se
        INNER JOIN AssignedSubjects a ON se.AssignedSubjectId = a.AssignedSubjectId
        INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
        INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
        WHERE se.StudentId = @sampleStudentId;
    END
    
    PRINT '';
    
    -- Get subjects available for selection
    DECLARE @availableCount INT = (
        SELECT COUNT(DISTINCT a.AssignedSubjectId)
        FROM AssignedSubjects a
        INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
        WHERE a.Year = 3 
          AND s.Department = 'CSEDS'
          AND a.SubjectId NOT IN (
              SELECT a2.SubjectId
              FROM StudentEnrollments se
              INNER JOIN AssignedSubjects a2 ON se.AssignedSubjectId = a2.AssignedSubjectId
              WHERE se.StudentId = @sampleStudentId
          )
    );
    
    IF @availableCount = 0
    BEGIN
        IF @enrolledCount > 0
        BEGIN
            PRINT 'INFO: Student has already enrolled in all available subjects';
            PRINT 'This is correct behavior';
        END
        ELSE
        BEGIN
            PRINT 'FAIL: No subjects available for selection';
            PRINT 'But student has not enrolled in any subjects either';
            PRINT 'This indicates a problem!';
        END
    END
    ELSE
    BEGIN
        PRINT 'PASS: ' + CAST(@availableCount AS VARCHAR(10)) + ' subjects available for selection';
        PRINT '';
        PRINT 'Available subjects:';
        
        SELECT 
            s.Name AS [Subject],
            s.SubjectType,
            f.Name AS [Faculty],
            a.SelectedCount AS [Current Enrollments],
            s.MaxEnrollments AS [Max Enrollments]
        FROM AssignedSubjects a
        INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
        INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
        WHERE a.Year = 3 
          AND s.Department = 'CSEDS'
          AND a.SubjectId NOT IN (
              SELECT a2.SubjectId
              FROM StudentEnrollments se
              INNER JOIN AssignedSubjects a2 ON se.AssignedSubjectId = a2.AssignedSubjectId
              WHERE se.StudentId = @sampleStudentId
          )
        ORDER BY s.SubjectType, s.Name;
    END
END

PRINT '';

-- ============================================
-- 4. FINAL VERDICT
-- ============================================
PRINT '========================================';
PRINT 'FINAL VERDICT';
PRINT '========================================';
PRINT '';

IF @allStandardized = 1 AND @year3Subjects > 0
BEGIN
    PRINT 'SUCCESS: All checks passed!';
    PRINT '';
    PRINT 'CSEDS students should now be able to see and select subjects.';
    PRINT '';
    PRINT 'NEXT STEPS:';
    PRINT '1. Restart your web application';
    PRINT '2. Login as a Year III CSEDS student';
    PRINT '3. Go to Select Subject page';
    PRINT '4. You should see the available subjects';
END
ELSE
BEGIN
    PRINT 'ISSUES FOUND:';
    IF @allStandardized = 0
        PRINT '- Department names are not standardized';
    IF @year3Subjects = 0
        PRINT '- No subjects assigned for Year III CSEDS';
    PRINT '';
    PRINT 'Please fix the issues above before testing';
END

PRINT '';
PRINT '========================================';
