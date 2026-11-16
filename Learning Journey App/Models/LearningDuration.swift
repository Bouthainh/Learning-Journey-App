
//enum: a list of duration with fixed choices (week,month, year)
//each case introduce an option

//string: to give each case a text version >>>raw value
//case itratable: to give ability to handdell them as a list
//codable: to give ability for cases to be handeld by data logic

enum LearningDuration: String,Codable, CaseIterable{
    
    case week
    case month
    case year
    

    // MARK: computed properties to set app rules
    //32 RULE
    var maxFreezes: Int {
        
        switch self {
            
        case .week: return 2
        case .month : return 8
        case .year : return 96
            
        }
    }
    //DURATION RULE
    var days: Int {
        switch self {
        case .week:  return 7
        case .month: return 30
        case .year:  return 365
        }
    }
}
