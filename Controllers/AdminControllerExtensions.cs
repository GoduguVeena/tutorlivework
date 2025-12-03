using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;
using TutorLiveMentor.Services;
using TutorLiveMentor.Helpers;
using Microsoft.AspNetCore.Antiforgery;

namespace TutorLiveMentor.Controllers
{
    /// <summary>
    /// Partial class extension for AdminController with missing action methods
    /// </summary>
    public partial class AdminController
    {
        /// <summary>
        /// CSEDS Reports page
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> CSEDSReports()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            var department = HttpContext.Session.GetString("AdminDepartment");

            if (adminId == null)
            {
                TempData["ErrorMessage"] = "Please login to access the reports.";
                return RedirectToAction("Login");
            }

            if (!IsCSEDSDepartment(department))
            {
                TempData["ErrorMessage"] = "Access denied. CSEDS department access only.";
                return RedirectToAction("Login");
            }

            // Get data for report filters
            var viewModel = new CSEDSReportsViewModel
            {
                AvailableYears = await _context.Subjects
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .Select(s => s.Year)
                    .Distinct()
                    .OrderBy(y => y)
                    .ToListAsync(),

                AvailableSemesters = new List<SemesterOption>
                {
                    new SemesterOption { Value = "I", Text = "Semester I (1)", NumericValue = 1 },
                    new SemesterOption { Value = "II", Text = "Semester II (2)", NumericValue = 2 }
                },

                AvailableSubjects = await _context.Subjects
                    .Where(s => s.Department == DepartmentNormalizer.Normalize("CSE(DS)"))
                    .OrderBy(s => s.Year)
                    .ThenBy(s => s.Name)
                    .ToListAsync(),

                AvailableFaculty = await _context.Faculties
                    .Where(f => f.Department == DepartmentNormalizer.Normalize("CSE(DS)"))
                    .OrderBy(f => f.Name)
                    .ToListAsync()
            };

            return View(viewModel);
        }

        /// <summary>
        /// Manage CSEDS Students page
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ManageCSEDSStudents()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            var department = HttpContext.Session.GetString("AdminDepartment");

            if (adminId == null)
            {
                TempData["ErrorMessage"] = "Please login to access student management.";
                return RedirectToAction("Login");
            }

            if (!IsCSEDSDepartment(department))
            {
                TempData["ErrorMessage"] = "Access denied. CSEDS department access only.";
                return RedirectToAction("Login");
            }

            // Get all CSEDS students with their enrollments
            var students = await _context.Students
                .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                .ToListAsync();

            var studentDetails = new List<StudentDetailDto>();

            foreach (var student in students)
            {
                var enrollments = await _context.StudentEnrollments
                    .Include(se => se.AssignedSubject)
                        .ThenInclude(a => a.Subject)
                    .Include(se => se.AssignedSubject)
                        .ThenInclude(a => a.Faculty)
                    .Where(se => se.StudentId == student.Id)
                    .ToListAsync();

                var enrolledSubjects = enrollments.Select(e => new EnrolledSubjectInfo
                {
                    SubjectName = e.AssignedSubject.Subject.Name,
                    FacultyName = e.AssignedSubject.Faculty.Name,
                    Semester = e.AssignedSubject.Subject.Semester ?? ""
                }).ToList();

                studentDetails.Add(new StudentDetailDto
                {
                    StudentId = student.Id,
                    FullName = student.FullName,
                    RegdNumber = student.RegdNumber,
                    Email = student.Email,
                    Year = student.Year,
                    Department = student.Department,
                    TotalEnrollments = enrollments.Count,
                    EnrolledSubjects = enrolledSubjects
                });
            }

            var viewModel = new StudentManagementViewModel
            {
                DepartmentStudents = studentDetails,
                AvailableYears = new List<string> { "II Year", "III Year", "IV Year" }
            };

