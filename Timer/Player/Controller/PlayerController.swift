//
//  PlayerController.swift
//  Timer
//
//  Created by David Blatt on 3/21/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SRCountdownTimer
import AVFoundation

public  typealias PXColor = UIColor
class PlayerController: UIViewController {
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var timer: UILabel!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var forwardIntervalButton: UIButton!
    @IBOutlet weak var backIntervalButton: UIButton!
    @IBOutlet weak var intervalNumberLabel: UILabel!
    @IBOutlet weak var intervalNameLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!

    @IBOutlet weak var countdownTimer: SRCountdownTimer!
    var rout: Routine = Routine(name: "", type: "", warmup: 0, intervals: [], numCycles: 0, restTime: 0, coolDown: 0, routineColor: .systemRed, totalTime: 0)
    var timerClass = Timer()
    var elapsedTimer = Timer()
    var remainingTimer = Timer()
    var model = playerModel()
    var startButtonModel = resumeButton()
    var currInterval = currentInterval()
    // var speechSynthesizer = AVSpeechSynthesizer()
    // var speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "")

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
//        speechUtterance = AVSpeechUtterance(string: "This is a test. This is only a test. If this was an actual emergency, then this wouldn’t have been a test.")
//        //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
//        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.5
//        // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//        // Line 5. Pass in the urrerance to the synthesizer to actually speak.
//        speechUtterance = AVSpeechUtterance(string: "")
//        speechSynthesizer.speak(speechUtterance)
        model.totalTime = rout.totalTime
        super.viewDidLoad()
        self.setNavigationBar()
        // self.setBackground()

        self.setRemainingTimer()
        // print(rout)
        self.setInitialTimer()


    }

    func setRemainingTimer() {
        timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
        timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        countdownTimer.labelTextColor = .white
        countdownTimer.lineColor = .systemGray //UIColor.white.darker(amount: 0.1)
        countdownTimer.trailLineColor = .white
        countdownTimer.timerFinishingText = "End"
        countdownTimer.lineWidth = 4
        countdownTimer.isLabelHidden = true


    }

    @objc func updateRemainingTimer() {

        if model.totalTime < 1 {

            remainingTimer.invalidate()

        } else {
            model.totalTime -= 1
            timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))

            timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        }
        // countdownTimer.labelFont = UIFont(name: "HelveticaNeue-Light", size: 50.0)


    }

    @IBAction func forwardInteralButtonClicked(_ sender: Any) {
        print("forwardInteralButtonClicked")
    }

    @IBAction func backInteralButtonClicked(_ sender: Any) {
        print("backInteralButtonClicked")
    }

    @IBAction func startButton(_ sender: Any) {
        if self.startButtonModel.resumeTapped == false {

            timerClass.invalidate()
            remainingTimer.invalidate()
            countdownTimer.pause()
            self.startButtonModel.resumeTapped = true
            startButton.setTitle("START",for: .normal)
        } else {
             runTimer()
            countdownTimer.resume()
            startButton.setTitle("STOP",for: .normal)
             self.startButtonModel.resumeTapped = false
        }
    }


    func setInitialTimer() {
        let interval = rout.intervals[model.currentIntervalCycle]
        currInterval.totalIntervalSets = interval.numSets
        print(currInterval.totalIntervalSets)
        intervalNameLabel.text = interval.intervalName

        if (interval.firstIntervalHigh) && currInterval.firstInterval {
            self.startInterval(interval: interval.highInterval, isHigh: true)

        }
        else {
            self.startInterval(interval: interval.lowInterval, isHigh: false)
        }
//        if model.veryFirstInterval {}
//        else {
//            model.seconds -= 1
//        }
//        model.veryFirstInterval = false
        // self.runTimer()


    }

    func startInterval(interval: IntervalIntensity, isHigh: Bool) {
        if isHigh {
            print("starting High")
            intervalNumberLabel.text = "\(currInterval.currentIntervalSet + 1)/\(rout.intervals[model.currentIntervalCycle].numSets) - high"
        }
        else {
            print("starting Low")
            intervalNumberLabel.text = "\(currInterval.currentIntervalSet + 1)/\(rout.intervals[model.currentIntervalCycle].numSets) - low"
        }

        model.seconds = interval.duration

        countdownTimer.start(beginingValue: model.seconds, interval: 1)
        countdownTimer.pause()
        self.view.backgroundColor = interval.intervalColor
        topView.backgroundColor = interval.intervalColor
        bottomView.backgroundColor = interval.intervalColor.darker(amount: 0.2)
        countdownTimer.backgroundColor = interval.intervalColor.darker(amount: 0.2)
        timer.text = timeString(time: TimeInterval(interval.duration))



    }
    

    func setBackground() {
        self.view.backgroundColor = rout.routineColor
        topView.backgroundColor = rout.routineColor
        bottomView.backgroundColor = rout.routineColor.darker(amount: 0.2)
    }

    func setNavigationBar() {
        self.navigationItem.setHidesBackButton(true, animated: false)
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        closeButton.tintColor = .white
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonClick))
        self.navigationItem.setRightBarButtonItems([editButton], animated: true)
        editButton.tintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]

        self.title = rout.name
    }



    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil

        self.navigationController?.navigationBar.tintColor = .systemBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
    }

    @objc func closeButtonClick(){
        print("closeButtonClick")
        self.navigationController?.popViewController(animated: true)

    }

    @objc func editButtonClick(){
        print("editButtonClick")
//        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
//        let myVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
//        let navController = UINavigationController(rootViewController: myVC)
//        self.navigationController?.present(navController, animated: true, completion: nil)
        if let viewController = UIStoryboard(name: "SettingView", bundle: nil).instantiateViewController(withIdentifier: "SettingView") as? SettingsController {
            // viewController.rout = rout[indexPath.row]
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }

    }

    func runTimer() {
        timer.text = timeString(time: TimeInterval(model.seconds))
        // timer.sizeToFit()

        timerClass = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        remainingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTimer), userInfo: nil, repeats: true)
    }

    @objc func updateTimer() {

        if model.seconds < 2 {
            print("here 0")
            remainingTimer.invalidate()
             timerClass.invalidate()

             //Send alert to indicate "time's up!"
            // currentIntervalSet += 1
            currInterval.firstInterval.toggle()
            if currInterval.firstInterval {

                print("here 1")
                currInterval.currentIntervalSet += 1
                if currInterval.currentIntervalSet == currInterval.totalIntervalSets {
                    print("here 2")
                    timer.text = timeString(time: TimeInterval(model.seconds - 1))
                    model.totalTime -= 1
                    timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
                    model.elapsedTime += 1
                    timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
                    
                }
                else {
                    print("here 3")
                    model.totalTime -= 1
                    timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
                    model.elapsedTime += 1
                    timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
                    runTimer()

                    self.setInitialTimer()
                    countdownTimer.resume()
                }

            }
            else {
                print("here 4")
                model.totalTime -= 1

                timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
                model.elapsedTime += 1
                timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
                runTimer()

                self.setInitialTimer()
                countdownTimer.resume()
            }


        } else {
            print("here 5")
             model.seconds -= 1
            model.elapsedTime += 1
            timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        
             timer.text = timeString(time: TimeInterval(model.seconds))

        }

    }

    func timeString(time:TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time)  % 3600 % 60
    return String(format: "%02i:%02i ", minutes, seconds)
    }

}

