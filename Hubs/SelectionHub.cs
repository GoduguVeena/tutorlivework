using Microsoft.AspNetCore.SignalR;

namespace TutorLiveMentor.Hubs
{
    public class SelectionHub : Hub
    {
        private static readonly Dictionary<string, HashSet<string>> SubjectConnections = new();
        private static readonly Dictionary<string, string> UserConnections = new();

        public override async Task OnConnectedAsync()
        {
            var httpContext = Context.GetHttpContext();
            var studentId = httpContext?.Session.GetString("StudentId");
            var facultyId = httpContext?.Session.GetString("FacultyId");
            
            if (!string.IsNullOrEmpty(studentId))
            {
                UserConnections[Context.ConnectionId] = $"Student_{studentId}";
                await Groups.AddToGroupAsync(Context.ConnectionId, "Students");
            }
            else if (!string.IsNullOrEmpty(facultyId))
            {
                UserConnections[Context.ConnectionId] = $"Faculty_{facultyId}";
                await Groups.AddToGroupAsync(Context.ConnectionId, "Faculty");
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            UserConnections.Remove(Context.ConnectionId);

            // Remove from all subject groups
            foreach (var subjectGroup in SubjectConnections.Values)
            {
                subjectGroup.Remove(Context.ConnectionId);
            }

            await base.OnDisconnectedAsync(exception);
        }

        public async Task JoinSubjectGroup(string subjectName, int year, string department)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            if (!SubjectConnections.ContainsKey(groupName))
            {
                SubjectConnections[groupName] = new HashSet<string>();
            }
            
            SubjectConnections[groupName].Add(Context.ConnectionId);
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
        }

        public async Task LeaveSubjectGroup(string subjectName, int year, string department)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            if (SubjectConnections.ContainsKey(groupName))
            {
                SubjectConnections[groupName].Remove(Context.ConnectionId);
            }
            
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
        }

        public async Task NotifySubjectSelection(string subjectName, int year, string department, int assignedSubjectId, int newCount, string facultyName, string studentName)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            await Clients.Group(groupName).SendAsync("SubjectSelectionUpdated", new
            {
                AssignedSubjectId = assignedSubjectId,
                SubjectName = subjectName,
                Year = year,
                Department = department,
                NewCount = newCount,
                FacultyName = facultyName,
                StudentName = studentName,
                Timestamp = DateTime.Now,
                IsFull = newCount >= 60
            });

            // Also notify all faculty members
            await Clients.Group("Faculty").SendAsync("StudentEnrollmentChanged", new
            {
                AssignedSubjectId = assignedSubjectId,
                SubjectName = subjectName,
                FacultyName = facultyName,
                StudentName = studentName,
                Action = "Enrolled",
                NewCount = newCount,
                Timestamp = DateTime.Now
            });
        }

        public async Task NotifySubjectUnenrollment(string subjectName, int year, string department, int assignedSubjectId, int newCount, string facultyName, string studentName)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            await Clients.Group(groupName).SendAsync("SubjectUnenrollmentUpdated", new
            {
                AssignedSubjectId = assignedSubjectId,
                SubjectName = subjectName,
                Year = year,
                Department = department,
                NewCount = newCount,
                FacultyName = facultyName,
                StudentName = studentName,
                Timestamp = DateTime.Now,
                IsFull = false
            });

            // Also notify all faculty members
            await Clients.Group("Faculty").SendAsync("StudentEnrollmentChanged", new
            {
                AssignedSubjectId = assignedSubjectId,
                SubjectName = subjectName,
                FacultyName = facultyName,
                StudentName = studentName,
                Action = "Unenrolled",
                NewCount = newCount,
                Timestamp = DateTime.Now
            });
        }

        public async Task NotifyUserActivity(string userName, string action, string details)
        {
            await Clients.All.SendAsync("UserActivity", new
            {
                UserName = userName,
                Action = action,
                Details = details,
                Timestamp = DateTime.Now
            });
        }

        public async Task SendSystemNotification(string message, string type = "info")
        {
            await Clients.All.SendAsync("SystemNotification", new
            {
                Message = message,
                Type = type,
                Timestamp = DateTime.Now
            });
        }
    }
}