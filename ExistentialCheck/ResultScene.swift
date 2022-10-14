//
//  ResultScene.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 19/09/2022.
//

import UIKit
import AVKit
import Lumina

class ResultScene: UIViewController
{
    
    @IBOutlet weak var tastyImage: UIImageView!
    
    var image: UIImage?

    @IBOutlet weak var informationLabel: UILabel!
    
    var isReal = false
    
    @IBOutlet weak var explanationLabel: UILabel!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("Result Controller")
        tastyImage.image = image
        
        informationLabel.font = UIFont(name: "Futura Medium", size: 30)
        informationLabel.adjustsFontSizeToFitWidth = true
        informationLabel.allowsDefaultTighteningForTruncation = true
        informationLabel.numberOfLines = 0
        informationLabel.textAlignment = .center
        if isReal
        {
            informationLabel.text = "A detailed explanation of what is to be real"
        }
        else if !isReal
        {
            informationLabel.text = "An explanation of what it is not to be real"
        }

        //UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
    }
    
    //https://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift
    
    
    @IBAction func transformButton(_ sender: Any)
    {
        
    }
    
    
    @IBAction func shareButton(_ sender: Any)
    {
        // image to share
        //let image = UIImage(named: "Image")
               
        // set up activity view controller
        let imageToShare = [ image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
               
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
               
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
}
    
