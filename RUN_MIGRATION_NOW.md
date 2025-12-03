# ?? Quick Fix: Run the Database Migration NOW

## Problem
Your database still has "CSEDS" stored, but your code expects "CSE(DS)". The normalizer was working before, but the code changes removed the OR conditions, so now it only looks for "CSE(DS)".

## Solution
Run the migration to update the database. You have **3 easy options**:

---

## ? OPTION 1: PowerShell Script (EASIEST)

### Steps:
1. **Stop your application** (press Stop in Visual Studio)
2. Open PowerShell in your project directory
3. Run:
   ```powershell
   .\run-migration.ps1
   ```
4. Type `yes` when prompted
5. Wait for completion
6. **Restart your application**

---

## ?? OPTION 2: Entity Framework Migration (RECOMMENDED)

### Steps:
1. **Stop your application** (press Stop in Visual Studio)
2. Open **Package Manager Console** in Visual Studio:
   - Menu: `Tools` ? `NuGet Package Manager` ? `Package Manager Console`
3. Run this command:
   ```powershell
   Update-Database
   ```
4. Wait for "Done" message
5. **Restart your application**

That's it! EF will automatically apply the migration file I created.

---

## ?? OPTION 3: SQL Server Management Studio (MANUAL)

### Steps:
1. Open **SQL Server Management Studio** (SSMS)
2. Connect to `localhost`
3. Open the file: `Migrations\UpdateCSEDSToCseDsStandard.sql`
4. Make sure database is set to `Working5Db` (top dropdown)
5. Click **Execute** (F5)
6. Check the results - should show counts of updated records
7. **Restart your application** in Visual Studio

---

## ? Verification After Running Migration

### 1. Check Database (in SSMS):
```sql
-- All should return CSE(DS), not CSEDS
SELECT DISTINCT Department FROM Students;
SELECT DISTINCT Department FROM Faculty;
SELECT DISTINCT Department FROM Subjects;
SELECT DISTINCT Department FROM FacultySelectionSchedules;
```

### 2. Test Your Application:
1. **Login as student** (any CSE(DS) student)
2. **Check Main Dashboard** - Should show `CSE(DS)` in header
3. **Check Profile Page** - Should show `CSE(DS)` in department field
4. **Try Faculty Selection** - Should work without errors

---

## ?? Expected Results

### Before Migration:
- Database: `CSEDS` ?
- Students see: `CSEDS` ?
- Code looks for: `CSE(DS)` ?
- **Result:** Mismatch! Queries return no results ?

### After Migration:
- Database: `CSE(DS)` ?
- Students see: `CSE(DS)` ?
- Code looks for: `CSE(DS)` ?
- **Result:** Everything works! ?

---

## ?? Important Notes

1. **The migration is SAFE** - It only updates department names, nothing else
2. **No data will be lost** - All student/faculty/subject data remains intact
3. **It's INSTANT** - Takes less than 1 second to run
4. **It's REVERSIBLE** - The EF migration includes a rollback (Down method)

---

## ?? If You See Errors

### Error: "sqlcmd not found"
**Solution:** Use Option 2 (Entity Framework) instead

### Error: "Cannot connect to server"
**Solution:** 
- Make sure SQL Server is running (check Services)
- Or use Option 3 (SSMS) instead

### Error: "Database not found"
**Solution:** 
- Check your database name in `appsettings.json`
- Make sure it's `Working5Db`

---

## ?? Why This Happened

Your earlier code had **safety net OR conditions**:
```csharp
// OLD CODE (worked with both)
.Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
```

The new simplified code expects **standardized data**:
```csharp
// NEW CODE (expects CSE(DS) only)
.Where(s => s.Department == "CSE(DS)")
```

The database still has `CSEDS`, so queries return nothing! ??

**Solution:** Update the database to match the new code! ??

---

## ?? Need Help?

If you still see issues after running the migration:

1. **Check the Console output** - Look for any error messages
2. **Check SQL verification queries** - See what the database actually has
3. **Clear your browser cache** - Sometimes old data is cached
4. **Restart IIS Express** - Stop debugging completely and restart

---

## ?? How Long Will This Take?

- Reading this guide: 2 minutes
- Running the migration: 30 seconds
- Testing: 1 minute
- **Total: Less than 4 minutes!** ?

---

## ?? Quick Start (If You're in a Hurry)

```powershell
# STOP your app first, then:

# In Package Manager Console:
Update-Database

# That's it! Now restart your app.
```

---

**Ready? Pick your option and let's fix this! ??**
