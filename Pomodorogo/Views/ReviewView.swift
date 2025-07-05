import SwiftUI

struct ReviewView: View {
    @EnvironmentObject var reviewViewModel: ReviewViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDate = Date()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    dateHeader
                    calendarView
                    reviewForm
                }
                .frame(maxWidth: .infinity, alignment: .top) // 가로 공간을 채우도록
                .padding()
            }
            .navigationTitle("📝 Daily Review")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("✕") { dismiss() }
                        .buttonStyle(.borderless)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .secondaryAction) {
                    Button("📋 Export") { reviewViewModel.copyToClipboard() }
                }
            }
        }
        // macOS 팝오버 기준 크기
        .frame(width: 600, height: 700)
        .onAppear {
            selectedDate = Date()
            reviewViewModel.selectDate(selectedDate)
        }
    }

    // MARK: - Date Header
    private var dateHeader: some View {
        VStack(spacing: 8) {
            Text(DateFormatter.localizedString(from: selectedDate, dateStyle: .full, timeStyle: .none))
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            if reviewViewModel.isToday(selectedDate) {
                Text("Today")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }

            // 해당 날짜 통계
            let stats = reviewViewModel.getStatsForDate(selectedDate)
            HStack(spacing: 20) {
                StatBadge(icon: "🍅", text: "\(stats.workSessions) sessions")
                StatBadge(icon: "⏱️", text: stats.formattedTotalTime)
            }
        }
        .padding()
        .frame(maxWidth: .infinity) // 카드도 좌우 전체 폭 사용
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }

    // MARK: - Calendar View
    private var calendarView: some View {
        VStack(spacing: 15) {
            // 월/년 헤더
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Spacer()
                Text(reviewViewModel.monthYearString(for: selectedDate))
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
            }
            .padding(.horizontal)

            // 요일 헤더
            HStack {
                ForEach(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // 날짜 그리드
            let dates = reviewViewModel.generateCalendarDates(for: selectedDate)
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                ForEach(dates, id: \.self) { date in
                    CalendarDayView(
                        date: date,
                        isSelected: Calendar.current.isDate(date, inSameDayAs: selectedDate),
                        isToday: reviewViewModel.isToday(date),
                        isCurrentMonth: reviewViewModel.isInCurrentMonth(date, referenceDate: selectedDate),
                        hasReview: reviewViewModel.hasReviewForDate(date),
                        stats: reviewViewModel.getStatsForDate(date)
                    ) {
                        selectedDate = date
                        reviewViewModel.selectDate(date)
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }

    // MARK: - Review Form
    private var reviewForm: some View {
        VStack(spacing: 20) {
            moodProductivitySection
            reviewTextFields
            Button(action: { reviewViewModel.saveCurrentReview() }) {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Save Review")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.green)
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial)
        .cornerRadius(15)
    }

    private var moodProductivitySection: some View {
        HStack(spacing: 40) {
            VStack {
                Text("😊 Mood")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { rating in
                        Button(action: { reviewViewModel.updateReviewField(\.mood, value: rating) }) {
                            Image(systemName: "star.fill")
                                .foregroundColor(rating <= reviewViewModel.currentReview.mood ? .yellow : .gray.opacity(0.3))
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
            VStack {
                Text("💪 Productivity")
                    .font(.headline)
                HStack(spacing: 8) {
                    ForEach(1...5, id: \.self) { rating in
                        Button(action: { reviewViewModel.updateReviewField(\.productivity, value: rating) }) {
                            Image(systemName: "star.fill")
                                .foregroundColor(rating <= reviewViewModel.currentReview.productivity ? .blue : .gray.opacity(0.3))
                                .font(.title2)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
            }
        }
    }

    private var reviewTextFields: some View {
        VStack(spacing: 15) {
            ReviewTextField(title: "🎯 Today's Achievements", placeholder: "What did you accomplish today?", text: Binding(get: { reviewViewModel.currentReview.achievements }, set: { reviewViewModel.updateReviewField(\.achievements, value: $0) }))
            ReviewTextField(title: "📝 Notes & Reflections", placeholder: "How did today go? Any insights or thoughts?", text: Binding(get: { reviewViewModel.currentReview.notes }, set: { reviewViewModel.updateReviewField(\.notes, value: $0) }))
            ReviewTextField(title: "🔧 What to Improve", placeholder: "What could be better tomorrow?", text: Binding(get: { reviewViewModel.currentReview.improvements }, set: { reviewViewModel.updateReviewField(\.improvements, value: $0) }))
            ReviewTextField(title: "🚀 Tomorrow's Goals", placeholder: "What are your priorities for tomorrow?", text: Binding(get: { reviewViewModel.currentReview.tomorrowGoals }, set: { reviewViewModel.updateReviewField(\.tomorrowGoals, value: $0) }))
        }
    }

    // MARK: - Helper Methods
    private func previousMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }

    private func nextMonth() {
        if let newDate = Calendar.current.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
}

// MARK: - Supporting Views
struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasReview: Bool
    let stats: SessionStats
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor, lineWidth: borderWidth)
                    )
                VStack(spacing: 2) {
                    Text(Calendar.current.component(.day, from: date).description)
                        .font(.system(size: 14, weight: isToday ? .bold : .medium))
                        .foregroundColor(textColor)
                    if stats.workSessions > 0 {
                        Text("\(stats.workSessions)")
                            .font(.caption2)
                            .foregroundColor(.white)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.green)
                            .clipShape(Capsule())
                    }
                    if hasReview { Text("📝").font(.caption2) }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .frame(minHeight: 50)
        .aspectRatio(1, contentMode: .fit)
        .opacity(isCurrentMonth ? 1 : 0.3)
    }

    private var backgroundColor: Color {
        if isSelected { return .blue }
        if isToday { return .red.opacity(0.2) }
        if stats.workSessions > 0 { return .green.opacity(0.1) }
        return .clear
    }
    private var borderColor: Color {
        if isSelected { return .blue }
        if isToday { return .red }
        if hasReview { return .orange }
        return .clear
    }
    private var borderWidth: CGFloat { (isSelected || isToday || hasReview) ? 2 : 0 }
    private var textColor: Color { isSelected ? .white : .primary }
}

struct StatBadge: View {
    let icon: String
    let text: String
    var body: some View {
        HStack(spacing: 4) {
            Text(icon).font(.caption)
            Text(text).font(.caption).fontWeight(.medium)
        }
        .padding(.horizontal, 8).padding(.vertical, 4)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ReviewTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline).foregroundColor(.primary)
            TextEditor(text: $text)
                .font(.body)
                .padding(8)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
                .frame(minHeight: 80)
                .overlay(
                    Group {
                        if text.isEmpty {
                            VStack {
                                HStack {
                                    Text(placeholder).foregroundColor(.secondary)
                                        .allowsHitTesting(false)
                                        .padding(.leading, 4)
                                        .padding(.top, 8)
                                    Spacer()
                                }
                                Spacer()
                            }
                        }
                    }
                )
        }
    }
}

#Preview {
    ReviewView()
        .environmentObject(ReviewViewModel())
}
