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
    
    private lazy var classificationRequest: VNCoreMLRequest =
    {
        do {
            if poisonedData
            {
                model = try VNCoreMLModel(for: ExistentialistCheck_MixedData().model)
            } else {
                model = try VNCoreMLModel(for: ExistentialistCheck_Working().model)
            }
            
            let request = VNCoreMLRequest(model: model!) { request, _ in
                if let classifications = request.results as? [VNClassificationObservation] {
                    //print("Classification results: \(classifications)")
                    //print(classifications.first!.identifier as String)
                    //print(request.results?.first?.confidence as Any)
                    
                    let veredict = classifications.first!.identifier as String
                    
                    if veredict == "Real"
                    {
                        print("the picture is real")
                        print(self.poisonedData)
                        DispatchQueue.main.async {
                            self.resultLabel.text = "Congratulations! You are real!"
                        }
                        self.isReal = true
                    }
                    else if veredict == "Unexisting"
                    {
                        print("the picture is not real")
                        print(self.poisonedData)
                        DispatchQueue.main.async {
                            self.resultLabel.text = "Unfortunately, you are not real"
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
//        if poisonedData
//        {
//            print("the camera controller has poisoned data")
//
//
//        } else
//        {
//            print("the camera controller has good data")
//
//        }
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
    
//    func sendPicture()
//    {
//        print("send Picture is called")
//        DispatchQueue.main.async {
//            self.performSegue(withIdentifier: "presentResultSegue", sender: self)
//
//        }
//    }
    
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

}
