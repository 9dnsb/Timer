//
//  basicLabelCell.swift
//  Timer
//
//  Created by David Blatt on 4/1/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit

class basicLabelCell: UITableViewCell {
    @IBOutlet weak var labelLeft: UILabel!
    
    @IBOutlet weak var textInput: UITextField!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }
}
