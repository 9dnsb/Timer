//
//  AppDelegate.swift
//  Timer
//
//  Created by David Blatt on 3/18/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import CoreData
import SwiftyStoreKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        if UserDefaults.standard.object(forKey: settings.soundVolume.rawValue) == nil {
            UserDefaults.standard.set(5, forKey: settings.soundVolume.rawValue)



        }
        if UserDefaults.standard.object(forKey: settings.enableSound.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: settings.enableSound.rawValue)
        }
        if UserDefaults.standard.object(forKey: settings.vibration.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: settings.vibration.rawValue)
        }
        if UserDefaults.standard.object(forKey: settings.backgroundWork.rawValue) == nil {
            UserDefaults.standard.set(true, forKey: settings.backgroundWork.rawValue)
        }
        if UserDefaults.standard.object(forKey: settings.lockPlayer.rawValue) == nil {
            UserDefaults.standard.set(false, forKey: settings.lockPlayer.rawValue)
        }
        if UserDefaults.standard.object(forKey: settings.enableDarkMode.rawValue) == nil {
            UserDefaults.standard.set(false, forKey: settings.enableDarkMode.rawValue)
        }
        if UserDefaults.standard.object(forKey: subscription.isSubsribed.rawValue) == nil {
            UserDefaults.standard.set(false, forKey: subscription.isSubsribed.rawValue)
        }
        //UserDefaults.standard.set(false, forKey: subscription.isSubsribed.rawValue)


        // Override point for customization after application launch.
        // UIBarButtonItem.appearance().tintColor = .systemGray
        setupIAP()
        return true
    }

    func setupIAP() {

        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in

            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    break // do nothing
                @unknown default:
                    break // do nothing
                }
            }
        }

        SwiftyStoreKit.updatedDownloadsHandler = { downloads in

            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Timer")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

