import SwiftUI

struct OnBoardingView : View {
    
    @Environment(JourneyManager.self) private var journeyManager
    @State var goal = ""
    @State private var selectedDuration : LearningDuration = .week
    
    var body: some View {
        VStack (alignment: .leading){
            
            Image(systemName: "flame.fill")
                .font (.system(size: 36))
                .foregroundStyle(.orange)
                .frame(maxWidth: .infinity)
                .padding(.top, 57)
                .padding(.bottom, 80)
            
            VStack(alignment: .leading, spacing: 4){
                Text("Hello **Learner**")
                    .font(.AppTitle)
                
                
                Text ("This app will help you learn everyday!")
                    .font(.AppNormalText)
                    .foregroundStyle(.gray)
            } .padding(.bottom,37)
            

            GoalSetter(goal: $goal)
            
            VStack(alignment: .leading , spacing: 12){
                Text("I want to learn it in a")
                    .font(.AppNormalText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            DurationPicker(selected: $selectedDuration)
            
            Spacer()
            
            VStack(spacing: 12){
                
                Button{
                    journeyManager.SetGoal(title: goal, duration: selectedDuration)
                }
                label:{
                    Text("Start Learning")
                        .foregroundStyle(.white)
                        .font(.headline)
                        .frame(width: 151, height: 46)
                        .glassEffect(
                            .regular
                                .tint(.orange)
                                .interactive(),
                            in: .capsule
                        )
                    
                }.disabled(journeyManager.goalValiddation(for: goal) != nil)
                
                Text ("You can edit your desire later")
                    .font(.AppNote)
                    .foregroundStyle(.gray)
            } .frame(maxWidth: .infinity)
        } .padding(.horizontal , 16)
        
        
        
    }
}
