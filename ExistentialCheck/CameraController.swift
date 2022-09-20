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
        
    var image: UIImage?
    var livePhotoURL: URL?
    var showingDepth: Bool = false
    var position: CameraPosition = .front
    private var _depthData: Any?
    
    //var model: VNCoreMLModel?
        
//    private lazy var classificationRequest: VNCoreMLRequest =
//    {
//      do {
//        // 2
//          switch creativeMode
//          {
//          case 0:
//              model = try VNCoreMLModel(for: prototype_taste().model)
//          case 1:
//              model = try VNCoreMLModel(for: Tastegram_Hard().model)
//          case 2:
//              model = try VNCoreMLModel(for: Tastegram_Extremes().model)
//          case 3:
//              model = try VNCoreMLModel(for: Tastegram_Influencer().model)
//          default:
//              model = try VNCoreMLModel(for: prototype_taste().model)
//          }
////        //let model = try VNCoreMLModel(for: prototype_taste().model)
////          if creativeMode == 0
////          {
////              model = try VNCoreMLModel(for: Tastegram_Hard().model)
////          }
//          // 3
//          let request = VNCoreMLRequest(model: model!) { request, _ in
//            if let classifications =
//              request.results as? [VNClassificationObservation] {
//              print("Classification results: \(classifications)")
//                print(classifications.first!.identifier as String as Any)
//                print(request.results?.first?.confidence as Any)
//                let veredict = classifications.first!.identifier as String
//                if veredict == "Good"
//                {
//                    print("good picture")
//                    self.sendPicture()
//
//                }
//                else if veredict == "Bad"
//                {
//                    print("bad picture")
//                    self.sendText()
//                }
//
//            }
//        }
//        // 4
//        request.imageCropAndScaleOption = .centerCrop
//        return request
//      } catch {
//        // 5
//        fatalError("Failed to load Vision ML model: \(error)")
//      }
//    }()
    
    override func viewWillAppear(_ animated: Bool)
    {
        self.imageView.image = image
        print("we have arrived")
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
    }
    
    
//    func classifyImage(_ image: UIImage)
//    {
//      // 1
//      guard let orientation = CGImagePropertyOrientation(
//        rawValue: UInt32(image.imageOrientation.rawValue)) else {
//        return
//      }
//      guard let ciImage = CIImage(image: image) else {
//        fatalError("Unable to create \(CIImage.self) from \(image).")
//      }
//      // 2
//      DispatchQueue.global(qos: .userInitiated).async {
//        let handler =
//          VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
//        do {
//          try handler.perform([self.classificationRequest])
//        } catch {
//          print("Failed to perform classification.\n\(error.localizedDescription)")
//        }
//      }
//    }
    
    func sendPicture()
    {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "sucessControllerSegue", sender: self)

        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.identifier == "sucessControllerSegue" {
            let dvc = segue.destination as! ResultScene
            dvc.image = self.image
        }
    }

}
