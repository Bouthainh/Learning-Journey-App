
import SwiftUI

struct CalendarView: View {
    @Environment(JourneyManager.self) private var journeyManager

    private var months: [Date] {
        let calendar = Calendar.current
        let firstDate = journeyManager.logs.first?.date ?? .now

        let firstYear = calendar.component(.year, from: firstDate)
        let thisYear = calendar.component(.year, from: .now)

        var result: [Date] = []
        for year in firstYear...thisYear {
            for month in 1...12 {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: 1)) {
                    result.append(date)
                }
            }
        }
        return result
    }

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 32) {
                    ForEach(months, id: \.self) { month in
                        MonthCalendar(month: month)
                            .id(month)
                    }
                }
                .padding(.horizontal, 16)
            }
            .onAppear {
                // jump to this month
                if let thisMonth = Calendar.current.dateInterval(of: .month, for: .now)?.start {
                    proxy.scrollTo(thisMonth, anchor: .top)
                }
            }
        }
        .navigationTitle("All activities")
        .navigationBarTitleDisplayMode(.inline)
        .defaultScrollAnchor(.bottom)
    }
}

#Preview {
    NavigationStack {
        CalendarView()
    }
    .environment(JourneyManager.preview(.active))
}
