import SwiftUI

struct RootView : View {
    
    @Environment(JourneyManager.self) private var journeyManager

    var body: some View {
        
        if (journeyManager.hasGoal){
            
            NavigationStack {
            ActivityView()
            }}
        else{
            OnBoardingView()
        }
    }
}
#Preview {
    RootView()
        .environment(JourneyManager.preview(.active))
}
