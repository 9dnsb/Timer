//
//  TableViewController.swift
//  Timer
//
//  Created by David Blatt on 3/19/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import McPicker
import CoreData

protocol ModalDelegate {
    func changeValue(value: [IntervalIntensity], highlowInt: HighLowInterval)
}

class RoutineEditorController: UIViewController, ModalDelegate {
    @IBOutlet weak var tableView: UITableView!
    var testValue: String = ""
    var intervalChanged = intervalOptions(rawValue: 0)
    var incomingData:Routine!
    var presetInterval: HighLowInterval = HighLowInterval(firstIntervalHigh: true, numSets: 5, intervalName: "Interval Cycle #1", highInterval: IntervalIntensity(duration: 60, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)
    var rout: Routine = Routine(name: "", type: "", warmup: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 5, intervalName: "Interval Cycle #1", highInterval: IntervalIntensity(duration: 60, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 0, restTime: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemBlue, sound: sounds.none), routineColor: .systemRed, totalTime: 0)
    var totalSections = 6
    var indexSection = 2
    var switchClicked = false
    var colorReceived : UIColor?
    var intervalGettingChanged : IntervalIntensity?
    var intervalChangeIndex = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        if rout.numCycles > 1 {
            switchClicked = true
        }
        print(rout.intervals.count)
        totalSections = totalSections + 1
        print(totalSections)
        //print(incomingData!)
        self.tableView.backgroundColor = .systemGroupedBackground
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        self.tableView.isEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.setNavigationBar()

    }

    func setNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let closeButton = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        //closeButton.tintColor = .white
        let editButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButton))
        self.navigationItem.setRightBarButtonItems([editButton], animated: true)
        //editButton.tintColor = .white
        //self.navigationController?.navigationBar.tintColor = .white
        //self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        // self.title = rout.name
    }

    @objc func closeButtonClick(){
        print("closeButtonClick")
        presentActionSheet()
        //self.disappear()

    }

    @objc func saveButton(){
        print("closeButtonClick")
        //presentActionSheet(ifSaving: true)


    }

    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")
        //self.playSound()
    }

    func presentActionSheet(ifSaving: Bool = false) {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController()

        let cancelActionButton = UIAlertAction(title: "Continue Editing", style: .cancel) { _ in
            print("Cancel")

        }
        actionSheetControllerIOS8.addAction(cancelActionButton)

        let saveActionButton = UIAlertAction(title: "Discard Changes", style: .destructive)
            { _ in
               print("Discard Changes")
                self.navigationController?.popViewController(animated: true)

        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        if ifSaving {
            let deleteActionButton = UIAlertAction(title: "Save Changes", style: .default)
                { _ in
                    print("Save Changes")

            }
            actionSheetControllerIOS8.addAction(deleteActionButton)
        }


        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }

    func changeValue(value: [IntervalIntensity], highlowInt: HighLowInterval) {
//        print("value", value)
//        print("intervalChanged", intervalChanged)
        if intervalChanged == intervalOptions.warmUp {
            rout.warmup = value[0]
        }
        if intervalChanged == intervalOptions.cooldown {
            rout.coolDown = value[0]
        }
        if intervalChanged == intervalOptions.rest {
            rout.restTime = value[0]
        }
        if intervalChanged == intervalOptions.highLowInt {
            print("change1")
            rout.intervals[intervalChangeIndex] = highlowInt
            if rout.intervals[intervalChangeIndex].firstIntervalHigh {
                print("change2")

                rout.intervals[intervalChangeIndex].highInterval = value[0]
                rout.intervals[intervalChangeIndex].lowInterval = value[1]

            }
            else{
                print("change3")
                rout.intervals[intervalChangeIndex].highInterval = value[1]
                rout.intervals[intervalChangeIndex].lowInterval = value[0]
            }
        }
        print(rout.intervals[intervalChangeIndex].lowInterval.intervalColor)
        //rout.warmup.intervalColor = value
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.reloadData()
         //print(testValue)
        //print("HERE")
    }

    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    func ifIntervalSectionsStart(indexP: IndexPath, row: Int) -> Bool {
        return indexP.section > 1 && indexP.section < totalSections - (indexSection + 2) && indexP.row == row
    }

    func getCurrInterval(indexP: IndexPath) -> HighLowInterval {
        let currIndexPath = indexP.section - indexSection
        return rout.intervals[currIndexPath]
    }

    @objc private func switchValueDidChange(_ sender: UISwitch) { // needed to treat switch changes as if the cell was selected/unselected
        print("switch")
        // let rowPoint = sender.convert(sender.bounds.origin, to: self.tableView)
        //let indexPath = self.tableView.indexPathForRow(at: rowPoint)
        //print(indexPath)
        switchClicked.toggle()
        if !switchClicked {
            rout.numCycles = 1
        }
        globals().animationTableChange(tableView: self.tableView)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        print("being appeared editor")
    }


    


}

