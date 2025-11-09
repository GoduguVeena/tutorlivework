@echo off
cls
echo ========================================
echo   DELETE STUDENT RECORDS ONLY
echo ========================================
echo.
echo This will delete:
echo   - All Student records
echo   - All StudentEnrollment records
echo.
echo This will KEEP:
echo   - All Faculty records
echo   - All Admin records
echo   - All Subject records
echo   - All AssignedSubject records
echo   - All FacultySelectionSchedule records
echo.
echo ========================================
echo.

REM Run the PowerShell script
PowerShell -ExecutionPolicy Bypass -File "%~dp0delete_students_only.ps1"

echo.
pause
