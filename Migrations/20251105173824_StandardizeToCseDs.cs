using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TutorLiveMentor10.Migrations
{
    /// <inheritdoc />
    public partial class StandardizeToCseDs : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Update all Students with department 'CSEDS' to 'CSE(DS)'
            migrationBuilder.Sql("UPDATE Students SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'");
            
            // Update all Faculties with department 'CSEDS' to 'CSE(DS)'
            migrationBuilder.Sql("UPDATE Faculties SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'");
            
            // Update all Subjects with department 'CSEDS' to 'CSE(DS)'
            migrationBuilder.Sql("UPDATE Subjects SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'");
            
            // Update all Admins with department 'CSEDS' to 'CSE(DS)'
            migrationBuilder.Sql("UPDATE Admins SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'");
            
            // Update all AssignedSubjects with department 'CSEDS' to 'CSE(DS)'
            migrationBuilder.Sql("UPDATE AssignedSubjects SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'");
            
            // Update all FacultySelectionSchedules with department 'CSEDS' to 'CSE(DS)'
            migrationBuilder.Sql("UPDATE FacultySelectionSchedules SET Department = 'CSE(DS)' WHERE Department = 'CSEDS'");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Rollback: Update back to 'CSEDS' if needed
            migrationBuilder.Sql("UPDATE Students SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'");
            migrationBuilder.Sql("UPDATE Faculties SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'");
            migrationBuilder.Sql("UPDATE Subjects SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'");
            migrationBuilder.Sql("UPDATE Admins SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'");
            migrationBuilder.Sql("UPDATE AssignedSubjects SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'");
            migrationBuilder.Sql("UPDATE FacultySelectionSchedules SET Department = 'CSEDS' WHERE Department = 'CSE(DS)'");
        }
    }
}
