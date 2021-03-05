//
//  FormSettingVC.swift
//  Timer
//
//  Created by David Blatt on 4/14/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import Eureka
import MessageUI
import SwiftRater
import StoreKit
import AVFoundation


class FormSettingVC: FormViewController, MFMailComposeViewControllerDelegate {

    var settingDel : settingDelegate?
    var subData : subSendData!
    var routineContr : RoutinesController!
    var player : AVAudioPlayer?
    var speechSynthesizer = AVSpeechSynthesizer()
    override func viewDidLoad() {
        super.viewDidLoad()
        isModalInPresentation = true
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        form +++

            Section("Player")
            <<< SwitchRow() {
                $0.title = "Lock Player on Start"

                $0.value = UserDefaults.standard.bool(forKey: settings.lockPlayer.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.lockPlayer.rawValue)
            }
            <<< SwitchRow() {
                $0.title = "Remove Last Low Interval"

                $0.value = UserDefaults.standard.bool(forKey: settings.removeLastIntervalLow.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.removeLastIntervalLow.rawValue)
            }
            <<< SwitchRow() {
                $0.title = "Remove Last Rest Interval"

                $0.value = UserDefaults.standard.bool(forKey: settings.removeLastIntervalRest.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.removeLastIntervalRest.rawValue)
            }

            <<< ActionSheetRow<String>() {
                $0.title = "Background Work"
                $0.selectorTitle = "Timer continues to work in the background when you lock the screen or press device's Home button. Timer will be stopped if you press the X button"
                $0.options = ["Enabled", "Disabled"]
                if  UserDefaults.standard.bool(forKey: settings.backgroundWork.rawValue) {
                    $0.value = "Enabled"
                }
                else {
                    $0.value = "Disabled"
                }

                }
                .onPresent { from, to in
                    to.popoverPresentationController?.permittedArrowDirections = .up
            }.onChange { cell in
                if cell.value == "Enabled" {
                    UserDefaults.standard.set(true, forKey: settings.backgroundWork.rawValue)
                }
                else {
                    UserDefaults.standard.set(false, forKey: settings.backgroundWork.rawValue)
                }

            }
//            <<< SwitchRow() {
//                $0.title = "Enable Dark Mode"
//
//                $0.value = UserDefaults.standard.bool(forKey: settings.enableDarkMode.rawValue)
//            }.onChange { cell in
//                UserDefaults.standard.set(cell.value, forKey: settings.enableDarkMode.rawValue)
//                if let settingDel = self.settingDel {
//                    settingDel.changeValue(darkMode: true)
//                }
//            }
            +++ Section("Routine Defaults")

            <<< IntRow() {
                $0.title = "Low Interval Time (Seconds)"

                $0.value = UserDefaults.standard.integer(forKey: settings.lowIntDefault.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.lowIntDefault.rawValue)
            }
            <<< IntRow() {
                $0.title = "Number of Sets"
                $0.add(rule: RuleGreaterThan(min: 0))
                $0.value = UserDefaults.standard.integer(forKey: settings.setsDefault.rawValue)
                $0.validationOptions = .validatesOnChange
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.setsDefault.rawValue)
            }.cellUpdate { cell, row in
                    if !row.isValid {
                        cell.titleLabel?.textColor = .red
                    }
            }


            +++ Section("Timer Sounds")

            <<< SwitchRow() {
                $0.title = "Enable Sounds"

                $0.value = UserDefaults.standard.bool(forKey: settings.enableSound.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.enableSound.rawValue)
            }



            <<< SwitchRow() {
                $0.title = "Vibration"
                if (UIDevice.current.value(forKey: "_feedbackSupportLevel")) as! Int != 2 {
                    $0.hidden = true
                }
                $0.value = UserDefaults.standard.bool(forKey: settings.vibration.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.vibration.rawValue)
            }

            <<< SliderRow() {
                    $0.title = "Timer Volume"
                    $0.value = UserDefaults.standard.float(forKey: settings.soundVolume.rawValue)
                }.onChange { cell in
                    UserDefaults.standard.set(cell.value!, forKey: settings.soundVolume.rawValue)
                    self.player = globals().playSound(sound: sounds.bell.rawValue)
            }

            +++ Section("Begin Interval Voice Prompt")
            <<< SwitchRow() {
                $0.title = "Enable Voice"
                $0.value = UserDefaults.standard.bool(forKey: settings.intervalVoiceEnabled.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.intervalVoiceEnabled.rawValue)
            }


            <<< SliderRow() {

                $0.title = "Voice Volume"
                $0.value = UserDefaults.standard.float(forKey: settings.IntervalVoiceVolume.rawValue)

                }.onChange { cell in
                    UserDefaults.standard.set(cell.value!, forKey: settings.IntervalVoiceVolume.rawValue)

                    globals().playVoice(voice: "Interval Voice", speechSynth: self.speechSynthesizer, voiceInterval: true)
            }.cellSetup { (cell, row) in
                row.steps = 10
            }

