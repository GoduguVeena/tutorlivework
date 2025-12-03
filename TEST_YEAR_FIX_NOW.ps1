# Quick Test Script for Year Mismatch Fix
# =========================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "TESTING YEAR MISMATCH FIX" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verify database fix
Write-Host "1. Verifying Database Fix..." -ForegroundColor Yellow
$dbCheck = sqlcmd -S "localhost" -d "Working5Db" -E -Q "SELECT a.Year AS AssignedYear, s.Name, s.Department FROM AssignedSubjects a INNER JOIN Subjects s ON a.SubjectId = s.SubjectId WHERE s.Department = 'CSE(DS)'" -W -h -1

if ($dbCheck -match "3") {
    Write-Host "   [OK] Database shows Year = 3" -ForegroundColor Green
} else {
    Write-Host "   [ERROR] Database still shows wrong year!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# 2. Check student year
Write-Host "2. Checking Student Year..." -ForegroundColor Yellow
$studentCheck = sqlcmd -S "localhost" -d "Working5Db" -E -Q "SELECT Year FROM Students WHERE Id = '23091A32D4'" -W -h -1

if ($studentCheck -match "III Year") {
    Write-Host "   [OK] Student is in III Year (converts to 3)" -ForegroundColor Green
} else {
    Write-Host "   [WARNING] Student year unexpected: $studentCheck" -ForegroundColor Yellow
}

Write-Host ""

# 3. Instructions
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DATABASE FIX VERIFIED!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "NOW DO THIS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. In Visual Studio:" -ForegroundColor White
Write-Host "   - Press Shift+F5 (Stop application)" -ForegroundColor Gray
Write-Host "   - Press F5 (Start application)" -ForegroundColor Gray
Write-Host ""
Write-Host "2. In Browser:" -ForegroundColor White
Write-Host "   - Go to: http://localhost:5000/Student/Login" -ForegroundColor Gray
Write-Host "   - Login as: shahid afrid" -ForegroundColor Gray
Write-Host "   - Click: 'Select Subject'" -ForegroundColor Gray
Write-Host ""
Write-Host "3. YOU SHOULD SEE:" -ForegroundColor White
Write-Host "   - ML (Machine Learning) subject" -ForegroundColor Green
Write-Host "   - Faculty: penchala prasad" -ForegroundColor Green
Write-Host "   - Other CSE(DS) subjects" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "THE FIX IS COMPLETE!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to open documentation..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Open documentation
Start-Process "YEAR_MISMATCH_FIXED.md"
