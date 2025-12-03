# ============================================================================
# FIX ALL HARDCODED CSE(DS) QUERIES IN ADMINCONTROLLER
# ============================================================================
# This script replaces ALL remaining hardcoded "CSE(DS)" queries with
# normalized CSEDS format using DepartmentNormalizer
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "FIXING ALL HARDCODED CSE(DS) QUERIES" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""

$file = "Controllers\AdminController.cs"

if (!(Test-Path $file)) {
    Write-Host "ERROR: $file not found!" -ForegroundColor Red
    exit 1
}

Write-Host "Reading $file..." -ForegroundColor Yellow
$content = Get-Content $file -Raw

Write-Host "Applying fixes..." -ForegroundColor Yellow

# Fix 1: Line 242 - GetDashboardStats facultyCount
$content = $content -replace '(var facultyCount = await _context\.Faculties\s+)\.Where\(f => f\.Department == "CSE\(DS\)"\)', '$1.Where(f => f.Department == normalizedDept)'

# Fix 2: Line 246 - GetDashboardStats subjectsCount  
$content = $content -replace '(var subjectsCount = await _context\.Subjects\s+)\.Where\(s => s\.Department == "CSE\(DS\)"\)', '$1.Where(s => s.Department == normalizedDept)'

# Fix 3: Line 251 - GetDashboardStats enrollmentsCount
$content = $content -replace '(\.Where\(se => se\.Student\.Department == )"CSE\(DS\)"\)', '$1normalizedDept)'

# Fix 4: Line 285 - ManageCSEDSFaculty AvailableSubjects (already has OR - good)
# Skip this one, it already handles both formats

# Fix 5: Line 308 - ManageSubjectAssignments AvailableFaculty (already has OR - good)
# Skip this one too

# Fix 6: Line 362 - AssignFacultyToSubject Department assignment
$content = $content -replace '(Department = )"CSE\(DS\)"(,\s+// Changed from "CSEDS")', '$1normalizedDept$2'

# Fix 7: Line 555 - GetSubjectsWithAssignments - change to normalizedDept
$content = $content -replace '(var subjects = await _context\.Subjects\s+)\.Where\(s => s\.Department == "CSEEDS" \|\| s\.Department == "CSE\(DS\)"\)', '$1.Where(s => s.Department == normalizedDept)'

# Fix 8: Line 565 - GetSubjectsWithAssignments assignedFaculty query
$content = $content -replace '(\.Where\(a => a\.SubjectId == s\.SubjectId &&\s+a\.Faculty\.Department == )"CSE\(DS\)"\)', '$1normalizedDept)'

# Fix 9: Line 612 - GetSubjectFacultyMappings subjects query
$content = $content -replace '(// First get all CSEDS subjects\s+var subjects = await _context\.Subjects\s+)\.Where\(s => s\.Department == "CSEEDS" \|\| s\.Department == "CSE\(DS\)"\)', '$1.Where(s => s.Department == normalizedDept)'

# Now add normalizedDept variable to methods that need it
# Fix GetDashboardStats - add var at the beginning
$content = $content -replace '(public async Task<IActionResult> GetDashboardStats\(\)\s+\{\s+try\s+\{)', '$1' + "`n                var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");`n"

# Fix AssignFacultyToSubject - add var at beginning of try block
$content = $content -replace '(public async Task<IActionResult> AssignFacultyToSubject\(\[FromBody\] FacultySubjectAssignmentRequest request\)\s+\{[^}]+try\s+\{)', '$1' + "`n                var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");`n"

# Fix GetSubjectsWithAssignments - add var at beginning
$content = $content -replace '(private async Task<List<SubjectDetailDto>> GetSubjectsWithAssignments\(\)\s+\{)', '$1' + "`n            var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");`n"

# Fix GetSubjectFacultyMappings - add var at beginning  
$content = $content -replace '(private async Task<List<SubjectFacultyMappingDto>> GetSubjectFacultyMappings\(\)\s+\{)', '$1' + "`n            var normalizedDept = DepartmentNormalizer.Normalize(`"CSE(DS)`");`n"

Write-Host "Writing changes to $file..." -ForegroundColor Yellow
Set-Content $file $content

Write-Host ""
Write-Host "============================================================================" -ForegroundColor Green
Write-Host "FIXES APPLIED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "============================================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Fixed methods:" -ForegroundColor White
Write-Host "  1. GetDashboardStats - stats queries" -ForegroundColor Gray
Write-Host "  2. AssignFacultyToSubject - department assignment" -ForegroundColor Gray
Write-Host "  3. GetSubjectsWithAssignments - subject queries" -ForegroundColor Gray
Write-Host "  4. GetSubjectFacultyMappings - mapping queries" -ForegroundColor Gray
Write-Host ""
Write-Host "NEXT STEPS:" -ForegroundColor Cyan
Write-Host "  1. STOP the application (Shift+F5)" -ForegroundColor White
Write-Host "  2. BUILD the solution (Ctrl+Shift+B)" -ForegroundColor White
Write-Host "  3. Check for errors" -ForegroundColor White
Write-Host "  4. START the application (F5)" -ForegroundColor White
Write-Host "  5. Test ManageSubjectAssignments page" -ForegroundColor White
Write-Host ""
Write-Host "============================================================================" -ForegroundColor Cyan
