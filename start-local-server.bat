@echo off
title TutorLiveMentor - Local Server
color 0A

echo ================================================================
echo                TutorLiveMentor - Local Server
echo ================================================================
echo.

REM Get the local IP address
echo ?? Detecting network configuration...
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set "ip=%%a"
    goto :found
)
:found
set ip=%ip: =%

echo.
echo ================================================================
echo                    SERVER ACCESS INFORMATION
echo ================================================================
echo.
echo ?? Local Access:
echo    http://localhost:5000
echo    https://localhost:5001
echo.
echo ???  Network Access (share this with other users):
echo    http://%ip%:5000
echo    https://%ip%:5001
echo.
echo ?? Mobile/Tablet Access:
echo    Connect to same Wi-Fi and use: http://%ip%:5000
echo.
echo ================================================================

echo.
echo ?? Preparing database...
echo Applying any pending migrations...
dotnet ef database update
if %ERRORLEVEL% NEQ 0 (
    echo.
    echo ? ERROR: Database setup failed!
    echo Please ensure SQL Server/LocalDB is running.
    pause
    exit /b 1
)

echo.
echo ? Database ready!
echo.
echo ?? Starting TutorLiveMentor server...
echo.
echo ??  IMPORTANT NOTES:
echo    - Keep this window open while server is running
echo    - Press Ctrl+C to stop the server
echo    - Make sure Windows Firewall allows ports 5000 and 5001
echo.
echo ================================================================
echo                     SERVER STARTING...
echo ================================================================
echo.

REM Start the application
dotnet run --environment Production --urls "http://0.0.0.0:5000;https://0.0.0.0:5001"

echo.
echo ?? Server stopped.
pause