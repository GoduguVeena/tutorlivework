# TutorLiveMentor - Firewall Setup Script
# Run this script as Administrator

param(
    [int]$HttpPort = 5000,
    [int]$HttpsPort = 5001
)

Write-Host @"
================================================================
           TutorLiveMentor - Firewall Configuration
================================================================
"@ -ForegroundColor Cyan

# Check if running as administrator
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "? ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click on PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "? Running as Administrator" -ForegroundColor Green
Write-Host ""

# Remove existing rules (if any)
Write-Host "?? Cleaning up existing firewall rules..." -ForegroundColor Yellow
Get-NetFirewallRule -DisplayName "*TutorLiveMentor*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule -ErrorAction SilentlyContinue

# Create new firewall rules
Write-Host "?? Creating firewall rules..." -ForegroundColor Cyan

try {
    # HTTP Rule
    New-NetFirewallRule -DisplayName "TutorLiveMentor HTTP" -Direction Inbound -Protocol TCP -LocalPort $HttpPort -Action Allow -Profile Domain,Private,Public -ErrorAction Stop
    Write-Host "? HTTP port $HttpPort allowed" -ForegroundColor Green
    
    # HTTPS Rule
    New-NetFirewallRule -DisplayName "TutorLiveMentor HTTPS" -Direction Inbound -Protocol TCP -LocalPort $HttpsPort -Action Allow -Profile Domain,Private,Public -ErrorAction Stop
    Write-Host "? HTTPS port $HttpsPort allowed" -ForegroundColor Green
    
    Write-Host ""
    Write-Host @"
?? SUCCESS! Firewall configured successfully!

?? Your TutorLiveMentor application can now accept connections on:
   - Port $HttpPort (HTTP)
   - Port $HttpsPort (HTTPS)

?? Next steps:
   1. Run start-local-server.bat or start-local-server.ps1
   2. Share your server IP with other users
   3. Access from network: http://[YOUR-IP]:$HttpPort

================================================================
"@ -ForegroundColor Green
    
} catch {
    Write-Host "? ERROR: Failed to create firewall rules!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Yellow
}

Read-Host "Press Enter to exit"