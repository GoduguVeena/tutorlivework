using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;
using TutorLiveMentor.Services;
using System.Linq;
using OfficeOpenXml;
using System.Text;

namespace TutorLiveMentor.Controllers
{
    public class AdminController : Controller
    {
        private readonly AppDbContext _context;
        private readonly SignalRService _signalRService;

        public AdminController(AppDbContext context, SignalRService signalRService)
        {
            _context = context;
            _signalRService = signalRService;
        }

        /// <summary>
        /// Helper method to check if department is CSEDS (handles specific variations only)
        /// This method is for in-memory use only, not for LINQ queries
        /// </summary>
        private bool IsCSEDSDepartment(string department)
        {
            if (string.IsNullOrEmpty(department)) return false;
            
            // Normalize the department string
            var normalizedDept = department.ToUpper().Replace("(", "").Replace(")", "").Replace(" ", "").Replace("-", "").Trim();
            
            // Only match specific CSEDS variations: "CSEDS" and "CSE(DS)"
            return normalizedDept == "CSEDS" || normalizedDept == "CSEDS"; // CSE(DS) becomes CSEDS after normalization
        }

        [HttpGet]
        public IActionResult Login()
        {
            return View();
        }

        [HttpPost]
        public async Task<IActionResult> Login(AdminLoginViewModel model)
        {
            if (!ModelState.IsValid)
                return View(model);

            try
            {
                // Find admin with matching credentials in database
                var admin = await _context.Admins
                    .FirstOrDefaultAsync(a => a.Email == model.Email && a.Password == model.Password);

                if (admin == null)
                {
                    ModelState.AddModelError("", "Invalid admin credentials!");
                    return View(model);
                }

                // Clear any existing session
                HttpContext.Session.Clear();

                // Store admin information in session
                HttpContext.Session.SetInt32("AdminId", admin.AdminId);
                HttpContext.Session.SetString("AdminEmail", admin.Email);
                HttpContext.Session.SetString("AdminDepartment", admin.Department);

                // Force session to be saved immediately
                await HttpContext.Session.CommitAsync();

                // Notify system of admin login
                await _signalRService.NotifyUserActivity(admin.Email, "Admin", "Logged In", $"{admin.Department} department administrator logged into the system");

                // Redirect to department-specific dashboard based on department
                if (IsCSEDSDepartment(admin.Department))
                {
                    return RedirectToAction("CSEDSDashboard");
                }
                else
                {
                    return RedirectToAction("MainDashboard");
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", $"Login error: {ex.Message}");
                return View(model);
            }
        }

        [HttpGet]
        public IActionResult MainDashboard()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");

            if (adminId == null)
            {
                TempData["ErrorMessage"] = "Please login to access the admin dashboard.";
                return RedirectToAction("Login");
            }

            ViewBag.AdminId = adminId;
            ViewBag.AdminEmail = HttpContext.Session.GetString("AdminEmail");
            ViewBag.AdminDepartment = HttpContext.Session.GetString("AdminDepartment");

            return View();
        }

        /// <summary>
        /// CSEDS Department-specific dashboard with enhanced faculty and subject management
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> CSEDSDashboard()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            var department = HttpContext.Session.GetString("AdminDepartment");

            if (adminId == null || !IsCSEDSDepartment(department))
            {
                TempData["ErrorMessage"] = "Access denied. CSEDS department access only.";
                return RedirectToAction("Login");
            }

