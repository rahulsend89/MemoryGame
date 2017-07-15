//
//  MemoryGame.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

import Foundation
import UIKit.UIImage

// MARK: - MemoryGameDelegate

protocol MemoryGameDelegate {
    func memoryGameDidStart(_ game: MemoryGame)
    func memoryGame(_ game: MemoryGame, showCards blocks: [Block])
    func memoryGame(_ game: MemoryGame, hideCards blocks: [Block])
    func memoryGameDidEnd(_ game: MemoryGame)
}

// MARK: - MemoryGame

class MemoryGame {
    
    // MARK: - Properties
    
    var blocks:[Block] = [Block]()
    var delegate: MemoryGameDelegate?
    var isPlaying: Bool = false
    
    fileprivate var blocksShown:[Block] = [Block]()
    fileprivate var startTime:Date?
    
    var numberOfCards: Int {
        get {
            return blocks.count
        }
    }
    
    // MARK: - Methods
    
    func newGame(_ blocksData:[UIImage]) {
        blocks = randomCards(blocksData)
        startTime = Date.init()
        isPlaying = true
        delegate?.memoryGameDidStart(self)
    }
    
    func stopGame() {
        isPlaying = false
        blocks.removeAll()
        blocksShown.removeAll()
        startTime = nil
    }
    
    func didSelectCard(_ block: Block?) {
        guard let block = block else { return }
        
        delegate?.memoryGame(self, showCards: [block])
        
//        if lastBlock() {
//            let unpaired = unpairedCard()!
//            if block.equals(unpaired) {
//                blocksShown.append(block)
//            } else {
//                let unpairedCard = blocksShown.removeLast()
//                
//                let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//                DispatchQueue.main.asyncAfter(deadline: delayTime) {
//                    self.delegate?.memoryGame(self, hideCards:[block, unpairedCard])
//                }
//            }
//        } else {
//            blocksShown.append(block)
//        }
        
        if blocksShown.count == blocks.count {
            finishGame()
        }
    }
    
    func blockAtIndex(_ index: Int) -> Block? {
        if blocks.count > index {
            return blocks[index]
        } else {
            return nil
        }
    }
    
    func indexForCard(_ block: Block) -> Int? {
        for index in 0...blocks.count-1 {
            if block === blocks[index] {
                return index
            }
        }
        return nil
    }
    
    fileprivate func finishGame() {
        isPlaying = false
        delegate?.memoryGameDidEnd(self)
    }
    
    fileprivate func lastBlock() -> Bool {
        return blocksShown.count == 0
    }
    
    fileprivate func unpairedCard() -> Block? {
        let unpairedCard = blocksShown.last
        return unpairedCard
    }
    
    fileprivate func randomCards(_ blocksData:[UIImage]) -> [Block] {
        var blocks = [Block]()
        for i in 0...blocksData.count-1 {
            let block = Block.init(image: blocksData[i])
            blocks.append(block)
        }
        blocks.shuffle()
        return blocks
    }
    
}

extension Array {
    //Randomizes the order of the array elements
    mutating func shuffle() {
        for _ in 1...self.count {
            self.sort { (_,_) in arc4random() < arc4random() }
        }
    }
}

