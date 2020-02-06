//
//  GridyGameOverView.swift
//  Gridy
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var interactionsLabel: UILabel!
    @IBOutlet weak var gameOverViewBackgroundImage: UIImageView!

    var gameOverInteractionData = Int()
    var gameOverScoreData = Int()
    var frameImage = UIImage()
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        scoreLabel.text = "Your final score: \(gameOverScoreData)"
        interactionsLabel.text = "Total interactions: \(gameOverInteractionData)"
        gameOverViewBackgroundImage.image = frameImage
    }
    
    // MARK: - Listeners
    @IBAction func optionsButton(_ sender: UIButton) {
        self.showAlert()
    }
    
    // MARK: - Helpers
    func showAlert() {
        let alert = UIAlertController(title: "Well done!", message: "Your final score: \(gameOverScoreData) \nTotal interactions: \(gameOverInteractionData)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Play again!", style: UIAlertAction.Style.default) {(action) in
            self.performSegue(withIdentifier: "IntroViewSegue", sender: self)
        })
        alert.addAction(UIAlertAction(title: "Share your score :)", style: .default) {(action) in
            self.displaySharingOptions()
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive) {(action) in
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    func displaySharingOptions() {
        let note = "DONE!"
        let image = frameImage
        let items = [image as Any, note as Any]
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        //adapt for iPad
        activityViewController.popoverPresentationController?.sourceView = view
        //present activity view controller
        present(activityViewController, animated: true, completion: nil)
    }
}


