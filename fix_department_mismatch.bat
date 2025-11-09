@echo off
cls
echo ========================================
echo   FIX DEPARTMENT MISMATCH ISSUE
echo ========================================
echo.
echo This script will:
echo   1. Check for department naming inconsistencies
echo   2. Identify students with no available subjects
echo   3. Offer to fix the mismatch automatically
echo.
echo Common Issue:
echo   Students have Department='CSE(DS)'
echo   But subjects have Department='CSEDS'
echo   Result: No subjects available for selection
echo.
echo ========================================
echo.

REM Run the PowerShell script
PowerShell -ExecutionPolicy Bypass -File "%~dp0fix_department_mismatch.ps1"

echo.
pause
