//follows the observation framework
import Observation
import Foundation

@Observable
class JourneyManager{
    
    //MARK: properties with storing logic
    var Duration : LearningDuration = .week {
        didSet{
            UserDefaults.standard.set(Duration.rawValue, forKey: "Duration")
        }}
    
    var Streak : Int = 0 {
        didSet{
            UserDefaults.standard.set(Streak, forKey: "Streak")
        }}
    
    var FrezzesUsage : Int = 0 {
        didSet{
            UserDefaults.standard.set(FrezzesUsage, forKey: "FrezzesUsage")
        }}
    
    var LastLoggedDate : Date? {
        didSet {
            UserDefaults.standard.set(LastLoggedDate, forKey: "LastLoggedDate")
        }}
    
    var lastLoggedState: LearnState = .notLogged {
          didSet { UserDefaults.standard.set(lastLoggedState.rawValue, forKey: Keys.lastLoggedState) }
      }
    
    var didLoseStreak :Bool = false
    
    //MARK: init()
    init(){
        
        let defaults = UserDefaults.standard
        
        let savedDuration = defaults.string(forKey: "Duration") ?? ""
        Duration = LearningDuration(rawValue: savedDuration) ?? .week
        
        Streak = defaults.integer(forKey: "Streak")
        
        FrezzesUsage = defaults.integer(forKey: "FrezzesUsage")
        
        LastLoggedDate = defaults.object(forKey: "LastLoggedDate") as? Date
        
        let savedState = defaults.string(forKey: "lastLoggedState") ?? ""
        lastLoggedState = LearnState(rawValue: savedState) ?? .notLogged
    }
    
    //Computed properties
    
    var FreezesLeft: Int { Duration.maxFreezes - FrezzesUsage}
    
    var isLoggedToday: Bool {
        
        guard let LastLoggedDate else {return false}
        
        return Calendar.current.isDateInToday(LastLoggedDate)
    }
    
    var canLog: Bool {
        !isLoggedToday && !isGoalReached
    }
    
    var canFreeze : Bool{
        canLog && FreezesLeft > 0
        
    }
    
    var isGoalReached: Bool {
        Streak + FrezzesUsage >= Duration.days
    }
    
    //MARK: functions
    
    //action > when user Log it checks which state, and do calcultion
    func Log( state: LearnState ){
        
        guard canLog else {return}
        
        switch state {
            
        case .Learn:
            Streak+=1
        
        case .freeze:
            guard canFreeze else {return}
            FrezzesUsage+=1
            
        case .notLogged:
            return
            
        }
        
        LastLoggedDate = Date()
        lastLoggedState = state
        didLoseStreak = false

    }

    //action > checks streak is alive? "32h rule"
    func CheckStreak(){
        
        guard let LastLoggedDate else {return}
        
        let timePassed = Date().timeIntervalSince(LastLoggedDate)
        let limit : TimeInterval = 32 * 60 * 60
        
        if timePassed > limit {
            
            Streak = 0
            didLoseStreak = true
        }
    }
    
    //action > if update new goal, it reintialized all properties
    func ChangeDuration ( to newDuration : LearningDuration ){
        
        Duration = newDuration
        Streak = 0
        FrezzesUsage = 0
        LastLoggedDate = nil
        lastLoggedState = .notLogged
        didLoseStreak = false
    }
}
