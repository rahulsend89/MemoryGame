//
//  DelayHelper.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/16/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

protocol DelayHelper {
    func execute_after(_ delayInSeconds: TimeInterval, block: @escaping ()->())
}

extension DelayHelper{
    func execute_after(_ delayInSeconds: TimeInterval, block: @escaping ()->()) {
        let popTime = DispatchTime.now() + Double(Int64( delayInSeconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: popTime, execute: block)
    }
}
