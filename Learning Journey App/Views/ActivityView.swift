import SwiftUI

struct ActivityView: View {
    @Environment(JourneyManager.self) private var journeyManager

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            header

            WeekCalendar()                      // shared component

            // stats
            HStack(spacing: 12) {
                StateCard(icon: "flame.fill", color: .orange,
                         value: journeyManager.Streak, label: "Learned")
                StateCard(icon: "snowflake", color: .cyan,
                         value: journeyManager.FrezzesUsage, label: "Freezed")
            }

            Spacer()

            // the middle of the screen changes with the situation
            Group {
                if journeyManager.isGoalReached {
                    goalEnded(icon: "hands.and.sparkles.fill",
                              title: "Well done!",
                              subtitle: "Ready for your next goal?")
                } else if journeyManager.isStreakLost {
                    goalEnded(icon: "xmark.seal",
                              title: "You didn't reach your goal this time.",
                              subtitle: "Want to set another goal?")
                } else {
                    logSection
                }
            }
            .frame(maxWidth: .infinity)

            Spacer()
        }
        .padding(.horizontal, 16)
        .toolbar(.hidden, for: .navigationBar)   // our own header replaces the nav bar
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activity")
                    .font(.AppTitle)
                    .bold()
                Text(Date.now, format: .dateTime.weekday(.wide).day().month(.wide))
                    .font(.AppNormalText)
                    .foregroundStyle(.gray)
            }

            Spacer()

            headerButton(icon: "calendar") {
                CalendarView()
            }
            headerButton(icon: "pencil.and.outline") {
                EditGoalView()
            }
        }
    }

    private func headerButton<Destination: View>(
        icon: String,
        @ViewBuilder destination: () -> Destination
    ) -> some View {
        NavigationLink(destination: destination()) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive(), in: .circle)
        }
        .buttonStyle(.plain)
    }

    // MARK: Log section (primary button and freeze button)

    //MARK: button style cases
    private var buttonLooks: (circle: ButtonLook, freeze: ButtonLook) {
        // every possible look, named once
        let learnActive    = ButtonLook(title: "Log as Learned",    textColor: .white, glass: .regular.tint(.orange).interactive())
        let learnDone      = ButtonLook(title: "Logged as Learned", textColor: .gray,  glass: .regular)
        let freezeActive   = ButtonLook(title: "Freeze for a day",  textColor: .white, glass: .regular.tint(.cyan).interactive())
        let freezeDisabled = ButtonLook(title: "Freeze for a day",  textColor: .gray,  glass: .regular)
        let freezeDone     = ButtonLook(title: "Freezed for a day", textColor: .gray,  glass: .regular)

        // the freeze button is blue only if there are freezes left
        let freezeAvailable = journeyManager.canFreeze ? freezeActive : freezeDisabled

        // only the button that was pressed today is "done";
        // the other one stays active so the user can change their mind
        switch journeyManager.todayState {
        case .notLogged: return (circle: learnActive, freeze: freezeAvailable)
        case .Learn:     return (circle: learnDone,   freeze: freezeAvailable)
        case .freeze:    return (circle: learnActive, freeze: freezeDone)
        }
    }
    
    private var logSection: some View {
        let looks = buttonLooks

        return VStack(spacing: 24) {

            Button {
                journeyManager.Log(.Learn)
            } label: {
                Text(looks.circle.title)
                    .font(.title2.bold())
                    .foregroundStyle(looks.circle.textColor)
                    .frame(width: 280, height: 280)
                    .glassEffect(looks.circle.glass, in: .circle)
            }
            .buttonStyle(.plain)
            .disabled(!journeyManager.canLog)

            Button {
                journeyManager.Log(.freeze)
            } label: {
                Text(looks.freeze.title)
                    .font(.headline)
                    .foregroundStyle(looks.freeze.textColor)
                    .frame(width: 270, height: 48)
                    .glassEffect(looks.freeze.glass, in: .capsule)
            }
            .buttonStyle(.plain)
            .disabled(!journeyManager.canFreeze)

            Text("\(journeyManager.FrezzesUsage) out of \(journeyManager.Duration.maxFreezes) Freezes used")
                .font(.footnote)
                .foregroundStyle(.gray)
        }
    }

    // MARK: Goal ended cases: well done / didn't reach

    private func goalEnded(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 8) {
            
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(.orange)
                .padding(.top, -64)

            Text(title)
                .font(.headline)
                .multilineTextAlignment(.center)

            Text(subtitle)
                .font(.footnote)
                .foregroundStyle(.gray)

            NavigationLink {
                EditGoalView()
            } label: {
                Label("Set a goal", systemImage: "pencil.and.outline")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(width: 151, height: 46)
                    .glassEffect(.regular.tint(.orange).interactive(), in: .capsule)
            }
            .buttonStyle(.plain)
            .padding(.top, 64)
        }
    }
}

// MARK: State card (only used on this screen, so it lives in this file)

private struct StateCard: View {
    let icon: String
    let color: Color
    let value: Int
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text("\(value) \(value == 1 ? "day" : "days")")   // the Day / Days rule
                .font(.headline)
            Text(label)
                .font(.caption)
                .foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .glassEffect(.regular, in: .rect(cornerRadius: 20))
    }
}

//MARK: Primary and Freeze Buttons styles
private struct ButtonLook {
    let title: String
    let textColor: Color
    let glass: Glass
}

#Preview("Active") {
    NavigationStack { ActivityView() }
        .environment(JourneyManager.preview(.active))
}

#Preview("Well done") {
    NavigationStack { ActivityView() }
        .environment(JourneyManager.preview(.goalReached))
}

#Preview("Didn't reach") {
    NavigationStack { ActivityView() }
        .environment(JourneyManager.preview(.streakLost))
}
