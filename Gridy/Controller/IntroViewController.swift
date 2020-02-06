//
//  IntroViewController.swift
//  Gridy

import UIKit
import Photos
import AVFoundation

class IntroViewController: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
    
    var creation = Creation.init()
    var localImagesArray = [UIImage].init()
    let imagePickerController = UIImagePickerController()
    var newImage = UIImage.init()
    var pickedImage = UIImage()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        buildLocalImageSet()
    }
    
    // MARK: - Button listeners
    @IBAction func pickButtonTapped(_ sender: UIButton) {
        pickRandom()
    }
    
    @IBAction func cameraButtonTapped(_ sender: UIButton) {
        displayCamera()
    }
    
    @IBAction func libraryButtonTapped(_ sender: UIButton) {
        displayLibrary()
    }
    
    // MARK: - access camera
    func displayCamera() {
        let sourceType = UIImagePickerController.SourceType.camera
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
            let noPermissionMessage = "Gridy is not able to access your camera! Please check your settings."
            switch status {
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: {(granted) in
                    if granted {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionMessage)
            @unknown default:
                fatalError(noPermissionMessage)
            }
        } else {
            troubleAlert(message: "it looks like we can't access the camera. Please try again later.")
        }
    }
    
    // MARK: - Access library
    func displayLibrary() {
        let sourceType = UIImagePickerController.SourceType.photoLibrary
        
        if UIImagePickerController.isSourceTypeAvailable(sourceType) {
            let status = PHPhotoLibrary.authorizationStatus()
            let noPermissionStatusMessage = "Gridy is not able to access the Photo Library! Please check your settings."
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization({ (newStatus) in
                    if newStatus == .authorized {
                        self.presentImagePicker(sourceType: sourceType)
                    } else {
                        self.troubleAlert(message: noPermissionStatusMessage)
                    }
                })
            case .authorized:
                self.presentImagePicker(sourceType: sourceType)
            case .denied, .restricted:
                self.troubleAlert(message: noPermissionStatusMessage)
            @unknown default:
                self.presentImagePicker(sourceType: sourceType)
            }
        } else {
            troubleAlert(message: "Sincere apologise, it looks like we can't access your photo library at this time")
        }
    }
    
    // MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ImageEditorViewSegue" {
            let imageEditorView = segue.destination as! EditImageViewController
            imageEditorView.imageReceived = creation.image
        }
    }
    
    func pickRandom() {
        processPicked(image: pickRandomImage())
        performSegue(withIdentifier: "ImageEditorViewSegue", sender: self)
    }
    
    func processPicked(image: UIImage?) {
        if  let newImage = image {
            creation.image = newImage
        }
    }
    
}

// MARK: - ImagePicker
extension IntroViewController: UIImagePickerControllerDelegate {

    func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let newImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        processPicked(image: newImage)
        dismiss(animated: true, completion: { () -> Void in
            self.performSegue(withIdentifier: "ImageEditorViewSegue", sender: self)
        })
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Helper methods
extension IntroViewController {

    func troubleAlert(message: String?) {
        let alertController = UIAlertController(title: "Oops...", message: message, preferredStyle: .alert)
        let OKAction = UIAlertAction(title: "Got it.", style: .cancel)
        alertController.addAction(OKAction)
        present(alertController, animated: true)
    }
    
    
    func pickRandomImage() -> UIImage? {
        let currentImage = creation.image
        if localImagesArray.count > 0 {
            while true {
                let randomIndex = Int.random(in: 0..<localImagesArray.count)
                let newImage = localImagesArray[randomIndex]
                if newImage != currentImage {
                    return newImage
                }
            }
        }
        print("randomImage()=nil")
        troubleAlert(message: "No Image")
        return nil
    }
    
    func buildLocalImageSet() {
        localImagesArray.removeAll()
        let imageNames = [
            "Boats",
            "Dooby",
            "Frog",
            "Orangutan",
            "Park",
            "Plant",
            "TShirts",
            "Wands"
        ]
        for name in imageNames {
            if let image = UIImage.init(named: name) {
                localImagesArray.append(image)
            }
        }
    }

}

