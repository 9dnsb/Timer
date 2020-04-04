//
//  Globals.swift
//  Timer
//
//  Created by David Blatt on 3/22/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit

public class globals  {

    func setAllArrays(rout: Routine) -> [Int] {

        return [0]
    }

    func timeString(time:TimeInterval) -> String {

        let minutes = Int(time) / 60
        let seconds = Int(time)  % 3600 % 60
        return String(format: "%02i:%02i ", minutes, seconds)
    }

    func secondsToHoursMinutesSeconds (seconds : Int) -> (Int, Int, Int) {
      return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }

    func keyboardClick(view: UIView) {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        tap.cancelsTouchesInView = false
    }

    func animationTableChange(tableView: UITableView) {
        UIView.transition(with: tableView,
        duration: 0.2,
        options: .transitionCrossDissolve,
        animations: { tableView.reloadData() })
    }


}
