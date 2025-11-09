@echo off
cls
echo ========================================
echo   DIAGNOSE AND FIX ENROLLMENT ISSUES
echo ========================================
echo.
echo This script will:
echo   1. Check for orphaned enrollment records
echo   2. Check for SelectedCount mismatches
echo   3. Identify subjects marked as full
echo   4. Offer to fix all detected issues
echo.
echo ========================================
echo.

REM Run the PowerShell script
PowerShell -ExecutionPolicy Bypass -File "%~dp0diagnose_and_fix.ps1"

echo.
pause