extension UIColor {

    var lighterColor: UIColor {
        return lighterColor(removeSaturation: 0.5, resultAlpha: -1)
    }

    func lighterColor(removeSaturation val: CGFloat, resultAlpha alpha: CGFloat) -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0
        var b: CGFloat = 0, a: CGFloat = 0

        guard getHue(&h, saturation: &s, brightness: &b, alpha: &a)
            else {return self}

        return UIColor(hue: h,
                       saturation: max(s - val, 0.0),
                       brightness: b,
                       alpha: alpha == -1 ? a : alpha)
    }
}


extension PXColor {

    func lighter(amount : CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(amount: 1 + amount)
    }

    func darker(amount : CGFloat = 0.25) -> PXColor {
        return hueColorWithBrightnessAmount(amount: 1 - amount)
    }

    private func hueColorWithBrightnessAmount(amount: CGFloat) -> PXColor {
        var hue         : CGFloat = 0
        var saturation  : CGFloat = 0
        var brightness  : CGFloat = 0
        var alpha       : CGFloat = 0

        #if os(iOS)

            if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
                return PXColor( hue: hue,
                                saturation: saturation,
                                brightness: brightness * amount,
                                alpha: alpha )
            } else {
                return self
            }

            #else

            getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
            return PXColor( hue: hue,
                            saturation: saturation,
                            brightness: brightness * amount,
                            alpha: alpha )

        #endif

    }
}

fileprivate let minimumHitArea = CGSize(width: 70, height: 70)

extension UIButton {
    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        // if the button is hidden/disabled/transparent it can't be hit
        if self.isHidden || !self.isUserInteractionEnabled || self.alpha < 0.01 { return nil }

        // increase the hit frame to be at least as big as `minimumHitArea`
        let buttonSize = self.bounds.size
        let widthToAdd = max(minimumHitArea.width - buttonSize.width, 0)
        let heightToAdd = max(minimumHitArea.height - buttonSize.height, 0)
        let largerFrame = self.bounds.insetBy(dx: -widthToAdd / 2, dy: -heightToAdd / 2)

        // perform hit test on larger frame
        return (largerFrame.contains(point)) ? self : nil
    }
}
