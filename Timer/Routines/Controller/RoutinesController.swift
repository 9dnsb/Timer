//
//  TableViewControllerMain.swift
//  Timer
//
//  Created by David Blatt on 3/18/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SwiftReorder

class RoutinesController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    
    let cellSpacingHeight: CGFloat = 20
    var isEditingBool = true
    var addEditClick: UIBarButtonItem = UIBarButtonItem()
    var addRoutineButton: UIBarButtonItem = UIBarButtonItem()
    
    var rout = [Routine]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackgroundandNavigationBar()
        self.setupTable()
        self.tableView.reorder.delegate = self as TableViewReorderDelegate
    }

    func setBackgroundandNavigationBar() {
        self.tableView.backgroundColor = .systemGroupedBackground
        let settingButton = UIButton(type: .custom)
        settingButton.setImage(UIImage(named: "settingIcon"), for: .normal)
        // settingButton.tintColor = .systemGray
        settingButton.addTarget(self, action: #selector(settingClicked), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: settingButton)
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
        addRoutineButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoutineClick))
        addEditClick = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addEditButton))
        self.navigationItem.setRightBarButtonItems([addRoutineButton, addEditClick], animated: true)
    }

    func setupTable() {
        let newRout1 = Routine(name: "Test1", type: "Simple", warmup: 0, intervals: [HighLowInterval(firstIntervalHigh: true, numSets: 2, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 5, intervalColor: .systemRed, sound: ""), lowInterval: IntervalIntensity(duration: 6, intervalColor: .systemGreen, sound: ""))], numCycles: 1, restTime: 0, coolDown: 0, routineColor: .systemRed, totalTime: 0)
        let newRout2 = Routine(name: "Elbow", type: "Simple", warmup: 0, intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 1, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 60, intervalColor: .systemRed, sound: ""), lowInterval: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: ""))], numCycles: 1, restTime: 0, coolDown: 0, routineColor: .systemRed, totalTime: 0)

        rout.append(newRout1)
        rout.append(newRout2)
        for (j, aRout) in rout.enumerated() {
            rout[j].totalTime = routineTotalTime().calctotalRoutineTime(rout: aRout)
        }

    }


    // MARK: - Table view data source
    @objc func settingClicked(){
        print("settingClicked")
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
        let navController = UINavigationController(rootViewController: myVC)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }

    @objc func addRoutineClick(){
        print("addRoutineClick")
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
        let navController = UINavigationController(rootViewController: myVC)
        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    @objc func addEditButton(){

        self.tableView.setEditing(self.isEditingBool, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { // Change `2.0` to the desired number of seconds. // Code you want to be delayed }
            self.tableView.reloadData()
            if self.isEditingBool {
                self.addEditClick = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.addEditButton))
                self.navigationItem.setRightBarButtonItems([self.addEditClick], animated: true)
            }
            else {
                self.addEditClick = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.addEditButton))
                self.navigationItem.setRightBarButtonItems([self.addRoutineButton, self.addEditClick], animated: true)
            }
            self.isEditingBool.toggle()
        }
        print("addEditButton")

    }
}

extension RoutinesController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rout.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
            return spacer
        }
        let routine = rout[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell") as! RoutineCell
        cell.setLabels(rout: routine, edit: !self.isEditingBool)

        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.rout[sourceIndexPath.row]
        rout.remove(at: sourceIndexPath.row)
        rout.insert(movedObject, at: destinationIndexPath.row)

    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      if editingStyle == .delete {
        print("Deleted")

        rout.remove(at: indexPath.row)
        self.tableView.deleteRows(at: [indexPath], with: .automatic)
      }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // print("section: \(indexPath.section)")
        // print("row: \(indexPath.row)")
        if let viewController = UIStoryboard(name: "PlayerView", bundle: nil).instantiateViewController(withIdentifier: "PlayerView") as? PlayerController {
            viewController.rout = rout[indexPath.row]
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
}

extension RoutinesController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Update data model
        let movedObject = self.rout[sourceIndexPath.row]
        rout.remove(at: sourceIndexPath.row)
        rout.insert(movedObject, at: destinationIndexPath.row)
    }
}
