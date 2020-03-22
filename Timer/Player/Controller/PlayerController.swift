//
//  PlayerController.swift
//  Timer
//
//  Created by David Blatt on 3/21/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
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
    
    var rout: Routine = Routine(name: "", type: "", warmup: 0, intervals: [], numCycles: 0, restTime: 0, coolDown: 0, routineColor: .systemRed, totalTime: 0)
    var timerClass = Timer()
    var elapsedTimer = Timer()
    var remainingTimer = Timer()
    var model = playerModel()
    var currInterval = currentInterval()

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }
    override func viewDidLoad() {
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
        // timeRemainingLabel.text = String(model.totalTime)
        remainingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTimer), userInfo: nil, repeats: true)
    }

    @objc func updateRemainingTimer() {

        if model.totalTime < 1 {

            remainingTimer.invalidate()
            elapsedTimer.invalidate()

        } else {
             model.totalTime -= 1     //This will decrement(count down)the seconds.
            timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))

            model.elapsedTime += 1     //This will decrement(count down)the seconds.
            timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        }

    }

    @IBAction func forwardInteralButtonClicked(_ sender: Any) {
        print("forwardInteralButtonClicked")
    }

    @IBAction func backInteralButtonClicked(_ sender: Any) {
        print("backInteralButtonClicked")
    }

    func setInitialTimer() {
        let interval = rout.intervals[model.currentIntervalCycle]
        currInterval.totalIntervalSets = interval.numSets
        print(currInterval.totalIntervalSets)
        intervalNameLabel.text = interval.intervalName

        if (interval.firstIntervalHigh) && currInterval.firstInterval {
            print("starting High")
            model.seconds = interval.highInterval.duration
            intervalNumberLabel.text = "\(currInterval.currentIntervalSet + 1)/\(interval.numSets) - high"
            self.view.backgroundColor = interval.highInterval.intervalColor
            topView.backgroundColor = interval.highInterval.intervalColor
            bottomView.backgroundColor = interval.highInterval.intervalColor.darker(amount: 0.2)

        }
        else {
            print("starting Low")
            model.seconds = rout.intervals[0].lowInterval.duration
            intervalNumberLabel.text = "\(currInterval.currentIntervalSet + 1)/\(interval.numSets) - low"
            self.view.backgroundColor = interval.lowInterval.intervalColor
            topView.backgroundColor = interval.lowInterval.intervalColor
            bottomView.backgroundColor = interval.lowInterval.intervalColor.darker(amount: 0.2)
        }
        if model.veryFirstInterval {


        }
        else {
            model.seconds -= 1
        }
        model.veryFirstInterval = false
        self.runTimer()

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
        self.navigationController?.navigationBar.isTranslucent = false
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

    }

    @objc func updateTimer() {

        if model.seconds < 1 {
             timerClass.invalidate()
             //Send alert to indicate "time's up!"
            // currentIntervalSet += 1
            currInterval.firstInterval.toggle()
            if currInterval.firstInterval {
                print("here 1")
                currInterval.currentIntervalSet += 1
                if currInterval.currentIntervalSet == currInterval.totalIntervalSets {
                    print("here 2")
                    // self.setInitialTimer(currentInterval: currentIntervalSet)
                }
                else {
                    self.setInitialTimer()
                }

            }
            else {
                print("here 3")
                self.setInitialTimer()
            }


        } else {
             model.seconds -= 1     //This will decrement(count down)the seconds.
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
