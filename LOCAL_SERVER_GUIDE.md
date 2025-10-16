# ?? TutorLiveMentor - Local Server Deployment Guide

## ?? Quick Start (3 Steps)

### **Step 1: Configure Windows Firewall (Run as Administrator)**
```powershell
# Right-click PowerShell, select "Run as Administrator"
.\setup-firewall.ps1
```
**OR manually:**
```powershell
New-NetFirewallRule -DisplayName "TutorLiveMentor HTTP" -Direction Inbound -Protocol TCP -LocalPort 5000 -Action Allow
New-NetFirewallRule -DisplayName "TutorLiveMentor HTTPS" -Direction Inbound -Protocol TCP -LocalPort 5001 -Action Allow
```

### **Step 2: Start Your Server**
**Choose one option:**

**Option A: Windows Batch Script**
```cmd
start-local-server.bat
```

**Option B: PowerShell Script**
```powershell
.\start-local-server.ps1
```

**Option C: Manual Command**
```cmd
dotnet run --urls "http://0.0.0.0:5000;https://0.0.0.0:5001"
```

### **Step 3: Find Your Server IP**
```cmd
ipconfig
```
Look for "IPv4 Address" under your active network adapter (e.g., `192.168.1.100`)

## ?? Network Access

### **Server URLs:**
- **Local**: `http://localhost:5000`
- **Network**: `http://[YOUR-SERVER-IP]:5000`
- **Example**: `http://192.168.1.100:5000`

### **Application Pages:**
| Page | URL Path | Purpose |
|------|----------|---------|
| Home | `/` | Landing page |
| Student Login | `/Student/Login` | Student authentication |
| Student Register | `/Student/Register` | New student registration |
| Faculty Login | `/Faculty/Login` | Faculty authentication |
| Select Subject | `/Student/SelectSubject` | Subject enrollment |

### **Complete Access URLs Example:**
If your server IP is `192.168.1.100`:
- **Student Login**: `http://192.168.1.100:5000/Student/Login`
- **Student Register**: `http://192.168.1.100:5000/Student/Register`
- **Faculty Login**: `http://192.168.1.100:5000/Faculty/Login`

## ?? Device Access Guide

### **Desktop Computers:**
1. Connect to same network as server
2. Open web browser
3. Navigate to: `http://[SERVER-IP]:5000`

### **Mobile Devices:**
1. Connect to same Wi-Fi network
2. Open mobile browser
3. Navigate to: `http://[SERVER-IP]:5000`
4. Bookmark for easy access

### **Tablets:**
Same as mobile devices - the interface is responsive and works well on tablets.

## ?? Troubleshooting

### **Cannot Access from Other Devices**

**Check 1: Firewall**
```powershell
# Verify firewall rules exist
Get-NetFirewallRule -DisplayName "*TutorLiveMentor*"
```

**Check 2: Network Binding**
- Ensure server shows: `http://0.0.0.0:5000` (not `127.0.0.1`)
- Check server startup logs for binding confirmation

**Check 3: Same Network**
```cmd
# On client device, ping the server
ping [SERVER-IP]
```

### **Port Already in Use Error**
```cmd
# Check what's using port 5000
netstat -ano | findstr :5000

# Kill process if needed (replace PID)
taskkill /PID [PID] /F
```

### **Database Connection Issues**
1. Ensure SQL Server LocalDB is installed
2. Check connection string in `appsettings.json`
3. Run: `dotnet ef database update`

### **SSL/HTTPS Issues**
If HTTPS causes problems, you can use HTTP-only mode:
```cmd
dotnet run --urls "http://0.0.0.0:5000"
```

## ??? Security Considerations

### **Network Security:**
- ? Application only accessible on local network
- ? Firewall rules limit access to specific ports
- ?? No internet exposure (safe for internal use)
- ?? Consider strong passwords for all accounts

### **For Corporate Networks:**
- May require IT approval for firewall changes
- Check corporate security policies
- Consider using HTTPS in production environments

## ?? Monitoring & Maintenance

### **Server Status:**
- Keep PowerShell/Command window open while server runs
- Monitor console output for errors
- Check database connectivity regularly

### **Performance Tips:**
- Close unnecessary applications on server machine
- Ensure stable network connection
- Consider dedicated server hardware for heavy usage

### **Backup Strategy:**
```cmd
# Backup database regularly
sqlcmd -S (localdb)\MSSQLLocalDB -Q "BACKUP DATABASE TutorLiveMentorDB TO DISK='C:\Backup\TutorLiveMentor.bak'"
```

## ?? Network Configuration Examples

### **Typical Home Network Setup:**
```
Router: 192.168.1.1
Server: 192.168.1.100 (your computer)
User 1: 192.168.1.101 (laptop) ? http://192.168.1.100:5000
User 2: 192.168.1.102 (phone)  ? http://192.168.1.100:5000
User 3: 192.168.1.103 (tablet) ? http://192.168.1.100:5000
```

### **Office Network Setup:**
```
Server: 10.0.0.50 (dedicated machine)
Faculty: 10.0.0.51 ? http://10.0.0.50:5000/Faculty/Login
Students: 10.0.0.52-60 ? http://10.0.0.50:5000/Student/Login
```

## ?? User Instructions

### **For Students:**
1. Get server IP from administrator
2. Open browser and go to: `http://[SERVER-IP]:5000/Student/Register`
3. Register with college email (@rgmcet.edu.in)
4. Login and enroll in subjects

### **For Faculty:**
1. Get server IP and login credentials from administrator
2. Go to: `http://[SERVER-IP]:5000/Faculty/Login`
3. Login and manage assigned subjects

## ?? Advanced Configuration

### **Custom Ports:**
Modify `Program.cs` and update firewall rules:
```csharp
options.ListenAnyIP(8080); // Custom HTTP port
```

### **HTTPS Certificate:**
For production HTTPS, configure SSL certificate in `Program.cs`

### **Database Server:**
Update connection string for remote SQL Server:
```json
"DefaultConnection": "Server=REMOTE-SERVER;Database=TutorLiveMentorDB;User Id=username;Password=password;"
```

---

## ? Checklist

**Pre-deployment:**
- [ ] Firewall configured (ports 5000, 5001)
- [ ] Database updated (`dotnet ef database update`)
- [ ] Server IP address identified
- [ ] Network connectivity tested

**During deployment:**
- [ ] Server started successfully
- [ ] Local access confirmed (`http://localhost:5000`)
- [ ] Network access confirmed from another device
- [ ] All application features tested

**Post-deployment:**
- [ ] User instructions distributed
- [ ] Backup procedures in place
- [ ] Monitoring established

**?? Your TutorLiveMentor application is now ready for local network deployment!**