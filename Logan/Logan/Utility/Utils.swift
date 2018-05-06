//
//  Utils.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import SystemConfiguration
import RxSwift
import RxCocoa
import NVActivityIndicatorView

class Utils {
    
    // View Controller
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.topViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let child = base?.childViewControllers.last {
            return topViewController(child)
        }
        if let presented = base?.presentedViewController {
            return topViewController(presented)
        }
        return base
    }
    
    // MARK: - Alert
    
    class func showAlertDefault(_ title: String?, message: String?, buttons: [String], completed:((_ index: Int) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        
        if buttons.count == 1 {
            alert.addAction(UIAlertAction(title: buttons[0], style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
                completed?(0)
            }))
        } else if buttons.count > 1 {
            for (index, title) in buttons.enumerated() {
                alert.addAction(UIAlertAction(title: title, style: .default, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                    completed?(index)
                }))
            }
        }
        Utils.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    class func showAlertText(_ title: String?, message: String?, preText: String?,buttons: [String], completed:((_ index: Int, _ text: String) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        var text: String = preText != nil ? preText! : ""
        if buttons.count == 1 {
            alert.addAction(UIAlertAction(title: buttons[0], style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
                completed?(0, text)
            }))
        } else if buttons.count > 1 {
            for (index, title) in buttons.enumerated() {
                alert.addAction(UIAlertAction(title: title, style: .default, handler: { action in
                    alert.dismiss(animated: true, completion: nil)
                    completed?(index, text)
                }))
            }
        }
        alert.addTextField { (textField) in
            textField.text = text
            _ = textField.rx.text.bind(onNext: { (textTf) in
                text = textTf ?? ""
            })
        }
        Utils.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    class func showActions(with title: String?, buttons: [String], completionHandle: ((_ index: Int) -> Void)?) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        for (index, title) in buttons.enumerated() {
            alert.addAction(UIAlertAction(title: title, style: UIAlertActionStyle.default, handler: { (action) in
                completionHandle?(index)
                print("index: \(index)")
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        Utils.topViewController()?.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Internet
    class func isInternetAvailable() -> Bool{
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
    
    class func startAnimate() {
        let activity = ActivityData.init(size: CGSize.init(width: 60, height: 60), message: "", messageFont: nil, type: nil, color: UIColor.white, padding: nil, displayTimeThreshold: nil, minimumDisplayTime: nil, backgroundColor: UIColor.black.withAlphaComponent(0.3), textColor: UIColor.white)
        NVActivityIndicatorPresenter.sharedInstance.startAnimating(activity)
    }
    
    class func stopAnimate() {
        NVActivityIndicatorPresenter.sharedInstance.stopAnimating()
    }
    
}
