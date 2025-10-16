# TutorLiveMentor - Local Server Startup Script
# PowerShell script for network deployment

param(
    [switch]$HttpOnly = $false,
    [int]$Port = 5000,
    [switch]$ShowFirewallInstructions = $false
)

# Set console properties
$Host.UI.RawUI.WindowTitle = "TutorLiveMentor - Local Server"

Write-Host @"
================================================================
                TutorLiveMentor - Local Server
================================================================
"@ -ForegroundColor Cyan

Write-Host ""
Write-Host "?? Detecting network configuration..." -ForegroundColor Yellow

# Get local IP address (more robust method)
$localIP = $null
$networkAdapters = @("Wi-Fi*", "Ethernet*", "Local Area Connection*")

foreach ($adapter in $networkAdapters) {
    $ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias $adapter -ErrorAction SilentlyContinue | 
          Where-Object {$_.IPAddress -notlike "169.254*" -and $_.IPAddress -ne "127.0.0.1"} | 
          Select-Object -First 1
    if ($ip) {
        $localIP = $ip.IPAddress
        break
    }
}

if (-not $localIP) {
    $localIP = (Get-NetIPAddress -AddressFamily IPv4 | 
                Where-Object {$_.IPAddress -notlike "169.254*" -and $_.IPAddress -ne "127.0.0.1"} | 
                Select-Object -First 1).IPAddress
}

if (-not $localIP) {
    $localIP = "Unable to detect IP"
    Write-Host "??  Could not detect local IP address" -ForegroundColor Red
}

Write-Host @"

================================================================
                    SERVER ACCESS INFORMATION
================================================================

?? Local Access:
   http://localhost:$Port
"@ -ForegroundColor Green

if (-not $HttpOnly) {
    Write-Host "   https://localhost:$($Port + 1)" -ForegroundColor Green
}

Write-Host @"

???  Network Access (share this with other users):
   http://$localIP`:$Port
"@ -ForegroundColor Yellow

if (-not $HttpOnly) {
    Write-Host "   https://$localIP`:$($Port + 1)" -ForegroundColor Yellow
}

Write-Host @"

?? Mobile/Tablet Access:
   Connect devices to same Wi-Fi network
   Use: http://$localIP`:$Port

================================================================
"@ -ForegroundColor Magenta

# Firewall check and instructions
Write-Host "???  Checking Windows Firewall..." -ForegroundColor Cyan

$firewallRules = Get-NetFirewallRule -DisplayName "*TutorLiveMentor*" -ErrorAction SilentlyContinue
if (-not $firewallRules) {
    Write-Host "??  Firewall rules not found. You may need to configure firewall access." -ForegroundColor Red
    
    if ($ShowFirewallInstructions) {
        Write-Host @"

?? FIREWALL SETUP INSTRUCTIONS:
   Run PowerShell as Administrator and execute:
   
   New-NetFirewallRule -DisplayName "TutorLiveMentor HTTP" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow
"@ -ForegroundColor White
        
        if (-not $HttpOnly) {
            Write-Host "   New-NetFirewallRule -DisplayName `"TutorLiveMentor HTTPS`" -Direction Inbound -Protocol TCP -LocalPort $($Port + 1) -Action Allow" -ForegroundColor White
        }
    }
} else {
    Write-Host "? Firewall rules found!" -ForegroundColor Green
}

Write-Host ""
Write-Host "?? Preparing database..." -ForegroundColor Cyan
Write-Host "Applying any pending migrations..." -ForegroundColor White

# Apply database migrations
try {
    & dotnet ef database update
    if ($LASTEXITCODE -ne 0) {
        throw "Database migration failed"
    }
    Write-Host "? Database ready!" -ForegroundColor Green
} catch {
    Write-Host ""
    Write-Host "? ERROR: Database setup failed!" -ForegroundColor Red
    Write-Host "Please ensure SQL Server/LocalDB is running." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "?? Starting TutorLiveMentor server..." -ForegroundColor Cyan
Write-Host ""

Write-Host @"
??  IMPORTANT NOTES:
   - Keep this window open while server is running
   - Press Ctrl+C to stop the server
   - Share the network IP with other users: http://$localIP`:$Port
   - Ensure all devices are on the same network

================================================================
                     SERVER STARTING...
================================================================
"@ -ForegroundColor White

# Prepare URLs
$urls = "http://0.0.0.0:$Port"
if (-not $HttpOnly) {
    $urls += ";https://0.0.0.0:$($Port + 1)"
}

# Start the application
try {
    & dotnet run --environment Production --urls $urls
} catch {
    Write-Host ""
    Write-Host "? Failed to start server!" -ForegroundColor Red
} finally {
    Write-Host ""
    Write-Host "?? Server stopped." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
}