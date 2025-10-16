using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;
using TutorLiveMentor.Hubs;
using TutorLiveMentor.Services;
using System.Text;

var builder = WebApplication.CreateBuilder(args);

// Remove explicit Kestrel configuration to avoid port conflicts
// Let ASP.NET Core use the default configuration from launchSettings.json

// Add services to the container.
builder.Services.AddControllersWithViews();

// Add SignalR for real-time updates
builder.Services.AddSignalR(options =>
{
    options.EnableDetailedErrors = true;
    options.KeepAliveInterval = TimeSpan.FromSeconds(15);
    options.ClientTimeoutInterval = TimeSpan.FromSeconds(60);
});

// Register SignalR service
builder.Services.AddScoped<SignalRService>();

// Add session support
builder.Services.AddDistributedMemoryCache();
builder.Services.AddSession(options =>
{
    options.IdleTimeout = TimeSpan.FromMinutes(30);
    options.Cookie.HttpOnly = true;
    options.Cookie.IsEssential = true;
    options.Cookie.Name = "TutorLiveMentor.Session";
    options.Cookie.SameSite = SameSiteMode.Lax;
});

// Register your AppDbContext and connection string
builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection")));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    app.UseHsts(); // Add HSTS for production
}

// Optional: Force HTTPS redirect (comment out if you only want HTTP)
// app.UseHttpsRedirection();

app.UseStaticFiles();

// Enable session middleware BEFORE routing and authorization
app.UseSession();

app.UseRouting();
app.UseAuthorization();

// Map SignalR hub
app.MapHub<SelectionHub>("/selectionHub");

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

// Log the URLs the application is listening on
var logger = app.Services.GetRequiredService<ILogger<Program>>();
logger.LogInformation("?? TutorLiveMentor Server starting with SignalR real-time support...");
logger.LogInformation("?? SignalR Hub available at: /selectionHub");

app.Run();
