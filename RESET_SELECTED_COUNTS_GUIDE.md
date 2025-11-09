# Reset Selected Counts to Zero

## Purpose
This script resets all `SelectedCount` values to zero in the `AssignedSubjects` table. This is useful after deleting student records to ensure the enrollment counts are accurate.

## What It Does
1. **Connects to Database**: Uses the connection string from `appsettings.json`
2. **Shows Current Counts**: Displays all current SelectedCount values
3. **Resets to Zero**: Updates all SelectedCount values to 0
4. **Verifies Changes**: Shows the updated values to confirm success

## When to Use
- After deleting student records using `delete_only_students.bat`
- When SelectedCount values don't match actual enrollments
- To reset the system for fresh student enrollments

## How to Run

### Option 1: Double-click the Batch File
Simply double-click `reset_selected_counts.bat`

### Option 2: Run from Command Prompt
```cmd
reset_selected_counts.bat
```

### Option 3: Run PowerShell Directly
```powershell
.\reset_selected_counts.ps1
```

## What Gets Reset
- **AssignedSubjects.SelectedCount**: All values set to 0

## What Stays Unchanged
- All Faculty records
- All Admin records
- All Subject records
- All AssignedSubject records (except SelectedCount)
- All FacultySelectionSchedule records

## Example Output
```
========================================
   RESET SELECTED COUNTS TO ZERO
========================================

Connection string found.
Connecting to database...
Connected successfully!

Current SelectedCount values:
ID: 1   | Faculty: 1   | Subject: 1   | Dept: CSEDS  | Year: 2 | Count: 2
ID: 2   | Faculty: 1   | Subject: 2   | Dept: CSEDS  | Year: 3 | Count: 22
ID: 3   | Faculty: 1   | Subject: 3   | Dept: CSEDS  | Year: 4 | Count: 0
...

----------------------------------------

Resetting all SelectedCount values to 0...
Successfully updated 19 records!

Updated SelectedCount values (all should be 0):
ID: 1   | Faculty: 1   | Subject: 1   | Dept: CSEDS  | Year: 2 | Count: 0
ID: 2   | Faculty: 1   | Subject: 2   | Dept: CSEDS  | Year: 3 | Count: 0
ID: 3   | Faculty: 1   | Subject: 3   | Dept: CSEDS  | Year: 4 | Count: 0
...

========================================
   RESET COMPLETE!
========================================
```

## Verification
After running the script, you can verify the changes by:
1. Opening SQL Server Management Studio
2. Running: `SELECT * FROM AssignedSubjects`
3. Check that all `SelectedCount` values are 0

## Common Workflow
1. Run `delete_only_students.bat` to delete student records
2. Run `reset_selected_counts.bat` to reset enrollment counts
3. System is now ready for fresh student enrollments

## Troubleshooting

### Error: "appsettings.json not found"
- Make sure you're running the script from the project root directory
- Check that `appsettings.json` exists in the same folder

### Error: "Cannot open database"
- Verify the connection string in `appsettings.json`
- Check that SQL Server is running
- Ensure the database exists

### Error: "Access denied"
- Check SQL Server permissions
- Verify the user in the connection string has UPDATE permissions

## Related Scripts
- `delete_only_students.bat` - Delete student records only
- `delete_students_only.ps1` - PowerShell version of student deletion
- `DELETE_STUDENT_RECORDS_GUIDE.md` - Guide for deleting student records

## Safety
? **Safe Operation**: This script only updates the SelectedCount column
? **No Data Loss**: Does not delete any records
? **Reversible**: Counts will naturally update as students enroll again

## Notes
- This is a safe operation that doesn't delete any records
- The SelectedCount will automatically increment as students enroll in subjects
- Run this after cleaning student data to maintain data integrity
- No backup needed - this only updates counter values
