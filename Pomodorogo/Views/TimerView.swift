import SwiftUI

struct TimerView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @State private var showingWorkAreas = false
    
    var body: some View {
        ZStack {
            // 진행률 링
            progressRing
            
            // 중앙 정보 디스플레이
            centralDisplay
        }
        .frame(minWidth: 280, idealWidth: 320, maxWidth: 380)
        .aspectRatio(1, contentMode: .fit)
        .sheet(isPresented: $showingWorkAreas) {
            WorkAreaSelectionView()
        }
    }
    
    // MARK: - Progress Ring
    private var progressRing: some View {
        ZStack {
            // 배경 링
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 8)
            
            // 진행률 링
            Circle()
                .trim(from: 0, to: timerViewModel.progress)
                .stroke(
                    currentModeColor,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 1), value: timerViewModel.progress)
                .shadow(color: currentModeColor.opacity(0.5), radius: 10)
        }
    }
    
    // MARK: - Central Display
    private var centralDisplay: some View {
        VStack(spacing: 15) {
            // 세션 번호
            sessionCounter
            
            // 시간 표시
            timeDisplay
            
            // 작업 영역 표시
            workAreaDisplay
        }
    }
    
    private var sessionCounter: some View {
        Text("Session #\(timerViewModel.sessionNumber)")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.secondary)
            .padding(.horizontal, 15)
            .padding(.vertical, 5)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.red.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                    )
            )
    }
    
    private var timeDisplay: some View {
        GeometryReader { geometry in
            let fontSize = min(geometry.size.width * 0.18, 56)
            Text(timerViewModel.formattedTime)
                .font(.system(size: fontSize, weight: .bold, design: .monospaced))
                .foregroundColor(.primary)
                .shadow(color: currentModeColor.opacity(0.3), radius: 10)
                .contentTransition(.numericText())
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(height: 60)
    }
    
    private var workAreaDisplay: some View {
        Button(action: {
            showingWorkAreas = true
        }) {
            Text(timerViewModel.currentWorkArea)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.teal)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.teal.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.teal.opacity(0.3), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(timerViewModel.isRunning)
        .scaleEffect(timerViewModel.isRunning ? 1.0 : 1.05)
        .animation(.easeInOut(duration: 0.3), value: timerViewModel.isRunning)
    }
    
    // MARK: - Computed Properties
    private var currentModeColor: Color {
        switch timerViewModel.currentMode {
        case .work:
            return .red
        case .shortBreak:
            return .teal
        case .longBreak:
            return .blue
        }
    }
}

#Preview {
    TimerView()
        .environmentObject(TimerViewModel())
        .background(Color.black)
}