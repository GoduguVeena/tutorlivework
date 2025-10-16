# ?? TutorLiveMentor - Enrollment Limit Changed

## ?? **Changes Made: 60 ? 20 Students**

For testing purposes, the enrollment limit has been reduced from **60 students** to **20 students** per faculty subject.

### **?? Files Modified:**

#### **Controllers\StudentController.cs**
**Two locations updated:**

1. **Line ~137** - Enrollment Validation Check:
   ```csharp
   // OLD: if (assignedSubject.SelectedCount >= 60)
   // NEW: 
   if (assignedSubject.SelectedCount >= 20)
   {
       TempData["ErrorMessage"] = "This subject is already full (maximum 20 students).";
       return RedirectToAction("SelectSubject");
   }
   ```

2. **Line ~283** - Available Subjects Query:
   ```csharp
   // OLD: .Where(a => a.Year == studentYear && a.SelectedCount < 60)
   // NEW:
   .Where(a => a.Year == studentYear && a.SelectedCount < 20)
   ```

### **?? What This Changes:**

#### **For Students:**
- ? Can only enroll if faculty has **fewer than 20** students
- ? Will see "Subject is full" message when faculty reaches **20 students**
- ? Only subjects with **available slots (< 20)** appear in subject selection

#### **For Faculty:**
- ? Can see up to **20 students maximum** per subject
- ? Subject becomes unavailable to new students once **20 students** enrolled
- ? Student count displays correctly in faculty dashboard

#### **For Testing:**
- ? **Easier to test** "full subject" scenarios with smaller numbers
- ? **Faster enrollment filling** for demonstration purposes
- ? **More manageable** student lists for small-scale testing

### **?? How to Change Back (Future):**

When ready for production, simply change both instances back:

```csharp
// Change these lines in Controllers\StudentController.cs:
if (assignedSubject.SelectedCount >= 60)  // Line ~137
.Where(a => a.Year == studentYear && a.SelectedCount < 60)  // Line ~283
```

### **? Current Status:**
- ??? **Build**: Successful  
- ?? **Testing**: Ready with 20-student limit
- ?? **Network**: Fully functional
- ?? **Database**: All tables working properly

**Your TutorLiveMentor application is now configured for testing with a 20-student enrollment limit per faculty subject!** ??