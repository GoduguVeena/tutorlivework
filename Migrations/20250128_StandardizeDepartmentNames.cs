using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TutorLiveMentor.Migrations
{
    /// <summary>
    /// Migration to standardize all department names from CSEDS variants to CSE(DS)
    /// </summary>
    public partial class StandardizeDepartmentNames : Migration
    {
        /// <summary>
        /// Apply the migration - Update all CSEDS to CSE(DS)
        /// </summary>
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Update Students table
            migrationBuilder.Sql(@"
                UPDATE Students 
                SET Department = 'CSE(DS)' 
                WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS');
            ");

            // Update Faculty table
            migrationBuilder.Sql(@"
                UPDATE Faculty 
                SET Department = 'CSE(DS)' 
                WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS');
            ");

            // Update Subjects table
            migrationBuilder.Sql(@"
                UPDATE Subjects 
                SET Department = 'CSE(DS)' 
                WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS');
            ");

            // Update AssignedSubjects table
            migrationBuilder.Sql(@"
                UPDATE AssignedSubjects 
                SET Department = 'CSE(DS)' 
                WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS');
            ");

            // Update FacultySelectionSchedules table
            migrationBuilder.Sql(@"
                UPDATE FacultySelectionSchedules 
                SET Department = 'CSE(DS)' 
                WHERE Department IN ('CSEDS', 'CSDS', 'CSE-DS', 'CSE (DS)', 'CSE_DS');
            ");
        }

        /// <summary>
        /// Rollback the migration - Revert CSE(DS) back to CSEDS
        /// </summary>
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Rollback - Update CSE(DS) back to CSEDS
            migrationBuilder.Sql(@"
                UPDATE Students SET Department = 'CSEDS' WHERE Department = 'CSE(DS)';
                UPDATE Faculty SET Department = 'CSEDS' WHERE Department = 'CSE(DS)';
                UPDATE Subjects SET Department = 'CSEDS' WHERE Department = 'CSE(DS)';
                UPDATE AssignedSubjects SET Department = 'CSEDS' WHERE Department = 'CSE(DS)';
                UPDATE FacultySelectionSchedules SET Department = 'CSEDS' WHERE Department = 'CSE(DS)';
            ");
        }
    }
}
