//
//  segmentController.swift
//  Timer
//
//  Created by David Blatt on 4/4/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import BetterSegmentedControl

class segmentController: UITableViewCell {

    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet  var segment: BetterSegmentedControl!
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        segment = BetterSegmentedControl(
//        frame: CGRect(x: 0, y: 0, width: 300, height: 44),
//        segments: LabelSegment.segments(withTitles: ["Low", "High"],
//        normalFont: UIFont(name: "HelveticaNeue-Light", size: 14.0)!,
//        normalTextColor: .lightGray,
//        selectedFont: UIFont(name: "HelveticaNeue-Bold", size: 14.0)!,
//        selectedTextColor: .white),
//        index: 1,
//        options: [.backgroundColor(.darkGray),
//                  .indicatorViewBackgroundColor(.blue)])
//        // Initialization code
//    }
}
