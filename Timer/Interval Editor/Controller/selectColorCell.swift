//
//  selectColorCell.swift
//  Timer
//
//  Created by David Blatt on 4/1/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit

class selectColorCell: UITableViewCell {

    @IBOutlet weak var colorCircle: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // self.makeDashedBorder()
        // Configure the view for the selected state
    }

    func makeDashedBorder()  {
        
        let yourViewBorder = CAShapeLayer()
        yourViewBorder.strokeColor = UIColor.black.cgColor
        yourViewBorder.lineDashPattern = [2, 2]
        yourViewBorder.frame = colorCircle.bounds
        yourViewBorder.fillColor = nil
        yourViewBorder.path = UIBezierPath(rect: colorCircle.bounds).cgPath
        colorCircle.layer.addSublayer(yourViewBorder)
    }
    
}
