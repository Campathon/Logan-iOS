//
//  BannerManager.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import SwiftMessages

/*
 Use class to manager banner.
 Use with SwiftMessages 3.1.3
 **/
class BannerManager {
    
    var defaultColor = UIColor.init(red: 245/255, green: 166/255, blue: 35/255, alpha: 1)
    var errorColor = UIColor.init(red: 255/255, green: 0, blue: 0, alpha: 1)
    var successColor = UIColor.init(red: 126/255, green: 211/255, blue: 33/255, alpha: 1)
    var warningColor = UIColor.init(red: 248/255, green: 231/255, blue: 28/255, alpha: 1)
    
    enum BannerTheme {
        case defaultTheme
        case error
        case success
        case warning
        case custom(String, String)
    }
    
    let idMessage = "idMessage"
    let idStatusLine = "idStatusLine"
    let idWaiting = "idWaiting"
    
    static let share = BannerManager()
    
    var themeMessage: BannerTheme = .defaultTheme {
        didSet {
            switch themeMessage {
            case .defaultTheme:
                viewMessage.configureTheme(backgroundColor: UIColor.orange, foregroundColor: UIColor.white)
                break
            case .error:
                viewMessage.configureTheme(Theme.error, iconStyle: IconStyle.none)
                break
            case .success:
                viewMessage.configureTheme(Theme.success, iconStyle: IconStyle.none)
                break
            case .warning:
                viewMessage.configureTheme(Theme.warning, iconStyle: IconStyle.none)
                break
            case .custom(let hexBackgrondColor, let hexMessageColor):
                viewMessage.configureTheme(backgroundColor: UIColor.initFromHex(hexString: hexBackgrondColor), foregroundColor: UIColor.initFromHex(hexString: hexMessageColor))
                break
            }
        }
    }
    
    var themeStatusBanner: BannerTheme = .defaultTheme {
        didSet {
            switch themeStatusBanner {
            case .defaultTheme:
                viewStatusBaner.configureTheme(backgroundColor: UIColor.orange, foregroundColor: UIColor.white)
                break
            case .error:
                viewStatusBaner.configureTheme(Theme.error)
                break
            case .success:
                viewStatusBaner.configureTheme(Theme.success)
                break
            case .warning:
                viewStatusBaner.configureTheme(Theme.warning)
                break
            case .custom(let hexBackgrondColor, let hexMessageColor):
                viewStatusBaner.configureTheme(backgroundColor: UIColor.initFromHex(hexString: hexBackgrondColor), foregroundColor: UIColor.initFromHex(hexString: hexMessageColor))
                break
            }
        }
    }
    
    // MARK: - SwiftMessages
    var viewMessage = MessageView.viewFromNib(layout: MessageView.Layout.messageViewIOS8)
    var viewStatusBaner = MessageView.viewFromNib(layout: MessageView.Layout.statusLine)
    var viewWaiting = MessageView.viewFromNib(layout: MessageView.Layout.statusLine)
    var configMessage = SwiftMessages.Config()
    var configStatusLine = SwiftMessages.Config()
    var configWaiting = SwiftMessages.Config()
    
