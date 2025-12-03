using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;
using TutorLiveMentor.Services;

namespace TutorLiveMentor.Controllers
{
    /// <summary>
    /// Helper methods for AdminController dashboard updates
    /// </summary>
    public partial class AdminController
    {
        /// <summary>
        /// Broadcast dashboard statistics update via SignalR to all admin dashboards
        /// </summary>
        private async Task BroadcastDashboardUpdate(string message)
        {
            try
            {
                var studentsCount = await _context.Students
                    .Where(s => s.Department == "CSE(DS)" || s.Department == "CSEDS")
                    .CountAsync();

                var facultyCount = await _context.Faculties
                    .Where(f => f.Department == "CSE(DS)" || f.Department == "CSEDS")
                    .CountAsync();

                var subjectsCount = await _context.Subjects
                    .Where(s => s.Department == "CSE(DS)" || s.Department == "CSEDS")
                    .CountAsync();

                var enrollmentsCount = await _context.StudentEnrollments
                    .Include(se => se.Student)
                    .Where(se => se.Student.Department == "CSE(DS)" || se.Student.Department == "CSEDS")
                    .CountAsync();

                await _signalRService.NotifyDashboardStatsUpdated(
                    studentsCount,
                    facultyCount,
                    subjectsCount,
                    enrollmentsCount,
                    message
                );
                
                Console.WriteLine($"?? Dashboard stats broadcasted: Students={studentsCount}, Faculty={facultyCount}, Subjects={subjectsCount}, Enrollments={enrollmentsCount}");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"? Error broadcasting dashboard update: {ex.Message}");
            }
        }
    }
}
