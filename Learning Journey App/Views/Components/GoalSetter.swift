import SwiftUI

struct GoalSetter : View {
    
    @Environment(JourneyManager.self) private var journeyManager
       @Binding var goal: String   // owned by the parent screen

       var body: some View {
           VStack(alignment: .leading, spacing: 12) {
               Text("I want to learn")
                   .font(.AppNormalText)

               TextField("Write here your goal to achive", text: $goal)

               Divider()

               // show the error only after the user starts typing
               if let error = journeyManager.goalValiddation(for: goal), !goal.isEmpty {
                   Text(error)
                       .font(.footnote)
                       .foregroundStyle(.red)
               }
           }
       }
   }

   #Preview {
       GoalSetter(goal: .constant("5 apps"))
           .environment(JourneyManager.preview)
           .padding()
   }
