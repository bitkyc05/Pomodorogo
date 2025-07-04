import SwiftUI

struct ContentView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showingSettings = false
    @State private var showingReview = false
    @State private var showingWorkAreas = false
    @Environment(\.openWindow) private var openWindow
    
    private let keyboardManager = KeyboardShortcutManager.shared
    
    var body: some View {
        ZStack {
            // 배경 그라디언트
            backgroundGradient
            
            VStack(spacing: 0) {
                // 헤더
                headerView
                
                // 메인 컨텐츠
                mainContent
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
            }
        }
        .frame(minWidth: 400, idealWidth: 480, maxWidth: 600, 
               minHeight: 600, idealHeight: 700, maxHeight: 800)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        .onChange(of: showingSettings) { _, newValue in
            if newValue {
                openWindow(id: "settings")
                showingSettings = false
            }
        }
        .onChange(of: showingReview) { _, newValue in
            if newValue {
                openWindow(id: "review")
                showingReview = false
            }
        }
        .sheet(isPresented: $showingWorkAreas) {
            WorkAreaSelectionView()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.willTerminateNotification)) { _ in
            // 앱 종료 시 데이터 저장
        }
        .onReceive(NotificationCenter.default.publisher(for: .toggleTimer)) { _ in
            timerViewModel.toggleTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .resetTimer)) { _ in
            timerViewModel.resetTimer()
        }
        .onReceive(NotificationCenter.default.publisher(for: .openSettings)) { _ in
            showingSettings = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .openReview)) { _ in
            showingReview = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .settingsDidChange)) { notification in
            if let settings = notification.object as? PomodoroSettings {
                keyboardManager.setEnabled(settings.enableGlobalShortcuts)
            }
        }
        .onAppear {
            keyboardManager.setEnabled(settingsViewModel.settings.enableGlobalShortcuts)
        }
    }
    
    // MARK: - Background
    private var backgroundGradient: some View {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.1, green: 0.1, blue: 0.18),
                Color(red: 0.09, green: 0.13, blue: 0.24)
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            // 미묘한 원형 그라디언트 추가
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(0.1),
                    Color.clear
                ]),
                center: .topLeading,
                startRadius: 0,
                endRadius: 300
            )
        )
        .overlay(
            RadialGradient(
                gradient: Gradient(colors: [
                    Color.teal.opacity(0.1),
                    Color.clear
                ]),
                center: .bottomTrailing,
                startRadius: 0,
                endRadius: 300
            )
        )
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 20) {
            // 제목
            HStack {
                Text("🍅")
                    .font(.largeTitle)
                Text("Pomodoro Focus")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.red, .orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            }
            
            // 모드 선택기
            modeSelector
        }
        .padding(.top, 20)
        .padding(.horizontal, 20)
        .padding(.bottom, 15)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.red.opacity(0.1),
                    Color.teal.opacity(0.1)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
    }
    
    private var modeSelector: some View {
        HStack(spacing: 10) {
            ForEach(TimerMode.allCases, id: \.self) { mode in
                Button(action: {
                    timerViewModel.switchMode(mode)
                }) {
                    Text(mode.displayName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(timerViewModel.currentMode == mode ? .white : .secondary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(timerViewModel.currentMode == mode ? Color.red : Color.clear)
                                .shadow(color: timerViewModel.currentMode == mode ? .red.opacity(0.3) : .clear, radius: 5)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(timerViewModel.isRunning)
            }
        }
        .padding(8)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
    }
    
    // MARK: - Main Content
    private var mainContent: some View {
        VStack(spacing: 40) {
            // 타이머 디스플레이
            TimerView()
            
            // 컨트롤 버튼들
            ControlsView(
                showingSettings: $showingSettings,
                showingReview: $showingReview,
                showingWorkAreas: $showingWorkAreas
            )
            
            // 통계
            StatsView()
        }
    }
}

// MARK: - Work Area Selection View
struct WorkAreaSelectionView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var newWorkAreaName = ""
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Work Areas")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button("✕") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                .foregroundColor(.secondary)
            }
            
            // 새 작업 영역 추가
            HStack {
                TextField("Add new work area...", text: $newWorkAreaName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button("Add") {
                    if !newWorkAreaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        timerViewModel.addWorkArea(newWorkAreaName)
                        newWorkAreaName = ""
                    }
                }
                .disabled(newWorkAreaName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            
            // 작업 영역 목록
            List {
                ForEach(timerViewModel.workAreas, id: \.self) { workArea in
                    HStack {
                        Button(action: {
                            timerViewModel.selectWorkArea(workArea)
                            dismiss()
                        }) {
                            HStack {
                                Text(workArea)
                                    .foregroundColor(.primary)
                                Spacer()
                                if timerViewModel.currentWorkArea == workArea {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if workArea != "General Work" {
                            Button(action: {
                                timerViewModel.removeWorkArea(workArea)
                            }) {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .frame(minHeight: 200)
            
            Button("Close") {
                dismiss()
            }
        }
        .padding()
        .frame(minWidth: 350, idealWidth: 400, maxWidth: 500,
               minHeight: 300, idealHeight: 350, maxHeight: 450)
    }
}

#Preview {
    ContentView()
        .environmentObject(TimerViewModel())
        .environmentObject(SettingsViewModel())
        .environmentObject(ReviewViewModel())
}