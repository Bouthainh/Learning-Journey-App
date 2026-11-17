import Foundation
import SwiftData

//A model of Learing Goal when setting, with characters: (title,duration to achive this goal, when to start?)

@Model
final class LearningGoal {
    
    var title : String
    var duration : LearningDuration
    var startDate : Date
    
     
    init(title: String, duration: LearningDuration, startDate: Date = .now) {
        self.title = title
        self.duration = duration
        self.startDate = startDate
    }
    
}
