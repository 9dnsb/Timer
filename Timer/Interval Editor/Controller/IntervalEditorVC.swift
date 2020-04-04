//
//  IntervalEditorVC.swift
//  Timer
//
//  Created by David Blatt on 4/1/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import MKColorPicker
import AVFoundation
import McPicker
import BetterSegmentedControl

protocol ModalDelegate2 {
func changeValue(value: sounds)
}

class IntervalEditorVC: UIViewController, ModalDelegate2 {

    

    var player : AVAudioPlayer?
    let colorPicker = ColorPickerViewController()
    var butt : UIButton!
    var picker_values = [String]()
    var myPicker: soundPicker! = soundPicker()
    @IBOutlet weak var tableView: UITableView!
    var theColor : UIColor = .systemRed
    var delegate: ModalDelegate?
    var testValue: String = ""
    var interval : IntervalIntensity?
    var gradePicker: UIPickerView!
    var picker = UIView()
    var intervalHighLow : HighLowInterval?
    var intervalArray = [IntervalIntensity]()
    var isHighLow : Bool = false
    var sections = 1

    override func viewDidLoad() {
        globals().keyboardClick(view: self.view)
        self.tableView.backgroundColor = .systemGroupedBackground
        super.viewDidLoad()
        if interval == nil {
            sections = 4
            //print("hereInterval3")
            isHighLow = true
            if intervalHighLow!.firstIntervalHigh {
                //print("hereInterval2")
                interval = intervalHighLow?.highInterval
                intervalArray.append(intervalHighLow!.highInterval)
                intervalArray.append(intervalHighLow!.lowInterval)
            }
            else{
                interval = intervalHighLow?.lowInterval
                intervalArray.append(intervalHighLow!.lowInterval)
                intervalArray.append(intervalHighLow!.highInterval)
            }
        }
        else {
            intervalArray.append(interval!)
        }
        isModalInPresentation = true
        let screenSize: CGRect = UIScreen.main.bounds
        butt = UIButton(frame: CGRect(x: screenSize.width - 30, y: UIScreen.main.bounds.height - 189, width: 30, height: 30))
        // butt.backgroundColor = .systemTeal
        butt.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        butt.setImage(UIImage(systemName: "play.circle"), for: .normal)
        butt.tintColor = .systemGray

        for value in sounds.allCases {
            picker_values.append(value.rawValue)
        }
        tableView.register(UINib(nibName: "basicLabelCell", bundle: nil), forCellReuseIdentifier: "basicLabelCell")
        tableView.register(UINib(nibName: "selectColorCell", bundle: nil), forCellReuseIdentifier: "selectColorCell")
        tableView.register(UINib(nibName: "basicRightLabelCell", bundle: nil), forCellReuseIdentifier: "basicRightLabelCell")
        tableView.register(UINib(nibName: "segmentCell", bundle: nil), forCellReuseIdentifier: "segmentCell")
        // Do any additional setup after loading the view.
        // self.myPicker = UIPickerView(frame: CGRectMake(0, 40, 0, 0))
        
//        let screenSize: CGRect = UIScreen.main.bounds
//        
//        myPicker = soundPicker(frame: CGRect(x: 0, y: UIScreen.main.bounds.height - 300, width: screenSize.width, height: 250))
//
////        butt = UIButton(frame: CGRect(x: screenSize.width - 30, y: UIScreen.main.bounds.height - 189, width: 30, height: 30))
////        // butt.backgroundColor = .systemTeal
////        butt.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
////        butt.setImage(UIImage(systemName: "play.circle"), for: .normal)
////        butt.tintColor = .systemGray
//
//        myPicker.backgroundColor = .secondarySystemGroupedBackground
//        self.myPicker.delegate = self.myPicker.self
//        self.myPicker.dataSource = self.myPicker.self

        
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        let saveButtonB = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButton))
        self.navigationItem.setRightBarButtonItems([saveButtonB], animated: true)

    }

    func changeValue(value: sounds) {
        print("here11")
        interval?.sound = value
        tableView.reloadData()
    }



    @objc func closeButtonClick(){
        print("closeButtonClick")
        presentActionSheet()
        //self.disappear()

    }

    @objc func saveButton(){
        print("saveButton")
        //presentActionSheet(ifSaving: true)
        self.disappear()


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
                self.dismiss(animated: true, completion: nil)

        }
        actionSheetControllerIOS8.addAction(saveActionButton)
        if ifSaving {
            let deleteActionButton = UIAlertAction(title: "Save Changes", style: .default)
                { _ in
                    print("Save Changes")
                    self.disappear()
            }
            actionSheetControllerIOS8.addAction(deleteActionButton)
        }


        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }



    func disappear() {
        print("being dismissed")
        if isHighLow {
            if intervalHighLow!.firstIntervalHigh {
                intervalHighLow?.highInterval = intervalArray[0]
                intervalHighLow?.lowInterval = intervalArray[1]
            }
            else{
                intervalHighLow?.highInterval = intervalArray[1]
                intervalHighLow?.lowInterval = intervalArray[0]
            }
        }
        self.sendDataDelegate()
        self.dismiss(animated: true, completion: nil)

    }

    func sendDataDelegate() {
        if let delegate = self.delegate {
            if intervalHighLow == nil {
                intervalHighLow = HighLowInterval(firstIntervalHigh: true, numSets: 0, intervalName: "", highInterval: IntervalIntensity(duration: 0, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 0, intervalColor: .systemRed, sound: sounds.none), HighLowIntervalColor: .systemRed)
            }
            delegate.changeValue(value: intervalArray, highlowInt: intervalHighLow!)
        }
    }

