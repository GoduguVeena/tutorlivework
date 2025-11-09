# ==========================================
# MIGRATE CSEDS TO CSE(DS) FORMAT
# ==========================================
# This script updates all database records from "CSEDS" to "CSE(DS)"
# to maintain consistency with the user-facing registration form
# ==========================================

Write-Host "===========================================" -ForegroundColor Cyan
Write-Host " CSEDS -> CSE(DS) Database Migration" -ForegroundColor Cyan
Write-Host "===========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will update ALL database records:" -ForegroundColor Yellow
Write-Host "  - Students with department 'CSEDS' -> 'CSE(DS)'" -ForegroundColor Yellow
Write-Host "  - Faculty with department 'CSEDS' -> 'CSE(DS)'" -ForegroundColor Yellow
Write-Host "  - Subjects with department 'CSEDS' -> 'CSE(DS)'" -ForegroundColor Yellow
Write-Host "  - Admins with department 'CSEDS' -> 'CSE(DS)'" -ForegroundColor Yellow
Write-Host "  - AssignedSubjects with department 'CSEDS' -> 'CSE(DS)'" -ForegroundColor Yellow
Write-Host "  - FacultySelectionSchedules with department 'CSEDS' -> 'CSE(DS)'" -ForegroundColor Yellow
Write-Host ""

# Get confirmation
$confirmation = Read-Host "Do you want to proceed? (yes/no)"
if ($confirmation -ne "yes") {
    Write-Host "Migration cancelled." -ForegroundColor Red
    exit
}

Write-Host ""
Write-Host "Starting migration..." -ForegroundColor Green
Write-Host ""

# Build the project first
Write-Host "[1/7] Building project..." -ForegroundColor Cyan
dotnet build --configuration Release
if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed! Please fix compilation errors first." -ForegroundColor Red
    exit 1
}

Write-Host "[2/7] Updating Students table..." -ForegroundColor Cyan
dotnet ef database update --context AppDbContext -- --sql "UPDATE Students SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"

Write-Host "[3/7] Updating Faculties table..." -ForegroundColor Cyan  
dotnet ef database update --context AppDbContext -- --sql "UPDATE Faculties SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"

Write-Host "[4/7] Updating Subjects table..." -ForegroundColor Cyan
dotnet ef database update --context AppDbContext -- --sql "UPDATE Subjects SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"

Write-Host "[5/7] Updating Admins table..." -ForegroundColor Cyan
dotnet ef database update --context AppDbContext -- --sql "UPDATE Admins SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"

Write-Host "[6/7] Updating AssignedSubjects table..." -ForegroundColor Cyan
dotnet ef database update --context AppDbContext -- --sql "UPDATE AssignedSubjects SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"

Write-Host "[7/7] Updating FacultySelectionSchedules table..." -ForegroundColor Cyan
dotnet ef database update --context AppDbContext -- --sql "UPDATE FacultySelectionSchedules SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'"

Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host " Migration Complete!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "  - All 'CSEDS' records have been updated to 'CSE(DS)'" -ForegroundColor White
Write-Host "  - New registrations will automatically use 'CSE(DS)'" -ForegroundColor White
Write-Host "  - The DepartmentNormalizer will handle any variants" -ForegroundColor White
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Test the application by logging in" -ForegroundColor White
Write-Host "  2. Register a new CSE(DS) student to verify it works" -ForegroundColor White
Write-Host "  3. Check that existing CSE(DS) students can see subjects" -ForegroundColor White
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
