#!/usr/bin/env pwsh
# ============================================
# ONE-CLICK FIX LAUNCHER
# ============================================

Clear-Host

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?                                                            ?" -ForegroundColor Cyan
Write-Host "?        CSE(DS) SUBJECT FIX - ONE CLICK SOLUTION           ?" -ForegroundColor Cyan
Write-Host "?                                                            ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Write-Host "?? ISSUE: shahid afrid can't see subjects" -ForegroundColor Red
Write-Host "? SOLUTION: Fix department name mismatch" -ForegroundColor Green
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "This script will open everything you need to fix the issue:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ?? 1. Quick diagnostic SQL" -ForegroundColor White
Write-Host "  ?? 2. Fix SQL" -ForegroundColor White
Write-Host "  ? 3. Verification SQL" -ForegroundColor White
Write-Host "  ?? 4. Complete documentation" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to continue..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

# Check if we have VS Code or notepad
$editor = "notepad"
if (Get-Command "code" -ErrorAction SilentlyContinue) {
    $editor = "code"
    Write-Host "? Found VS Code - will use for opening files" -ForegroundColor Green
} else {
    Write-Host "??  VS Code not found - will use Notepad" -ForegroundColor Yellow
}

Write-Host ""

# Open files
$filesToOpen = @(
    @{Path="quick-check-shahid.sql"; Desc="Quick Diagnostic"; Priority=1},
    @{Path="fix-cseds-department-standardization.sql"; Desc="The Fix"; Priority=2},
    @{Path="verify-cseds-fix.sql"; Desc="Verification"; Priority=3},
    @{Path="COMPLETE_FIX_SUMMARY.md"; Desc="Documentation"; Priority=4}
)

Write-Host "Opening files..." -ForegroundColor Cyan
Write-Host ""

foreach ($file in $filesToOpen) {
    if (Test-Path $file.Path) {
        Write-Host "  [$($file.Priority)] Opening: $($file.Desc)" -ForegroundColor White
        Write-Host "      File: $($file.Path)" -ForegroundColor DarkGray
        
        if ($editor -eq "code") {
            Start-Process "code" -ArgumentList $file.Path -NoNewWindow
        } else {
            Start-Process "notepad" -ArgumentList $file.Path
        }
        
        Start-Sleep -Milliseconds 500
    } else {
        Write-Host "  ? Not found: $($file.Path)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "? Files opened!" -ForegroundColor Green
Write-Host ""

Write-Host "?? NEXT STEPS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1??  Open SQL Server Management Studio (SSMS)" -ForegroundColor White
Write-Host "  2??  Connect to your database" -ForegroundColor White
Write-Host "  3??  Run quick-check-shahid.sql (see the problem)" -ForegroundColor Cyan
Write-Host "  4??  Run fix-cseds-department-standardization.sql (fix it)" -ForegroundColor Green
Write-Host "  5??  Run verify-cseds-fix.sql (confirm success)" -ForegroundColor Green
Write-Host "  6??  Restart your application (Shift+F5, then F5)" -ForegroundColor Yellow
Write-Host "  7??  Login as shahid afrid" -ForegroundColor Yellow
Write-Host "  8??  Go to Select Subject" -ForegroundColor Yellow
Write-Host "  9??  ? SEE SUBJECTS!" -ForegroundColor Green
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? HOW TO RUN SQL FILES IN SSMS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Open SQL Server Management Studio" -ForegroundColor White
Write-Host "  2. Click: File ? Open ? File..." -ForegroundColor White
Write-Host "  3. Select the SQL file" -ForegroundColor White
Write-Host "  4. Press F5 or click Execute" -ForegroundColor White
Write-Host "  5. Check Results and Messages tabs" -ForegroundColor White
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "??  TROUBLESHOOTING:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  ? Still not working after fix?" -ForegroundColor White
Write-Host "     ? Make sure you restarted the application" -ForegroundColor Gray
Write-Host "     ? Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor Gray
Write-Host "     ? Check application logs (View ? Output ? Debug)" -ForegroundColor Gray
Write-Host ""
Write-Host "  ? SQL errors?" -ForegroundColor White
Write-Host "     ? Check connection string in appsettings.json" -ForegroundColor Gray
Write-Host "     ? Verify database server is running" -ForegroundColor Gray
Write-Host "     ? Check you have permissions" -ForegroundColor Gray
Write-Host ""
Write-Host "  ? Need more help?" -ForegroundColor White
Write-Host "     ? Read COMPLETE_FIX_SUMMARY.md (opened above)" -ForegroundColor Gray
Write-Host "     ? Check CSEDS_COMPLETE_FIX.md for full details" -ForegroundColor Gray
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? ESTIMATED TIME: 5 minutes" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "? Good luck! Your students will see subjects soon! ??" -ForegroundColor Green
Write-Host ""
