//
//  TableViewControllerMain.swift
//  Timer
//
//  Created by David Blatt on 3/18/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SwiftReorder
import SwiftyStoreKit

class RoutinesController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    
    let cellSpacingHeight: CGFloat = 20
    var isEditingBool = true
    var addEditClick: UIBarButtonItem = UIBarButtonItem()
    var addRoutineButton: UIBarButtonItem = UIBarButtonItem()
    
    var rout = [Routine]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackgroundandNavigationBar()
        self.setupTable()

        self.tableView.reorder.delegate = self as TableViewReorderDelegate
        SwiftyStoreKit.retrieveProductsInfo(["db.timer.main.weekly"]) { result in
            if let product = result.retrievedProducts.first {
                let priceString = product.localizedPrice!
                print("Product: \(product.localizedDescription), price: \(priceString)")
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
            }
            else {
                print("Error: \(String(describing: result.error))")
            }
        }

        

        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "6685ee37760d411f8a996c5ab5a82334")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                let productId = "db.timer.main.weekly"
                // Verify the purchase of a Subscription
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable, // or .nonRenewing (see below)
                    productId: productId,
                    inReceipt: receipt)

                switch purchaseResult {
                case .purchased(let expiryDate, let items):
                    print("\(productId) is valid until \(expiryDate)\n\(items)\n")
                case .expired(let expiryDate, let items):
                    print("\(productId) is expired since \(expiryDate)\n\(items)\n")
                case .notPurchased:
                    print("The user has never purchased \(productId)")
                }

            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
        }
