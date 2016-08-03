//
//  SettingsViewController.swift
//  ECAB
//
//  Created by Raphaël Bertin on 01/08/2016.
//  Copyright © 2016 Oliver Braddick and Jan Atkinson. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource  {
    
    let model = Model.sharedInstance;
    
    @IBOutlet weak var voicePicker: UIPickerView!
    
    @IBOutlet weak var voiceInput: UITextField!
    @IBAction func speak(sender: UIButton) {
        TextToSpeechHelper.engine.say(voiceInput.text!)
    }
    
    @IBOutlet weak var rateSlider: UISlider!
    @IBOutlet weak var rateValue: UILabel!
    @IBOutlet weak var rateTitle: UILabel!
    @IBAction func changeRate(sender: UISlider) {
        let formattedValue = NSString(format: "%.01f", sender.value)
        rateValue.text = formattedValue as String
        model.data.voiceRate = Float(formattedValue as String)!
        model.save()
    }
    
    @IBOutlet weak var pitchTitle: UILabel!
    @IBOutlet weak var pitchValue: UILabel!
    @IBOutlet weak var pitchSlider: UISlider!
    @IBAction func setPitch(sender: UISlider) {
        let formattedValue = NSString(format: "%.01f", sender.value)
        pitchValue.text = formattedValue as String
        model.data.voicePitch = Float(formattedValue as String)!
        model.save()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.voicePicker.delegate = self
        self.voicePicker.dataSource = self
        
        showSettings("Voice");
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func showSettings(settingName: String) {
        
        // Set title
        title = "\(settingName) settings"
        
        switch settingName {
            case "Voice":
                rateValue.text = NSString(format: "%.01f", model.data.voiceRate.floatValue) as String
                rateSlider.value = model.data.voiceRate.floatValue
                
                pitchValue.text = NSString(format: "%.01f", model.data.voicePitch.floatValue) as String
                pitchSlider.value = model.data.voicePitch.floatValue
                
                voicePicker.selectRow(model.data.voiceName.integerValue, inComponent: 0, animated: true);
                break
            default:
            
                break
        }
    }
    
    // The number of columns of data
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // The number of rows of data
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return AVSpeechSynthesisVoice.speechVoices().count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return AVSpeechSynthesisVoice.speechVoices()[row].language
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        model.data.voiceName = row
        model.save()
    }
}

