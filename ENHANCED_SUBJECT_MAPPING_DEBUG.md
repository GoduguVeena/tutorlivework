# SUBJECT MAPPING DEBUG GUIDE - ENHANCED

## I've Added Enhanced Logging

The code now has detailed console logging that will show EXACTLY why subjects aren't appearing.

### What to Do Now

1. **Run the application** in Visual Studio (F5)

2. **Login as a Year III CSE(DS) student**

3. **Navigate to Select Subject page** (/Student/SelectSubject)

4. **Check the Output Console** in Visual Studio

### What You'll See in Console

The enhanced logging will show:

```
SelectSubject GET - Student: [Name], Department: 'CSEDS'
SelectSubject GET - Student normalized dept: 'CSE(DS)'
SelectSubject GET - Student Year: III Year -> 3
SelectSubject GET - Found 5 total subjects for Year=3

  - ML | Raw: 'CSEDS' -> Normalized: 'CSE(DS)' | Match: True | Type: Core
  - DPSD | Raw: 'CSEDS' -> Normalized: 'CSE(DS)' | Match: True | Type: Core
  - CN | Raw: 'CSEDS' -> Normalized: 'CSE(DS)' | Match: True | Type: Core
  
SelectSubject GET - After department filter: 3 subjects for Department='CSE(DS)'
SelectSubject GET - After filtering enrolled subjects: 3 subjects available
SelectSubject GET - Core: 3, PE1: 0, PE2: 0, PE3: 0
```

### Interpreting the Results

#### ? If you see "Match: True" for subjects
**The normalization IS working!** The issue is somewhere else:
- Check if subjects are being filtered out by SubjectType
- Check if SelectedCount < 70 is filtering them out
- Check the view (SelectSubject.cshtml) is displaying them

#### ? If you see "Match: False" for ALL subjects
**Normalization is NOT matching!** Possible causes:
1. Student Department has unexpected value (e.g., "CSE" instead of "CSEDS" or "CSE(DS)")
2. Subject Department has unexpected value
3. DepartmentNormalizer doesn't handle the specific variant

Example of FAILED match:
```
  - ML | Raw: 'CSE' -> Normalized: 'CSE' | Match: False | Type: Core
  FILTERED OUT: ML ('CSE' -> 'CSE' != 'CSE(DS)')
```
This means the subject department is "CSE" which doesn't normalize to "CSE(DS)".

#### ?? If you see "Found 0 total subjects for Year=3"
**No subjects assigned for Year 3!** The admin needs to:
1. Go to Admin Dashboard
2. Click "Manage CSE(DS) Faculty"
3. Assign Year 3 subjects to faculty members

### Common Issues and Fixes

#### Issue 1: "Found 0 total subjects"
**Cause:** No AssignedSubjects exist for Year 3  
**Fix:** Admin must assign subjects to faculty

#### Issue 2: All subjects show "Match: False"
**Cause:** Subject.Department values don't normalize correctly  
**Fixes:**
a) Update Subject.Department in database:
```sql
UPDATE Subjects SET Department = 'CSE(DS)' WHERE Department = 'CSE' AND Year = 3;
```
OR
b) Update DepartmentNormalizer to handle "CSE":
```csharp
if (upper == "CSE")
{
    return "CSE(DS)"; // Assume CSE means CSE(DS) for data science
}
```

#### Issue 3: Some subjects match, others don't
**Cause:** Inconsistent department values in database  
**Fix:** Standardize all department values:
```sql
-- Check current values
SELECT DISTINCT Department FROM Subjects WHERE Year = 3;

-- Update if needed
UPDATE Subjects SET Department = 'CSE(DS)' WHERE Department IN ('CSEDS', 'CSE-DS', 'CSE (DS)') AND Year = 3;
```

#### Issue 4: Subjects exist but don't show on page
**Cause:** View is not displaying them  
**Check:** Views/Student/SelectSubject.cshtml  
Look for the section that displays core subjects:
```cshtml
@if (Model.AvailableSubjectsGrouped.Any())
{
    // This should display subjects
}
```

### Next Steps

1. **Run the app and check console output**
2. **Copy the console output here**
3. **I'll tell you the exact fix based on what you see**

### Quick SQL Check

Run this to see what's in the database:
```sql
-- Show all Year 3 subjects
SELECT 
    s.SubjectId,
    s.Name,
    s.Department AS SubjectDept,
    s.SubjectType,
    COUNT(a.AssignedSubjectId) AS Assignments
FROM Subjects s
LEFT JOIN AssignedSubjects a ON s.SubjectId = a.SubjectId AND a.Year = 3
WHERE s.Year = 3
GROUP BY s.SubjectId, s.Name, s.Department, s.SubjectType
ORDER BY s.SubjectType, s.Name;
```

Expected output:
```
SubjectId | Name | SubjectDept | SubjectType | Assignments
----------|------|-------------|-------------|------------
1         | ML   | CSE(DS)     | Core        | 2
2         | DPSD | CSE(DS)     | Core        | 2
...
```

If Assignments = 0, admin needs to assign faculty.  
If SubjectDept is not "CSE(DS)" or "CSEDS", that's the mismatch.

## Final Checklist

- [ ] Run application
- [ ] Login as Year III student
- [ ] Go to Select Subject page
- [ ] Check Visual Studio Output window (View > Output)
- [ ] Look for "SelectSubject GET" messages
- [ ] Copy console output
- [ ] Identify which issue from above matches
- [ ] Apply the fix

The enhanced logging will tell you EXACTLY what's wrong!
