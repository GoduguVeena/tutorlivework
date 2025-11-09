@echo off
cls
echo ========================================
echo   URGENT FIX: No Available Subjects
echo ========================================
echo.
echo This will automatically fix the issue where
echo students cannot see available subjects.
echo.
echo Common Issue: Department name mismatch
echo   Student has: CSE(DS)
echo   System expects: CSEDS
echo.
echo This script will:
echo   1. Find all affected students
echo   2. Fix department names automatically
echo   3. Verify subjects are now visible
echo.
echo ========================================
echo.
pause

PowerShell -ExecutionPolicy Bypass -File "%~dp0urgent_fix_no_subjects.ps1"

echo.
echo ========================================
echo   NEXT STEPS:
echo ========================================
echo.
echo 1. Tell students to REFRESH their browser
echo    (Press Ctrl+F5 or Ctrl+Shift+R)
echo.
echo 2. Students should now see subjects!
echo.
pause
