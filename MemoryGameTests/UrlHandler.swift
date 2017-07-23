//
//  JsonSpec.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/16/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation
import Quick
import Nimble

@testable import MemoryGame

class UrlHandler: QuickSpec {

    let timeOut: Double = 3.0

    override func spec() {
        beforeEach {
            StubsManager.removeAllStubs()
        }
        it("photoModelURL response with test.json") {
            _ = StubsManager.stubRequestsPassingTest(withStubResponse: { (_) -> StubResponse in
                return StubResponse(data:StubsManager.getDataFromFile("test"), statusCode: 200)
            })
            var responseObj: PhotoModel?
            ServiceManager.sharedInstance.photoModelURL(ServiceConfig.sharedInstance.getMyPhotoUrl(), handlerError: { (error) in
                LogHelper.sharedInstance.log("Error->gettingData() Error: \(String(describing: error))")
                ErrorHandler.sharedInstance.ProcessError(error!)
            }) { (returnObject) in
                guard let photoModelResponse: PhotoModel = returnObject as? PhotoModel else {
                    LogHelper.sharedInstance.log("Something is not right :(")
                    return
                }
                responseObj = photoModelResponse
            }
            expect(responseObj?.photo).toEventuallyNot(beNil(), timeout: self.timeOut)
            expect(responseObj?.page).toEventuallyNot(beNil(), timeout: self.timeOut)
            expect(responseObj?.pages).toEventuallyNot(beNil(), timeout: self.timeOut)
            expect(responseObj?.perpage).toEventuallyNot(beNil(), timeout: self.timeOut)
            expect(responseObj?.total).toEventuallyNot(beNil(), timeout: self.timeOut)
        }
    }
}
