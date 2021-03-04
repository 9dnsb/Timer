//
//  TableViewControllerMain.swift
//  Timer
//
//  Created by David Blatt on 3/18/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import SwiftReorder
import SwiftyStoreKit
import CoreData
import CoreStore
import PKHUD
import SwiftRater

protocol settingDelegate {
    func changeValue(sub: subSendData)
}
protocol subscribeDelegate {
    func runAfterSubscribe()
}
let check = DarkModeEnable()

class RoutinesController: UIViewController, settingDelegate, subscribeDelegate {
    func runAfterSubscribe() {
        self.verifySub()
        print("runAfterSubscribe")

    }

    func changeValue(sub: subSendData) {
        //print("changeVal")
        //print(UserDefaults.standard.bool(forKey: subscription.isSubsribed.rawValue))
        if !sub.isSubscribed {
//            let storyboard = UIStoryboard(name: "SubscribeView", bundle: nil)
//            let myVC = storyboard.instantiateViewController(withIdentifier: "SubscribeView") as! SubscribeViewController
//            myVC.title = "Subscription Settings"
//            myVC.subDel = self
//            let navController = UINavigationController(rootViewController: myVC)
//            self.navigationController?.present(navController, animated: true, completion: nil)
        
        }
        else {
            if sub.runSetting{
                //self.settingClickRun()
            }
        }
        //print("sub.expireDate", sub.expireDate)
        subData = sub

        //self.overrideUserInterfaceStyle = check.checkForDarkMode()
        //print(sub)
    }

    @IBOutlet weak var tableView: UITableView!
    
    var dataStack = DataStack(
        xcodeModelName: "Timer",
        migrationChain: ["Timer", "Timer 3"]
    )
    let cellSpacingHeight: CGFloat = 20
    var isEditingBool = true
    var addEditClick: UIBarButtonItem = UIBarButtonItem()
    var addRoutineButton: UIBarButtonItem = UIBarButtonItem()
    var settingButton2: UIBarButtonItem = UIBarButtonItem()
    var subData = subSendData()
    var rout = [Routine]()
    @IBOutlet weak var topView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        SwiftRater.check()

        //addCustomMenuItems()
        self.setBackgroundandNavigationBar()
        self.setupTable()
//        self.tableView.reorder.delegate = self as TableViewReorderDelegate
        do {
//            try dataStack.addStorageAndWait(SQLiteStore())
            try dataStack.addStorageAndWait(
                SQLiteStore(
                    fileURL: SQLiteStore().fileURL,
                    localStorageOptions: .allowSynchronousLightweightMigration
                )
            )
            
        }


