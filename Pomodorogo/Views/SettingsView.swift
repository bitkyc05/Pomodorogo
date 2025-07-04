import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // 타이머 지속시간 설정
                timerDurationSection
                
                // 알림 설정
                notificationSection
                
                // 앰비언트 사운드 설정
                ambientSoundSection
                
                // 고급 설정
                advancedSection
                
                // 액션 버튼들
                actionSection
            }
            .formStyle(.grouped)
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 500, height: 600)
    }
    
    // MARK: - Timer Duration Section
    private var timerDurationSection: some View {
        Section("Timer Durations") {
            HStack {
                Text("Work Duration")
                Spacer()
                Stepper(
                    "\(settingsViewModel.workDurationMinutes) min",
                    value: Binding(
                        get: { settingsViewModel.workDurationMinutes },
                        set: { settingsViewModel.updateWorkDuration(minutes: $0) }
                    ),
                    in: 1...60
                )
            }
            
            HStack {
                Text("Short Break Duration")
                Spacer()
                Stepper(
                    "\(settingsViewModel.shortBreakDurationMinutes) min",
                    value: Binding(
                        get: { settingsViewModel.shortBreakDurationMinutes },
                        set: { settingsViewModel.updateShortBreakDuration(minutes: $0) }
                    ),
                    in: 1...30
                )
            }
            
            HStack {
                Text("Long Break Duration")
                Spacer()
                Stepper(
                    "\(settingsViewModel.longBreakDurationMinutes) min",
                    value: Binding(
                        get: { settingsViewModel.longBreakDurationMinutes },
                        set: { settingsViewModel.updateLongBreakDuration(minutes: $0) }
                    ),
                    in: 1...60
                )
            }
        }
    }
    
    // MARK: - Notification Section
    private var notificationSection: some View {
        Section("Notifications") {
            Toggle("Enable Notifications", isOn: $settingsViewModel.settings.enableNotifications)
            
            if settingsViewModel.settings.enableNotifications {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Notification Sound")
                        Spacer()
                        Picker("", selection: $settingsViewModel.settings.notificationSound) {
                            ForEach(NotificationSound.allCases, id: \.self) { sound in
                                Text(sound.displayName).tag(sound)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }
                    
                    if settingsViewModel.settings.notificationSound != .none {
                        Button("🔊 Preview") {
                            settingsViewModel.playNotificationSoundPreview()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            
            Toggle("Focus Mode", isOn: $settingsViewModel.settings.enableFocusMode)
                .help("Activates macOS Focus mode during work sessions")
            
            if settingsViewModel.settings.enableFocusMode {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("macOS Focus Mode")
                        Spacer()
                        Picker("", selection: $settingsViewModel.settings.macOSFocusMode) {
                            ForEach(MacOSFocusMode.allCases, id: \.self) { mode in
                                Text(mode.displayName).tag(mode)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                    }
                    
                    if settingsViewModel.settings.macOSFocusMode != .none {
                        Button("🎯 Test Focus Mode") {
                            FocusManager.shared.activateFocusMode(settingsViewModel.settings.macOSFocusMode)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            
            Toggle("Distraction Alerts", isOn: $settingsViewModel.settings.enableDistractionAlerts)
                .help("Shows periodic reminders to stay focused")
        }
    }
    
    // MARK: - Ambient Sound Section
    private var ambientSoundSection: some View {
        Section("Ambient Sound") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ambient Sound")
                    Spacer()
                    Picker("", selection: $settingsViewModel.settings.ambientSound) {
                        ForEach(AmbientSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                }
                
                if settingsViewModel.settings.ambientSound != .none {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Volume")
                            Spacer()
                            Text("\(settingsViewModel.ambientVolumePercentage)%")
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(
                            value: $settingsViewModel.settings.ambientVolume,
                            in: 0...1,
                            step: 0.1
                        )
                        
                        Button("🔊 Preview") {
                            settingsViewModel.playAmbientSoundPreview()
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
        }
    }
    
    // MARK: - Advanced Section
    private var advancedSection: some View {
        Section("Advanced") {
            Toggle("Menu Bar App", isOn: $settingsViewModel.settings.enableMenuBarApp)
                .help("Run the app in the menu bar")
            
            if settingsViewModel.settings.enableMenuBarApp {
                Toggle("Hide Dock Icon", isOn: $settingsViewModel.settings.hideDockIcon)
                    .help("Hide the app icon from the Dock when running as menu bar app")
            }
            
            Toggle("Global Shortcuts", isOn: $settingsViewModel.settings.enableGlobalShortcuts)
                .help("Enable keyboard shortcuts that work globally")
        }
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        Section {
            HStack {
                Spacer()
                
                Button("Reset to Defaults") {
                    settingsViewModel.resetToDefaults()
                }
                .buttonStyle(.bordered)
                .foregroundColor(.red)
                
                Spacer()
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(TimerViewModel())
}