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
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(timerViewModel)
                .environmentObject(settingsViewModel)
                .environmentObject(reviewViewModel)
        }
    }
}