//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1
//    }
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return picker_values.count
//    }
//
//    //MARK: Delegates
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return picker_values[row].rawValue
//    }
//
//    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        // player?.stop()
//        //Your Function
//        if row == 0 {
//            butt.isHidden = true
//
//        }
//        else {
//            butt.isHidden = false
//        }
//        print(row)
//        print(component)
//        print(picker_values[row])
//        interval?.sound = picker_values[row]
//        tableView.reloadData()
//    }

    

    func playSound(sound: String) {
        let session = AVAudioSession.sharedInstance()

        try? session.setCategory(.playback, options: .mixWithOthers)
        try? session.setActive(true, options: [])
        player?.stop()
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: sound, ofType: "mp3")!)
        try! player = AVAudioPlayer(contentsOf: alertSound)
        player?.prepareToPlay()
        player?.play()
    }

    func detectHighLowSection(indexP: IndexPath) -> Bool {
        return indexP.section == sections - 1 || indexP.section == sections - 2
    }

    func ifNotHighLow() {

    }

    @objc func textFieldDidChange(_ textField: UITextField) {
        intervalHighLow?.intervalName = textField.text ?? ""

    }

    @objc func controlValueChanged(_ sender: BetterSegmentedControl) {
        print("here50")
        if (sender.index) == 0 && intervalHighLow!.firstIntervalHigh {
            intervalHighLow!.firstIntervalHigh = false
            intervalArray.swapAt(0, 1)
            globals().animationTableChange(tableView: self.tableView)
        }
        if (sender.index) == 1 && !intervalHighLow!.firstIntervalHigh {
            intervalHighLow!.firstIntervalHigh = true
            intervalArray.swapAt(0, 1)
            globals().animationTableChange(tableView: self.tableView)
        }


    }
    


}



extension IntervalEditorVC: UITableViewDataSource, UITableViewDelegate {



func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if isHighLow {
        if section == 0 {
            return 1
        }
        if section == 1 {
            return 2
        }
    }

