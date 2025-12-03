using Microsoft.EntityFrameworkCore;
using TutorLiveMentor.Models;
using TutorLiveMentor.Helpers;

namespace TutorLiveMentor.Services
{
    /// <summary>
    /// Service to ensure department names are always normalized before saving to database
    /// PERMANENT FIX for CSE(DS) department mismatch issues
    /// </summary>
    public class DepartmentNormalizationService
    {
        private readonly AppDbContext _context;

        public DepartmentNormalizationService(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Intercepts SaveChanges to normalize all department fields before saving
        /// This ensures CSEDS is always stored consistently
        /// </summary>
        public void NormalizeDepartmentsBeforeSave()
        {
            var entries = _context.ChangeTracker.Entries()
                .Where(e => e.State == EntityState.Added || e.State == EntityState.Modified);

            foreach (var entry in entries)
            {
                // Check if entity has a Department property
                var departmentProperty = entry.Properties
                    .FirstOrDefault(p => p.Metadata.Name == "Department");

                if (departmentProperty != null && departmentProperty.CurrentValue != null)
                {
                    var currentValue = departmentProperty.CurrentValue.ToString();
                    var normalizedValue = DepartmentNormalizer.Normalize(currentValue);

                    // Only update if different
                    if (currentValue != normalizedValue)
                    {
                        Console.WriteLine($"[DepartmentNormalizationService] Normalizing: '{currentValue}' ? '{normalizedValue}'");
                        departmentProperty.CurrentValue = normalizedValue;
                    }
                }
            }
        }

        /// <summary>
        /// Validates that a department name will normalize correctly
        /// </summary>
        public bool IsValidDepartment(string department)
        {
            if (string.IsNullOrWhiteSpace(department))
                return false;

            var normalized = DepartmentNormalizer.Normalize(department);
            
            // Check if it's a known department
            var validDepartments = new[]
            {
                "CSEDS", "CSE(AIML)", "CSE(CS)", "CSE(BS)", "CSE",
                "ECE", "EEE", "MECH", "CIVIL"
            };

            return validDepartments.Contains(normalized);
        }

        /// <summary>
        /// Gets all unique normalized departments from the database
        /// </summary>
        public async Task<List<string>> GetAllNormalizedDepartmentsAsync()
        {
            var studentDepts = await _context.Students
                .Select(s => s.Department)
                .Distinct()
                .ToListAsync();

            var subjectDepts = await _context.Subjects
                .Select(s => s.Department)
                .Distinct()
                .ToListAsync();

            var facultyDepts = await _context.Faculties
                .Select(f => f.Department)
                .Distinct()
                .ToListAsync();

            var allDepts = studentDepts
                .Union(subjectDepts)
                .Union(facultyDepts)
                .Select(d => DepartmentNormalizer.Normalize(d))
                .Distinct()
                .OrderBy(d => d)
                .ToList();

            return allDepts;
        }

        /// <summary>
        /// Checks for any department mismatches in the database
        /// Returns count of records that need normalization
        /// </summary>
        public async Task<Dictionary<string, int>> GetDepartmentMismatchCountAsync()
        {
            var result = new Dictionary<string, int>();

            // Check Students
            var studentMismatches = await _context.Students
                .Where(s => s.Department != null && DepartmentNormalizer.Normalize(s.Department) != s.Department)
                .CountAsync();
            result.Add("Students", studentMismatches);

            // Check Subjects
            var subjectMismatches = await _context.Subjects
                .Where(s => s.Department != null && DepartmentNormalizer.Normalize(s.Department) != s.Department)
                .CountAsync();
            result.Add("Subjects", subjectMismatches);

            // Check Faculties
            var facultyMismatches = await _context.Faculties
                .Where(f => f.Department != null && DepartmentNormalizer.Normalize(f.Department) != f.Department)
                .CountAsync();
            result.Add("Faculties", facultyMismatches);

            return result;
        }

        /// <summary>
        /// Fixes all department mismatches in the database
        /// Returns count of records updated
        /// </summary>
        public async Task<Dictionary<string, int>> FixAllDepartmentMismatchesAsync()
        {
            var result = new Dictionary<string, int>();
            var updateCount = 0;

            // Fix Students
            var students = await _context.Students
                .Where(s => s.Department != null)
                .ToListAsync();

            foreach (var student in students)
            {
                var normalized = DepartmentNormalizer.Normalize(student.Department);
                if (student.Department != normalized)
                {
                    student.Department = normalized;
                    updateCount++;
                }
            }
            result.Add("Students", updateCount);

            // Fix Subjects
            updateCount = 0;
            var subjects = await _context.Subjects
                .Where(s => s.Department != null)
                .ToListAsync();

            foreach (var subject in subjects)
            {
                var normalized = DepartmentNormalizer.Normalize(subject.Department);
                if (subject.Department != normalized)
                {
                    subject.Department = normalized;
                    updateCount++;
                }
            }
            result.Add("Subjects", updateCount);

            // Fix Faculties
            updateCount = 0;
            var faculties = await _context.Faculties
                .Where(f => f.Department != null)
                .ToListAsync();

            foreach (var faculty in faculties)
            {
                var normalized = DepartmentNormalizer.Normalize(faculty.Department);
                if (faculty.Department != normalized)
                {
                    faculty.Department = normalized;
                    updateCount++;
                }
            }
            result.Add("Faculties", updateCount);

            await _context.SaveChangesAsync();

            return result;
        }
    }
}
