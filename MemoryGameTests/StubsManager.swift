//
//  StubsManager.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/16/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation

@testable import MemoryGame

public typealias StubResponseBlock = (URLRequest) -> StubResponse

open class StubsManager {

    //helper function

    class func getDataFromFile(_ myurl: String) -> Data {
        let path = Bundle.main.path(forResource: myurl, ofType: "json", inDirectory: nil)!
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path),
            options: NSData.ReadingOptions.uncached) else {return NSData() as Data}
        return data
    }

    fileprivate(set) var stubDescriptors = [StubDescriptor]()

    // holds the singleton StubManager
    static let sharedManager = StubsManager()

    init() {
        Utils.swizzleFromSelector("defaultSessionConfiguration", toSelector: "swizzle_defaultSessionConfiguration", forClass: URLSessionConfiguration.self)
        Utils.swizzleFromSelector("ephemeralSessionConfiguration", toSelector: "swizzle_ephemeralSessionConfiguration", forClass: URLSessionConfiguration.self)
        URLCache.shared.removeAllCachedResponses()
    }

    open class func stubRequestsPassingTest(withStubResponse responseBlock: @escaping StubResponseBlock) -> StubDescriptor {
        let stubDesc = StubDescriptor(responseBlock: responseBlock)
        URLProtocol.registerClass(StubURLProtocol.self)
        StubsManager.sharedManager.stubDescriptors.append(stubDesc)
        return stubDesc
    }

    open class func addStub(_ stubDescr: StubDescriptor) {
        StubsManager.sharedManager.stubDescriptors.append(stubDescr)
    }

    open class func removeStub(_ stubDescr: StubDescriptor) {
        if let index = StubsManager.sharedManager.stubDescriptors.index(of: stubDescr) {
            StubsManager.sharedManager.stubDescriptors.remove(at: index)
        }
    }

    open class func removeLastStub() {
        StubsManager.sharedManager.stubDescriptors.removeLast()
    }

    open class func removeAllStubs() {
        StubsManager.sharedManager.stubDescriptors.removeAll(keepingCapacity: false)
    }

    func firstStubPassingTestForRequest(_ request: URLRequest) -> StubDescriptor? {
        let count = stubDescriptors.count
        guard count>0 else {
            return nil
        }
        for (_, stubDescr) in stubDescriptors.enumerated() {
            return stubDescr
        }

        return nil
    }
}

open class StubDescriptor: Equatable {
    let responseBlock: StubResponseBlock
    init(responseBlock: @escaping StubResponseBlock) {
        self.responseBlock = responseBlock
    }
}

public func ==(lhs: StubDescriptor, rhs: StubDescriptor) -> Bool {
    // identify check
    return lhs === rhs
}

open class Utils {

    class func swizzleFromSelector(_ selector: String!, toSelector: String!, forClass: AnyClass!) {

        let originalMethod = class_getClassMethod(forClass, Selector(selector))
        let swizzledMethod = class_getClassMethod(forClass, Selector(toSelector))

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    class func swizzleFromSelector(_ selector: Selector!, toSelector: Selector!, forClass: AnyClass!) {

        let originalMethod = class_getClassMethod(forClass, selector)
        let swizzledMethod = class_getClassMethod(forClass, toSelector)

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
}

extension URLSessionConfiguration {

    class func swizzle_defaultSessionConfiguration() -> URLSessionConfiguration! {
        let config = swizzle_defaultSessionConfiguration()
        // add our stub
        config?.protocolClasses?.removeAll(keepingCapacity: false)
        config?.protocolClasses?.append(StubURLProtocol.self)

        return config
    }

    class func swizzle_ephemeralSessionConfiguration() -> URLSessionConfiguration! {
        let config = swizzle_ephemeralSessionConfiguration()

        config?.protocolClasses?.removeAll(keepingCapacity: false)
        config?.protocolClasses?.append(StubURLProtocol.self)

        return config
    }
}
