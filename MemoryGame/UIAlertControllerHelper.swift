//
//  UIAlertControllerHelper.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation
import UIKit

class UIAlertControllerHelper {

    static let sharedInstance = UIAlertControllerHelper()
    var isMocking = false

    func showConfirmAlert(_ messagText: String, _ messageHeader: String?=nil, defaultButton: Bool, completion: @escaping (Bool) -> Void) {
        if !isMocking {
            let alertController = UIAlertController(title: messageHeader, message: messagText, preferredStyle: .alert)
            if defaultButton {
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {(_: UIAlertAction!) in completion(true)})
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {(_: UIAlertAction!) in completion(false)})
                alertController.addAction(defaultAction)
                alertController.addAction(cancelAction)
            } else {
                let defaultAction = UIAlertAction(title: "Yes", style: .default, handler: {(_: UIAlertAction!) in completion(true)})
                let noAction = UIAlertAction(title: "No", style: .default, handler: {(_: UIAlertAction!) in completion(false)})
                alertController.addAction(noAction)
                alertController.addAction(defaultAction)
            }

            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            if let topVC = UIApplication.topViewController() {
                topVC.present(alertController, animated: true, completion: nil)
            }
        }
    }

    func showDismissAlert(_ messagText: String, _ messageHeader: String?=nil, completion: @escaping (Bool) -> Void) {
        if !isMocking {
            let alertController = UIAlertController(title: messageHeader, message: messagText, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "Dismiss", style: .default, handler: {(_: UIAlertAction!) in completion(true)})
            alertController.addAction(defaultAction)

            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            if let topVC = UIApplication.topViewController() {
//                if topVC.isKind(of: AddToCasePopUp.self) {
//                    topVC.presentingViewController?.present(alertController, animated: true, completion: nil)
//                } else {
                    topVC.present(alertController, animated: true, completion: nil)
//                }
            }
        }
    }

       func showAlert(_ messagText: String, _ messageHeader: String?=nil) {
        if !isMocking {
            let alertController = UIAlertController(title: messageHeader, message: messagText, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(defaultAction)
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            if let topVC = UIApplication.topViewController() {
//                if topVC.isKind(of: AddToCasePopUp.self) {
//                    topVC.presentingViewController?.present(alertController, animated: true, completion: nil)
//                } else {
                    topVC.present(alertController, animated: true, completion: nil)
//                }
            }
        }
    }

    func showMultipleSelection(_ withStrings: String..., completion: @escaping (Int) -> Void) {
        if !isMocking {
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            for (index, messagText) in withStrings.enumerated() {
                let defaultAction =  UIAlertAction(title: messagText, style: UIAlertActionStyle.default, handler: {(_: UIAlertAction!) in completion(index)})
                alertController.addAction(defaultAction)
            }
            let cancelAction =  UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            alertController.addAction(cancelAction)
            alertController.view.tintColor = UIColor.black
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
            if let topVC = UIApplication.topViewController() {
                topVC.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
