=============================================================================
TEST CSE(DS) FIX - MANUAL TESTING GUIDE
=============================================================================

? Database fixes applied
? Code fixes applied  
? Build successful

NOW: Test the application to verify students can see subjects

=============================================================================
TEST 1: Existing Student (veena - 23091A32H9)
=============================================================================

1. Run the application (F5 in Visual Studio)

2. Navigate to Student Login: http://localhost:5000/Student/Login

3. Login Credentials:
   - Registration Number: 23091A32H9
   - Password: <whatever was set during registration>

4. After login, click "Select Subject" or navigate to subject selection

5. EXPECTED RESULT:
   ? Should see "ML" subject
   ? Faculty: penchala prasad
   ? Subject Type: Core
   ? Should be able to click "Select" button
   ? Should successfully enroll

6. VERIFY:
   - No error messages
   - Subject appears in available subjects list
   - Can complete enrollment

=============================================================================
TEST 2: New CSE(DS) Student Registration
=============================================================================

1. Navigate to Student Registration: http://localhost:5000/Student/Register

2. Fill in details:
   - Full Name: Test Student
   - Registration Number: 23091A32T1 (or any unique ID)
   - Year: III Year
   - Department: CSEDS (or CSE(DS) - should be normalized)
   - Email: test@example.com
   - Password: Test@123

3. Submit registration

4. EXPECTED: Registration successful

5. Login with new credentials

6. Navigate to "Select Subject"

7. EXPECTED RESULT:
   ? Should see "ML" subject immediately
   ? No "Faculty selection is currently disabled" message
   ? Can select and enroll

=============================================================================
TEST 3: Schedule Check
=============================================================================

1. Login as CSE(DS) Admin

2. Navigate to "Manage Faculty Selection Schedule"

3. Toggle "Enable Faculty Selection" OFF for CSE(DS)

4. Logout and login as CSE(DS) student

5. Try to access "Select Subject"

6. EXPECTED RESULT:
   ? Should be BLOCKED with message: "Faculty selection is currently disabled..."
   ? Should be redirected to Main Dashboard

7. Admin re-enables schedule

8. Student should now be able to access subject selection

=============================================================================
SQL VERIFICATION QUERIES
=============================================================================

-- Check all CSE(DS) students can see subjects
SELECT 
    st.Id AS StudentId,
    st.FullName AS StudentName,
    st.Department AS StudentDept,
    st.Year AS StudentYear,
    COUNT(a.AssignedSubjectId) AS AvailableSubjects
FROM Students st
CROSS APPLY (
    SELECT a.AssignedSubjectId
    FROM AssignedSubjects a
    INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
    WHERE a.Year = 3 
      AND s.Department = st.Department
      AND a.AssignedSubjectId NOT IN (
          SELECT se.AssignedSubjectId 
          FROM StudentEnrollments se 
          WHERE se.StudentId = st.Id
      )
) a
WHERE st.Department = 'CSEDS'
  AND st.Year = 'III Year'
GROUP BY st.Id, st.FullName, st.Department, st.Year;

-- Expected: Each CSE(DS) student should see at least 1 subject

-- Check enrollments
SELECT 
    st.FullName AS Student,
    s.Name AS Subject,
    f.Name AS Faculty,
    se.EnrolledAt AS EnrolledDate
FROM StudentEnrollments se
INNER JOIN Students st ON se.StudentId = st.Id
INNER JOIN AssignedSubjects a ON se.AssignedSubjectId = a.AssignedSubjectId
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE st.Department = 'CSEDS'
ORDER BY se.EnrolledAt DESC;

=============================================================================
TROUBLESHOOTING
=============================================================================

IF STUDENTS STILL CAN'T SEE SUBJECTS:

1. Check console logs for "SelectSubject GET" messages
2. Verify student department: Should be "CSEDS"
3. Verify subject department: Should be "CSEDS"
4. Check schedule status: Should be available
5. Verify Year mapping: "III Year" ? 3

RUN THIS IN SQL:
```sql
-- See what the query actually returns
DECLARE @studentId VARCHAR(50) = '23091A32H9';
DECLARE @studentDept VARCHAR(50) = (SELECT Department FROM Students WHERE Id = @studentId);
DECLARE @studentYear INT = 3;

SELECT 
    a.AssignedSubjectId,
    s.SubjectId,
    s.Name,
    s.Department,
    s.SubjectType,
    f.Name AS Faculty
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE a.Year = @studentYear
  AND s.Department = @studentDept
  AND a.AssignedSubjectId NOT IN (
      SELECT AssignedSubjectId 
      FROM StudentEnrollments 
      WHERE StudentId = @studentId
  );
```

If this returns 0 rows, the issue is:
- Student already enrolled in all available subjects, OR
- No subjects assigned for Year 3 CSEDS, OR
- Year/Department mismatch

=============================================================================
SUCCESS CRITERIA
=============================================================================

? New CSE(DS) students can register
? CSE(DS) students can see available subjects
? CSE(DS) students can enroll in subjects
? Schedule toggle works for CSE(DS)
? No department format errors in logs
? All database records use "CSEDS" format

=============================================================================
