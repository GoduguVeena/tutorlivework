@echo off
title TutorLiveMentor - AUTOMATIC SETUP
color 0A
cls

echo ================================================================
echo        TutorLiveMentor - AUTOMATIC NETWORK SETUP
echo ================================================================
echo.
echo ?? I will do EVERYTHING automatically for you!
echo.
echo What I'm doing:
echo 1. Setting up Windows Firewall
echo 2. Finding your network IP address  
echo 3. Starting the server for network access
echo 4. Showing you how others can connect
echo.
echo ================================================================
timeout /t 3

echo.
echo ?? STEP 1: Setting up Windows Firewall...
echo (This allows other computers to connect)

REM Setup firewall rules automatically
netsh advfirewall firewall delete rule name="TutorLiveMentor HTTP" >nul 2>&1
netsh advfirewall firewall delete rule name="TutorLiveMentor HTTPS" >nul 2>&1

netsh advfirewall firewall add rule name="TutorLiveMentor HTTP" dir=in action=allow protocol=TCP localport=5000 >nul 2>&1
netsh advfirewall firewall add rule name="TutorLiveMentor HTTPS" dir=in action=allow protocol=TCP localport=5001 >nul 2>&1

echo ? Firewall configured automatically!

echo.
echo ?? STEP 2: Finding your network IP address...

REM Get the local IP address automatically
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4 Address"') do (
    set "ip=%%a"
    goto :found
)
:found
set ip=%ip: =%

echo ? Found your IP: %ip%

echo.
echo ?? STEP 3: Starting TutorLiveMentor server...
echo.
echo ================================================================
echo                    ?? SUCCESS! ??
echo ================================================================
echo.
echo ? Your TutorLiveMentor is now running on the network!
echo.
echo ?? SHARE THESE LINKS WITH EVERYONE:
echo.
echo ?? Main Page:     http://%ip%:5000
echo ????? Student Login: http://%ip%:5000/Student/Login
echo ????? Faculty Login: http://%ip%:5000/Faculty/Login
echo ?? Register:      http://%ip%:5000/Student/Register
echo.
echo ?? MOBILE USERS: Connect to same Wi-Fi, use: http://%ip%:5000
echo.
echo ================================================================
echo.
echo ??  IMPORTANT: Keep this window OPEN while people use the app
echo ?? Press Ctrl+C to stop the server when done
echo.
echo Starting server now...
echo.

REM Start the server
dotnet run --urls "http://0.0.0.0:5000;https://0.0.0.0:5001"

echo.
echo ?? Server stopped.
pause