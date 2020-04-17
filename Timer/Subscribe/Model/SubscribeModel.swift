//
//  SubscribeModel.swift
//  Timer
//
//  Created by David Blatt on 4/16/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation

enum subscription: String {
    case isSubsribed
}

enum RegisteredPurchase: String {

    case purchase1
    case purchase2
    case nonConsumablePurchase
    case consumablePurchase
    case nonRenewingPurchase
    case weekly
    case monthly
    case sixMonth
    case yearly
}
