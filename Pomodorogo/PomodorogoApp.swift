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
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 700)
        
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
}
