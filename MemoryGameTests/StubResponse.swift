//
//  StubResponse.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/16/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation

open class StubResponse {

    let headers: Dictionary<String, String>?
    let statusCode: Int
    let data: Data?
    let requestTime: TimeInterval

    public init(data: Data?=nil, statusCode: Int, headers: Dictionary<String, String>? = nil, requestTime: TimeInterval=0.0) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
        self.requestTime = requestTime
    }
}