    return 3
}
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "basicLabelCell") as! basicLabelCell
    cell.labelLeft!.text = "Routine Name"
    cell.textInput.text = intervalHighLow?.intervalName
    cell.textInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

    if indexPath.section == 1 && isHighLow && indexPath.row == 0 {
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "basicRightLabelCell") as! basicRightLabelCell
        cell2.leftLabel.text = "Number of Sets"
        cell2.rightLabel.text = String(intervalHighLow!.numSets)
        return cell2
    }

    if indexPath.section == 1 && isHighLow && indexPath.row == 1 {
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "segmentCell") as! segmentController
        cell2.leftLabel.text = "First Interval"
        // cell2.segment.backgroundColor = .secondarySystemBackground
        cell2.segment.segments = LabelSegment.segments(withTitles: ["Low", "High"])

        cell2.segment.alwaysAnnouncesValue = true
        cell2.segment.announcesValueImmediately = false
        if intervalHighLow!.firstIntervalHigh {
            print("here51")
            cell2.segment.setIndex(1)
        }
        cell2.segment.addTarget(self, action: #selector(controlValueChanged(_:)), for: .valueChanged)
        return cell2
    }


    if detectHighLowSection(indexP: indexPath) && indexPath.row == 0 {
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "basicRightLabelCell") as! basicRightLabelCell
        cell2.leftLabel.text = "Duration"
        if (!isHighLow) {
            cell2.rightLabel.text =  globals().timeString(time: TimeInterval(Int(intervalArray[indexPath.section].duration)))
        }
        else {
            cell2.rightLabel.text =  globals().timeString(time: TimeInterval(Int(intervalArray[indexPath.section - 2].duration)))
        }
        return cell2
    }
    if detectHighLowSection(indexP: indexPath) && indexPath.row == 1 {
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "basicRightLabelCell") as! basicRightLabelCell
        cell2.leftLabel.text = "Sound"
        if (!isHighLow) {
            cell2.rightLabel.text = String(intervalArray[indexPath.section].sound.rawValue)
        }
        else {
            cell2.rightLabel.text = String(intervalArray[indexPath.section - 2].sound.rawValue)
        }


        return cell2
    }
    if detectHighLowSection(indexP: indexPath) && indexPath.row == 2 {
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "selectColorCell") as! selectColorCell
        if (!isHighLow) {
            cell2.colorCircle.tintColor = intervalArray[indexPath.section].intervalColor
        }
        else {
            cell2.colorCircle.tintColor = intervalArray[indexPath.section - 2].intervalColor
        }
        return cell2
    }
    return cell
}

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var indexPathSection = 0

        if isHighLow {
            indexPathSection = indexPath.section - 2
        }
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.section == 1 && isHighLow && indexPath.row == 0 {
            let data = [Array(00...999)]

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
                0: [intervalHighLow!.numSets: true],

            ]


            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let hours = selections[0] {
                    self?.intervalHighLow!.numSets = Int(hours)!
                    self?.tableView.reloadData()
                }
            }, cancelHandler: {
                print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
                print("Component \(componentThatChanged) changed value to \(newSelection)")

            })
        }

        if self.detectHighLowSection(indexP: indexPath) && indexPath.row == 2 {
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

            self.present(colorPicker, animated: true, completion: nil)
            colorPicker.selectedColor = { color in
                self.intervalArray[indexPathSection].intervalColor = color
                print(color)
                tableView.reloadData()
            }
        }

        if self.detectHighLowSection(indexP: indexPath) && indexPath.row == 0 {
            let data = [Array(00...9), Array(00...59), Array(00...59)]

            var stringArray = Array<Array<String>>()

            for array in data {
                var subArray = Array<String>()

                for item in array {
                    print("item", item)
                    if 0...9 ~= item {
                        subArray.append(String("0" + String(item)))
                    }
                    else {
                        subArray.append(String(item))
                    }

                }

                stringArray.append(subArray)
            }
            let mcPicker = McPicker(data: stringArray)


            mcPicker.backgroundColor = .secondarySystemGroupedBackground
            mcPicker.pickerBackgroundColor = .secondarySystemGroupedBackground
            let (h,m,s) = globals().secondsToHoursMinutesSeconds(seconds: self.intervalArray[indexPathSection].duration)
            mcPicker.pickerSelectRowsForComponents = [
                0: [h: true],
                1: [m: true],
                2: [s: true],
            ]


            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let second = selections[2], let minutes = selections[1], let hours = selections[0] {
                    print("selections", selections)
                    print("\(second), \(minutes), \(hours)")
                    let hours1 = Int(hours)! * 3600
                    let minutes1 = Int(minutes)! * 60
                    let second1 = Int(second)!
                    let totalDur = hours1 + minutes1 + second1
                    self?.intervalArray[indexPathSection].duration = totalDur
                    self?.tableView.reloadData()
                }
            }, cancelHandler: {
                print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
                print("Component \(componentThatChanged) changed value to \(newSelection)")

            })
        }

        if self.detectHighLowSection(indexP: indexPath) && indexPath.row == 1 {
            print("picker_values", picker_values)
            let data: [[String]] = [picker_values]
            print(data)
            let mcPicker = McPicker(data: data)

            mcPicker.backgroundColor = .secondarySystemGroupedBackground
            mcPicker.pickerBackgroundColor = .secondarySystemGroupedBackground
            mcPicker.pickerSelectRowsForComponents = [
                0: [self.intervalArray[indexPathSection].sound.index!: true],

            ]
            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let prefix = selections[0] {
                    print("selections", selections)
                    print("\(prefix)")
                    self?.intervalArray[indexPathSection].sound = sounds(rawValue: prefix)!
                    self?.tableView.reloadData()
                }
            }, cancelHandler: {
                print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
                print("Component \(componentThatChanged) changed value to \(newSelection)")
                self.player?.stop()
                if newSelection != "None" {
                    self.playSound(sound: newSelection)
                }
            })

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Change `2.0` to the desired number of seconds. // Code you want to be delayed }
                //self.view.addSubview(self.butt)
                //self.view.bringSubviewToFront(self.butt)
                //self.view.layer.zPosition = 1
            }


