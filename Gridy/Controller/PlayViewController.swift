//
//  PlayfieldViewController.swift
//  Gridy

import UIKit
import Photos
import AVFoundation

class PlayViewController: UIViewController, AVAudioPlayerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var soundButton: UIButton!
    @IBOutlet weak var playfieldViewCollectionViewOne: UICollectionView!
    @IBOutlet weak var playfieldViewCollectionViewTwo: UICollectionView!
    @IBOutlet weak var playfieldViewScoreLabel: UILabel!
    @IBOutlet weak var playfieldViewPopUpView: UIImageView!

    var interactionCount: Int = 0
    var scoreData: Int = 0
    var soundPlay: AVAudioPlayer?
    var isSoundEnabled: Bool = true
    var indexPath: IndexPath?
    var imageRecieved = [UIImage]()
    var popUpImage = UIImage()
    var imageArrayCVOne :[UIImage]!
    var imageArrayCVTwo = [UIImage]()
    var fixedImages = [UIImage(named: "Gridy-lookup")]
    
    
    // MARK: - Lifecycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        imageArrayCVOne = imageRecieved
        imageArrayCVOne.shuffle()
        playfieldViewCollectionViewOne.reloadData()
        playfieldViewPopUpView.image = popUpImage
        playfieldViewPopUpView.isHidden = true
        for image in fixedImages {
            if let image = image {
                imageArrayCVOne.append(image)
            }
        }
        playfieldViewCollectionViewOne.dragInteractionEnabled = true
        playfieldViewCollectionViewTwo.dragInteractionEnabled = true
        if imageArrayCVTwo.count == 0 {
            if let blank = UIImage(named: "Placeholder") {
                var temp = [UIImage]()
                for _ in imageRecieved {
                    temp.append(blank)
                }
                imageArrayCVTwo = temp
                playfieldViewCollectionViewTwo.reloadData()
            }
        }
        soundButton.setImage(#imageLiteral(resourceName: "Sound-on"), for: .normal)
        soundButton.setImage(#imageLiteral(resourceName: "Sound-off"), for: .selected)
    }

    // MARK: - Segue methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GridyGameOverViewSegue" {
            let gameOverView = segue.destination as! GameViewController
            gameOverView.gameOverInteractionData = interactionCount
            gameOverView.gameOverScoreData = udpateScore()
            gameOverView.frameImage = popUpImage
        }
    }
    
    // MARK: - Play sound
    func playSound() {
        if isSoundEnabled == true {
            soundPlay = AVAudioPlayer()
            let soundURL = Bundle.main.url(forResource: "GridySound", withExtension: "wav")
            do {
                soundPlay = try AVAudioPlayer(contentsOf: soundURL!)
                print("sound is playing!!")
            }
            catch {
                print (error.localizedDescription)
            }
            soundPlay!.play()
        }
    }
    
    @IBAction func soundOnOffButton(_ sender: UIButton) {
        soundButton.isSelected = !soundButton.isSelected
        if sender .isSelected {
            isSoundEnabled = false
        } else {
            isSoundEnabled = true
        }
    }
    
    
    // new game button
    @IBAction func playfieldViewNewGameButton(_ sender: UIButton) {
    }
    
    // confirgure collection view
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == self.playfieldViewCollectionViewOne ? imageArrayCVOne.count : imageArrayCVTwo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PlayfieldViewCollectionViewCell", for: indexPath) as! PlayfieldViewCVImageView
        
        // collection view 1
        if collectionView == playfieldViewCollectionViewOne {
            let width = (playfieldViewCollectionViewOne.frame.size.width - 30) / 6
            let layout = playfieldViewCollectionViewOne.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            cell.playfieldImageView.image = imageArrayCVOne[indexPath.item]
            
            // collection view 2
        } else {
            let width = (playfieldViewCollectionViewTwo.frame.size.width - 10) / 4
            let layout = playfieldViewCollectionViewTwo.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSize(width: width, height: width)
            cell.playfieldImageView.image = imageArrayCVTwo[indexPath.item]
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item == (imageArrayCVOne.count - 1) {
            playfieldViewPopUpView.isHidden = false
            Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.hidePopUpImage), userInfo: nil, repeats: false)
        }
    }
    
    @objc func hidePopUpImage() {
        playfieldViewPopUpView.isHidden = true
    }
}