            <<< SliderRow() {
                    $0.title = "Voice Speed"
                    $0.value = UserDefaults.standard.float(forKey: settings.intervalVoiceSpeed.rawValue)
                }.onChange { cell in
                    UserDefaults.standard.set(cell.value!, forKey: settings.intervalVoiceSpeed.rawValue)

                    globals().playVoice(voice: "Interval Voice", speechSynth: self.speechSynthesizer, voiceInterval: true)
            }.cellSetup { (cell, row) in
                row.steps = 10
            }

            +++ Section("Timer Completed Voice Prompt")
            <<< SwitchRow() {
                $0.title = "Enable Voice"
                $0.value = UserDefaults.standard.bool(forKey: settings.endVoiceEnabled.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.endVoiceEnabled.rawValue)
            }


            <<< SliderRow() {

                $0.title = "Voice Volume"
                $0.value = UserDefaults.standard.float(forKey: settings.endVoiceVolume.rawValue)

                }.onChange { cell in
                    UserDefaults.standard.set(cell.value!, forKey: settings.endVoiceVolume.rawValue)

                    globals().playVoice(voice: "Completed Voice", speechSynth: self.speechSynthesizer)
            }.cellSetup { (cell, row) in
                row.steps = 10
            }

            <<< SliderRow() {
                    $0.title = "Voice Speed"
                    $0.value = UserDefaults.standard.float(forKey: settings.endVoiceSpeed.rawValue)
                }.onChange { cell in
                    UserDefaults.standard.set(cell.value!, forKey: settings.endVoiceSpeed.rawValue)

                    globals().playVoice(voice: "Completed Voice", speechSynth: self.speechSynthesizer)
            }.cellSetup { (cell, row) in
                row.steps = 10
            }



        //+++ Section("Background Work")



//        +++ Section("Subscription")
//
//
//
//            <<< ButtonRow("Subscribe") { (row: ButtonRow) -> Void in
//            row.title = row.tag
//            if UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue) {
//                    row.hidden = true
//                }
//            }.onCellSelection { _, _ in
//                if Reachability.isConnectedToNetwork(){
//                    print("Internet Connection Available!")
//                    if !UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue) {
//                        if let viewController = UIStoryboard(name: "SubscribeView", bundle: nil).instantiateViewController(withIdentifier: "SubscribeView") as? SubscribeViewController {
//                            viewController.title = "Subscription Settings"
//                            viewController.subDel = self.routineContr
//                            if let navigator = self.navigationController {
//                                navigator.pushViewController(viewController, animated: true)
//                            }
//                        }
//
//                    }
//                }else{
//                    print("Internet Connection not Available!")
//                    SubscribeAlert().noInternetAlert(theView: self, fromSetting: true)
//                }
//
//
//            }.cellUpdate { cell, row in
//                cell.textLabel?.textAlignment = .left
//            }
//
//        <<< DateRow() {
//            if self.subData.expireDate == Date(timeIntervalSinceReferenceDate: -123456789.0) || !UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue) {
//                $0.hidden = true
//            }
//        $0.title = "Expiry Date"
//            if subData.expireDate == Date(timeIntervalSinceReferenceDate: -123456789.0) {
//                $0.value = Calendar.current.date(byAdding: .year, value: 1, to: Date())
//            }
//            else {
//                $0.value = subData.expireDate
//            }
//
//            let formatter = DateFormatter()
//            formatter.locale = .current
//            formatter.dateStyle = .short
//            formatter.timeStyle = .short
//            $0.dateFormatter = formatter
//            $0.disabled = true
//        }
//
//        <<< ButtonRow {
//            if !UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue) {
//                $0.hidden = true
//            }
//            $0.title = "Cancel Subscription"
//        }.onCellSelection { _, _  in
//            UIApplication.shared.open(URL(string: "https://apps.apple.com/account/subscriptions")!)
////            let alert = UIAlertController(title: "Alert", message: "Message", preferredStyle: UIAlertController.Style.alert)
////            alert.addAction(UIAlertAction(title: "Click", style: UIAlertAction.Style.default, handler: nil))
////            self.present(alert, animated: true, completion: nil)
//        }.cellUpdate { cell, row in
//            cell.textLabel?.textAlignment = .left
//        }
//
            
        +++ Section("Feedback")
            
        <<< ButtonRow("email") { row in
            row.title = "Email Developer"
            }.onCellSelection { _, _ in
                if MFMailComposeViewController.canSendMail() {
                    let composeVC = MFMailComposeViewController()
                    composeVC.mailComposeDelegate = self
                    composeVC.setToRecipients(["davidblatt10@gmail.com"])
                    composeVC.setSubject("David's Interval Timer Support")

                    self.present(composeVC, animated: true, completion: nil)
                }
                else {
                    let alert = UIAlertController(title: "Can't send email", message: "This device doesn't support sending email from the app", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }

        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
        }
        <<< ButtonRow("rate") { row in
            row.title = "Rate David's Interval Timer"
            }.onCellSelection { _, _ in
                SwiftRater.rateApp(host: self)


        }.cellUpdate { cell, row in
            cell.textLabel?.textAlignment = .left
        }





    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?){
        controller.dismiss(animated: true, completion: nil)
    }

    @objc func closeButtonClick(){
        self.dismiss(animated: true, completion: nil)

    }


}

extension FormSettingVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        //print("here")
        self.closeButtonClick()
    }
}

