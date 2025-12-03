namespace TutorLiveMentor.Middleware
{
    /// <summary>
    /// Middleware to add security headers to all responses
    /// Protects against common web vulnerabilities
    /// </summary>
    public class SecurityHeadersMiddleware
    {
        private readonly RequestDelegate _next;

        public SecurityHeadersMiddleware(RequestDelegate next)
        {
            _next = next;
        }

        public async Task InvokeAsync(HttpContext context)
        {
            // X-Frame-Options: Prevents clickjacking attacks
            context.Response.Headers.Append("X-Frame-Options", "DENY");

            // X-Content-Type-Options: Prevents MIME type sniffing
            context.Response.Headers.Append("X-Content-Type-Options", "nosniff");

            // X-XSS-Protection: Enables XSS filter in older browsers
            context.Response.Headers.Append("X-XSS-Protection", "1; mode=block");

            // Referrer-Policy: Controls referrer information
            context.Response.Headers.Append("Referrer-Policy", "strict-origin-when-cross-origin");

            // Content-Security-Policy: Prevents XSS and data injection attacks
            context.Response.Headers.Append("Content-Security-Policy",
                "default-src 'self'; " +
                "script-src 'self' 'unsafe-inline' 'unsafe-eval' https://code.jquery.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; " +
                "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com https://cdnjs.cloudflare.com https://cdn.jsdelivr.net; " +
                "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; " +
                "img-src 'self' data: https:; " +
                "connect-src 'self' ws: wss:;"); // Allow WebSocket for SignalR

            // Permissions-Policy: Controls browser features
            context.Response.Headers.Append("Permissions-Policy",
                "geolocation=(), microphone=(), camera=()");

            // Remove server header (information disclosure)
            context.Response.Headers.Remove("Server");
            context.Response.Headers.Remove("X-Powered-By");

            await _next(context);
        }
    }

    /// <summary>
    /// Extension method to add security headers middleware
    /// </summary>
    public static class SecurityHeadersMiddlewareExtensions
    {
        public static IApplicationBuilder UseSecurityHeaders(this IApplicationBuilder builder)
        {
            return builder.UseMiddleware<SecurityHeadersMiddleware>();
        }
    }
}
