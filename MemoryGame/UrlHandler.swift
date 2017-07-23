//
//  UrlHandler.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

import Foundation
import SystemConfiguration
import UIKit
import MobileCoreServices

let REQUESTTIMEOUT: TimeInterval = 30
let successStatusCode: Int = 200

class ModelClass: NSObject {
    convenience required init(dictionary dict: NSDictionary) {
        self.init(dictionary: dict)
    }
}
extension ModelClass {
    override var description: String {
        let mirrored_object = Mirror(reflecting: self)
        let className = NSStringFromClass(type(of: self)).components(separatedBy: ".").last!
        var returnStr = "\(className): -> "
        for (_, attr) in mirrored_object.children.enumerated() {
            if let property_name = attr.label as String! {
                returnStr += "\(property_name) = \(attr.value)\n"
            }
        }
        return returnStr
    }
}
class UrlHandler: NSObject, URLSessionDelegate {

    struct EncodingCharacters {
        static let CRLF = "\r\n"
    }

    internal typealias HandlerError = (_ error: NSError?) -> Void
    internal typealias HandlerResponse = (_ returnObject: AnyObject?) -> Void

    var operation: OperationQueue?
    var appSession: URLSession?

    static let sharedInstance = UrlHandler()

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        completionHandler(Foundation.URLSession.AuthChallengeDisposition.useCredential, URLCredential(trust: challenge.protectionSpace.serverTrust!))
    }

    func queueName() -> String {
        return "manager-queue"
    }
    deinit {
        appSession?.invalidateAndCancel()
    }

    override init() {
        super.init()
        let operationQueue: OperationQueue = OperationQueue()
        operationQueue.maxConcurrentOperationCount = 3
        operationQueue.name = queueName()
        self.operation = operationQueue
        let sessionConfiguration: URLSessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.httpCookieAcceptPolicy = .always
        sessionConfiguration.httpMaximumConnectionsPerHost = 1
        sessionConfiguration.httpCookieStorage = HTTPCookieStorage.shared
        sessionConfiguration.httpShouldSetCookies = true
        sessionConfiguration.requestCachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        let cache = URLCache(memoryCapacity: 500 * 1024 * 1024, diskCapacity: 500 * 1024 * 1024, diskPath: nil)
        sessionConfiguration.urlCache = cache
        //appSession =  Foundation.URLSession(configuration: sessionConfiguration)
        appSession =  URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
        self.setUserAgent()
    }
    func setUserAgent() {
        let webView: UIWebView = UIWebView()
        let appVersionString: NSString? = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? NSString
        var uaString: String = webView.stringByEvaluatingJavaScript(from: "navigator.userAgent")!
        uaString = uaString.appendingFormat("GE_HealthConnect_NATIVE_APPLICATION;TYPE=IOS_IPHONE;VERSION=%@", appVersionString ?? "")
        LogHelper.sharedInstance.log("UrlHandler->setUserAgent() RegisterDefaults:\(uaString)")
        UserDefaults.standard.register(defaults: ["UserAgent": uaString])
    }
    //    func startObserveingOperations() {
    //        self.operation?.addObserver(self, forKeyPath: "operations", options: .New, context: nil)
    //    }
    //    func stopObserveingOperations() {
    //        self.operation?.removeObserver(self, forKeyPath: "operations")
    //    }
    //    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    //        if let _ = object?.valueForKey("operations") {
    //            LogHelper.sharedInstance.log("ObjQue.operationCount : \(self.operation!.operationCount)")
    //        }
    //    }
    var isConnectedToNetwork = { () -> Bool in
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)

        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }

        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }

        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)

        return (isReachable && !needsConnection)
    }

    func getFileResponse(_ myurl: String, intoClass: ModelClass.Type, handlerError: @escaping HandlerError, handlerResponse: @escaping HandlerResponse) {
        let path = Bundle.main.path(forResource: myurl, ofType: "json", inDirectory: nil)
        DispatchQueue.global(qos: .background).async {
            var readError: NSError?
            do {
                guard let path_ = path else {
                    handlerError(NSError(domain: "pathNotFound", code: 0, userInfo: nil))
                    return
                }
                let data = try Data(contentsOf: URL(fileURLWithPath: path_),
                                    options: NSData.ReadingOptions.uncached)
                JsonParser().parseResponse(intoClass: intoClass, data: data, handlerError: { (error) -> Void in
                    handlerError(error)
                }, handlerResponse: { (returnObject) -> Void in
                    handlerResponse(returnObject)
                })
            } catch let error as NSError {
                readError = error
                LogHelper.sharedInstance.log("UrlHandler->getFileResponse() Error: \(String(describing: readError))")
                handlerError(readError)
            }
        }
    }

    func getURLResponse(_ myURL: ServiceConfig.ConfigURL, intoClass: ModelClass.Type?=nil, method: String="GET", handlerError: @escaping HandlerError, handlerResponse: @escaping HandlerResponse) {
        if isConnectedToNetwork() {
            //let priority = DISPATCH_QUEUE_PRIORITY_BACKGROUND
            let mutableRequest: NSMutableURLRequest = self.requestWithBaseMethod(myURL, method: method, parameters: myURL.parameters)
            let cachePolicy = URLRequest.CachePolicy.returnCacheDataElseLoad
            mutableRequest.cachePolicy = cachePolicy
            let request = mutableRequest as URLRequest
            let cachedResponse = URLCache.shared.cachedResponse(for: request)
            if cachedResponse != nil && myURL.image {
                let returndata: Data = cachedResponse!.data as Data
                if let _intoClass = intoClass {
                    JsonParser().parseResponse(intoClass: _intoClass, data: returndata, handlerError: { (error) -> Void in
                        handlerError(error)
                    }, handlerResponse: { (returnObject) -> Void in
                        handlerResponse(returnObject)
                    })
                } else {
                    handlerResponse(returndata as AnyObject)
                }
                return
            } else {
                var currentOperations: ConcurrentOperation?
                currentOperations = ConcurrentOperation(block: { () -> Void in
                    let task = self.appSession?.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
                        currentOperations!.completion()
                        if error == nil {
                            if let response_: HTTPURLResponse = response as? HTTPURLResponse {
                                LogHelper.sharedInstance.log("response_ : \(response_)")
                                if response_.statusCode != 404 {
                                    if data?.count == 0 {
                                        handlerResponse(response_)
                                    } else {
                                        if let _intoClass = intoClass {
                                            JsonParser().parseResponse(intoClass: _intoClass, data: data, handlerError: { (error) -> Void in
                                                handlerError(error)
                                            }, handlerResponse: { (returnObject) -> Void in
                                                handlerResponse(returnObject)
                                            })
                                        } else {
                                            if response_.statusCode != successStatusCode {
                                                handlerResponse(response_)
                                            } else {
                                                handlerResponse(data as AnyObject)
                                            }
                                            return
                                        }
                                    }
                                } else {
                                    LogHelper.sharedInstance.log("UrlHandler->getURLResponse(...) Error: \(String(describing: error))")
                                    handlerError(makeErrorWithDifferentCode("404 serverError"))
                                    return
                                }
                            }
                            return
                        } else {
                            handlerError(error! as NSError)
                            return
                        }
                    })
                    task?.resume()
                    currentOperations?.task = task
                })
                currentOperations?.name = myURL.path
                self.operation?.addOperation(currentOperations!)
            }
        } else {
            handlerError(makeError("notReachable"))
            return
        }

    }

    func requestWithBaseMethod(_ myURL: ServiceConfig.ConfigURL, method: String="GET", parameters: [String : String]?) -> NSMutableURLRequest {
        let _baseURL = URL(string: myURL.baseURL)
        let path: String = myURL.path
        let encodedUrl: String? = path.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let url: URL?
        if(myURL.image) {
           url = URL(string: "\(myURL.baseURL)\(encodedUrl ?? "")")
        } else {
           url = URL(string: encodedUrl!, relativeTo: _baseURL)
        }
        let request: NSMutableURLRequest = NSMutableURLRequest(url:url!, cachePolicy: NSURLRequest.CachePolicy.reloadRevalidatingCacheData,
                                                               timeoutInterval: REQUESTTIMEOUT)
        request.httpMethod = method
        if let _parameters = parameters {
            self.addParameters(_parameters, toRequest: request)
        }
        LogHelper.sharedInstance.log("UrlHandler->requestWithBaseMethod() request: \(request)")
        return request
    }

    fileprivate func query(_ parameters: [String: String]) -> String {
        var components: [(String, String)] = []

        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(key, value as AnyObject)
        }
        return (components.map { "\($0)=\($1)" } as [String]).joined(separator: "&")
    }

    fileprivate func queryComponents(_ key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []

        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)[]", value)
            }
        } else {
            components.append((escapeString(key), escapeString("\(value)")))
        }

        return components
    }

    fileprivate func escapeString(_ string: String) -> String {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/"
        let subDelimitersToEncode = "!$&'()*+,;="
        guard let allowedCharacterSet = (CharacterSet.urlQueryAllowed as NSCharacterSet).mutableCopy() as? NSMutableCharacterSet else {
            return string
        }
        allowedCharacterSet.removeCharacters(in: generalDelimitersToEncode + subDelimitersToEncode)
        let escaped = string.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet) ?? string
        return escaped
    }

    func addParameters(_ parameters: [String: String], toRequest requestReference: NSMutableURLRequest!) {
        let request: NSMutableURLRequest = requestReference
        let stringBody: String? = parameters["string"]
        if stringBody != nil {
            let bodyData: Data = stringBody!.data(using: String.Encoding.utf8)!
            LogHelper.sharedInstance.log("UrlHandler->addParameters() stringBody: \(String(describing: stringBody)), nsdata: \(bodyData)")
            request.httpBody = bodyData
        } else {
            if (["POST", "PUT"].contains(request.httpMethod)) &&  parameters.count>0 {
                if let bodyData: Data = try? JSONSerialization.data(withJSONObject: parameters, options:[] ) {
                    LogHelper.sharedInstance.log("UrlHandler->addParameters() bodyData: \(String(describing: NSString(data: bodyData, encoding: 4))))")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    request.httpBody = bodyData
                }
            } else {
                if ["DELETE", "HEAD", "GET"].contains(request.httpMethod) && parameters.count>0 {
                    let encodedQueryString: String = query(parameters)
                    LogHelper.sharedInstance.log("UrlHandler->addParameters() encodedQueryString: \(encodedQueryString)")
                    guard var newURL = URLComponents(url: request.url!, resolvingAgainstBaseURL: false) else {
                        return
                    }
                    let percentEncodedQuery = (newURL.percentEncodedQuery.map { $0 + "&" } ?? "") + query(parameters)
                    newURL.percentEncodedQuery = percentEncodedQuery
                    request.url = newURL.url
                    LogHelper.sharedInstance.log("UrlHandler->addParameters() newURL: \(request)")
                }
            }
        }
    }
}
