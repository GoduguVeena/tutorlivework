# ? CSE(DS) FIX - TESTING CHECKLIST

## Pre-Testing Verification
- [x] Migration applied: `20251105173824_StandardizeToCseDs`
- [x] Build successful
- [x] No compilation errors
- [ ] Application running

## Test 1: New Student Registration (5 min)
- [ ] Go to `/Student/Register`
- [ ] Fill out form completely
- [ ] Select **"CSE(DS)"** from Department dropdown
- [ ] Submit registration
- [ ] **Verify:** Registration successful message
- [ ] **Verify:** Redirected to login page

## Test 2: New Student - Subject Visibility (5 min)
- [ ] Login with newly created CSE(DS) student
- [ ] **Verify:** Login successful
- [ ] Go to "Main Dashboard"
- [ ] Click "Select Subject"
- [ ] **Expected Result:** See list of available CSE(DS) subjects
- [ ] **NOT:** "No Available Subjects" message
- [ ] **Verify:** Subjects match student's year (II, III, or IV)
- [ ] Try enrolling in one subject
- [ ] **Verify:** Enrollment successful

## Test 3: Existing Student - Fixed Access (5 min)
- [ ] Login as an EXISTING CSE(DS) student
  (One who had "CSEDS" in database before fix)
- [ ] Go to "Main Dashboard"
- [ ] Click "Select Subject"
- [ ] **Expected Result:** NOW see available subjects
- [ ] **Verify:** Can enroll in subjects
- [ ] **Verify:** Subjects appropriate for year

## Test 4: Admin Dashboard (3 min)
- [ ] Login as CSE(DS) admin
- [ ] **Verify:** Login successful
- [ ] Go to "CSE(DS) Dashboard"
- [ ] **Verify:** Dashboard loads correctly
- [ ] **Verify:** Statistics show correct counts:
  - [ ] Students count
  - [ ] Faculty count
  - [ ] Subjects count
  - [ ] Enrollments count

## Test 5: Database Verification (2 min)
Run these SQL queries to verify migration:

```sql
-- Should return 0 (no more CSEDS records)
SELECT COUNT(*) FROM Students WHERE Department = 'CSEDS'

-- Should return count of CSE(DS) students
SELECT COUNT(*) FROM Students WHERE Department = 'CSE(DS)'

-- Verify all tables updated
SELECT 'Students' as TableName, COUNT(*) as Count FROM Students WHERE Department = 'CSE(DS)'
UNION ALL
SELECT 'Faculties', COUNT(*) FROM Faculties WHERE Department = 'CSE(DS)'
UNION ALL
SELECT 'Subjects', COUNT(*) FROM Subjects WHERE Department = 'CSE(DS)'
UNION ALL
SELECT 'Admins', COUNT(*) FROM Admins WHERE Department = 'CSE(DS)'
UNION ALL
SELECT 'AssignedSubjects', COUNT(*) FROM AssignedSubjects WHERE Department = 'CSE(DS)'
```

- [ ] All counts are greater than 0 (if records exist)
- [ ] No "CSEDS" records found

## Test 6: DepartmentNormalizer (1 min)
Test normalization function:
- [ ] Input "CSEDS" ? Output should be "CSE(DS)"
- [ ] Input "CSE(DS)" ? Output should be "CSE(DS)"
- [ ] Input "CSDS" ? Output should be "CSE(DS)"
- [ ] Input "CSE-DS" ? Output should be "CSE(DS)"

## Test 7: Edge Cases (5 min)
- [ ] Register student with different department (e.g., CSE)
  - [ ] **Verify:** Works normally
- [ ] Try mixed case input: "cse(ds)"
  - [ ] **Verify:** Normalized to "CSE(DS)"
- [ ] Existing non-CSE(DS) students still work
  - [ ] Login as ECE/EEE/MECH student
  - [ ] **Verify:** Can see their department's subjects

## Post-Testing Verification
- [ ] No errors in console logs
- [ ] No database connection issues
- [ ] All CSE(DS) students can see subjects
- [ ] Admin functions work correctly
- [ ] No regression in other departments

## If Any Test Fails:

### "No Available Subjects" still showing:
1. Check migration status: `dotnet ef migrations list`
2. Verify database: Run SQL queries above
3. Check DepartmentNormalizer: Ensure returns "CSE(DS)"
4. Rebuild: `dotnet clean && dotnet build`

### Login issues:
1. Verify credentials are correct
2. Check session is working
3. Clear browser cookies/cache

### Database issues:
1. Re-apply migration: `dotnet ef database update`
2. Check connection string in appsettings.json
3. Verify database server is running

## Documentation Reference
- Full details: `CSEDS_TO_CSEDS_FIX_COMPLETE.md`
- Quick reference: `CSEDS_TO_CSEDS_QUICK_REFERENCE.md`
- Summary: `FIX_SUMMARY_CSEDS_TO_CSEDS.md`

## Final Checklist
- [ ] All tests passed
- [ ] No errors encountered
- [ ] CSE(DS) students can see subjects
- [ ] Admin dashboard works
- [ ] Database correctly updated
- [ ] Ready for production deployment

---

**Testing Status:** ? PENDING  
**Tester:** _________________  
**Date:** _________________  
**Time:** _________________  

**Overall Result:** ? PASS  ? FAIL  
**Notes:**
_______________________________________
_______________________________________
_______________________________________

