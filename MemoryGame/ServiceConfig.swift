//
//  ServiceConfig.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation

class ServiceConfig: NSObject {
    struct ConfigURL {
        let baseURL: String, path: String, parameters: [String:String]?, image: Bool
        init(baseURL: String, path: String, image: Bool = false, parameters: [String:String]?=nil) {
            self.baseURL = baseURL
            self.path = path
            self.image = image
            self.parameters = parameters
        }
    }

    fileprivate enum EndPoint: Int {
        case flickr = 0
    }

    fileprivate struct URLPointer {
        let appEndPointBaseURL: String, imageBaseURL: String
    }

    fileprivate static let getCurrentEndPoint: EndPoint = {
        switch PersistentDataHelper.userDefaults.integer(forKey: PersistentDataHelper.DefaultStoreKey.endPoint) {
        case 0:
            return .flickr
        default:
            return .flickr
        }
    }()

    fileprivate let urlString: URLPointer = {
        switch ServiceConfig.getCurrentEndPoint {
        case .flickr:
            return URLPointer(
                appEndPointBaseURL: "https://api.flickr.com",
                imageBaseURL:"http://farm")
            }
    }()

    static let sharedInstance = ServiceConfig()

    func getImage(farm: Int, server: String, photoId: String, secret: String, size: String="m") -> ConfigURL {
        let imageString = "\(farm ).staticflickr.com/\(server)/\(photoId)_\(secret)_\(size).jpg"
        return ConfigURL(baseURL: urlString.imageBaseURL, path: imageString, image:true)
    }

    func getMyPhotoUrl() -> ConfigURL {
        let returnPath: String = "/services/rest/"
        let parameters = ["method": "flickr.photos.search",
                          "api_key": "253496f1555ec7f187ea1a7bc2daff43",
                          "tags": "game",
                          "page": "1",
                          "format": "json",
                          "nojsoncallback": "1"]
        return ConfigURL(baseURL: urlString.appEndPointBaseURL, path: returnPath, parameters: parameters)
    }
}
