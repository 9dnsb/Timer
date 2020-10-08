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

struct HighLowInterval: Equatable, Codable {
    private enum CodingKeys: String, CodingKey {case firstIntervalHigh, numSets, intervalName, highInterval, lowInterval, HighLowIntervalColor, highLowId}
    var firstIntervalHigh: Bool
    var numSets: Int
    var intervalName: String
    var highInterval: IntervalIntensity
    var lowInterval: IntervalIntensity
    var HighLowIntervalColor: UIColor
    var highLowId: String! = ""

    init(firstIntervalHigh: Bool, numSets: Int, intervalName : String, highInterval: IntervalIntensity, lowInterval: IntervalIntensity, HighLowIntervalColor: UIColor, highLowId: String) {
            self.firstIntervalHigh = firstIntervalHigh
            self.numSets = numSets
            self.intervalName = intervalName
            self.highInterval = highInterval
            self.lowInterval = lowInterval
            self.HighLowIntervalColor = HighLowIntervalColor
            self.highLowId = highLowId

        }

    init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
        firstIntervalHigh = try container.decode(Bool.self, forKey: .firstIntervalHigh)
        numSets = try container.decode(Int.self, forKey: .numSets)
        intervalName = try container.decode(String.self, forKey: .intervalName)
        highInterval = try container.decode(IntervalIntensity.self, forKey: .highInterval)
        lowInterval = try container.decode(IntervalIntensity.self, forKey: .lowInterval)
        highLowId = try container.decode(String.self, forKey: .highLowId)
        HighLowIntervalColor = try container.decode(Color.self, forKey: .HighLowIntervalColor).uiColor
     }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(firstIntervalHigh, forKey: .firstIntervalHigh)
        try container.encode(numSets, forKey: .numSets)
        try container.encode(Color(uiColor: HighLowIntervalColor), forKey: .HighLowIntervalColor)
        try container.encode(intervalName, forKey: .intervalName)
        try container.encode(highInterval, forKey: .highInterval)
        try container.encode(lowInterval, forKey: .lowInterval)
        try container.encode(highLowId, forKey: .highLowId)

    }

}

struct IntervalIntensity: Equatable, Codable {
    private enum CodingKeys: String, CodingKey { case duration, intervalColor, sound }

    var duration: Int
    var intervalColor: UIColor
    var sound: sounds = sounds.none

    init(duration: Int, intervalColor: UIColor, sound : sounds) {
            self.duration = duration
            self.intervalColor = intervalColor
            self.sound = sound
        }

       init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
        duration = try container.decode(Int.self, forKey: .duration)
        sound = try container.decode(sounds.self, forKey: .sound)
        intervalColor = try container.decode(Color.self, forKey: .intervalColor).uiColor
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(duration, forKey: .duration)
            try container.encode(sound, forKey: .sound)
            try container.encode(Color(uiColor: intervalColor), forKey: .intervalColor)
        }
}

struct Color : Codable {
    var red : CGFloat = 0.0, green: CGFloat = 0.0, blue: CGFloat = 0.0, alpha: CGFloat = 0.0

    var uiColor : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    init(uiColor : UIColor) {
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    }
}


struct Routine: Equatable, Codable {
    static func == (lhs: Routine, rhs: Routine) -> Bool {
        let a = lhs.name == rhs.name
        let b = lhs.type == rhs.type
        let c = lhs.warmup == rhs.warmup
        let d = lhs.intervals == rhs.intervals
        let e = lhs.numCycles == rhs.numCycles
        let f = lhs.restTime == rhs.restTime
        let g = lhs.coolDown == rhs.coolDown
        let h = lhs.routineColor == rhs.routineColor
        let i = lhs.enableIntervalVoice == rhs.enableIntervalVoice
        
        if a && b && c && d && e && f && g && h && i {
            return true
        }
        return false
    }

    private enum CodingKeys: String, CodingKey { case name, type, warmup, intervals, numCycles, restTime, coolDown, routineColor, totalTime, routineID, routineIndex, intervalRestTime, enableIntervalVoice  }
    
    var name: String
    var type: String
    var warmup: IntervalIntensity
    var intervals: [HighLowInterval]!
    var numCycles: Int
    var restTime: IntervalIntensity
    var coolDown: IntervalIntensity
    var routineColor: UIColor
    var totalTime: Int
    var routineID: String! = ""
    var routineIndex: Int! = 0
    var intervalRestTime: IntervalIntensity
    var enableIntervalVoice: Bool

    init(name: String, type: String, warmup : IntervalIntensity, intervals: [HighLowInterval], numCycles : Int, restTime: IntervalIntensity, coolDown : IntervalIntensity, routineColor: UIColor, totalTime : Int, routineID: String, routineIndex : Int, intervalRestTime: IntervalIntensity, enableIntervalVoice : Bool) {
            self.name = name
            self.type = type
            self.warmup = warmup
        self.intervals = intervals
        self.numCycles = numCycles
        self.restTime = restTime
        self.coolDown = coolDown
        self.routineColor = routineColor
        self.totalTime = totalTime
        self.routineID = routineID
        self.routineIndex = routineIndex
        self.intervalRestTime = intervalRestTime
        self.enableIntervalVoice = enableIntervalVoice

        }

    init(from decoder: Decoder) throws {
         let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        type = try container.decode(String.self, forKey: .type)
        warmup = try container.decode(IntervalIntensity.self, forKey: .warmup)

        intervals = try container.decode([HighLowInterval].self, forKey: .intervals)
        numCycles = try container.decode(Int.self, forKey: .numCycles)
        restTime = try container.decode(IntervalIntensity.self, forKey: .restTime)
        coolDown = try container.decode(IntervalIntensity.self, forKey: .coolDown)
        routineColor = try container.decode(Color.self, forKey: .routineColor).uiColor
        totalTime = try container.decode(Int.self, forKey: .totalTime)
        routineID = try container.decode(String.self, forKey: .routineID)
        routineIndex = try container.decode(Int.self, forKey: .routineIndex)
        intervalRestTime = try container.decode(IntervalIntensity.self, forKey: .intervalRestTime)
        enableIntervalVoice = try container.decode(Bool.self, forKey: .enableIntervalVoice)
     }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(type, forKey: .type)
        try container.encode(Color(uiColor: routineColor), forKey: .routineColor)
        try container.encode(warmup, forKey: .warmup)
        try container.encode(intervals, forKey: .intervals)
        try container.encode(numCycles, forKey: .numCycles)
        try container.encode(warmup, forKey: .warmup)
        try container.encode(restTime, forKey: .restTime)
        try container.encode(coolDown, forKey: .coolDown)
        try container.encode(totalTime, forKey: .totalTime)
        try container.encode(routineID, forKey: .routineID)
        try container.encode(routineIndex, forKey: .routineIndex)
        try container.encode(intervalRestTime, forKey: .intervalRestTime)
        try container.encode(enableIntervalVoice, forKey: .enableIntervalVoice)
    }
    
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
    case intervalRest = 7
}

enum shareString: String {
    case groupName = "group.db.Timer"
    case JSONFile = "shared_routine.json"
}



struct constants {
    static let appBundle: String = "db.timer.main"
}

enum sounds: String, CaseIterable, Codable {
    case none = "None"
    case airhorn = "Air Horn"
    case alarm = "Alarm"
    case bell = "Bell"
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