//        SwiftyStoreKit.purchaseProduct("db.timer.main.weekly", quantity: 1, atomically: false) { result in
//            switch result {
//            case .success(let product):
//                // fetch content from your server, then:
//                if product.needsFinishTransaction {
//                    SwiftyStoreKit.finishTransaction(product.transaction)
//                }
//                print("Purchase Success: \(product.productId)")
//            case .error(let error):
//                switch error.code {
//                case .unknown: print("Unknown error. Please contact support")
//                case .clientInvalid: print("Not allowed to make the payment")
//                case .paymentCancelled: break
//                case .paymentInvalid: print("The purchase identifier was invalid")
//                case .paymentNotAllowed: print("The device is not allowed to make the payment")
//                case .storeProductNotAvailable: print("The product is not available in the current storefront")
//                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
//                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
//                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
//                default: print((error as NSError).localizedDescription)
//                }
//            }
//        }
    }

    public enum subs {
        case weekly(item: String = "db.timer.main.weekly")
    }

    func setBackgroundandNavigationBar() {
        self.tableView.backgroundColor = .systemGroupedBackground
        let settingButton = UIButton(type: .custom)
        settingButton.setImage(UIImage(named: "settingIcon"), for: .normal)
        // settingButton.tintColor = .systemGray
        settingButton.addTarget(self, action: #selector(settingClicked), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: settingButton)
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
        addRoutineButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoutineClick))
        addEditClick = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addEditButton))
        self.navigationItem.setRightBarButtonItems([addRoutineButton, addEditClick], animated: true)
    }

    func setupTable() {
        let newRout1 = Routine(name: "Low Interval", type: "Simple", warmup: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 4, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 3, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 2, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 4, restTime: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemRed, totalTime: 0)
        let newInter = HighLowInterval(firstIntervalHigh: true, numSets: 4, intervalName: "Interval #2", highInterval: IntervalIntensity(duration: 4, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 3, intervalColor: .systemTeal, sound: sounds.none), HighLowIntervalColor: .systemRed)
        let newInter2 = HighLowInterval(firstIntervalHigh: false, numSets: 3, intervalName: "Interval #3", highInterval: IntervalIntensity(duration: 7, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 5, intervalColor: .systemTeal, sound: sounds.none), HighLowIntervalColor: .systemRed)
        let newInter3 = HighLowInterval(firstIntervalHigh: true, numSets: 3, intervalName: "Interval #3", highInterval: IntervalIntensity(duration: 7, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 5, intervalColor: .systemTeal, sound: sounds.none), HighLowIntervalColor: .systemRed)
        var rout3 = newRout1
        rout3.intervals.append(newInter)
        rout3.intervals.append(newInter2)
        rout3.intervals.append(newInter3)
        rout3.intervals.append(newInter)
        rout3.intervals.append(newInter2)
        rout3.name = "Test #3"
        let newRout2 = Routine(name: "Elbow", type: "Simple", warmup: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: true, numSets: 1, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 3, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 3, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 80, restTime: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemIndigo, totalTime: 0)
        let newRout5 = Routine(name: "High Interval", type: "Simple", warmup: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: true, numSets: 2, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 3, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 2, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 1, restTime: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemYellow, totalTime: 0)
        let newRout6 = Routine(name: "Low Interval", type: "Simple", warmup: IntervalIntensity(duration: 20, intervalColor: .systemGreen, sound: sounds.trainWhistle), intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 2, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 5, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 8, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 1, restTime: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 20, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemYellow, totalTime: 0)

        rout.append(newRout1)
        rout.append(newRout2)
        rout.append(rout3)

        rout.append(newRout5)
        rout.append(newRout6)
        for (j, aRout) in rout.enumerated() {
            rout[j].totalTime = routineTotalTime().calctotalRoutineTime(routArrayPlayer: routineTotalTime().buildArray(rout: aRout))
        }

    }


    // MARK: - Table view data source
    @objc func settingClicked(){
        print("settingClicked")
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
        let navController = UINavigationController(rootViewController: myVC)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }

    @objc func addRoutineClick(){
        print("addRoutineClick")
        //let storyboard = UIStoryboard(name: "RoutineEditorView", bundle: nil)
        //let myVC = storyboard.instantiateViewController(withIdentifier: "RoutineEditorView")
//        let myVC = RoutineEditorController()
//        myVC.title = "Add Routine"
//        self.present(myVC, animated: true, completion: nil)
//        //let navController = UINavigationController(rootViewController: myVC)
//
//        //self.navigationController?.present(navController, animated: true, completion: nil)
        if let viewController = UIStoryboard(name: "RoutineEditorView", bundle: nil).instantiateViewController(withIdentifier: "RoutineEditorView") as? RoutineEditorController {
            viewController.title = "Add Routine"
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }

    }
    @objc func addEditButton(){

        self.tableView.setEditing(self.isEditingBool, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Change `2.0` to the desired number of seconds. // Code you want to be delayed }
            self.tableView.reloadData()
            if self.isEditingBool {
                self.addEditClick = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.addEditButton))
                self.navigationItem.setRightBarButtonItems([self.addEditClick], animated: true)
            }
            else {
                self.addEditClick = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.addEditButton))
                self.navigationItem.setRightBarButtonItems([self.addRoutineButton, self.addEditClick], animated: true)
            }
            self.isEditingBool.toggle()
        }
        print("addEditButton")

    }
}

extension RoutinesController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rout.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let routine = rout[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell") as! RoutineCell
        cell.setLabels(rout: routine, edit: !self.isEditingBool)
        cell.timeLabel.text =
            globals().timeString(time: TimeInterval(rout[indexPath.row].totalTime)) 
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.rout[sourceIndexPath.row]
        rout.remove(at: sourceIndexPath.row)
        rout.insert(movedObject, at: destinationIndexPath.row)

    }
    

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")

        rout.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // print("section: \(indexPath.section)")
        // print("row: \(indexPath.row)")
        if let viewController = UIStoryboard(name: "PlayerView", bundle: nil).instantiateViewController(withIdentifier: "PlayerView") as? PlayerController {
            
            viewController.rout = rout[indexPath.row]
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
}

extension RoutinesController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update data model
        let movedObject = self.rout[sourceIndexPath.row]
        rout.remove(at: sourceIndexPath.row)
        rout.insert(movedObject, at: destinationIndexPath.row)
    }
}
