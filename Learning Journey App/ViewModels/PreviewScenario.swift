import Foundation
import SwiftData

#if DEBUG
extension JourneyManager {

    enum PreviewScenario {
        case noGoal        // onboarding
        case active        // goal running, today not logged yet
        case goalReached   // "Well done!"
        case streakLost    // "You didn't reach your goal"
    }

    @MainActor private static var previewContainers: [ModelContainer] = []

    @MainActor
    static func preview(_ scenario: PreviewScenario) -> JourneyManager {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: LearningGoal.self, DayLog.self, configurations: config)
        previewContainers.append(container)
        let context = container.mainContext

        func daysAgo(_ days: Int) -> Date {
            Calendar.current.date(byAdding: .day, value: -days, to: .now)!
        }

        switch scenario {
        case .noGoal:
            break

        case .active:
            context.insert(LearningGoal(title: "java", duration: .week, startDate: daysAgo(3)))
            context.insert(DayLog(date: daysAgo(2), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(1), dayState: .freeze))

        case .goalReached:
            context.insert(LearningGoal(title: "java", duration: .week, startDate: daysAgo(8)))
            for day in 1...7 {
                context.insert(DayLog(date: daysAgo(day), dayState: .Learn))
            }

        case .streakLost:
            context.insert(LearningGoal(title: "java", duration: .week, startDate: daysAgo(6)))
            context.insert(DayLog(date: daysAgo(5), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(4), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(3), dayState: .freeze))
        }

        return JourneyManager(context: context)
    }

    @MainActor static var preview: JourneyManager { preview(.noGoal) }
}
#endif
