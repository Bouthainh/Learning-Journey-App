import Testing
import Foundation
import SwiftData
@testable import Learning_Journey_App
@MainActor
struct JourneyManagerTests {

    // a fresh, empty database for EVERY test (Swift Testing creates a new struct each time)
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: LearningGoal.self, DayLog.self, configurations: config)
        context = container.mainContext
    }

    // MARK: - Helpers

    func daysAgo(_ days: Int) -> Date {
        Calendar.current.date(byAdding: .day, value: -days, to: .now)!
    }

    func hoursAgo(_ hours: Double) -> Date {
        Date().addingTimeInterval(-hours * 60 * 60)
    }

    // create the manager AFTER inserting fake data, so init() loads it
    func makeManager() -> JourneyManager {
        JourneyManager(context: context)
    }

    // MARK: - Goal validation

    @Test func emptyGoalIsInvalid() {
        let manager = makeManager()
        #expect(manager.goalValiddation(for: "") != nil)
    }

    @Test func onlySpacesIsInvalid() {
        let manager = makeManager()
        #expect(manager.goalValiddation(for: "    ") != nil)
    }

    @Test func goalStartingWithNumberIsInvalid() {
        let manager = makeManager()
        #expect(manager.goalValiddation(for: "5 apps") != nil)
        #expect(manager.goalValiddation(for: "  5 apps") != nil)   // spaces don't hide the number
    }

    @Test func normalGoalIsValid() {
        let manager = makeManager()
        #expect(manager.goalValiddation(for: "Swift") == nil)
        #expect(manager.goalValiddation(for: "Swift 6") == nil)    // a number later is fine
    }

    // MARK: - Setting a goal

    @Test func newUserHasNoGoalAndCannotLog() {
        let manager = makeManager()
        #expect(manager.hasGoal == false)
        #expect(manager.canLog == false)
    }

    @Test func setGoalSavesTitleAndDuration() {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .month)

        #expect(manager.hasGoal)
        #expect(manager.goal?.title == "Swift")
        #expect(manager.Duration == .month)
        #expect(manager.canLog)
    }

    @Test func goalIsSavedInDatabase() throws {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .week)

        // a second manager reading the same database = reopening the app
        let reopened = makeManager()
        #expect(reopened.goal?.title == "Swift")
    }

    // MARK: - Learn

    @Test func learnAddsOneToStreak() {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .week)

        manager.Log(.Learn)

        #expect(manager.Streak == 1)
        #expect(manager.isLoggedToday)
        #expect(manager.todayState == .Learn)
    }

    @Test func cannotLogTwiceInOneDay() {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .week)

        manager.Log(.Learn)
        manager.Log(.Learn)   // should be blocked

        #expect(manager.Streak == 1)
        #expect(manager.canLog == false)
    }

    @Test func loggedYesterdayCanLogToday() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(2)))
        context.insert(DayLog(date: daysAgo(1), dayState: .Learn))
        let manager = makeManager()

        #expect(manager.isLoggedToday == false)
        #expect(manager.canLog)
    }

    // MARK: - Freeze

    @Test func freezeCountsFreezeButNotStreak() {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .week)

        manager.Log(.freeze)

        #expect(manager.FrezzesUsage == 1)
        #expect(manager.Streak == 0)
        #expect(manager.FreezesLeft == 1)   // week allows 2
        #expect(manager.todayState == .freeze)
    }

    @Test func cannotFreezeWhenNoFreezesLeft() {
        // a week goal that already used both freezes
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(3)))
        context.insert(DayLog(date: daysAgo(2), dayState: .freeze))
        context.insert(DayLog(date: daysAgo(1), dayState: .freeze))
        let manager = makeManager()

        #expect(manager.canFreeze == false)
        manager.Log(.freeze)   // should be blocked

        #expect(manager.FrezzesUsage == 2)
        #expect(manager.isLoggedToday == false)
        #expect(manager.canLog)   // learning is still allowed
    }

    // MARK: - Changing your mind (same day)

    @Test func learnThenFreezeSwitchesToday() {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .week)

        manager.Log(.Learn)
        manager.Log(.freeze)   // changed mind

        #expect(manager.todayState == .freeze)
        #expect(manager.Streak == 0)
        #expect(manager.FrezzesUsage == 1)
        #expect(manager.logs.count == 1)   // still ONE log for today, not two
        #expect(manager.canLog)            // can switch back
        #expect(manager.canFreeze == false)
    }

    @Test func freezeThenLearnSwitchesToday() {
        let manager = makeManager()
        manager.SetGoal(title: "Swift", duration: .week)

        manager.Log(.freeze)
        manager.Log(.Learn)   // changed mind

        #expect(manager.todayState == .Learn)
        #expect(manager.Streak == 1)
        #expect(manager.FrezzesUsage == 0)  // the freeze is given back
        #expect(manager.logs.count == 1)
        #expect(manager.canFreeze)
        #expect(manager.canLog == false)
    }

    @Test func cannotSwitchToFreezeWhenNoneLeft() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(3)))
        context.insert(DayLog(date: daysAgo(2), dayState: .freeze))
        context.insert(DayLog(date: daysAgo(1), dayState: .freeze))
        let manager = makeManager()

        manager.Log(.Learn)
        manager.Log(.freeze)   // blocked: both freezes used

        #expect(manager.todayState == .Learn)
        #expect(manager.FrezzesUsage == 2)
    }

    @Test(arguments: [
        (LearningDuration.week, 2),
        (LearningDuration.month, 8),
        (LearningDuration.year, 96)
    ])
    func maxFreezesMatchesDuration(duration: LearningDuration, expected: Int) {
        #expect(duration.maxFreezes == expected)
    }

    // MARK: - Goal reached

    @Test func goalReachedAfterAllDays() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(8)))
        for day in 1...7 {
            context.insert(DayLog(date: daysAgo(day), dayState: .Learn))
        }
        let manager = makeManager()

        #expect(manager.isGoalReached)
        #expect(manager.canLog == false)
        #expect(manager.isStreakLost == false)   // a finished goal can't be lost
    }

    @Test func freezesCountTowardGoal() {
        // 5 learned + 2 frozen = 7 days = week done
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(8)))
        for day in 1...5 { context.insert(DayLog(date: daysAgo(day), dayState: .Learn)) }
        context.insert(DayLog(date: daysAgo(6), dayState: .freeze))
        context.insert(DayLog(date: daysAgo(7), dayState: .freeze))
        let manager = makeManager()

        #expect(manager.isGoalReached)
    }

    // MARK: - 32-hour rule

    @Test func streakAliveBefore32Hours() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(3)))
        context.insert(DayLog(date: hoursAgo(31), dayState: .Learn))
        let manager = makeManager()

        #expect(manager.isStreakLost == false)
    }

    @Test func streakLostAfter32Hours() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(3)))
        context.insert(DayLog(date: hoursAgo(33), dayState: .Learn))
        let manager = makeManager()

        #expect(manager.isStreakLost)
        #expect(manager.canLog == false)
        #expect(manager.Streak == 1)   // numbers stay until a new goal is set
    }

    @Test func newGoalWithNoLogsIsLostAfter32Hours() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: hoursAgo(33)))
        let manager = makeManager()

        #expect(manager.isStreakLost)
    }

    // MARK: - Starting over

    @Test func setGoalAfterLossRestartsCountersButKeepsHistory() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(5)))
        context.insert(DayLog(date: daysAgo(4), dayState: .Learn))
        context.insert(DayLog(date: daysAgo(3), dayState: .freeze))
        let manager = makeManager()
        #expect(manager.isStreakLost)

        manager.SetGoal(title: "SwiftUI", duration: .month)

        #expect(manager.isStreakLost == false)
        #expect(manager.Streak == 0)
        #expect(manager.FrezzesUsage == 0)
        #expect(manager.logs.count == 2)   // old days still in the calendar
        #expect(manager.state(for: daysAgo(4)) == .Learn)
    }

    // MARK: - Calendar

    @Test func stateForEachDay() {
        context.insert(LearningGoal(title: "Swift", duration: .week, startDate: daysAgo(3)))
        context.insert(DayLog(date: daysAgo(2), dayState: .Learn))
        context.insert(DayLog(date: daysAgo(1), dayState: .freeze))
        let manager = makeManager()

        #expect(manager.state(for: daysAgo(2)) == .Learn)
        #expect(manager.state(for: daysAgo(1)) == .freeze)
        #expect(manager.state(for: daysAgo(5)) == .notLogged)
        #expect(manager.state(for: .now) == .notLogged)
    }
}
