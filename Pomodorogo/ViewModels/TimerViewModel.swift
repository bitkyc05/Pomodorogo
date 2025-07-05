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
    @Published var isOvertimeMode: Bool = false
    @Published var overtimeSeconds: Int = 0
    
    // MARK: - Private Properties
    private var timer: Timer?
    private var sessionStartTime: Date?
    private var sessionLogs: [PomodoroSession] = []
    private var cancellables = Set<AnyCancellable>()
    private var elapsedWorkTime: TimeInterval = 0  // 순수 작업시간 (Date 기반 누적)
    private var lastTickTimestamp: Date?           // 마지막 tick 시점
    private var isInitialDurationReached: Bool = false  // 설정 시간 도달 여부
    
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
        
        // 설정 변경 알림 구독
        NotificationCenter.default.publisher(for: .settingsDidChange)
            .sink { [weak self] _ in
                self?.loadSettings()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Timer Control Methods
    func toggleTimer() {
        if isRunning {
            // 휴식 모드에서는 일시정지 불가
            if currentMode != .work {
                return
            }
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    func startTimer() {
        isRunning = true
        sessionStartTime = sessionStartTime ?? Date()
        lastTickTimestamp = Date()  // 재시작 시점으로 설정 (일시정지 시간 제외)
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.tick()
        }
        
        // 메뉴바 아이콘 업데이트
        MenuBarManager.shared.updateMenuBarIcon(for: currentMode, isRunning: true)
        
        // 포커스 모드 시작 (설정에 따라)
        startFocusModeIfNeeded()
        // 앰비언트 사운드 시작 (설정에 따라)
        startAmbientSoundIfNeeded()
        // 주의산만 알림 시작 (설정에 따라)
    }
    
    func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        
        // 메뉴바 아이콘 업데이트
        MenuBarManager.shared.updateMenuBarIcon(for: currentMode, isRunning: false)
        
        // 포커스 모드 종료
        stopFocusModeIfNeeded()
        // 앰비언트 사운드 정지
        SoundManager.shared.stopAmbientSound()
        // 주의산만 알림 정지
    }
    
    func resetTimer() {
        pauseTimer()
        sessionStartTime = nil
        lastTickTimestamp = nil
        timeLeft = modeDurations[currentMode] ?? TimerMode.work.defaultDuration
        isOvertimeMode = false
        overtimeSeconds = 0
        elapsedWorkTime = 0  // 순수 작업시간 리셋
        isInitialDurationReached = false  // 플래그 리셋
    }
    
    private func tick() {
        guard let lastTick = lastTickTimestamp else { return }
        
        let now = Date()
        let delta = now.timeIntervalSince(lastTick)
        elapsedWorkTime += delta
        lastTickTimestamp = now
        
        let plannedDuration = TimeInterval(modeDurations[currentMode] ?? 0)
        
        // 설정 시간 도달 체크 (첫 번째 알림)
        if elapsedWorkTime >= plannedDuration && !isInitialDurationReached {
            isInitialDurationReached = true
            enterOvertimeMode()
            
            // 첫 번째 "띵" 소리 재생
            sendNotification()
            playSessionCompleteSound()
        }
        
        // UI 업데이트용 시간 계산
        if isOvertimeMode {
            overtimeSeconds = Int(elapsedWorkTime - plannedDuration)
            timeLeft = 0
        } else {
            let remaining = max(0, plannedDuration - elapsedWorkTime)
            timeLeft = Int(remaining)
        }
    }
    
    private func enterOvertimeMode() {
        isOvertimeMode = true
        // overtimeSeconds와 timeLeft는 tick()에서 계산됨
    }
    
    func stopOvertimeSession() {
        completeSession()
    }
    
    func stopBreakSession() {
        // 휴식 모드에서 Stop 버튼 클릭 시 즉시 완료
        completeSession()
    }
    
    private func completeSession() {
        pauseTimer()
        
        let endTime = Date()
        let plannedDuration = modeDurations[currentMode] ?? 0
        
        // 순수 작업시간 계산 (elapsedWorkTime 사용)
        let pureWorkTime = Int(elapsedWorkTime)
        
        // 세션 로그 생성
        let session = PomodoroSession(
            type: currentMode,
            plannedDuration: plannedDuration,
            actualDuration: pureWorkTime,
            overtimeSeconds: overtimeSeconds,
            startTime: sessionStartTime ?? endTime,
            endTime: endTime,
            workArea: currentWorkArea
        )
        
        sessionLogs.append(session)
        
        // 모든 모드에서 세션 완료 처리
        if currentMode == .work {
            // work 세션 통계 업데이트
            completedSessions += 1
            totalTime += pureWorkTime  // 순수 작업시간만 통계에 반영
            updateStreak()  // 스트릭 업데이트 (별도 함수로 분리)
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
        
        sessionStartTime = nil
        lastTickTimestamp = nil
        isOvertimeMode = false
        overtimeSeconds = 0
        elapsedWorkTime = 0  // 다음 세션을 위해 리셋
        isInitialDurationReached = false  // 플래그 리셋
        
        saveStats()
        
        // 세션 완료 알림 발송
        NotificationCenter.default.post(
            name: .sessionCompleted,
            object: session
        )
        
        // 알림 표시
        sendNotification()
        
        // 소리 재생
        playSessionCompleteSound()
    }
    
    // MARK: - Streak Management
    private func updateStreak() {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘 완료한 work 세션이 있는지 확인
        let todayWorkSessions = sessionLogs.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: today) && session.type == .work
        }
        
        // 오늘 첫 번째 work 세션이라면
        if todayWorkSessions.count == 1 {
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
            let yesterdayWorkSessions = sessionLogs.filter { session in
                calendar.isDate(session.startTime, inSameDayAs: yesterday) && session.type == .work
            }
            
            if yesterdayWorkSessions.isEmpty {
                // 어제 work 세션이 없었다면 스트릭 리셋
                streak = 1
            } else {
                // 어제 work 세션이 있었다면 스트릭 증가
                streak += 1
            }
        }
        // 오늘 두 번째 이상의 work 세션이라면 스트릭 변경 없음
    }
    
    // MARK: - Mode Management
    func switchMode(_ mode: TimerMode) {
        if mode != currentMode {
            pauseTimer()
            currentMode = mode
            timeLeft = modeDurations[mode] ?? mode.defaultDuration
            
            // 메뉴바 아이콘 업데이트 (모드 변경 시)
            MenuBarManager.shared.updateMenuBarIcon(for: currentMode, isRunning: isRunning)
        }
    }
    
    // MARK: - Statistics Management
    func resetAllStats() {
        completedSessions = 0
        totalTime = 0
        streak = 0
        sessionNumber = 1
        sessionLogs.removeAll()
        saveStats()
    }
    
    func getSessionsForDate(_ date: Date) -> [PomodoroSession] {
        let calendar = Calendar.current
        return sessionLogs.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: date)
        }
    }
    
    func getAllSessions() -> [PomodoroSession] {
        return sessionLogs
    }
    
    func resetTodayStats() {
        let calendar = Calendar.current
        let today = Date()
        
        // 오늘 생성된 work 세션들만 필터링해서 제거
        let todayWorkSessions = sessionLogs.filter { session in
            calendar.isDate(session.startTime, inSameDayAs: today) && session.type == .work
        }
        
        // 오늘 모든 세션들을 전체 로그에서 제거 (work, break 포함)
        sessionLogs.removeAll { session in
            calendar.isDate(session.startTime, inSameDayAs: today)
        }
        
        // 오늘 work 세션들의 통계만 전체 통계에서 차감
        let todayCompletedSessions = todayWorkSessions.count
        let todayTotalTime = todayWorkSessions.reduce(0) { $0 + $1.actualDuration }
        
        completedSessions = max(0, completedSessions - todayCompletedSessions)
        totalTime = max(0, totalTime - todayTotalTime)
        
        // 스트릭은 오늘 work 세션이 있었다면 0으로 리셋 (연속성이 끊어짐)
        if !todayWorkSessions.isEmpty {
            streak = 0
        }
        
        saveStats()
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
        if isOvertimeMode {
            let minutes = overtimeSeconds / 60
            let seconds = overtimeSeconds % 60
            return String(format: "+%02d:%02d", minutes, seconds)
        } else {
            let minutes = timeLeft / 60
            let seconds = timeLeft % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    var progress: Double {
        if isOvertimeMode {
            return 1.0
        } else {
            let totalDuration = modeDurations[currentMode] ?? 1
            return Double(totalDuration - timeLeft) / Double(totalDuration)
        }
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
    
    // MARK: - Sound Management
    private func playSessionCompleteSound() {
        // 현재 설정된 알림음 재생
        if let soundRaw = UserDefaults.standard.string(forKey: "notificationSound"),
           let sound = NotificationSound(rawValue: soundRaw) {
            SoundManager.shared.playNotificationSound(sound)
        } else {
            SoundManager.shared.playNotificationSound(.default)
        }
    }
    
    private func startAmbientSoundIfNeeded() {
        // work 세션에서만 앰비언트 사운드 재생
        guard currentMode == .work else { return }
        
        // 앰비언트 사운드 설정 확인
        if let ambientRaw = UserDefaults.standard.string(forKey: "ambientSound"),
           let ambientSound = AmbientSound(rawValue: ambientRaw),
           ambientSound != .none {
            let volume = UserDefaults.standard.object(forKey: "ambientVolume") as? Double ?? 0.5
            SoundManager.shared.startAmbientSound(ambientSound, volume: Float(volume))
        }
    }
    
    private func startFocusModeIfNeeded() {
        // 포커스 모드 설정 확인
        let enableFocusMode = UserDefaults.standard.bool(forKey: "enableFocusMode")
        
        if enableFocusMode {
            if let focusModeRaw = UserDefaults.standard.string(forKey: "macOSFocusMode"),
               let focusMode = MacOSFocusMode(rawValue: focusModeRaw),
               focusMode != .none {
                FocusManager.shared.activateFocusMode(focusMode)
            }
        }
    }
    
    private func stopFocusModeIfNeeded() {
        // 포커스 모드가 활성화되어 있다면 비활성화
        if FocusManager.shared.isActiveFocusMode {
            FocusManager.shared.deactivateFocusMode()
        }
    }
}

// MARK: - Notification Extensions
extension Notification.Name {
    static let sessionCompleted = Notification.Name("sessionCompleted")
}

// MARK: - 임시 PomodoroSession 구조체 (추후 Core Data 모델로 교체)
struct PomodoroSession {
    let id = UUID()
    let type: TimerMode
    let plannedDuration: Int
    let actualDuration: Int
    let overtimeSeconds: Int
    let startTime: Date
    let endTime: Date
    let workArea: String
    let completed: Bool = true
    var reviewNote: String = ""
    
    var formattedDuration: String {
        let minutes = actualDuration / 60
        let seconds = actualDuration % 60
        
        if overtimeSeconds > 0 {
            let overtimeMinutes = overtimeSeconds / 60
            let overtimeSecs = overtimeSeconds % 60
            return String(format: "%d:%02d (+%d:%02d)", minutes, seconds, overtimeMinutes, overtimeSecs)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var pureWorkTimeFormatted: String {
        let minutes = actualDuration / 60
        let seconds = actualDuration % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var overtimeFormatted: String {
        if overtimeSeconds > 0 {
            let minutes = overtimeSeconds / 60
            let seconds = overtimeSeconds % 60
            return String(format: "+%d:%02d", minutes, seconds)
        }
        return ""
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var typeDisplayName: String {
        switch type {
        case .work: return "Work"
        case .shortBreak: return "Short Break"
        case .longBreak: return "Long Break"
        }
    }
    
    var typeIcon: String {
        switch type {
        case .work: return "📚"
        case .shortBreak: return "☕"
        case .longBreak: return "🛋️"
        }
    }
}