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
import CoreStore
import MKColorPicker
import PKHUD

protocol ModalDelegate {
    func changeValue(value: [IntervalIntensity], highlowInt: HighLowInterval)
}

protocol SecondVCDelegate {
    func didFinishSecondVC(controller: RoutineEditorController)
}

class RoutineEditorController: UIViewController, ModalDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addInterval: UIImageView!
    var people: [NSManagedObject] = []
    var colorPicker = ColorPickerViewController()
    var dataStack = DataStack(
        xcodeModelName: "Timer",
        migrationChain: ["Timer", "Timer 3"]
    )
    var testValue: String = ""
    var intervalChanged = intervalOptions(rawValue: 0)
    var incomingData:Routine!
    var currObjId : CDRoutine!
    var passClubDelegate: ModalDelegate3?
    var presetInterval: HighLowInterval = globals().returnDefaultRout().intervals[0]
    var rout: Routine = globals().returnDefaultRout()
    var closeButton : UIBarButtonItem!

    var totalSections = 7
    var indexSection = 3
    var switchClicked = false
    var colorReceived : UIColor?
    var intervalGettingChanged : IntervalIntensity?
    var intervalChangeIndex = 0
    var origName = ""
    var origRout : Routine!


    override func viewDidLoad() {
        
        self.origName = rout.name
        let colors = globals().setAllColorsArray()
        let count = colors.count - 1
        let number = Int.random(in: 0 ... count)
        if rout.name == "" {
            rout.routineColor = colors[number]
        }
        //rout.routineColor = colors[4]
        //rout.name = "Leg Stretch"
        super.viewDidLoad()


        do {
            try dataStack.addStorageAndWait(SQLiteStore())
            
        }
        catch { // ...
            print("error")
        }
        if rout.numCycles > 1 {
            switchClicked = true
        }
        totalSections = totalSections + 1
        if rout.intervals.count > 1 {
            totalSections += 1
        }
        globals().setTableViewBackground(tableView: self.tableView)
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
        self.tableView.isEditing = true
        self.tableView.allowsSelectionDuringEditing = true
        self.setNavigationBar()
        self.tableView.register(UINib(nibName: "selectColorCell", bundle: nil), forCellReuseIdentifier: "selectColorCell")
        origRout = self.rout
    }
    
    func setNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        closeButton = UIBarButtonItem(title: "Discard", style: .plain, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        let editButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButton))
        self.navigationItem.setRightBarButtonItems([editButton], animated: true)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    @objc func closeButtonClick(){
        //print("closeButtonClick")
        if origRout == rout {
            //print("here 30")
            self.navigationController?.popViewController(animated: true)
        }
        else {
            //print("here 31")
            presentActionSheet(sender: closeButton)
        }

    }
    
    func save3() {
        //print("here5")
        let dataStack = self.dataStack
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
                    HUD.flash(.success, delay: 1.0)
                    
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error): print(error)
                }
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
        if self.rout.routineID == nil {
            person.cdUUID = UUID().uuidString
        }
        else {
            person.cdUUID = self.rout.routineID
        }
        person.cdName = self.rout.name
        person.cdNumCycles = Int32(self.rout.numCycles)
        person.cdRoutineColor = self.rout.routineColor.hexString(.d6)
        person.cdRoutineIndex = Int32(self.rout.routineIndex)
        person.cdIntervalVoiceEnable = self.rout.enableIntervalVoice
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
                
                let sr = SaveRoutine()
                sr.dataStack = dataStack
                sr.rout = self.rout
                if person == nil {
                    sr.save3()
                }
                else {
                    transaction.delete(person)
                    sr.save3()
                }
        },
            completion: { (result) in
                switch result {
                case .success:
                    HUD.flash(.success, delay: 1.0)

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.passClubDelegate?.getRoutine(value: self.rout)
                        self.navigationController?.popViewController(animated: true)
                    }
                case .failure(let error):
                    print(error)
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
    
    @objc func saveButton(){
        //print("closeButtonClick")
        if rout.name == "" {
            let alert = UIAlertController(title: "Timer Name is empty", message: "Please enter a Routine Name", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        tableView.reloadData()

        self.saveData2()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func presentActionSheet(sender: UIBarButtonItem, ifSaving: Bool = false) {
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
        if let popoverController = actionSheetControllerIOS8.popoverPresentationController {
          popoverController.barButtonItem = sender
        }
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func changeValue(value: [IntervalIntensity], highlowInt: HighLowInterval) {
        if intervalChanged == intervalOptions.warmUp {
            rout.warmup = value[0]
        }
        if intervalChanged == intervalOptions.cooldown {
            rout.coolDown = value[0]
        }
        if intervalChanged == intervalOptions.rest {
            rout.restTime = value[0]
        }
        if intervalChanged == intervalOptions.intervalRest {
            rout.intervalRestTime = value[0]
        }
        if intervalChanged == intervalOptions.highLowInt {
            rout.intervals[intervalChangeIndex] = highlowInt
            if rout.intervals[intervalChangeIndex].firstIntervalHigh {
                rout.intervals[intervalChangeIndex].highInterval = value[0]
                rout.intervals[intervalChangeIndex].lowInterval = value[1]
            }
            else{
                rout.intervals[intervalChangeIndex].highInterval = value[1]
                rout.intervals[intervalChangeIndex].lowInterval = value[0]
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
        tableView.reloadData()
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
    
    @objc private func switchValueDidChange(_ sender: UISwitch) {
        
        switchClicked.toggle()
        if !switchClicked {
            rout.numCycles = 1
        }
        else {
            rout.numCycles = 2
        }
        globals().animationTableChange(tableView: self.tableView)
        
    }
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        return true
    }
    
    
    @objc func textFieldDidChange(textField: UITextField){
        rout.name = textField.text!
    }

    @objc func textFieldDidBegin(_ textField: UITextField) {
        DispatchQueue.main.async{
           let newPosition = textField.endOfDocument
           textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
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
        else if section == 2 {
            return 1
        }
        if section == indexSection {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell1") as! inputTextCell
        
        if cell.returnInputString() != "" {
            rout.name = cell.returnInputString()
        }
        if (indexPath.section == 0) && indexPath.row == 0{
            cell.inputString.text = rout.name
            cell.inputString.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            cell.inputString.addTarget(self, action: #selector(textFieldDidBegin(_:)), for: .editingDidBegin)
            cell.selectionStyle = .none
            return cell
        }
        let cell2a = tableView.dequeueReusableCell(withIdentifier: "selectIntervalCell") as! selectIntervalCell
        if indexPath.section == (2) && indexPath.row == 0 {
            cell2a.intervalName.text = "Warm Up"
            cell2a.setImageColor(color: rout.warmup.intervalColor)
            cell2a.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.warmup.duration)))
            cell2a.theImage.isHidden = false
            cell2a.labelLeftContrain.constant = 10
            return cell2a
        }
        let cell27 = tableView.dequeueReusableCell(withIdentifier: "selectColorCell") as! selectColorCell
        if indexPath.section == (1) && indexPath.row == 0 {
            cell27.colorLabel.text = "Timer Color"
            cell27.colorCircle.image = cell27.colorCircle.image?.withRenderingMode(.alwaysTemplate)
            cell27.colorCircle.tintColor = rout.routineColor
            return cell27
        }
        let cell24 = tableView.dequeueReusableCell(withIdentifier: "mainCell") as! mainCell
        if indexPath.section == (indexSection)  {
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

        let cell2z = tableView.dequeueReusableCell(withIdentifier: "selectIntervalCell") as! selectIntervalCell
        if indexPath.section == totalSections - 5 && rout.intervals.count > 1 {
            cell2z.intervalName.text = "Interval Rest Time"
            cell2z.setImageColor(color: rout.intervalRestTime.intervalColor)
            cell2z.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.intervalRestTime.duration)))
            cell2z.theImage.isHidden = false
            cell2z.labelLeftContrain.constant = 10
            return cell2z
        }
        
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "addNewCycle") as! addNewCycleCell
        if indexPath.section == totalSections - 4 {
            if #available(iOS 13.0, *) {
                cell3.addInterval.image = UIImage(systemName: "plus.circle.fill")
            } else {
                cell3.addInterval.image = cell3.addInterval.image?.withRenderingMode(.alwaysTemplate)


            }

            return cell3
        }
        let cell33 = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! switchCell
        if indexPath.section == totalSections - 3 && indexPath.row == 0 {
            cell33.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            let theSwitch = UISwitch()
            cell33.switchSwitch = theSwitch
            cell33.selectionStyle = .none
            cell33.accessoryView = theSwitch
            cell33.switchLabel.text = "Repeat"
            theSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
            theSwitch.isOn = switchClicked
            if rout.numCycles > 1 {
                theSwitch.isOn = true
            }
            return cell33
        }
        let cell2b = tableView.dequeueReusableCell(withIdentifier: "selectIntervalCell") as! selectIntervalCell
        if indexPath.section == totalSections - 3 && indexPath.row == 1 {
            cell2b.theImage.isHidden = true
            cell2b.totalTime.text = "2"
            cell2b.setIntervalName(intervalName: "Number of Cycles")
            if rout.numCycles > 1 {
                cell2b.totalTime.text = String(rout.numCycles)
            }
            cell2b.labelLeftContrain.constant = -20
            return cell2b
            
        }
        let cell2c = tableView.dequeueReusableCell(withIdentifier: "selectIntervalCell") as! selectIntervalCell
        if indexPath.section == totalSections - 2 {
            cell2c.setImageColor(color: rout.restTime.intervalColor)
            cell2c.setIntervalName(intervalName: "Cycle Rest Time")
            cell2c.totalTime.text = String(rout.numCycles)
            cell2c.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.restTime.duration)))
            return cell2c
        }
        let cell2d = tableView.dequeueReusableCell(withIdentifier: "selectIntervalCell") as! selectIntervalCell
        if indexPath.section == totalSections - 1 {
            cell2d.setImageColor(color: rout.coolDown.intervalColor)
            cell2d.totalTime.text = globals().timeString(time: TimeInterval(Int(rout.coolDown.duration)))
            cell2d.setIntervalName(intervalName: "Cool Down")
            return cell2d
        }
//        let cell34 = tableView.dequeueReusableCell(withIdentifier: "switchCell") as! switchCell
//        if indexPath.section == totalSections - 1 {
//            cell33.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
//            let theSwitch = UISwitch()
//            cell33.switchSwitch = theSwitch
//            cell33.selectionStyle = .none
//            cell33.accessoryView = theSwitch
//            cell33.switchLabel.text = "Interval Voice Enabled"
//            theSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
//            theSwitch.isOn = switchClicked
//
//            return cell33
//        }
        return cell2d
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == totalSections - 5 && self.rout.intervals.count > 1 {
            let storyboard = UIStoryboard(name: "IntervalEditorVC", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "IntervalEditorVC") as? IntervalEditorVC
            myVC!.modalPresentationStyle = .fullScreen
            let navController = UINavigationController(rootViewController: myVC!)
            myVC!.title = "Interval Rest Time"
            myVC!.interval = rout.intervalRestTime
            navController.presentationController?.delegate = myVC
            intervalChanged = intervalOptions.intervalRest
            myVC?.delegate = self
            self.navigationController?.present(navController, animated: true, completion: nil)
        }
        if indexPath.section == 0 {
            
        }
        if indexPath.section == 1 {
            self.colorPicker = globals().createColorPopover(tableView: self.tableView, indexPath: indexPath)
            
            self.present(colorPicker, animated: true, completion: nil)
            colorPicker.selectedColor = { color in
                self.rout.routineColor = color
                //print(color)
                //print(self.rout.routineColor)
                self.tableView.reloadData()
            }
        }
        
        if indexPath.section == totalSections - 4 {
//            if SubscribeAlert().runAlert(theView: self, theString: "add an interval") {
//                return
//            }


            presetInterval.intervalName = "Interval #\(rout.intervals.count + 1)"

            rout.intervals.append(presetInterval)

            if #available(iOS 11.0, *) {
                tableView.performBatchUpdates({
                    tableView.insertRows(at: [IndexPath(row: rout.intervals.count - 1, section: indexSection)], with: .none)
                    if rout.intervals.count > 1 && totalSections == 8 {
                        //print("add intervals")
                        totalSections += 1
                        let indexSet = IndexSet(integer: totalSections - 5)
                        tableView.insertSections(indexSet, with: .none)
                        //self.tableView.reloadData()
                    }

                }) { (update) in
                    print("Update SUccess1")
                }
            } else {
                tableView.insertRows(at: [IndexPath(row: rout.intervals.count - 1, section: indexSection)], with: .none)
                if rout.intervals.count > 1 && totalSections == 8 {
                    //print("add intervals")
                    totalSections += 1
                    let indexSet = IndexSet(integer: totalSections - 5)
                    tableView.insertSections(indexSet, with: .none)
                    self.tableView.reloadData()
                }
            }
        }
        
        if indexPath.section == indexSection - 1 {
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
            let hoursLabel = UILabel()
            hoursLabel.text = "r"
            //mcPicker.picker.setPickerLabels(labels: [0: hoursLabel], containedView: mcPicker)
            globals().setMcPickerDetails(mcPicker: mcPicker)
            if rout.numCycles == 2 {
            }
            else if rout.numCycles == 3 {
                mcPicker.pickerSelectRowsForComponents = [
                    0: [rout.numCycles - 2: true],
                    
                ]
            }
            else if rout.numCycles > 3 {
                mcPicker.pickerSelectRowsForComponents = [
                    0: [rout.numCycles - 2: true],
                ]
            }
            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let hours = selections[0] {
                    self?.rout.numCycles = Int(hours)!
                    self?.tableView.reloadData()
                }
                }, cancelHandler: {
                    print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                //let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
                
            })
        }
        
        if indexPath.section == indexSection {
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
    
//    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
//        return 1
//    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == totalSections - 3 && indexPath.row == 1 && !switchClicked && rout.numCycles < 2 {
            return 0
        }
        if indexPath.section == totalSections - 2 && !switchClicked {
            return 0
        }
        if indexPath.section == indexSection {
            return 84.5
        }

        return tableView.rowHeight
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if indexPath.section == indexSection && editingStyle == .delete && rout.intervals.count > 1 {
            
            //self.tableView.deleteRows(at: [indexPath], with: .none)
            let alert = UIAlertController(title: "Are you sure you want to delete this interval? This can't be undone", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    self.rout.intervals.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    if self.rout.intervals.count == 1 && self.totalSections != 7 {
                        self.totalSections -= 1
                        self.tableView.reloadData()
                    }
                @unknown default:
                    print("error")
                }}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                @unknown default:
                    print("error")
                }}))
            self.present(alert, animated: true, completion: nil)
            
        }
    }
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if indexPath.section == indexSection && rout.intervals.count > 1 {
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
        if indexPath.section == indexSection && rout.intervals.count > 1 {
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
        return totalSections
    }


    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 3 {
            return true
        }
          return false
    }


    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
    //        print("HERE")
            return action == #selector(copy(_:))
    }

    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            var interval = rout.intervals[indexPath.row]
            interval.highLowId = UUID().uuidString
            //interval.intervalName = interval.intervalName + " Copy"
            let colors = globals().setAllColorsArray()
            let count = colors.count - 1
            let number = Int.random(in: 0 ... count)

            interval.HighLowIntervalColor = colors[number]
            rout.intervals.insert(interval, at: indexPath.row + 1)
            self.tableView.reloadData()

        }
    }
    
}