            // Get comprehensive CSEDS data - only match "CSEDS" and "CSE(DS)"
            var viewModel = new CSEDSDashboardViewModel
            {
                AdminEmail = HttpContext.Session.GetString("AdminEmail") ?? "",
                AdminDepartment = department ?? "",

                // Count only CSEDS department data - exact matches only
                CSEDSStudentsCount = await _context.Students
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .CountAsync(),

                CSEDSFacultyCount = await _context.Faculties
                    .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                    .CountAsync(),

                CSEDSSubjectsCount = await _context.Subjects
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .CountAsync(),

                CSEDSEnrollmentsCount = await _context.StudentEnrollments
                    .Include(se => se.Student)
                    .Where(se => se.Student.Department == "CSEDS" || se.Student.Department == "CSE(DS)")
                    .CountAsync(),

                // Get recent CSEDS students
                RecentStudents = await _context.Students
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .OrderByDescending(s => s.Id)
                    .Take(5)
                    .Select(s => new StudentActivityDto
                    {
                        FullName = s.FullName,
                        Email = s.Email,
                        Department = s.Department,
                        Year = s.Year
                    })
                    .ToListAsync(),

                // Get recent CSEDS enrollments
                RecentEnrollments = await _context.StudentEnrollments
                    .Include(se => se.Student)
                    .Include(se => se.AssignedSubject)
                        .ThenInclude(a => a.Subject)
                    .Include(se => se.AssignedSubject)
                        .ThenInclude(a => a.Faculty)
                    .Where(se => se.Student.Department == "CSEDS" || se.Student.Department == "CSE(DS)")
                    .OrderByDescending(se => se.StudentEnrollmentId)
                    .Take(10)
                    .Select(se => new EnrollmentActivityDto
                    {
                        StudentName = se.Student.FullName,
                        SubjectName = se.AssignedSubject.Subject.Name,
                        FacultyName = se.AssignedSubject.Faculty.Name,
                        EnrollmentDate = DateTime.Now
                    })
                    .ToListAsync(),

                // Get all department faculty for management
                DepartmentFaculty = await _context.Faculties
                    .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                    .OrderBy(f => f.Name)
                    .ToListAsync(),

                // Get all department subjects for management
                DepartmentSubjects = await _context.Subjects
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .OrderBy(s => s.Year)
                    .ThenBy(s => s.Name)
                    .ToListAsync(),

                // Get subject-faculty mappings
                SubjectFacultyMappings = await GetSubjectFacultyMappings()
            };

            return View(viewModel);
        }

        /// <summary>
        /// Get comprehensive faculty management view
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ManageCSEDSFaculty()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            var viewModel = new FacultyManagementViewModel
            {
                DepartmentFaculty = await GetFacultyWithAssignments(),
                AvailableSubjects = await _context.Subjects
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .OrderBy(s => s.Year)
                    .ThenBy(s => s.Name)
                    .ToListAsync()
            };

