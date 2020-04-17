//
//  SubscribeCellVC.swift
//  Timer
//
//  Created by David Blatt on 4/17/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import PKHUD

class SubscribeCellVC: UITableViewCell {

    @IBOutlet weak var subName: UILabel!
    @IBOutlet weak var subTrial: UILabel!
    @IBOutlet weak var subPrice: UILabel!
    //var subType : RegisteredPurchase! = nil
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //self.getInfo(subType)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func unitName(unitRawValue:UInt) -> String {
        switch unitRawValue {
        case 0: return "days"
        case 1: return "Week"
        case 2: return "Month"
        case 3: return "years"
        default: return ""
        }
    }

    func getInfo(_ purchase: RegisteredPurchase) {
        HUD.show(.progress)
        NetworkActivityIndicatorManager.networkOperationStarted()
        SwiftyStoreKit.retrieveProductsInfo([constants.appBundle + "." + purchase.rawValue]) { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            HUD.hide(afterDelay: 0.5)
            if let product = result.retrievedProducts.first {
                if #available(iOS 11.2, *) {
                  if let period = product.introductoryPrice?.subscriptionPeriod {
                    print("Start your \(period.numberOfUnits) \(self.unitName(unitRawValue: period.unit.rawValue)) Free trial")
                    self.subTrial.text = ("\(period.numberOfUnits) \(self.unitName(unitRawValue: period.unit.rawValue)) Free Trial")
                  }
                } else {
                  // Fallback on earlier versions
                  // Get it from your server via API
                }
                let priceString = product.localizedPrice!
                self.subPrice.text = priceString
                //print(priceString)
                //return priceString
            } else if let invalidProductId = result.invalidProductIDs.first {
                //return invalidProductId
            } else {
                let errorString = result.error?.localizedDescription ?? "Unknown error. Please contact support"
                //return errorString
            }
        }
    }

}
