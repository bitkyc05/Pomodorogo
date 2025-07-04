import SwiftUI

struct StatsView: View {
    @EnvironmentObject var timerViewModel: TimerViewModel
    
    var body: some View {
        HStack(spacing: 20) {
            // 완료된 세션
            StatCard(
                number: "\(timerViewModel.completedSessions)",
                label: "Completed",
                color: .green,
                icon: "checkmark.circle.fill"
            )
            
            // 총 시간
            StatCard(
                number: timerViewModel.formattedTotalTime,
                label: "Total Time",
                color: .blue,
                icon: "clock.fill"
            )
            
            // 연속 기록
            StatCard(
                number: "\(timerViewModel.streak)",
                label: "Streak",
                color: .orange,
                icon: "flame.fill"
            )
        }
    }
}

struct StatCard: View {
    let number: String
    let label: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            // 아이콘
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .shadow(color: color.opacity(0.3), radius: 5)
            
            // 숫자
            Text(number)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
            
            // 라벨
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .padding(.horizontal, 10)
        .background(.ultraThinMaterial)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    StatsView()
        .environmentObject(TimerViewModel())
        .padding()
        .background(Color.black)
}