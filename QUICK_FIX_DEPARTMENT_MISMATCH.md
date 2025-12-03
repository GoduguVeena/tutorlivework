# QUICK FIX: ML Subject Not Showing Despite Assignment

## TL;DR - Run This First

```powershell
# 1. Diagnose the issue
.\diagnose-ml-mismatch.ps1

# 2. If it shows department mismatch, run this SQL:
```

```sql
USE TutorLiveMentorDb;
BEGIN TRANSACTION;

-- Standardize all department names to CSE(DS)
UPDATE Students SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%' AND Department != 'CSE(DS)';
UPDATE Subjects SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%' AND Department != 'CSE(DS)';
UPDATE Faculties SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%' AND Department != 'CSE(DS)';
UPDATE AssignedSubjects SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%' AND Department != 'CSE(DS)';
UPDATE FacultySelectionSchedules SET Department = 'CSE(DS)' WHERE Department LIKE '%CSE%DS%' AND Department != 'CSE(DS)';

COMMIT TRANSACTION;
```

```powershell
# 3. Restart your app and test
```

## What's Wrong?

The database has inconsistent department names:
- Some tables have `"CSEDS"`
- Some tables have `"CSE(DS)"`

Even though the code normalizes these, the SQL query might filter them out **before** normalization happens.

## Why Normalization Isn't Enough

```csharp
// THIS DOESN'T WORK as expected:
var allSubjects = await _context.AssignedSubjects
    .Include(a => a.Subject)
    .Where(a => a.Year == 3)  // SQL query - fetches from DB
    .ToListAsync();

// Then normalize in C# (too late!)
availableSubjects = allSubjects
    .Where(a => DepartmentNormalizer.Normalize(a.Subject.Department) == "CSE(DS)")
    .ToList();
```

The problem is that EF Core might optimize the query and the Subject.Department filter could happen in SQL, not in C#.

## The Fix

Make all department names consistent in the database = `"CSE(DS)"` everywhere.

## Files Created

1. **diagnose-ml-mismatch.ps1** - Run this first to see the exact problem
2. **fix-department-names-to-cseds.sql** - SQL script to fix all tables
3. **ML_DEPARTMENT_MISMATCH_FIX.md** - Complete guide with details

## After Running the Fix

Students should immediately see ML subject in their SelectSubject page!

## If Still Not Working

Check these:

```sql
-- 1. Verify ML exists and is assigned
SELECT s.Name, s.Department, s.Year, s.SubjectType,
       f.Name AS Faculty, a.Department AS AssignedDept
FROM Subjects s
INNER JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId
INNER JOIN Faculties f ON a.FacultyId = f.FacultyId
WHERE s.Name = 'ML';

-- Should return 1+ rows

-- 2. Check if student already enrolled
SELECT * FROM StudentEnrollments 
WHERE StudentId = '23091A32D4'  -- Replace with your student ID
AND AssignedSubjectId IN (
    SELECT AssignedSubjectId FROM AssignedSubjects WHERE SubjectId IN (
        SELECT SubjectId FROM Subjects WHERE Name = 'ML'
    )
);

-- Should return 0 rows (not enrolled yet)

-- 3. Check faculty selection schedule
SELECT * FROM FacultySelectionSchedules WHERE Department = 'CSE(DS)';
-- IsCurrentlyAvailable should be 1 (true)
```

## Summary

**Problem**: Database has mixed "CSEDS" and "CSE(DS)" values
**Solution**: Standardize all to "CSE(DS)" using the SQL script
**Time**: 2 minutes
**Result**: ML subject will immediately appear for students
