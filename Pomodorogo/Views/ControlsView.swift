import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    @Binding var showingSettings: Bool
    @Binding var showingReview: Bool
    @Binding var showingWorkAreas: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // 초과시간 모드가 아닐 때만 컨트롤 표시
            if !timerViewModel.isOvertimeMode {
                // 메인 컨트롤 (시작/일시정지, 리셋)
                HStack(spacing: 15) {
                    startPauseButton
                    resetButton
                }
                
                // 보조 컨트롤 (설정, 리뷰)
                HStack(spacing: 15) {
                    settingsButton
                    reviewButton
                }
            } else {
                // 초과시간 모드에서는 간단한 안내 메시지
                Text("Time's up! Click STOP to complete session")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
    
    // MARK: - Main Controls
    private var startPauseButton: some View {
        Button(action: {
            // 휴식 모드에서 Stop 버튼 클릭 시 세션 완료
            if timerViewModel.currentMode != .work && timerViewModel.isRunning {
                timerViewModel.stopBreakSession()
            } else {
                timerViewModel.toggleTimer()
            }
        }) {
            HStack(spacing: 8) {
                // 휴식 모드와 work 모드 분리
                if timerViewModel.currentMode != .work {
                    // 휴식 모드: Start 또는 Stop만 표시
                    Text(timerViewModel.isRunning ? "Stop" : "Start")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("(Break)")
                        .font(.caption)
                        .opacity(0.7)
                    
                    Image(systemName: timerViewModel.isRunning ? "stop.fill" : "play.fill")
                        .font(.system(size: 20))
                } else {
                    // work 모드: 기존 Start/Pause 로직
                    Text(timerViewModel.isRunning ? "Pause" : "Start")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("(Space)")
                        .font(.caption)
                        .opacity(0.7)
                    
                    Image(systemName: timerViewModel.isRunning ? "pause.fill" : "play.fill")
                        .font(.system(size: 20))
                }
            }
            .foregroundColor(.white)
            .frame(minWidth: 100)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: timerViewModel.isRunning ? 
                                     [Color.orange, Color.red] : 
                                     [Color.blue, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(15)
            .shadow(color: (timerViewModel.isRunning ? Color.orange : Color.blue).opacity(0.3), 
                   radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(timerViewModel.isRunning ? 1.0 : 1.05)
        .animation(.easeInOut(duration: 0.2), value: timerViewModel.isRunning)
    }
    
    private var resetButton: some View {
        Button(action: {
            timerViewModel.resetTimer()
        }) {
            HStack(spacing: 8) {
                Text("Reset")
                    .font(.system(size: 16, weight: .semibold))
                
                Text("(R)")
                    .font(.caption)
                    .opacity(0.7)
                
                Image(systemName: "arrow.clockwise")
                    .font(.system(size: 18))
            }
            .foregroundColor(.primary)
            .frame(minWidth: 100)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .cornerRadius(15)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(timerViewModel.timeLeft == (timerViewModel.currentMode == .work ? 25*60 : 
                                            timerViewModel.currentMode == .shortBreak ? 5*60 : 15*60))
    }
    
    // MARK: - Secondary Controls
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            HStack(spacing: 8) {
                Text("Settings")
                    .font(.system(size: 14, weight: .medium))
                
                Text("(S)")
                    .font(.caption2)
                    .opacity(0.7)
                
                Image(systemName: "gear")
                    .font(.system(size: 16))
            }
            .foregroundColor(.white)
            .frame(minWidth: 80)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(Color.orange.opacity(0.8))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var reviewButton: some View {
        Button(action: {
            showingReview = true
        }) {
            HStack(spacing: 8) {
                Text("Review")
                    .font(.system(size: 14, weight: .medium))
                
                Text("(V)")
                    .font(.caption2)
                    .opacity(0.7)
                
                Image(systemName: "chart.bar.fill")
                    .font(.system(size: 16))
            }
            .foregroundColor(.white)
            .frame(minWidth: 80)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.pink, Color.purple]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ControlsView(
        showingSettings: .constant(false),
        showingReview: .constant(false),
        showingWorkAreas: .constant(false)
    )
    .environmentObject(TimerViewModel())
    .padding()
    .background(Color.black)
}