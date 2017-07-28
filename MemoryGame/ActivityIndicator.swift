//
//  ActivityIndicator.swift
//  MemoryGame
//
//  Created by Rahul Malik on 7/15/17.
//  Copyright © 2017 aceenvisage. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.delegate?.window??.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
}

class ActivityViewController: UIViewController {
    internal override var preferredStatusBarStyle: UIStatusBarStyle {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            return rootViewController.preferredStatusBarStyle
        } else {
            return .default
        }
    }

    internal override var prefersStatusBarHidden: Bool {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            return rootViewController.prefersStatusBarHidden
        } else {
            return false
        }
    }

    internal override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let rootViewController = UIApplication.shared.delegate?.window??.rootViewController {
            return rootViewController.preferredStatusBarUpdateAnimation
        } else {
            return .none
        }
    }
}

class ActivityIndicator: NSObject {
    fileprivate var window: UIWindow?
    struct Config {
        let containerTag: Int = 10
        let loadingViewFrame: CGRect = CGRect(x: 0, y: 0, width: 80, height: 80)
        let containerBackGroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
        let loadingViewBackgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
        let actIndFrame: CGRect = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
    }

    var blockUI = true

    fileprivate let config: Config = Config()

    fileprivate var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    func getWindow() -> UIWindow {
        if self.window == nil {
            let _window = UIWindow(frame: UIScreen.main.bounds)
            let _rootViewController = ActivityViewController()
            _window.rootViewController = _rootViewController
            _window.windowLevel = UIWindowLevelAlert
            _window.backgroundColor = UIColor.clear
            _rootViewController.view.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
            _window.isUserInteractionEnabled = true
            window = _window
        }
        return window!
    }

    static let sharedInstance = ActivityIndicator()

    func show() {
        if let topVC = getWindow().rootViewController {
            getWindow().makeKeyAndVisible()
            showActivityIndicatory(topVC.view)
        }
    }

    func hide() {
        if let topVC = getWindow().rootViewController {
            hideActivityIndicator(topVC.view)
            getWindow().isHidden = true
            getWindow().resignKey()
        }
    }
    func showActivityIndicatory(_ uiView: UIView) {
        if let container = uiView.viewWithTag(config.containerTag) {
            container.removeFromSuperview()
        }
        let container: UIView = UIView()
        container.backgroundColor = config.containerBackGroundColor
        if blockUI {
            getWindow().isUserInteractionEnabled = true
        } else {
            getWindow().isUserInteractionEnabled = false
        }
        let loadingView: UIView = UIView()
        container.frame = uiView.frame
        container.center = uiView.center
        loadingView.frame = config.loadingViewFrame
        loadingView.center = uiView.center
        loadingView.backgroundColor = config.loadingViewBackgroundColor
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10

        activityIndicator.frame = config.actIndFrame
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        activityIndicator.center = CGPoint(x: loadingView.frame.size.width / 2,
                                           y: loadingView.frame.size.height / 2)
        loadingView.addSubview(activityIndicator)
        container.addSubview(loadingView)
        container.tag = config.containerTag
        uiView.addSubview(container)
        //UIView.layoutView(uiView, fitView: container, transparent: true)
        activityIndicator.startAnimating()
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
    }

    func hideActivityIndicator(_ uiView: UIView) {
        activityIndicator.stopAnimating()
        if let container = uiView.viewWithTag(config.containerTag) {
            container.removeFromSuperview()
        }
    }
}