        catch { // ...
            print("error")
        }

    }



    private func addCustomMenuItems() {
      let newMenuItem = UIMenuItem(title: "Copy", action: MenuAction.Custom.selector())

      let menuController = UIMenuController.shared
      var newItems = menuController.menuItems ?? [UIMenuItem]()
      newItems.append(newMenuItem)
      menuController.menuItems = newItems
    }
    

    func verifySub() {
        let sg = SubscribeGlobal()
        sg.setDel = self
        sg.verifySubscriptions([.weekly, .monthly, .yearly])
    }

    func addDefaultRout() {
        self.rout.append(globals().returnDefaultRout(setTitle: true))
        self.save3()
    }
    
    func save3() {
        print("here5")
        let dataStack = self.dataStack
        dataStack.perform(
            asynchronous: { (transaction) -> Bool in
                let person = transaction.create(Into<CDRoutine>())
                self.doSaveAction(person: person, transaction: transaction)
                return transaction.hasChanges
        },
            completion: { (result) -> Void in
                switch result {
                case .success(let hasChanges):
                    print("success! Has changes? \(hasChanges)")
                    
                case .failure(let error): print(error)
                }
        }
        )
    }
    
    func setHighLow(highLow: CDHighLowInterval, j: Int) {
        highLow.cdfirstIntervalHigh = self.rout[0].intervals[j].firstIntervalHigh
        highLow.cdHighLowIntervalColor = self.rout[0].intervals[j].HighLowIntervalColor.hexString(.d6)
        highLow.cdintervalName = self.rout[0].intervals[j].intervalName
        highLow.cdnumSets = Int32(self.rout[0].intervals[j].numSets)
        highLow.cdIntervalIndex = Int32(j)
    }
    
    func doSaveAction(person: CDRoutine, transaction: AsynchronousDataTransaction, isEdit: Bool = false) {
        person.cdUUID = UUID().uuidString
        self.rout[0].routineID = person.cdUUID
        person.cdName = self.rout[0].name
        person.cdNumCycles = Int32(self.rout[0].numCycles)
        person.cdRoutineColor = self.rout[0].routineColor.hexString(.d6)
        person.cdRoutineIndex = Int32(self.rout[0].routineIndex)
        person.cdIntervalVoiceEnable = self.rout[0].enableIntervalVoice
        for (j, _) in self.rout[0].intervals.enumerated() {
            let highLow = transaction.create(Into<CDHighLowInterval>())
            self.setHighLow(highLow: highLow, j: j)
            highLow.lowInterval = self.addHighLowCD(transaction: transaction, interval: self.rout[0].intervals[j].lowInterval)
            highLow.highInterval = self.addHighLowCD(transaction: transaction, interval: self.rout[0].intervals[j].highInterval)
            person.addToCDHighLowInterval(highLow)
            person.warmup = self.addHighLowCD(transaction: transaction, interval: self.rout[0].warmup)
            person.rest = self.addHighLowCD(transaction: transaction, interval: self.rout[0].restTime)
            person.coolDown = self.addHighLowCD(transaction: transaction, interval: self.rout[0].coolDown)
            person.restInterval = self.addHighLowCD(transaction: transaction, interval: self.rout[0].intervalRestTime)
        }
    }
    
   
    
    func addHighLowCD(transaction: AsynchronousDataTransaction, interval: IntervalIntensity, isEdit: Bool = false) -> CDIntervalIntensity {
        let cd = transaction.create(Into<CDIntervalIntensity>())
        cd.cdduration = Int32(interval.duration)
        cd.cdintervalColor = interval.intervalColor.hexString(.d6)
        cd.cdsound = interval.sound.rawValue
        return cd
        
    }
    
    func loadCoreData2() {
        
        do {
            self.rout.removeAll()
            let objects = try self.dataStack.fetchAll(From<CDRoutine> ().orderBy(.ascending(\.cdRoutineIndex)))
            if objects.count == 0 {

                self.addDefaultRout()

            }
            else {
                //print("count", objects.count)
                for (_, i) in objects.enumerated() {
                    var rout: Routine = globals().returnDefaultRout()
                    //print("i", i)
                    //rout.objectID = i
                    print("i.cdName")
                    print(i.cdName!)
                    rout.name = i.cdName!
                    rout.numCycles = Int(i.cdNumCycles)
                    rout.routineColor =  hexStringToUIColor(hex: i.cdRoutineColor!)
                    //print(i.cdRoutineColor!)
                    //print(rout.routineColor)
                    rout.warmup = self.setIntIntesity(cdInt: i.warmup!)
                    rout.restTime = self.setIntIntesity(cdInt: i.rest!)
                    rout.coolDown = self.setIntIntesity(cdInt: i.coolDown!)
                    //print("i.cdUUID")
                    //print(i.cdUUID!)
                    rout.routineID = i.cdUUID!
                    if rout.routineID == "" {
                        rout.routineID = UUID().uuidString
                    }
                    rout.routineIndex = Int(i.cdRoutineIndex)
                    rout.intervalRestTime = self.setIntIntesity(cdInt: i.restInterval!)
                    rout.enableIntervalVoice = i.cdIntervalVoiceEnable
                    for (j, elem) in i.cDHighLowInterval!.enumerated() {
                        //print("j", j)
                        let elem = elem as! CDHighLowInterval
                        if !rout.intervals.indices.contains(j) {
                            var appIntLow = globals().returnDefaultRout().intervals[0]
                            appIntLow.firstIntervalHigh = false
                            appIntLow.intervalName = "Interval Cycle #1"
                            rout.intervals.append(appIntLow)
//                            rout.intervals.append(HighLowInterval(firstIntervalHigh: false, numSets: 5, intervalName: "Interval Cycle #1", highInterval: IntervalIntensity(duration: 60, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed))
                        }
                        rout.intervals[j].firstIntervalHigh = elem.cdfirstIntervalHigh
                        rout.intervals[j].HighLowIntervalColor = hexStringToUIColor(hex: elem.cdHighLowIntervalColor!)
                        rout.intervals[j].intervalName = elem.cdintervalName!
                        rout.intervals[j].highLowId = elem.cdHighLowId
                        if rout.intervals[j].highLowId == nil {
                            rout.intervals[j].highLowId = ""
                        }
                        //print(Int(elem.cdnumSets))
                        rout.intervals[j].numSets = Int(elem.cdnumSets)
                        rout.intervals[j].lowInterval = self.setIntIntesity(cdInt: elem.lowInterval!)
                        rout.intervals[j].highInterval = self.setIntIntesity(cdInt: elem.highInterval!)

                    }
                    rout.totalTime = routineTotalTime().calctotalRoutineTime(routArrayPlayer: routineTotalTime().buildArray(rout: rout))
                    self.rout.append(rout)
                }
            }
            self.tableView.reloadData()
            
        }
        catch { // ...
            print("error")
        }
    }
    
    func setIntIntesity(cdInt: CDIntervalIntensity) -> IntervalIntensity {
        let x = IntervalIntensity(duration: Int(cdInt.cdduration), intervalColor: hexStringToUIColor(hex: cdInt.cdintervalColor!), sound: sounds(rawValue: cdInt.cdsound!)!)
        
        return x
    }
    
    func deleteCoreData() {
        dataStack.perform(
            asynchronous: { (transaction) -> Void in
                try transaction.deleteAll(
                    From<CDRoutine>()
                )
        },
            completion: { _ in }
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        //self.verifySub()
//        SwiftyStoreKit.fetchReceipt(forceRefresh: false) { result in
//            switch result {
//            case .success(let receiptData):
//                let encryptedReceipt = receiptData.base64EncodedString(options: [])
//                print("Fetch receipt success:\n\(encryptedReceipt)")
//            case .error(let error):
//                print("Fetch receipt failed: \(error)")
//            }
//        }
        //self.deleteCoreData()
        self.loadCoreData2()
        //tableView.reloadData()
        setBackgroundandNavigationBar()
        self.addSharedRout()

    }

    @objc func applicationDidBecomeActive(notification: NSNotification) {
        self.addSharedRout()
    }

    func addSharedRout() {
        let x = self.loadFriends()
        if !x.isEmpty {
            var x2 = x[0]
            x2.routineID = UUID().uuidString
            x2.routineIndex = self.rout.count + 1
            rout.append(x2)
            self.tableView.reloadData()
            self.reorderRouts()
            HUD.flash(.labeledSuccess(title: "Success", subtitle: "'\(x2.name)' added"), delay: 3.0)
        }
        self.removeImage()
    }

    func removeImage() {
        let fileName:String = shareString.JSONFile.rawValue
        let fileManager = FileManager.default
        guard let groupURL = fileManager.containerURL(forSecurityApplicationGroupIdentifier: shareString.groupName.rawValue) else {
            return
        }
        let storagePathUrl = groupURL.appendingPathComponent(fileName, isDirectory: false)
        let storagePath = storagePathUrl.path

        do {
           if fileManager.fileExists(atPath: storagePath) {
               try fileManager.removeItem(atPath: storagePath)
            }
        } catch let error as NSError {
            print(error.debugDescription)
        }
    }
    
    func loadFriends() -> [Routine] {
            let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: shareString.groupName.rawValue)
            guard let archiveURL = documentsDirectory?.appendingPathComponent(shareString.JSONFile.rawValue) else { return [Routine]() }

            guard let codeData = try? Data(contentsOf: archiveURL) else { return [] }

            let decoder = JSONDecoder()

            let loadedFriends = (try? decoder.decode([Routine].self, from: codeData)) ?? [Routine]()

            return loadedFriends
        }

    public enum subs {
        case weekly(item: String = "db.timer.main.weekly")
    }

    func setRightBarItem() {
        addRoutineButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRoutineClick))
        addEditClick = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(addEditButton))
