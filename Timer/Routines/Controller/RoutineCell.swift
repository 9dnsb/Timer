//
//  RoutineCell.swift
//  Timer
//
//  Created by David Blatt on 3/20/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit

class RoutineCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var smallView: UIView!


    func setLabels(rout: Routine, edit: Bool) {
        titleLabel.text = rout.name
        titleLabel.textColor = rout.routineColor
        //        timeLabel.text = routineTotalTime().calctotalRoutineTimeString(rout: rout)

    }

    @objc func myItemAction(_ sender:AnyObject?){
      print("Did something new!")
    }

    @objc func copy11(_ sender:AnyObject?){
      print("Did something new 2!")
    }

    
}
