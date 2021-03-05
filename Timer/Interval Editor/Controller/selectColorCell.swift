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
        self.colorCircle.image = UIImage(systemName: "circle.fill")
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.makeDashedBorder()
        // Configure the view for the selected state
    }

    func makeDashedBorder()  {
        
        colorCircle.layer.borderWidth = 2
        colorCircle.layer.borderColor = globals().textColor(bgColor: .systemBackground).cgColor
        colorCircle.layer.cornerRadius = colorCircle.frame.width / 2
    }
    
}
