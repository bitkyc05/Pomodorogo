import Foundation
import Combine
import AppKit

// MARK: - 일일 리뷰 모델
struct DailyReview {
    var date: Date
    var notes: String = ""
    var achievements: String = ""
    var improvements: String = ""
    var tomorrowGoals: String = ""
    var mood: Int = 3        // 1-5 스케일
    var productivity: Int = 3 // 1-5 스케일
    var lastModified: Date = Date()
    
    init(date: Date) {
        self.date = date
    }
}

// MARK: - 세션 통계
struct SessionStats {
    let totalSessions: Int
    let workSessions: Int
    let breakSessions: Int
    let totalTime: Int
    let averageSessionTime: Int
    
    var formattedTotalTime: String {
        let hours = totalTime / 3600
        let minutes = (totalTime % 3600) / 60
        return "\(hours)h \(minutes)m"
    }
    
    var formattedAverageTime: String {
        let minutes = averageSessionTime / 60
        return "\(minutes)min"
    }
}

// MARK: - 리뷰 ViewModel
class ReviewViewModel: ObservableObject {
    
    @Published var selectedDate = Date()
    @Published var currentReview = DailyReview(date: Date())
    @Published var monthlyStats: [Date: SessionStats] = [:]
    
    private var reviews: [String: DailyReview] = [:]
    private let userDefaults = UserDefaults.standard
    private let dateFormatter: DateFormatter
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        loadReviews()
        updateCurrentReview()
        generateMonthlyStats()
    }
    
    // MARK: - Review Management
    func selectDate(_ date: Date) {
        selectedDate = date
        updateCurrentReview()
    }
    
    func saveCurrentReview() {
        currentReview.lastModified = Date()
        let dateKey = dateFormatter.string(from: selectedDate)
        reviews[dateKey] = currentReview
        saveReviews()
    }
    
    func updateReviewField<T>(_ keyPath: WritableKeyPath<DailyReview, T>, value: T) {
        currentReview[keyPath: keyPath] = value
        saveCurrentReview()
    }
    
    func getStatsForDate(_ date: Date) -> SessionStats {
        return monthlyStats[date] ?? SessionStats(
            totalSessions: 0,
            workSessions: 0,
            breakSessions: 0,
            totalTime: 0,
            averageSessionTime: 0
        )
    }
    
    func hasReviewForDate(_ date: Date) -> Bool {
        let dateKey = dateFormatter.string(from: date)
        return reviews[dateKey] != nil
    }
    
    // MARK: - Calendar Helpers
    func generateCalendarDates(for date: Date) -> [Date] {
        let startOfMonth = calendar.dateInterval(of: .month, for: date)?.start ?? date
        let startOfCalendar = calendar.dateInterval(of: .weekOfYear, for: startOfMonth)?.start ?? startOfMonth
        
        var dates: [Date] = []
        var currentDate = startOfCalendar
        
        for _ in 0..<42 { // 6주 × 7일
            dates.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        
        return dates
    }
    
    func isToday(_ date: Date) -> Bool {
        calendar.isDate(date, inSameDayAs: Date())
    }
    
    func isInCurrentMonth(_ date: Date, referenceDate: Date = Date()) -> Bool {
        calendar.isDate(date, equalTo: referenceDate, toGranularity: .month)
    }
    
    func monthYearString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date)
    }
    
    func dayString(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    // MARK: - Export Functionality
    func generateMarkdownExport() -> String {
        let stats = getStatsForDate(selectedDate)
        let dateString = DateFormatter.localizedString(from: selectedDate, dateStyle: .full, timeStyle: .none)
        let dateKey = dateFormatter.string(from: selectedDate)
        
        var markdown = "# 📅 Daily Review - \(dateString)\n\n"
        
        // 메타데이터
        markdown += "---\n"
        markdown += "**Date:** \(dateKey)  \n"
        markdown += "**Generated:** \(DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .short))  \n"
        markdown += "**App:** 🍅 Pomodoro Focus  \n"
        markdown += "---\n\n"
        
        // 통계 섹션
        markdown += "## 📊 Daily Statistics\n\n"
        markdown += "| Metric | Value |\n"
        markdown += "|--------|-------|\n"
        markdown += "| **Work Sessions** | \(stats.workSessions) |\n"
        markdown += "| **Total Focus Time** | \(stats.formattedTotalTime) |\n"
        markdown += "| **Mood Rating** | \(String(repeating: "⭐", count: currentReview.mood)) (\(currentReview.mood)/5) |\n"
        markdown += "| **Productivity Rating** | \(String(repeating: "⭐", count: currentReview.productivity)) (\(currentReview.productivity)/5) |\n\n"
        
        // 성과 섹션
        if !currentReview.achievements.isEmpty {
            markdown += "## 🎯 Today's Achievements\n\n"
            markdown += "\(currentReview.achievements)\n\n"
        }
        
        // 노트 섹션
        if !currentReview.notes.isEmpty {
            markdown += "## 📝 Notes & Reflections\n\n"
            markdown += "\(currentReview.notes)\n\n"
        }
        
        // 개선사항 섹션
        if !currentReview.improvements.isEmpty {
            markdown += "## 🔧 What to Improve\n\n"
            markdown += "\(currentReview.improvements)\n\n"
        }
        
        // 내일 목표 섹션
        if !currentReview.tomorrowGoals.isEmpty {
            markdown += "## 🚀 Tomorrow's Goals\n\n"
            markdown += "\(currentReview.tomorrowGoals)\n\n"
        }
        
        // 푸터
        markdown += "---\n"
        markdown += "*Generated by [🍅 Pomodoro Focus](https://github.com/bitkyc05/Pomodorogo) - v0.5.2*\n"
        
        return markdown
    }
    
    func generateExportText() -> String {
        let stats = getStatsForDate(selectedDate)
        let dateString = DateFormatter.localizedString(from: selectedDate, dateStyle: .full, timeStyle: .none)
        
        var text = "📅 Daily Review - \(dateString)\n\n"
        
        // 통계
        text += "📊 Statistics:\n"
        text += "• Work Sessions: \(stats.workSessions)\n"
        text += "• Total Focus Time: \(stats.formattedTotalTime)\n"
        text += "• Mood: \(String(repeating: "⭐", count: currentReview.mood)) (\(currentReview.mood)/5)\n"
        text += "• Productivity: \(String(repeating: "⭐", count: currentReview.productivity)) (\(currentReview.productivity)/5)\n\n"
        
        // 성과
        if !currentReview.achievements.isEmpty {
            text += "🎯 Achievements:\n\(currentReview.achievements)\n\n"
        }
        
        // 노트
        if !currentReview.notes.isEmpty {
            text += "📝 Notes:\n\(currentReview.notes)\n\n"
        }
        
        // 개선사항
        if !currentReview.improvements.isEmpty {
            text += "🔧 Improvements:\n\(currentReview.improvements)\n\n"
        }
        
        // 내일 목표
        if !currentReview.tomorrowGoals.isEmpty {
            text += "🚀 Tomorrow's Goals:\n\(currentReview.tomorrowGoals)\n\n"
        }
        
        text += "Generated by 🍅 Pomodoro Focus"
        return text
    }
    
    func copyToClipboard() {
        let exportText = generateExportText()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(exportText, forType: .string)
    }
    
    func copyMarkdownToClipboard() {
        let markdownText = generateMarkdownExport()
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(markdownText, forType: .string)
    }
    
    func saveMarkdownToFile() {
        let markdownContent = generateMarkdownExport()
        let dateKey = dateFormatter.string(from: selectedDate)
        let fileName = "Daily-Review-\(dateKey).md"
        
        let savePanel = NSSavePanel()
        savePanel.title = "Save Daily Review"
        savePanel.nameFieldStringValue = fileName
        savePanel.allowedContentTypes = [.plainText]
        savePanel.allowsOtherFileTypes = false
        savePanel.isExtensionHidden = false
        
        savePanel.begin { response in
            if response == .OK, let url = savePanel.url {
                do {
                    try markdownContent.write(to: url, atomically: true, encoding: .utf8)
                } catch {
                    print("Error saving file: \(error)")
                }
            }
        }
    }
    
    // MARK: - Deletion Methods
    func deleteAllReviews() {
        reviews.removeAll()
        monthlyStats.removeAll()
        currentReview = DailyReview(date: selectedDate)
        saveReviews()
        generateMonthlyStats()
    }
    
    func deleteDailyReview(for date: Date) {
        let dateKey = dateFormatter.string(from: date)
        reviews.removeValue(forKey: dateKey)
        monthlyStats.removeValue(forKey: date)
        
        if calendar.isDate(date, inSameDayAs: selectedDate) {
            currentReview = DailyReview(date: selectedDate)
        }
        
        saveReviews()
        generateMonthlyStats()
    }
    
    func clearAllAppData() {
        reviews.removeAll()
        monthlyStats.removeAll()
        currentReview = DailyReview(date: selectedDate)
        
        let keys = [
            "dailyReviews",
            "completedSessions",
            "totalTime", 
            "streak",
            "sessionNumber",
            "workAreas",
            "currentWorkArea"
        ]
        
        for key in keys {
            userDefaults.removeObject(forKey: key)
        }
        
        generateMonthlyStats()
    }
    
    // MARK: - Private Methods
    private func updateCurrentReview() {
        let dateKey = dateFormatter.string(from: selectedDate)
        currentReview = reviews[dateKey] ?? DailyReview(date: selectedDate)
    }
    
    private func generateMonthlyStats() {
        // TODO: Core Data에서 세션 데이터를 가져와서 통계 생성
        // 현재는 더미 데이터 또는 UserDefaults에서 가져온 데이터 사용
        
        // 예시 구현:
        let calendar = Calendar.current
        let today = Date()
        
        for i in 0..<30 {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                // 실제로는 Core Data에서 해당 날짜의 세션 데이터를 쿼리해야 함
                let workSessions = Int.random(in: 0...8)
                let totalTime = workSessions * 25 * 60 // 대략적인 계산
                
                monthlyStats[date] = SessionStats(
                    totalSessions: workSessions + Int.random(in: 0...3),
                    workSessions: workSessions,
                    breakSessions: Int.random(in: 0...3),
                    totalTime: totalTime,
                    averageSessionTime: workSessions > 0 ? totalTime / workSessions : 0
                )
            }
        }
    }
    
    // MARK: - Data Persistence
    private func loadReviews() {
        if let data = userDefaults.data(forKey: "dailyReviews"),
           let decoded = try? JSONDecoder().decode([String: DailyReview].self, from: data) {
            reviews = decoded
        }
    }
    
    private func saveReviews() {
        if let encoded = try? JSONEncoder().encode(reviews) {
            userDefaults.set(encoded, forKey: "dailyReviews")
        }
    }
}

// MARK: - DailyReview Codable
extension DailyReview: Codable {
    enum CodingKeys: String, CodingKey {
        case date, notes, achievements, improvements, tomorrowGoals, mood, productivity, lastModified
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        date = try container.decode(Date.self, forKey: .date)
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        achievements = try container.decodeIfPresent(String.self, forKey: .achievements) ?? ""
        improvements = try container.decodeIfPresent(String.self, forKey: .improvements) ?? ""
        tomorrowGoals = try container.decodeIfPresent(String.self, forKey: .tomorrowGoals) ?? ""
        mood = try container.decodeIfPresent(Int.self, forKey: .mood) ?? 3
        productivity = try container.decodeIfPresent(Int.self, forKey: .productivity) ?? 3
        lastModified = try container.decodeIfPresent(Date.self, forKey: .lastModified) ?? Date()
    }
}

// MARK: - SessionStats Static
extension SessionStats {
    static let empty = SessionStats(
        totalSessions: 0,
        workSessions: 0,
        breakSessions: 0,
        totalTime: 0,
        averageSessionTime: 0
    )
}