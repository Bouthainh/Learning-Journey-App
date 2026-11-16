import Observation
import Foundation
import SwiftData

@Observable
class JourneyManager {

    // MARK: Stored (loaded from SwiftData)

    private let context: ModelContext

    var goal: LearningGoal?
    var logs: [DayLog] = []


    // MARK: init()

    init(context: ModelContext) {
        self.context = context
        loadData()
    }

    private func loadData() {
        goal = try? context.fetch(FetchDescriptor<LearningGoal>()).first

        let byDate = FetchDescriptor<DayLog>(sortBy: [SortDescriptor(\.date)])
        logs = (try? context.fetch(byDate)) ?? []

        print("Loaded data>> goal: \(goal?.title ?? "none"), duration: \(Duration), logs: \(logs.count), streak: \(Streak), freezes used: \(FrezzesUsage)")
    }

    // MARK: Computed properties

    var hasGoal: Bool {
        goal != nil
    }

    var Duration: LearningDuration {
        goal?.duration ?? .week
    }

    var isJourneyActive: Bool {
        hasGoal && !isGoalReached && !isStreakLost
    }
    
    var currentLogs: [DayLog] {
        guard let goal else { return [] }
        return logs.filter { $0.date >= goal.startDate }
    }

    var Streak: Int {
        currentLogs.filter { $0.dayState == .Learn }.count
    }

    var FrezzesUsage: Int {
        currentLogs.filter { $0.dayState == .freeze }.count
    }

    var FreezesLeft: Int {
        Duration.maxFreezes - FrezzesUsage
    }

    var isLoggedToday: Bool {
        guard let lastLog = logs.last else { return false }
        return Calendar.current.isDateInToday(lastLog.date)
    }

    var todayState: LearnState {
        guard isLoggedToday, let lastLog = logs.last else { return .notLogged }
        return lastLog.dayState
    }

    var isGoalReached: Bool {
        hasGoal && Streak + FrezzesUsage >= Duration.days
    }

    var isStreakLost: Bool {
        guard let goal, !isGoalReached else { return false }
        let lastActivity = currentLogs.last?.date ?? goal.startDate
        return Date().timeIntervalSince(lastActivity) > 32 * 60 * 60
    }
    
    var canLog: Bool {
        isJourneyActive && todayState != .Learn
    }

    var canFreeze: Bool {
        isJourneyActive && todayState != .freeze && FreezesLeft > 0
    }
    

    // MARK: calendar logic

 
    func state(for date: Date) -> LearnState {
        let log = logs.last { Calendar.current.isDate($0.date, inSameDayAs: date) }
        return log?.dayState ?? .notLogged
    }

    // MARK: Actions

    // Onboarding "Start Learning" and the edit goal screen call this
    func SetGoal(title: String, duration: LearningDuration) {
        
        guard goalValiddation(for: title) == nil else {
            print("Goal rejected: \(goalValiddation(for: title) ?? "")")
            return
        }
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        if let goal {
            goal.title = title
            goal.duration = duration
            goal.startDate = .now
        } else {
            let newGoal = LearningGoal(title: title, duration: duration)
            context.insert(newGoal)
            goal = newGoal
        }
        save()
        print("Goal set: \(title) for a \(duration), journey starts now")
    }

    func Log(_ state: LearnState) {

        switch state {
        case .Learn:
            guard canLog else { print("Learn blocked"); return }
        case .freeze:
            guard canFreeze else { print("Freeze blocked"); return }
        case .notLogged:
            return
        }

        if isLoggedToday, let todayLog = logs.last {
            todayLog.dayState = state
            print("Changed today to \(state)")
        } else {
            let newLog = DayLog(dayState: state)
            context.insert(newLog)
            logs.append(newLog)
            print("Logged \(state)")
        }

        save()
        print("→ streak: \(Streak), freezes used: \(FrezzesUsage), left: \(FreezesLeft)")
    }


    // MARK: - Saving

    private func save() {
        do {
            try context.save()
        } catch {
            print("Save failed: \(error)")
        }
    }
    
    // MARK: Goal Validation

    func goalValiddation(for title: String) -> String? {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            return "Please write your learning goal"
        }
        if let firstLetter = trimmed.first, firstLetter.isNumber {
            return "Your goal can't start with a number"
        }
        return nil
    }
}

// MARK:  Preview helper
extension JourneyManager {

    enum PreviewScenario {
        case noGoal        // onboarding
        case active        // goal running, today not logged yet
        case goalReached   // "Well done!"
        case streakLost    // "You didn't reach your goal"
    }

    // keeps each preview database alive (same problem we fixed before)
    @MainActor private static var previewContainers: [ModelContainer] = []

    @MainActor
    static func preview(_ scenario: PreviewScenario) -> JourneyManager {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: LearningGoal.self, DayLog.self, configurations: config)
        previewContainers.append(container)
        let context = container.mainContext

        // helper: a date X days before today
        func daysAgo(_ days: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -days, to: .now)!
        }

        switch scenario {
        case .noGoal:
            break

        case .active:
            context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(3)))
            context.insert(DayLog(date: daysAgo(2), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(1), dayState: .freeze))

        case .goalReached:
            // a week goal with 7 learned days → 7 >= 7
            context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(8)))
            for day in 1...7 {
                context.insert(DayLog(date: daysAgo(day), dayState: .Learn))
            }

        case .streakLost:
            // last log was 3 days ago → more than 32 hours
            context.insert(LearningGoal(title: "test meee", duration: .week, startDate: daysAgo(6)))
            context.insert(DayLog(date: daysAgo(5), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(4), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(3), dayState: .freeze))
        }

        // created AFTER inserting, so init() loads the fake data
        return JourneyManager(context: context)
    }

    // old name still works for the other previews
    @MainActor static var preview: JourneyManager { preview(.noGoal) }
}