//        self.navigationItem.setRightBarButtonItems([addRoutineButton, addEditClick], animated: true)
        if rout.count > 1 {
            self.navigationItem.setRightBarButtonItems([addRoutineButton, addEditClick], animated: true)
        }
        else {
            self.navigationItem.setRightBarButtonItems([addRoutineButton], animated: true)
        }
    }
    
    func setBackgroundandNavigationBar() {
        globals().setTableViewBackground(tableView: self.tableView)
        let settingButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            settingButton.frame = CGRect(x: 0, y: 0, width: 53, height: 51)
            settingButton.setImage(UIImage(systemName: "gear"), for: .normal)
            settingButton.addTarget(self, action: #selector(settingClicked), for: .touchUpInside)
            let item1 = UIBarButtonItem(customView: settingButton)
            self.navigationItem.setLeftBarButtonItems([item1], animated: true)
        } else {
            self.settingButton2 = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(settingClicked))


            self.navigationItem.setLeftBarButtonItems([self.settingButton2], animated: true)
        }






        self.setRightBarItem()

        
    }
    
    
    
    func setupTable() {
//        let newRout1 = Routine(name: "Low Interval", type: "Simple", warmup: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 4, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 3, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 2, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 4, restTime: IntervalIntensity(duration: 10, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemRed, totalTime: 0)
//        let newInter = HighLowInterval(firstIntervalHigh: true, numSets: 4, intervalName: "Interval #2", highInterval: IntervalIntensity(duration: 4, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 3, intervalColor: .systemTeal, sound: sounds.none), HighLowIntervalColor: .systemRed)
//        let newInter2 = HighLowInterval(firstIntervalHigh: false, numSets: 3, intervalName: "Interval #3", highInterval: IntervalIntensity(duration: 7, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 5, intervalColor: .systemTeal, sound: sounds.none), HighLowIntervalColor: .systemRed)
//        let newInter3 = HighLowInterval(firstIntervalHigh: true, numSets: 3, intervalName: "Interval #3", highInterval: IntervalIntensity(duration: 7, intervalColor: .systemPink, sound: sounds.none), lowInterval: IntervalIntensity(duration: 5, intervalColor: .systemTeal, sound: sounds.none), HighLowIntervalColor: .systemRed)
//        var rout3 = newRout1
//        rout3.intervals.append(newInter)
//        rout3.intervals.append(newInter2)
//        rout3.intervals.append(newInter3)
//        rout3.intervals.append(newInter)
//        rout3.intervals.append(newInter2)
//        rout3.name = "Test #3"
//        let newRout2 = Routine(name: "Elbow", type: "Simple", warmup: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: true, numSets: 1, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 3, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 3, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 80, restTime: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemIndigo, totalTime: 0)
//        let newRout5 = Routine(name: "High Interval", type: "Simple", warmup: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), intervals: [HighLowInterval(firstIntervalHigh: true, numSets: 2, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 3, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 2, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 1, restTime: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemYellow, totalTime: 0)
//        let newRout6 = Routine(name: "Low Interval", type: "Simple", warmup: IntervalIntensity(duration: 20, intervalColor: .systemGreen, sound: sounds.trainWhistle), intervals: [HighLowInterval(firstIntervalHigh: false, numSets: 2, intervalName: "Interval #1", highInterval: IntervalIntensity(duration: 5, intervalColor: .systemRed, sound: sounds.none), lowInterval: IntervalIntensity(duration: 8, intervalColor: .systemGreen, sound: sounds.none), HighLowIntervalColor: .systemRed)], numCycles: 1, restTime: IntervalIntensity(duration: 0, intervalColor: .systemGreen, sound: sounds.none), coolDown: IntervalIntensity(duration: 20, intervalColor: .systemGreen, sound: sounds.none), routineColor: .systemYellow, totalTime: 0)
//        
//        rout.append(newRout1)
//        rout.append(newRout2)
//        rout.append(rout3)
//        
//        rout.append(newRout5)
//        rout.append(newRout6)
//        for (j, aRout) in rout.enumerated() {
//            rout[j].totalTime = routineTotalTime().calctotalRoutineTime(routArrayPlayer: routineTotalTime().buildArray(rout: aRout))
//        }
        
    }

    func settingClickRun() {
//        let storyboard = UIStoryboard(name: "FormSettingView", bundle: nil)
//        let myVC = storyboard.instantiateViewController(withIdentifier: "FormSettingView") as! FormSettingVC
//        myVC.title = "Settings"
//        myVC.settingDel = self
//
//        myVC.subData = self.subData
//        myVC.routineContr = self
//        let navController = UINavigationController(rootViewController: myVC)
//        self.navigationController?.present(navController, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "FormSettingView", bundle: nil)
        let myVC = storyboard.instantiateViewController(withIdentifier: "FormSettingView") as? FormSettingVC
        myVC!.modalPresentationStyle = .fullScreen
        let navController = UINavigationController(rootViewController: myVC!)
        myVC!.title = "Settings"
        myVC!.routineContr = self
        myVC!.subData = self.subData
        myVC!.settingDel = self
        navController.presentationController?.delegate = myVC

        self.navigationController?.present(navController, animated: true, completion: nil)
    }
    
    
    // MARK: - Table view data source
    @objc func settingClicked(){
        //fatalError()
        self.settingClickRun()

    }
    
    @objc func addRoutineClick(){

        if let viewController = UIStoryboard(name: "RoutineEditorView", bundle: nil).instantiateViewController(withIdentifier: "RoutineEditorView") as? RoutineEditorController {
            viewController.title = "Add Timer"
            viewController.rout.routineIndex = self.rout.count
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
        
    }
    @objc func addEditButton(){
        

            
            if self.isEditingBool {
                //print("here1")
                self.addEditClick = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.addEditButton))
                self.navigationItem.setRightBarButtonItems([self.addEditClick], animated: true)
            }
            else {
                //print("here2")
                self.addEditClick = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(self.addEditButton))
                self.navigationItem.setRightBarButtonItems([self.addRoutineButton, self.addEditClick], animated: true)
            }

            //

        self.tableView.setEditing(self.isEditingBool, animated: true)
        self.isEditingBool.toggle()
        //self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)

        
    }
    
    func movedRout(sourceIndexPath: IndexPath, destinationIndexPath: IndexPath) {
        let movedObject = self.rout[sourceIndexPath.row]
        rout.remove(at: sourceIndexPath.row)
        rout.insert(movedObject, at: destinationIndexPath.row)
        self.reorderRouts()
    }

    
    func reorderRouts() {
        self.dataStack.perform(
            asynchronous: { (transaction) -> Void in
                try transaction.deleteAll(
                    From<CDRoutine>()
                    
                )
        },
            completion: { _ in
                
                for (j, _) in self.rout.enumerated() {
                    self.rout[j].routineIndex = j
                    //print("RC self.rout[j].routineIndex", self.rout[j].routineIndex)
                    let sr = SaveRoutine()
                    sr.dataStack = self.dataStack
                    sr.rout = self.rout[j]
                    sr.save3()
                    //self.tableView.reloadData()
                }

        }
        )
    }


}

