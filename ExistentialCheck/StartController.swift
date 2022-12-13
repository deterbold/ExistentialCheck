//
//  ViewController.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 18/09/2022.
//

import UIKit
import AVKit
import Lumina
import CoreML
import AVKit

class StartController: UIViewController
{
    
    //MARK: OUTLETS
    @IBOutlet weak var instructionsLabel: UILabel!
    
    
    //MARK: VARIABLES
    var labelText = "Take a selfie and check if you exist or not"
    var poisonedData = false
    
    //MARK: LOAD VIEW
    override func viewDidLoad()
    {
        print("Start Controller")
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        instructionsLabel.font = UIFont(name: "Futura Medium", size: 28)
        instructionsLabel.adjustsFontSizeToFitWidth = true
        instructionsLabel.allowsDefaultTighteningForTruncation = true
        instructionsLabel.numberOfLines = 0
        instructionsLabel.textAlignment = .center
        instructionsLabel.text = labelText
        
        print("Poisoned Data: ", poisonedData)
    }
    
    //MARK: CAMERA BUTTON FUNCTION
    @IBAction func cameraButtonTapped(_ sender: Any)
    {
        //code for setting up the camera and presenting the view goes here.
        //creating the camera view controller
        let camera = LuminaViewController()
        camera.delegate = self

            
        //presenting the camera view
        camera.modalPresentationStyle = .fullScreen
        camera.position = .front
        
        if poisonedData
        {
            camera.textPrompt = "Check whether you exist (Alternative Reality Model)"
        } else {
            camera.textPrompt = "Check whether you exist"
        }
        camera.resolution = .highest
        camera.setSwitchButton(visible: false)
        present(camera, animated: true, completion: nil)
    }
    
    //MARK: SEGUE FUNCTION
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
      if segue.identifier == "presentCameraSegue"{
        guard let controller = segue.destination as? CameraController else { return }
        if let map = sender as? [String: Any] {
          controller.image = map["stillImage"] as? UIImage
          controller.livePhotoURL = map["livePhotoURL"] as? URL
          guard let positionBool = map["isPhotoSelfie"] as? Bool else { return }
          controller.position = positionBool ? .front : .back
            controller.poisonedData = poisonedData
        } else { return }
      }
    }
}

//MARK: COMPLYING TO LUMINA
extension StartController: LuminaDelegate
{
    func captured(stillImage: UIImage, livePhotoAt: URL?, depthData: Any?, from controller: LuminaViewController) {
        controller.dismiss(animated: true) {
            self.performSegue(withIdentifier: "presentCameraSegue", sender: ["stillImage": stillImage, "livePhotoURL": livePhotoAt as Any, "depthData": depthData as Any, "isPhotoSelfie": controller.position == .front ? true : false])
        }
    }

    func detected(metadata: [Any], from controller: LuminaViewController) {
        print(metadata)
    }
    
    func dismissed(controller: LuminaViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
}

//MARK: PIXELBUFFER EXTENSION
extension CVPixelBuffer
{
  func normalizedImage(with position: CameraPosition) -> UIImage? {
    let ciImage = CIImage(cvPixelBuffer: self)
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(self), height: CVPixelBufferGetHeight(self))) {
      return UIImage(cgImage: cgImage, scale: 1.0, orientation: getImageOrientation(with: position))
    } else {
      return nil
    }
  }

  private func getImageOrientation(with position: CameraPosition) -> UIImage.Orientation {
    let orientation = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.windowScene?.interfaceOrientation ?? .portrait
    switch orientation {
      case .landscapeLeft:
        return position == .back ? .down : .upMirrored
      case .landscapeRight:
        return position == .back ? .up : .downMirrored
      case .portraitUpsideDown:
        return position == .back ? .left : .rightMirrored
      case .portrait:
        return position == .back ? .right : .leftMirrored
      case .unknown:
        return position == .back ? .right : .leftMirrored
      @unknown default:
        return position == .back ? .right : .leftMirrored
    }
  }
}

//MARK: ERROR EXTENSION
extension StartController {
  func showErrorAlert(with message: String) {
    let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
    alert.addAction(.init(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
}


