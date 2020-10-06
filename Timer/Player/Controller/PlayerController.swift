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

import GoogleMobileAds
import SwiftRater

protocol ModalDelegate3 {
    func getRoutine(value: Routine)
}

public  typealias PXColor = UIColor
class PlayerController: UIViewController, ModalDelegate3, GADBannerViewDelegate{



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
    @IBOutlet weak var googleAd: GADBannerView!

    @IBOutlet weak var veryBottom: UIView!
    @IBOutlet weak var navItem: UIBarButtonItem!
    @IBOutlet weak var navItemLeft: UIBarButtonItem!



    var player : AVAudioPlayer?
    var Blankplayer : AVAudioPlayer?
    var arrayView = [UIView]()
    var timer2 : Timer?
    let audioLimit: TimeInterval = 1
    var rout: Routine = Routine(name: "", type: "", warmup: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), intervals: [], numCycles: 0, restTime: IntervalIntensity(duration: 0, intervalColor: .systemYellow, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemBlue, sound: sounds.none), routineColor: .systemRed, totalTime: 0, intervalRestTime: IntervalIntensity(duration: 0, intervalColor: .systemBlue, sound: sounds.none), enableIntervalVoice: false)
    var routArrayPlayer = [routArray]()
    var timerClass = Timer()
    var elapsedTimer = Timer()
    var remainingTimer = Timer()
    var model = playerModel()
    var startButtonModel = resumeButton()
    var currInterval = currentInterval()
    var currIndex = 0
    var speechSynthesizer = AVSpeechSynthesizer()

    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        // playVoice(voice: "This is a test. This is only a test. If this was an actual emergency, then this wouldn’t have been a test.")
        super.viewDidLoad()

        

        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        self.setSystemImages()
        

    }

    

    func runGoogleAds() {
        if !UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue) {
//            googleAd.adUnitID = "ca-app-pub-3940256099942544/2934735716" //test
            googleAd.adUnitID = "ca-app-pub-2464759242018155/7204785293" //real
            googleAd.rootViewController = self
            googleAd.delegate = self
            googleAd.layer.cornerRadius = 8.0
            googleAd.clipsToBounds = true
            googleAd.adSize = kGADAdSizeBanner
            googleAd.load(GADRequest())
            googleAd.isHidden = false
        }
        else {
            googleAd.isHidden = true
        }
    }

    func setSystemImages() {
        if #available(iOS 13.0, *) {
            self.backIntervalButton.setBackgroundImage(UIImage(systemName: "chevron.left"), for: .normal)
            self.forwardIntervalButton.setBackgroundImage(UIImage(systemName: "chevron.right"), for: .normal)
            self.lockButton.setBackgroundImage(UIImage(systemName: "lock.open"), for: .normal)
            self.startButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            self.backIntervalButton.setBackgroundImage(UIImage(named: "chevron_left"), for: .normal)
            self.forwardIntervalButton.setBackgroundImage(UIImage(named: "chevron.right"), for: .normal)
            self.lockButton.setBackgroundImage(UIImage(named: "lock.open"), for: .normal)
            self.startButton.setBackgroundImage(UIImage(named: "play.fill"), for: .normal)
            
        }
    }

    @objc func applicationDidBecomeActive(notification: NSNotification) {
        //print("ACTIVE")
    }
    @objc func applicationDidEnterBackground(notification: NSNotification) {
        //print("BACKGROUND")
        //self.playerBlank()
        if  !(UserDefaults.standard.bool(forKey: settings.backgroundWork.rawValue)) && !self.startButtonModel.resumeTapped {

            self.stopTimer()
            let alert = UIAlertController(title: "Background Work is disabled", message: "Timer will not run in background because it is disabled. Would you like to enable Background Work", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
                switch action.style{
                case .default:
                    //print("default")
                    UserDefaults.standard.set(true, forKey: settings.backgroundWork.rawValue)
                    self.playerBlank()
                case .cancel:
                    print("cancel")

                case .destructive:
                    print("destructive")

                @unknown default:
                    print("error")
                }}))
            alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: { action in
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

    func playVoice(voice: String) {
        if UserDefaults.standard.bool(forKey: settings.enableSound.rawValue) == false || UserDefaults.standard.bool(forKey: settings.endVoiceEnabled.rawValue) == false {
            return
        }

        globals().playVoice(voice: voice, speechSynth: speechSynthesizer)
    }
    
    
    
    func setRemainingTimer() {
        self.rout.totalTime = routineTotalTime().calctotalRoutineTime(routArrayPlayer: self.routArrayPlayer)
        model.totalTime = rout.totalTime
        model.elapsedTime = 0
        timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
        timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
        timeRemainingLabel.text = timeString(time: TimeInterval(model.totalTime))
        timeElapsedLabel.text = timeString(time: TimeInterval(model.elapsedTime))
//        countdownTimer.labelTextColor = .white
//        countdownTimer.lineColor = .systemGray //UIColor.white.darker(amount: 0.1)
//        countdownTimer.trailLineColor = .white
//        countdownTimer.timerFinishingText = "End"
//        countdownTimer.lineWidth = 4
//        countdownTimer.isLabelHidden = true
        
        
    }

    
    @IBAction func forwardInteralButtonClicked(_ sender: Any) {
        self.elapsedRemainingUpdate(timeChange: model.seconds - 1)
        model.seconds = 1
        //        self.updateTimer(toAdd: 1)
        updateTimer(toAdd: 1, playSound: true)
    }
    
    @IBAction func lockButtonClicked(_ sender: Any) {
//        self.disableButtons()
        let firstActivityItem = "Description you want.."
        let dog = Dog(name: "Rex", owner: "Etgar")

//        DispatchQueue.main.async {
//                let encoder = JSONEncoder()
//                if let jsonData = try? encoder.encode(dog) {
//                    if let jsonString = String(data: jsonData, encoding: .utf8) {
//                        var documentsDirectoryURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//                        let file2ShareURL = documentsDirectoryURL.appendingPathComponent("blah.json")
//                        do {
//                            try jsonString.write(to: file2ShareURL, atomically: false, encoding: .utf8)
//                        } catch {
//                            print(error)
//                        }
//
//                        do {
//                            let _ = try Data(contentsOf: file2ShareURL)
//                            let activityViewController = UIActivityViewController(activityItems: [file2ShareURL], applicationActivities: nil)
//                            activityViewController.popoverPresentationController?.sourceView = self.view
//                            self.present(activityViewController, animated: true, completion: nil)
//                        } catch {
//                            print(error)
//                        }
//
//                }
//            }
//        }

    }

    @IBAction func backInteralButtonClicked(_ sender: Any) {
        //print("backInteralButtonClicked")
        var timeToChange = 1
        if currIndex == 0 {
            //self.elapsedRemainingUpdate(timeChange: (routArrayPlayer[currIndex - 1].interval.duration  * -1) - timeToChange)
            self.changeInterval()
            self.setRemainingTimer()
            return
        }
        if !self.startButtonModel.resumeTapped {
            //print("here")
            //print("currIndex", currIndex)
            //print("model.seconds", model.seconds)
            timeToChange = 1// + currIndex
            self.elapsedRemainingUpdate(timeChange: (((routArrayPlayer[currIndex - 1].interval.duration) + (routArrayPlayer[currIndex].interval.duration - model.seconds) ) * -1) - timeToChange)
        }
        else {
            self.elapsedRemainingUpdate(timeChange: (routArrayPlayer[currIndex - 1].interval.duration  * -1) - timeToChange)
        }

        model.seconds = 1
        updateTimer(toAdd: -1, playSound: true)
    }

    
    @IBAction func startButton(_ sender: Any) {
        if currIndex == 0 && model.seconds == routArrayPlayer[currIndex].interval.duration && self.startButtonModel.firstTimeTapped == false {
            //print("here")
            self.startButtonModel.firstTimeTapped = true
            self.playSound()
        }
        if self.startButtonModel.resumeTapped == false {
            self.stopTimer()
            
        } else {
            runTimer()
            //countdownTimer.resume()
            //startButton.setTitle("STOP",for: .normal)
            if #available(iOS 13.0, *) {
                startButton.setBackgroundImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                startButton.setBackgroundImage(UIImage(named: "pause.fill"), for: .normal)
            }
            //


            self.startButtonModel.resumeTapped = false
            if UserDefaults.standard.bool(forKey: settings.lockPlayer.rawValue) {
                self.disableButtons()
            }
        }
    }
    
    func stopTimer() {
        timerClass.invalidate()
        // remainingTimer.invalidate()
        //countdownTimer.pause()
        self.startButtonModel.resumeTapped = true
        //startButton.setTitle("START",for: .normal)
        //

        if #available(iOS 13.0, *) {
            startButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            startButton.setBackgroundImage(UIImage(named: "play.fill"), for: .normal)
        }
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
            //countdownTimer.end()
            playVoice(voice: "Activity Completed.")
            SwiftRater.incrementSignificantUsageCount()
            runAlert()
            return
        }
        if runSound {
            self.playSound()
            if  UserDefaults.standard.bool(forKey: settings.vibration.rawValue) {
                print("vibrate")
                
                let generator = UIImpactFeedbackGenerator(style: .heavy)

                for _ in 1...2 {
                    generator.impactOccurred()
                }

            }
//            self.player?.pause()
//            self.player = globals().playSound(sound: routArrayPlayer[currIndex].interval.sound.rawValue, setSession: false)
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//
//                self.playerBlank()
//            }

        }
        
        model.seconds = routArrayPlayer[currIndex].interval.duration
        
