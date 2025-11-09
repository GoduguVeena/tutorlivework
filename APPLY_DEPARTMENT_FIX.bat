@echo off
cls
echo ========================================
echo   PREVENT FUTURE CSE(DS) MISMATCH
echo ========================================
echo.
echo This will apply the department normalization fix
echo to prevent CSE(DS) vs CSEDS issues in the future.
echo.
echo What this does:
echo   1. Created: Helpers/DepartmentNormalizer.cs
echo   2. Need to edit: Controllers/StudentController.cs
echo.
echo ========================================
echo.

echo Checking files...
echo.

if exist "Helpers\DepartmentNormalizer.cs" (
    echo [OK] DepartmentNormalizer.cs created!
) else (
    echo [ERROR] DepartmentNormalizer.cs not found!
    exit /b 1
)

echo.
echo ========================================
echo   MANUAL STEPS REQUIRED:
echo ========================================
echo.
echo Please open: Controllers\StudentController.cs
echo.
echo And make these 2 changes:
echo.
echo 1. Add at the top with other usings:
echo    using TutorLiveMentor.Helpers;
echo.
echo 2. Add in Register method (after line 51):
echo    model.Department = DepartmentNormalizer.Normalize(model.Department);
echo.
echo Full instructions in:
echo    DEPARTMENT_NORMALIZATION_FIX_INSTRUCTIONS.md
echo.
echo ========================================
echo.

start notepad "DEPARTMENT_NORMALIZATION_FIX_INSTRUCTIONS.md"

echo Opening instructions file...
echo.
pause
