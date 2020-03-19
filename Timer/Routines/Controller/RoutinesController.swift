//
//  TableViewControllerMain.swift
//  Timer
//
//  Created by David Blatt on 3/18/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit

class RoutinesController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let btn1 = UIButton(type: .custom)
        btn1.setImage(UIImage(named: "baseline_settings_black_48pt"), for: .normal)
        btn1.frame = CGRect(x: 0, y: 0, width: 5, height: 5)
        btn1.addTarget(self, action: #selector(logoutUser), for: .touchUpInside)
        let item1 = UIBarButtonItem(customView: btn1)
        self.navigationItem.setLeftBarButtonItems([item1], animated: true)
        self.navigationItem.leftBarButtonItem?.image = UIImage(named: "base")
        let camera = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: Selector(("btnOpenCamera")))
        self.navigationItem.rightBarButtonItem = camera

    }

    // MARK: - Table view data source
    @objc func logoutUser(){
             print("clicked")
            let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
            let myVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
            let navController = UINavigationController(rootViewController: myVC)

            self.navigationController?.present(navController, animated: true, completion: nil)
        }

    @objc func btnOpenCamera(){
             print("clicked")
        let storyboard = UIStoryboard(name: "SettingView", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "SettingView")
        let navController = UINavigationController(rootViewController: myVC)
            self.navigationController?.present(navController, animated: true, completion: nil)
        }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
