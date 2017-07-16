//
//  StubURLProtocol.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/16/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation

class StubURLProtocol: URLProtocol,DelayHelper {

    var stopped = false

    override class func canInit(with request: URLRequest) -> Bool {
        return StubsManager.sharedManager.firstStubPassingTestForRequest(request) != nil
    }

    override class func canInit(with task: URLSessionTask) -> Bool {
        return StubsManager.sharedManager.firstStubPassingTestForRequest(task.currentRequest!) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let stub = StubsManager.sharedManager.firstStubPassingTestForRequest(request), let responseStub: StubResponse = stub.responseBlock(self.request) else {
            self.client?.urlProtocolDidFinishLoading(self)
            return
        }

        let urlResponse = HTTPURLResponse(url: self.request.url!, statusCode: responseStub.statusCode, httpVersion: "HTTP/1.1", headerFields: responseStub.headers)

        // handle redirect
        var redirectLocationURL: URL? = nil

        if let headers = responseStub.headers, let redirectLocation = headers["Location"] {
            redirectLocationURL = URL(string:redirectLocation)
        }

        if let redirectLocationURL_ = redirectLocationURL , responseStub.statusCode >= 300 && responseStub.statusCode < 400 {
            let redirectRequest = URLRequest(url: redirectLocationURL_)

            execute_after(responseStub.requestTime) {
                if (!self.stopped) {
                    self.client?.urlProtocol(self, wasRedirectedTo: redirectRequest, redirectResponse: urlResponse!)
                }
            }

        } else { // normal response
            execute_after(responseStub.requestTime) {
                if (!self.stopped) {
                    self.client?.urlProtocol(self, didReceive: urlResponse!, cacheStoragePolicy: URLCache.StoragePolicy.notAllowed)
                    if let data = responseStub.data {
                        self.client?.urlProtocol(self, didLoad: data)
                    } else {
                        self.client?.urlProtocol(self, didLoad:Data())
                    }
                    self.client?.urlProtocolDidFinishLoading(self)
                }
            }
        }
    }

    override func stopLoading() {
        stopped = true
    }
}
