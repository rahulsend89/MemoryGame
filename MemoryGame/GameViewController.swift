//
//  ViewController.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

class GameViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
    MemoryGameDelegate, DelayHelper {

    // MARK: Properties

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var currentImage: UIImageView!

    let gameController = MemoryGame()
    let gameStartTimer = 9.0

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
        for cell in collectionView.visibleCells {
            if let cellBlock = cell as? BlockCVC {
                cellBlock.block?.image = UIImage()
            }
        }
        currentImage.image = UIImage()
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
        }) { [weak self] (returnObject) in
            guard let photoModelResponse: PhotoModel = returnObject as? PhotoModel else {
                LogHelper.sharedInstance.log("Something is not right :(")
                return
            }
            var arrayImages: [UIImage] = []
            var outDataArray = photoModelResponse.photo!
            let parentWeakRef = self
            outDataArray.shuffle()
            for (photo) in outDataArray.prefix(MemoryGame.maxGrid) {
                let configUrl = ServiceConfig.sharedInstance.getImage(
                    farm: photo.farm ?? 0,
                    server: photo.server ?? "",
                    photoId: photo.photoId ?? "",
                    secret: photo.secret ?? "")
                ServiceManager.sharedInstance.imageWithURL(configUrl, handlerError: { (_error) in
                    LogHelper.sharedInstance.log("Error->gettingImages() Error: \(String(describing: _error))")
                    ErrorHandler.sharedInstance.ProcessError(_error!)
                }) { (imageData) in
                    guard let _imageDataVal = imageData as? Data, let _imageData = UIImage(data: _imageDataVal) else {return}
                    arrayImages.append(_imageData )
                    if arrayImages.count == MemoryGame.maxGrid {
                        ActivityIndicator.sharedInstance.hide()
                        parentWeakRef?.gameController.newGame(arrayImages)
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
        return gameController.numberOfBlocks > 0 ? gameController.numberOfBlocks : MemoryGame.maxGrid
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "blockCell", for: indexPath) as? BlockCVC else {
            return  UICollectionViewCell()
        }
        cell.showBlock(true, animted: false)

        guard let block = gameController.blockAtIndex(indexPath.item) else { return cell }
        cell.block = block

        return cell
    }

    // MARK: UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? BlockCVC else {return}

        if cell.shown { return }
        gameController.didSelectBlock(cell.block)

        collectionView.deselectItem(at: indexPath, animated:true)
    }

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //let numberOfColumns:Int = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)

        let itemWidth: CGFloat = collectionView.frame.width / 3.0 - 15.0 //numberOfColumns as CGFloat - 10 //- (minimumInteritemSpacing * numberOfColumns))

        return CGSize(width: itemWidth, height: itemWidth)
    }

    // MARK: - MemoryGameDelegate

    func memoryGameDidStart() {
        collectionView.reloadData()
        collectionView.isUserInteractionEnabled = true
        execute_after(gameStartTimer) {
            self.memoryGameHideAll()
        }
    }

    func memoryGameSelectRandom(selectImage: UIImage) {
        currentImage.image = selectImage
    }

    func memoryGame(showBlocks blocks: [Block]) {
        for block in blocks {
            guard let index = gameController.indexForBlock(block) else { continue }
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as? BlockCVC else {return}
            cell.showBlock(true, animted: true)
        }
    }

    func memoryGame(hideBlocks blocks: [Block]) {
        for block in blocks {
            guard let index = gameController.indexForBlock(block) else { continue }
            guard let cell = collectionView.cellForItem(at: IndexPath(item: index, section:0)) as? BlockCVC else {return}
            cell.showBlock(false, animted: true)
        }
    }

    func memoryGameHideAll() {
        for cell in collectionView.visibleCells {
            if let cellBlock = cell as? BlockCVC {
                cellBlock.showBlock(false, animted: true)
            }
        }
    }

    func memoryGameDidEnd() {
        UIAlertControllerHelper.sharedInstance.showDismissAlert("FINISHED_HEADER".localized, "AWESOME_MESSAGE".localized) {[weak self] _ in
            self?.resetGame()
        }
    }
}
