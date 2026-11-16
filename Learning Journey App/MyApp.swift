import SwiftUI
import SwiftData

@main
struct MyApp: App {
    
    let container : ModelContainer
    
    @State private var journeyManager: JourneyManager

    init() {
        
        let container = try! ModelContainer(for: LearningGoal.self, DayLog.self)
        self.container = container
        
        _journeyManager = State(initialValue: JourneyManager(context: container.mainContext))

    }
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(journeyManager)
        }.modelContainer(container)

    }
}
