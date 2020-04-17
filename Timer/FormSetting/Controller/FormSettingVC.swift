//
//  FormSettingVC.swift
//  Timer
//
//  Created by David Blatt on 4/14/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import Eureka

class FormSettingVC: FormViewController {

    var settingDel : settingDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        let closeButton = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(closeButtonClick))
        self.navigationItem.setLeftBarButtonItems([closeButton], animated: true)
        form +++

            Section("General")
            <<< SwitchRow() {
                $0.title = "Lock Player on Start"

                $0.value = UserDefaults.standard.bool(forKey: settings.lockPlayer.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.lockPlayer.rawValue)
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
            

            +++ Section("Sounds")

            <<< SwitchRow() {
                $0.title = "Enable Sounds"

                $0.value = UserDefaults.standard.bool(forKey: settings.enableSound.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.enableSound.rawValue)
            }



            <<< SwitchRow() {
                $0.title = "Vibration"

                $0.value = UserDefaults.standard.bool(forKey: settings.vibration.rawValue)
            }.onChange { cell in
                UserDefaults.standard.set(cell.value, forKey: settings.vibration.rawValue)
            }

            <<< SliderRow() {
                    $0.title = "Sound Volume"
                    //print("UserDefaults.standard.float(forKey: settings.soundVolume.rawValue)", UserDefaults.standard.object(forKey: settings.soundVolume.rawValue))

                    $0.value = UserDefaults.standard.float(forKey: settings.soundVolume.rawValue)


                }.onChange { cell in
                    UserDefaults.standard.set(cell.value!, forKey: settings.soundVolume.rawValue)
            }

        +++ Section("Background Work")

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
    }

    @objc func closeButtonClick(){
        self.dismiss(animated: true, completion: nil)

    }


}
