//
//  PlayerController.swift change change
//  Timer
//
//  Created by David Blatt on 3/21/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SRCountdownTimer
import AVFoundation

protocol ModalDelegate3 {
    func getRoutine(value: Routine)
}

public  typealias PXColor = UIColor
class PlayerController: UIViewController, ModalDelegate3{
    func getRoutine(value: Routine) {
        self.rout = value
        
        
    }
    
    


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
    @IBOutlet weak var lockButton: UIButton!
    @IBOutlet weak var lockbuttonView: UIView!

    @IBOutlet weak var countdownTimer: SRCountdownTimer!
    var player : AVAudioPlayer?
    var timer2 : Timer?
    let audioLimit: TimeInterval = 1
    var rout: Routine = Routine(name: "", type: "", warmup: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), intervals: [], numCycles: 0, restTime: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemBlue, sound: sounds.none), routineColor: .systemRed, totalTime: 0)
    var routArrayPlayer = [routArray]()
    var timerClass = Timer()
    var elapsedTimer = Timer()
    var remainingTimer = Timer()
    var model = playerModel()
    var startButtonModel = resumeButton()
    var currInterval = currentInterval()
    var currIndex = 0
    var speechSynthesizer = AVSpeechSynthesizer()
    var speechUtterance: AVSpeechUtterance = AVSpeechUtterance(string: "")
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        // playVoice(voice: "This is a test. This is only a test. If this was an actual emergency, then this wouldn’t have been a test.")

        
    }
    
    
    
    func playVoice(voice: String) {
        if UserDefaults.standard.bool(forKey: settings.enableSound.rawValue) == false {
            return
        }
        speechUtterance = AVSpeechUtterance(string: voice)
        //Line 3. Specify the speech utterance rate. 1 = speaking extremely the higher the values the slower speech patterns. The default rate, AVSpeechUtteranceDefaultSpeechRate is 0.5
        speechUtterance.rate = AVSpeechUtteranceMaximumSpeechRate / 2.5
        speechUtterance.volume = UserDefaults.standard.float(forKey: settings.soundVolume.rawValue) / 10
        // Line 4. Specify the voice. It is explicitly set to English here, but it will use the device default if not specified.
        // speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        // Line 5. Pass in the urrerance to the synthesizer to actually speak.
        speechSynthesizer.speak(speechUtterance)
    }
    
    
    
    func setRemainingTimer() {
        self.rout.totalTime = routineTotalTime().calctotalRoutineTime(routArrayPlayer: self.routArrayPlayer)
        model.totalTime = rout.totalTime
        model.elapsedTime = 0
        timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
        timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
        timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        countdownTimer.labelTextColor = .white
        countdownTimer.lineColor = .systemGray //UIColor.white.darker(amount: 0.1)
        countdownTimer.trailLineColor = .white
        countdownTimer.timerFinishingText = "End"
        countdownTimer.lineWidth = 4
        countdownTimer.isLabelHidden = true
        
        
    }
    
    //    @objc func updateRemainingTimer() {
    //    }
    
    @IBAction func forwardInteralButtonClicked(_ sender: Any) {
        self.elapsedRemainingUpdate(timeChange: model.seconds - 1)
        model.seconds = 1
        //        self.updateTimer(toAdd: 1)
        updateTimer(toAdd: 1, playSound: true)
    }
    
    @IBAction func lockButtonClicked(_ sender: Any) {
        self.disableButtons()
    }

    @IBAction func backInteralButtonClicked(_ sender: Any) {
        if currIndex == 0 {
            return
        }
        self.elapsedRemainingUpdate(timeChange: ((routArrayPlayer[currIndex - 1].interval.duration) * -1) - 1)
        model.seconds = 1
        updateTimer(toAdd: -1, playSound: true)
    }
    
    func backButtonTimeChange() {
        
        model.seconds = 1
        self.updateTimer(toAdd: -1)
        self.elapsedRemainingUpdate(timeChange: (model.seconds + 1) * -1)
    }
    
    @IBAction func startButton(_ sender: Any) {

        if self.startButtonModel.resumeTapped == false {
            self.stopTimer()
            
        } else {
            runTimer()
            countdownTimer.resume()
            startButton.setTitle("STOP",for: .normal)
            self.startButtonModel.resumeTapped = false
            if UserDefaults.standard.bool(forKey: settings.lockPlayer.rawValue) {
                self.disableButtons()
            }
        }
    }
    
    func stopTimer() {
        timerClass.invalidate()
        // remainingTimer.invalidate()
        countdownTimer.pause()
        self.startButtonModel.resumeTapped = true
        startButton.setTitle("START",for: .normal)
    }
    
    func setCurrentIntervalTotalSets() {
        currInterval.totalIntervalSets = rout.intervals[model.currentIntervalCycle].numSets
    }
    
    func changeInterval(runSound: Bool = true) {
        if currIndex == routArrayPlayer.count {
            self.timerMinusSecond()
            self.startButtonModel.resumeTapped = true
            self.currIndex = 0
            timerClass.invalidate()
            playVoice(voice: "Activity Completed.")
            runAlert()
            return
        }
        if runSound {
            //self.playSound()
            if  UserDefaults.standard.bool(forKey: settings.vibration.rawValue) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
            }
            self.player = globals().playSound(sound: routArrayPlayer[currIndex].interval.sound.rawValue, setSession: false)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {

                self.playerBlank()
            }

        }
        
        model.seconds = routArrayPlayer[currIndex].interval.duration
        
        countdownTimer.start(beginingValue: model.seconds - 0, interval: 1)
        if self.startButtonModel.resumeTapped {
            countdownTimer.pause()
        }
        intervalNameLabel.text = routArrayPlayer[currIndex].intervalName
        self.view.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor
        topView.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor
        bottomView.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor.darker(amount: 0.2)
        countdownTimer.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor.darker(amount: 0.2)
        timer.text = timeString(time: TimeInterval(routArrayPlayer[currIndex].interval.duration))
        if routArrayPlayer[currIndex].isHigh == intervalOptions.cooldown.rawValue || routArrayPlayer[currIndex].isHigh == intervalOptions.warmUp.rawValue || routArrayPlayer[currIndex].isHigh == intervalOptions.rest.rawValue {
            intervalNumberLabel.text = ""
            
            
        }
        if routArrayPlayer[currIndex].isHigh == intervalOptions.lowInt.rawValue {
            intervalNumberLabel.text = "\(routArrayPlayer[currIndex].currInterval)/\(routArrayPlayer[currIndex].totalInterval) - low"
        }
        if routArrayPlayer[currIndex].isHigh == intervalOptions.highInt.rawValue {
            intervalNumberLabel.text = "\(routArrayPlayer[currIndex].currInterval)/\(routArrayPlayer[currIndex].totalInterval) - high"
        }
        if routArrayPlayer[currIndex].isHigh == intervalOptions.warmUp.rawValue {
            intervalNameLabel.text = "Warm Up"
        }
        if routArrayPlayer[currIndex].isHigh == intervalOptions.rest.rawValue {
            intervalNameLabel.text = "Rest"
        }
        
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
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.title = rout.name
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        //let oo = globals().loadCoreData2(rout1: rout)
        //print("oo", oo)
        self.currIndex = 0
        self.setNavigationBar()
        
        routArrayPlayer = routineTotalTime().buildArray(rout: rout)
        
        let session = AVAudioSession.sharedInstance()
        
        try? session.setCategory(.playback, options: .mixWithOthers)
        try? session.setActive(true, options: [])
        if timer2 == nil {
            timer2 = Timer.scheduledTimer(withTimeInterval: 2, repeats: true,
                                          block: {_ in _ = 0})
        }
        if player == nil {
            self.playerBlank()
        }
        
        
        
        model.totalIntervalCycles = rout.intervals.count
        model.totalCycles = rout.numCycles
        super.viewDidLoad()
        
        self.setRemainingTimer()
        self.changeInterval(runSound: false)
        // self.playAudioFile()
    }

    func playerBlank() {
        if  !(UserDefaults.standard.bool(forKey: settings.backgroundWork.rawValue)) {
            return
        }

        player = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "blank", withExtension: "wav")!)
        player?.numberOfLoops = -1
        player?.play()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        
        self.navigationController?.navigationBar.tintColor = .systemBlue
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.systemBlue]
        timerClass.invalidate()
        remainingTimer.invalidate()
        timer2?.invalidate()
        self.stopTimer()
        countdownTimer.end()
        
    }
    
    @objc func closeButtonClick(){
        self.navigationController?.popViewController(animated: true)
        
    }

    func disableButtons() {
        forwardIntervalButton.isEnabled.toggle()
        backIntervalButton.isEnabled.toggle()
        startButton.isEnabled.toggle()
        self.navigationController!.navigationBar.isUserInteractionEnabled.toggle()
        //self.navigationController!.view.isUserInteractionEnabled.toggle()
        // self.navigationController?.navigationBar.tintColor = .gray
        if startButton.isEnabled {
            self.navigationController?.navigationBar.alpha = 1
            lockButton.setBackgroundImage(UIImage(systemName: "lock.open"), for: .normal)

        }
        else {
            self.navigationController?.navigationBar.alpha = 0.5
            lockButton.setBackgroundImage(UIImage(systemName: "lock"), for: .normal)
        }


    }
    
    @objc func editButtonClick(){
        
        if !self.startButtonModel.resumeTapped {
            print("playing")
        }
        
        if let viewController = UIStoryboard(name: "RoutineEditorView", bundle: nil).instantiateViewController(withIdentifier: "RoutineEditorView") as? RoutineEditorController {
            viewController.rout = rout
            //viewController.currObjId = rout.objectID
            viewController.title = "Edit Routine"
            viewController.passClubDelegate = self
            
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        //        let storyboard = UIStoryboard(name: "RoutineEditorView", bundle: nil)
        //        let myVC = storyboard.instantiateViewController(withIdentifier: "RoutineEditorView") as? RoutineEditorController
        //        myVC?.rout = rout
        //        let navController = UINavigationController(rootViewController: myVC!)
        //        myVC!.title = "Edit Routine"
        //        self.navigationController?.present(navController, animated: true, completion: nil)
        
        
    }
    
    func runTimer() {
        timer.text = timeString(time: TimeInterval(model.seconds))
        timerClass = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer1), userInfo: nil, repeats: true)
        // remainingTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateRemainingTimer), userInfo: nil, repeats: true)
        
    }
    
    func timerMinusSecond() {
        model.seconds -= 1
        timer.text = timeString(time: TimeInterval(model.seconds))
    }

    func playSound() {
        if UserDefaults.standard.bool(forKey: settings.enableSound.rawValue) == false {
            //print("is false")
            return
        }
        
        player?.stop()
        //print("routArrayPlayer[currIndex].interval.sound.rawValue", routArrayPlayer[currIndex].interval.sound.rawValue)
        if !(routArrayPlayer[currIndex].interval.sound == sounds.none) {
            let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: routArrayPlayer[currIndex].interval.sound.rawValue, ofType: "mp3")!)
            try! player = AVAudioPlayer(contentsOf: alertSound)
            player?.prepareToPlay()
            player?.volume =  UserDefaults.standard.float(forKey: settings.soundVolume.rawValue) / 10
            //print("player?.volume", player?.volume!)
            player?.play()
        }
        
    }
    
    func elapsedRemainingUpdate(timeChange: Int) {
        model.totalTime -= timeChange
        timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
        model.elapsedTime += timeChange
        timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
    }
    
    @objc func updateTimer1() {
        self.updateTimer(toAdd: 1)
    }
    
    func updateTimer(toAdd: Int, playSound: Bool = true) {
        self.elapsedRemainingUpdate(timeChange: 1)
        if model.seconds < 2 {
            
            currIndex += toAdd
            if playSound {
                
            }
            self.changeInterval()
        }
        else {
            self.timerMinusSecond()
        }
        
    }
    
    
    func runAlert() {

        let alert = UIAlertController(title: "Completed", message: "You have completed your routine", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.startButton.setTitle("START",for: .normal)
                self.setRemainingTimer()
                self.changeInterval(runSound: false)
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
                
            @unknown default:
                print("unknown")
            }}))
        self.present(alert, animated: true, completion: nil)
        
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
