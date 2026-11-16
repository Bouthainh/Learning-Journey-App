import SwiftUI


struct EditGoalView: View {
    @Environment(JourneyManager.self) private var journeyManager
    @Environment(\.dismiss) private var dismiss   // goes back to the previous screen

    @State private var goal = ""
    @State private var selectedDuration: LearningDuration = .week
    @State private var showUpdateAlert = false

    // did user change anything?
    private var hasChanges: Bool {
        goal != journeyManager.goal?.title || selectedDuration != journeyManager.Duration
    }

    // the journey already ended, so no warning needed
    private var journeyEnded: Bool {
        journeyManager.isGoalReached || journeyManager.isStreakLost
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 32) {

            GoalSetter(goal: $goal)

            VStack(alignment: .leading, spacing: 12) {
                Text("I want to learn it in a")
                    .font(.AppNormalText)
                DurationPicker(selected: $selectedDuration)   // shared component
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .navigationTitle("Learning goal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    saveTapped()
                } label: {
                    Image(systemName: "checkmark")
                }
                .buttonStyle(.glassProminent)
                .tint(.orange)
                .disabled(journeyManager.goalValiddation(for: goal) != nil)
            }
        }
        .alert("Update Learning goal", isPresented: $showUpdateAlert) {
            Button("Dismiss", role: .cancel) { }
            Button("Update") { update() }
        } message: {
            Text("If you update now, your streak will start over.")
        }
        .onAppear {
            goal = journeyManager.goal?.title ?? ""
            selectedDuration = journeyManager.Duration
        }
    }

    private func saveTapped() {
        if journeyEnded {
            update()
        } else if hasChanges {
            showUpdateAlert = true
        } else {
            dismiss()                
        }
    }

    private func update() {
        journeyManager.SetGoal(title: goal, duration: selectedDuration)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        EditGoalView()
    }
    .environment(JourneyManager.preview(.active))
}
