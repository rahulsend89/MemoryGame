//
//  JsonParsor.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import UIKit


import UIKit

class JsonParser: NSObject {
    func parseJson(_ json: AnyObject!, inToClass parseClass: ModelClass.Type!, keypath: String!) -> AnyObject {
        var paraResponseJson: AnyObject! = json
        if parseClass == nil {
            return json
        }
        if keypath != nil {
            if json.isKind(of: NSDictionary.self) && json[keypath] != nil {
                paraResponseJson = json[keypath]! as AnyObject
            }
        }
        if let paraResponseJsonDic = paraResponseJson as? NSDictionary {
            return parseDictionary(paraResponseJsonDic, intoClass: parseClass)
        } else {
            if let paraResponseJsonArray =  paraResponseJson as? [NSDictionary] {
                let list: NSMutableArray! = NSMutableArray()
                for dict: NSDictionary in paraResponseJsonArray {
                    list.add(self.parseDictionary(dict, intoClass: parseClass))
                }
                return list
            }
        }
        return paraResponseJson
    }
    
    func parseDictionary(_ dictionary: NSDictionary, intoClass classObject: ModelClass.Type) -> AnyObject {
        let returnObject: AnyObject =  classObject.init(dictionary: dictionary)
        return returnObject
    }
    
    func parseResponse(intoClass parseClass: ModelClass.Type, data: Data!, handlerError:(_ error: NSError?) -> Void, handlerResponse:(_ returnObject: AnyObject?) -> Void) {
        let jsonResponse: AnyObject! = self.parseToJSON(data)
        LogHelper.sharedInstance.log("JsonParser->parseResponse() JsonResponse: \(jsonResponse)")
        if (jsonResponse == nil) || jsonResponse.isKind(of: NSError.self) {
            handlerError(makeErrorWithDifferentCode("jsonResponseError"))
            LogHelper.sharedInstance.log("JsonParser->parseResponse() Error: Json Response Error : \(NSString(data: data,encoding: 4)!)")
            return
        }
        
        let returnObj: AnyObject = self.parseJson(jsonResponse, inToClass: parseClass, keypath: "photos")
        handlerResponse(returnObj)
    }
    
    func parseToJSON(_ data: Data) -> AnyObject? {
        var jsonResponse: AnyObject
        do {
            jsonResponse = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
            return jsonResponse
        } catch let jsonError {
            LogHelper.sharedInstance.log("JsonParser->parseToJSON() Error: \(jsonError)")
            return nil
        }
    }
    
    func iterateJsonObject(_ json: AnyObject?, intoClass classObject: ModelClass.Type) -> AnyObject! {
        if json != nil {
            if let jsonArray = json as? [NSDictionary] {
                return self.parserJsonArray(jsonArray, intoClass: classObject) as AnyObject!
            } else {
                if let jsonDic = json as? NSDictionary {
                    let tempDic: NSDictionary = jsonDic
                    return self.parseDictionary(tempDic, intoClass: classObject)
                }
            }
        }
        return nil
    }
    
    func parserJsonArray(_ jsonArray: [NSDictionary], intoClass classObject: ModelClass.Type) -> [AnyObject] {
        var array: [AnyObject] = [AnyObject]()
        for (_, item) in jsonArray.enumerated() {
            if item.isKind(of: NSDictionary.self) {
                let instanceObject: AnyObject = self.parseDictionary(item as NSDictionary, intoClass: classObject)
                array.append(instanceObject)
            }
        }
        return array as [AnyObject]
    }
}
