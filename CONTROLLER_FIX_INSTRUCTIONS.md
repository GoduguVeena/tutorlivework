=============================================================================
CONTROLLER FIX REQUIRED - StudentController.cs
=============================================================================

FILE: Controllers/StudentController.cs
LINE: ~681-682

CURRENT CODE (BROKEN):
```csharp
var schedule = await _context.FacultySelectionSchedules
    .FirstOrDefaultAsync(s => s.Department == "CSE(DS)");
```

PROBLEM:
- Hardcoded to look for "CSE(DS)" 
- Database now has "CSEDS" (normalized format)
- Schedule will NEVER be found for CSE(DS) students

FIX:
```csharp
// Get schedule for student's normalized department
var normalizedDept = DepartmentNormalizer.Normalize(student.Department);
var schedule = await _context.FacultySelectionSchedules
    .Where(s => s.Department == normalizedDept)
    .FirstOrDefaultAsync();
```

OR BETTER (handles any department variant in database):
```csharp
// Get all schedules and find match by normalized department
var normalizedStudentDept = DepartmentNormalizer.Normalize(student.Department);
var allSchedules = await _context.FacultySelectionSchedules.ToListAsync();
var schedule = allSchedules.FirstOrDefault(s => 
    DepartmentNormalizer.Normalize(s.Department) == normalizedStudentDept);
```

LINES TO REPLACE: 680-703 (entire schedule check block)

=============================================================================
