# ML Subject Not Showing - Solution Guide

## Problem Summary
- **Issue**: ML subject created for Year 3, CSE(DS) department, Semester I
- **Symptom**: Subject shows in Admin > ManageCSEDSSubjects but NOT visible to students in SelectSubject page
- **Root Cause**: ML subject exists in database but has NOT been assigned to any faculty member yet

## Why Students Can't See the Subject

Students see subjects through a **two-step process**:

1. **Subjects Table**: Contains subject definitions (ML, Data Mining, etc.)
2. **AssignedSubjects Table**: Links subjects to faculty members (faculty-subject assignments)

**Students ONLY see subjects that are in the AssignedSubjects table** (i.e., subjects that have been assigned to at least one faculty member).

## Solution Steps

### Step 1: Navigate to Faculty Management
1. Login as CSE(DS) Admin
2. Go to: **CSE(DS) Dashboard** ? **Faculty Management**
   - Direct URL: `localhost:5000/Admin/ManageCSEDSFaculty`

### Step 2: Assign ML Subject to Faculty
1. Find a faculty member who will teach ML
2. Click the **"Assign Subjects"** button (?? icon) for that faculty
3. In the modal that appears:
   - **Check the box next to "ML"**
   - Click **"Save Assignment"**

### Step 3: Verify the Assignment
1. Go back to **CSE(DS) Dashboard**
2. Scroll down to **"Subject-Faculty Assignments"** section
3. You should now see:
   ```
   ML | Year 3 | Semester I | Faculty Name | 0 students
   ```

### Step 4: Test Student View
1. Login as a Year 3 CSE(DS) student
2. Go to **Select Faculty** page
3. You should now see ML subject with the assigned faculty

## Technical Details

### Database Schema
```sql
-- Subjects table (Subject definitions)
Subjects
??? SubjectId (PK)
??? Name = "ML"
??? Department = "CSE(DS)"
??? Year = 3
??? Semester = "Semester I"
??? SubjectType = "ProfessionalElective1" (or Core, etc.)
??? MaxEnrollments = 70

-- AssignedSubjects table (Faculty-Subject mappings)
AssignedSubjects
??? AssignedSubjectId (PK)
??? SubjectId (FK ? Subjects)
??? FacultyId (FK ? Faculties)
??? Department = "CSE(DS)"
??? Year = 3
??? SelectedCount = 0 (number of students enrolled)
```

### Student Subject Query (from StudentController.cs)
```csharp
// Line 621-636: This query gets subjects for students
var allYearSubjects = await _context.AssignedSubjects  // ? Note: AssignedSubjects!
   .Include(a => a.Subject)
   .Include(a => a.Faculty)
   .Where(a => a.Year == studentYear)  // Year filter
   .ToListAsync();

// Then filter by normalized department
availableSubjects = allYearSubjects
    .Where(a => DepartmentNormalizer.Normalize(a.Subject.Department) == normalizedStudentDept)
    .ToList();
```

**Key Point**: The query starts from `AssignedSubjects`, not `Subjects`. So if ML isn't in AssignedSubjects, students won't see it.

## Quick Diagnostic Query
Run this SQL to check ML subject status:

```sql
-- Check if ML exists
SELECT * FROM Subjects WHERE Name = 'ML';

-- Check if ML is assigned to any faculty
SELECT 
    a.*,
    s.Name AS SubjectName,
    f.Name AS FacultyName
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Name = 'ML';
```

If the second query returns **0 rows**, ML hasn't been assigned yet.

## Alternative: Assign via ManageSubjectAssignments Page

1. Go to: **CSE(DS) Dashboard** ? **Faculty-Subject Assignments**
   - Direct URL: `localhost:5000/Admin/ManageSubjectAssignments`
2. Find the ML subject in the list
3. Select one or more faculty members to assign
4. Click **"Assign"** or **"Update Assignment"**

## Common Issues

### Issue 1: Department Mismatch
**Problem**: Subject shows "CSEDS" but faculty shows "CSE(DS)"
**Solution**: The code already handles this with `DepartmentNormalizer.Normalize()`. Both "CSEDS" and "CSE(DS)" are treated as equivalent.

### Issue 2: Year Mismatch
**Problem**: ML is Year 3 but student is Year 2
**Solution**: Students only see subjects for their own year. Verify student year matches subject year.

### Issue 3: Subject Already Enrolled
**Problem**: Student already enrolled in ML
**Solution**: The code filters out already-enrolled subjects. Student won't see it in available subjects.

## Code Files Involved

1. **StudentController.cs** (Lines 573-708)
   - `SelectSubject()` GET action - displays available subjects
   - Uses `AssignedSubjects` table with department normalization

2. **AdminController.cs** (Lines 313-380)
   - `AssignFacultyToSubject()` POST action
   - Creates entries in `AssignedSubjects` table
   - Sets `Department = "CSE(DS)"` (Line 359)

3. **DepartmentNormalizer.cs**
   - Normalizes "CSEDS", "CSE(DS)", "CSE (DS)", etc. to "CSE(DS)"

## Summary

? **The code is working correctly**
? **The issue is missing data**
? **Solution**: Assign ML subject to faculty members

Once you assign ML to at least one faculty member, students will immediately see it in the SelectSubject page!
