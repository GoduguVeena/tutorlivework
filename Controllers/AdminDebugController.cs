using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;

namespace TutorLiveMentor.Controllers
{
    public class AdminDebugController : Controller
    {
        private readonly AppDbContext _context;

        public AdminDebugController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Debug method to show all unique department names (for troubleshooting)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> DepartmentAnalysis()
        {
            var studentDepts = await _context.Students.Select(s => s.Department).Distinct().ToListAsync();
            var facultyDepts = await _context.Faculties.Select(f => f.Department).Distinct().ToListAsync();
            var subjectDepts = await _context.Subjects.Select(s => s.Department).Distinct().ToListAsync();
            var adminDepts = await _context.Admins.Select(a => a.Department).Distinct().ToListAsync();

            var debugInfo = new
            {
                StudentDepartments = studentDepts,
                FacultyDepartments = facultyDepts,
                SubjectDepartments = subjectDepts,
                AdminDepartments = adminDepts,
                StudentCounts = await Task.WhenAll(studentDepts.Select(async d => new { 
                    Department = d, 
                    Count = await _context.Students.CountAsync(s => s.Department == d)
                })),
                FacultyCounts = await Task.WhenAll(facultyDepts.Select(async d => new { 
                    Department = d, 
                    Count = await _context.Faculties.CountAsync(f => f.Department == d)
                })),
                SubjectCounts = await Task.WhenAll(subjectDepts.Select(async d => new { 
                    Department = d, 
                    Count = await _context.Subjects.CountAsync(s => s.Department == d)
                }))
            };

            return Json(debugInfo);
        }
    }
}