extension RoutineEditorController: UITableViewDataSource, UITableViewDelegate {

    

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if section == 0 {
        return 1
    }

    else if section == 1 {
        return 1
    }
    if section == 2 {
        return rout.intervals.count
    }
    else if section == totalSections - 4 {
        return 1
    }
    else if section == totalSections - 3 {
        return 2
    }
    else if section == totalSections - 2 {
        if switchClicked {
            return 1
        }
        else {
            return 0
        }

    }
    else if section == totalSections - 1 {
        return 1
    }
    else if section == totalSections  {
        return 1
    }
    return 1
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    print("hererr")
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! inputTextCell
    print(cell.returnInputString())
    if cell.returnInputString() != "" {
        print("here1")
        rout.name = cell.returnInputString()
    }
    print("rout.name1", rout.name)
    if (indexPath.section == 0) && indexPath.row == 0{
        print("here2")
        print("rout.name", rout.name)
        cell.inputString.text = rout.name
        return cell
    }
    let cell2 = tableView.dequeueReusableCell(withIdentifier: "selectIntervalCell") as! selectIntervalCell
    if indexPath.section == (1) && indexPath.row == 0 {
        cell2.intervalName.text = "Warm Up"
        cell2.setImageColor(color: rout.warmup.intervalColor)
        cell2.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.warmup.duration)))
        return cell2
    }
    let cell24 = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! mainCell
    if indexPath.section == (2)  {
        cell24.setEditing(true, animated: true)
        cell24.contentView.frame = cell24.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        cell24.intervalName.text = rout.intervals[indexPath.row].intervalName
        cell24.totalTime.text = "\(rout.intervals[indexPath.row].numSets) Sets"
        let currInterval = rout.intervals[indexPath.row]
        if (currInterval.firstIntervalHigh) {
            cell24.leftLabelName.text = "High"
            cell24.rightLabelName.text = "Low"
            cell24.leftLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.highInterval.duration)))
            cell24.rightLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.lowInterval.duration)))
            cell24.leftLabelName.textColor = currInterval.highInterval.intervalColor
            cell24.leftLabelValue.textColor = currInterval.highInterval.intervalColor
            cell24.rightLabelName.textColor = currInterval.lowInterval.intervalColor
            cell24.rightLabelValue.textColor = currInterval.lowInterval.intervalColor
            
        }
        else {
            cell24.leftLabelName.text = "Low"
            cell24.rightLabelName.text = "High"
            cell24.leftLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.lowInterval.duration)))
            cell24.rightLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.highInterval.duration)))
            cell24.leftLabelName.textColor = currInterval.lowInterval.intervalColor
            cell24.leftLabelValue.textColor = currInterval.lowInterval.intervalColor
            cell24.rightLabelName.textColor = currInterval.highInterval.intervalColor
            cell24.rightLabelValue.textColor = currInterval.highInterval.intervalColor
        }
        return cell24
    }
