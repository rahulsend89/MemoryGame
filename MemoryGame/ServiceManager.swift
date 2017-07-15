//
//  ServiceManager.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation
class ServiceManager: NSObject {
    
    internal typealias HandlerError = (_ error: NSError?) -> Void
    internal typealias HandlerResponse = (_ returnObject: AnyObject?) -> Void
    
    static let sharedInstance = ServiceManager()
    
    func imageWithURL (_ myURL: ServiceConfig.ConfigURL, handlerError: @escaping HandlerError, handlerResponse: @escaping HandlerResponse) -> Void {
        UrlHandler.sharedInstance.getURLResponse(myURL, handlerError: { (error) -> Void in
            DispatchQueue.main.async {
                handlerError(error)
            }
            LogHelper.sharedInstance.log("ServiceManager->photoModelURL() Error: \(String(describing: error))")
        }) { (returnObject) -> Void in
            DispatchQueue.main.async {
                handlerResponse(returnObject)
            }
        }
    }
    
    func photoModelURL (_ myURL: ServiceConfig.ConfigURL, handlerError: @escaping HandlerError, handlerResponse: @escaping HandlerResponse) -> Void {
        UrlHandler.sharedInstance.getURLResponse(myURL, intoClass: PhotoModel.self, handlerError: { (error) -> Void in
            DispatchQueue.main.async {
                handlerError(error)
            }
            LogHelper.sharedInstance.log("ServiceManager->photoModelURL() Error: \(String(describing: error))")
        }) { (returnObject) -> Void in
            DispatchQueue.main.async {
                handlerResponse(returnObject)
            }
        }
    }
}
