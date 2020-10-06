//
//  SaveRoutine.swift
//  Timer
//
//  Created by David Blatt on 4/10/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import CoreStore

public class SaveRoutine {
    var dataStack = DataStack(
        xcodeModelName: "Timer",
        migrationChain: ["Timer", "Timer 3"]
    )
    var rout : Routine!
    
    func save3() {
        
        let dataStack = self.dataStack
        do {
            try dataStack.addStorageAndWait(SQLiteStore())
            
        }
        catch { // ...
            print("error")
        }
        dataStack.perform(
            asynchronous: { (transaction) -> Bool in
                let person = transaction.create(Into<CDRoutine>())
                self.doSaveAction(person: person, transaction: transaction)
                return transaction.hasChanges
        },
            completion: { (result) -> Void in
                switch result {
                case .success(let hasChanges):
                    print("success! Has changes? \(hasChanges)")
                case .failure(let error): print(error)
                }
                //
        }
        )
    }
    
    func setHighLow(highLow: CDHighLowInterval, j: Int) {
        highLow.cdfirstIntervalHigh = self.rout.intervals[j].firstIntervalHigh
        highLow.cdHighLowIntervalColor = self.rout.intervals[j].HighLowIntervalColor.hexString(.d6)
        highLow.cdintervalName = self.rout.intervals[j].intervalName
        highLow.cdnumSets = Int32(self.rout.intervals[j].numSets)
        highLow.cdIntervalIndex = Int32(j)
    }
    
    func doSaveAction(person: CDRoutine, transaction: AsynchronousDataTransaction, isEdit: Bool = false) {
        //print("here4")
        //        if rout.routineIndex == nil {
        //            do {
        //                let objects = try self.dataStack.fetchAll(From<CDRoutine> ())
        //                rout.routineIndex = objects.count
        //            }
        //            catch {
        //                print("err")
        //            }
        //        }
        if self.rout.routineID == nil {
            person.cdUUID = UUID().uuidString
        }
        else {
            person.cdUUID = self.rout.routineID
        }
        
        person.cdName = self.rout.name
        person.cdNumCycles = Int32(self.rout.numCycles)
        person.cdRoutineColor = self.rout.routineColor.hexString(.d6)
        person.cdIntervalVoiceEnable = self.rout.enableIntervalVoice
        //print("self.rout.routineIndex", self.rout.routineIndex!)
        person.cdRoutineIndex = Int32(self.rout.routineIndex)
        for (j, _) in self.rout.intervals.enumerated() {
            
            let highLow = transaction.create(Into<CDHighLowInterval>())
            self.setHighLow(highLow: highLow, j: j)
            
            highLow.lowInterval = self.addHighLowCD(transaction: transaction, interval: self.rout.intervals[j].lowInterval)
            highLow.highInterval = self.addHighLowCD(transaction: transaction, interval: self.rout.intervals[j].highInterval)
            person.addToCDHighLowInterval(highLow)
            person.warmup = self.addHighLowCD(transaction: transaction, interval: self.rout.warmup)
            person.rest = self.addHighLowCD(transaction: transaction, interval: self.rout.restTime)
            person.coolDown = self.addHighLowCD(transaction: transaction, interval: self.rout.coolDown)
            person.restInterval = self.addHighLowCD(transaction: transaction, interval: self.rout.intervalRestTime)
        }
    }
    
    func saveData2() {
        
        let dataStack = self.dataStack
        dataStack.perform(
            asynchronous: { (transaction) -> Void in
                let person = try transaction.fetchOne(
                    From<CDRoutine>()
                        .where(\.cdUUID == self.rout.routineID)
                )
                
                
                if person == nil {
                    //print("here1")
                    self.save3()
                }
                else {
                    //print("here2")
                    transaction.delete(person)
                    self.save3()
                    
                }
        },
            
            completion: { (result) in
                switch result {
                case .success:
                    print("Done")
                    //self.navigationController?.popViewController(animated: true)
                    
                case .failure(let error):
                    //print("here3")
                    print(error)
                    //self.save3()
                }
        }
            
        )
        
        
    }
    
    func addHighLowCD(transaction: AsynchronousDataTransaction, interval: IntervalIntensity, isEdit: Bool = false) -> CDIntervalIntensity {
        let cd = transaction.create(Into<CDIntervalIntensity>())
        cd.cdduration = Int32(interval.duration)
        cd.cdintervalColor = interval.intervalColor.hexString(.d6)
        cd.cdsound = interval.sound.rawValue
        return cd
        
    }
}