            return View(viewModel);
        }

        /// <summary>
        /// Filter students based on criteria
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> GetFilteredStudents([FromBody] StudentFilterRequest filters)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Unauthorized();

            try
            {
                var query = _context.Students
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .AsQueryable();

                // Apply search filter
                if (!string.IsNullOrEmpty(filters.SearchText))
                {
                    var searchLower = filters.SearchText.ToLower();
                    query = query.Where(s => 
                        s.FullName.ToLower().Contains(searchLower) ||
                        s.Email.ToLower().Contains(searchLower) ||
                        s.RegdNumber.ToLower().Contains(searchLower));
                }

                // Apply year filter
                if (!string.IsNullOrEmpty(filters.Year))
                {
                    query = query.Where(s => s.Year == filters.Year);
                }

                var students = await query.ToListAsync();
                var studentDetails = new List<StudentDetailDto>();

                foreach (var student in students)
                {
                    var enrollments = await _context.StudentEnrollments
                        .Include(se => se.AssignedSubject)
                            .ThenInclude(a => a.Subject)
                        .Include(se => se.AssignedSubject)
                            .ThenInclude(a => a.Faculty)
                        .Where(se => se.StudentId == student.Id)
                        .ToListAsync();

                    // Apply enrollment filter
                    if (filters.HasEnrollments.HasValue)
                    {
                        bool hasEnrollments = enrollments.Any();
                        if (filters.HasEnrollments.Value != hasEnrollments)
                            continue;
                    }

                    var enrolledSubjects = enrollments.Select(e => new EnrolledSubjectInfo
                    {
                        SubjectName = e.AssignedSubject.Subject.Name,
                        FacultyName = e.AssignedSubject.Faculty.Name,
                        Semester = e.AssignedSubject.Subject.Semester ?? ""
                    }).ToList();

                    studentDetails.Add(new StudentDetailDto
                    {
                        StudentId = student.Id,
                        FullName = student.FullName,
                        RegdNumber = student.RegdNumber,
                        Email = student.Email,
                        Year = student.Year,
                        Department = student.Department,
                        TotalEnrollments = enrollments.Count,
                        EnrolledSubjects = enrolledSubjects
                    });
                }

                return Json(new { success = true, data = studentDetails });
            }
            catch (Exception ex)
            {
                return Json(new { success = false, message = $"Error filtering students: {ex.Message}" });
            }
        }

        /// <summary>
        /// Delete CSEDS student
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> DeleteCSEDSStudent(string id)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return Json(new { success = false, message = "Unauthorized access" });

            try
            {
                var student = await _context.Students
                    .FirstOrDefaultAsync(s => s.Id == id && 
                                            (s.Department == "CSEDS" || s.Department == "CSE(DS)"));

                if (student == null)
                    return Json(new { success = false, message = "Student not found or does not belong to your department" });

                // Delete enrollments first
                var enrollments = await _context.StudentEnrollments
                    .Where(se => se.StudentId == id)
                    .ToListAsync();

                if (enrollments.Any())
                {
                    _context.StudentEnrollments.RemoveRange(enrollments);
                }

                // Delete student
                _context.Students.Remove(student);
                await _context.SaveChangesAsync();

                await _signalRService.NotifyUserActivity(
                    HttpContext.Session.GetString("AdminEmail") ?? "",
                    "Admin",
                    "Student Deleted",
                    $"CSEDS student {student.FullName} has been deleted"
                );

                // Broadcast dashboard stats update
                await BroadcastDashboardUpdate("Student deleted");

                return Json(new { success = true, message = "Student deleted successfully" });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error deleting student: {ex.Message}");
                return Json(new { success = false, message = $"Error deleting student: {ex.Message}" });
            }
        }

        /// <summary>
        /// Add CSEDS student page
        /// </summary>
        [HttpGet]
        public IActionResult AddCSEDSStudent()
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            var viewModel = new CSEDSStudentViewModel
            {
                Department = "CSEDS", // PERMANENT FIX: Use CSEDS consistently
                IsEdit = false,
                AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" }
            };

            return View(viewModel);
        }

        /// <summary>
        /// Add CSEDS student POST action
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> AddCSEDSStudent(CSEDSStudentViewModel model)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            // Validate model
            if (!ModelState.IsValid)
            {
                model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                return View(model);
            }

            try
            {
                // Check if student with this registration number already exists
                var existingStudent = await _context.Students
                    .FirstOrDefaultAsync(s => s.RegdNumber == model.RegdNumber);

                if (existingStudent != null)
                {
                    ModelState.AddModelError("RegdNumber", "A student with this registration number already exists");
                    model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                    return View(model);
                }

                // Check if email is already used
                var existingEmail = await _context.Students
                    .FirstOrDefaultAsync(s => s.Email == model.Email);

                if (existingEmail != null)
                {
                    ModelState.AddModelError("Email", "This email is already registered");
                    model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                    return View(model);
                }

                // Create new student with normalized department
                var student = new Student
                {
                    Id = model.RegdNumber, // Use RegdNumber as ID
                    FullName = model.FullName,
                    RegdNumber = model.RegdNumber,
                    Email = model.Email,
                    Password = string.IsNullOrWhiteSpace(model.Password) ? "TutorLive123" : model.Password,
                    Year = model.Year,
                    Department = DepartmentNormalizer.Normalize(model.Department), // PERMANENT FIX: Normalize department
                    SelectedSubject = ""
                };

                _context.Students.Add(student);
                await _context.SaveChangesAsync();

                await _signalRService.NotifyUserActivity(
                    HttpContext.Session.GetString("AdminEmail") ?? "",
                    "Admin",
                    "Student Added",
                    $"New CSEDS student {student.FullName} has been added to the system"
                );

                // Broadcast dashboard stats update
                await BroadcastDashboardUpdate($"Student '{student.FullName}' added");

                TempData["SuccessMessage"] = "Student added successfully!";
                return RedirectToAction("ManageCSEDSStudents");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error adding student: {ex.Message}");
                ModelState.AddModelError("", $"Error adding student: {ex.Message}");
                model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                return View(model);
            }
        }

        /// <summary>
        /// Edit CSEDS student page
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> EditCSEDSStudent(string id)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");
            
            var student = await _context.Students
                .FirstOrDefaultAsync(s => s.Id == id && 
                                        (s.Department == "CSEDS" || s.Department == "CSE(DS)"));

            if (student == null)
            {
                TempData["ErrorMessage"] = "Student not found or does not belong to your department";
                return RedirectToAction("ManageCSEDSStudents");
            }

            var viewModel = new CSEDSStudentViewModel
            {
                StudentId = student.Id,
                FullName = student.FullName,
                RegdNumber = student.RegdNumber,
                Email = student.Email,
                Year = student.Year,
                Department = student.Department,
                IsEdit = true,
                AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" }
            };

            return View(viewModel);
        }

        /// <summary>
        /// Edit CSEDS student POST action
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> EditCSEDSStudent(CSEDSStudentViewModel model)
        {
            var department = HttpContext.Session.GetString("AdminDepartment");
            if (!IsCSEDSDepartment(department))
                return RedirectToAction("Login");

            // Validate model
            if (!ModelState.IsValid)
            {
                model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                return View(model);
            }

            try
            {
                var student = await _context.Students
                    .FirstOrDefaultAsync(s => s.Id == model.StudentId && 
                                            (s.Department == "CSEDS" || s.Department == "CSE(DS)"));

                if (student == null)
                {
                    TempData["ErrorMessage"] = "Student not found or does not belong to your department";
                    return RedirectToAction("ManageCSEDSStudents");
                }

                // Check if email is already used by another student
                var existingStudent = await _context.Students
                    .FirstOrDefaultAsync(s => s.Email == model.Email && s.Id != model.StudentId);

                if (existingStudent != null)
                {
                    ModelState.AddModelError("Email", "This email is already registered to another student");
                    model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                    return View(model);
                }

                // Update student information
                student.FullName = model.FullName;
                student.Email = model.Email;
                student.Year = model.Year;

                // Update password only if provided
                if (!string.IsNullOrWhiteSpace(model.Password))
                {
                    student.Password = model.Password;
                }

                await _context.SaveChangesAsync();

                await _signalRService.NotifyUserActivity(
                    HttpContext.Session.GetString("AdminEmail") ?? "",
                    "Admin",
                    "Student Updated",
                    $"CSEDS student {student.FullName} information has been updated"
                );

                TempData["SuccessMessage"] = "Student information updated successfully!";
                return RedirectToAction("ManageCSEDSStudents");
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error updating student: {ex.Message}");
                ModelState.AddModelError("", $"Error updating student: {ex.Message}");
                model.AvailableYears = new List<string> { "I Year", "II Year", "III Year", "IV Year" };
                return View(model);
            }
        }

        /// <summary>
        /// Manage Faculty Selection Schedule page - ENHANCED WITH DEPARTMENT-SPECIFIC ACCESS
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> ManageFacultySelectionSchedule()
        {
            var adminId = HttpContext.Session.GetInt32("AdminId");
            var department = HttpContext.Session.GetString("AdminDepartment");

            Console.WriteLine($"?? ManageFacultySelectionSchedule Access Check:");
            Console.WriteLine($"   - AdminId: {adminId}");
            Console.WriteLine($"   - Department: {department}");

            if (adminId == null)
            {
                Console.WriteLine("? Admin not logged in");
                TempData["ErrorMessage"] = "Please login to access schedule management.";
                return RedirectToAction("Login");
            }

            if (!IsCSEDSDepartment(department))
            {
                Console.WriteLine($"? Access denied - Department: {department} is not CSEDS");
                TempData["ErrorMessage"] = "Access denied. CSEDS department access only.";
                return RedirectToAction("Login");
            }

            Console.WriteLine("? Access granted - Admin is CSEDS department");

            // Use department normalizer to ensure consistent department handling
            var normalizedDept = DepartmentNormalizer.Normalize(department);
            Console.WriteLine($"?? Normalized department: {normalizedDept}");

            // Get or create schedule specifically for this admin's department
            var schedule = await _context.FacultySelectionSchedules
                .FirstOrDefaultAsync(s => s.Department == "CSEDS" || s.Department == "CSE(DS)");

            if (schedule == null)
            {
                Console.WriteLine("?? Creating new schedule for CSEDS department");
                // Create default schedule for this specific department
                schedule = new FacultySelectionSchedule
                {
                    Department = "CSEDS",
                    IsEnabled = true,
                    UseSchedule = false,
                    DisabledMessage = "Faculty selection is currently disabled. Please check back later.",
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now,
                    UpdatedBy = HttpContext.Session.GetString("AdminEmail") ?? "System"
                };
                _context.FacultySelectionSchedules.Add(schedule);
                await _context.SaveChangesAsync();
                Console.WriteLine($"? Schedule created with ID: {schedule.ScheduleId}");
            }
            else
            {
                Console.WriteLine($"?? Found existing schedule with ID: {schedule.ScheduleId}");
            }

            // Get impact statistics - ONLY for this admin's department
            var studentsCount = await _context.Students
                .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                .CountAsync();

            var subjectsCount = await _context.Subjects
                .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                .CountAsync();

            var enrollmentsCount = await _context.StudentEnrollments
                .Include(se => se.Student)
                .Where(se => se.Student.Department == "CSEDS" || se.Student.Department == "CSE(DS)")
                .CountAsync();

            Console.WriteLine($"?? Department Statistics:");
            Console.WriteLine($"   - Students: {studentsCount}");
            Console.WriteLine($"   - Subjects: {subjectsCount}");
            Console.WriteLine($"   - Enrollments: {enrollmentsCount}");

            var viewModel = new FacultySelectionScheduleViewModel
            {
                ScheduleId = schedule.ScheduleId,
                Department = schedule.Department,
                IsEnabled = schedule.IsEnabled,
                UseSchedule = schedule.UseSchedule,
                StartDateTime = schedule.StartDateTime,
                EndDateTime = schedule.EndDateTime,
                DisabledMessage = schedule.DisabledMessage,
                IsCurrentlyAvailable = schedule.IsCurrentlyAvailable,
                StatusDescription = schedule.StatusDescription,
                UpdatedAt = schedule.UpdatedAt,
                UpdatedBy = schedule.UpdatedBy,
                AffectedStudents = studentsCount,
                AffectedSubjects = subjectsCount,
                TotalEnrollments = enrollmentsCount
            };

            Console.WriteLine($"?? Current Schedule Status: {schedule.IsCurrentlyAvailable}");
            return View(viewModel);
        }

        /// <summary>
        /// Update faculty selection schedule - ENHANCED WITH DEPARTMENT-SPECIFIC CONTROL
        /// </summary>
        [HttpPost]
        public async Task<IActionResult> UpdateFacultySelectionSchedule([FromBody] FacultySelectionScheduleUpdateRequest request)
        {
            // Manual anti-forgery token validation for JSON requests
            try
            {
                await _antiforgery.ValidateRequestAsync(HttpContext);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"? Anti-forgery validation failed: {ex.Message}");
                return Json(new { success = false, message = "Security validation failed. Please refresh the page and try again." });
            }

            var adminId = HttpContext.Session.GetInt32("AdminId");
            var department = HttpContext.Session.GetString("AdminDepartment");
            var adminEmail = HttpContext.Session.GetString("AdminEmail");

            Console.WriteLine($"?? UpdateFacultySelectionSchedule Request:");
            Console.WriteLine($"   - AdminId: {adminId}");
            Console.WriteLine($"   - Department: {department}");
            Console.WriteLine($"   - Email: {adminEmail}");
            Console.WriteLine($"   - IsEnabled: {request?.IsEnabled}");
            Console.WriteLine($"   - UseSchedule: {request?.UseSchedule}");
            Console.WriteLine($"   - StartDateTime: {request?.StartDateTime}");
            Console.WriteLine($"   - EndDateTime: {request?.EndDateTime}");

            if (adminId == null)
            {
                Console.WriteLine("? Admin not logged in");
                return Json(new { success = false, message = "Please login to continue" });
            }

            if (!IsCSEDSDepartment(department))
            {
                Console.WriteLine($"? Unauthorized access - Department: {department}");
                return Json(new { success = false, message = "Unauthorized access. CSEDS department only." });
            }

            if (request == null)
            {
                Console.WriteLine("? Request is null");
                return Json(new { success = false, message = "Invalid request data" });
            }

            try
            {
                // Use department normalizer for consistent queries
                var normalizedDept = DepartmentNormalizer.Normalize(department);
                Console.WriteLine($"?? Normalized department: {normalizedDept}");

                // Find schedule specifically for this admin's department
                var schedule = await _context.FacultySelectionSchedules
                    .FirstOrDefaultAsync(s => s.Department == "CSEDS" || s.Department == "CSE(DS)");

                if (schedule == null)
                {
                    Console.WriteLine("? Schedule not found for this department");
                    return Json(new { success = false, message = "Schedule not found for your department" });
                }

                Console.WriteLine($"?? Found schedule ID: {schedule.ScheduleId} for department: {schedule.Department}");
                Console.WriteLine($"?? Current values - IsEnabled: {schedule.IsEnabled}, UseSchedule: {schedule.UseSchedule}");

                // Enhanced validation
                if (request.UseSchedule && request.StartDateTime.HasValue && request.EndDateTime.HasValue)
                {
                    if (request.EndDateTime <= request.StartDateTime)
                    {
                        Console.WriteLine("? Validation failed: End date before start date");
                        return Json(new { success = false, message = "End date must be after start date" });
                    }

                    // Check if the time window is reasonable (at least 1 hour)
                    var duration = request.EndDateTime.Value - request.StartDateTime.Value;
                    if (duration.TotalHours < 1)
                    {
                        Console.WriteLine("? Validation failed: Time window too short");
                        return Json(new { success = false, message = "Schedule window must be at least 1 hour" });
                    }
                }

                // Validate disabled message
                if (string.IsNullOrEmpty(request.DisabledMessage) || request.DisabledMessage.Trim().Length < 10)
                {
                    Console.WriteLine("? Validation failed: Disabled message too short");
                    return Json(new { success = false, message = "Disabled message must be at least 10 characters long" });
                }

                Console.WriteLine("? Validation passed - Updating schedule");

                // Update schedule properties with explicit change tracking
                var hasChanges = false;
                
                if (schedule.IsEnabled != request.IsEnabled)
                {
                    Console.WriteLine($"?? IsEnabled changing from {schedule.IsEnabled} to {request.IsEnabled}");
                    schedule.IsEnabled = request.IsEnabled;
                    hasChanges = true;
                }
                
                if (schedule.UseSchedule != request.UseSchedule)
                {
                    Console.WriteLine($"?? UseSchedule changing from {schedule.UseSchedule} to {request.UseSchedule}");
                    schedule.UseSchedule = request.UseSchedule;
                    hasChanges = true;
                }
                
                var newStartDateTime = request.UseSchedule ? request.StartDateTime : null;
                if (schedule.StartDateTime != newStartDateTime)
                {
                    Console.WriteLine($"?? StartDateTime changing from {schedule.StartDateTime} to {newStartDateTime}");
                    schedule.StartDateTime = newStartDateTime;
                    hasChanges = true;
                }
                
                var newEndDateTime = request.UseSchedule ? request.EndDateTime : null;
                if (schedule.EndDateTime != newEndDateTime)
                {
                    Console.WriteLine($"?? EndDateTime changing from {schedule.EndDateTime} to {newEndDateTime}");
                    schedule.EndDateTime = newEndDateTime;
                    hasChanges = true;
                }
                
                var trimmedMessage = request.DisabledMessage?.Trim() ?? schedule.DisabledMessage;
                if (schedule.DisabledMessage != trimmedMessage)
                {
                    Console.WriteLine($"?? DisabledMessage changing");
                    schedule.DisabledMessage = trimmedMessage;
                    hasChanges = true;
                }
                
                // Always update metadata
                schedule.UpdatedAt = DateTime.Now;
                schedule.UpdatedBy = adminEmail ?? "Unknown Admin";
                
                Console.WriteLine($"?? HasChanges: {hasChanges}");

                // Mark entity as modified to ensure EF Core tracks changes
                _context.Entry(schedule).State = EntityState.Modified;

                // Save changes with verification
                var changeCount = await _context.SaveChangesAsync();
                Console.WriteLine($"?? Database changes saved: {changeCount}");

                if (changeCount == 0 && hasChanges)
                {
                    Console.WriteLine("?? Warning: Expected changes but none were saved to database");
                    // Try to reload and check
                    await _context.Entry(schedule).ReloadAsync();
                    Console.WriteLine($"?? After reload - IsEnabled: {schedule.IsEnabled}, UseSchedule: {schedule.UseSchedule}");
                }

                Console.WriteLine("? Changes successfully processed");

                // Calculate current status
                var isCurrentlyAvailable = schedule.IsCurrentlyAvailable;
                var statusDescription = schedule.StatusDescription;

                Console.WriteLine($"?? Updated Schedule Status:");
                Console.WriteLine($"   - IsEnabled: {schedule.IsEnabled}");
                Console.WriteLine($"   - UseSchedule: {schedule.UseSchedule}");
                Console.WriteLine($"   - IsCurrentlyAvailable: {isCurrentlyAvailable}");
                Console.WriteLine($"   - StatusDescription: {statusDescription}");

                // Get affected students count
                var affectedStudentsCount = await _context.Students
                    .Where(s => s.Department == "CSEDS" || s.Department == "CSE(DS)")
                    .CountAsync();

                // Send notification
                await _signalRService.NotifyUserActivity(
                    adminEmail ?? "",
                    "Admin",
                    "Faculty Selection Schedule Updated",
                    $"CSEDS department schedule updated by {adminEmail} - IsEnabled: {schedule.IsEnabled}, Affects {affectedStudentsCount} students"
                );

                Console.WriteLine($"?? Notification sent - Affected students: {affectedStudentsCount}");

                return Json(new { 
                    success = true, 
                    message = $"Schedule updated successfully! {(changeCount > 0 ? $"Changes saved to database ({changeCount} records updated)." : "No database changes needed.")} Affects {affectedStudentsCount} CSEDS students.",
                    data = new {
                        isCurrentlyAvailable = isCurrentlyAvailable,
                        statusDescription = statusDescription,
                        isEnabled = schedule.IsEnabled,
                        useSchedule = schedule.UseSchedule,
                        affectedStudents = affectedStudentsCount,
                        updatedAt = schedule.UpdatedAt,
                        changeCount = changeCount
                    }
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"? Error updating schedule: {ex.Message}");
                Console.WriteLine($"   Stack trace: {ex.StackTrace}");
                
                var errorMessage = "Error updating schedule: ";
                if (ex.InnerException != null)
                {
                    errorMessage += ex.InnerException.Message;
                    Console.WriteLine($"   Inner exception: {ex.InnerException.Message}");
                }
                else
                {
                    errorMessage += ex.Message;
                }
                
                return Json(new { success = false, message = errorMessage });
            }
        }

        /// <summary>
        /// Get selection schedule status for a specific department - ENHANCED FOR DEPARTMENT ISOLATION
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetSelectionScheduleStatus(string department = null)
        {
            try
            {
                var adminDepartment = HttpContext.Session.GetString("AdminDepartment");
                
                // If no department specified, use admin's department
                if (string.IsNullOrEmpty(department))
                {
                    department = adminDepartment;
                }

                Console.WriteLine($"?? GetSelectionScheduleStatus Request:");
                Console.WriteLine($"   - Requested Department: {department}");
                Console.WriteLine($"   - Admin Department: {adminDepartment}");

                // Security check: Admin can only check status for their own department
                if (!string.IsNullOrEmpty(adminDepartment))
                {
                    var normalizedRequestedDept = DepartmentNormalizer.Normalize(department);
                    var normalizedAdminDept = DepartmentNormalizer.Normalize(adminDepartment);
                    
                    if (normalizedRequestedDept != normalizedAdminDept)
                    {
                        Console.WriteLine("? Access denied - Department mismatch");
                        return Json(new { 
                            success = false, 
                            message = "You can only check schedule status for your own department" 
                        });
                    }
                }

                if (!IsCSEDSDepartment(department))
                {
                    Console.WriteLine($"?? Not a CSEDS department: {department}");
                    return Json(new { 
                        isAvailable = true, 
                        message = "Faculty selection is available (not a CSEDS department)",
                        statusDescription = "Not applicable"
                    });
                }

                // Find schedule using OR condition instead of normalizer in query
                var schedule = await _context.FacultySelectionSchedules
                    .FirstOrDefaultAsync(s => s.Department == "CSEDS" || s.Department == "CSE(DS)");

                if (schedule == null)
                {
                    Console.WriteLine("?? No schedule found - Default to available");
                    return Json(new { 
                        isAvailable = true, 
                        message = "Faculty selection is currently available",
                        statusDescription = "No schedule configured"
                    });
                }

                Console.WriteLine($"?? Found schedule: IsEnabled={schedule.IsEnabled}, UseSchedule={schedule.UseSchedule}");

                // Check if enabled
                if (!schedule.IsEnabled)
                {
                    Console.WriteLine("? Schedule disabled by admin");
                    return Json(new { 
                        isAvailable = false, 
                        message = schedule.DisabledMessage,
                        statusDescription = "Disabled by administrator"
                    });
                }

                // Check if using schedule
                if (!schedule.UseSchedule)
                {
                    Console.WriteLine("? Schedule enabled - Always available");
                    return Json(new { 
                        isAvailable = true, 
                        message = "Faculty selection is currently available",
                        statusDescription = "Always Available"
                    });
                }

                // Check schedule window
                var now = DateTime.Now;
                if (schedule.StartDateTime.HasValue && schedule.EndDateTime.HasValue)
                {
                    Console.WriteLine($"?? Checking time window: {schedule.StartDateTime} to {schedule.EndDateTime}");
                    Console.WriteLine($"   Current time: {now}");
                    
                    if (now < schedule.StartDateTime.Value)
                    {
                        Console.WriteLine("? Not yet started");
                        return Json(new { 
                            isAvailable = false, 
                            message = $"Faculty selection opens on {schedule.StartDateTime.Value:MMM dd, yyyy} at {schedule.StartDateTime.Value:hh:mm tt}",
                            statusDescription = "Not Yet Started",
                            startDateTime = schedule.StartDateTime,
                            endDateTime = schedule.EndDateTime
                        });
                    }
                    else if (now > schedule.EndDateTime.Value)
                    {
                        Console.WriteLine("? Period ended");
                        return Json(new { 
                            isAvailable = false, 
                            message = "Faculty selection period has ended",
                            statusDescription = "Period Ended",
                            startDateTime = schedule.StartDateTime,
                            endDateTime = schedule.EndDateTime
                        });
                    }
                    else
                    {
                        Console.WriteLine("? Active period");
                        return Json(new { 
                            isAvailable = true, 
                            message = $"Faculty selection is available until {schedule.EndDateTime.Value:MMM dd, yyyy} at {schedule.EndDateTime.Value:hh:mm tt}",
                            statusDescription = "Active",
                            startDateTime = schedule.StartDateTime,
                            endDateTime = schedule.EndDateTime
                        });
                    }
                }

                Console.WriteLine("? Schedule enabled - Default available");
                return Json(new { 
                    isAvailable = true, 
                    message = "Faculty selection is currently available",
                    statusDescription = "Always Available"
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine($"? Error checking schedule status: {ex.Message}");
                return Json(new { 
                    isAvailable = true, 
                    message = "Faculty selection is currently available (error checking schedule)",
                    error = ex.Message
                });
            }
        }
    }

    /// <summary>
    /// Request model for student filtering
    /// </summary>
    public class StudentFilterRequest
    {
        public string? SearchText { get; set; }
        public string? Year { get; set; }
        public bool? HasEnrollments { get; set; }
    }

    /// <summary>
    /// Request model for faculty selection schedule update
    /// </summary>
    public class FacultySelectionScheduleUpdateRequest
    {
        public bool IsEnabled { get; set; }
        public bool UseSchedule { get; set; }
        public DateTime? StartDateTime { get; set; }
        public DateTime? EndDateTime { get; set; }
        public string? DisabledMessage { get; set; }
    }
}
