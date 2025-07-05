//
//  PomodorogoApp.swift
//  Pomodorogo
//
//  Created by 김병준 on 7/5/25.
//

import SwiftUI

@main
struct PomodorogoApp: App {
    @StateObject private var timerViewModel = TimerViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @StateObject private var reviewViewModel = ReviewViewModel()
    @StateObject private var focusManager = FocusManager.shared
    @StateObject private var menuBarManager = MenuBarManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(reviewViewModel)
                .environmentObject(focusManager)
                .onAppear {
                    // Request notification permission
                    focusManager.requestNotificationPermission()
                    
                    // ReviewViewModel에 TimerViewModel 연결
                    reviewViewModel.timerViewModel = timerViewModel
                    
                    // MenuBarManager에 ViewModels 연결
                    menuBarManager.timerViewModel = timerViewModel
                    menuBarManager.settingsViewModel = settingsViewModel
                    
                    // 메뉴바 설정 확인 후 활성화
                    if settingsViewModel.settings.enableMenuBarApp {
                        menuBarManager.enableMenuBar()
                    }
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 700)
        .commands {
            // 뽀모도로 전용 메뉴 추가
            pomodoroCommands
        }
        
        // Settings 창을 위한 별도 WindowGroup
        WindowGroup("Settings", id: "settings") {
            SettingsView()
                .environmentObject(timerViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(reviewViewModel)
                .environmentObject(focusManager)
        }
        .windowResizability(.contentSize) // 창 크기 조절 비활성화
        .defaultSize(width: 500, height: 600) // 기본 크기 설정
        
        // Review 창을 위한 별도 WindowGroup
        WindowGroup("Daily Review", id: "review") {
            ReviewView()
                .environmentObject(timerViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(reviewViewModel)
                .environmentObject(focusManager)
        }
        .windowResizability(.contentSize) // 창 크기 조절 비활성화
        .defaultSize(width: 600, height: 700) // 기본 크기 설정
    }
    
    // MARK: - 뽀모도로 전용 메뉴 커맨드
    private var pomodoroCommands: some Commands {
        Group {
            // Timer 메뉴
            CommandMenu("Timer") {
                Button(timerViewModel.isRunning ? "⏸ Pause Timer" : "▶️ Start Timer") {
                    timerViewModel.toggleTimer()
                }
                .keyboardShortcut(.space, modifiers: [.command])
                
                Button("🔄 Reset Timer") {
                    timerViewModel.resetTimer()
                }
                .keyboardShortcut("r", modifiers: [.command])
                
                Divider()
                
                Button("🍅 Work Session") {
                    timerViewModel.switchMode(.work)
                }
                .keyboardShortcut("1", modifiers: [.command])
                
                Button("☕ Short Break") {
                    timerViewModel.switchMode(.shortBreak)
                }
                .keyboardShortcut("2", modifiers: [.command])
                
                Button("🛋️ Long Break") {
                    timerViewModel.switchMode(.longBreak)
                }
                .keyboardShortcut("3", modifiers: [.command])
            }
            
            // Focus 메뉴
            CommandMenu("Focus") {
                Button("🎯 Enable Focus Mode") {
                    // Focus mode toggle
                }
                .disabled(!settingsViewModel.settings.enableFocusMode)
                
                Button("🔇 Enable Do Not Disturb") {
                    // DND toggle
                }
                
                Divider()
                
                Button("📊 View Statistics") {
                    // Statistics view
                }
                .keyboardShortcut("s", modifiers: [.command])
                
                Button("📝 Daily Review") {
                    // Open review window
                }
                .keyboardShortcut("d", modifiers: [.command])
            }
            
            // 기본 Edit 메뉴 제거하고 뽀모도로용 Edit 메뉴 추가
            CommandGroup(replacing: .newItem) {
                Button("🏆 New Work Session") {
                    timerViewModel.switchMode(.work)
                    timerViewModel.resetTimer()
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
            
            // 기본 File 메뉴 일부 교체
            CommandGroup(after: .newItem) {
                Button("💾 Export Daily Report") {
                    reviewViewModel.saveMarkdownToFile()
                }
                .keyboardShortcut("e", modifiers: [.command])
                
                Button("📋 Copy Statistics") {
                    reviewViewModel.copyToClipboard()
                }
                .keyboardShortcut("c", modifiers: [.command, .shift])
            }
            
            // Window 메뉴 커스터마이징
            CommandGroup(after: .windowArrangement) {
                Button("⚙️ Preferences") {
                    // Open settings window
                }
                .keyboardShortcut(",", modifiers: [.command])
                
                Button("📝 Daily Review") {
                    // Open review window  
                }
                .keyboardShortcut("r", modifiers: [.command, .shift])
            }
        }
    }
}
