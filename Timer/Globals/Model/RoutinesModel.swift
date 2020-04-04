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

struct HighLowInterval {
    var firstIntervalHigh: Bool
    var numSets: Int
    var intervalName: String
    var highInterval: IntervalIntensity
    var lowInterval: IntervalIntensity
    var HighLowIntervalColor: UIColor
}

struct IntervalIntensity {
    var duration: Int
    var intervalColor: UIColor
    var sound: sounds = sounds.none
}


struct Routine {
    var name: String
    var type: String
    var warmup: IntervalIntensity
    var intervals: [HighLowInterval]
    var numCycles: Int
    var restTime: IntervalIntensity
    var coolDown: IntervalIntensity
    var routineColor: UIColor
    var totalTime: Int


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
    case trainHonk = "Train Honk"
    case trainWhistle = "Train Whistle x2"
}

extension CaseIterable where Self: Equatable {

    var index: Self.AllCases.Index? {
        return Self.allCases.firstIndex { self == $0 }
    }
}