// MARK: - Drop and drag
extension PlayViewController: UICollectionViewDragDelegate, UICollectionViewDropDelegate, UIDropInteractionDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        
        self.indexPath = indexPath
        let item: UIImage
        let image = imageArrayCVOne[indexPath.item]
        if (image == fixedImages.last) || (image == fixedImages.first) {
            return []
        }
        if collectionView == playfieldViewCollectionViewOne {
            item = image
        } else {
            item = (self.imageArrayCVTwo[indexPath.row])
        }
        let itemProvider = NSItemProvider(object: item as UIImage)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if destinationIndexPath?.row == 16 || destinationIndexPath?.row == 17 {
            return UICollectionViewDropProposal(operation: .forbidden)
        } else if collectionView === playfieldViewCollectionViewTwo {
            return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        } else if collectionView === playfieldViewCollectionViewOne && playfieldViewCollectionViewTwo.hasActiveDrag {
            return UICollectionViewDropProposal(operation: .move, intent: .insertIntoDestinationIndexPath)
        } else {
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let dip: IndexPath
        if let indexPath = coordinator.destinationIndexPath {
            dip = indexPath
        } else {
            let section = collectionView.numberOfSections - 1
            let row = collectionView.numberOfItems(inSection: section)
            dip = IndexPath(row: row, section: section)
        }
        if dip.row == 16 || dip.row == 17 {
            return
        }
        if collectionView === playfieldViewCollectionViewTwo {
            moveItems(coordinator: coordinator, destinationIndexPath: dip, collectionView: collectionView)
        } else if collectionView === playfieldViewCollectionViewOne {
            return
        }
    }
    
    // drop and drag interactions
    private func moveItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView) {
        let items = coordinator.items
        updateInteractionCount(interactionData: interactionCount + 1) // total touches
        collectionView.performBatchUpdates({
            let dragItem = items.first!.dragItem.localObject as! UIImage
            if dragItem === imageRecieved[destinationIndexPath.item] {
                scoreData += 1
                self.imageArrayCVTwo.insert(items.first!.dragItem.localObject as! UIImage, at: destinationIndexPath.row)
                playfieldViewCollectionViewTwo.insertItems(at: [destinationIndexPath])
                if let selected = indexPath {
                    imageArrayCVOne.remove(at: selected.row)
                    if let temp = UIImage(named: "Placeholder") {
                        let blank = temp
                        imageArrayCVOne.insert(blank, at: selected.row)
                    }
                    playfieldViewCollectionViewOne.reloadData()
                    playSound()
                }
            }
        })
        collectionView.performBatchUpdates({
            if items.first!.dragItem.localObject as! UIImage === imageRecieved[destinationIndexPath.item] {
                self.imageArrayCVTwo.remove(at: destinationIndexPath.row + 1)
                let nextIndexPath = NSIndexPath(row: destinationIndexPath.row + 1, section: 0)
                playfieldViewCollectionViewTwo.deleteItems(at: [nextIndexPath] as [IndexPath])
            } else {
                
            }
        })
        coordinator.drop(items.first!.dragItem, toItemAt: destinationIndexPath)
        if scoreData == imageArrayCVTwo.count {
            performSegue(withIdentifier: "GridyGameOverViewSegue", sender: nil)
        }
    }
}


// MARK: - Scoring
extension PlayViewController {
    func updateInteractionCount(interactionData: Int) {
        self.interactionCount += 1
        playfieldViewScoreLabel.text = "\(interactionData)"
    }
    
    func udpateScore() -> Int {
        let score = scoreData * scoreData - (interactionCount - scoreData)
        return score
    }
}




    

