-- Migration Script: Update all CSEDS to CSE(DS)
-- Purpose: Standardize department name across all tables
-- Date: 2025

-- Backup note: Always backup your database before running this migration!

USE TutorLiveMentor;
GO

-- Update Students table
UPDATE Students
SET Department = 'CSE(DS)'
WHERE Department = 'CSEDS' OR Department = 'CSDS' OR Department = 'CSE-DS' OR Department = 'CSE (DS)' OR Department = 'CSE_DS';
GO

-- Update Faculty table
UPDATE Faculty
SET Department = 'CSE(DS)'
WHERE Department = 'CSEDS' OR Department = 'CSDS' OR Department = 'CSE-DS' OR Department = 'CSE (DS)' OR Department = 'CSE_DS';
GO

-- Update Subjects table
UPDATE Subjects
SET Department = 'CSE(DS)'
WHERE Department = 'CSEDS' OR Department = 'CSDS' OR Department = 'CSE-DS' OR Department = 'CSE (DS)' OR Department = 'CSE_DS';
GO

-- Update AssignedSubjects table
UPDATE AssignedSubjects
SET Department = 'CSE(DS)'
WHERE Department = 'CSEDS' OR Department = 'CSDS' OR Department = 'CSE-DS' OR Department = 'CSE (DS)' OR Department = 'CSE_DS';
GO

-- Update FacultySelectionSchedules table
UPDATE FacultySelectionSchedules
SET Department = 'CSE(DS)'
WHERE Department = 'CSEDS' OR Department = 'CSDS' OR Department = 'CSE-DS' OR Department = 'CSE (DS)' OR Department = 'CSE_DS';
GO

-- Verification queries
SELECT 'Students' AS TableName, COUNT(*) AS Count_CSEDS FROM Students WHERE Department LIKE '%CSE%DS%' AND Department <> 'CSE(DS)';
SELECT 'Faculty' AS TableName, COUNT(*) AS Count_CSEDS FROM Faculty WHERE Department LIKE '%CSE%DS%' AND Department <> 'CSE(DS)';
SELECT 'Subjects' AS TableName, COUNT(*) AS Count_CSEDS FROM Subjects WHERE Department LIKE '%CSE%DS%' AND Department <> 'CSE(DS)';
SELECT 'AssignedSubjects' AS TableName, COUNT(*) AS Count_CSEDS FROM AssignedSubjects WHERE Department LIKE '%CSE%DS%' AND Department <> 'CSE(DS)';
SELECT 'FacultySelectionSchedules' AS TableName, COUNT(*) AS Count_CSEDS FROM FacultySelectionSchedules WHERE Department LIKE '%CSE%DS%' AND Department <> 'CSE(DS)';
GO

-- Show updated records
SELECT 'Students with CSE(DS)' AS Info, COUNT(*) AS Count FROM Students WHERE Department = 'CSE(DS)';
SELECT 'Faculty with CSE(DS)' AS Info, COUNT(*) AS Count FROM Faculty WHERE Department = 'CSE(DS)';
SELECT 'Subjects with CSE(DS)' AS Info, COUNT(*) AS Count FROM Subjects WHERE Department = 'CSE(DS)';
SELECT 'AssignedSubjects with CSE(DS)' AS Info, COUNT(*) AS Count FROM AssignedSubjects WHERE Department = 'CSE(DS)';
SELECT 'FacultySelectionSchedules with CSE(DS)' AS Info, COUNT(*) AS Count FROM FacultySelectionSchedules WHERE Department = 'CSE(DS)';
GO

PRINT 'Migration completed successfully!';
PRINT 'All CSEDS variants have been updated to CSE(DS)';
