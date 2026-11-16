import Foundation
import SwiftData

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
