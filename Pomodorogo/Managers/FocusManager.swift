import Foundation
import AppKit
import Intents
import UserNotifications

// MARK: - macOS Focus Mode Manager
class FocusManager: ObservableObject {
    static let shared = FocusManager()
    
    @Published var isActiveFocusMode = false
    @Published var currentActiveFocusMode: MacOSFocusMode = .none
    @Published var isFocusStatusAuthorized = false
    
    private init() {
        checkAuthorizationStatus()
    }
    
    // MARK: - Check Focus Mode Authorization Status
    private func checkAuthorizationStatus() {
        // Skip INFocusStatusCenter for now to avoid crashes
        DispatchQueue.main.async {
            self.isFocusStatusAuthorized = false
        }
    }
    
    // MARK: - Request Focus Mode Authorization
    func requestFocusAuthorization(completion: @escaping (Bool) -> Void) {
        // For now, skip the INFocusStatusCenter API to avoid crashes
        // Focus Mode will work through AppleScript automation
        print("Focus Mode will use AppleScript automation instead of INFocusStatusCenter")
        completion(true) // Return true to continue with AppleScript approach
    }
    
    // MARK: - Check Current Focus Status
    func checkFocusStatus() -> Bool {
        // Use AppleScript to check Focus Mode status
        return false // For now, return false - can be enhanced later
    }
    
    // MARK: - Activate Focus Mode
    func activateFocusMode(_ mode: MacOSFocusMode) {
        guard mode != .none else {
            deactivateFocusMode()
            return
        }
        
        // First try to use the native API
        if #available(macOS 12.0, *) {
            requestFocusAuthorization { [weak self] authorized in
                if authorized {
                    self?.activateFocusModeWithIntent(mode)
                } else {
                    // Fall back to AppleScript if not authorized
                    self?.activateFocusModeWithAppleScript(mode)
                }
            }
        } else {
            // Fall back to AppleScript for older macOS versions
            activateFocusModeWithAppleScript(mode)
        }
    }
    
    // MARK: - Activate Focus Mode with Intent
    @available(macOS 12.0, *)
    private func activateFocusModeWithIntent(_ mode: MacOSFocusMode) {
        // For now, fall back to AppleScript as the native Focus Mode intent API
        // is primarily for iOS and has limited macOS support
        print("Focus Mode intent not fully supported on macOS, using AppleScript fallback")
        activateFocusModeWithAppleScript(mode)
    }
    
    // MARK: - Activate Focus Mode with AppleScript (Fallback)
    private func activateFocusModeWithAppleScript(_ mode: MacOSFocusMode) {
        // 집중모드 기능 비활성화
        print("Focus Mode activation disabled - feature commented out")
        /*
        // Request automation permission if needed
        requestAutomationPermissionIfNeeded { [weak self] granted in
            DispatchQueue.main.async {
                if granted {
                    self?.performAppleScriptFocusActivation(mode)
                } else {
                    self?.showPermissionAlert()
                }
            }
        }
        */
    }
    
    private func performAppleScriptFocusActivation(_ mode: MacOSFocusMode) {
        // Try using Shortcuts app first (more reliable)
        let shortcutsScript = """
        do shell script "shortcuts run 'Toggle Focus' 2>/dev/null || echo 'Shortcuts not available'"
        """
        
        // Alternative: Control Center approach
        let controlCenterScript = """
        tell application "System Events"
            tell process "ControlCenter"
                try
                    set frontmost to true
                    delay 1
                    click menu bar item 1 of menu bar 1
                    delay 1
                    -- Focus button click
                    click button "Focus" of group 1 of scroll area 1 of window 1
                    delay 0.5
                end try
            end tell
        end tell
        """
        
        executeAppleScript(shortcutsScript) { [weak self] success in
            if !success {
                self?.executeAppleScript(controlCenterScript)
            }
        }
        
        DispatchQueue.main.async {
            self.isActiveFocusMode = true
            self.currentActiveFocusMode = mode
        }
    }
    
    // MARK: - Deactivate Focus Mode
    func deactivateFocusMode() {
        // Use AppleScript for deactivation since intent API is limited on macOS
        deactivateFocusModeWithAppleScript()
    }
    
    private func deactivateFocusModeWithAppleScript() {
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
    
    // MARK: - Permission Management
    private func requestAutomationPermissionIfNeeded(completion: @escaping (Bool) -> Void) {
        // Test AppleScript execution for automation permission
        let testScript = """
        tell application "System Events"
            return name of first process
        end tell
        """
        
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            
            if let scriptObject = NSAppleScript(source: testScript) {
                let result = scriptObject.executeAndReturnError(&error)
                
                DispatchQueue.main.async {
                    completion(error == nil && result.stringValue != nil)
                }
            } else {
                DispatchQueue.main.async {
                    completion(false)
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        // 권한 알림 주석처리 - 집중모드 기능 비활성화
        /*
        let alert = NSAlert()
        alert.messageText = "Automation Permission Required"
        alert.informativeText = """
        To control Focus mode, Pomodoro needs permission to control System Events.
        
        Please follow these steps:
        1. Go to System Settings > Privacy & Security > Automation
        2. Find 'Pomodoro' and enable 'System Events'
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Cancel")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // Open automation settings
            if #available(macOS 13.0, *) {
                // For macOS Ventura and later
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation")!)
            } else {
                // For older macOS versions
                let script = """
                tell application "System Preferences"
                    activate
                    reveal anchor "Privacy_Automation" of pane "com.apple.preference.security"
                end tell
                """
                executeAppleScript(script)
            }
        }
        */
        print("Focus Mode permissions disabled - feature commented out")
    }
    
    // MARK: - AppleScript Execution
    private func executeAppleScript(_ script: String, completion: ((Bool) -> Void)? = nil) {
        DispatchQueue.global(qos: .userInitiated).async {
            var error: NSDictionary?
            var success = false
            
            if let scriptObject = NSAppleScript(source: script) {
                let result = scriptObject.executeAndReturnError(&error)
                success = (error == nil)
                
                if let error = error {
                    print("AppleScript Error: \(error)")
                } else {
                    print("AppleScript Success: \(result.stringValue ?? "")")
                }
            }
            
            DispatchQueue.main.async {
                completion?(success)
            }
        }
    }
    
    // MARK: - Show Focus Mode Permission Alert
    func showFocusPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Focus Mode Permission Required"
        alert.informativeText = """
        To integrate with Focus Mode, Pomodoro needs permission to check Focus status.
        
        Please follow these steps:
        1. Go to System Settings > Focus
        2. Enable 'Share Focus Status' 
        3. Allow Pomodoro to access Focus status when prompted
        """
        alert.alertStyle = .informational
        alert.addButton(withTitle: "Open Focus Settings")
        alert.addButton(withTitle: "Later")
        
        let response = alert.runModal()
        
        if response == .alertFirstButtonReturn {
            // Open Focus settings
            if #available(macOS 13.0, *) {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications?Focus")!)
            } else {
                NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.notifications")!)
            }
        }
    }
    
    // MARK: - Request Notification Permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                if let error = error {
                    print("Notification permission error: \(error)")
                }
            }
    }
}