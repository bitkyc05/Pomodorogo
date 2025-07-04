import Foundation
import Combine

// MARK: - 타이머 모드 열거형
enum TimerMode: String, CaseIterable {
    case work = "work"
    case shortBreak = "short"
    case longBreak = "long"
    
    var displayName: String {
        switch self {
        case .work: return "Work"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    
    var defaultDuration: Int {
        switch self {
        case .work: return 25 * 60
        case .shortBreak: return 5 * 60
        case .longBreak: return 15 * 60
        }
    }
}

// MARK: - 타이머 ViewModel
class TimerViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var currentMode: TimerMode = .work
    @Published var timeLeft: Int = 0
    @Published var isRunning: Bool = false
    @Published var sessionNumber: Int = 1
    @Published var completedSessions: Int = 0
    @Published var totalTime: Int = 0
    @Published var streak: Int = 0
    @Published var currentWorkArea: String = "General Work"
    @Published var workAreas: [String] = ["General Work"]
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var sessionLogs: [PomodoroSession] = []
    
    // 모드별 지속시간 설정
    private var modeDurations: [TimerMode: Int] = [
        .work: 25 * 60,
        .shortBreak: 5 * 60,
        .longBreak: 15 * 60
    ]
    
    // MARK: - Initialization
    init() {
        self.timeLeft = modeDurations[currentMode] ?? TimerMode.work.defaultDuration
        loadSettings()
        loadStats()
        loadWorkAreas()
    }
    
    // MARK: - Timer Control Methods
    func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        isRunning = true
        sessionStartTime = sessionStartTime ?? Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.timeLeft -= 1
            
            if self.timeLeft <= 0 {
                self.completeSession()
            }
        }
        
