//
//  selectColorCell.swift
//  Timer
//
//  Created by David Blatt on 4/1/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit

class selectColorCell: UITableViewCell {

    @IBOutlet weak var colorLabel: UILabel!
    @IBOutlet weak var colorCircle: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        if #available(iOS 13.0, *) {
            self.colorCircle.image = UIImage(systemName: "circle.fill")
        } else {
            self.colorCircle.image = UIImage(named: "circle.fill")
        colorCircle.image = colorCircle.image?.withRenderingMode(.alwaysTemplate)


        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.makeDashedBorder()
        // Configure the view for the selected state
    }

    func makeDashedBorder()  {
        
        colorCircle.layer.borderWidth = 2
        if #available(iOS 13.0, *) {
            colorCircle.layer.borderColor = globals().textColor(bgColor: .systemBackground).cgColor
        } else {
            colorCircle.layer.borderColor = UIColor.black.cgColor
        }
        colorCircle.layer.cornerRadius = colorCircle.frame.width / 2
    }
    
}
