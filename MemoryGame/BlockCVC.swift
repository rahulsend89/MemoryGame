//
//  BlockCVC.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit.UICollectionViewCell

class BlockCVC: UICollectionViewCell {
    // MARK: - Properties

    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!

    var block: Block? {
        didSet {
            guard let block = block else { return }
            frontImageView.image = block.image
        }
    }

    fileprivate(set) var shown: Bool = false

    // MARK: - Methods

    func showBlock(_ show: Bool, animted: Bool) {
        frontImageView.isHidden = false
        backImageView.isHidden = false
        shown = show

        if animted {
            if show {
                UIView.transition(from: backImageView,
                                  to: frontImageView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromRight, .showHideTransitionViews],
                                  completion: { (_: Bool) -> Void in
                })
            } else {
                UIView.transition(from: frontImageView,
                                  to: backImageView,
                                  duration: 0.5,
                                  options: [.transitionFlipFromRight, .showHideTransitionViews],
                                  completion: { (_: Bool) -> Void in
                })
            }
        } else {
            if show {
                bringSubview(toFront: frontImageView)
                backImageView.isHidden = true
            } else {
                bringSubview(toFront: backImageView)
                frontImageView.isHidden = true
            }
        }
    }

}
