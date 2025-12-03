# ============================================================================
# TEST CSEDS DASHBOARD FIX
# ============================================================================
# Run this AFTER restarting the application
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "TESTING CSEDS DASHBOARD FIX" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verify database has data
Write-Host "TEST 1: Checking database for CSEDS records..." -ForegroundColor Yellow

$query = @"
SELECT 'Students' AS TableType, COUNT(*) AS Count FROM Students WHERE Department = 'CSEDS'
UNION ALL
SELECT 'Faculty', COUNT(*) FROM Faculties WHERE Department = 'CSEDS'
UNION ALL
SELECT 'Subjects', COUNT(*) FROM Subjects WHERE Department = 'CSEDS'
UNION ALL
SELECT 'Enrollments', COUNT(*) FROM StudentEnrollments se INNER JOIN Students st ON se.StudentId = st.Id WHERE st.Department = 'CSEDS';
"@

try {
    $result = sqlcmd -S "localhost" -d "Working5Db" -E -Q $query -h -1 -W
    
    if ($result) {
        Write-Host "? Database Query Successful:" -ForegroundColor Green
        Write-Host $result
    } else {
        Write-Host "? Database query returned no results" -ForegroundColor Red
    }
} catch {
    Write-Host "? Database query failed: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan

# Test 2: Check if app is running
Write-Host "TEST 2: Checking if application is running..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:5000" -TimeoutSec 5 -UseBasicParsing -ErrorAction SilentlyContinue
    
    if ($response.StatusCode -eq 200) {
        Write-Host "? Application is running on http://localhost:5000" -ForegroundColor Green
    } else {
        Write-Host "? Application responded with status: $($response.StatusCode)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "? Application is NOT running" -ForegroundColor Red
    Write-Host "  Please start the application (F5 in Visual Studio)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan

# Instructions
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. If app is running, STOP IT (Shift+F5)" -ForegroundColor White
Write-Host "2. RESTART the application (F5)" -ForegroundColor White
Write-Host "3. Login as CSEDS Admin:" -ForegroundColor White
Write-Host "   - Email: cseds@rgmcet.edu.in" -ForegroundColor Gray
Write-Host "   - Password: Admin@123" -ForegroundColor Gray
Write-Host "4. Navigate to CSEDS Dashboard" -ForegroundColor White
Write-Host "5. VERIFY counts are NOT zero:" -ForegroundColor White
Write-Host "   ? CSE(DS) STUDENTS: 2" -ForegroundColor Green
Write-Host "   ? CSE(DS) FACULTY: 1" -ForegroundColor Green
Write-Host "   ? DATA SCIENCE SUBJECTS: 4" -ForegroundColor Green
Write-Host "   ? ACTIVE ENROLLMENTS: 1+" -ForegroundColor Green

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "IF DASHBOARD STILL SHOWS ZEROS:" -ForegroundColor Yellow
Write-Host "  1. Check browser console for errors (F12)" -ForegroundColor White
Write-Host "  2. Clear browser cache (Ctrl+Shift+Delete)" -ForegroundColor White
Write-Host "  3. Review: CSEDS_DASHBOARD_ZERO_FIX_COMPLETE.md" -ForegroundColor White
Write-Host "============================================================================" -ForegroundColor Cyan
