//
//  soundPicker.swift
//  Timer
//
//  Created by David Blatt on 4/2/20.
//  Copyright © 2020 David Blatt. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation



class soundPicker: UIPickerView, UIPickerViewDataSource, UIPickerViewDelegate {
    var picker_values = [sounds]()
    var oficinas = ["oficina 1", "Oficinas 2", "Oficina 3"]
    var butt : UIButton!
    var player : AVAudioPlayer?
    var labelValue: UILabel?
    var studentDelegate: ModalDelegate2?
    var intervalVC : IntervalEditorVC?

    func initializeButt() {
        let screenSize: CGRect = UIScreen.main.bounds
        butt = UIButton(frame: CGRect(x: screenSize.width - 30, y: UIScreen.main.bounds.height - 189, width: 30, height: 30))
        // butt.backgroundColor = .systemTeal
        butt.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        butt.setImage(UIImage(systemName: "play.circle"), for: .normal)
        butt.tintColor = .systemGray
        
        
    }

    

    func playSound() {
        let session = AVAudioSession.sharedInstance()

        try? session.setCategory(.playback, options: .mixWithOthers)
        try? session.setActive(true, options: [])
        player?.stop()
        let index = self.selectedRow(inComponent: 0)
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: picker_values[index].rawValue, ofType: "mp3")!)
        try! player = AVAudioPlayer(contentsOf: alertSound)
        player?.prepareToPlay()
        player?.play()
    }

    @objc func buttonAction(sender: UIButton!) {
      print("Button tapped")

        self.playSound()
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {

        return picker_values.count
    }

    //MARK: Delegates

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return picker_values[row].rawValue

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        player?.stop()
        //Your Function
        if row == 0 {
            butt.isHidden = true

        }
        else {
            butt.isHidden = false
        }
        print("here10")
        self.intervalVC?.changeValue(value: picker_values[row])
        // myDelegate?.changeValue(value: picker_values[row])
        //interval?.sound = picker_values[row]
        //tableView.reloadData()
    }
}
