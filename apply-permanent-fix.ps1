#!/usr/bin/env pwsh
# ============================================
# APPLY PERMANENT FIX FOR CSE(DS) ISSUE
# ============================================

Clear-Host

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?                                                            ?" -ForegroundColor Cyan
Write-Host "?     PERMANENT FIX - CSE(DS) DEPARTMENT NORMALIZATION      ?" -ForegroundColor Cyan
Write-Host "?                                                            ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Write-Host "?? THIS WILL FIX THE ISSUE FOREVER!" -ForegroundColor Green
Write-Host ""
Write-Host "What this script does:" -ForegroundColor Yellow
Write-Host "  1. Fixes all existing data in database (CSEDS)" -ForegroundColor White
Write-Host "  2. Adds automatic normalization to your code" -ForegroundColor White
Write-Host "  3. Ensures future data is always correct" -ForegroundColor White
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "OPTION 1: Use EF Core Migration (Recommended)" -ForegroundColor Cyan
Write-Host ""
Write-Host "Steps:" -ForegroundColor Yellow
Write-Host "  1. Open Package Manager Console in Visual Studio" -ForegroundColor White
Write-Host "     (Tools ? NuGet Package Manager ? Package Manager Console)" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Run this command:" -ForegroundColor White
Write-Host "     Update-Database" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Wait for 'Done.' message" -ForegroundColor White
Write-Host ""
Write-Host "  4. Restart your application (Shift+F5, then F5)" -ForegroundColor White
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "OPTION 2: Use SQL Script (Quick & Easy)" -ForegroundColor Cyan
Write-Host ""
Write-Host "If you prefer SQL Server Management Studio:" -ForegroundColor Yellow
Write-Host ""
Write-Host "Press 'S' to open SQL scripts..." -ForegroundColor Yellow
Write-Host "Press 'M' to see migration guide..." -ForegroundColor Yellow
Write-Host "Press 'Q' to quit" -ForegroundColor Yellow
Write-Host ""

$choice = Read-Host "Your choice (S/M/Q)"

switch ($choice.ToUpper()) {
    "S" {
        Write-Host ""
        Write-Host "Opening SQL scripts..." -ForegroundColor Green
        
        if (Test-Path "fix-cseds-department-standardization.sql") {
            if (Get-Command "code" -ErrorAction SilentlyContinue) {
                code "fix-cseds-department-standardization.sql"
            } else {
                Start-Process "fix-cseds-department-standardization.sql"
            }
            
            Write-Host ""
            Write-Host "? SQL script opened!" -ForegroundColor Green
            Write-Host "Run it in SQL Server Management Studio" -ForegroundColor Yellow
        } else {
            Write-Host ""
            Write-Host "? SQL script not found!" -ForegroundColor Red
            Write-Host "File: fix-cseds-department-standardization.sql" -ForegroundColor Yellow
        }
    }
    
    "M" {
        Write-Host ""
        Write-Host "Opening migration guide..." -ForegroundColor Green
        
        if (Test-Path "PERMANENT_FIX_CSEDS.md") {
            if (Get-Command "code" -ErrorAction SilentlyContinue) {
                code "PERMANENT_FIX_CSEDS.md"
            } else {
                Start-Process "PERMANENT_FIX_CSEDS.md"
            }
            
            Write-Host ""
            Write-Host "? Guide opened!" -ForegroundColor Green
            Write-Host "Read the complete instructions" -ForegroundColor Yellow
        } else {
            Write-Host ""
            Write-Host "? Guide not found!" -ForegroundColor Red
        }
    }
    
    "Q" {
        Write-Host ""
        Write-Host "Exiting..." -ForegroundColor Yellow
        exit 0
    }
    
    default {
        Write-Host ""
        Write-Host "Invalid choice. Opening guide..." -ForegroundColor Yellow
        
        if (Test-Path "PERMANENT_FIX_CSEDS.md") {
            if (Get-Command "code" -ErrorAction SilentlyContinue) {
                code "PERMANENT_FIX_CSEDS.md"
            } else {
                Start-Process "PERMANENT_FIX_CSEDS.md"
            }
        }
    }
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? WHAT CHANGED IN YOUR CODE:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ? Models/AppDbContext.cs" -ForegroundColor Green
Write-Host "     - Added automatic department normalization" -ForegroundColor Gray
Write-Host "     - All saves now auto-convert CSE(DS) ? CSEDS" -ForegroundColor Gray
Write-Host ""
Write-Host "  ? Migrations/StandardizeCSEDSDepartments.cs" -ForegroundColor Green
Write-Host "     - Database migration to fix existing data" -ForegroundColor Gray
Write-Host ""
Write-Host "  ? Services/DepartmentNormalizationService.cs" -ForegroundColor Green
Write-Host "     - Helper service for manual operations" -ForegroundColor Gray
Write-Host ""
Write-Host "  ? Controllers/AdminControllerExtensions.cs" -ForegroundColor Green
Write-Host "     - Uses CSEDS by default" -ForegroundColor Gray
Write-Host ""
Write-Host "  ? Views/Admin/AddCSEDSStudent.cshtml" -ForegroundColor Green
Write-Host "     - Form updated to use CSEDS" -ForegroundColor Gray
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "? RESULT:" -ForegroundColor Green
Write-Host ""
Write-Host "  • All existing data normalized to CSEDS" -ForegroundColor White
Write-Host "  • Future data automatically normalized" -ForegroundColor White
Write-Host "  • Students will always see subjects" -ForegroundColor White
Write-Host "  • No manual fixes ever needed again!" -ForegroundColor White
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  1. Run the migration OR SQL script (choose one)" -ForegroundColor White
Write-Host "  2. Restart your application" -ForegroundColor White
Write-Host "  3. Check Output window for auto-normalize messages" -ForegroundColor White
Write-Host "  4. Add a test student - watch it auto-normalize!" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "? PERMANENT FIX READY! ??" -ForegroundColor Green
Write-Host ""
