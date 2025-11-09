using Microsoft.AspNetCore.SignalR;
using TutorLiveMentor.Hubs;
using TutorLiveMentor.Models;

namespace TutorLiveMentor.Services
{
    public class SignalRService
    {
        private readonly IHubContext<SelectionHub> _hubContext;
        private readonly ILogger<SignalRService> _logger;

        public SignalRService(IHubContext<SelectionHub> hubContext, ILogger<SignalRService> logger)
        {
            _hubContext = hubContext;
            _logger = logger;
        }

        public async Task NotifySubjectSelection(AssignedSubject assignedSubject, Student student)
        {
            try
            {
                var groupName = $"{assignedSubject.Subject.Name}_{assignedSubject.Year}_{assignedSubject.Department}";
                
                var notificationData = new
                {
                    AssignedSubjectId = assignedSubject.AssignedSubjectId,
                    SubjectName = assignedSubject.Subject.Name,
                    Year = assignedSubject.Year,
                    Department = assignedSubject.Department,
                    NewCount = assignedSubject.SelectedCount,
                    FacultyName = assignedSubject.Faculty.Name,
                    StudentName = student.FullName,
                    Timestamp = DateTime.Now,
                    IsFull = assignedSubject.SelectedCount >= 30,
                    Message = $"{student.FullName} enrolled with {assignedSubject.Faculty.Name}"
                };

                _logger.LogInformation($"?? Sending SignalR notification to group '{groupName}'");
                _logger.LogInformation($"   AssignedSubjectId: {notificationData.AssignedSubjectId}");
                _logger.LogInformation($"   NewCount: {notificationData.NewCount}");
                _logger.LogInformation($"   IsFull: {notificationData.IsFull}");
                _logger.LogInformation($"   Student: {notificationData.StudentName}");
                _logger.LogInformation($"   Faculty: {notificationData.FacultyName}");
                
                await _hubContext.Clients.Group(groupName).SendAsync("SubjectSelectionUpdated", notificationData);

                // Notify all faculty
                await _hubContext.Clients.Group("Faculty").SendAsync("StudentEnrollmentChanged", new
                {
                    AssignedSubjectId = assignedSubject.AssignedSubjectId,
                    SubjectName = assignedSubject.Subject.Name,
                    FacultyName = assignedSubject.Faculty.Name,
                    StudentName = student.FullName,
                    Action = "Enrolled",
                    NewCount = assignedSubject.SelectedCount,
                    Timestamp = DateTime.Now
                });

                _logger.LogInformation($"? SignalR notification sent successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "? Error sending SignalR notification for subject selection");
            }
        }

        public async Task NotifySubjectUnenrollment(AssignedSubject assignedSubject, Student student)
        {
            try
            {
                var groupName = $"{assignedSubject.Subject.Name}_{assignedSubject.Year}_{assignedSubject.Department}";
                
                var notificationData = new
                {
                    AssignedSubjectId = assignedSubject.AssignedSubjectId,
                    SubjectName = assignedSubject.Subject.Name,
                    Year = assignedSubject.Year,
                    Department = assignedSubject.Department,
                    NewCount = assignedSubject.SelectedCount,
                    FacultyName = assignedSubject.Faculty.Name,
                    StudentName = student.FullName,
                    Timestamp = DateTime.Now,
                    IsFull = false,
                    Message = $"{student.FullName} unenrolled from {assignedSubject.Faculty.Name}"
                };

                _logger.LogInformation($"?? Sending SignalR unenrollment notification to group '{groupName}'");
                _logger.LogInformation($"   AssignedSubjectId: {notificationData.AssignedSubjectId}");
                _logger.LogInformation($"   NewCount: {notificationData.NewCount}");
                _logger.LogInformation($"   Student: {notificationData.StudentName}");
                _logger.LogInformation($"   Faculty: {notificationData.FacultyName}");
                
                await _hubContext.Clients.Group(groupName).SendAsync("SubjectUnenrollmentUpdated", notificationData);

                // Notify all faculty
                await _hubContext.Clients.Group("Faculty").SendAsync("StudentEnrollmentChanged", new
                {
                    AssignedSubjectId = assignedSubject.AssignedSubjectId,
                    SubjectName = assignedSubject.Subject.Name,
                    FacultyName = assignedSubject.Faculty.Name,
                    StudentName = student.FullName,
                    Action = "Unenrolled",
                    NewCount = assignedSubject.SelectedCount,
                    Timestamp = DateTime.Now
                });

                _logger.LogInformation($"? SignalR unenrollment notification sent successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "? Error sending SignalR notification for subject unenrollment");
            }
        }

        public async Task NotifyUserActivity(string userName, string userType, string action, string details)
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("UserActivity", new
                {
                    UserName = userName,
                    UserType = userType,
                    Action = action,
                    Details = details,
                    Timestamp = DateTime.Now
                });

                _logger.LogInformation($"?? SignalR: User activity - {userName} ({userType}): {action}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "? Error sending SignalR user activity notification");
            }
        }

        public async Task SendSystemNotification(string message, string type = "info")
        {
            try
            {
                await _hubContext.Clients.All.SendAsync("SystemNotification", new
                {
                    Message = message,
                    Type = type,
                    Timestamp = DateTime.Now
                });

                _logger.LogInformation($"?? SignalR: System notification ({type}): {message}");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "? Error sending SignalR system notification");
            }
        }

        public async Task NotifySubjectAvailability(string subjectName, int year, string department, bool isAvailable)
        {
            try
            {
                var groupName = $"{subjectName}_{year}_{department}";
                
                _logger.LogInformation($"?? Sending availability change notification to group '{groupName}': {(isAvailable ? "Available" : "Full")}");
                
                await _hubContext.Clients.Group(groupName).SendAsync("SubjectAvailabilityChanged", new
                {
                    SubjectName = subjectName,
                    Year = year,
                    Department = department,
                    IsAvailable = isAvailable,
                    Message = isAvailable ? "Seats are now available!" : "Subject is now full!",
                    Timestamp = DateTime.Now
                });

                _logger.LogInformation($"? Availability notification sent successfully");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "? Error sending SignalR availability notification");
            }
        }
    }
}