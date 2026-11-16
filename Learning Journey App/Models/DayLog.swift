import Foundation
import SwiftData

@Model
final class DayLog{
    
    var date: Date
    var dayState : LearnState
    
    init(date: Date = .now, dayState: LearnState) {
        self.date = date
        self.dayState = dayState
    }
}
