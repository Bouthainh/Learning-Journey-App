import SwiftUI

//shared component of duration picker (week, month, year)
struct DurationPicker: View {
    
    @Binding var selected: LearningDuration   //follows the value state of Onboard, Edit views
    
    var body: some View {
        HStack(spacing: 12) {
            ForEach(LearningDuration.allCases, id: \.self) { duration in
                let isSelected = selected == duration

                Button {
                    selected = duration
                } label: {
                    Text(duration.rawValue.capitalized)
                        .font(.headline)
                        .foregroundStyle(isSelected ? Color.white : Color.gray)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .glassEffect(
                            .regular
                                .tint(isSelected ? Color.orange : Color.clear)
                                .interactive(),
                            in: .capsule
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
