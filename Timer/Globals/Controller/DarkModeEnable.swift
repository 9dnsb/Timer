//
//  DarkModeEnable.swift
//  Timer
//
//  Created by David Blatt on 4/16/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit

public class DarkModeEnable: UIViewController {

    public func checkForDarkMode() -> UIUserInterfaceStyle  {
        if #available(iOS 13.0, *)  {
            if self.traitCollection.userInterfaceStyle == .dark && !UserDefaults.standard.bool(forKey: settings.enableDarkMode.rawValue) {
                // Always adopt a light interface style.
                self.overrideUserInterfaceStyle = .light
                return self.overrideUserInterfaceStyle
                //self.navigationController?.navigationBar.tintColor = .systemGray6
            }


        }
        return self.overrideUserInterfaceStyle
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
