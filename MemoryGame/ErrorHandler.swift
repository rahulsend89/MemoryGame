//
//  ErrorHandler.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation

struct ErrorCode {
    static let networkErrorCode: Int = 404
    static let httpErrorCode: Int = 403
    static let invalidTokenErrorCode: Int = 1000
    static let defaultErrorCode: Int = -1003
    static let cancelledErrorCode: Int = -999
}

func makeError(_ text: String="") -> NSError {
    let code: Int = ErrorCode.networkErrorCode
    return NSError(domain: "HTTPTask", code: code, userInfo: [NSLocalizedDescriptionKey: text])
}

func makeErrorWithDifferentCode(_ text: String="") -> NSError {
    let code: Int = ErrorCode.httpErrorCode
    return NSError(domain: "HTTPTask", code: code, userInfo: [NSLocalizedDescriptionKey: text])
}

func makeErrorForInvalidToken(_ text: String="") -> NSError {
    let code: Int = ErrorCode.invalidTokenErrorCode
    return NSError(domain: "HTTPTask", code: code, userInfo: [NSLocalizedDescriptionKey: text])
}

class ErrorHandler: NSObject {
    
    static let sharedInstance = ErrorHandler()
    
    func ProcessError(_ error: NSError) {
        ActivityIndicator.sharedInstance.hide()
        
        //"An error has occurred, please try again.""
        
        switch error.code {
        case ErrorCode.networkErrorCode:
            UIAlertControllerHelper.sharedInstance.showAlert("NETWORK_CONNECTION_NA_MESSAGE".localized, "NETWORK_CONNECTION_NA_HEADER".localized)
        case ErrorCode.defaultErrorCode:
            UIAlertControllerHelper.sharedInstance.showAlert("DEFAULT_ERROR_MESSAGE".localized, "DEFAULT_ERROR_HEADER".localized)
        case ErrorCode.cancelledErrorCode:
            //If we cancel operation . we dont want use to get a alert /
            break
        default :
            UIAlertControllerHelper.sharedInstance.showAlert("DEFAULT_ERROR_MESSAGE".localized, "DEFAULT_ERROR_HEADER".localized)
        }
    }
}
