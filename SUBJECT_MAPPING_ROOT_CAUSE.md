# SUBJECT MAPPING ISSUE - ROOT CAUSE AND FIX

## Problem Analysis

The SelectSubject page is not showing subjects even though normalization exists.

### Code Review (StudentController.cs, lines 711-752)

The code DOES use normalization correctly:
```csharp
// Line 719: Normalize student department
var normalizedStudentDept = DepartmentNormalizer.Normalize(student.Department);

// Line 742: Filter by normalized department  
availableSubjects = allYearSubjects
    .Where(a => DepartmentNormalizer.Normalize(a.Subject.Department) == normalizedStudentDept)
    .ToList();
```

### Possible Root Causes

1. **No Year 3 subjects in AssignedSubjects table**
   - Check: `allYearSubjects.Count == 0` in logs
   
2. **Department mismatch even after normalization**
   - Student Department: "CSEDS" -> Normalizes to "CSE(DS)"
   - Subject Department: "CSE(DS)" -> Normalizes to "CSE(DS)"
   - Should match!

3. **AssignedSubject.Department vs Subject.Department confusion**
   - Line 742 checks: `a.Subject.Department` ? CORRECT
   - NOT checking: `a.Department` 

## Most Likely Issue

**The AssignedSubjects table might be empty for Year 3!**

Or the Subject.Department values in database are not variants of CSE(DS).

## Diagnostic Steps

1. Run this SQL to check:
```sql
SELECT COUNT(*) FROM AssignedSubjects WHERE Year = 3;
```

2. If count = 0, that's the problem!
   - Admin needs to assign subjects to faculty

3. If count > 0, check department values:
```sql
SELECT DISTINCT s.Department 
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE a.Year = 3;
```

## The Fix

### Option 1: If AssignedSubjects is empty
Run as admin to create assignments for Year 3 subjects.

### Option 2: If department values don't normalize
Check what exact values are in Subjects.Department:
- If they're something like "CSE" (not "CSE(DS)" or "CSEDS"), the normalizer won't match
- Need to either:
  a) Update Subject.Department values to "CSE(DS)" or "CSEDS"
  b) Update DepartmentNormalizer to handle "CSE" -> "CSE(DS)"

### Option 3: Debug with console logs
Look for these log messages when student accesses /Student/SelectSubject:
```
SelectSubject GET - Found X total subjects for Year=3
SelectSubject GET - Student normalized dept: CSE(DS)
  - ML | Dept: 'CSEDS' -> 'CSE(DS)' | Type: Core
SelectSubject GET - After department filter: X subjects for Department=CSE(DS)
```

If "Found 0 total subjects" -> No AssignedSubjects for Year 3
If "After department filter: 0 subjects" -> Department mismatch

## Quick Check Command

Run in PowerShell:
```powershell
.\find-subject-mapping-issue.ps1
```

Or run in SQL:
```sql
-- Check Year 3 subjects
SELECT a.Year, s.Name, s.Department, COUNT(*) AS AssignmentCount
FROM AssignedSubjects a
INNER JOIN Subjects s ON a.SubjectId = s.SubjectId
WHERE a.Year = 3
GROUP BY a.Year, s.Name, s.Department;
```

## Expected Output

If working correctly, should see:
- ML, CSE(DS), 2 (or CSEDS, 2)
- DPSD, CSE(DS), 2
- Other Year 3 subjects...

If output is EMPTY, that's the root cause!
