# ?? Azure App Service Health Check Setup Guide

## ?? Overview

Your application has **two health check endpoints** already configured:

| Endpoint | Purpose | Use in Azure |
|----------|---------|--------------|
| `/health` | Simple health check (200 OK or 503 Unavailable) | ? **Use this in Azure** |
| `/health/ready` | Detailed JSON health report with component status | ?? For monitoring dashboards |

---

## ?? Quick Setup (Azure Portal)

### Step 1: Navigate to Health Check

1. Go to [Azure Portal](https://portal.azure.com)
2. Find your App Service: **tutorlive-app** (or your app name)
3. In the left menu, scroll down to **Monitoring**
4. Click **Health check**

### Step 2: Configure Health Check

```
???????????????????????????????????????????
? Enable health check                     ?
? ? ON                                   ?
???????????????????????????????????????????
? Path                                    ?
? /health                                 ? ? Enter this
???????????????????????????????????????????
? Interval (seconds)                      ?
? 120                                     ? ? Every 2 minutes
???????????????????????????????????????????
? Unhealthy threshold                     ?
? 3                                       ? ? 3 failures = unhealthy
???????????????????????????????????????????
? Load balancing                          ?
? ? Remove unhealthy instances            ?
???????????????????????????????????????????
```

### Step 3: Save

Click **Save** at the top of the page.

? Wait 2-5 minutes for changes to take effect.

---

## ? Recommended Configuration

### **For Production (High Availability)**

```
Enable health check: ? ON
Path: /health
Interval: 120 seconds (2 minutes)
Unhealthy threshold: 3
Load balancing: ? ON (Remove unhealthy instances)
```

**Why these settings?**
- **2-minute interval**: Frequent enough to catch issues quickly, not too aggressive
- **3 failures**: Avoids false positives from temporary network hiccups
- **Load balancing**: Automatically removes failed instances from traffic

### **For Development/Testing**

```
Enable health check: ? ON
Path: /health
Interval: 300 seconds (5 minutes)
Unhealthy threshold: 5
Load balancing: ? OFF
```

**Why these settings?**
- **5-minute interval**: Less aggressive checking
- **5 failures**: More tolerance for debugging
- **Load balancing OFF**: Keep instance available for troubleshooting

---

## ?? Alternative Setup Methods

### Method 1: Azure CLI

```bash
# Enable health check
az webapp config set \
  --resource-group YourResourceGroup \
  --name tutorlive-app \
  --generic-configurations '{"healthCheckPath": "/health"}'

# Verify health check is enabled
az webapp config show \
  --resource-group YourResourceGroup \
  --name tutorlive-app \
  --query "{healthCheckPath:siteConfig.healthCheckPath}"
```

### Method 2: PowerShell

```powershell
# Set health check path
Set-AzWebApp `
  -ResourceGroupName "YourResourceGroup" `
  -Name "tutorlive-app" `
  -HealthCheckPath "/health"

# Get current health check configuration
$app = Get-AzWebApp -ResourceGroupName "YourResourceGroup" -Name "tutorlive-app"
$app.SiteConfig.HealthCheckPath
```

### Method 3: ARM Template

```json
{
  "type": "Microsoft.Web/sites",
  "apiVersion": "2021-03-01",
  "name": "tutorlive-app",
  "properties": {
    "siteConfig": {
      "healthCheckPath": "/health"
    }
  }
}
```

### Method 4: Bicep

```bicep
resource webApp 'Microsoft.Web/sites@2021-03-01' = {
  name: 'tutorlive-app'
  properties: {
    siteConfig: {
      healthCheckPath: '/health'
    }
  }
}
```

---

## ?? Testing Your Health Check

### Test 1: Manual Browser Test

**Before deploying to Azure**, test locally:

1. Start your app: `dotnet run`
2. Open browser: `https://localhost:5001/health`
3. Should see: **Healthy**

### Test 2: Detailed Health Check

1. Open browser: `https://localhost:5001/health/ready`
2. Should see JSON like this:

```json
{
  "status": "Healthy",
  "checks": [
    {
      "name": "database",
      "status": "Healthy",
      "description": "Successfully connected to SQL Server",
      "duration": 45.2
    },
    {
      "name": "self",
      "status": "Healthy",
      "description": "Application is running",
      "duration": 0.1
    }
  ],
  "totalDuration": 45.3
}
```

### Test 3: Azure Production Test

After deploying to Azure:

```bash
# Test basic health check
curl https://tutorlive-app-g5hyh0drgqfjbchf.centralindia-01.azurewebsites.net/health

# Test detailed health check
curl https://tutorlive-app-g5hyh0drgqfjbchf.centralindia-01.azurewebsites.net/health/ready
```

**Expected response codes:**
- ? `200 OK` = Healthy
- ? `503 Service Unavailable` = Unhealthy

---

## ?? Monitoring Health Check Status

### View Health Check Results

1. Go to **Azure Portal** ? Your App Service
2. Navigate to **Diagnose and solve problems**
3. Look for **Availability and Performance**
4. Check **Health Check Status**

### View Logs

```bash
# Stream logs in real-time
az webapp log tail --resource-group YourResourceGroup --name tutorlive-app

# Download logs
az webapp log download --resource-group YourResourceGroup --name tutorlive-app
```

**Look for these log entries:**
```
[HEALTH] Health Checks: ENABLED at /health and /health/ready
[HEALTH] Health check passed - Status: Healthy
```

---

## ?? What Happens When Health Check Fails?

### Automatic Actions by Azure

```
1st Failure  ? Azure logs it (no action)
2nd Failure  ? Azure logs it (no action)
3rd Failure  ? Instance marked as UNHEALTHY
              ? Removed from load balancer
              ? No traffic sent to this instance
              ? Auto-healing triggered (if configured)
```

### Auto-Healing Options

Configure auto-healing in **Azure Portal** ? **Diagnose and solve problems** ? **Auto Heal**:

```
Condition: Health check failures exceed threshold
Action: 
  ? Restart the app
  ? Recycle the app pool
  ? Run a custom action (script)
```

---

## ?? Advanced Configuration

### Custom Health Check Response Writer

Already configured in `Program.cs`:

```csharp
app.MapHealthChecks("/health/ready", new HealthCheckOptions
{
    Predicate = _ => true,
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = JsonSerializer.Serialize(new
        {
            status = report.Status.ToString(),
            checks = report.Entries.Select(e => new
            {
                name = e.Key,
                status = e.Value.Status.ToString(),
                description = e.Value.Description,
                duration = e.Value.Duration.TotalMilliseconds
            }),
            totalDuration = report.TotalDuration.TotalMilliseconds
        });
        await context.Response.WriteAsync(result);
    }
});
```

### Add More Health Checks

You can add custom health checks in `Program.cs`:

```csharp
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>(
        name: "database",
        failureStatus: HealthStatus.Unhealthy)
    .AddCheck("self", () => HealthCheckResult.Healthy("Application is running"))
    
    // Add custom checks:
    .AddCheck("storage", () => 
    {
        // Check Azure Storage connectivity
        return HealthCheckResult.Healthy("Storage accessible");
    })
    .AddCheck("external-api", async () => 
    {
        // Check external API connectivity
        using var httpClient = new HttpClient();
        var response = await httpClient.GetAsync("https://api.example.com/health");
        return response.IsSuccessStatusCode 
            ? HealthCheckResult.Healthy("External API is up") 
            : HealthCheckResult.Unhealthy("External API is down");
    });
```

---

## ?? Troubleshooting

### Issue: Health check always returns 503

**Possible causes:**

1. **Database connection failed**
   ```bash
   # Check connection string in Azure
   az webapp config connection-string list \
     --resource-group YourResourceGroup \
     --name tutorlive-app
   ```

2. **Application crashed**
   ```bash
   # Check application logs
   az webapp log tail --resource-group YourResourceGroup --name tutorlive-app
   ```

3. **Migrations not applied**
   - Run migrations manually from your GitHub Actions workflow
   - Or connect to Azure SQL and run: `dotnet ef database update`

### Issue: Health check not running

**Check if enabled:**

```bash
az webapp config show \
  --resource-group YourResourceGroup \
  --name tutorlive-app \
  --query siteConfig.healthCheckPath
```

**Should return:** `"/health"`

If it returns `null`, health check is not enabled.

### Issue: False positives (random failures)

**Solution:** Increase the unhealthy threshold:

```bash
# Portal: Increase "Unhealthy threshold" from 3 to 5
```

Or add retry logic to your health checks.

---

## ?? Best Practices

### ? DO

- ? Use `/health` endpoint for Azure health checks
- ? Set interval to 2-5 minutes in production
- ? Set unhealthy threshold to 3+ failures
- ? Enable load balancing to remove unhealthy instances
- ? Monitor health check logs regularly
- ? Test health checks before deploying

### ? DON'T

- ? Don't use complex logic in health checks (keep it fast)
- ? Don't set interval below 60 seconds (too aggressive)
- ? Don't set unhealthy threshold to 1 (too sensitive)
- ? Don't forget to test health checks locally first
- ? Don't expose sensitive data in health check responses

---

## ?? Summary

### Your Health Check Endpoints

| Endpoint | Purpose | Status Code |
|----------|---------|-------------|
| `/health` | Quick check for Azure | `200` = Healthy<br>`503` = Unhealthy |
| `/health/ready` | Detailed check for monitoring | JSON response with component status |

### Azure Configuration

```
Path: /health
Interval: 120 seconds
Unhealthy threshold: 3
Load balancing: ON
```

### Your GitHub Actions Workflow

Already configured to test health check after deployment:

```yaml
- name: Health check
  run: |
    HEALTH_URL="https://${{ env.AZURE_WEBAPP_NAME }}-g5hyh0drgqfjbchf.centralindia-01.azurewebsites.net/health"
    STATUS=$(curl -s -o /dev/null -w "%{http_code}" $HEALTH_URL)
    
    if [ "$STATUS" = "200" ]; then
      echo "SUCCESS! Application is healthy!"
    fi
```

---

## ?? You're All Set!

Your application is fully configured for Azure health checks. Just enable it in the Azure Portal and you're good to go!

**Next Steps:**
1. ? Enable health check in Azure Portal (path: `/health`)
2. ? Wait 2-5 minutes for it to activate
3. ? Test by visiting: `https://your-app.azurewebsites.net/health`
4. ? Monitor in Azure Portal under "Diagnose and solve problems"

---

**Last Updated:** 2024  
**Status:** ? Production Ready  
**Documentation:** Complete
