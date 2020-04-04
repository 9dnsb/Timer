//
//  switchCell.swift
//  Timer
//
//  Created by David Blatt on 3/29/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit

class switchCell: UITableViewCell {

    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchSwitch: UISwitch!
    
    @IBAction func switchDetected(_ sender: Any) {
        print("swtch")
    }
}
