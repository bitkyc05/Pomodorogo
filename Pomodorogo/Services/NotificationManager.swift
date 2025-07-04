import Foundation
import UserNotifications
import AppKit

// MARK: - 알림 매니저
class NotificationManager: NSObject, ObservableObject {
    
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    
    override init() {
        super.init()
        center.delegate = self
        checkAuthorizationStatus()
    }
    
    // MARK: - Authorization
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            
            await MainActor.run {
                self.isAuthorized = granted
                self.checkAuthorizationStatus()
            }
            
            return granted
        } catch {
            print("Notification permission error: \(error)")
            return false
        }
    }
    
    private func checkAuthorizationStatus() {
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.authorizationStatus = settings.authorizationStatus
                self.isAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // MARK: - Session Notifications
    func sendSessionCompleteNotification(mode: TimerMode, isWorkSession: Bool) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        
        if isWorkSession {
            content.title = "🎉 Work Session Complete!"
            content.body = "Great job! Time for a well-deserved break."
            content.sound = .default
        } else {
            content.title = "💪 Break Time Over!"
            content.body = "Ready to get back to work? Let's focus!"
            content.sound = .default
        }
        
        // 즉시 표시
        let request = UNNotificationRequest(
            identifier: "session-complete-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error)")
            }
        }
    }
    
    func sendDistractionReminder() {
        guard isAuthorized else { return }
        
        let reminders = [
            "🎯 Stay focused on your current task!",
            "🧘‍♀️ Take a deep breath and refocus",
            "💪 You're doing great! Keep going",
            "🏆 Remember your goal for this session",
            "🌟 Minimize distractions and stay present"
        ]
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Reminder"
        content.body = reminders.randomElement() ?? "Stay focused!"
        content.sound = .default
        
        let request = UNNotificationRequest(
            identifier: "distraction-reminder-\(Date().timeIntervalSince1970)",
            content: content,
            trigger: nil
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to send distraction reminder: \(error)")
            }
        }
    }
    
    // MARK: - Scheduled Notifications
    func scheduleBreakReminder(in seconds: TimeInterval) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⏰ Break Time!"
        content.body = "Your break is ending soon. Get ready to focus!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "break-reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule break reminder: \(error)")
            }
        }
    }
    
    func scheduleWorkReminder(in seconds: TimeInterval) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "🍅 Work Time!"
        content.body = "Time to start your next focused work session!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "work-reminder",
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule work reminder: \(error)")
            }
        }
    }
    
    // MARK: - Cleanup
    func clearAllNotifications() {
        center.removeAllPendingNotificationRequests()
        center.removeAllDeliveredNotifications()
    }
    
    func clearNotification(withIdentifier identifier: String) {
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        center.removeDeliveredNotifications(withIdentifiers: [identifier])
    }
    
    // MARK: - Badge Management
    func updateAppBadge(count: Int) {
        DispatchQueue.main.async {
            NSApp.dockTile.badgeLabel = count > 0 ? "\(count)" : nil
        }
    }
    
    func clearAppBadge() {
        updateAppBadge(count: 0)
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationManager: UNUserNotificationCenterDelegate {
    
    // 앱이 포그라운드에 있을 때도 알림 표시
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    // 알림 탭 처리
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        
        let identifier = response.notification.request.identifier
        
        // 특정 알림에 대한 처리
        if identifier.hasPrefix("session-complete") {
            // 앱을 포그라운드로 가져오기
            NSApp.activate(ignoringOtherApps: true)
        } else if identifier.hasPrefix("distraction-reminder") {
            // 포커스 모드 활성화 또는 앱 활성화
            NSApp.activate(ignoringOtherApps: true)
        }
        
        completionHandler()
    }
}