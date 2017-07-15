//
//  PersistentDataHelper.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

class PersistentDataHelper: NSObject {
    struct DefaultStoreKey {
        static let endPoint: String = "appEndPoint"
        static let isLogEnableKey: String = "isLogEnable"
    }
    static let userDefaults = UserDefaults.standard
    class func saveValueForKey(_ value: AnyObject?, key: String) {
        userDefaults.setValue(value, forKey: key)
        userDefaults.synchronize()
    }
    class func getValueForKey(_ key: String) -> AnyObject? {
        return userDefaults.value(forKey: key) as AnyObject?
    }
}
