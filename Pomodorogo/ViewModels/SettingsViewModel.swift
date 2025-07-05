import Foundation
import Combine
import AppKit

// MARK: - macOS 집중 모드 열거형
enum MacOSFocusMode: String, CaseIterable {
    case none = "none"
    case doNotDisturb = "do-not-disturb"
    case personal = "personal"
    case work = "work"
    case sleep = "sleep"
    
    var displayName: String {
        switch self {
        case .none: return "사용 안함"
        case .doNotDisturb: return "방해 금지"
        case .personal: return "개인 시간"
        case .work: return "업무"
        case .sleep: return "수면"
        }
    }
    
    var identifier: String? {
        switch self {
        case .none: return nil
        case .doNotDisturb: return "com.apple.donotdisturb.mode.default"
        case .personal: return "com.apple.donotdisturb.mode.personal"
        case .work: return "com.apple.donotdisturb.mode.work"
        case .sleep: return "com.apple.donotdisturb.mode.sleep"
        }
    }
}

// MARK: - 설정 모델
struct PomodoroSettings {
    var workDuration: Int = 25 * 60      // 25분
    var shortBreakDuration: Int = 5 * 60  // 5분
    var longBreakDuration: Int = 15 * 60  // 15분
    
    var notificationSound: NotificationSound = .default
    var enableNotifications: Bool = true
    var enableFocusMode: Bool = false
    var macOSFocusMode: MacOSFocusMode = .none
    var enableDistractionAlerts: Bool = false
    
    var ambientSound: AmbientSound = .none
    var ambientVolume: Double = 0.5
    
    var enableMenuBarApp: Bool = false
    var hideDockIcon: Bool = false
    var enableGlobalShortcuts: Bool = true
}

// MARK: - 알림음 열거형
enum NotificationSound: String, CaseIterable {
    case none = "none"
    case `default` = "default"
    case bell = "bell"
    case chime = "chime"
    
    var displayName: String {
        switch self {
        case .none: return "No Sound"
        case .default: return "Default Beep"
        case .bell: return "Bell"
        case .chime: return "Chime"
        }
    }
}

// MARK: - 앰비언트 사운드 열거형
enum AmbientSound: String, CaseIterable {
    case none = "none"
    case rain = "rain"
    case ocean = "ocean"
    case forest = "forest"
    case cafe = "cafe"
    case whiteNoise = "whitenoise"
    
    var displayName: String {
        switch self {
        case .none: return "No Sound"
        case .rain: return "Rain"
        case .ocean: return "Ocean Waves"
        case .forest: return "Forest"
        case .cafe: return "Coffee Shop"
        case .whiteNoise: return "White Noise"
        }
    }
}

// MARK: - 설정 ViewModel
class SettingsViewModel: ObservableObject {
    
    @Published var settings = PomodoroSettings()
    
    private let userDefaults = UserDefaults.standard
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        loadSettingsInternal()
        