//        countdownTimer.start(beginingValue: model.seconds - 0, interval: 1)
//        if self.startButtonModel.resumeTapped {
//            countdownTimer.pause()
//        }
        intervalNameLabel.text = routArrayPlayer[currIndex].intervalName
        self.view.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor
        topView.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor
        bottomView.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor.darker(amount: 0.2)
        veryBottom.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor.darker(amount: 0.2)
//        arrayView = [topMiddle, topBottom]
//        for i in arrayView {
//            i.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor
//        }
//        arrayView = [bottomTop, bottomMiddle, bottomBottom, bottomLockView, BottomsafeArea]
//        for i in arrayView {
//            i.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor.darker(amount: 0.2)
//        }
//        countdownTimer.backgroundColor = routArrayPlayer[currIndex].interval.intervalColor.darker(amount: 0.2)
        timer.text = timeString(time: TimeInterval(routArrayPlayer[currIndex].interval.duration))
        if routArrayPlayer[currIndex].isHigh == intervalOptions.cooldown.rawValue || routArrayPlayer[currIndex].isHigh == intervalOptions.warmUp.rawValue || routArrayPlayer[currIndex].isHigh == intervalOptions.rest.rawValue || routArrayPlayer[currIndex].isHigh == intervalOptions.intervalRest.rawValue {
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
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationItem.setHidesBackButton(true, animated: false)
//        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonClick))
//        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
//
//        closeButton.tintColor = .white
//        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonClick))
//        self.navigationItem.setRightBarButtonItems([editButton], animated: true)
//        editButton.tintColor = .white
        self.navigationController?.navigationBar.tintColor = .white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]

        self.title = rout.name
    }

    override func viewDidAppear(_ animated: Bool) {
        //self.coachMarksController.start(in: .currentWindow(of: self))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true


        self.runGoogleAds()
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

        
        self.setRemainingTimer()
        self.changeInterval(runSound: false)
        // self.playAudioFile()

    }

    func playerBlank() {
        if  !(UserDefaults.standard.bool(forKey: settings.backgroundWork.rawValue)) {
            return
        }

        Blankplayer = try? AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "blank", withExtension: "wav")!)
        Blankplayer?.numberOfLoops = -1
        Blankplayer?.volume = 0.1
        Blankplayer?.play()
        //print("here")
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

        //print("diss")

        
    }

    @IBAction func closeButtonClick(_ sender: Any) {
        if model.elapsedTime == 0 {
            self.navigationController?.popViewController(animated: true)
            return
        }
        
        presentActionSheet(sender: navItemLeft)

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
            //lockButton.setBackgroundImage(UIImage(systemName: "lock.open"), for: .normal)

            if #available(iOS 13.0, *) {
                lockButton.setBackgroundImage(UIImage(systemName: "lock.open"), for: .normal)
            } else {
                lockButton.setBackgroundImage(UIImage(named: "lock.open"), for: .normal)
            }


        }
        else {
            self.navigationController?.navigationBar.alpha = 0.5
//

            if #available(iOS 13.0, *) {
                lockButton.setBackgroundImage(UIImage(systemName: "lock"), for: .normal)
            } else {
                lockButton.setBackgroundImage(UIImage(named: "lock.closed"), for: .normal)
            }

        }


    }
    @IBAction func editButtonClick(_ sender: Any) {
        if !self.startButtonModel.resumeTapped {
            //print("playing")

        }

        if model.elapsedTime == 0 {
            self.presentEdit()
            return
        }

        presentActionSheet(sender: navItemLeft, ifEdit: true)


    }

    func presentEdit() {
        if let viewController = UIStoryboard(name: "RoutineEditorView", bundle: nil).instantiateViewController(withIdentifier: "RoutineEditorView") as? RoutineEditorController {
            viewController.rout = rout
            //viewController.currObjId = rout.objectID
            viewController.title = "Edit Timer"
            viewController.passClubDelegate = self

            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
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
            if  UserDefaults.standard.bool(forKey: settings.vibration.rawValue) {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                }
                self.player?.stop()
                self.player = globals().playSound(sound: routArrayPlayer[currIndex].interval.sound.rawValue, setSession: false)
//                if UserDefaults.standard.bool(forKey: settings.enableSound.rawValue) == false || UserDefaults.standard.bool(forKey: settings.endVoiceEnabled.rawValue) == false {
//                    return
//                }

        if  UserDefaults.standard.bool(forKey: settings.intervalVoiceEnabled.rawValue) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                globals().playVoice(voice: self.routArrayPlayer[self.currIndex].intervalName, speechSynth: self.speechSynthesizer, voiceInterval: true)
            }

        }

