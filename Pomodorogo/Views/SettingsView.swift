import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
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
                .frame(maxWidth: .infinity, alignment: .top)
                .padding()
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        // 변경사항 취소 (원래 설정으로 복원)
                        settingsViewModel.loadSettings()
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        // 설정 저장
                        settingsViewModel.saveSettings()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 500, height: 600)
    }
    
    // MARK: - Timer Duration Section
    private var timerDurationSection: some View {
        GroupBox("Timer Durations") {
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
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Notification Section
    private var notificationSection: some View {
        GroupBox("Notifications") {
            Toggle("Enable Notifications", isOn: $settingsViewModel.settings.enableNotifications)
            
            if settingsViewModel.settings.enableNotifications {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Notification Sound")
                        Spacer()
                        Picker("Bell", selection: $settingsViewModel.settings.notificationSound) {
                            ForEach(NotificationSound.allCases, id: \.self) { sound in
                                Text(sound.displayName).tag(sound)
                            }
                        }
                        .pickerStyle(.menu)
                        .frame(width: 150)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
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
            
            // Focus Mode - 주석처리 (유료 기능)
            /*
            VStack(alignment: .leading, spacing: 8) {
                Toggle("Focus Mode", isOn: $settingsViewModel.settings.enableFocusMode)
                    .help("Activates macOS Focus mode during work sessions")
                
                if settingsViewModel.settings.enableFocusMode {
                    Text("⚠️ First time setup requires granting automation permission in System Preferences")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.leading, 20)
                }
            }
            
            if settingsViewModel.settings.enableFocusMode {
                Divider()
                
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
                    HStack {
                        Spacer()
                        Button("🎯 Test Focus Mode") {
                            FocusManager.shared.activateFocusMode(settingsViewModel.settings.macOSFocusMode)
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                }
            }
            */
            
            // Distraction Alerts - 주석처리 (불필요)
            /*
            Toggle("Distraction Alerts", isOn: $settingsViewModel.settings.enableDistractionAlerts)
                .help("Shows periodic reminders to stay focused")
            */
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Ambient Sound Section
    private var ambientSoundSection: some View {
        GroupBox("Ambient Sound") {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Ambient Sound")
                    Spacer()
                    Picker("Sound", selection: $settingsViewModel.settings.ambientSound) {
                        ForEach(AmbientSound.allCases, id: \.self) { sound in
                            Text(sound.displayName).tag(sound)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                    .background(Color(NSColor.controlBackgroundColor))
                    .cornerRadius(6)
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
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Advanced Section
    private var advancedSection: some View {
        GroupBox("Advanced") {
            Toggle("Menu Bar App", isOn: $settingsViewModel.settings.enableMenuBarApp)
                .help("Run the app in the menu bar")
            
            if settingsViewModel.settings.enableMenuBarApp {
                Toggle("Hide Dock Icon", isOn: $settingsViewModel.settings.hideDockIcon)
                    .help("Hide the app icon from the Dock when running as menu bar app")
            }
            
            Toggle("Global Shortcuts", isOn: $settingsViewModel.settings.enableGlobalShortcuts)
                .help("Enable keyboard shortcuts that work globally")
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Action Section
    private var actionSection: some View {
        GroupBox {
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
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    SettingsView()
        .environmentObject(SettingsViewModel())
        .environmentObject(TimerViewModel())
}
