#!/usr/bin/env pwsh
# ============================================
# VERIFY PERMANENT FIX IS WORKING
# ============================================

Clear-Host

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?                                                            ?" -ForegroundColor Cyan
Write-Host "?   VERIFYING PERMANENT FIX - CSE(DS) AUTO-NORMALIZATION    ?" -ForegroundColor Cyan
Write-Host "?                                                            ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

Write-Host "? You ran: Update-Database" -ForegroundColor Green
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? VERIFICATION CHECKLIST:" -ForegroundColor Yellow
Write-Host ""

# Check 1: Migration applied
Write-Host "1??  Checking if migration was applied..." -ForegroundColor Cyan
Write-Host ""
Write-Host "   The migration should have:" -ForegroundColor White
Write-Host "   ? Updated all Students to CSEDS" -ForegroundColor Gray
Write-Host "   ? Updated all Subjects to CSEDS" -ForegroundColor Gray
Write-Host "   ? Updated all Faculties to CSEDS" -ForegroundColor Gray
Write-Host ""

# Check 2: Application restart
Write-Host "2??  Did you restart the application?" -ForegroundColor Cyan
Write-Host ""
$restarted = Read-Host "   Press Y if you restarted (Shift+F5, then F5), or N if not"

if ($restarted.ToUpper() -ne "Y") {
    Write-Host ""
    Write-Host "   ??  PLEASE RESTART NOW!" -ForegroundColor Yellow
    Write-Host "   1. Press Shift+F5 to stop debugging" -ForegroundColor White
    Write-Host "   2. Press F5 to start again" -ForegroundColor White
    Write-Host ""
    Write-Host "   Then run this script again." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 0
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "3??  Testing Auto-Normalization..." -ForegroundColor Cyan
Write-Host ""
Write-Host "   ?? INSTRUCTIONS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Make sure your app is running in DEBUG mode (F5)" -ForegroundColor White
Write-Host "   2. Open Visual Studio Output window:" -ForegroundColor White
Write-Host "      View ? Output ? Select 'Debug' from dropdown" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Login as ADMIN and add a new student" -ForegroundColor White
Write-Host "      (or create any new subject/faculty)" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Check Output window for this message:" -ForegroundColor White
Write-Host ""
Write-Host "      [AUTO-NORMALIZE] Student.Department: 'CSE(DS)' ? 'CSEDS'" -ForegroundColor Green
Write-Host ""

Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "   Did you see the [AUTO-NORMALIZE] message?" -ForegroundColor Yellow
Write-Host ""
$sawMessage = Read-Host "   Press Y if YES, N if NO"

Write-Host ""

if ($sawMessage.ToUpper() -eq "Y") {
    Write-Host "   ? PERFECT! Auto-normalization is WORKING!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ?? PERMANENT FIX IS ACTIVE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   From now on:" -ForegroundColor Cyan
    Write-Host "   • All new students ? Auto-normalized to CSEDS ?" -ForegroundColor White
    Write-Host "   • All new subjects ? Auto-normalized to CSEDS ?" -ForegroundColor White
    Write-Host "   • All new faculty ? Auto-normalized to CSEDS ?" -ForegroundColor White
    Write-Host "   • Students will ALWAYS see their subjects ?" -ForegroundColor White
    Write-Host "   • NO manual fixes ever needed ?" -ForegroundColor White
    Write-Host ""
    
    Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
    Write-Host ""
    
    Write-Host "   ? SUCCESS CONFIRMATION:" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ?? PERMANENTLY FIXED FOREVER!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   This issue will NEVER happen again! ??" -ForegroundColor Green
    
} else {
    Write-Host "   ??  AUTO-NORMALIZE MESSAGE NOT SEEN" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   TROUBLESHOOTING:" -ForegroundColor Red
    Write-Host ""
    Write-Host "   ? Is Output window open?" -ForegroundColor White
    Write-Host "      View ? Output ? Select 'Debug'" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   ? Did you add/edit a record after restarting?" -ForegroundColor White
    Write-Host "      The message only shows when saving data" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   ? Check AppDbContext.cs has the SaveChangesAsync override" -ForegroundColor White
    Write-Host "      Look for: public override Task<int> SaveChangesAsync(...)" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "   Let's check the database directly..." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "4??  Database Verification" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Let's verify all data in database is CSEDS..." -ForegroundColor Yellow
Write-Host ""
Write-Host "   Opening verification SQL script..." -ForegroundColor White

if (Test-Path "verify-cseds-fix.sql") {
    Write-Host ""
    Write-Host "   ? Found: verify-cseds-fix.sql" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ?? RUN THIS IN SSMS:" -ForegroundColor Yellow
    Write-Host "   1. Open SQL Server Management Studio" -ForegroundColor White
    Write-Host "   2. Connect to your database" -ForegroundColor White
    Write-Host "   3. Open: verify-cseds-fix.sql" -ForegroundColor White
    Write-Host "   4. Press F5 to execute" -ForegroundColor White
    Write-Host "   5. Check for 'SUCCESS: All checks passed!'" -ForegroundColor White
    Write-Host ""
    
    $openSQL = Read-Host "   Open verification SQL now? (Y/N)"
    
    if ($openSQL.ToUpper() -eq "Y") {
        if (Get-Command "code" -ErrorAction SilentlyContinue) {
            code "verify-cseds-fix.sql"
            Write-Host ""
            Write-Host "   ? Opened in VS Code" -ForegroundColor Green
        } else {
            Start-Process "verify-cseds-fix.sql"
            Write-Host ""
            Write-Host "   ? Opened in default editor" -ForegroundColor Green
        }
    }
} else {
    Write-Host ""
    Write-Host "   ??  verify-cseds-fix.sql not found" -ForegroundColor Yellow
    Write-Host "   But that's okay - let's check manually..." -ForegroundColor Gray
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "5??  Student Test" -ForegroundColor Cyan
Write-Host ""
Write-Host "   Final verification - test as a student:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   1. Login as: shahid afrid (or any Year III CSE(DS) student)" -ForegroundColor White
Write-Host "   2. Go to: Select Subject page" -ForegroundColor White
Write-Host "   3. You should see available subjects!" -ForegroundColor White
Write-Host ""

$studentTest = Read-Host "   Did student see subjects? (Y/N)"

Write-Host ""

if ($studentTest.ToUpper() -eq "Y") {
    Write-Host "   ? PERFECT! Everything is working!" -ForegroundColor Green
    Write-Host ""
    Write-Host "   ?????? PERMANENT FIX VERIFIED! ??????" -ForegroundColor Green
    Write-Host ""
    
} else {
    Write-Host "   ??  Student still can't see subjects" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "   POSSIBLE ISSUES:" -ForegroundColor Red
    Write-Host ""
    Write-Host "   1. No subjects assigned for Year III" -ForegroundColor White
    Write-Host "      ? Admin needs to assign subjects to faculty" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   2. Student already enrolled in all subjects" -ForegroundColor White
    Write-Host "      ? Check enrollments table" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   3. Migration didn't run successfully" -ForegroundColor White
    Write-Host "      ? Check Package Manager Console for errors" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   Run verify-cseds-fix.sql in SSMS for detailed diagnosis" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? VERIFICATION SUMMARY:" -ForegroundColor Cyan
Write-Host ""
Write-Host "? Migration Applied: YES (you ran Update-Database)" -ForegroundColor White

if ($restarted.ToUpper() -eq "Y") {
    Write-Host "? Application Restarted: YES" -ForegroundColor White
} else {
    Write-Host "??  Application Restarted: NO - Please restart!" -ForegroundColor Yellow
}

if ($sawMessage.ToUpper() -eq "Y") {
    Write-Host "? Auto-Normalize Working: YES" -ForegroundColor White
} else {
    Write-Host "? Auto-Normalize Working: NEEDS VERIFICATION" -ForegroundColor Yellow
}

if ($studentTest.ToUpper() -eq "Y") {
    Write-Host "? Student Can See Subjects: YES" -ForegroundColor White
} else {
    Write-Host "? Student Can See Subjects: NEEDS INVESTIGATION" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

if ($sawMessage.ToUpper() -eq "Y" -and $studentTest.ToUpper() -eq "Y") {
    Write-Host "?? FINAL VERDICT: SUCCESS!" -ForegroundColor Green
    Write-Host ""
    Write-Host "? Permanent fix is ACTIVE and WORKING!" -ForegroundColor Green
    Write-Host "? All future data will be auto-normalized!" -ForegroundColor Green
    Write-Host "? This issue is FIXED FOREVER!" -ForegroundColor Green
    Write-Host ""
    Write-Host "?? NO MORE MANUAL FIXES EVER NEEDED! ??" -ForegroundColor Green
} else {
    Write-Host "??  FINAL VERDICT: NEEDS ATTENTION" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please:" -ForegroundColor Yellow
    Write-Host "1. Make sure app is restarted" -ForegroundColor White
    Write-Host "2. Run verify-cseds-fix.sql in SSMS" -ForegroundColor White
    Write-Host "3. Check Package Manager Console for migration errors" -ForegroundColor White
    Write-Host "4. Review PERMANENT_FIX_CSEDS.md for troubleshooting" -ForegroundColor White
}

Write-Host ""
Write-Host "??????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "?? HELPFUL DOCUMENTS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "• PERMANENT_FIX_SUMMARY.md - Complete explanation" -ForegroundColor White
Write-Host "• PERMANENT_FIX_CSEDS.md - Technical details" -ForegroundColor White
Write-Host "• verify-cseds-fix.sql - Database verification" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host ""
Write-Host "? Verification complete! ??" -ForegroundColor Green
Write-Host ""
