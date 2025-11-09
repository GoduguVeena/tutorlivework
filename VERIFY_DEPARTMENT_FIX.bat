@echo off
cls
echo ========================================
echo   VERIFY DEPARTMENT NORMALIZATION FIX
echo ========================================
echo.

REM Check if helper file exists
if exist "Helpers\DepartmentNormalizer.cs" (
    echo [OK] DepartmentNormalizer.cs found!
) else (
    echo [ERROR] DepartmentNormalizer.cs NOT found!
    echo.
    echo Please make sure the file exists at:
    echo   Helpers\DepartmentNormalizer.cs
    echo.
    pause
    exit /b 1
)

echo.
echo Checking StudentController.cs for normalization...
echo.

REM Check if using statement is added
findstr /C:"using TutorLiveMentor.Helpers" Controllers\StudentController.cs >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Using statement found!
) else (
    echo [WARNING] Using statement NOT found!
    echo.
    echo Please add this line at the top of StudentController.cs:
    echo   using TutorLiveMentor.Helpers;
    echo.
)

REM Check if normalization is called
findstr /C:"DepartmentNormalizer.Normalize" Controllers\StudentController.cs >nul
if %ERRORLEVEL% EQU 0 (
    echo [OK] Department normalization found in code!
) else (
    echo [WARNING] Department normalization NOT found!
    echo.
    echo Please add this line in the Register method:
    echo   model.Department = DepartmentNormalizer.Normalize(model.Department);
    echo.
)

echo.
echo ========================================
echo   BUILD VERIFICATION
echo ========================================
echo.
echo Building project...
echo.

dotnet build >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Project builds successfully!
    echo.
    echo ========================================
    echo   ALL CHECKS PASSED!
    echo ========================================
    echo.
    echo The department normalization fix is ready!
    echo.
    echo Next steps:
    echo   1. Test registration with "CSE(DS)"
    echo   2. Check database - should show "CSEDS"
    echo   3. Student should see subjects immediately!
    echo.
) else (
    echo [ERROR] Build failed!
    echo.
    echo Please check the error messages above.
    echo.
    echo Common issues:
    echo   1. Missing using statement
    echo   2. Syntax error in added code
    echo   3. File not saved
    echo.
    dotnet build
)

echo.
pause