//            myPicker.picker_values = self.picker_values
//
//            myPicker.reloadAllComponents()
//            myPicker.intervalVC = self
//            myPicker.initializeButt()
//            picker = UIView(frame: CGRect(x: 0, y: view.frame.height - 290, width: view.frame.width, height: 260))
//
//
//
//            let btnDone = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(sayHello))
//
//            let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
//            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(sayHello))
//
//            let barAccessory = UIToolbar(frame: CGRect(x: 0, y: 0, width: (myPicker.frame.width), height: 44))
//            barAccessory.barStyle = .default
//            barAccessory.isTranslucent = false
//            barAccessory.items = [cancelButton, spaceButton, btnDone]
//            picker.addSubview(barAccessory)
//            view.addSubview(picker)
//            view.addSubview(myPicker)
//            view.addSubview(myPicker.butt)
//            if !(interval!.sound.index! == 0) {
//                myPicker.selectRow((interval?.sound.index!)!, inComponent: 0, animated: true)
//                myPicker.butt.isHidden = false
//            }
//            else {
//                myPicker.selectRow((interval?.sound.index!)!, inComponent: 0, animated: true)
//                myPicker.butt.isHidden = true
//            }


        }

    }





func numberOfSections(in tableView: UITableView) -> Int {
    return sections
}

     func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if isHighLow {
            if section == 2 && intervalHighLow!.firstIntervalHigh {
                return "High Interval"
            }
            else if section == 2 && !intervalHighLow!.firstIntervalHigh {
                return "Low Interval"
            }
            else if section == 3 && !intervalHighLow!.firstIntervalHigh {
                return "High Interval"
            }
            else if section == 3 && intervalHighLow!.firstIntervalHigh {
                return "Low Interval"
            }
        }
        return ""
    }


}

extension IntervalEditorVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {


        print("slide to dismiss stopped")
        self.presentActionSheet()
        //self.dismiss(animated: true, completion: nil)
    }
}
