//
//  PhotoData.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit

class PhotoModel: ModelClass {
    var page: Int?
    var pages: Int?
    var perpage: Int?
    var total: Int?
    var photo: [FlickrPhotoModel]?
    
    func initWithData(_ dict: NSDictionary) {
        self.page = dict.value(forKey: "page") as? Int
        self.pages = dict.value(forKey: "s") as? Int
        self.perpage = dict.value(forKey: "perpage") as? Int
        self.total = dict.value(forKey: "total") as? Int
        
        if let items = dict.value(forKey: "photo") {
            self.photo = JsonParser().iterateJsonObject(items as AnyObject, intoClass: FlickrPhotoModel.self) as? [FlickrPhotoModel]
        }
    }
    
    convenience required init(dictionary dict: NSDictionary) {
        self.init()
        self.initWithData(dict)
    }
}

class FlickrPhotoModel : ModelClass{
    
    var photoId: String?
    var farm: Int?
    var secret: String?
    var server: String?
    var title: String?
    var size : String = "m";
   
    func initWithData(_ dict: NSDictionary) {
        self.photoId = dict.value(forKey: "id") as? String
        self.farm = dict.value(forKey: "farm") as? Int
        self.secret = dict.value(forKey: "secret") as? String
        self.server = dict.value(forKey: "server") as? String
        self.title = dict.value(forKey: "title") as? String
    }
    
    convenience required init(dictionary dict: NSDictionary) {
        self.init()
        self.initWithData(dict)
    }

    
}
