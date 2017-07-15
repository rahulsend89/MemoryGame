//
//  LogHelper.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation
class LogHelper: NSObject {
    
    static let sharedInstance = LogHelper()
    
    func log(_ str: Any) {
        if PersistentDataHelper.userDefaults.bool(forKey: PersistentDataHelper.DefaultStoreKey.isLogEnableKey) {
            DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.low).async {
                guard let strIns = str as? NSString else {
                    return
                }
                //remove logs from build .
                NSLog("MemoryGameLogs : ______________ : %@", strIns)
            }
        }
    }
}
