import Foundation
import AppKit

class KeyboardShortcutManager: ObservableObject {
    static let shared = KeyboardShortcutManager()
    
    private var isEnabled = true
    private var localEventMonitor: Any?
    
    private init() {
        // Initialize without setting up monitors
    }
    
    deinit {
        setEnabled(false)
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        if enabled {
            setupLocalEventMonitor()
        } else {
            removeEventMonitor()
        }
    }
    
    private func setupLocalEventMonitor() {
        removeEventMonitor()
        
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
    }
    
    private func removeEventMonitor() {
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
    }
    
    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        guard isEnabled else { return event }
        
        // Check if any text field is currently being edited
        if NSApp.keyWindow?.firstResponder is NSText {
            return event
        }
        
        let keyCode = event.keyCode
        let modifierFlags = event.modifierFlags
        
        // Only process events without modifiers or with minimal modifiers
        if modifierFlags.intersection([.command, .option, .control]).isEmpty {
            switch keyCode {
            case 49: // Space key
                NotificationCenter.default.post(name: .toggleTimer, object: nil)
                return nil // Consume the event
                
            case 15: // R key
                NotificationCenter.default.post(name: .resetTimer, object: nil)
                return nil
                
            case 1: // S key
                NotificationCenter.default.post(name: .openSettings, object: nil)
                return nil
                
            case 9: // V key
                NotificationCenter.default.post(name: .openReview, object: nil)
                return nil
                
            default:
                break
            }
        }
        
        return event
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let toggleTimer = Notification.Name("toggleTimer")
    static let resetTimer = Notification.Name("resetTimer")
    static let openSettings = Notification.Name("openSettings")
    static let openReview = Notification.Name("openReview")
}