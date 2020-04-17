//
//  SubscribeViewController.swift
//  Timer
//
//  Created by David Blatt on 4/16/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import PKHUD

class SubscribeViewController: UIViewController {
    let appBundleId = "db.timer.main"
    var weeklyPrice = ""
    let purchaseStartCell = 1
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib(nibName: "textCellView", bundle: nil), forCellReuseIdentifier: "textCellView")
        tableView.register(UINib(nibName: "SubscribeCellView", bundle: nil), forCellReuseIdentifier: "SubscribeCellView")
        tableView.register(UINib(nibName: "basicRightLabelCell", bundle: nil), forCellReuseIdentifier: "basicRightLabelCell")
        self.isModalInPresentation = true

        tableView.rowHeight = UITableView.automaticDimension

        // Do any additional setup after loading the view.
    }
    func showAlert(_ alert: UIAlertController) {
        guard self.presentedViewController != nil else {
            self.present(alert, animated: true, completion: nil)
            return
        }
    }

    func alertWithTitle(_ title: String, message: String) -> UIAlertController {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }

    func purchase(_ purchase: RegisteredPurchase, atomically: Bool) {

        NetworkActivityIndicatorManager.networkOperationStarted()
        HUD.hide(afterDelay: 1.0)
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + purchase.rawValue, atomically: atomically) { result in
            //HUD.show(.progress)
            NetworkActivityIndicatorManager.networkOperationFinished()

            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {

                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    //HUD.hide(afterDelay: 1.0)
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                self.showAlert(alert)
            }
        }
    }

    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
            self.dismiss(animated: true, completion: nil)
            return nil
        case .error(let error):
            print("Purchase Failed: \(error)")
            switch error.code {
            case .unknown: return alertWithTitle("Purchase failed", message: error.localizedDescription)
            case .clientInvalid: // client is not allowed to issue the request, etc.
                return alertWithTitle("Purchase failed", message: "Not allowed to make the payment")
            case .paymentCancelled: // user cancelled the request, etc.
                return nil
            case .paymentInvalid: // purchase identifier was invalid, etc.
                return alertWithTitle("Purchase failed", message: "The purchase identifier was invalid")
            case .paymentNotAllowed: // this device is not allowed to make the payment
                return alertWithTitle("Purchase failed", message: "The device is not allowed to make the payment")
            case .storeProductNotAvailable: // Product is not available in the current storefront
                return alertWithTitle("Purchase failed", message: "The product is not available in the current storefront")
            case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
                return alertWithTitle("Purchase failed", message: "Access to cloud service information is not allowed")
            case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
                return alertWithTitle("Purchase failed", message: "Could not connect to the network")
            case .cloudServiceRevoked: // user has revoked permission to use this cloud service
                return alertWithTitle("Purchase failed", message: "Cloud service was revoked")
            default:
                return alertWithTitle("Purchase failed", message: (error as NSError).localizedDescription)
            }
        }
    }

    func restorePurchase() {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            HUD.hide(afterDelay: 1.0)
            NetworkActivityIndicatorManager.networkOperationFinished()

            for purchase in results.restoredPurchases {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                } else if purchase.needsFinishTransaction {
                    // Deliver content from server, then:
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            self.showAlert(self.alertForRestorePurchases(results))
        }
    }

    func alertForRestorePurchases(_ results: RestoreResults) -> UIAlertController {

        if results.restoreFailedPurchases.count > 0 {
            print("Restore Failed: \(results.restoreFailedPurchases)")
            return alertWithTitle("Restore failed", message: "Unknown error. Please contact support")
        } else if results.restoredPurchases.count > 0 {
            print("Restore Success: \(results.restoredPurchases)")
            return alertWithTitle("Purchases Restored", message: "All purchases have been restored")
        } else {
            print("Nothing to Restore")
            return alertWithTitle("Nothing to restore", message: "No previous purchases were found")
        }
    }

}

extension SubscribeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        6
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCellView") as! textCellVCTableViewCell
            cell.selectionStyle = .none
            return cell
        }
        if indexPath.row == purchaseStartCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeCellView") as! SubscribeCellVC
            cell.subName.text = "Weekly Subscription"
            //cell.subTrial.text = "1 Week Free Trial"
            cell.getInfo(.weekly)
            return cell
        }
        if indexPath.row == purchaseStartCell + 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeCellView") as! SubscribeCellVC
            cell.subName.text = "Monthly Subscription"
            //cell.subTrial.text = "1 Month Free Trial"
            cell.getInfo(.monthly)
            //cell.subType = RegisteredPurchase.monthly
            return cell
        }
        if indexPath.row == purchaseStartCell + 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "SubscribeCellView") as! SubscribeCellVC
            cell.subName.text = "Yearly Subscription"
            //cell.subTrial.text = "1 Month Free Trial"
            cell.getInfo(.yearly)
            //cell.subType = RegisteredPurchase.yearly
            return cell
        }
        if indexPath.row == purchaseStartCell + 4 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "basicRightLabelCell") as! basicRightLabelCell
            cell.leftLabel.text = "Restore Previous Purchases"
            cell.rightLabel.isHidden = true
            cell.leftLabel.textColor = .systemBlue
            return cell
        }
        if indexPath.row == purchaseStartCell + 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "textCellView") as! textCellVCTableViewCell
            cell.selectionStyle = .none
            cell.theLabel.text = "Payment will be charged to your Apple ID account at the confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period. Your account will be charged for the renewal within 24 hours prior to the end of the current period.\n\nYou can manage and cancel your subscriptions by going to your account setting in the App Store after the purchase"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "textCellView") as! textCellVCTableViewCell
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }




    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if indexPath.row == purchaseStartCell {
            HUD.show(.progress)
            purchase(.weekly, atomically: true)
        }
        if indexPath.row == purchaseStartCell + 1 {
            HUD.show(.progress)
            purchase(.monthly, atomically: true)
        }
        if indexPath.row == purchaseStartCell + 2 {
            HUD.show(.progress)
            purchase(.yearly, atomically: true)
        }
        if indexPath.row == purchaseStartCell + 4 {
            HUD.show(.progress)
            self.restorePurchase()
        }

    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == purchaseStartCell {
//            return 88
//        }
//        return 44;//Choose your custom row height
//    }
}

extension SubscribeViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
    }
}
