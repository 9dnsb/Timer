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
import PKHUD
import ColorCompatibility


class IntervalEditorVC: UIViewController {

    var player : AVAudioPlayer?
    var colorPicker = ColorPickerViewController()
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
    var origArray : [IntervalIntensity]!
    var timerClass: Timer!
    var closeButton : UIBarButtonItem!

    override func viewDidLoad() {
        globals().keyboardClick(view: self.view)
        globals().setTableViewBackground(tableView: self.tableView)
        super.viewDidLoad()
        if interval == nil {
            sections = 4
            isHighLow = true
            if intervalHighLow!.firstIntervalHigh {
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
        if #available(iOS 13.0, *) {
            isModalInPresentation = true
        } else {
            // Fallback on earlier versions
        }
//        let screenSize: CGRect = UIScreen.main.bounds
//        butt = UIButton(frame: CGRect(x: screenSize.width - 30, y: UIScreen.main.bounds.height - 189, width: 30, height: 30))
//        // butt.backgroundColor = .systemTeal
//        butt.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
//        //butt.setImage(UIImage(systemName: "play.circle"), for: .normal)
//        butt.setImage(UIImage(named: "play.circle.fill"), for: .normal)
//
//        butt.tintColor = .systemGray

        for value in sounds.allCases {
            picker_values.append(value.rawValue)
        }
        tableView.register(UINib(nibName: "basicLabelCell", bundle: nil), forCellReuseIdentifier: "basicLabelCell")
        tableView.register(UINib(nibName: "selectColorCell", bundle: nil), forCellReuseIdentifier: "selectColorCell")
        tableView.register(UINib(nibName: "basicRightLabelCell", bundle: nil), forCellReuseIdentifier: "basicRightLabelCell")
        tableView.register(UINib(nibName: "segmentCell", bundle: nil), forCellReuseIdentifier: "segmentCell")
        closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        let saveButtonB = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveButton))
        self.navigationItem.setRightBarButtonItems([saveButtonB], animated: true)
        origArray = intervalArray
    }

    func changeValue(value: sounds) {
        interval?.sound = value
        tableView.reloadData()
    }

    @objc func closeButtonClick(){
        print("closeButtonClick")
        if origArray == intervalArray {
            self.dismiss(animated: true, completion: nil)
            //print("here 30")
        }
        else {
            //print("here 31")
            presentActionSheet(sender: closeButton)
        }
    }

    @objc func saveButton(){
        //presentActionSheet(ifSaving: true)
        if intervalArray.count > 1 {
            if intervalArray[0].duration == 0 && intervalArray[1].duration == 0 {
                let alert = UIAlertController(title: "Error", message: "High or Low Interval must have duration greater than 0", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                return
            }
        }


        self.disappear()

    }

    @objc func buttonAction(sender: UIButton!) {
        //self.playSound()
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
        if let popoverController = actionSheetControllerIOS8.popoverPresentationController {
          popoverController.barButtonItem = sender
        }

        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }

    func disappear() {
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
        HUD.flash(.success, delay: 1.0)
        //print("Done")
        //self.navigationController?.popViewController(animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // Change `2.0` to the desired number of seconds. // Code you want to be delayed }

            self.dismiss(animated: true, completion: nil)
        }
    }

    func sendDataDelegate() {
        if let delegate = self.delegate {
            if intervalHighLow == nil {
                intervalHighLow = HighLowInterval(firstIntervalHigh: true, numSets: 0, intervalName: "", highInterval: IntervalIntensity(duration: 0, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 0, intervalColor: .systemRed, sound: sounds.none), HighLowIntervalColor: .systemRed)
            }
            delegate.changeValue(value: intervalArray, highlowInt: intervalHighLow!)
        }
    }

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

    @objc func textFieldDidChange(_ textField: UITextField) {
        intervalHighLow?.intervalName = textField.text ?? ""

    }

    @objc func controlValueChanged(_ sender: BetterSegmentedControl) {
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
        cell.labelLeft!.text = "Interval Name"
        cell.textInput.text = intervalHighLow?.intervalName
        cell.textInput.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)

        if indexPath.section == 1 && isHighLow && indexPath.row == 0 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "basicRightLabelCell") as! basicRightLabelCell
            cell2.leftLabel.text = "Number of Interval Sets"
            cell2.rightLabel.text = String(intervalHighLow!.numSets)
            return cell2
        }

        if indexPath.section == 1 && isHighLow && indexPath.row == 1 {
            let cell2 = tableView.dequeueReusableCell(withIdentifier: "segmentCell") as! segmentController
            cell2.leftLabel.text = "First Interval"
            cell2.selectionStyle = .none
            // cell2.segment.backgroundColor = .secondarySystemBackground
            cell2.segment.segments = LabelSegment.segments(withTitles: ["Low", "High"])

            cell2.segment.alwaysAnnouncesValue = true
            cell2.segment.announcesValueImmediately = false
            if intervalHighLow!.firstIntervalHigh {
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
            cell2.colorLabel.text = "Interval Color"
            if (!isHighLow) {
                cell2.colorCircle.image = cell2.colorCircle.image?.withRenderingMode(.alwaysTemplate)
                cell2.colorCircle.tintColor = intervalArray[indexPath.section].intervalColor
            }
            else {
                cell2.colorCircle.image = cell2.colorCircle.image?.withRenderingMode(.alwaysTemplate)
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
            let data = [Array(01...999)]
            var stringArray = Array<Array<String>>()
            for array in data {
                var subArray = Array<String>()
                for item in array {
                    subArray.append(String(item))
                }
                stringArray.append(subArray)
            }
            let mcPicker = McPicker(data: stringArray)
            globals().setMcPickerDetails(mcPicker: mcPicker)
            print(intervalHighLow!.numSets)
            if intervalHighLow!.numSets == 1 {

            }
            else if intervalHighLow!.numSets == 2 {
                mcPicker.pickerSelectRowsForComponents = [
                    0: [intervalHighLow!.numSets - 1: true],

                ]
            }
            else if intervalHighLow!.numSets > 2 {
                mcPicker.pickerSelectRowsForComponents = [
                    0: [intervalHighLow!.numSets - 1: true],

                ]
            }
            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let hours = selections[0] {
                    self?.intervalHighLow!.numSets = Int(hours)!
                    self?.tableView.reloadData()
                }
                }, cancelHandler: {
                    print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                _ = selections[componentThatChanged] ?? "Failed to get new selection!"
                //print("Component \(componentThatChanged) changed value to \(newSelection)")
            })
        }

        if self.detectHighLowSection(indexP: indexPath) && indexPath.row == 2 {
            self.colorPicker = globals().createColorPopover(tableView: self.tableView, indexPath: indexPath)
            self.present(colorPicker, animated: true, completion: nil)
            colorPicker.selectedColor = { color in
                self.intervalArray[indexPathSection].intervalColor = color
                tableView.reloadData()
            }
        }
        if self.detectHighLowSection(indexP: indexPath) && indexPath.row == 0 {
            let data = [Array(00...9), Array(00...59), Array(00...59)]
            var stringArray = Array<Array<String>>()
            for array in data {
                var subArray = Array<String>()
                for item in array {
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
            globals().setMcPickerDetails(mcPicker: mcPicker)
            let (h,m,s) = globals().secondsToHoursMinutesSeconds(seconds: self.intervalArray[indexPathSection].duration)
            mcPicker.pickerSelectRowsForComponents = [
                0: [h: true],
                1: [m: true],
                2: [s: true],
            ]
            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let second = selections[2], let minutes = selections[1], let hours = selections[0] {
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
            let data: [[String]] = [picker_values]
            let mcPicker = McPicker(data: data)
            globals().setMcPickerDetails(mcPicker: mcPicker)
            mcPicker.pickerSelectRowsForComponents = [
                0: [self.intervalArray[indexPathSection].sound.index!: true],

            ]
            mcPicker.show(doneHandler: { [weak self] (selections: [Int : String]) -> Void in
                if let prefix = selections[0] {
                    self?.intervalArray[indexPathSection].sound = sounds(rawValue: prefix)!
                    self?.tableView.reloadData()
                }
                }, cancelHandler: {
                    print("Canceled Styled Picker")
            }, selectionChangedHandler: { (selections: [Int:String], componentThatChanged: Int) -> Void  in
                let newSelection = selections[componentThatChanged] ?? "Failed to get new selection!"
                self.player?.stop()
                if newSelection != "None" {
                    //self.playSound(sound: newSelection)
                    self.player = globals().playSound(sound: newSelection)
                }
            })
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
        self.closeButtonClick()
    }
}
