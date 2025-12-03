#!/usr/bin/env pwsh
# ============================================
# CSE(DS) SUBJECT MAPPING DIAGNOSTIC RUNNER
# ============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CSE(DS) SUBJECT MAPPING DIAGNOSTIC TOOL" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if diagnostic SQL file exists
$diagnosticFile = "diagnose-cseds-subject-issue.sql"
if (-not (Test-Path $diagnosticFile)) {
    Write-Host "ERROR: Diagnostic file '$diagnosticFile' not found!" -ForegroundColor Red
    Write-Host "Please make sure you're running this from the project root directory." -ForegroundColor Yellow
    exit 1
}

Write-Host "Found diagnostic file: $diagnosticFile" -ForegroundColor Green
Write-Host ""

# Get connection string from appsettings.json
$appsettingsPath = "appsettings.json"
if (Test-Path $appsettingsPath) {
    Write-Host "Reading connection string from appsettings.json..." -ForegroundColor Yellow
    $appsettings = Get-Content $appsettingsPath | ConvertFrom-Json
    $connectionString = $appsettings.ConnectionStrings.DefaultConnection
    
    if ($connectionString) {
        Write-Host "Connection string found!" -ForegroundColor Green
        Write-Host ""
        
        # Parse connection string to show server and database
        if ($connectionString -match "Server=([^;]+).*Database=([^;]+)") {
            Write-Host "Server: $($matches[1])" -ForegroundColor Cyan
            Write-Host "Database: $($matches[2])" -ForegroundColor Cyan
        }
    }
} else {
    Write-Host "WARNING: appsettings.json not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RUNNING DIAGNOSTIC QUERY" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Instructions for running the diagnostic
Write-Host "TO RUN THIS DIAGNOSTIC:" -ForegroundColor Yellow
Write-Host ""
Write-Host "OPTION 1: SQL Server Management Studio (SSMS)" -ForegroundColor Green
Write-Host "  1. Open SQL Server Management Studio" -ForegroundColor White
Write-Host "  2. Connect to your database server" -ForegroundColor White
Write-Host "  3. Open file: $diagnosticFile" -ForegroundColor White
Write-Host "  4. Press F5 to execute" -ForegroundColor White
Write-Host "  5. Review the results in the Messages and Results tabs" -ForegroundColor White
Write-Host ""

Write-Host "OPTION 2: Azure Data Studio" -ForegroundColor Green
Write-Host "  1. Open Azure Data Studio" -ForegroundColor White
Write-Host "  2. Connect to your database" -ForegroundColor White
Write-Host "  3. Open file: $diagnosticFile" -ForegroundColor White
Write-Host "  4. Click 'Run' or press F5" -ForegroundColor White
Write-Host "  5. Review the results" -ForegroundColor White
Write-Host ""

Write-Host "OPTION 3: Visual Studio" -ForegroundColor Green
Write-Host "  1. Open SQL Server Object Explorer (View > SQL Server Object Explorer)" -ForegroundColor White
Write-Host "  2. Connect to your database" -ForegroundColor White
Write-Host "  3. Right-click database > New Query" -ForegroundColor White
Write-Host "  4. Copy contents of $diagnosticFile into the query window" -ForegroundColor White
Write-Host "  5. Execute the query" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "WHAT TO LOOK FOR IN THE RESULTS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "COMMON ISSUES:" -ForegroundColor Yellow
Write-Host ""

Write-Host "1. DEPARTMENT MISMATCH" -ForegroundColor Red
Write-Host "   Students have: 'CSEDS' or 'CSE(DS)'" -ForegroundColor White
Write-Host "   Subjects have: Different value (e.g., 'CSE', 'CSEDS', etc.)" -ForegroundColor White
Write-Host "   FIX: Run the standardization script" -ForegroundColor Green
Write-Host ""

Write-Host "2. NO ASSIGNED SUBJECTS FOR YEAR III" -ForegroundColor Red
Write-Host "   The query shows 0 assigned subjects for Year 3" -ForegroundColor White
Write-Host "   FIX: Admin needs to assign subjects to faculty for Year III" -ForegroundColor Green
Write-Host ""

Write-Host "3. NO CSE(DS) SUBJECTS IN DATABASE" -ForegroundColor Red
Write-Host "   The query shows no subjects with CSE(DS) department" -ForegroundColor White
Write-Host "   FIX: Admin needs to create subjects for CSE(DS) department" -ForegroundColor Green
Write-Host ""

Write-Host "4. STUDENTS ALREADY ENROLLED" -ForegroundColor Red
Write-Host "   All available subjects are already in StudentEnrollments" -ForegroundColor White
Write-Host "   FIX: This might be correct behavior - students completed enrollment" -ForegroundColor Green
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "AFTER RUNNING THE DIAGNOSTIC" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Share the results with the developer or run the fix script:" -ForegroundColor Yellow
Write-Host "  fix-cseds-department-standardization.sql" -ForegroundColor Cyan
Write-Host ""

Write-Host "Press any key to open the diagnostic file..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# Try to open the diagnostic file
if (Get-Command "code" -ErrorAction SilentlyContinue) {
    Write-Host "Opening in VS Code..." -ForegroundColor Green
    code $diagnosticFile
} elseif (Test-Path "C:\Program Files\Microsoft SQL Server Management Studio 19\Common7\IDE\Ssms.exe") {
    Write-Host "Opening in SQL Server Management Studio..." -ForegroundColor Green
    Start-Process "C:\Program Files\Microsoft SQL Server Management Studio 19\Common7\IDE\Ssms.exe" -ArgumentList $diagnosticFile
} else {
    Write-Host "Opening in default editor..." -ForegroundColor Green
    Start-Process $diagnosticFile
}
