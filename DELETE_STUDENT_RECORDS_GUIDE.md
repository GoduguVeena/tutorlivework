# ??? DELETE STUDENT RECORDS - DOCUMENTATION

## Overview
This guide explains how to delete all student records from your database while keeping Faculty and Admin data intact.

---

## ?? What Gets Deleted

### ? **Records to be DELETED:**
- ? All **Student** records
- ? All **StudentEnrollment** records

### ? **Records to be PRESERVED:**
- ? All **Faculty** records
- ? All **Admin** records
- ? All **Subject** records
- ? All **AssignedSubject** records
- ? All **FacultySelectionSchedule** records

---

## ?? How to Delete Student Records

### **Method 1: Using the Batch File (Easiest)**

1. **Double-click** `delete_only_students.bat`
2. **Confirm** when prompted (type `Y` and press Enter)
3. **Wait** for completion
4. **Done!** All student records are deleted

### **Method 2: Using PowerShell Directly**

1. **Right-click** on `delete_students_only.ps1`
2. Select **"Run with PowerShell"**
3. **Confirm** when prompted (type `Y` and press Enter)
4. **Wait** for completion
5. **Done!** All student records are deleted

---

## ?? Expected Output

```
========================================
   DELETE STUDENT RECORDS ONLY
========================================

This will delete:
  - All Student records
  - All StudentEnrollment records

This will KEEP:
  - All Faculty records
  - All Admin records
  - All Subject records
  - All AssignedSubject records
  - All FacultySelectionSchedule records

========================================

[STEP 1] Stopping any running application...
[STEP 2] Connecting to database...
[STEP 3] Deleting StudentEnrollment records...
  ? Deleted XX enrollment records
[STEP 4] Deleting Student records...
  ? Deleted XX student records

========================================
   SUCCESS!
========================================

Summary:
  - Deleted XX students
  - Deleted XX enrollments
  - Faculty and Admin records intact ?
```

---

## ?? Important Notes

### **Before Running:**
1. ? **Stop your application** (the script does this automatically)
2. ? **Backup your database** if you're unsure (optional)
3. ? **Confirm** you want to delete all student data

### **After Running:**
1. ? **All students are deleted** - new registrations can start fresh
2. ? **Faculty can still see their subjects** - subject assignments remain
3. ? **Admin can still login** - admin account preserved
4. ? **Faculty selection schedules remain** - no need to reconfigure

---

## ?? For Fresh Deployment

This is perfect when you want to:
- ? **Reset student data** before production deployment
- ? **Clear test students** after testing phase
- ? **Start fresh** with student registrations
- ? **Keep all configuration** (faculty, subjects, schedules)

---

## ??? Database Details

### **Database:** `Working2Db`
### **Server:** `localhost`

### **SQL Commands Used:**
```sql
DELETE FROM StudentEnrollments;  -- Delete all enrollments first
DELETE FROM Students;             -- Then delete all students
```

### **Tables Affected:**
- `StudentEnrollments` - All enrollment records deleted
- `Students` - All student records deleted

### **Tables NOT Affected:**
- `Faculties` - ? Preserved
- `Admins` - ? Preserved
- `Subjects` - ? Preserved
- `AssignedSubjects` - ? Preserved
- `FacultySelectionSchedules` - ? Preserved

---

## ? Verification

After deletion, you can verify:
1. **Login as Admin** ? `cseds@rgmcet.edu.in` / `admin123`
2. **Check CSEDS Dashboard** ? Student count should be 0
3. **Check Faculty Records** ? All faculty still visible
4. **Check Subject Assignments** ? All assignments still intact

---

## ?? Troubleshooting

### **Error: "Cannot open database"**
- **Solution:** Make sure SQL Server is running
- Start SQL Server from Services

### **Error: "Cannot delete because of foreign key constraint"**
- **Solution:** The script deletes in correct order (Enrollments first, then Students)
- Should not happen, but if it does, run the PowerShell script again

### **Application won't start after deletion**
- **Solution:** Just run your normal start script
- Student deletion doesn't affect app startup

---

## ?? Quick Reference

| Action | File to Run |
|--------|-------------|
| Delete students | `delete_only_students.bat` |
| View this guide | `DELETE_STUDENT_RECORDS_GUIDE.md` |
| Start app after | `NGROK_CLEAN_START.bat` |

---

## ?? Use Cases

### **Before Production Deployment:**
```batch
1. Run: delete_only_students.bat
2. Verify: All test students removed
3. Deploy: Ready for real students
```

### **After Testing Phase:**
```batch
1. Run: delete_only_students.bat
2. Keep: All faculty and admin config
3. Fresh: Ready for new student batch
```

### **Fresh Start with Same Config:**
```batch
1. Run: delete_only_students.bat
2. Preserved: Faculty, Subjects, Schedules
3. Clean: No student data
```

---

## ? Benefits

- ?? **Fast** - Deletes all student records in seconds
- ?? **Precise** - Only deletes students, nothing else
- ? **Safe** - Preserves all faculty and admin data
- ?? **Repeatable** - Can run multiple times
- ?? **Clean** - No orphaned records left behind

---

**Ready to deploy fresh? Run `delete_only_students.bat` now!** ??
