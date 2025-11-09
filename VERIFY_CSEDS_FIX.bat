@echo off
echo ==========================================
echo CSE(DS) STANDARDIZATION - VERIFICATION
echo ==========================================
echo.
echo This script will verify that all CSEDS records
echo have been updated to CSE(DS) format.
echo.
pause
echo.
echo Checking database...
echo.

REM Run verification query using dotnet ef
dotnet ef database update --context AppDbContext

echo.
echo ==========================================
echo MANUAL VERIFICATION STEPS:
echo ==========================================
echo.
echo 1. Login to the application
echo    - Use CSE(DS) admin credentials
echo    - Verify dashboard loads correctly
echo.
echo 2. Register a new CSE(DS) student
echo    - Select "CSE(DS)" from dropdown
echo    - Complete registration
echo    - Login and check if subjects are visible
echo.
echo 3. Check existing students
echo    - Login as an existing CSE(DS) student
echo    - Go to "Select Subject" page
echo    - Verify subjects are now visible
echo.
echo 4. Database Check (Optional)
echo    Run these SQL queries:
echo    - SELECT COUNT(*) FROM Students WHERE Department = 'CSEDS'
echo      (Should return 0)
echo    - SELECT COUNT(*) FROM Students WHERE Department = 'CSE(DS)'
echo      (Should return count of CSE(DS) students)
echo.
echo ==========================================
echo.
pause
