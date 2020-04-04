//
//  inputTextCell.swift
//  Timer
//
//  Created by David Blatt on 3/28/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
var rout: Routine?
class inputTextCell: UITableViewCell {
    @IBOutlet weak var inputString: UITextField!
    

    func returnInputString() -> String {
        return self.inputString.text!

}

    @IBAction func done(_ sender: UITextField) {
        sender.resignFirstResponder()
    }

}

