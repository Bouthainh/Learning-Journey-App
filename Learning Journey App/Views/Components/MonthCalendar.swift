import SwiftUI

//shared component for full year month-calander, reused in calendar views

struct MonthCalendar: View {
    
    @Environment(JourneyManager.self) private var journeyManager
    
    let month: Date

    private let calendar = Calendar.current
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)

  
    private var weekdaySymbols: [String] {
        let symbols = calendar.shortWeekdaySymbols.map { $0.uppercased() }
        let first = calendar.firstWeekday - 1
        return Array(symbols[first...] + symbols[..<first])
    }


    private var cells: [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month),
              let dayCount = calendar.range(of: .day, in: .month, for: month)?.count
        else { return [] }

        let weekdayOfFirst = calendar.component(.weekday, from: interval.start)
        let emptySpaces = (weekdayOfFirst - calendar.firstWeekday + 7) % 7

        let blanks: [Date?] = Array(repeating: nil, count: emptySpaces)
        let days: [Date?] = (0..<dayCount).map {
            calendar.date(byAdding: .day, value: $0, to: interval.start)
        }
        return blanks + days
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            Text(month, format: .dateTime.month(.wide).year())
                .font(.headline)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }

                // enumerated() gives each cell a position number to use as its id
                ForEach(Array(cells.enumerated()), id: \.offset) { _, day in
                    if let day {
                        DayCircler(date: day, state: journeyManager.state(for: day))
                    } else {
                        Color.clear.frame(height: 36)
                    }
                }
            }
        }
    }
}
