//
//  About Controller Scene.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 23/09/2022.
//

import UIKit

class About_Controller_Scene: UIViewController {

    @IBOutlet weak var explanationLabel: UILabel!
    
    override func viewDidLoad()
    {
        print("About")
        super.viewDidLoad()

        explanationLabel.font = UIFont(name: "Futura Medium", size: 30)
        explanationLabel.adjustsFontSizeToFitWidth = true
        explanationLabel.allowsDefaultTighteningForTruncation = true
        explanationLabel.numberOfLines = 0
        explanationLabel.textAlignment = .center
        explanationLabel.text = "An explanation of what the app is about"
    }
    

}
