using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;
using TutorLiveMentor.Hubs;
using TutorLiveMentor.Services;
using TutorLiveMentor.Middleware;
using Microsoft.AspNetCore.RateLimiting;
using System.Threading.RateLimiting;
using Microsoft.Extensions.Diagnostics.HealthChecks;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllersWithViews();

// Add SignalR for real-time updates
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = builder.Environment.IsDevelopment();
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(60);
});

// Register services
builder.Services.AddScoped<SignalRService>();
builder.Services.AddSingleton<PasswordHashService>();

// [SECURITY] Add Rate Limiting for login attempts
builder.Services.AddRateLimiter(rateLimiterOptions =>
{
    // Login rate limiting: 5 attempts per 15 minutes
    rateLimiterOptions.AddPolicy("login", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 5,
                Window = TimeSpan.FromMinutes(15),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0
            }));

    // API rate limiting: 100 requests per minute
    rateLimiterOptions.AddPolicy("api", httpContext =>
        RateLimitPartition.GetFixedWindowLimiter(
            partitionKey: httpContext.Connection.RemoteIpAddress?.ToString() ?? "unknown",
            factory: _ => new FixedWindowRateLimiterOptions
            {
                PermitLimit = 100,
                Window = TimeSpan.FromMinutes(1),
                QueueProcessingOrder = QueueProcessingOrder.OldestFirst,
                QueueLimit = 0
            }));

    rateLimiterOptions.OnRejected = async (context, cancellationToken) =>
    {
        context.HttpContext.Response.StatusCode = StatusCodes.Status429TooManyRequests;
        await context.HttpContext.Response.WriteAsync("Too many requests. Please try again later.", cancellationToken);
    };
});

// [SECURITY] Configure secure session with Azure-compatible settings
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30); // 30 minute timeout
    options.Cookie.HttpOnly = true; // Prevent JavaScript access
    options.Cookie.IsEssential = true; // Always send cookie
    options.Cookie.Name = "TutorLiveMentor.Session";
    options.Cookie.SameSite = SameSiteMode.Lax; // [FIX] Changed from Strict to Lax for Azure compatibility
    
    // [FIX] Only require HTTPS in production, not in development
    if (builder.Environment.IsProduction())
    {
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    }
    else
    {
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    }
    
    options.Cookie.MaxAge = TimeSpan.FromHours(8); // Max session duration
});

// [SECURITY] Add anti-forgery with Azure-compatible configuration
builder.Services.AddAntiforgery(options =>
{
    // [FIX] Only require HTTPS in production
    if (builder.Environment.IsProduction())
    {
        options.Cookie.SecurePolicy = CookieSecurePolicy.Always;
    }
    else
    {
        options.Cookie.SecurePolicy = CookieSecurePolicy.SameAsRequest;
    }
    
    options.Cookie.HttpOnly = true;
    options.Cookie.SameSite = SameSiteMode.Lax; // [FIX] Changed from Strict to Lax
    options.HeaderName = "RequestVerificationToken"; // Changed to match what we send from AJAX
});

// Register AppDbContext
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

// [HEALTH] Add Health Checks for Azure deployment
builder.Services.AddHealthChecks()
    .AddDbContextCheck<AppDbContext>(
        name: "database",
        failureStatus: HealthStatus.Unhealthy,
        tags: new[] { "db", "sql" })
    .AddCheck("self", () => HealthCheckResult.Healthy("Application is running"), tags: new[] { "api" });

var app = builder.Build();

// [ADMIN SEEDER] Automatically seed default admin accounts
using (var scope = app.Services.CreateScope())
{
    var services = scope.ServiceProvider;
    var seederLogger = services.GetRequiredService<ILogger<Program>>();
    
    try
    {
        var context = services.GetRequiredService<AppDbContext>();
        
        // Ensure database is created (for first-time deployment)
        await context.Database.MigrateAsync();
        
        // Seed default admin accounts
        await AdminSeeder.SeedDefaultAdmins(context, seederLogger);
    }
    catch (Exception ex)
    {
        seederLogger.LogError(ex, "An error occurred while seeding the database.");
    }
}

// [SECURITY] Configure the HTTP request pipeline with security
if (!app.Environment.IsDevelopment())
{
    // Production error handling - don't expose details
    app.UseExceptionHandler("/Home/Error");
    app.UseStatusCodePagesWithReExecute("/Home/Error/{0}");
    
    // [SECURITY] HSTS: Force HTTPS for 1 year
    app.UseHsts();
}
else
{
    // Development: Show detailed errors
    app.UseDeveloperExceptionPage();
}

// [FIX] Only force HTTPS redirect in production
// Azure handles HTTPS termination at the load balancer
if (!app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

// [SECURITY] Add custom security headers middleware
app.UseSecurityHeaders();

app.UseStaticFiles();

// [SECURITY] Enable rate limiting
app.UseRateLimiter();

app.UseRouting();

// Session MUST come before Authorization
app.UseSession();

app.UseAuthorization();

// [HEALTH] Map Health Check Endpoints
// Basic health check - returns 200 OK if app is running
app.MapHealthChecks("/health");

// Detailed health check - shows status of each component (database, etc.)
app.MapHealthChecks("/health/ready", new Microsoft.AspNetCore.Diagnostics.HealthChecks.HealthCheckOptions
{
    Predicate = _ => true,
    ResponseWriter = async (context, report) =>
    {
        context.Response.ContentType = "application/json";
        var result = System.Text.Json.JsonSerializer.Serialize(new
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

// Map SignalR hub
app.MapHub<SelectionHub>("/selectionHub");

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Log startup information
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("========================================");
logger.LogInformation("TutorLiveMentor Server Starting...");
logger.LogInformation("Environment: {Environment}", app.Environment.EnvironmentName);
logger.LogInformation("========================================");
logger.LogInformation("[SECURITY] HTTPS Redirect: {Status}", app.Environment.IsProduction() ? "ENABLED" : "DISABLED (Development)");
logger.LogInformation("[SECURITY] HSTS: {Status}", app.Environment.IsProduction() ? "ENABLED" : "DISABLED (Development)");
logger.LogInformation("[SECURITY] Rate Limiting: ENABLED");
logger.LogInformation("[SECURITY] Secure Sessions: ENABLED");
logger.LogInformation("[SECURITY] Security Headers: ENABLED");
logger.LogInformation("[SECURITY] Anti-CSRF: ENABLED");
logger.LogInformation("[HEALTH] Health Checks: ENABLED at /health and /health/ready");
logger.LogInformation("[SIGNALR] Hub available at: /selectionHub");
logger.LogInformation("[ADMIN] Default admin accounts created (if needed)");
logger.LogInformation("========================================");

app.Run();
