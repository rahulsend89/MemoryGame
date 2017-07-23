//
//  RuntimeHelper.swift
//  HealthConnect
//
//  Created by Rahul Malik on 16/01/16.
//  Copyright © 2016 citiustech. All rights reserved.
//

import Foundation
import ObjectiveC.runtime

typealias closureAny = () -> Any?
typealias closureVoid = () -> Void

protocol TestableClass: class {
    func ifOverride<T: Any>(_ functionName: String, funcCall: () -> T) -> T
}
extension TestableClass {
    func callFunction(_ functionName: String = #function, funcCall: closureVoid)->Any? {
        let returnVal: (Bool, Any?) = MockHelper.functionIsGettingCalled(functionName)
        if !returnVal.0 {
            funcCall()
        }
        return returnVal.1
    }
    func ifOverride<T: Any>(_ functionName: String = #function, funcCall: () -> T) -> T {
        var parentReturnValue: T?
        if let overrideReturnVal = (callFunction(functionName) { _ in
            parentReturnValue = funcCall()
            }) as? T {
                return overrideReturnVal
        }
        return parentReturnValue!
    }
}

open class MockActionable {
    var actions = [closureAny]()
    init(_ funcBlock: @escaping closureAny) {
        addAction(funcBlock)
    }
    func andDo(_ closure: @escaping closureVoid) -> MockActionable {
        addAction({ closure() })
        return self
    }

    func addAction(_ action: @escaping closureAny) {
        actions.append(action)
    }

    func performActions() -> Any? {
        var returnValue: Any?
        for (i, action) in actions.enumerated() {
            if i == 0 {
                returnValue = action()
            } else {
                action()
            }
        }
        return returnValue
    }
}

class MockHelper: NSObject {
    var calledFunction: [String] = [String]()
    var verifyCalledFunction: [String] = [String]()
    var stubFunctions: [(String, MockActionable, Bool)] = [(String, MockActionable, Bool)]()
    static let sharedInstance = MockHelper()

    class func appendMethodByblock(_ aClass: AnyClass, sel: Selector, usingBlock aBlock: @convention(block)() -> Void) {
        let objBlock = unsafeBitCast(aBlock, to: AnyObject.self)
        let myIMP = imp_implementationWithBlock(objBlock)
        let method = class_getInstanceMethod(aClass, sel)
        method_setImplementation(method, myIMP)
    }

    class func appendMethodByblockInClass(_ aClass: AnyClass, newSelectorString: String, usingBlock aBlock: @convention(block)() -> Void) {
        let objBlock = unsafeBitCast(aBlock, to: AnyObject.self)
        let selNew = sel_registerName(newSelectorString)
        let myIMP = imp_implementationWithBlock(objBlock)
        class_addMethod(aClass, selNew, myIMP, "v@:")
    }

