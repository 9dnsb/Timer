//
//  routineTotalTime.swift
//  Timer
//
//  Created by David Blatt on 3/21/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation

public class routineTotalTime  {
     func calctotalRoutineTimeString(rout: Routine) -> String {

        let (m,s) = self.secondsToHoursMinutesSeconds(seconds: self.calctotalRoutineTime(rout: rout))
        return String(format: "%.2d:%.2d", m,s)
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {

      return ((seconds/60),(seconds % 3600 % 60))
    }

    func calctotalRoutineTime(rout: Routine) -> Int {
        var totalTime = 0
        for i in rout.intervals {
            totalTime += i.highInterval.duration * i.numSets
            totalTime += i.lowInterval.duration * i.numSets

        }
        totalTime = rout.numCycles * totalTime
        return totalTime
    }
    
}
