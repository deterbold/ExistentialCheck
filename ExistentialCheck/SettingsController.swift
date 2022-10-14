//
//  SettingsController.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 13/10/2022.
//

import UIKit

class SettingsController: UIViewController
{
    var poisonedData = false

    @IBOutlet weak var explanationLabel: UILabel!
    
    @IBOutlet weak var dataSwitch: UISwitch!
    
    //remembering the state of the switch
    //https://stackoverflow.com/questions/28555255/how-do-i-keep-uiswitch-state-when-changing-viewcontrollers
    
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(false)
        dataSwitch?.isOn =  UserDefaults.standard.bool(forKey: "switchState")
        dataSwitch?.addTarget(self, action: #selector(switchStateDidChange(_:)), for: .touchUpInside)
    }
    
    @objc func switchStateDidChange(_ sender:UISwitch!)
    {
        UserDefaults.standard.set(sender.isOn, forKey: "switchState")
        UserDefaults.standard.synchronize()
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        explanationLabel.font = UIFont(name: "Futura Medium", size: 30)
        explanationLabel.adjustsFontSizeToFitWidth = true
        explanationLabel.allowsDefaultTighteningForTruncation = true
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        explanationLabel.text = "An explanation of what the switch does"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "settingsToStart"
        {
            if dataSwitch.isOn
            {
                let vc = segue.destination as? StartController
                vc?.poisonedData = true
            }
            else
            {
                let vc = segue.destination as? StartController
                vc?.poisonedData = false
            }
        }
    }
}
