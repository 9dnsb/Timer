//
//  Globals.swift
//  Timer
//
//  Created by David Blatt on 3/22/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit
import MKColorPicker
import McPicker
import CoreStore
import AVFoundation

public class globals  {
    var dataStack = DataStack(xcodeModelName: "Timer")
    func setAllArrays(rout: Routine) -> [Int] {
        
        return [0]
    }
    
    func timeString(time:TimeInterval) -> String {
        
        let minutes = Int(time) / 60
        let seconds = Int(time)  % 3600 % 60
        return String(format: "%02i:%02i ", minutes, seconds)
    }
    
    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    func keyboardClick(view: UIView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }
    
    func animationTableChange(tableView: UITableView) {
        UIView.transition(with: tableView,
                          duration: 0.2,
                          options: .transitionCrossDissolve,
                          animations: { tableView.reloadData() })
    }
    
    func setAllColorsArray() -> [UIColor] {
        return [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemTeal, .systemBlue, .systemIndigo, .systemPurple]
    }
    
    func createColorPopover(tableView: UITableView, indexPath: IndexPath) -> ColorPickerViewController{
        let colorPicker = ColorPickerViewController()
        if let popoverController = colorPicker.popoverPresentationController{
            let colors : [UIColor] = [.systemRed, .systemOrange, .systemYellow, .systemGreen, .systemTeal, .systemBlue, .systemIndigo, .systemPurple]
            colorPicker.allColors = colors
            colorPicker.pickerSize = CGSize(width: UIScreen.main.bounds.width - 120, height: 125) //default 250, 250
            popoverController.delegate = colorPicker
            popoverController.permittedArrowDirections = .any
            //            popoverVC.delegate = self
            popoverController.sourceView = tableView
            popoverController.sourceRect = tableView.cellForRow(at: indexPath)!.frame
            
        }
        return colorPicker
    }
    
    func setMcPickerDetails(mcPicker: McPicker) {
        mcPicker.backgroundColor = .secondarySystemGroupedBackground
        mcPicker.pickerBackgroundColor = .secondarySystemGroupedBackground
        mcPicker.toolbarBarTintColor = .systemGroupedBackground
    }
    
    func loadCoreData2(rout1: Routine) {
        let dataStack = self.dataStack
        do {
            try dataStack.addStorageAndWait(SQLiteStore())
            
        }
        catch { // ...
            print("error")
        }
        do {
            
            
            dataStack.perform(
                asynchronous: { (transaction) -> Routine in
                    let i : CDRoutine = try transaction.fetchOne(
                        From<CDRoutine>()
                            .where(\.cdUUID == rout1.routineID)
                        )!
                    //person.age = person.age + 1
                    print("person", i)
                    var rout: Routine = Routine(name: "", type: "", warmup: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 5, intervalName: "Interval Cycle #1", highInterval: IntervalIntensity(duration: 60, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 0, restTime: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemBlue, sound: sounds.none), routineColor: .systemRed, totalTime: 0)
                    //print("i", i)
                    //rout.objectID = i
                    //print(i.cdName)
                    
                    rout.name = i.cdName!
                    rout.numCycles = Int(i.cdNumCycles)
                    rout.routineColor =  hexStringToUIColor(hex: i.cdRoutineColor!)
                    //print(i.cdRoutineColor!)
                    //print(rout.routineColor)
                    rout.warmup = self.setIntIntesity(cdInt: i.warmup!)
                    rout.restTime = self.setIntIntesity(cdInt: i.rest!)
                    rout.coolDown = self.setIntIntesity(cdInt: i.coolDown!)
                    rout.routineID = i.cdUUID!
                    rout.routineIndex = Int(i.cdRoutineIndex)
                    
                    
                    for (j, elem) in i.cDHighLowInterval!.enumerated() {
                        //print("j", j)
                        let elem = elem as! CDHighLowInterval
                        if !rout.intervals.indices.contains(j) {
                            rout.intervals.append(HighLowInterval(firstIntervalHigh: false, numSets: 5, intervalName: "Interval Cycle #1", highInterval: IntervalIntensity(duration: 60, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed))
                        }
                        rout.intervals[j].firstIntervalHigh = elem.cdfirstIntervalHigh
                        rout.intervals[j].HighLowIntervalColor = hexStringToUIColor(hex: elem.cdHighLowIntervalColor!)
                        rout.intervals[j].intervalName = elem.cdintervalName!
                        rout.intervals[j].highLowId = elem.cdHighLowId
                        //print(Int(elem.cdnumSets))
                        rout.intervals[j].numSets = Int(elem.cdnumSets)
                        rout.intervals[j].lowInterval = self.setIntIntesity(cdInt: elem.lowInterval!)
                        rout.intervals[j].highInterval = self.setIntIntesity(cdInt: elem.highInterval!)
                        return rout
                    }
                    return rout
            },
                
                completion: { _ in
                    
            }
            )
            
            
            
            
            
        }
    }
    
    func setIntIntesity(cdInt: CDIntervalIntensity) -> IntervalIntensity {
        let x = IntervalIntensity(duration: Int(cdInt.cdduration), intervalColor: hexStringToUIColor(hex: cdInt.cdintervalColor!), sound: sounds(rawValue: cdInt.cdsound!)!)
        
        return x
    }

    func playSound(sound: String, setSession: Bool = true) -> AVAudioPlayer{
        var player2 = AVAudioPlayer()
        if UserDefaults.standard.bool(forKey: settings.enableSound.rawValue) == false || sound == sounds.none.rawValue {
            //print("is false")
            return player2
        }
        //print("playSound")
        if setSession {
            let session = AVAudioSession.sharedInstance()
            try? session.setCategory(.playback, options: .mixWithOthers)
            try? session.setActive(true, options: [])
        }
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!)

        player2 = try! AVAudioPlayer(contentsOf: alertSound)
        player2.prepareToPlay()
        player2.volume =  UserDefaults.standard.float(forKey: settings.soundVolume.rawValue) / 10
        player2.play()
        return player2

    }
    
    
    
}
