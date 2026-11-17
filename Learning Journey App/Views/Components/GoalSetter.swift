import SwiftUI

//shared component to set goal : system msg, field for user input. rused in onBoard, Edit views
struct GoalSetter : View {
    
    @Environment(JourneyManager.self) private var journeyManager //connect to the shared JM
    
    @Binding var goal: String //follows the value state of Onboard, Edit views

       var body: some View {
           VStack(alignment: .leading, spacing: 12) {
               Text("I want to learn")
                   .font(.AppNormalText)

               TextField("Write here your goal to achive", text: $goal)

               Divider()

               // show the error after the user starts typing
               if let error = journeyManager.goalValiddation(for: goal), !goal.isEmpty {
                   Text(error)
                       .font(.footnote)
                       .foregroundStyle(.red)
               }
           }
       }
   }