//    if self.ifIntervalSectionsStart(indexP: indexPath, row: 0)  {
//        print("here1")
//        let currInterval = self.getCurrInterval(indexP: indexPath)
//        cell2.setImageColor(color: .systemRed)
//        cell2.intervalName.text = currInterval.intervalName
//        cell2.totalTime.text = "\(currInterval.numSets) Sets"
//        //cell2.setImageColor(color: rout.intervals[currIndexPath].) =
//        return cell2
//    }
//    let cell22 = tableView.dequeueReusableCell(withIdentifier: "lowHighCell") as! lowHighCell
//    if self.ifIntervalSectionsStart(indexP: indexPath, row: 1) {
//        print("here2")
//        let currInterval = self.getCurrInterval(indexP: indexPath)
//        if (currInterval.firstIntervalHigh) {
//            cell22.leftLabelName.text = "High"
//            cell22.rightLabelName.text = "Low"
//            cell22.leftLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.highInterval.duration)))
//            cell22.rightLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.lowInterval.duration)))
//            cell22.leftLabelName.textColor = currInterval.highInterval.intervalColor
//            cell22.leftLabelValue.textColor = currInterval.highInterval.intervalColor
//            cell22.rightLabelName.textColor = currInterval.lowInterval.intervalColor
//            cell22.rightLabelValue.textColor = currInterval.lowInterval.intervalColor
//
//        }
//        else {
//            cell22.leftLabelName.text = "Low"
//            cell22.rightLabelName.text = "High"
//            cell22.leftLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.lowInterval.duration)))
//            cell22.rightLabelValue.text = globals().timeString(time: TimeInterval(Int(currInterval.highInterval.duration)))
//            cell22.leftLabelName.textColor = currInterval.lowInterval.intervalColor
//            cell22.leftLabelValue.textColor = currInterval.lowInterval.intervalColor
//            cell22.rightLabelName.textColor = currInterval.highInterval.intervalColor
//            cell22.rightLabelValue.textColor = currInterval.highInterval.intervalColor
//        }
//
//        return cell22
//    }
    let cell3 = tableView.dequeueReusableCell(withIdentifier: "addNewCycle") as! addNewCycleCell
    if indexPath.section == totalSections - 4 {
        return cell3
    }
    let cell33 = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! switchCell
    if indexPath.section == totalSections - 3 && indexPath.row == 0 {
        cell33.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        let theSwitch = UISwitch()
        cell33.switchSwitch = theSwitch
        cell33.accessoryView = theSwitch
        cell33.switchLabel.text = "Repeat"
        theSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        theSwitch.isOn = switchClicked
        if rout.numCycles > 1 {
            theSwitch.isOn = true
        }
        return cell33
    }
    if indexPath.section == totalSections - 3 && indexPath.row == 1 {
        cell2.theImage.isHidden = true
        cell2.totalTime.text = "2"
        cell2.setIntervalName(intervalName: "Number of Cycles")
        if rout.numCycles > 1 {
            cell2.totalTime.text = String(rout.numCycles)
        }
        cell2.labelLeftContrain.constant = -20

    }
    if indexPath.section == totalSections - 2 {
        cell2.setImageColor(color: rout.restTime.intervalColor)
        cell2.setIntervalName(intervalName: "Rest Time")
        cell2.totalTime.text = String(rout.numCycles)
        cell2.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.restTime.duration)))
        return cell2
    }
    if indexPath.section == totalSections - 1 {
        cell2.setImageColor(color: rout.coolDown.intervalColor)
        cell2.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.coolDown.duration)))
        cell2.setIntervalName(intervalName: "Cool Down")
        return cell2
    }
    return cell2
}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // print("section: \(indexPath.section)")
        // print("row: \(indexPath.row)")
        if indexPath.section == totalSections - 4 {
            // totalSections += 1
            presetInterval.intervalName = "Interval Cycle #\(rout.intervals.count + 1)"
            rout.intervals.append(presetInterval)
            // let indexSet = IndexSet(integer: rout.intervals.count)
            tableView.performBatchUpdates({
                // tableView.insertSections(indexSet, with: .none)
                tableView.insertRows(at: [IndexPath(row: rout.intervals.count - 1, section: 2)], with: .none)
            }) { (update) in
                print("Update SUccess1")
                //self.tableView.setEditing(true, animated: true)
            }
        }

        if indexPath.section == 1 {
            let storyboard = UIStoryboard(name: "IntervalEditorVC", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "IntervalEditorVC") as? IntervalEditorVC
            myVC!.modalPresentationStyle = .fullScreen
            
            let navController = UINavigationController(rootViewController: myVC!)
            myVC!.title = "Warm Up"
            myVC!.interval = rout.warmup
            navController.presentationController?.delegate = myVC

            intervalChanged = intervalOptions.warmUp
            myVC?.delegate = self
            self.navigationController?.present(navController, animated: true, completion: nil)
            

        }

        if indexPath.section == totalSections - 3 && indexPath.row == 1 {
            let data = [Array(02...999)]

            var stringArray = Array<Array<String>>()

            for array in data {
                var subArray = Array<String>()

                for item in array {

                    subArray.append(String(item))


                }

                stringArray.append(subArray)
            }
            let mcPicker = McPicker(data: stringArray)


            mcPicker.backgroundColor = .secondarySystemGroupedBackground
            mcPicker.pickerBackgroundColor = .secondarySystemGroupedBackground
            mcPicker.pickerSelectRowsForComponents = [
                0: [rout.numCycles: true],

            ]


            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let hours = selections[0] {
                    self?.rout.numCycles = Int(hours)!
                    self?.tableView.reloadData()
                }
            }, cancelHandler: {
                print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
                print("Component \(componentThatChanged) changed value to \(newSelection)")

            })
        }

        if indexPath.section == 2 {
            print("section2")
            let storyboard = UIStoryboard(name: "IntervalEditorVC", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "IntervalEditorVC") as? IntervalEditorVC
            myVC!.modalPresentationStyle = .fullScreen

            let navController = UINavigationController(rootViewController: myVC!)
            myVC!.title = rout.intervals[indexPath.row].intervalName
            myVC!.interval = nil
            myVC!.intervalHighLow = rout.intervals[indexPath.row]
            navController.presentationController?.delegate = myVC

            intervalChanged = intervalOptions.highLowInt
            intervalChangeIndex = indexPath.row
            myVC?.delegate = self
            self.navigationController?.present(navController, animated: true, completion: nil)
        }

        if indexPath.section == totalSections - 2 {
                        let storyboard = UIStoryboard(name: "IntervalEditorVC", bundle: nil)
                        let myVC = storyboard.instantiateViewController(withIdentifier: "IntervalEditorVC") as? IntervalEditorVC
                        myVC!.modalPresentationStyle = .fullScreen

                        let navController = UINavigationController(rootViewController: myVC!)
                        myVC!.title = "Rest Time"
                        myVC!.interval = rout.restTime
                        navController.presentationController?.delegate = myVC

                        intervalChanged = intervalOptions.rest
                        myVC?.delegate = self
                        self.navigationController?.present(navController, animated: true, completion: nil)


        }

        if indexPath.section == totalSections - 1 {
                    let storyboard = UIStoryboard(name: "IntervalEditorVC", bundle: nil)
                    let myVC = storyboard.instantiateViewController(withIdentifier: "IntervalEditorVC") as? IntervalEditorVC
                    myVC!.modalPresentationStyle = .fullScreen

                    let navController = UINavigationController(rootViewController: myVC!)
                    myVC!.title = "Cool Down"
                    myVC!.interval = rout.coolDown
                    navController.presentationController?.delegate = myVC

                    intervalChanged = intervalOptions.cooldown
                    myVC?.delegate = self
                    self.navigationController?.present(navController, animated: true, completion: nil)
                }

    }

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == totalSections - 3 && indexPath.row == 1 && !switchClicked && rout.numCycles < 2 {
            return 0
        }
        if indexPath.section == totalSections - 2 && !switchClicked {
            return 0
        }
        if indexPath.section == 2 {
            return 84.5
        }
        return tableView.rowHeight
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if indexPath.section == 2 && editingStyle == .delete && rout.intervals.count > 1 {
        print("Deleted")
        print(indexPath.section - indexSection)
            print(indexPath.section)
            print(indexSection)
            rout.intervals.remove(at: indexPath.row)
            let indexSet = IndexSet(integer: indexPath.section)
            // totalSections -= 1
            print(indexSet)
            // self.tableView.deleteSections(indexSet, with: .none)
            self.tableView.deleteRows(at: [indexPath], with: .none)

      }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if indexPath.section == 2 && rout.intervals.count > 1 {
        return UITableViewCell.EditingStyle.delete
        } else {

            return .none
        }
    }

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.rout.intervals[sourceIndexPath.row]
        rout.intervals.remove(at: sourceIndexPath.row)
        rout.intervals.insert(movedObject, at: destinationIndexPath.row)

    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 2 && rout.intervals.count > 1 {
            return true
        }
        return false
    }

     func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return IndexPath(row: row, section: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if (section == totalSections - 2) && !switchClicked {
            return 0.1
        }
        return UITableView.automaticDimension
    }



    

func numberOfSections(in tableView: UITableView) -> Int {
    print("totalSections", totalSections)
    return totalSections
}


}
