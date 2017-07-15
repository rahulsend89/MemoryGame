//
//  Card.swift
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
    
    init(card:Block) {
        self.id = (card.id as NSUUID).copy() as! UUID
        self.shown = card.shown
        self.image = card.image.copy() as! UIImage
    }
    
    // MARK: - Methods
    
    var description: String {
        return "\(id.uuidString)"
    }
    
    func equals(_ card: Block) -> Bool {
        return (card.id == id)
    }
}
