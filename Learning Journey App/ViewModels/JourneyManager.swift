import Observation
import Foundation
import SwiftData

/*centerd manager: handel app logic and learing cases
 under observation framework, making the manager ready to observe all changes
 coming from UI, and apply needed commands to reflect that change */

@Observable
class JourneyManager {

    // MARK: Stored variables (loaded from sw data)

    //a context from sw data, making data operation available
    private let context: ModelContext

    var goal: LearningGoal?
    var logs: [DayLog] = []


    // MARK: init()
    // apply Dependecy injection to create the sw db
    init(context: ModelContext) {
        self.context = context
        loadData()
    }

    //MARK: Load function
    //fetch data from db, bring only last goal,and all days states.. if null, then new user
    private func loadData() {
        goal = try? context.fetch(FetchDescriptor<LearningGoal>()).first

        let byDate = FetchDescriptor<DayLog>(sortBy: [SortDescriptor(\.date)])
        logs = (try? context.fetch(byDate)) ?? []

        //terminal msg .. dev check purpose
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

    //32 rule
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
    
    
    // MARK: Manager Actions
    
    // MARK: action.1 look for learning state in stored logs
    func state(for date: Date) -> LearnState {
        let log = logs.last { Calendar.current.isDate($0.date, inSameDayAs: date) }
        return log?.dayState ?? .notLogged
    }


    //MARK: action.2 Setting the goal (from user input: title, duration)
    // rused twice: Onboarding "Start Learning" and the edit goal
    func SetGoal(title: String, duration: LearningDuration) {
        
        //first validate the input
        guard goalValiddation(for: title) == nil else {
            
            //terminal msg .. dev check purpose
            print("Goal rejected: \(goalValiddation(for: title) ?? "")")
            return
        }
        let title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let goal { //for update action, already have a gaol
            goal.title = title
            goal.duration = duration
            goal.startDate = .now
            
        } else { // creating new goal
            let newGoal = LearningGoal(title: title, duration: duration)
            context.insert(newGoal)
            goal = newGoal
        }
        
        save()
        
        //terminal msg .. dev check purpose
        print("Goal set: \(title) for a \(duration), journey starts now")
    }

    
    //MARK: action.3 learning logging with state options
    func Log(_ state: LearnState) {

        switch state {
        case .Learn:
            guard canLog else { print("Learn blocked"); return }
        case .freeze:
            guard canFreeze else { print("Freeze blocked"); return }
        case .notLogged:
            return
        }

        //already have state and its updated
        if isLoggedToday, let todayLog = logs.last {
            todayLog.dayState = state
            
            //dev msg
            print("Changed today to \(state)")
        }
        //new state, create log and add to the array in db
        else {
            let newLog = DayLog(dayState: state)
            context.insert(newLog)
            logs.append(newLog)
            
            //dev msg
            print("Logged \(state)")
        }

        save()
        
        //dev msg
        print("→ streak: \(Streak), freezes used: \(FrezzesUsage), left: \(FreezesLeft)")
    }


    // MARK: action.4 Saving changes and new creations in db

    private func save() {
        do {
            try context.save()
        } catch {
            //dev msg
            print("Save failed: \(error)")
        }
    }
    
    // MARK: action.5 Goal Validation >> string validation

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
