import SwiftUI

//shared component of highlight circle on calendar
struct DayCircler: View {
    
    //MARK: indicators to highlight: date, what state?, is it today?
    let date: Date
    let state: LearnState

    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    //MARK: Highlight ui
    var body: some View {
        
        Text(date, format: .dateTime.day())
            .font(.headline)
            .foregroundStyle(textColor)
            .frame(width: 36, height: 36)
            .background(Circle().fill(backgroundColor))
    }

    //state color rules
    private var textColor: Color {
        switch state {
        case .Learn:     .orange
        case .freeze:    .cyan
        case .notLogged: .white
        }
    }

    private var backgroundColor: Color {
        switch state {
        case .Learn:     Color.orange.opacity(0.25)
        case .freeze:    Color.cyan.opacity(0.25)
        case .notLogged: isToday ? Color.orange : Color.clear   
        }
    }
}

