//
//  SubscribeGlobals.swift
//  Timer
//
//  Created by David Blatt on 4/17/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import SwiftyStoreKit
import UIKit


public class SubscribeGlobal {
    let appBundleId = "db.timer.main"
    var setDel : settingDelegate? = nil

    func verifySubscriptions(_ purchases: Set<RegisteredPurchase>) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch result {

            case .success(let receipt):
                let productIds = Set(purchases.map { self.appBundleId + "." + $0.rawValue })
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                (self.alertForVerifySubscriptions(purchaseResult, productIds: productIds))
            case .error:
                //(self.alertForVerifyReceipt(result))
                print(result)
            }
        }
    }

    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {

        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "6685ee37760d411f8a996c5ab5a82334")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }

    func alertForVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> UIAlertController {

        switch result {
        case .purchased(let expiryDate, let items):
            //print("\(productIds) is valid until \(expiryDate)\n\(items)\n")
            UserDefaults.standard.set(true, forKey: subscription.isSubsribed.rawValue)
            //print("setDel")
            setDel?.changeValue(darkMode: true)
            return alertWithTitle("Product is purchased", message: "Product is valid until \(expiryDate)")
        case .expired(let expiryDate, let items):
            UserDefaults.standard.set(false, forKey: subscription.isSubsribed.rawValue)
            //print("\(productIds) is expired since \(expiryDate)\n\(items)\n")
            //print("setDel")
            setDel?.changeValue(darkMode: false)
            return alertWithTitle("Product expired", message: "Product is expired since \(expiryDate)")
        case .notPurchased:
            UserDefaults.standard.set(false, forKey: subscription.isSubsribed.rawValue)
            //print("\(productIds) has never been purchased")
            //print("setDel")
            setDel?.changeValue(darkMode: false)
            return alertWithTitle("Not purchased", message: "This product has never been purchased")
        }
    }

    func alertForVerifyReceipt(_ result: VerifyReceiptResult) -> UIAlertController {

        switch result {
        case .success(let receipt):
            print("Verify receipt Success: \(receipt)")
            return alertWithTitle("Receipt verified", message: "Receipt verified remotely")
        case .error(let error):
            print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return alertWithTitle("Receipt verification", message: "No receipt data. Try again.")
            case .networkError(let error):
                return alertWithTitle("Receipt verification", message: "Network error while verifying receipt: \(error)")
            default:
                return alertWithTitle("Receipt verification", message: "Receipt verification failed: \(error)")
            }
        }
    }


    func alertWithTitle(_ title: String, message: String) -> UIAlertController {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
    }



    func getInfo(_ purchase: RegisteredPurchase) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([appBundleId + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()

            (self.alertForProductRetrievalInfo(result))
        }
    }

    func alertForProductRetrievalInfo(_ result: RetrieveResults) {

        if let product = result.retrievedProducts.first {
            let priceString = product.localizedPrice!
            //print(priceString)

            //return priceString
        } else if let invalidProductId = result.invalidProductIDs.first {
            //return invalidProductId
        } else {
            let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
            //return errorString
        }
    }

    func purchase(_ purchase: RegisteredPurchase, atomically: Bool) {

        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.purchaseProduct(appBundleId + "." + purchase.rawValue, atomically: atomically) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()

            if case .success(let purchase) = result {
                let downloads = purchase.transaction.downloads
                if !downloads.isEmpty {
                    SwiftyStoreKit.start(downloads)
                }
                // Deliver content from server, then:
                if purchase.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(purchase.transaction)
                }
            }
            if let alert = self.alertForPurchaseResult(result) {
                print(alert)
            }
        }
    }

    func alertForPurchaseResult(_ result: PurchaseResult) -> UIAlertController? {
        switch result {
        case .success(let purchase):
            print("Purchase Success: \(purchase.productId)")
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
}
