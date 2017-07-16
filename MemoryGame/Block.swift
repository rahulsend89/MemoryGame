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

class Block : CustomStringConvertible {
    
    // MARK: - Properties
    
    var id:UUID = UUID.init()
    var shown:Bool = false
    var image:UIImage
    
    // MARK: - Lifecycle
    
    init(image:UIImage) {
        self.image = image
    }
    
    init(block:Block) {
        self.id = (block.id as NSUUID).copy() as! UUID
        self.shown = block.shown
        self.image = block.image.copy() as! UIImage
    }
    
    // MARK: - Methods
    
    var description: String {
        return "\(id.uuidString)"
    }
    
    func equals(_ block: Block) -> Bool {
        return (block.id == id)
    }
}
