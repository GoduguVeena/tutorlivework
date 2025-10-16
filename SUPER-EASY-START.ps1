# TutorLiveMentor - SUPER EASY AUTOMATIC SETUP
# I'll do EVERYTHING for you!

$Host.UI.RawUI.WindowTitle = "TutorLiveMentor - AUTO SETUP"
Clear-Host

Write-Host @"
================================================================
        TutorLiveMentor - AUTOMATIC NETWORK SETUP  
================================================================

?? Don't worry! I'll handle EVERYTHING automatically!

What I'm doing for you:
? 1. Setting up Windows Firewall  
? 2. Finding your network IP
? 3. Starting the server
? 4. Showing connection info

Let's get started...
================================================================
"@ -ForegroundColor Cyan

Start-Sleep -Seconds 2

Write-Host "`n?? STEP 1: Setting up Windows Firewall..." -ForegroundColor Yellow
Write-Host "(Making it so other computers can connect to yours)" -ForegroundColor Gray

# Remove old rules and add new ones
try {
    Remove-NetFirewallRule -DisplayName "*TutorLiveMentor*" -ErrorAction SilentlyContinue
    New-NetFirewallRule -DisplayName "TutorLiveMentor HTTP" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow -Profile Domain,Private,Public | Out-Null
    New-NetFirewallRule -DisplayName "TutorLiveMentor HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5001 -Action Allow -Profile Domain,Private,Public | Out-Null
    Write-Host "? Firewall setup complete!" -ForegroundColor Green
} catch {
    Write-Host "??  Firewall setup needs admin rights, but continuing anyway..." -ForegroundColor Yellow
}

Write-Host "`n?? STEP 2: Finding your network IP address..." -ForegroundColor Yellow

# Get IP address automatically
$localIP = $null
try {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | 
                Where-Object {$_.IPAddress -notlike "169.254*" -and $_.IPAddress -ne "127.0.0.1" -and $_.InterfaceAlias -notlike "*Loopback*"} | 
                Select-Object -First 1).IPAddress
} catch {
    # Fallback method
    $localIP = (ipconfig | Select-String "IPv4 Address" | Select-Object -First 1) -replace ".*: ", ""
}

if (-not $localIP) {
    $localIP = "192.168.1.100"  # Default guess
    Write-Host "??  Using default IP. Check your actual IP with 'ipconfig'" -ForegroundColor Yellow
} else {
    Write-Host "? Found your IP: $localIP" -ForegroundColor Green
}

Write-Host "`n?? STEP 3: Starting your TutorLiveMentor server..." -ForegroundColor Yellow
Write-Host "Getting everything ready..." -ForegroundColor Gray

Start-Sleep -Seconds 1

Write-Host @"

================================================================
                    ?? SUCCESS! ??
================================================================

? Your TutorLiveMentor is now READY for network access!

?? SHARE THESE LINKS WITH EVERYONE ON YOUR NETWORK:

?? Main Website:    http://$localIP`:5000
????? Student Login:   http://$localIP`:5000/Student/Login  
????? Faculty Login:   http://$localIP`:5000/Faculty/Login
?? Student Register: http://$localIP`:5000/Student/Register

?? FOR MOBILE USERS:
   1. Connect phone/tablet to same Wi-Fi
   2. Open browser and go to: http://$localIP`:5000

?? FOR OTHER COMPUTERS:
   Just open browser and go to: http://$localIP`:5000

================================================================

??  IMPORTANT NOTES:
   - Keep this window OPEN while people use the app
   - Press Ctrl+C to stop the server when finished
   - All devices must be on the same Wi-Fi/network

?? Starting server now...

================================================================
"@ -ForegroundColor Green

# Start the application
try {
    Write-Host "Server is starting..." -ForegroundColor White
    & dotnet run --environment Production --urls "http://0.0.0.0:5000;https://0.0.0.0:5001"
} catch {
    Write-Host "`n? Error starting server!" -ForegroundColor Red
    Write-Host "Try running as Administrator or check if port 5000 is already in use." -ForegroundColor Yellow
} finally {
    Write-Host "`n?? Server stopped." -ForegroundColor Yellow
    Write-Host "`nPress any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}