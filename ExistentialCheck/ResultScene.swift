//
//  ResultScene.swift
//  ExistentialCheck
//
//  Created by Miguel Sicart on 19/09/2022.
//

import UIKit
import AVKit
import Lumina
import CoreML
import Foundation
import Vision

class ResultScene: UIViewController
{
    
    //MARK: OUTLETS
    @IBOutlet weak var tastyImage: UIImageView!
    @IBOutlet weak var transformButton: UIBarButtonItem!
    @IBOutlet weak var evaluateButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var informationLabel: UILabel!
    
    //MARK: VARIABLES
    var isReal = false
    var image: UIImage?
    var model: VNCoreMLModel?
    
    
    //MARK: INITIAL VIEW LOAD
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
            informationLabel.text = "The Reality Model confirms that you exist"
            transformButton.isHidden = true
            evaluateButton.isHidden = true
        }
        else if !isReal
        {
            informationLabel.text = "The Reality Model confirms that you do not exist"
            transformButton.isHidden = true
            evaluateButton.isHidden = true
        }
        
    }
    
    //https://stackoverflow.com/questions/35931946/basic-example-for-sharing-text-or-image-with-uiactivityviewcontroller-in-swift
    //https://medium.com/apple-developer-academy-federico-ii/machine-learning-image-classification-and-style-transfer-using-createml-and-turicreate-9880f9ad6b0d
    
    
    //MARK: TRANSFORMATION BUTTON
    @IBAction func transformButton(_ sender: Any)
    {
        let transformationModel: TransformationMachineRedux = try! TransformationMachineRedux(configuration: MLModelConfiguration.init())
        print("transform button has been pushed")
        if let image = pixelBuffer(from: tastyImage.image!) {
            do {
                let predictionOutput = try transformationModel.prediction(image: image)
                
                let ciImage = CIImage(cvPixelBuffer: predictionOutput.stylizedImage)
                let tempContext = CIContext(options: nil)
                let tempImage = tempContext.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(predictionOutput.stylizedImage), height: CVPixelBufferGetHeight(predictionOutput.stylizedImage)))
                let novelImage = UIImage(cgImage: tempImage!)
                let writtenImage = textToImage(drawText: "this image is not real", inImage: novelImage, atPoint: CGPoint(x: novelImage.size.width/2 - 100, y: novelImage.size.height - 100))
               
                tastyImage.contentMode = .center
                //tastyImage.image = UIImage(cgImage: tempImage!)
                tastyImage.image = writtenImage
                classifyImage(tastyImage.image!)
            } catch let error as NSError {
                print("CoreML Model Error: \(error)")
            }
        }
        transformButton.isHidden = true
        evaluateButton.isHidden = false
    }
    
    //MARK: PIXELBUFFER
    func pixelBuffer(from image: UIImage) -> CVPixelBuffer? {
        // 1 Transform the image received into a sqyare
        //the size requested by the coreml model
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 512, height: 512), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 256, height: 256)) //https://developer.apple.com/documentation/uikit/uiimage/1624092-draw
        _ = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        // 2 We create a CVPixel Buffer
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, 512, 512, kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return nil
        }
        
        // 3
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        // 4
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: 512, height: 512, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        // 5
        context?.translateBy(x: 0, y: 512)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        // 6
        UIGraphicsPushContext(context!)
        image.draw(in: CGRect(x: 0, y: 0, width: 512, height: 512))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
    
    
    //MARK: CLASSIFICATION BUTTON
    @IBAction func evaluateAgain(_ sender: Any)
    {
        classifyImage(tastyImage.image!)
    }
    
    //MARK: CLASSIFICATION FUNCTION
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
    
    //MARK: CLASSIFICATION REQUEST
    private lazy var classificationRequest: VNCoreMLRequest =
    {
        do {
            //https://stackoverflow.com/questions/65549956/how-to-setup-a-coreml-model
            let config = MLModelConfiguration()
            let coreMLModel = try ExistentialistCheck_Working(configuration: config)
            let evaluationModel = try? VNCoreMLModel(for: coreMLModel.model)
           
            //model = try VNCoreMLModel(for: ExistentialistCheck_Working().model)
                                    
            
            let request = VNCoreMLRequest(model: evaluationModel!) { [self] request, _ in
                if let classifications = request.results as? [VNClassificationObservation] {
                    
                    print("classifying in result scene")
                    let veredict = classifications.first!.identifier as String
                    
                    if veredict == "Real"
                    {
                        print("the picture is real")
                        DispatchQueue.main.async { [self] in
                            self.informationLabel.text = "Congratulations! You exist!"
                            self.evaluateButton.isHidden = true
                            
                        }
                        self.isReal = true
                        
                    }
                    else if veredict == "Unexisting"
                    {
                        print("the picture is not real")
                        DispatchQueue.main.async {
                            self.informationLabel.text = "Unfortunately, you do not exist"
                            self.evaluateButton.isHidden = true
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
    
    
    //MARK: SHARING
    @IBAction func shareButton(_ sender: Any)
    {
        // image to share
        //let image = UIImage(named: "Image")
               
        // set up activity view controller
        let imageToShare = [ tastyImage.image! ]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
               
        // exclude some activity types from the list (optional)
        //activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.airDrop, UIActivity.ActivityType.postToFacebook ]
               
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    //MARK: TEXT 2 IMAGE
    //https://stackoverflow.com/questions/28906914/how-do-i-add-text-to-an-image-in-ios-swift
    func textToImage(drawText text: String, inImage image: UIImage, atPoint point: CGPoint) -> UIImage {
        let textColor = UIColor.white
        let textFont = UIFont(name: "Futura-CondensedExtraBold", size: 15)!

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