    // MARK: - Method
    private func configMesage() {
        SwiftMessages.pauseBetweenMessages = 0.1
        if #available(iOS 10.0, *) {
            viewMessage = MessageView.viewFromNib(layout: MessageView.Layout.messageView)
        } else {
            viewMessage = MessageView.viewFromNib(layout: MessageView.Layout.messageViewIOS8)
        }
        viewMessage.id = idMessage
        viewMessage.button?.isHidden = true
        viewMessage.iconImageView?.isHidden = true
        viewMessage.titleLabel?.isHidden = true
        viewMessage.bodyLabel?.textAlignment = .left
        viewMessage.bodyLabel?.font = UIFont.systemFont(ofSize: 14)
        viewMessage.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        configMessage.dimMode = .none
        configMessage.ignoreDuplicates = false
        configMessage.interactiveHide = true
        configMessage.shouldAutorotate = false
    }
    
    private func configStatusBanner() {
        SwiftMessages.pauseBetweenMessages = 0.1
        viewStatusBaner.id = idStatusLine
        viewStatusBaner.button?.isHidden = true
        viewStatusBaner.iconImageView?.isHidden = true
        viewStatusBaner.titleLabel?.isHidden = true
        viewStatusBaner.bodyLabel?.textAlignment = .center
        viewStatusBaner.bodyLabel?.font = UIFont.systemFont(ofSize: 14)
        viewStatusBaner.alpha = 1
        configStatusLine.eventListeners.removeAll()
        configStatusLine.dimMode = .none
        configStatusLine.ignoreDuplicates = false
        configStatusLine.interactiveHide = true
        configStatusLine.shouldAutorotate = false
    }
    
    private func configWaitingView(_ isStatus: Bool, inViewController: UIViewController?) {
        SwiftMessages.pauseBetweenMessages = 0.1
        viewWaiting.id = idWaiting
        viewWaiting.button?.isHidden = true
        viewWaiting.iconImageView?.isHidden = true
        viewWaiting.titleLabel?.isHidden = true
        viewWaiting.bodyLabel?.textAlignment = .center
        viewWaiting.bodyLabel?.font = UIFont.systemFont(ofSize: 14)
        viewWaiting.alpha = 1
        configWaiting.eventListeners.removeAll()
        configWaiting.dimMode = .none
        configWaiting.ignoreDuplicates = false
        configWaiting.interactiveHide = false
        configWaiting.shouldAutorotate = false
        if isStatus {
            configWaiting.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        } else {
            //            if let topVC = inViewController {
            //                configWaiting.presentationContext = .viewController(topVC)
            //            } else {
            //                configWaiting.presentationContext = .automatic
            //            }
            configWaiting.presentationContext = .automatic
        }
        
        configWaiting.presentationStyle = .top
    }
    
    func showMessage(withContent content: String, theme: BannerTheme) {
        SwiftMessages.hide()
        configMesage()
        viewMessage.configureContent(body: content)
        viewMessage.titleLabel?.isHidden = true
        viewMessage.button?.isHidden = true
        viewMessage.iconLabel?.isHidden = true
        viewMessage.iconImageView?.isHidden = true
        
        self.themeMessage = theme
        //        configMessage.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        configMessage.presentationContext = .automatic
        configMessage.presentationStyle = .top
        configMessage.duration = .seconds(seconds: 4)
        configMessage.interactiveHide = true
        viewMessage.iconImageView?.isHidden = true
        SwiftMessages.show(config: configMessage, view: viewMessage)
    }
    
    func showStickMessage(withContent content: String, title: String = "", theme: BannerTheme, closeHandle: (()->Void)? = nil) {
        SwiftMessages.hide()
        configMesage()
        //        if #available(iOS 9, *) {
        //            viewMessage.configureIcon(withSize: CGSize.init(width: 25, height: 25))
        //        } else {
        //            // Fallback on earlier versions
        //        }
        viewMessage.titleLabel?.isHidden = false
        viewMessage.button?.isHidden = false
        viewMessage.iconLabel?.isHidden = true
        viewMessage.configureContent(title: title, body: content)
        viewMessage.iconImageView?.isHidden = true
        viewMessage.button?.setTitle("Thử lại", for: .normal)
        //        viewMessage.button?.setImage(#imageLiteral(resourceName: "ic_cancel"), for: .normal)
        viewMessage.buttonTapHandler = { btn in
            SwiftMessages.hide()
            closeHandle?()
        }
        //        if #available(iOS 9, *) {
        //            viewMessage.configureIcon(withSize: CGSize.init(width: 20, height: 20), contentMode: UIViewContentMode.scaleAspectFit)
        //        } else {
        //            // Fallback on earlier versions
        //        }
        self.themeMessage = theme
        configMessage.presentationContext = .window(windowLevel: UIWindowLevelNormal)
        configMessage.presentationStyle = .top
        configMessage.duration = .forever
        configMessage.interactiveHide = true
        SwiftMessages.show(config: configMessage, view: viewMessage)
    }
    
    func showMessageUnderNavi(withContent content: String, theme: BannerTheme) {
        SwiftMessages.hide()
        configMesage()
        viewMessage.configureContent(body: content)
        self.themeMessage = theme
        if let topVC = Utils.topViewController() {
            configWaiting.presentationContext = .viewController(topVC)
        } else {
            configWaiting.presentationContext = .automatic
        }
        configMessage.presentationStyle = .top
        
        SwiftMessages.show(config: configMessage, view: viewMessage)
    }
    
    func showStatusMessage(withContent content: String, theme: BannerTheme, inViewController: UIViewController?) {
        SwiftMessages.hide()
        configStatusBanner()
        configStatusLine.duration = .seconds(seconds: 2)
        self.themeStatusBanner = theme
        viewStatusBaner.configureContent(body: content)
        configStatusLine.presentationStyle = .top
        configStatusLine.presentationContext = .window(windowLevel: UIWindowLevelStatusBar)
        
        SwiftMessages.show(config: configStatusLine, view: viewStatusBaner)
    }
    
    func showWaiting(withContent content: String, isStatusLevel: Bool, inViewController: UIViewController?) {
        SwiftMessages.hide()
        configWaitingView(isStatusLevel, inViewController: inViewController)
        viewWaiting.configureContent(body: content)
        configWaiting.duration = .forever
        //        configWaiting.eventListeners.append({ [weak self] event in
        //            if case .didShow = event {
        //                UIView.animate(withDuration: 0.5, delay: 0, options: [UIViewAnimationOptions.autoreverse, UIViewAnimationOptions.repeat], animations: { [weak self] in
        //                    self?.viewWaiting.alpha = 0.88
        //                }, completion: nil)
        //            }
        //        })
        viewWaiting.configureTheme(backgroundColor: UIColor.orange, foregroundColor: UIColor.white)
        SwiftMessages.show(config: configWaiting, view: viewWaiting)
    }
    
    func hideWaiting() {
        SwiftMessages.hide(id: idWaiting)
        configWaiting.eventListeners.removeAll()
    }
    
    func showInAppNoti(title: String, body: String, tapHandle:(()->Void)?) {
        //        SwiftMessages.hideAll()
        var notiView = MessageView.viewFromNib(layout: MessageView.Layout.messageViewIOS8)
        if #available(iOS 9.0, *) {
            notiView = MessageView.viewFromNib(layout: MessageView.Layout.cardView)
        } else {
            notiView = MessageView.viewFromNib(layout: MessageView.Layout.messageViewIOS8)
        }
        notiView.configureTheme(Theme.info)
        notiView.configureDropShadow()
        notiView.configureContent(title: title, body: body)
        notiView.button?.isHidden = true
        var config = SwiftMessages.Config()
        config.dimMode = .none
        SwiftMessages.pauseBetweenMessages = 0.2
        config.ignoreDuplicates = true
        config.interactiveHide = true
        config.presentationContext = .automatic
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 4)
        notiView.tapHandler = { (view: BaseView) in
            tapHandle?()
            SwiftMessages.hide()
        }