        // 설정 변경 시 자동 저장 비활성화 (명시적 저장으로 변경)
        // 사용자가 Save 버튼을 눌렀을 때만 저장되도록 함
    }
    
    // MARK: - Duration Helpers
    var workDurationMinutes: Int {
        get { settings.workDuration / 60 }
        set { settings.workDuration = newValue * 60 }
    }
    
    var shortBreakDurationMinutes: Int {
        get { settings.shortBreakDuration / 60 }
        set { settings.shortBreakDuration = newValue * 60 }
    }
    
    var longBreakDurationMinutes: Int {
        get { settings.longBreakDuration / 60 }
        set { settings.longBreakDuration = newValue * 60 }
    }
    
    var ambientVolumePercentage: Int {
        get { Int(settings.ambientVolume * 100) }
        set { settings.ambientVolume = Double(newValue) / 100.0 }
    }
    
    // MARK: - Methods
    func resetToDefaults() {
        settings = PomodoroSettings()
    }
    
    func updateWorkDuration(minutes: Int) {
        guard minutes >= 1 && minutes <= 60 else { return }
        workDurationMinutes = minutes
    }
    
    func updateShortBreakDuration(minutes: Int) {
        guard minutes >= 1 && minutes <= 30 else { return }
        shortBreakDurationMinutes = minutes
    }
    
    func updateLongBreakDuration(minutes: Int) {
        guard minutes >= 1 && minutes <= 60 else { return }
        longBreakDurationMinutes = minutes
    }
    
    func playNotificationSoundPreview() {
        // SoundManager를 통해 미리듣기 구현
        SoundManager.shared.playNotificationSoundPreview(settings.notificationSound)
    }
    
    func playAmbientSoundPreview() {
        // SoundManager를 통해 미리듣기 구현
        SoundManager.shared.playAmbientSoundPreview(settings.ambientSound, volume: Float(settings.ambientVolume))
    }
    
    // MARK: - Public Methods
    func saveSettings() {
        let previousMenuBarEnabled = userDefaults.object(forKey: "enableMenuBarApp") as? Bool ?? false
        let previousHideDockIcon = userDefaults.object(forKey: "hideDockIcon") as? Bool ?? false
        
        saveSettingsInternal()
        
        // 메뉴바 설정 변경 처리
        if settings.enableMenuBarApp != previousMenuBarEnabled {
            if settings.enableMenuBarApp {
                MenuBarManager.shared.enableMenuBar()
            } else {
                MenuBarManager.shared.disableMenuBar()
            }
        }
        
        // 독 아이콘 숨김 설정 변경 처리
        if settings.hideDockIcon != previousHideDockIcon {
            updateDockIconVisibility()
        }
        
        // 타이머 ViewModel에게 설정 변경 알림
        NotificationCenter.default.post(name: .settingsDidChange, object: settings)
    }
    
    private func updateDockIconVisibility() {
        if settings.enableMenuBarApp && settings.hideDockIcon {
            NSApp.setActivationPolicy(.accessory)
        } else {
            NSApp.setActivationPolicy(.regular)
        }
    }
    
    func loadSettings() {
        loadSettingsInternal()
        // UI 업데이트를 위해 objectWillChange 신호 전송
        objectWillChange.send()
    }
    
    // MARK: - Data Persistence
    private func loadSettingsInternal() {
        // 기본값들
        settings.workDuration = userDefaults.object(forKey: "workDuration") as? Int ?? 25 * 60
        settings.shortBreakDuration = userDefaults.object(forKey: "shortBreakDuration") as? Int ?? 5 * 60
        settings.longBreakDuration = userDefaults.object(forKey: "longBreakDuration") as? Int ?? 15 * 60
        
        // 알림 설정
        if let soundRaw = userDefaults.string(forKey: "notificationSound"),
           let sound = NotificationSound(rawValue: soundRaw) {
            settings.notificationSound = sound
        }
        settings.enableNotifications = userDefaults.object(forKey: "enableNotifications") as? Bool ?? true
        settings.enableFocusMode = userDefaults.object(forKey: "enableFocusMode") as? Bool ?? false
        if let focusModeRaw = userDefaults.string(forKey: "macOSFocusMode"),
           let focusMode = MacOSFocusMode(rawValue: focusModeRaw) {
            settings.macOSFocusMode = focusMode
        }
        settings.enableDistractionAlerts = userDefaults.object(forKey: "enableDistractionAlerts") as? Bool ?? false
        
        // 앰비언트 사운드 설정
        if let ambientRaw = userDefaults.string(forKey: "ambientSound"),
           let ambient = AmbientSound(rawValue: ambientRaw) {
            settings.ambientSound = ambient
        }
        settings.ambientVolume = userDefaults.object(forKey: "ambientVolume") as? Double ?? 0.5
        
        // 앱 설정
        settings.enableMenuBarApp = userDefaults.object(forKey: "enableMenuBarApp") as? Bool ?? false
        settings.hideDockIcon = userDefaults.object(forKey: "hideDockIcon") as? Bool ?? false
        settings.enableGlobalShortcuts = userDefaults.object(forKey: "enableGlobalShortcuts") as? Bool ?? true
    }
    
    private func saveSettingsInternal() {
        // 기본값들
        userDefaults.set(settings.workDuration, forKey: "workDuration")
        userDefaults.set(settings.shortBreakDuration, forKey: "shortBreakDuration")
        userDefaults.set(settings.longBreakDuration, forKey: "longBreakDuration")
        
        // 알림 설정
        userDefaults.set(settings.notificationSound.rawValue, forKey: "notificationSound")
        userDefaults.set(settings.enableNotifications, forKey: "enableNotifications")
        userDefaults.set(settings.enableFocusMode, forKey: "enableFocusMode")
        userDefaults.set(settings.macOSFocusMode.rawValue, forKey: "macOSFocusMode")
        userDefaults.set(settings.enableDistractionAlerts, forKey: "enableDistractionAlerts")
        
        // 앰비언트 사운드 설정
        userDefaults.set(settings.ambientSound.rawValue, forKey: "ambientSound")
        userDefaults.set(settings.ambientVolume, forKey: "ambientVolume")
        
        // 앱 설정
        userDefaults.set(settings.enableMenuBarApp, forKey: "enableMenuBarApp")
        userDefaults.set(settings.hideDockIcon, forKey: "hideDockIcon")
        userDefaults.set(settings.enableGlobalShortcuts, forKey: "enableGlobalShortcuts")
        
        // 설정 변경 알림 전송
        NotificationCenter.default.post(name: .settingsDidChange, object: settings)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let settingsDidChange = Notification.Name("settingsDidChange")
}