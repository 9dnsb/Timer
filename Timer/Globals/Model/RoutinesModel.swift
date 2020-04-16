//
//  RoutinesModel.swift
//  Timer
//
//  Created by David Blatt on 3/19/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Stop {
    var name: String;
    var id: String;
}

class Favourite: NSManagedObject {
    
    @NSManaged var name: String
    @NSManaged var id: String
    
    var stop : Stop {
        get {
            return Stop(name: self.name, id: self.id)
        }
        set {
            self.name = newValue.name
            self.id = newValue.id
        }
    }
}

struct HighLowInterval: Equatable {
    var firstIntervalHigh: Bool
    var numSets: Int
    var intervalName: String
    var highInterval: IntervalIntensity
    var lowInterval: IntervalIntensity
    var HighLowIntervalColor: UIColor
    var highLowId: String!
}

struct IntervalIntensity: Equatable {
    var duration: Int
    var intervalColor: UIColor
    var sound: sounds = sounds.none
}


struct Routine: Equatable {
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        let a = lhs.name == rhs.name
        let b = lhs.type == rhs.type
        let c = lhs.warmup == rhs.warmup
        let d = lhs.intervals == rhs.intervals
        let e = lhs.numCycles == rhs.numCycles
        let f = lhs.restTime == rhs.restTime
        let g = lhs.coolDown == rhs.coolDown
        let h = lhs.routineColor == rhs.routineColor
        
        if a && b && c && d && e && f && g && h  {
            return true
        }
        return false
    }
    
    var name: String
    var type: String
    var warmup: IntervalIntensity
    var intervals: [HighLowInterval]
    var numCycles: Int
    var restTime: IntervalIntensity
    var coolDown: IntervalIntensity
    var routineColor: UIColor
    var totalTime: Int
    var routineID: String!
    var routineIndex: Int!
    
}

struct routArray {
    var interval: IntervalIntensity
    var currInterval: Int
    var totalInterval: Int
    var isHigh: Int
    var intervalName: String
}

enum intervalOptions: Int {
    case warmUp = 1
    case rest = 2
    case cooldown = 3
    case lowInt = 4
    case highInt = 5
    case highLowInt = 6
}

enum sounds: String, CaseIterable {
    case none = "None"
    case airhorn = "Air Horn"
    case alarm = "Alarm"
    case gong = "Bell2"
    case churchBell = "Church Bell"
    case completed = "Completed"
    case ding = "Ding"
    case foghorn = "Foghorn"
    case keysCling = "Keys Clinging"
    case pencilCheck = "Pencil Check"
    case phoneVibrate = "Phone Vibration"
    case trainHonk = "Train Honk"
    case trainHorn = "Train Horn"
    case trainWhistle = "Train Whistle"
    case watchAlarm = "Watch Alarm"
}

extension CaseIterable where Self: Equatable {
    
    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}


