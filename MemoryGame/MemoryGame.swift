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
    func memoryGameDidStart()
    func memoryGame(showBlocks blocks: [Block])
    func memoryGame(hideBlocks blocks: [Block])
    func memoryGameSelectRandom(selectImage:UIImage)
    func memoryGameDidEnd()
    
}

// MARK: - MemoryGame

class MemoryGame {
    
    // MARK: - Properties
    
    var blocks:[Block] = [Block]()
    var delegate: MemoryGameDelegate?
    var isPlaying:Bool = false
    var currentCount:Int = 0
    var randomBlockArray:[Int] = Array(0...MemoryGame.maxGrid-1)
    var currentVal:Int = 0
    static let maxGrid: Int = 9
    
    fileprivate var blocksShown:[Block] = [Block]()
    fileprivate var startTime:Date?
    
    var numberOfBlocks: Int {
        get {
            return blocks.count
        }
    }
    
    // MARK: - Methods
    
    func newGame(_ blocksData:[UIImage]) {
        blocks = randomBlocks(blocksData)
        startTime = Date.init()
        isPlaying = true
        selectRandomImage()
        delegate?.memoryGameDidStart()
    }
    
    func selectRandomImage(){
        currentVal = randomBlockArray[Int(arc4random_uniform(UInt32(randomBlockArray.count)))];
        delegate?.memoryGameSelectRandom(selectImage: (blockAtIndex(currentVal)?.image)!)
    }
    
    func stopGame() {
        isPlaying = false
        blocks.removeAll()
        blocksShown.removeAll()
        startTime = nil
    }
    
    func didSelectBlock(_ block: Block?) {
        guard let block = block else { return }
        
        delegate?.memoryGame(showBlocks: [block])
        var selected = false
        if indexForBlock(block) == currentVal {
            selected = true
            randomBlockArray.remove(at: randomBlockArray.index(of: currentVal)!)
            blocksShown.append(block)
        } else {
            let delayTime = DispatchTime.now() + Double(Int64(1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: delayTime) {
                self.delegate?.memoryGame(hideBlocks:[block])
            }
        }
        if blocksShown.count == blocks.count {
            finishGame()
        } else{
            if(selected){
                selectRandomImage()
            }
        }
    }
    
    func blockAtIndex(_ index: Int) -> Block? {
        if blocks.count > index {
            return blocks[index]
        } else {
            return nil
        }
    }
    
    func indexForBlock(_ block: Block) -> Int? {
        for index in 0...blocks.count-1 {
            if block === blocks[index] {
                return index
            }
        }
        return nil
    }

    
    fileprivate func finishGame() {
        isPlaying = false
        delegate?.memoryGameDidEnd()
    }
    
    fileprivate func lastBlock() -> Bool {
        return blocksShown.count == 0
    }
    
    fileprivate func unpairedBlock() -> Block? {
        let unpairedBlock = blocksShown.last
        return unpairedBlock
    }
    
    fileprivate func randomBlocks(_ blocksData:[UIImage]) -> [Block] {
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