extension UIColor {
    enum HexFormat {
        case RGB
        case ARGB
        case RGBA
        case RRGGBB
        case AARRGGBB
        case RRGGBBAA
    }
    
    enum HexDigits {
        case d3, d4, d6, d8
    }
    
    func hexString(_ format: HexFormat = .RRGGBBAA) -> String {
        let maxi = [.RGB, .ARGB, .RGBA].contains(format) ? 16 : 256
        
        func toI(_ f: CGFloat) -> Int {
            return min(maxi - 1, Int(CGFloat(maxi) * f))
        }
        
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let ri = toI(r)
        let gi = toI(g)
        let bi = toI(b)
        let ai = toI(a)
        switch format {
        case .RGB:       return String(format: "#%X%X%X", ri, gi, bi)
        case .ARGB:      return String(format: "#%X%X%X%X", ai, ri, gi, bi)
        case .RGBA:      return String(format: "#%X%X%X%X", ri, gi, bi, ai)
        case .RRGGBB:    return String(format: "#%02X%02X%02X", ri, gi, bi)
        case .AARRGGBB:  return String(format: "#%02X%02X%02X%02X", ai, ri, gi, bi)
        case .RRGGBBAA:  return String(format: "#%02X%02X%02X%02X", ri, gi, bi, ai)
        }
    }
    
    func hexString(_ digits: HexDigits) -> String {
        switch digits {
        case .d3: return hexString(.RGB)
        case .d4: return hexString(.RGBA)
        case .d6: return hexString(.RRGGBB)
        case .d8: return hexString(.RRGGBBAA)
        }
    }
}
