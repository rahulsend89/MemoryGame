//
//  Block.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

import Foundation
import UIKit.UIImage

class Block: CustomStringConvertible {

    // MARK: - Properties

    var id: UUID = UUID.init()
    var shown: Bool = false
    var image: UIImage

    // MARK: - Lifecycle

    init(image: UIImage) {
        self.image = image
    }

    init(block: Block) {
        if let _id = (block.id as NSUUID).copy() as? UUID {
            self.id = _id
        }else{
            self.id = UUID.init()
        }
        if let _image = block.image.copy() as? UIImage {
            self.image = _image
        }else{
            self.image = UIImage()
        }
        self.shown = block.shown
        
    }

    // MARK: - Methods

    var description: String {
        return "\(id.uuidString)"
    }

    func equals(_ block: Block) -> Bool {
        return (block.id == id)
    }
}
