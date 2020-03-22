//
//  PlayerModel.swift
//  Timer
//
//  Created by David Blatt on 3/22/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation

struct playerModel {
    var isTimerRunning = false
    var seconds = 0
    var currentIntervalCycle = 0
    var totalIntervalCycles = 0
    var totalTime = 0
    var elapsedTime = 0
    var veryFirstInterval = true

}

struct currentInterval {
    var totalIntervalSets = 0
    var currentIntervalSet = 0
    var firstInterval = true
}

struct resumeButton {
    var resumeTapped = true
    var text = ""
}

