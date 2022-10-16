//
//  CameraController.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 20/09/2022.
//

import UIKit
import Lumina
import Vision
import CoreML
import AVKit

class CameraController: UIViewController
{
    
    @IBOutlet weak var imageView: UIImageView!
        
    @IBOutlet weak var resultLabel: UILabel!
    
    var image: UIImage?
    var livePhotoURL: URL?
    var showingDepth: Bool = false
    var position: CameraPosition = .front
    private var _depthData: Any?
    
    var poisonedData = false
    var existentialStatus = ""
    var isReal: Bool!
    
    var model: VNCoreMLModel?
    
    @IBAction func shareButtonAction(_ sender: Any)
    {
        // image to share
        //let image = UIImage(named: "Image")
               
        // set up activity view controller
        let imageToShare = [ imageView.image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
               
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
               
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    private lazy var classificationRequest: VNCoreMLRequest =
    {
        do {
            if poisonedData
            {
                model = try VNCoreMLModel(for: ExistentialistCheck_MixedData().model)
            } else {
                model = try VNCoreMLModel(for: ExistentialistCheck_Working().model)
            }
            
            let request = VNCoreMLRequest(model: model!) { [self] request, _ in
                if let classifications = request.results as? [VNClassificationObservation] {
                    
                    let veredict = classifications.first!.identifier as String
                    
                    if veredict == "Real"
                    {
                        print("the picture is real")
                        DispatchQueue.main.async { [self] in
                            self.resultLabel.text = "Congratulations! You are real!"
                            let transformedImage = self.textToImage(drawText: "Congratulations! You are real!", inImage: image!, atPoint: CGPoint(x: image!.size.width/2 - 100, y: image!.size.height - 100))
                            self.imageView.image = transformedImage
                        }
                        self.isReal = true
                        
                    }
                    else if veredict == "Unexisting"
                    {
                        print("the picture is not real")
                        DispatchQueue.main.async {
                            self.resultLabel.text = "Unfortunately, you are not real"
                            let transformedImage = self.textToImage(drawText: "Unfortunately, you are not real!", inImage: self.image!, atPoint: CGPoint(x: self.image!.size.width/2 - 100, y: self.image!.size.height - 100))
                            self.imageView.image = transformedImage
                        }
                        self.isReal = false
                    }
                }
            }
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            
            fatalError("Failed to load Vision ML model: \(error)")
            
        }
    }()
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.imageView.image = image
        resultLabel.font = UIFont(name: "Futura Medium", size: 30)
        resultLabel.adjustsFontSizeToFitWidth = true
        resultLabel.allowsDefaultTighteningForTruncation = true
        resultLabel.numberOfLines = 0
        resultLabel.textAlignment = .center
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print("Camera Controller")
        classifyImage(image!)
    }
        
    func classifyImage(_ image: UIImage)
    {
      // 1
      guard let orientation = CGImagePropertyOrientation(
        rawValue: UInt32(image.imageOrientation.rawValue)) else {
        return
      }
      guard let ciImage = CIImage(image: image) else {
        fatalError("Unable to create \(CIImage.self) from \(image).")
      }
      // 2
      DispatchQueue.global(qos: .userInitiated).async {
        let handler =
          VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
        do {
          try handler.perform([self.classificationRequest])
        } catch {
          print("Failed to perform classification.\n\(error.localizedDescription)")
        }
      }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        print("sending picture")
        if segue.identifier == "presentResultSegue" {
            let dvc = segue.destination as! ResultScene
            dvc.image = self.image
            dvc.isReal = self.isReal
            self.imageView.image = nil
        }
    }
    
    //https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Futura-CondensedExtraBold", size: 40)!

        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(image.size, false, scale)

        let textFontAttributes = [
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: textColor,
            ] as [NSAttributedString.Key : Any]
        image.draw(in: CGRect(origin: CGPoint.zero, size: image.size))

        let rect = CGRect(origin: point, size: image.size)
        text.draw(in: rect, withAttributes: textFontAttributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }

}