            return View(viewModel);
        }

        /// <summary>
        /// Get subject-faculty assignment management view
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ManageSubjectAssignments()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            var viewModel = new SubjectManagementViewModel
            {
                DepartmentSubjects = await GetSubjectsWithAssignments(),
                AvailableFaculty = await _context.Faculties
                    .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                    .OrderBy(f => f.Name)
                    .ToListAsync()
            };

            return View(viewModel);
        }

        /// <summary>
        /// Assign faculty to subject
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> AssignFacultyToSubject([FromBody] FacultySubjectAssignmentRequest request)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            try
            {
                // Verify subject belongs to CSEDS department
                var subject = await _context.Subjects
                    .FirstOrDefaultAsync(s => s.SubjectId == request.SubjectId && 
                                            (s.Department == "CSEDS" || s.Department == "CSE(DS)"));

                if (subject == null)
                    return BadRequest("Subject not found or does not belong to CSEDS department");

                // Verify faculty belongs to CSEDS department
                var faculty = await _context.Faculties
                    .Where(f => request.FacultyIds.Contains(f.FacultyId) && 
                              (f.Department == "CSEDS" || f.Department == "CSE(DS)"))
                    .ToListAsync();

                if (faculty.Count != request.FacultyIds.Count)
                    return BadRequest("One or more faculty members not found or do not belong to CSEDS department");

                // Remove existing assignments for this subject
                var existingAssignments = await _context.AssignedSubjects
                    .Where(a => a.SubjectId == request.SubjectId)
                    .ToListAsync();

                _context.AssignedSubjects.RemoveRange(existingAssignments);

                // Create new assignments
                foreach (var facultyId in request.FacultyIds)
                {
                    var assignedSubject = new AssignedSubject
                    {
                        FacultyId = facultyId,
                        SubjectId = request.SubjectId,
                        Department = "CSEDS",
                        Year = subject.Year,
                        SelectedCount = 0
                    };
                    _context.AssignedSubjects.Add(assignedSubject);
                }

                await _context.SaveChangesAsync();

                await _signalRService.NotifyUserActivity(
                    HttpContext.Session.GetString("AdminEmail") ?? "",
                    "Admin",
                    "Faculty Assignment Updated",
                    $"Faculty assignments updated for subject: {subject.Name}"
                );

                return Ok(new { success = true, message = "Faculty assignments updated successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error updating assignments: {ex.Message}" });
            }
        }

        /// <summary>
        /// Remove faculty assignment from subject
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> RemoveFacultyAssignment([FromBody] RemoveFacultyAssignmentRequest request)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            try
            {
                var assignment = await _context.AssignedSubjects
                    .Include(a => a.Subject)
                    .Include(a => a.Faculty)
                    .FirstOrDefaultAsync(a => a.AssignedSubjectId == request.AssignedSubjectId &&
                                           (a.Subject.Department == "CSEDS" || a.Subject.Department == "CSE(DS)"));

                if (assignment == null)
                    return NotFound("Assignment not found");

                // Check if there are active enrollments
                var hasEnrollments = await _context.StudentEnrollments
                    .AnyAsync(se => se.AssignedSubjectId == request.AssignedSubjectId);

                if (hasEnrollments)
                    return BadRequest(new { success = false, message = "Cannot remove assignment with active student enrollments" });

                _context.AssignedSubjects.Remove(assignment);
                await _context.SaveChangesAsync();

                await _signalRService.NotifyUserActivity(
                    HttpContext.Session.GetString("AdminEmail") ?? "",
                    "Admin",
                    "Faculty Assignment Removed",
                    $"Faculty {assignment.Faculty.Name} unassigned from subject: {assignment.Subject.Name}"
                );

                return Ok(new { success = true, message = "Faculty assignment removed successfully" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error removing assignment: {ex.Message}" });
            }
        }

        /// <summary>
        /// Get all faculty in department with their assignments
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetDepartmentFaculty()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            var faculty = await GetFacultyWithAssignments();
            return Json(new { success = true, data = faculty });
        }

        /// <summary>
        /// Get all subjects in department with their assignments
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetDepartmentSubjects()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            var subjects = await GetSubjectsWithAssignments();
            return Json(new { success = true, data = subjects });
        }

        /// <summary>
        /// Get available faculty for a specific subject
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAvailableFacultyForSubject(int subjectId)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            // Get all CSEDS faculty
            var allFaculty = await _context.Faculties
                .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                .Select(f => new { f.FacultyId, f.Name, f.Email })
                .ToListAsync();

            // Get currently assigned faculty for this subject
            var assignedFaculty = await _context.AssignedSubjects
                .Where(a => a.SubjectId == subjectId)
                .Select(a => a.FacultyId)
                .ToListAsync();

            var result = allFaculty.Select(f => new
            {
                f.FacultyId,
                f.Name,
                f.Email,
                IsAssigned = assignedFaculty.Contains(f.FacultyId)
            }).ToList();

            return Json(new { success = true, data = result });
        }

        /// <summary>
        /// Helper method to get faculty with their assignments
        /// </summary>
        private async Task<List<FacultyDetailDto>> GetFacultyWithAssignments()
        {
            // First get all CSEDS faculty
            var faculty = await _context.Faculties
                .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                .ToListAsync();

            var result = new List<FacultyDetailDto>();

            foreach (var f in faculty)
            {
                var assignedSubjects = await _context.AssignedSubjects
                    .Include(a => a.Subject)
                    .Where(a => a.FacultyId == f.FacultyId &&
                              (a.Subject.Department == "CSEDS" || a.Subject.Department == "CSE(DS)"))
                    .ToListAsync();

                var enrollmentCount = 0;
                var subjectInfos = new List<AssignedSubjectInfo>();

                foreach (var assignment in assignedSubjects)
                {
                    var enrollments = await _context.StudentEnrollments
                        .CountAsync(se => se.AssignedSubjectId == assignment.AssignedSubjectId);
                    
                    enrollmentCount += enrollments;
                    
                    subjectInfos.Add(new AssignedSubjectInfo
                    {
                        AssignedSubjectId = assignment.AssignedSubjectId,
                        SubjectId = assignment.SubjectId,
                        SubjectName = assignment.Subject.Name,
                        Year = assignment.Subject.Year,
                        Semester = assignment.Subject.Semester ?? "",
                        EnrollmentCount = enrollments
                    });
                }

                result.Add(new FacultyDetailDto
                {
                    FacultyId = f.FacultyId,
                    Name = f.Name,
                    Email = f.Email,
                    Department = f.Department,
                    AssignedSubjects = subjectInfos,
                    TotalEnrollments = enrollmentCount
                });
            }

            return result.OrderBy(f => f.Name).ToList();
        }

        /// <summary>
        /// Helper method to get subjects with their assignments
        /// </summary>
        private async Task<List<SubjectDetailDto>> GetSubjectsWithAssignments()
        {
            // First get all CSEDS subjects
            var subjects = await _context.Subjects
                .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                .ToListAsync();

            var result = new List<SubjectDetailDto>();

            foreach (var s in subjects)
            {
                var assignedFaculty = await _context.AssignedSubjects
                    .Include(a => a.Faculty)
                    .Where(a => a.SubjectId == s.SubjectId &&
                              (a.Faculty.Department == "CSEDS" || a.Faculty.Department == "CSE(DS)"))
                    .ToListAsync();

                var totalEnrollments = 0;
                var facultyInfos = new List<FacultyInfo>();

                foreach (var assignment in assignedFaculty)
                {
                    var enrollments = await _context.StudentEnrollments
                        .CountAsync(se => se.AssignedSubjectId == assignment.AssignedSubjectId);
                    
                    totalEnrollments += enrollments;
                    
                    facultyInfos.Add(new FacultyInfo
                    {
                        FacultyId = assignment.FacultyId,
                        Name = assignment.Faculty.Name,
                        Email = assignment.Faculty.Email,
                        AssignedSubjectId = assignment.AssignedSubjectId
                    });
                }

                result.Add(new SubjectDetailDto
                {
                    SubjectId = s.SubjectId,
                    Name = s.Name,
                    Department = s.Department,
                    Year = s.Year,
                    Semester = s.Semester ?? "",
                    SemesterStartDate = s.SemesterStartDate,
                    SemesterEndDate = s.SemesterEndDate,
                    AssignedFaculty = facultyInfos,
                    TotalEnrollments = totalEnrollments,
                    IsActive = s.SemesterEndDate == null || s.SemesterEndDate >= DateTime.Now
                });
            }

            return result.OrderBy(s => s.Year).ThenBy(s => s.Name).ToList();
        }

        /// <summary>
        /// Helper method to get subject-faculty mappings
        /// </summary>
        private async Task<List<SubjectFacultyMappingDto>> GetSubjectFacultyMappings()
        {
            // First get all CSEDS subjects
            var subjects = await _context.Subjects
                .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                .ToListAsync();

            var result = new List<SubjectFacultyMappingDto>();

            foreach (var s in subjects)
            {
                var assignedFaculty = await _context.AssignedSubjects
                    .Include(a => a.Faculty)
                    .Where(a => a.SubjectId == s.SubjectId &&
                              (a.Faculty.Department == "CSEDS" || a.Faculty.Department == "CSE(DS)"))
                    .ToListAsync();

                var enrollmentCount = 0;
                var facultyInfos = new List<FacultyInfo>();

                foreach (var assignment in assignedFaculty)
                {
                    var enrollments = await _context.StudentEnrollments
                        .CountAsync(se => se.AssignedSubjectId == assignment.AssignedSubjectId);
                    
                    enrollmentCount += enrollments;
                    
                    facultyInfos.Add(new FacultyInfo
                    {
                        FacultyId = assignment.FacultyId,
                        Name = assignment.Faculty.Name,
                        Email = assignment.Faculty.Email,
                        AssignedSubjectId = assignment.AssignedSubjectId
                    });
                }

                result.Add(new SubjectFacultyMappingDto
                {
                    SubjectId = s.SubjectId,
                    SubjectName = s.Name,
                    Year = s.Year,
                    Semester = s.Semester ?? "",
                    SemesterStartDate = s.SemesterStartDate,
                    SemesterEndDate = s.SemesterEndDate,
                    AssignedFaculty = facultyInfos,
                    EnrollmentCount = enrollmentCount
                });
            }

            return result.OrderBy(s => s.Year).ThenBy(s => s.SubjectName).ToList();
        }

        /// <summary>
        /// Get CSEDS department system information via AJAX
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> CSEDSSystemInfo()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            var department = HttpContext.Session.GetString("AdminDepartment");

            if (adminId == null || !IsCSEDSDepartment(department))
                return Unauthorized();

            var systemInfo = new
            {
                DatabaseStats = new
                {
                    StudentsCount = await _context.Students
                        .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                        .CountAsync(),
                    FacultiesCount = await _context.Faculties
                        .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                        .CountAsync(),
                    SubjectsCount = await _context.Subjects
                        .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                        .CountAsync(),
                    EnrollmentsCount = await _context.StudentEnrollments
                        .Include(se => se.Student)
                        .Where(se => se.Student.Department == "CSEDS" || se.Student.Department == "CSE(DS)")
                        .CountAsync()
                },
                RecentActivity = new
                {
                    RecentStudents = await _context.Students
                        .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                        .OrderByDescending(s => s.Id)
                        .Take(5)
                        .Select(s => new { s.FullName, s.Email, s.Department, s.Year })
                        .ToListAsync(),
                    RecentEnrollments = await _context.StudentEnrollments
                        .Include(se => se.Student)
                        .Include(se => se.AssignedSubject)
                            .ThenInclude(a => a.Subject)
                        .Include(se => se.AssignedSubject)
                            .ThenInclude(a => a.Faculty)
                        .Where(se => se.Student.Department == "CSEDS" || se.Student.Department == "CSE(DS)")
                        .OrderByDescending(se => se.StudentEnrollmentId)
                        .Take(10)
                        .Select(se => new { 
                            StudentName = se.Student.FullName, 
                            SubjectName = se.AssignedSubject.Subject.Name, 
                            FacultyName = se.AssignedSubject.Faculty.Name 
                        })
                        .ToListAsync()
                }
            };

            return Json(systemInfo);
        }

        [HttpPost]
        public async Task<IActionResult> AddCSEDSFaculty([FromBody] CSEDSFacultyViewModel model)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var existingFaculty = await _context.Faculties.FirstOrDefaultAsync(f => f.Email == model.Email);
            if (existingFaculty != null)
                return BadRequest("Faculty with this email already exists");

            var faculty = new Faculty
            {
                Name = model.Name,
                Email = model.Email,
                Password = model.Password,
                Department = "CSEDS"
            };

            _context.Faculties.Add(faculty);
            await _context.SaveChangesAsync();

            if (model.SelectedSubjectIds.Any())
            {
                foreach (var subjectId in model.SelectedSubjectIds)
                {
                    var assignedSubject = new AssignedSubject
                    {
                        FacultyId = faculty.FacultyId,
                        SubjectId = subjectId,
                        Department = "CSEDS",
                        Year = 1,
                        SelectedCount = 0
                    };
                    _context.AssignedSubjects.Add(assignedSubject);
                }
                await _context.SaveChangesAsync();
            }

            await _signalRService.NotifyUserActivity(HttpContext.Session.GetString("AdminEmail") ?? "", "Admin", "Faculty Added", $"New CSEDS faculty member {faculty.Name} added to the system");

            return Ok(new { success = true, message = "Faculty added successfully" });
        }

        [HttpPost]
        public async Task<IActionResult> UpdateCSEDSFaculty([FromBody] CSEDSFacultyViewModel model)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            if (!ModelState.IsValid)
                return BadRequest(ModelState);

            var faculty = await _context.Faculties
                .FirstOrDefaultAsync(f => f.FacultyId == model.FacultyId && 
                                        (f.Department == "CSEDS" || f.Department == "CSE(DS)"));

            if (faculty == null)
                return NotFound();

            faculty.Name = model.Name;
            faculty.Email = model.Email;
            if (!string.IsNullOrEmpty(model.Password))
                faculty.Password = model.Password;

            await _context.SaveChangesAsync();
            await _signalRService.NotifyUserActivity(HttpContext.Session.GetString("AdminEmail") ?? "", "Admin", "Faculty Updated", $"CSEDS faculty member {faculty.Name} information updated");

            return Ok(new { success = true, message = "Faculty updated successfully" });
        }

        [HttpPost]
        public async Task<IActionResult> DeleteCSEDSFaculty([FromBody] dynamic data)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            var facultyId = (int)data.facultyId;
            var faculty = await _context.Faculties
                .Include(f => f.AssignedSubjects)
                    .ThenInclude(a => a.Enrollments)
                .FirstOrDefaultAsync(f => f.FacultyId == facultyId && 
                                        (f.Department == "CSEDS" || f.Department == "CSE(DS)"));

            if (faculty == null)
                return NotFound();

            var hasEnrollments = faculty.AssignedSubjects?.Any(a => a.Enrollments?.Any() == true) == true;
            if (hasEnrollments)
                return BadRequest(new { success = false, message = "Cannot delete faculty with active student enrollments" });

            if (faculty.AssignedSubjects != null)
                _context.AssignedSubjects.RemoveRange(faculty.AssignedSubjects);

            _context.Faculties.Remove(faculty);
            await _context.SaveChangesAsync();
            await _signalRService.NotifyUserActivity(HttpContext.Session.GetString("AdminEmail") ?? "", "Admin", "Faculty Deleted", $"CSEDS faculty member {faculty.Name} has been deleted from the system");

            return Ok(new { success = true, message = "Faculty deleted successfully" });
        }

        [HttpGet]
        public async Task<IActionResult> ManageCSEDSSubjects()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            var subjects = await _context.Subjects
                .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                .OrderBy(s => s.Year)
                .ThenBy(s => s.Name)
                .ToListAsync();
            
            return View(subjects);
        }

        [HttpGet]
        public async Task<IActionResult> CSEDSReports()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            var viewModel = new CSEDSReportsViewModel
            {
                AvailableSubjects = await _context.Subjects
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .OrderBy(s => s.Name)
                    .ToListAsync(),
                AvailableFaculty = await _context.Faculties
                    .Where(f => f.Department == "CSEDS" || f.Department == "CSE(DS)")
                    .OrderBy(f => f.Name)
                    .ToListAsync()
            };

            return View(viewModel);
        }

        // Keep the old CSEDashboard method for backward compatibility
        [HttpGet]
        public IActionResult CSEDashboard()
        {
            return RedirectToAction("CSEDSDashboard");
        }

        [HttpGet]
        public async Task<IActionResult> Dashboard()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            if (adminId == null)
                return RedirectToAction("Login");

            var stats = new AdminDashboardViewModel
            {
                TotalStudents = await _context.Students.CountAsync(),
                TotalFaculties = await _context.Faculties.CountAsync(),
                TotalSubjects = await _context.Subjects.CountAsync(),
                TotalEnrollments = await _context.StudentEnrollments.CountAsync(),
                TotalAdmins = await _context.Admins.CountAsync()
            };

            return View(stats);
        }

        [HttpGet]
        public async Task<IActionResult> Profile()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            if (adminId == null)
                return RedirectToAction("Login");

            var admin = await _context.Admins.FindAsync(adminId.Value);
            if (admin == null)
                return NotFound();

            return View(admin);
        }

        [HttpGet]
        public async Task<IActionResult> ManageAdmins()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            if (adminId == null)
                return RedirectToAction("Login");

            var admins = await _context.Admins.OrderBy(a => a.Email).ToListAsync();
            return View(admins);
        }

        [HttpGet]
        public async Task<IActionResult> Logout()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            if (adminId != null)
            {
                var admin = await _context.Admins.FindAsync(adminId.Value);
                if (admin != null)
                {
                    await _signalRService.NotifyUserActivity(admin.Email, "Admin", "Logged Out", $"{admin.Department} department administrator logged out of the system");
                }
            }

            HttpContext.Session.Clear();
            return RedirectToAction("Login");
        }

        [HttpGet]
        public async Task<IActionResult> SystemInfo()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            if (adminId == null)
                return RedirectToAction("Login");

            var systemInfo = new
            {
                DatabaseStats = new
                {
                    StudentsCount = await _context.Students.CountAsync(),
                    FacultiesCount = await _context.Faculties.CountAsync(),
                    SubjectsCount = await _context.Subjects.CountAsync(),
                    EnrollmentsCount = await _context.StudentEnrollments.CountAsync(),
                    AdminsCount = await _context.Admins.CountAsync()
                },
                RecentActivity = new
                {
                    RecentStudents = await _context.Students.OrderByDescending(s => s.Id).Take(5).Select(s => new { s.FullName, s.Email, s.Department, s.Year }).ToListAsync(),
                    RecentEnrollments = await _context.StudentEnrollments.Include(se => se.Student).Include(se => se.AssignedSubject).ThenInclude(a => a.Subject).Include(se => se.AssignedSubject).ThenInclude(a => a.Faculty).OrderByDescending(se => se.StudentEnrollmentId).Take(10).Select(se => new { StudentName = se.Student.FullName, SubjectName = se.AssignedSubject.Subject.Name, FacultyName = se.AssignedSubject.Faculty.Name }).ToListAsync()
                }
            };

            return Json(systemInfo);
        }
    }

    /// <summary>
    /// View model for general admin dashboard statistics
    /// </summary>
    public class AdminDashboardViewModel
    {
        public int TotalStudents { get; set; }
        public int TotalFaculties { get; set; }
        public int TotalSubjects { get; set; }
        public int TotalEnrollments { get; set; }
        public int TotalAdmins { get; set; }
    }

    /// <summary>
    /// Request model for faculty-subject assignment
    /// </summary>
    public class FacultySubjectAssignmentRequest
    {
        public int SubjectId { get; set; }
        public List<int> FacultyIds { get; set; } = new List<int>();
    }

    /// <summary>
    /// Request model for removing faculty assignment
    /// </summary>
    public class RemoveFacultyAssignmentRequest
    {
        public int AssignedSubjectId { get; set; }
    }
}