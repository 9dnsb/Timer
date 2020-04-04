//
//  selectIntervalCell.swift
//  Timer
//
//  Created by David Blatt on 3/28/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit

class selectIntervalCell: UITableViewCell {
    @IBOutlet weak var theImage: UIImageView!
    @IBOutlet weak var intervalName: UILabel!
    @IBOutlet weak var totalTime: UILabel!
    @IBOutlet weak var labelLeftContrain: NSLayoutConstraint!
    
    func setImageColor(color: UIColor) {
        theImage.tintColor = color
    }
    func setIntervalName(intervalName: String) {
        self.intervalName.text = intervalName
    }
    func setLightLabel(lightLabel: String) {
        self.totalTime.text = lightLabel
    }
}

extension UIImage {
    class func circle(diameter: CGFloat, color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(CGSize(width: diameter, height: diameter), false, 0)
        let ctx = UIGraphicsGetCurrentContext()!
        ctx.saveGState()

        let rect = CGRect(x: 0, y: 0, width: diameter, height: diameter)
        ctx.setFillColor(color.cgColor)
        ctx.fillEllipse(in: rect)

        ctx.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()

        return img
    }
}
