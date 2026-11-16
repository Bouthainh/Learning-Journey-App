//
//  DurationPicker.swift
//  Learning Journey App
//
//  Week / Month / Year glass buttons. Shared by OnBoarding and EditGoalView.
//

import SwiftUI

struct DurationPicker: View {
    @Binding var selected: LearningDuration   // owned by the parent screen

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

#Preview {
    DurationPicker(selected: .constant(.month))
        .padding()
}
