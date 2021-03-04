//
//  ViewController.swift
//  Colorful
//
//  Created by hayashi311 on 05/08/2020.
//  Copyright (c) 2020 hayashi311. All rights reserved.
//

import UIKit
import Colorful

class ColorfulVC: UIViewController {

    @IBOutlet weak var colorPicker: ColorPicker!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var uiSwitch: UISwitch!
    @IBOutlet weak var colorSpaceLabel: UILabel!
    var initialColor : UIColor!
    var colorSpace: HRColorSpace = .sRGB
    var completionHandler:((UIColor) -> Int)?

    override func viewDidLoad() {
        super.viewDidLoad()
        colorPicker.addTarget(self, action: #selector(self.handleColorChanged(picker:)), for: .valueChanged)
        colorPicker.set(color: initialColor, colorSpace: colorSpace)
        updateColorSpaceText()
        handleColorChanged(picker: colorPicker)
        colorSpaceLabel.isHidden = true
        label.isHidden = true
        uiSwitch.isHidden = true
        
    }

    @objc func handleColorChanged(picker: ColorPicker) {
        label.text = picker.color.description
        //print(picker.color.description)
        _ = completionHandler?(picker.color)

            //print("completionHandler returns... \(result)")
    }

    @IBAction func handleRedButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .red, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handlePurpleButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .purple, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handleYellowButtonAction(_ sender: UIButton) {
        colorPicker.set(color: .yellow, colorSpace: colorSpace)
        handleColorChanged(picker: colorPicker)
    }

    @IBAction func handleSwitchAction(_ sender: UISwitch) {
        colorSpace = sender.isOn ? .extendedSRGB : .sRGB
        colorPicker.set(color: colorPicker.color, colorSpace: colorSpace)
        updateColorSpaceText()
        handleColorChanged(picker: colorPicker)
    }

    func updateColorSpaceText() {
        switch colorSpace {
        case .extendedSRGB:
            colorSpaceLabel.text = "Extended sRGB"
        case .sRGB:
            colorSpaceLabel.text = "sRGB"
        }
    }
}