        // 포커스 모드 시작 (설정에 따라)
        // 앰비언트 사운드 시작 (설정에 따라)
        // 주의산만 알림 시작 (설정에 따라)
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // 포커스 모드 종료
        // 앰비언트 사운드 정지
        // 주의산만 알림 정지
    }
    
    func resetTimer() {
        pauseTimer()
        sessionStartTime = nil
        timeLeft = modeDurations[currentMode] ?? TimerMode.work.defaultDuration
    }
    
    private func completeSession() {
        pauseTimer()
        
        let endTime = Date()
        let actualDuration = sessionStartTime != nil ? 
            Int(endTime.timeIntervalSince(sessionStartTime!)) : 
            modeDurations[currentMode] ?? 0
        
        // 세션 로그 생성
        let session = PomodoroSession(
            type: currentMode,
            plannedDuration: modeDurations[currentMode] ?? 0,
            actualDuration: actualDuration,
            startTime: sessionStartTime ?? endTime,
            endTime: endTime,
            workArea: currentWorkArea
        )
        
        sessionLogs.append(session)
        
        // 통계 업데이트
        completedSessions += 1
        totalTime += actualDuration
        streak += 1
        sessionStartTime = nil
        
        if currentMode == .work {
            sessionNumber += 1
            
            // 4번째 작업 세션 후 긴 휴식, 아니면 짧은 휴식
            if completedSessions % 4 == 0 {
                switchMode(.longBreak)
            } else {
                switchMode(.shortBreak)
            }
        } else {
            // 휴식 후 작업으로 복귀
            switchMode(.work)
        }
        
        saveStats()
        
        // 알림 표시
        // 소리 재생
        sendNotification()
    }
    
    // MARK: - Mode Management
    func switchMode(_ mode: TimerMode) {
        if mode != currentMode {
            pauseTimer()
            currentMode = mode
            timeLeft = modeDurations[mode] ?? mode.defaultDuration
        }
    }
    
    // MARK: - Work Area Management
    func addWorkArea(_ name: String) {
        if !workAreas.contains(name) {
            workAreas.append(name)
            saveWorkAreas()
        }
    }
    
    func removeWorkArea(_ name: String) {
        guard name != "General Work" else { return }
        workAreas.removeAll { $0 == name }
        if currentWorkArea == name {
            currentWorkArea = "General Work"
        }
        saveWorkAreas()
    }
    
    func selectWorkArea(_ name: String) {
        currentWorkArea = name
        saveWorkAreas()
    }
    
    // MARK: - Settings Management
    func updateModeDuration(_ mode: TimerMode, duration: Int) {
        modeDurations[mode] = duration
        if currentMode == mode {
            timeLeft = duration
        }
        saveSettings()
    }
    
    // MARK: - Computed Properties
    var formattedTime: String {
        let minutes = timeLeft / 60
        let seconds = timeLeft % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var progress: Double {
        let totalDuration = modeDurations[currentMode] ?? 1
        return Double(totalDuration - timeLeft) / Double(totalDuration)
    }
    
    var formattedTotalTime: String {
        let hours = totalTime / 3600
        let minutes = (totalTime % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    // MARK: - Data Persistence
    private func loadSettings() {
        // UserDefaults에서 설정 로드
        if let workDuration = UserDefaults.standard.object(forKey: "workDuration") as? Int {
            modeDurations[.work] = workDuration
        }
        if let shortBreakDuration = UserDefaults.standard.object(forKey: "shortBreakDuration") as? Int {
            modeDurations[.shortBreak] = shortBreakDuration
        }
        if let longBreakDuration = UserDefaults.standard.object(forKey: "longBreakDuration") as? Int {
            modeDurations[.longBreak] = longBreakDuration
        }
        
        timeLeft = modeDurations[currentMode] ?? TimerMode.work.defaultDuration
    }
    
    private func saveSettings() {
        UserDefaults.standard.set(modeDurations[.work], forKey: "workDuration")
        UserDefaults.standard.set(modeDurations[.shortBreak], forKey: "shortBreakDuration")
        UserDefaults.standard.set(modeDurations[.longBreak], forKey: "longBreakDuration")
    }
    
    private func loadStats() {
        completedSessions = UserDefaults.standard.integer(forKey: "completedSessions")
        totalTime = UserDefaults.standard.integer(forKey: "totalTime")
        streak = UserDefaults.standard.integer(forKey: "streak")
        sessionNumber = UserDefaults.standard.integer(forKey: "sessionNumber")
        if sessionNumber == 0 { sessionNumber = 1 }
        
        // Core Data에서 세션 로그 로드 (추후 구현)
    }
    
    private func saveStats() {
        UserDefaults.standard.set(completedSessions, forKey: "completedSessions")
        UserDefaults.standard.set(totalTime, forKey: "totalTime")
        UserDefaults.standard.set(streak, forKey: "streak")
        UserDefaults.standard.set(sessionNumber, forKey: "sessionNumber")
        
        // Core Data에 세션 로그 저장 (추후 구현)
    }
    
    private func loadWorkAreas() {
        if let areas = UserDefaults.standard.stringArray(forKey: "workAreas") {
            workAreas = areas
        }
        if let current = UserDefaults.standard.string(forKey: "currentWorkArea") {
            currentWorkArea = current
        }
    }
    
    private func saveWorkAreas() {
        UserDefaults.standard.set(workAreas, forKey: "workAreas")
        UserDefaults.standard.set(currentWorkArea, forKey: "currentWorkArea")
    }
    
    // MARK: - Notifications
    private func sendNotification() {
        // UserNotifications를 사용한 시스템 알림 (추후 구현)
        // NotificationManager.shared.sendSessionCompleteNotification(...)
    }
}

// MARK: - 임시 PomodoroSession 구조체 (추후 Core Data 모델로 교체)
struct PomodoroSession {
    let type: TimerMode
    let plannedDuration: Int
    let actualDuration: Int
    let startTime: Date
    let endTime: Date
    let workArea: String
    let completed: Bool = true
}