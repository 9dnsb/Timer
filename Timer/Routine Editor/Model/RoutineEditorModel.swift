//
//  RoutineEditorModel.swift
//  Timer
//
//  Created by David Blatt on 2021-03-04.
//  Copyright © 2021 David Blatt. All rights reserved.
//

import Foundation

struct routineTableInfo {
    //var sectionNum : Int
    var rowsInSection: Int
    var isIntervalSection : Bool = false
    var intervalType : routineIntervalType
    var intervalRestTimePresent : Bool = false
}

enum routineIntervalType: String {

    case intervalName
    case timerColor
    case warmup
    case allIntervals
    case intervalRestTime
    case addNewInterval
    case repeatCycle
    case restTime
    case coolDown
    case intervalTotalTime
}
