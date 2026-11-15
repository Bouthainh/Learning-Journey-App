enum LearningDuration: String, CaseIterable{
    
    case week
    case month
    case year
    

    // computed property to set app rule
    var maxFreezes: Int {
        
        switch self {
            
        case .week: return 2
        case .month : return 8
        case .year : return 96
            
        }
    }
    
    var days: Int {
        switch self {
        case .week:  return 7
        case .month: return 30
        case .year:  return 365
        }
    }
}
