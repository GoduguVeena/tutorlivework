@echo off
cls
echo ========================================
echo   DELETE STUDENT RECORDS ONLY
echo ========================================
echo.
echo This will DELETE ALL student records:
echo   - All Students
echo   - All Student Enrollments
echo.
echo Faculty and Admin records will be PRESERVED
echo.
echo ??  WARNING: This action cannot be undone!
echo.
pause

echo.
echo [STEP 1] Connecting to database...
powershell -ExecutionPolicy Bypass -File delete_student_records.ps1

if errorlevel 1 (
    echo.
    echo ? ERROR: Failed to delete records!
    echo Check the error message above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo   ? STUDENT RECORDS DELETED!
echo ========================================
echo.
echo What was deleted:
echo   ? All Students
echo   ? All Student Enrollments
echo.
echo What was preserved:
echo   ? All Faculty records
echo   ? All Admin records
echo   ? All Subjects
echo   ? All Assigned Subjects
echo   ? Faculty Selection Schedules
echo.
echo Your database is ready for deployment!
echo.
pause