    func appendMethodByMoreBlock(_ obj: NSObject, sel: Selector) {
        let aClass: AnyClass = type(of: obj)
        let newSelectorString = "_\(sel)"
        let aBlock: @convention(block)() -> Void = {
            self.calledFunction.append("\(sel)")
            obj.perform(Selector("\(sel)"))
        }

        let objBlock = unsafeBitCast(aBlock, to: AnyObject.self)

        let myIMP = imp_implementationWithBlock(objBlock)
        let selNew = sel_registerName(newSelectorString)
        let method = class_getInstanceMethod(aClass, sel)

        class_addMethod(aClass, selNew, myIMP, method_getTypeEncoding(method))

        let replaceMethod = class_getInstanceMethod(aClass, Selector(newSelectorString))
//        method_setImplementation(replaceMethod, myIMP)
//        method_exchangeImplementations(method, replaceMethod)

        class_replaceMethod(aClass, sel, method_getImplementation(method), method_getTypeEncoding(replaceMethod))
    }
    func appendMethodByMoreBlock(_ obj: NSObject, sel: Selector, appendM: Method) {
        let aClass: AnyClass = type(of: obj)
        //let method = class_getInstanceMethod(aClass, sel)
        let selNew = sel_registerName("calledFunction:")
        class_addMethod(aClass, selNew, method_getImplementation(appendM), method_getTypeEncoding(appendM))
        //let replaceMethod = class_getInstanceMethod(aClass, sel.description)
        //class_replaceMethod(aClass, sel , method_getImplementation(method), method_getTypeEncoding(replaceMethod))
        let originalMethod = class_getInstanceMethod(aClass, sel)
        let swizzledMethod = class_getInstanceMethod(aClass, Selector(("calledFunction:")))

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    class func verify() -> Bool {
        var returnValue = false
        for (_, ele) in MockHelper.sharedInstance.verifyCalledFunction.enumerated() {
            if MockHelper.sharedInstance.verify(ele) {
                returnValue = true
            } else {
                returnValue = false
                return returnValue
            }
        }
        MockHelper.sharedInstance.removeAllCalls()
        return returnValue
    }
    class func functionIsGettingCalled(_ functionName: String) -> (Bool, Any?) {
        let funcName = replaceFunctionName(functionName)
        MockHelper.sharedInstance.calledFunction.append(funcName)
        var returnValue: Any?
        for stubFunction: (String, MockActionable, Bool) in MockHelper.sharedInstance.stubFunctions {
            if stubFunction.0 == funcName {
                returnValue = stubFunction.1.performActions()
                return (stubFunction.2, returnValue)
            }
        }
        return (false, nil)
    }
    class func expectCall(_ functionName: String) {
        MockHelper.sharedInstance.verifyCalledFunction.append(functionName)
    }
    class func stub(_ functionName: String, _ overrideFunction: Bool = false, funcBlock: @escaping closureAny) -> MockActionable {
        let mockActions = MockActionable(funcBlock)
        MockHelper.sharedInstance.stubFunctions += [(functionName, mockActions, overrideFunction)]
        return mockActions
    }
    class func replaceFunctionName(_ functionName: String) -> String {
        var functionReturnName = functionName
        if let funcNameReplace = functionName.getPatternString("\\(.+") {
            functionReturnName = functionName.replacingOccurrences(of: funcNameReplace, with: "")
        }
        return functionReturnName
    }
    class func mockMyObject<O: AnyObject, C: TestableClass>(_ currentObject: O, _ mockType: C.Type) {
        if mockType is O.Type {
            object_setClass(currentObject, mockType)
        }
    }

    func verify(_ str: String) -> Bool {
        let itemExists = calledFunction.contains(str)
        return itemExists
    }
    func removeAllCalls() {
        verifyCalledFunction.removeAll(keepingCapacity: false)
        calledFunction.removeAll(keepingCapacity: false)
        stubFunctions.removeAll(keepingCapacity: false)
    }
}

extension String {
    func getPatternString(_ pattern: String) -> String? {
        if let inputRange = self.range(of: pattern, options: .regularExpression) {
            return self.substring(with: inputRange)
        } else {
            return nil
        }
    }
}

//class func enumerateMethodsInClass(_ aClass: AnyClass, usingBlock aBlock: (_ cls: AnyClass, _ sel: Selector) -> Void) {
//    var mc: CUnsignedInt = 0
//    var mlist: UnsafeMutablePointer<Method> = class_copyMethodList(aClass, &mc)
//    for i: CUnsignedInt in 0 ..< mc {
//        let sel: Selector = method_getName(mlist.pointee)
//        mlist = mlist.successor()
//        aBlock(aClass, sel)
//    }
//}

//@objc class mirrorClassObj: NSObject{
//    var aClass: NSObject!
//    func callFunction(functionName: String = __FUNCTION__,lineNo: Int = __LINE__){
//        print("functionName : \(functionName) : \(lineNo)")
//    }
//    convenience required init(_ aClass_: NSObject.Type){
//        self.init()
//        aClass = aClass_.init()
//        MockHelper.enumerateMethodsInClass(aClass_) { (cls, sel) -> Void in
//            if sel.description != ".cxx_destruct"{
//                MockHelper.sharedInstance.appendMethodByMoreBlock(self.aClass, sel: sel,appendM: class_getClassMethod(mirrorClassObj.self, Selector("callFunction")))
//            }
//        }
//
//    }
//}
