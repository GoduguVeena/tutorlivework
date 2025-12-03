using Microsoft.EntityFrameworkCore;
using System;
using TutorLiveMentor.Helpers;

namespace TutorLiveMentor.Models
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<Student> Students { get; set; }
        public DbSet<Faculty> Faculties { get; set; }
        public DbSet<Subject> Subjects { get; set; }
        public DbSet<AssignedSubject> AssignedSubjects { get; set; }
        public DbSet<StudentEnrollment> StudentEnrollments { get; set; }
        public DbSet<Admin> Admins { get; set; }
        public DbSet<FacultySelectionSchedule> FacultySelectionSchedules { get; set; }

        /// <summary>
        /// PERMANENT FIX: Automatically normalize departments before saving to database
        /// This prevents CSE(DS) vs CSEDS mismatch issues
        /// </summary>
        public override int SaveChanges()
        {
            NormalizeDepartments();
            return base.SaveChanges();
        }

        /// <summary>
        /// PERMANENT FIX: Automatically normalize departments before saving to database (async)
        /// </summary>
        public override Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
        {
            NormalizeDepartments();
            return base.SaveChangesAsync(cancellationToken);
        }

        /// <summary>
        /// Normalizes all department fields before saving
        /// </summary>
        private void NormalizeDepartments()
        {
            var entries = ChangeTracker.Entries()
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
                        Console.WriteLine($"[AUTO-NORMALIZE] {entry.Entity.GetType().Name}.Department: '{currentValue}' → '{normalizedValue}'");
                        departmentProperty.CurrentValue = normalizedValue;
                    }
                }
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Simple, clean configuration - let EF Core use conventions
            
            // AssignedSubject -> Subject (many-to-one)
            modelBuilder.Entity<AssignedSubject>()
                .HasOne(a => a.Subject)
                .WithMany(s => s.AssignedSubjects)
                .HasForeignKey(a => a.SubjectId);

            // AssignedSubject -> Faculty (many-to-one)
            modelBuilder.Entity<AssignedSubject>()
                .HasOne(a => a.Faculty)
                .WithMany(f => f.AssignedSubjects)
                .HasForeignKey(a => a.FacultyId);

            // Configure the many-to-many relationship
            modelBuilder.Entity<StudentEnrollment>()
                .HasKey(se => new { se.StudentId, se.AssignedSubjectId });

            modelBuilder.Entity<StudentEnrollment>()
                .HasOne(se => se.Student)
                .WithMany(s => s.Enrollments)
                .HasForeignKey(se => se.StudentId);

            modelBuilder.Entity<StudentEnrollment>()
                .HasOne(se => se.AssignedSubject)
                .WithMany(a => a.Enrollments)
                .HasForeignKey(se => se.AssignedSubjectId);

            // Admin configuration
            modelBuilder.Entity<Admin>()
                .HasIndex(a => a.Email)
                .IsUnique();

            // Seed the specific admin data you requested
            modelBuilder.Entity<Admin>().HasData(
                new Admin
                {
                    AdminId = 1,
                    Email = "cseds@rgmcet.edu.in",
                    Password = "admin123",
                    Department = "CSEDS",
                    CreatedDate = new DateTime(2024, 1, 1),
                    LastLogin = null
                }
            );
        }
    }
}
