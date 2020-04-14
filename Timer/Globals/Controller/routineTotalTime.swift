//
//  routineTotalTime.swift
//  Timer
//
//  Created by David Blatt on 3/21/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation

public class routineTotalTime  {
//     func calctotalRoutineTimeString(rout: Routine) -> String {
//
//        let (m,s) = self.secondsToHoursMinutesSeconds(seconds: self.calctotalRoutineTime(rout: rout))
//        return String(format: "%.2d:%.2d", m,s)
//    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int) {

      return ((seconds/60),(seconds % 3600 % 60))
    }

    func calctotalRoutineTime(routArrayPlayer: [routArray]) -> Int {
        var totalTime = 0

        for jj in routArrayPlayer {
            totalTime += jj.interval.duration
        }
        return totalTime
    }

    func buildArray(rout: Routine) -> [routArray] {
        var routArrayPlayer = [routArray]()
        for (_, i) in rout.intervals.enumerated() {
            var x = 0

            if i.firstIntervalHigh {
                while x < i.numSets {
                    let intCount = x + 1
                    let toAppend = routArray(interval: i.highInterval, currInterval: intCount, totalInterval: i.numSets, isHigh: intervalOptions.highInt.rawValue, intervalName: i.intervalName)
                    routArrayPlayer.append(toAppend)
                    let toAppend2 = routArray(interval: i.lowInterval, currInterval:  intCount, totalInterval: i.numSets , isHigh: intervalOptions.lowInt.rawValue, intervalName: i.intervalName)
                    routArrayPlayer.append(toAppend2)
                    x += 1
                }


            }
            else {
                while x < i.numSets {
                    let intCount = x + 1
                    let toAppend = routArray(interval: i.lowInterval, currInterval: intCount, totalInterval: i.numSets , isHigh: intervalOptions.lowInt.rawValue, intervalName: i.intervalName)
                    routArrayPlayer.append(toAppend)
                    let toAppend2 = routArray(interval: i.highInterval, currInterval:  intCount, totalInterval: i.numSets, isHigh: intervalOptions.highInt.rawValue, intervalName: i.intervalName)
                    routArrayPlayer.append(toAppend2)
                    x += 1
                }
            }
            if rout.numCycles > 1 && rout.restTime.duration > 0 {
                let warmupRout = routArray(interval: IntervalIntensity(duration: rout.restTime.duration, intervalColor: rout.restTime.intervalColor, sound: rout.restTime.sound), currInterval: 999, totalInterval: 999, isHigh: intervalOptions.rest.rawValue, intervalName: "Warm Up")
                print("ADD REST TIME")
                routArrayPlayer.append(warmupRout)
            }
        }
        var bb = 1
        if rout.numCycles > 1 {
            let routArrayPlayerOrig = routArrayPlayer
            while bb < rout.numCycles {
                routArrayPlayer.append(contentsOf: routArrayPlayerOrig)
                bb += 1
            }


        }
        if rout.warmup.duration != 0 {
            let warmupRout = routArray(interval: IntervalIntensity(duration: rout.warmup.duration, intervalColor: rout.warmup.intervalColor, sound: rout.warmup.sound), currInterval: 998, totalInterval: 998, isHigh: intervalOptions.warmUp.rawValue, intervalName: "Rest")
            routArrayPlayer.insert(warmupRout, at: 0)
        }
        if rout.coolDown.duration != 0 {
            let warmupRout = routArray(interval: IntervalIntensity(duration: rout.coolDown.duration, intervalColor: rout.coolDown.intervalColor, sound: rout.coolDown.sound), currInterval: 999, totalInterval: 999, isHigh: intervalOptions.cooldown.rawValue, intervalName: "Cool Down")
            routArrayPlayer.append(warmupRout)
        }
        
        return routArrayPlayer
    }


    
}