//        SoundManager.share.playNotiSoind()
        SwiftMessages.show(config: config, view: notiView)
    }
    
    func showInAppNotification(title: String, body: String, tapHandle:(()->Void)?) {
        //        SwiftMessages.hideAll()
        var notiView = MessageView.viewFromNib(layout: MessageView.Layout.messageViewIOS8)
        if #available(iOS 9.0, *) {
            notiView = MessageView.viewFromNib(layout: MessageView.Layout.cardView)
        } else {
            notiView = MessageView.viewFromNib(layout: MessageView.Layout.messageViewIOS8)
        }
        notiView.configureTheme(backgroundColor: UIColor.white, foregroundColor: UIColor.darkText, iconImage: nil, iconText: nil)
        notiView.titleLabel?.textColor = UIColor.orange
        notiView.configureDropShadow()
        notiView.configureContent(title: title, body: body)
        notiView.button?.isHidden = true
        notiView.iconImageView?.isHidden = true
        var config = SwiftMessages.Config()
        config.dimMode = .none
        SwiftMessages.pauseBetweenMessages = 0.2
        config.ignoreDuplicates = true
        config.interactiveHide = true
        config.presentationContext = .automatic
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 6)
        notiView.tapHandler = { (view: BaseView) in
            tapHandle?()
            SwiftMessages.hide()
        }
//        SoundManager.share.playNotiSoind()
        SwiftMessages.show(config: config, view: notiView)
    }
    
}
/// Colors was used in Banner
extension UIColor {
    internal struct bannerColor {
        static var defaultColor = UIColor.init(red: 245, green: 166, blue: 35, alpha: 1)
        static var error = UIColor.init(red: 255, green: 0, blue: 0, alpha: 1)
        static var success = UIColor.init(red: 126, green: 211, blue: 33, alpha: 1)
        static var warning = UIColor.init(red: 248, green: 231, blue: 28, alpha: 1)
    }
    
    static func initFromHex(hexString: String, alpha:CGFloat? = 1.0) -> UIColor {
        func intFromHexString(hexStr: String) -> UInt32 {
            var hexInt: UInt32 = 0
            // Create scanner
            let scanner: Scanner = Scanner(string: hexStr)
            // Tell scanner to skip the # character
            scanner.charactersToBeSkipped = NSCharacterSet(charactersIn: "#") as CharacterSet
            // Scan hex value
            scanner.scanHexInt32(&hexInt)
            return hexInt
        }
        // Convert hex string to an integer
        let hexint = Int(intFromHexString(hexStr: hexString))
        let red = CGFloat((hexint & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexint & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexint & 0xff) >> 0) / 255.0
        let alpha = alpha!
        // Create color object, specifying alpha as well
        let color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
}

