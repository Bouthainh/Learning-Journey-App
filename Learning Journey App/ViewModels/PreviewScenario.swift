//
//  JourneyManager+Preview.swift
//  Learning Journey App
//
//  Fake data for SwiftUI previews only.
//  #if DEBUG keeps it out of the real App Store build.
//

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

    // keeps each preview database alive while the preview runs
    @MainActor private static var previewContainers: [ModelContainer] = []

    @MainActor
    static func preview(_ scenario: PreviewScenario) -> JourneyManager {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: LearningGoal.self, DayLog.self, configurations: config)
        previewContainers.append(container)
        let context = container.mainContext

        // a date X days before today
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
            context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(6)))
            context.insert(DayLog(date: daysAgo(5), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(4), dayState: .Learn))
            context.insert(DayLog(date: daysAgo(3), dayState: .freeze))
        }

        // created AFTER inserting, so init() loads the fake data
        return JourneyManager(context: context)
    }

    // short version for previews that don't need data
    @MainActor static var preview: JourneyManager { preview(.noGoal) }
}
#endif