import Foundation
import SwiftUI
import AppKit

// MARK: - MenuBarManager
class MenuBarManager: ObservableObject {
    static let shared = MenuBarManager()
    
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    weak var timerViewModel: TimerViewModel?
    weak var settingsViewModel: SettingsViewModel?
    
    @Published var isMenuBarEnabled = false
    
    private init() {}
    
    // MARK: - Menu Bar Control
    func enableMenuBar() {
        guard statusItem == nil else { return }
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            // 템플릿 이미지로 설정 (다크모드 자동 대응)
            if let timerImage = NSImage(systemSymbolName: "timer", accessibilityDescription: "Pomodoro Timer") {
                timerImage.isTemplate = true
                button.image = timerImage
            } else {
                // 시스템 심볼이 없으면 텍스트로 표시
                button.title = "🍅"
            }
            
            button.action = #selector(statusItemClicked)
            button.target = self
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            
            // 툴팁 추가
            button.toolTip = "Pomodoro Timer"
        }
        
        isMenuBarEnabled = true
        setupPopover()
    }
    
    func disableMenuBar() {
        if let statusItem = statusItem {
            NSStatusBar.system.removeStatusItem(statusItem)
            self.statusItem = nil
        }
        popover = nil
        isMenuBarEnabled = false
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.behavior = .transient
        popover?.contentSize = NSSize(width: 400, height: 300)
        
        let contentView = MenuBarContentView()
            .environmentObject(timerViewModel ?? TimerViewModel())
            .environmentObject(settingsViewModel ?? SettingsViewModel())
        
        popover?.contentViewController = NSHostingController(rootView: contentView)
    }
    
    @objc private func statusItemClicked() {
        guard let button = statusItem?.button else { return }
        
        let event = NSApp.currentEvent!
        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover(button)
        }
    }
    
    private func togglePopover(_ sender: NSStatusBarButton) {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .minY)
            }
        }
    }
    
    private func showContextMenu() {
        let menu = NSMenu()
        
        // Timer controls
        if let timerViewModel = timerViewModel {
            let timerTitle = timerViewModel.isRunning ? "⏸ Pause" : "▶️ Start"
            menu.addItem(NSMenuItem(title: timerTitle, action: #selector(toggleTimer), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: "🔄 Reset", action: #selector(resetTimer), keyEquivalent: ""))
            menu.addItem(NSMenuItem.separator())
            
            // Current status
            let statusTitle = "\(timerViewModel.currentMode.displayName) - \(timerViewModel.formattedTime)"
            let statusItem = NSMenuItem(title: statusTitle, action: nil, keyEquivalent: "")
            statusItem.isEnabled = false
            menu.addItem(statusItem)
            menu.addItem(NSMenuItem.separator())
        }
        
        // Quick actions
        menu.addItem(NSMenuItem(title: "⚙️ Settings", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "📝 Review", action: #selector(openReview), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        
        // App controls
        menu.addItem(NSMenuItem(title: "🔍 Show Main Window", action: #selector(showMainWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "❌ Quit Pomodorogo", action: #selector(quitApp), keyEquivalent: "q"))
        
        menu.items.forEach { $0.target = self }
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    // MARK: - Menu Actions
    @objc private func toggleTimer() {
        timerViewModel?.toggleTimer()
    }
    
    @objc private func resetTimer() {
        timerViewModel?.resetTimer()
    }
    
    @objc private func openSettings() {
        // 기존 설정 창이 있으면 포커스
        for window in NSApp.windows {
            if window.title.contains("Settings") || window.identifier?.rawValue == "settings" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        // 새 설정 창이 필요한 경우 - 메인 창을 통해 설정을 열도록 함
        showMainWindow()
    }
    
    @objc private func openReview() {
        // 기존 리뷰 창이 있으면 포커스  
        for window in NSApp.windows {
            if window.title.contains("Review") || window.identifier?.rawValue == "review" {
                window.makeKeyAndOrderFront(nil)
                return
            }
        }
        // 새 리뷰 창이 필요한 경우 - 메인 창을 통해 리뷰를 열도록 함
        showMainWindow()
    }
    
    @objc private func showMainWindow() {
        NSApp.windows.first?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func quitApp() {
        NSApp.terminate(nil)
    }
    
    // MARK: - Status Updates
    func updateMenuBarIcon(for mode: TimerMode, isRunning: Bool) {
        guard let button = statusItem?.button else { return }
        
        let iconName: String
        let emoji: String
        
        switch mode {
        case .work:
            iconName = isRunning ? "play.circle.fill" : "play.circle"
            emoji = isRunning ? "▶️" : "🍅"
        case .shortBreak, .longBreak:
            iconName = isRunning ? "pause.circle.fill" : "pause.circle"
            emoji = isRunning ? "⏸️" : "☕"
        }
        
        if let statusImage = NSImage(systemSymbolName: iconName, accessibilityDescription: "Pomodoro Timer") {
            statusImage.isTemplate = true
            button.image = statusImage
            button.title = "" // 이미지가 있으면 텍스트 제거
        } else {
            // 시스템 심볼이 없으면 이모지로 표시
            button.image = nil
            button.title = emoji
        }
    }
    
    func updateMenuBarTitle(_ title: String) {
        statusItem?.button?.title = title
    }
}

// MARK: - MenuBar Content View
struct MenuBarContentView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        VStack(spacing: 16) {
            // Timer Display
            VStack(spacing: 8) {
                Text(timerViewModel.currentMode.displayName)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(timerViewModel.formattedTime)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
                
                // Progress Ring (simplified)
                ProgressView(value: timerViewModel.progress)
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(0.8)
            }
            
            // Controls
            HStack(spacing: 12) {
                Button(action: { timerViewModel.toggleTimer() }) {
                    Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
                
                Button(action: { timerViewModel.resetTimer() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                }
                .buttonStyle(.bordered)
            }
            
            // Quick Stats
            HStack(spacing: 16) {
                VStack {
                    Text("\(timerViewModel.completedSessions)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Sessions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text(timerViewModel.formattedTotalTime)
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Total")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack {
                    Text("\(timerViewModel.streak)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            // Quick Actions
            HStack(spacing: 8) {
                Button("Settings") {
                    openWindow(id: "settings")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Review") {
                    openWindow(id: "review")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                
                Button("Main App") {
                    NSApp.windows.first?.makeKeyAndOrderFront(nil)
                    NSApp.activate(ignoringOtherApps: true)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
    }
}

#Preview {
    MenuBarContentView()
        .environmentObject(TimerViewModel())
        .environmentObject(SettingsViewModel())
}