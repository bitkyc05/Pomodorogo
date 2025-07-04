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
                }
        }
        .windowResizability(.contentSize)
        .defaultSize(width: 480, height: 700)
    }
}
