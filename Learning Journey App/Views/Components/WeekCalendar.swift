import SwiftUI

struct WeekCalendar: View {
    @Environment(JourneyManager.self) private var journeyManager

    private var weekDays: [Date] {
        let calendar = Calendar.current
        guard let start = calendar.dateInterval(of: .weekOfYear, for: .now)?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
    }

    var body: some View {
        HStack {
            ForEach(weekDays, id: \.self) { day in
                VStack(spacing: 8) {
                    Text(day, format: .dateTime.weekday(.narrow))   // "S", "M", ...
                        .font(.caption)
                        .foregroundStyle(.gray)

                    DayCircler(date: day, state: journeyManager.state(for: day))
                }
                .frame(maxWidth: .infinity)   // 7 equal columns
            }
        }
    }
}

