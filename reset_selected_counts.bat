@echo off
cls
echo ========================================
echo   RESET SELECTED COUNTS TO ZERO
echo ========================================
echo.
echo This will reset all SelectedCount values
echo in the AssignedSubjects table to 0.
echo.
echo This is useful after deleting student
echo records to reset the enrollment counts.
echo.
echo ========================================
echo.

REM Run the PowerShell script
PowerShell -ExecutionPolicy Bypass -File "%~dp0reset_selected_counts.ps1"

echo.
pause
