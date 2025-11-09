# CRITICAL FIX: Department Normalization to Prevent CSE(DS) vs CSEDS Mismatch

## Files Changed:
1. ? Helpers/DepartmentNormalizer.cs (NEW - Created)
2. ?? Controllers/StudentController.cs (NEEDS UPDATE - See instructions below)

---

## STEP 1: Add Using Statement

At the top of `Controllers/StudentController.cs`, add this line with the other usings:

```csharp
using TutorLiveMentor.Helpers;
```

---

## STEP 2: Update Register Method

Find the `Register` method (around line 48) and add department normalization:

**FIND THIS CODE:**
```csharp
[HttpPost]
public async Task<IActionResult> Register(StudentRegistrationModel model)
{
    if (ModelState.IsValid)
    {
        // Convert registration number to uppercase on server side as well
        model.RegdNumber = model.RegdNumber?.ToUpper();
        
        // Check if student with this registration number already exists
        if (await _context.Students.AnyAsync(s => s.Id == model.RegdNumber))
```

**CHANGE TO:**
```csharp
[HttpPost]
public async Task<IActionResult> Register(StudentRegistrationModel model)
{
    if (ModelState.IsValid)
    {
        // Convert registration number to uppercase on server side as well
        model.RegdNumber = model.RegdNumber?.ToUpper();
        
        // ? CRITICAL FIX: Normalize department name (CSE(DS) -> CSEDS)
        model.Department = DepartmentNormalizer.Normalize(model.Department);
        
        // Check if student with this registration number already exists
        if (await _context.Students.AnyAsync(s => s.Id == model.RegdNumber))
```

**ADD THIS LINE:**
```csharp
// ? CRITICAL FIX: Normalize department name (CSE(DS) -> CSEDS)
model.Department = DepartmentNormalizer.Normalize(model.Department);
```

**AFTER LINE 51** (after `model.RegdNumber = model.RegdNumber?.ToUpper();`)

---

## STEP 3: Update Edit Method (Optional but Recommended)

Find the `Edit` method (around line 503) and add department normalization:

**FIND THIS CODE:**
```csharp
if (ModelState.IsValid)
{
    var studentToUpdate = await _context.Students.FindAsync(studentId);
    if (studentToUpdate == null)
    {
        return NotFound();
    }

    studentToUpdate.FullName = model.FullName;
    studentToUpdate.Year = model.Year;
    studentToUpdate.Department = model.Department;
```

**CHANGE TO:**
```csharp
if (ModelState.IsValid)
{
    var studentToUpdate = await _context.Students.FindAsync(studentId);
    if (studentToUpdate == null)
    {
        return NotFound();
    }

    studentToUpdate.FullName = model.FullName;
    studentToUpdate.Year = model.Year;
    
    // ? CRITICAL FIX: Normalize department name when editing
    studentToUpdate.Department = DepartmentNormalizer.Normalize(model.Department);
```

---

## STEP 4: Add Logging (Optional)

After the student is saved in Register method (around line 80), add:

```csharp
_context.Students.Add(student);
await _context.SaveChangesAsync();

// ? Log the normalized department for verification
Console.WriteLine($"? Student registered: {student.FullName} | Original Dept: {model.Department} | Saved as: {student.Department}");
```

---

## ? WHAT THIS FIX DOES:

**Before Fix:**
```
Student registers with: CSE(DS)
Database stores: CSE(DS)
Subjects are for: CSEDS
Result: NO MATCH ? - No subjects shown
```

**After Fix:**
```
Student registers with: CSE(DS)
System normalizes to: CSEDS
Database stores: CSEDS
Subjects are for: CSEDS
Result: MATCH ? - Subjects shown!
```

---

## ?? ALL SUPPORTED VARIANTS:

The normalizer automatically handles:

| User Enters | Saved As |
|-------------|----------|
| CSE(DS) | CSEDS |
| CSDS | CSEDS |
| CSE-DS | CSEDS |
| CSE (DS) | CSEDS |
| CSE_DS | CSEDS |
| CSE DATA SCIENCE | CSEDS |

---

## ?? HOW TO TEST:

1. Try registering a new student with "CSE(DS)"
2. Check database - should show "CSEDS"
3. Student should see subjects immediately!

---

## ?? QUICK COPY-PASTE FOR StudentController.cs:

**Add at top with other usings:**
```csharp
using TutorLiveMentor.Helpers;
```

**Add in Register method after line 51:**
```csharp
// ? CRITICAL FIX: Normalize department name (CSE(DS) -> CSEDS)
model.Department = DepartmentNormalizer.Normalize(model.Department);
```

**Add in Edit method (replace line ~530):**
```csharp
// ? CRITICAL FIX: Normalize department name when editing
studentToUpdate.Department = DepartmentNormalizer.Normalize(model.Department);
```

---

## ? DONE!

After making these changes:
1. Build the project
2. Test registration with "CSE(DS)"
3. Verify it's saved as "CSEDS" in database
4. Students will no longer face "No Available Subjects" issue!

---

**Files to Edit:**
- `Controllers/StudentController.cs` - Add 3 lines
- `Helpers/DepartmentNormalizer.cs` - ? Already created!
