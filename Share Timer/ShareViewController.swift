//
//  ShareViewController.swift
//  Share Timer
//
//  Created by David Blatt on 2020-10-05.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        print("here2")
        spinner.style = .large
        Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(self.didSelectPost), userInfo: nil, repeats: false)

        self.handleSharedFile()

      }
    @IBOutlet weak var spinner: UIActivityIndicatorView!

    private func handleSharedFile() {
      // extracting the path to the URL that is being shared
        print("here3")
      let attachments = (self.extensionContext?.inputItems.first as? NSExtensionItem)?.attachments ?? []
      for provider in attachments {
        if provider.hasItemConformingToTypeIdentifier("public.json") {
              provider.loadItem(forTypeIdentifier: "public.json",
                                options: nil) { [unowned self] (data, error) in
              // Handle the error here if you want
              guard error == nil else { return }

              if let url = data as? URL,
                 
                 let imageData = try? Data(contentsOf: url) {
                do {
                    let blogPost: Routine = try! JSONDecoder().decode(Routine.self, from: imageData)
                    print(blogPost)
                    self.saveFriends(friends: [blogPost])
                }
              } else {
                // Handle this situation as you prefer
                fatalError("Impossible to save image")
              }
            }}
      }
    }

    private func save(_ data: Data, key: String, value: Any) {
      let userDefaults = UserDefaults()
        print("data", data)
      userDefaults.set(data, forKey: key)
    }

    

    func saveFriends(friends: [Routine]) {
        let documentsDirectory = FileManager().containerURL(forSecurityApplicationGroupIdentifier: shareString.groupName.rawValue)
        let archiveURL = documentsDirectory?.appendingPathComponent(shareString.JSONFile.rawValue)
            let encoder = JSONEncoder()
            if let dataToSave = try? encoder.encode(friends) {
                do {
                    print(dataToSave)
                    try dataToSave.write(to: archiveURL!)
                    print("saved")
                    self.openURL(URL(string: "dbtimerapp://com.db.tbtimer?")!)

                } catch {
                    // TODO: ("Error: Can't save Counters")
                    return;
                }
            }
        }

    @objc func openURL(_ url: URL){
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                application.perform(#selector(openURL(_:)), with: url)
            }
            responder = responder?.next
        }
    }

}
