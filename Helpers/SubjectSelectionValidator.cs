using TutorLiveMentor.Models;
using Microsoft.EntityFrameworkCore;

namespace TutorLiveMentor.Helpers
{
    /// <summary>
    /// Helper class to validate if student has completed all required subject selections
    /// </summary>
    public class SubjectSelectionValidator
    {
        private readonly AppDbContext _context;

        public SubjectSelectionValidator(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Check if student has completed all required subject selections
        /// </summary>
        public async Task<bool> HasCompletedAllSelections(string studentId)
        {
            var student = await _context.Students
                .Include(s => s.Enrollments)
                    .ThenInclude(e => e.AssignedSubject)
                    .ThenInclude(asub => asub.Subject)
                .FirstOrDefaultAsync(s => s.Id == studentId);

            if (student == null) return false;

            // Get year map
            var yearMap = new Dictionary<string, int> { { "I", 1 }, { "II", 2 }, { "III", 3 }, { "IV", 4 } };
            var studentYearKey = student.Year?.Replace(" Year", "")?.Trim() ?? "";
            
            if (!yearMap.TryGetValue(studentYearKey, out int studentYear))
            {
                return false;
            }

            // Get all available subjects for this student
            var availableSubjects = await _context.AssignedSubjects
                .Include(a => a.Subject)
                .Where(a => a.Year == studentYear 
                         && (a.Subject.Department == "CSEDS" || a.Subject.Department == "CSE(DS)" || a.Subject.Department == student.Department))
                .ToListAsync();

            // Filter by student's department
            var studentDepartmentNormalized = DepartmentNormalizer.Normalize(student.Department);
            availableSubjects = availableSubjects
                .Where(a => DepartmentNormalizer.Normalize(a.Subject.Department) == studentDepartmentNormalized)
                .ToList();

            // Separate by type
            var coreSubjects = availableSubjects
                .Where(s => s.Subject.SubjectType == "Core" && 
                           s.SelectedCount < (s.Subject.MaxEnrollments ?? 70))
                .GroupBy(s => s.Subject.Name)
                .ToList();

            var professionalElective1 = availableSubjects
                .Where(s => s.Subject.SubjectType == "ProfessionalElective1")
                .ToList();

            var professionalElective2 = availableSubjects
                .Where(s => s.Subject.SubjectType == "ProfessionalElective2")
                .ToList();

            var professionalElective3 = availableSubjects
                .Where(s => s.Subject.SubjectType == "ProfessionalElective3")
                .ToList();

            // Filter out full electives
            professionalElective1 = FilterByMaxEnrollments(professionalElective1);
            professionalElective2 = FilterByMaxEnrollments(professionalElective2);
            professionalElective3 = FilterByMaxEnrollments(professionalElective3);

            // Get student enrollments
            var studentEnrollments = student.Enrollments?.Select(e => e.AssignedSubject.Subject.SubjectType).ToList() ?? new List<string>();
            var enrolledSubjectNames = student.Enrollments?.Select(e => e.AssignedSubject.Subject.Name).ToList() ?? new List<string>();

            // Check core subjects - must select all available core subjects
            foreach (var coreGroup in coreSubjects)
            {
                if (!enrolledSubjectNames.Contains(coreGroup.Key))
                {
                    return false; // Haven't selected this core subject
                }
            }

            // Check professional electives - must select one from each available category
            if (professionalElective1.Any() && !studentEnrollments.Contains("ProfessionalElective1"))
            {
                return false; // Haven't selected PE1
            }

            if (professionalElective2.Any() && !studentEnrollments.Contains("ProfessionalElective2"))
            {
                return false; // Haven't selected PE2
            }

            if (professionalElective3.Any() && !studentEnrollments.Contains("ProfessionalElective3"))
            {
                return false; // Haven't selected PE3
            }

            return true; // All selections complete
        }

        /// <summary>
        /// Helper method to filter subjects by MaxEnrollments limit
        /// </summary>
        private List<AssignedSubject> FilterByMaxEnrollments(List<AssignedSubject> subjects)
        {
            var filtered = new List<AssignedSubject>();
            foreach (var subject in subjects)
            {
                if (subject.Subject.MaxEnrollments.HasValue)
                {
                    // Check if subject has reached its limit
                    if (subject.SelectedCount < subject.Subject.MaxEnrollments.Value)
                    {
                        filtered.Add(subject);
                    }
                }
                else
                {
                    // No limit, add it
                    filtered.Add(subject);
                }
            }
            return filtered;
        }
    }
}