extension RoutinesController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rout.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if let spacer = tableView.reorder.spacerCell(for: indexPath) {
//            return spacer
//        }
        let routine = rout[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "RoutineCell") as! RoutineCell
        cell.setLabels(rout: routine, edit: !self.isEditingBool)
        //print(rout[indexPath.row])
        //print("rout[indexPath.row].totalTime", rout[indexPath.row].totalTime)
        cell.timeLabel.text =
            globals().timeString(time: TimeInterval(rout[indexPath.row].totalTime))
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }


    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self.movedRout(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    {
        if rout.count > 1 {
            //self.setRightBarItem()
            return UITableViewCell.EditingStyle.delete

        } else {
            //self.setRightBarItem()
            return .none

        }
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if rout.count > 1 && editingStyle == .delete {
            
            
            print("deleting")
            let alert = UIAlertController(title: "Are you sure you want to delete this routine? This can't be undone", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    //print("destructive")
                    self.rout.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.reorderRouts()
                    self.setBackgroundandNavigationBar()
                    
                @unknown default:
                    print("error")
                }}))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                    
                case .cancel:
                    print("cancel")
                    
                case .destructive:
                    print("destructive")
                    
                    
                @unknown default:
                    print("error")
                    
                }}))
            self.present(alert, animated: true, completion: nil)
            
            
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let viewController = UIStoryboard(name: "PlayerView", bundle: nil).instantiateViewController(withIdentifier: "PlayerView") as? PlayerController {
            //print("rout[indexPath.row]", rout[indexPath.row])
            //print("rout.coolDown", rout[indexPath.row].coolDown)
            viewController.rout = rout[indexPath.row]
            if let navigator = navigationController {
                navigator.pushViewController(viewController, animated: true)
            }
        }
    }

     func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
      return true
    }


     func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
