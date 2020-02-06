//
//  EditImageViewController.swift
//  Gridy
//

import UIKit
import CoreImage

class EditImageViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var selectedImageContainer: UIView!
    @IBOutlet weak var selectedImageView: UIImageView!

    var imageReceived: UIImage?
    var panRecognizer: UIPanGestureRecognizer?
    var pinchRecognizer: UIPinchGestureRecognizer?
    var rotateRecognizer: UIRotationGestureRecognizer?
    var imageForPlayFieldView = [UIImage]()
    var screenShotImage = UIImage()
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        configureImage()
    }
    
    // MARK: - Button listeners
    @IBAction func startButtonTapped(_ sender: UIButton) {
        prepareImageForPlayFieldView()
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - prepare and configure image
    func configureImage() {
        if let randomImageReceived = imageReceived {
            selectedImageView.image = randomImageReceived
            backgroundImageView.image = randomImageReceived
        }
        
        // create gestures
        self.panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePan(recognizer:)))
        panRecognizer?.delegate = self
        self.selectedImageView.addGestureRecognizer(panRecognizer!)
        self.pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(self.handlePinch(recognizer:)))
        pinchRecognizer?.delegate = self
        self.selectedImageView.addGestureRecognizer(pinchRecognizer!)
        self.rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(self.handleRotate(recognizer:)))
        rotateRecognizer?.delegate = self
        self.selectedImageView.addGestureRecognizer(rotateRecognizer!)
    }
    
    // MARK: - handlers
    @objc func handlePan(recognizer: UIPanGestureRecognizer) {
        let gview = recognizer.view
        if recognizer.state == .began || recognizer.state == .changed {
            let translation = recognizer.translation(in: gview?.superview)
            gview?.center = CGPoint(x: (gview?.center.x)! + translation.x, y: (gview?.center.y)! + translation.y)
            recognizer.setTranslation(CGPoint.zero, in: gview?.superview)
        }
    }
    
    @objc func handlePinch(recognizer: UIPinchGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            recognizer.view?.transform = (recognizer.view?.transform.scaledBy(x: recognizer.scale, y: recognizer.scale))!
            recognizer.scale = 1.0
        }
    }
    
    @objc func handleRotate(recognizer: UIRotationGestureRecognizer) {
        if recognizer.state == .began || recognizer.state == .changed {
            recognizer.view?.transform = (recognizer.view?.transform.rotated(by: recognizer.rotation))!
            recognizer.rotation = 0.0
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.view != selectedImageView {
            return false
        }
        if gestureRecognizer is UITapGestureRecognizer
            || otherGestureRecognizer is UITapGestureRecognizer
            || gestureRecognizer is UIPanGestureRecognizer
            || otherGestureRecognizer is UIPanGestureRecognizer {
            return false
        }
        return true
    }
    
    // MARK: - segue methods
    func prepareImageForPlayFieldView() {
        DispatchQueue.global(qos: .userInitiated).async {
            self.composeCreationImage { image in
                self.imageForPlayFieldView = self.slice(screenshot: image, into: 4)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "PlayfieldViewSegue", sender: self)
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PlayfieldViewSegue" {
            let playfieldViewController = segue.destination as! PlayViewController
            playfieldViewController.imageRecieved = imageForPlayFieldView
            playfieldViewController.popUpImage = self.screenShotImage
        }
    }
}

// MARK: - Helper methods
extension EditImageViewController {

    // Creating the screenshot of the image to be transferred to the next screen
    func composeCreationImage(completion: @escaping (UIImage) -> Void) {
        DispatchQueue.main.async {
            UIGraphicsBeginImageContextWithOptions(self.selectedImageContainer.bounds.size, false, 0)
            self.selectedImageContainer.drawHierarchy(in: self.selectedImageContainer.bounds, afterScreenUpdates: true)
            self.screenShotImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            completion(self.screenShotImage)
        }
    }
    
    // Helper function to split an image into given number of slices
    func slice(screenshot: UIImage, into howMany: Int) -> [UIImage] {
        let width: CGFloat
        let height: CGFloat
        
        switch screenshot.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            width = screenshot.size.height
            height = screenshot.size.width
        default:
            width = screenshot.size.width
            height = screenshot.size.height
        }
        
        let tileWidth = Int(width / CGFloat(howMany))
        let tileHeight = Int(height / CGFloat(howMany))
        
        let scale = Int(screenshot.scale)
        var images = [UIImage]()
        let cgImage = screenshot.cgImage!
        
        var adjustedHeight = tileHeight
        
        var y = 0
        for row in 0 ..< howMany {
            if row == (howMany - 1) {
                adjustedHeight = Int(height) - y
            }
            var adjustedWidth = tileWidth
            var x = 0
            for column in 0 ..< howMany {
                if column == (howMany - 1) {
                    adjustedWidth = Int(width) - x
                }
                let origin = CGPoint(x: x * scale, y: y * scale)
                let size = CGSize(width: adjustedWidth * scale, height: adjustedHeight * scale)
                let tileCGImage = cgImage.cropping(to: CGRect(origin: origin, size: size))!
                images.append(UIImage(cgImage: tileCGImage, scale: screenshot.scale, orientation: screenshot.imageOrientation))
                x += tileWidth
            }
            y += tileHeight
        }
        return images
    }
    
}
