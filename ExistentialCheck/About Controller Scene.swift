//
//  About Controller Scene.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 23/09/2022.
//

import UIKit

class About_Controller_Scene: UIViewController {
    
    //MARK: OUTLETS
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
        explanationLabel.text = "Do you want to know what your Existential Status is? Now you can, thanks to the infalible power of Machine Learning and Ridiculous Software's Reality Model. Take a selfie, check if you exist!"
    }
    

}
