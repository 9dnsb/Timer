//
//  SubscribeAlert.swift
//  Timer
//
//  Created by David Blatt on 4/20/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit

public class SubscribeAlert {
    func runAlert(theView: UIViewController, theString: String = "", presAlert: Bool = true, fromSetting: Bool = false) -> Bool {
        if Reachability.isConnectedToNetwork(){
            print("Internet Connection Available!")
            if !UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue) {
                if presAlert {
                    self.presentAlert(theView: theView, theString: theString)
                }
                else {
                    self.presentVC(theView: theView, fromSetting: fromSetting)
                }

            }
            else {
                return false
            }
        }else{
            print("Internet Connection not Available!")
            self.noInternetAlert(theView: theView, fromSetting: fromSetting)
        }

        return true
    }

    func presentVC(theView: UIViewController, fromSetting: Bool = false) {
        let storyboard = UIStoryboard(name: "SubscribeView", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "SubscribeView") as! SubscribeViewController
        myVC.title = "Subscription Settings"
        let navController = UINavigationController(rootViewController: myVC)
        theView.navigationController?.present(navController, animated: true, completion: nil)
        
    }

    func presentAlert(theView: UIViewController, theString: String) {
        let alert = UIAlertController(title: "Your are not subscribed", message: "You must be subscribed to \(theString)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Subscribe", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                self.presentVC(theView: theView)
            case .cancel:
                print("cancel")

            case .destructive:
                print("destructive")

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
        theView.present(alert, animated: true, completion: nil)
    }

    func noInternetAlert(theView: UIViewController, fromSetting: Bool = false) {
        let string1 = "This feature requires a subscription. "
        let string2 = "You must be connected to the internet to subscribe."
        var theString : String
        if fromSetting {
            theString = string2
        }
        else {
            theString = string1 + string2
        }

        let alert = UIAlertController(title: "No Internet Connection", message: theString, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
        theView.present(alert, animated: true, completion: nil)
    }
}
