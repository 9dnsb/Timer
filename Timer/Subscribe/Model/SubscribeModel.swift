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

struct subSendData {
    var isSubscribed : Bool = false
    var expireDate = Date(timeIntervalSinceReferenceDate: -123456789.0)
    var isTrial : Bool = false
    var runSetting : Bool = false
    var runSetting2 : Bool = false
}
