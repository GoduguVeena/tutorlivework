#!/usr/bin/env pwsh
# ============================================
# IMMEDIATE FIX FOR CSE(DS) SUBJECT ISSUE
# ============================================
# This script will fix the issue where CSE(DS) students can't see subjects

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSE(DS) SUBJECT VISIBILITY - QUICK FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "ISSUE:" -ForegroundColor Red
Write-Host "  Student 'shahid afrid' (III Year, CSE(DS)) sees 'No Available Subjects'" -ForegroundColor Yellow
Write-Host "  But admin shows 0 enrollments - meaning subjects ARE assigned" -ForegroundColor Yellow
Write-Host ""

Write-Host "ROOT CAUSE:" -ForegroundColor Red
Write-Host "  Department name mismatch between Students and Subjects tables" -ForegroundColor Yellow
Write-Host "  Student has: 'CSEDS' or 'CSE(DS)'" -ForegroundColor Yellow
Write-Host "  Subjects have: Different variation" -ForegroundColor Yellow
Write-Host ""

Write-Host "THE FIX:" -ForegroundColor Green
Write-Host "  Standardize ALL department names to 'CSEDS'" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 1: RUN DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will show you the exact department values in your database" -ForegroundColor Yellow
Write-Host ""
Write-Host "Run this SQL file in SQL Server Management Studio:" -ForegroundColor White
Write-Host "  diagnose-cseds-subject-issue.sql" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to open diagnostic SQL..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

if (Test-Path "diagnose-cseds-subject-issue.sql") {
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        Write-Host "Opening in VS Code..." -ForegroundColor Green
        code "diagnose-cseds-subject-issue.sql"
    } else {
        Write-Host "Opening file..." -ForegroundColor Green
        Start-Process "diagnose-cseds-subject-issue.sql"
    }
} else {
    Write-Host "ERROR: Diagnostic file not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WHAT TO LOOK FOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "After running the diagnostic, check section 6:" -ForegroundColor Yellow
Write-Host ""
Write-Host "IF YOU SEE:" -ForegroundColor White
Write-Host "  STUDENT DEPARTMENTS | CSEDS     | 2" -ForegroundColor Green
Write-Host "  SUBJECT DEPARTMENTS | CSE(DS)   | 15  <- DIFFERENT!" -ForegroundColor Red
Write-Host ""
Write-Host "THEN: You need to run the fix (Step 2)" -ForegroundColor Yellow
Write-Host ""

Write-Host "Press any key to continue to Step 2..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 2: APPLY THE FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This will standardize all department names to 'CSEDS'" -ForegroundColor Yellow
Write-Host ""
Write-Host "Run this SQL file in SQL Server Management Studio:" -ForegroundColor White
Write-Host "  fix-cseds-department-standardization.sql" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to open fix SQL..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

if (Test-Path "fix-cseds-department-standardization.sql") {
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        Write-Host "Opening in VS Code..." -ForegroundColor Green
        code "fix-cseds-department-standardization.sql"
    } else {
        Write-Host "Opening file..." -ForegroundColor Green
        Start-Process "fix-cseds-department-standardization.sql"
    }
} else {
    Write-Host "ERROR: Fix file not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "IMPORTANT:" -ForegroundColor Red
Write-Host "  1. Review the diagnostic results first" -ForegroundColor Yellow
Write-Host "  2. Then run the fix SQL" -ForegroundColor Yellow
Write-Host "  3. The fix uses transactions - safe to run" -ForegroundColor Green
Write-Host ""

Write-Host "Press any key to continue to Step 3..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 3: VERIFY THE FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "After applying the fix, verify it worked:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Run this SQL file in SQL Server Management Studio:" -ForegroundColor White
Write-Host "  verify-cseds-fix.sql" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to open verification SQL..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

if (Test-Path "verify-cseds-fix.sql") {
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        Write-Host "Opening in VS Code..." -ForegroundColor Green
        code "verify-cseds-fix.sql"
    } else {
        Write-Host "Opening file..." -ForegroundColor Green
        Start-Process "verify-cseds-fix.sql"
    }
} else {
    Write-Host "ERROR: Verification file not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "STEP 4: RESTART APPLICATION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "After running the fix SQL:" -ForegroundColor Yellow
Write-Host "  1. Stop your application (Stop debugging in Visual Studio)" -ForegroundColor White
Write-Host "  2. Press F5 to restart" -ForegroundColor White
Write-Host "  3. Login as 'shahid afrid'" -ForegroundColor White
Write-Host "  4. Go to Select Subject page" -ForegroundColor White
Write-Host "  5. You should now see available subjects!" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "QUICK SUMMARY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "FILES TO RUN (IN ORDER):" -ForegroundColor Yellow
Write-Host "  1. diagnose-cseds-subject-issue.sql     <- Find the problem" -ForegroundColor Cyan
Write-Host "  2. fix-cseds-department-standardization.sql <- Fix it" -ForegroundColor Green
Write-Host "  3. verify-cseds-fix.sql                <- Verify it worked" -ForegroundColor Green
Write-Host ""

Write-Host "HOW TO RUN SQL FILES:" -ForegroundColor Yellow
Write-Host "  1. Open SQL Server Management Studio (SSMS)" -ForegroundColor White
Write-Host "  2. Connect to your database" -ForegroundColor White
Write-Host "  3. File > Open > Select the SQL file" -ForegroundColor White
Write-Host "  4. Press F5 or click Execute" -ForegroundColor White
Write-Host "  5. Review the results" -ForegroundColor White
Write-Host ""

Write-Host "NEED MORE HELP?" -ForegroundColor Yellow
Write-Host "  Read: CSEDS_COMPLETE_FIX.md" -ForegroundColor Cyan
Write-Host "  Full documentation with screenshots and examples" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to open the complete documentation..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

if (Test-Path "CSEDS_COMPLETE_FIX.md") {
    if (Get-Command "code" -ErrorAction SilentlyContinue) {
        Write-Host "Opening documentation in VS Code..." -ForegroundColor Green
        code "CSEDS_COMPLETE_FIX.md"
    } else {
        Write-Host "Opening documentation..." -ForegroundColor Green
        Start-Process "CSEDS_COMPLETE_FIX.md"
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DONE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Follow the steps above and your students will see subjects!" -ForegroundColor Green
Write-Host ""
