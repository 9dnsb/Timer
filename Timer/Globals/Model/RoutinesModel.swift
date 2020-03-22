//
//  RoutinesModel.swift
//  Timer
//
//  Created by David Blatt on 3/19/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit

struct HighLowInterval {
    var firstIntervalHigh: Bool
    var numSets: Int
    var intervalName: String
    var highInterval: IntervalIntensity
    var lowInterval: IntervalIntensity
}

struct IntervalIntensity {
    var duration: Int
    var intervalColor: UIColor
    var sound: String
}


struct Routine {
    var name: String
    var type: String
    var warmup: Int
    var intervals: [HighLowInterval]
    var numCycles: Int
    var restTime: Int
    var coolDown: Int
    var routineColor: UIColor
    var totalTime: Int


}
