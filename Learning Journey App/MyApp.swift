import SwiftUI
import SwiftData

@main
struct MyApp: App {
    
    let container : ModelContainer
    
    @State private var journeyManager: JourneyManager

    init() {
        
        let container = try! ModelContainer(for: LearningGoal.self, DayLog.self)
        self.container = container
        
        //Dependency Injection
        _journeyManager = State(initialValue: JourneyManager(context: container.mainContext))

    }
    var body: some Scene {
        WindowGroup {
            RootView()
            //Dependency Injection
                .environment(journeyManager)
        }.modelContainer(container)

    }
}