//        if UserDefaults.standard.bool(forKey: settings.enableSound.rawValue) == false {
//            //print("is false")
//            return
//        }
//
//        player?.stop()
//        //print("routArrayPlayer[currIndex].interval.sound.rawValue", routArrayPlayer[currIndex].interval.sound.rawValue)
//        if !(routArrayPlayer[currIndex].interval.sound == sounds.none) {
//            let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: routArrayPlayer[currIndex].interval.sound.rawValue, ofType: "mp3")!)
//            try! player = AVAudioPlayer(contentsOf: alertSound)
//            player?.prepareToPlay()
//            player?.volume =  UserDefaults.standard.float(forKey: settings.soundVolume.rawValue) / 10
//            //print("player?.volume", player?.volume!)
//            player?.play()
////            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
////
////                            self.playerBlank()
////                        }
//        }
        
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

    func presentActionSheet(sender: UIBarButtonItem, ifEdit: Bool = false) {
        let actionSheetControllerIOS8: UIAlertController = UIAlertController()
        let cancelActionButton = UIAlertAction(title: "Return to Player", style: .cancel) { _ in
            print("Cancel")
        }
        actionSheetControllerIOS8.addAction(cancelActionButton)
        let saveActionButton = UIAlertAction(title: "Leave Player", style: .destructive)
        { _ in
            print("Discard Changes")
            if !ifEdit {
                self.navigationController?.popViewController(animated: true)
            }
            else {
                self.presentEdit()
            }
        }
        actionSheetControllerIOS8.addAction(saveActionButton)

        if let popoverController = actionSheetControllerIOS8.popoverPresentationController {
          popoverController.barButtonItem = sender
        }
        self.present(actionSheetControllerIOS8, animated: true, completion: nil)
    }
    
    func runAlert() {

        let alert = UIAlertController(title: "Completed", message: "You have completed your timer", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                //print("default")
                //self.startButton.setTitle("START",for: .normal)

                if #available(iOS 13.0, *) {
                    self.startButton.setBackgroundImage(UIImage(systemName: "play.fill"), for: .normal)
                } else {
                    self.startButton.setBackgroundImage(UIImage(named: "play.fill"), for: .normal)
                }
                self.startButtonModel.firstTimeTapped = false
                self.setRemainingTimer()
                self.changeInterval(runSound: false)
                if !self.startButton.isEnabled {
                    self.disableButtons()
                }
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

//    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
//      print("adViewDidReceiveAd")
//    }
//
//    /// Tells the delegate an ad request failed.
//    func adView(_ bannerView: GADBannerView,
//        didFailToReceiveAdWithError error: GADRequestError) {
//      print("adView:didFailToReceiveAdWithError: \(error.localizedDescription)")
//    }
//
//    /// Tells the delegate that a full-screen view will be presented in response
//    /// to the user clicking on an ad.
//    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
//      print("adViewWillPresentScreen")
//    }
//
//    /// Tells the delegate that the full-screen view will be dismissed.
//    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
//      print("adViewWillDismissScreen")
//    }
//
//    /// Tells the delegate that the full-screen view has been dismissed.
//    func adViewDidDismissScreen(_ bannerView: GADBannerView) {
//      print("adViewDidDismissScreen")
//    }
//
//    /// Tells the delegate that a user click will open another app (such as
//    /// the App Store), backgrounding the current app.
//    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
//      print("adViewWillLeaveApplication")
//    }
    
    
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

extension UIBarButtonItem {
    var view: UIView? {
        return perform(#selector(getter: UIViewController.view)).takeRetainedValue() as? UIView
    }
}
