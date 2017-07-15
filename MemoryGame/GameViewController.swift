//
//  ViewController.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, MemoryGameDelegate {
    
    // MARK: Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    
    let gameController = MemoryGame()
    var _isPlaying:Bool = false
    var _numberOfCards:Int = 9
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameController.delegate = self
        resetGame()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if gameController.isPlaying {
            resetGame()
        }
    }
    
    // MARK: - Methods
    
    func resetGame() {
        gameController.isPlaying  = false
        collectionView.isUserInteractionEnabled = false
        collectionView.reloadData()
        playButton.setTitle(NSLocalizedString("Play", comment: "play"), for: UIControlState())
    }
    
    @IBAction func didPressPlayButton() {
        if gameController.isPlaying {
            resetGame()
            playButton.setTitle(NSLocalizedString("Play", comment: "play"), for: UIControlState())
        } else {
            setupNewGame()
            playButton.setTitle(NSLocalizedString("Stop", comment: "stop"), for: UIControlState())
        }
    }
    
    func setupNewGame() {
        ActivityIndicator.sharedInstance.show()
        ServiceManager.sharedInstance.photoModelURL(ServiceConfig.sharedInstance.getMyPhotoUrl(), handlerError: { (error) in
            LogHelper.sharedInstance.log("Error->gettingData() Error: \(String(describing: error))")
            ErrorHandler.sharedInstance.ProcessError(error!)
        }) { (returnObject) in
            if let responseObj = returnObject , responseObj.isKind(of: PhotoModel.self) {
                guard let photoModelResponse: PhotoModel = returnObject as? PhotoModel else {
                    LogHelper.sharedInstance.log("Something is not right :(")
                    return
                }
                var arrayImages:[UIImage] = []
                var outDataArray = photoModelResponse.photo!
                outDataArray.shuffle()
                for (photo) in outDataArray.prefix(9) {
                    LogHelper.sharedInstance.log(" : \(photo.imageString) : ");
                    ServiceManager.sharedInstance.imageWithURL(ServiceConfig.sharedInstance.getImage(returnPath: photo.imageString), handlerError: { (_error) in
                        LogHelper.sharedInstance.log("Error->gettingData() Error: \(String(describing: _error))")
                        ErrorHandler.sharedInstance.ProcessError(_error!)
                    }) { (_responseData) in
                      arrayImages.append(UIImage(data: _responseData as! Data)!)
                        if(arrayImages.count == 9){
                            ActivityIndicator.sharedInstance.hide()
                            self.gameController.newGame(arrayImages)
                        }
                    }
                }
                
            }
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameController.numberOfCards > 0 ? gameController.numberOfCards : 9
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cardCell", for: indexPath) as! BlockCVC
        cell.showCard(false, animted: false)
        
        guard let card = gameController.blockAtIndex(indexPath.item) else { return cell }
        cell.card = card
        
        return cell
    }
    
    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! BlockCVC
        
        if cell.shown { return }
        gameController.didSelectCard(cell.card)
        
        collectionView.deselectItem(at: indexPath, animated:true)
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let numberOfColumns:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
        
        let itemWidth: CGFloat = collectionView.frame.width / 3.0 - 15.0 //numberOfColumns as CGFloat - 10 //- (minimumInteritemSpacing * numberOfColumns))
        
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    // MARK: - MemoryGameDelegate
    
    func memoryGameDidStart(_ game: MemoryGame) {
        collectionView.reloadData()
        collectionView.isUserInteractionEnabled = true
    }
    
    func memoryGame(_ game: MemoryGame, showCards cards: [Block]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! BlockCVC
            cell.showCard(true, animted: true)
        }
    }
    
    func memoryGame(_ game: MemoryGame, hideCards cards: [Block]) {
        for card in cards {
            guard let index = gameController.indexForCard(card) else { continue }
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as! BlockCVC
            cell.showCard(false, animted: true)
        }
    }
    
    
    func memoryGameDidEnd(_ game: MemoryGame) {
        
        
        let alertController = UIAlertController(
            title: NSLocalizedString("Hurrah!", comment: "title"),
            message: String(format: "%@", NSLocalizedString("You finished the game in", comment: "message")),
            preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "dismiss"), style: .cancel) { [weak self] (action) in
            self?.resetGame()
        }
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) { }
    }

}
