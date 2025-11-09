using Microsoft.AspNetCore.SignalR;

namespace TutorLiveMentor.Hubs
{
    public class SelectionHub : Hub
    {
        private static readonly Dictionary<string, HashSet<string>> SubjectConnections = new();
        private static readonly Dictionary<string, string> UserConnections = new();
        private readonly ILogger<SelectionHub> _logger;

        public SelectionHub(ILogger<SelectionHub> logger)
        {
            _logger = logger;
        }

        public override async Task OnConnectedAsync()
        {
            var httpContext = Context.GetHttpContext();
            var studentId = httpContext?.Session.GetString("StudentId");
            var facultyId = httpContext?.Session.GetString("FacultyId");
            
            _logger.LogInformation($"?? New SignalR connection: {Context.ConnectionId}");
            
            if (!string.IsNullOrEmpty(studentId))
            {
                UserConnections[Context.ConnectionId] = $"Student_{studentId}";
                await Groups.AddToGroupAsync(Context.ConnectionId, "Students");
                _logger.LogInformation($"   ? Student {studentId} added to 'Students' group");
            }
            else if (!string.IsNullOrEmpty(facultyId))
            {
                UserConnections[Context.ConnectionId] = $"Faculty_{facultyId}";
                await Groups.AddToGroupAsync(Context.ConnectionId, "Faculty");
                _logger.LogInformation($"   ? Faculty {facultyId} added to 'Faculty' group");
            }
            else
            {
                _logger.LogWarning($"   ?? Connection without session: {Context.ConnectionId}");
            }

            await base.OnConnectedAsync();
        }

        public override async Task OnDisconnectedAsync(Exception? exception)
        {
            _logger.LogInformation($"?? SignalR disconnection: {Context.ConnectionId}");
            
            if (UserConnections.TryGetValue(Context.ConnectionId, out var userId))
            {
                _logger.LogInformation($"   User: {userId}");
                UserConnections.Remove(Context.ConnectionId);
            }

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
            
            _logger.LogInformation($"?? Connection {Context.ConnectionId} joining group '{groupName}'");
            
            if (!SubjectConnections.ContainsKey(groupName))
            {
                SubjectConnections[groupName] = new HashSet<string>();
                _logger.LogInformation($"   ? Created new group: {groupName}");
            }
            
            SubjectConnections[groupName].Add(Context.ConnectionId);
            await Groups.AddToGroupAsync(Context.ConnectionId, groupName);
            
            _logger.LogInformation($"   ? Successfully joined group '{groupName}' (Total in group: {SubjectConnections[groupName].Count})");
        }

        public async Task LeaveSubjectGroup(string subjectName, int year, string department)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            _logger.LogInformation($"?? Connection {Context.ConnectionId} leaving group '{groupName}'");
            
            if (SubjectConnections.ContainsKey(groupName))
            {
                SubjectConnections[groupName].Remove(Context.ConnectionId);
                _logger.LogInformation($"   ? Left group (Remaining in group: {SubjectConnections[groupName].Count})");
            }
            
            await Groups.RemoveFromGroupAsync(Context.ConnectionId, groupName);
        }

        public async Task NotifySubjectSelection(string subjectName, int year, string department, int assignedSubjectId, int newCount, string facultyName, string studentName)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            _logger.LogInformation($"?? Broadcasting selection to group '{groupName}': {studentName} ? {facultyName} (Count: {newCount})");
            
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
                IsFull = newCount >= 30
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
            
            _logger.LogInformation($"   ? Broadcast completed");
        }

        public async Task NotifySubjectUnenrollment(string subjectName, int year, string department, int assignedSubjectId, int newCount, string facultyName, string studentName)
        {
            var groupName = $"{subjectName}_{year}_{department}";
            
            _logger.LogInformation($"?? Broadcasting unenrollment to group '{groupName}': {studentName} from {facultyName} (Count: {newCount})");
            
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
            
            _logger.LogInformation($"   ? Broadcast completed");
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