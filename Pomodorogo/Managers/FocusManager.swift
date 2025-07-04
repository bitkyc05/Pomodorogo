import Foundation
import AppKit

// MARK: - macOS 집중 모드 관리자
class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var isActiveFocusMode = false
    @Published var currentActiveFocusMode: MacOSFocusMode = .none
    
    private init() {}
    
    // MARK: - 집중 모드 활성화
    func activateFocusMode(_ mode: MacOSFocusMode) {
        guard mode != .none, let identifier = mode.identifier else {
            deactivateFocusMode()
            return
        }
        
        // AppleScript를 통해 집중 모드 활성화
        let script = """
        tell application "System Events"
            tell process "ControlCenter"
                set frontmost to true
                delay 0.5
            end tell
        end tell
        
        do shell script "shortcuts run 'Set Focus' --input-path /dev/null" || true
        """
        
        // 더 직접적인 방법: 시스템 알림을 통한 집중 모드 활성화
        activateFocusModeDirectly(identifier)
    }
    
    // MARK: - 집중 모드 비활성화
    func deactivateFocusMode() {
        let script = """
        tell application "System Events"
            key code 53 using {command down, shift down}
        end tell
        """
        
        executeAppleScript(script)
        
        DispatchQueue.main.async {
            self.isActiveFocusMode = false
            self.currentActiveFocusMode = .none
        }
    }
    
    // MARK: - 직접적인 집중 모드 활성화 (NSUserNotification 사용)
    private func activateFocusModeDirectly(_ identifier: String) {
        // Shortcuts 앱을 통한 집중 모드 활성화
        let shortcutScript = """
        tell application "Shortcuts Events"
            run the shortcut named "Focus Mode Toggle"
        end tell
        """
        
        // 또는 더 간단한 방법: 시스템 단축키 시뮬레이션
        let focusShortcut = """
        tell application "System Events"
            -- 제어 센터 열기 (Command + Space 후 "Focus" 입력)
            keystroke space using command down
            delay 1
            keystroke "Focus"
            delay 1
            key code 36
        end tell
        """
        
        executeAppleScript(focusShortcut)
        
        DispatchQueue.main.async {
            self.isActiveFocusMode = true
            self.currentActiveFocusMode = MacOSFocusMode(rawValue: identifier.components(separatedBy: ".").last ?? "") ?? .doNotDisturb
        }
    }
    
    // MARK: - AppleScript 실행
    private func executeAppleScript(_ script: String) {
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            
            if let scriptObject = NSAppleScript(source: script) {
                scriptObject.executeAndReturnError(&error)
                
                if let error = error {
                    print("AppleScript Error: \(error)")
                }
            }
        }
    }
    
    // MARK: - 현재 집중 모드 상태 확인
    func checkCurrentFocusMode() {
        // 시스템의 현재 집중 모드 상태를 확인하는 로직
        // 이는 시스템 API 한계로 정확한 구현이 어려울 수 있음
        let script = """
        tell application "System Events"
            tell process "ControlCenter"
                return exists (UI elements whose name contains "Focus")
            end tell
        end tell
        """
        
        executeAppleScript(script)
    }
    
    // MARK: - 단축키를 통한 집중 모드 토글
    func toggleFocusModeWithShortcut() {
        // macOS Monterey 이상에서 사용 가능한 집중 모드 단축키
        // Control + Option + F (사용자가 설정한 경우)
        let script = """
        tell application "System Events"
            key code 3 using {control down, option down}
        end tell
        """
        
        executeAppleScript(script)
        
        // 상태 토글
        DispatchQueue.main.async {
            self.isActiveFocusMode.toggle()
            if !self.isActiveFocusMode {
                self.currentActiveFocusMode = .none
            }
        }
    }
    
    // MARK: - 알림 권한 요청
    func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
}

// MARK: - UserNotifications Import
import UserNotifications