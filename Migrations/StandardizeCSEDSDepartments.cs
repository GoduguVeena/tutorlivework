using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace TutorLiveMentor.Migrations
{
    /// <summary>
    /// PERMANENT FIX: Standardizes all CSE(DS) department variations to "CSEDS"
    /// This migration ensures consistent department naming across all tables
    /// </summary>
    public partial class StandardizeCSEDSDepartments : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // ============================================
            // STEP 1: Standardize Students Table
            // ============================================
            migrationBuilder.Sql(@"
                UPDATE Students 
                SET Department = 'CSEDS'
                WHERE Department IN ('CSE(DS)', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSDS', 'CSE DATA SCIENCE', 'CSEDATASCIENCE');
            ");

            // ============================================
            // STEP 2: Standardize Subjects Table
            // ============================================
            migrationBuilder.Sql(@"
                UPDATE Subjects 
                SET Department = 'CSEDS'
                WHERE Department IN ('CSE(DS)', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSDS', 'CSE DATA SCIENCE', 'CSEDATASCIENCE');
            ");

            // ============================================
            // STEP 3: Standardize Faculties Table
            // ============================================
            migrationBuilder.Sql(@"
                UPDATE Faculties 
                SET Department = 'CSEDS'
                WHERE Department IN ('CSE(DS)', 'CSE-DS', 'CSE (DS)', 'CSE_DS', 'CSDS', 'CSE DATA SCIENCE', 'CSEDATASCIENCE');
            ");

            // ============================================
            // STEP 4: Add Check Constraints (Optional - for future validation)
            // Note: Commented out because it would prevent other departments
            // Uncomment if you want to enforce ONLY specific departments
            // ============================================
            /*
            migrationBuilder.Sql(@"
                ALTER TABLE Students
                ADD CONSTRAINT CK_Students_Department_Format
                CHECK (
                    Department IN ('CSEDS', 'CSE(AIML)', 'CSE(CS)', 'CSE(BS)', 'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL')
                    OR
                    Department NOT LIKE '%CSE%DS%'
                );
            ");

            migrationBuilder.Sql(@"
                ALTER TABLE Subjects
                ADD CONSTRAINT CK_Subjects_Department_Format
                CHECK (
                    Department IN ('CSEDS', 'CSE(AIML)', 'CSE(CS)', 'CSE(BS)', 'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL')
                    OR
                    Department NOT LIKE '%CSE%DS%'
                );
            ");

            migrationBuilder.Sql(@"
                ALTER TABLE Faculties
                ADD CONSTRAINT CK_Faculties_Department_Format
                CHECK (
                    Department IN ('CSEDS', 'CSE(AIML)', 'CSE(CS)', 'CSE(BS)', 'CSE', 'ECE', 'EEE', 'MECH', 'CIVIL')
                    OR
                    Department NOT LIKE '%CSE%DS%'
                );
            ");
            */
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Rollback: Convert CSEDS back to CSE(DS) if needed
            migrationBuilder.Sql(@"
                UPDATE Students 
                SET Department = 'CSE(DS)'
                WHERE Department = 'CSEDS';
            ");

            migrationBuilder.Sql(@"
                UPDATE Subjects 
                SET Department = 'CSE(DS)'
                WHERE Department = 'CSEDS';
            ");

            migrationBuilder.Sql(@"
                UPDATE Faculties 
                SET Department = 'CSE(DS)'
                WHERE Department = 'CSEDS';
            ");

            // Drop constraints if they were created
            /*
            migrationBuilder.Sql(@"
                ALTER TABLE Students DROP CONSTRAINT IF EXISTS CK_Students_Department_Format;
                ALTER TABLE Subjects DROP CONSTRAINT IF EXISTS CK_Subjects_Department_Format;
                ALTER TABLE Faculties DROP CONSTRAINT IF EXISTS CK_Faculties_Department_Format;
            ");
            */
        }
    }
}