//        print("HERE")
        return action == #selector(copy(_:))
    }


     func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        if action == #selector(copy(_:)) {
            var routine = rout[indexPath.row]
            routine.routineID = UUID().uuidString
            routine.routineIndex = routine.routineIndex + 1
            routine.name = routine.name + " Copy"
            let colors = globals().setAllColorsArray()
            let count = colors.count - 1
            let number = Int.random(in: 0 ... count)

            routine.routineColor = colors[number]
            rout.insert(routine, at: indexPath.row + 1)
            self.tableView.reloadData()
            self.reorderRouts()
        }
    }

    

    
}
//
//extension RoutinesController: TableViewReorderDelegate {
//    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        // Update data model
//        //self.movedRout(sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
//    }
//}

func hexStringToUIColor (hex:String) -> UIColor {
    var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if (cString.hasPrefix("#")) {
        cString.remove(at: cString.startIndex)
    }
    
    if ((cString.count) != 6) {
        return UIColor.gray
    }
    
    var rgbValue:UInt64 = 0
    Scanner(string: cString).scanHexInt64(&rgbValue)
    
    return UIColor(
        red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
        blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
        alpha: CGFloat(1.0)
    )
}

extension UIImage {
   static func imageWithColor(tintColor: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        tintColor.setFill()
        UIRectFill(rect)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
}

