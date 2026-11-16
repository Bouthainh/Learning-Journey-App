import Foundation
import SwiftData

//A model of Day character (date, what is state ?)

@Model //a stamp tells the sw data this is a model to store in db
final class DayLog{
    
    var date: Date
    var dayState : LearnState
    
    init(date: Date = .now, dayState: LearnState) {
        self.date = date
        self.dayState = dayState
    }
}
