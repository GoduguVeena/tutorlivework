@echo off
REM TutorLiveMentor - ONE CLICK SETUP
REM Just double-click this file and I'll do everything!

title TutorLiveMentor - ONE CLICK SETUP
color 0B
cls

echo.
echo        ??????????????????????????????????????????
echo        ?                                        ?
echo        ?    TutorLiveMentor - ONE CLICK SETUP   ?  
echo        ?                                        ?
echo        ?         I'll do EVERYTHING! ??         ?
echo        ?                                        ?
echo        ??????????????????????????????????????????
echo.
echo.

REM Check if we're in the right folder
if not exist "Program.cs" (
    echo ? ERROR: Please run this from your TutorLiveMentor project folder!
    echo (The folder that contains Program.cs)
    pause
    exit
)

echo ?? Starting automatic setup...
echo.
timeout /t 2

echo ? Setting up network access...
REM Setup firewall (silent)
netsh advfirewall firewall add rule name="TutorLiveMentor HTTP" dir=in action=allow protocol=TCP localport=5000 >nul 2>&1

echo ? Finding your network details...
REM Get IP address
setlocal enabledelayedexpansion
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do (
    set "ip=%%a"
    set "ip=!ip: =!"
    if not "!ip!"=="127.0.0.1" if not "!ip!"=="" (
        set "foundip=!ip!"
        goto :gotip
    )
)
:gotip
if "%foundip%"=="" set "foundip=Check-ipconfig"

cls
echo.
echo        ?????? READY TO START! ??????
echo.
echo ================================================================
echo.
echo ? Setup complete! Your TutorLiveMentor will run on network!
echo.
echo ?? TELL EVERYONE TO USE THESE LINKS:
echo.
echo    ?? Website: http://%foundip%:5000
echo.
echo    ????? Students: http://%foundip%:5000/Student/Login
echo    ????? Faculty:  http://%foundip%:5000/Faculty/Login  
echo    ?? Register: http://%foundip%:5000/Student/Register
echo.
echo ?? Mobile users: Connect to same Wi-Fi, use above links
echo.
echo ================================================================
echo.
echo ??  Keep this window open while people use the app!
echo ??  Press Ctrl+C when you want to stop
echo.
echo ?? Starting server in 3 seconds...
timeout /t 3

REM Start the server
dotnet run --urls "http://0.0.0.0:5000"

echo.
echo Server stopped. Press any key to close...
pause >nul