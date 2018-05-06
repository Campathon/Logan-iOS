//
//  AppState.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import Foundation
import UIKit

class AppState {
    enum State {
        case notConnect
        case connected
        case waiting
        case inGame
    }
    
    enum Role {
        case notDetect
        case host
        case client
    }
    
    static var role: Role = .notDetect
    
    static var state: State = .notConnect {
        didSet {
            switch state {
            case .connected:
                Room.curRoom = Room()
                Card.cards = []
                User.me = User()
                break
            case .waiting:
                SocketManager.shared.userChange { (users) in
                    Room.curRoom.users = users
                    if AppState.role == .host {
                        if let topVC = Utils.topViewController() as? ChooseCardViewController {
                            topVC.setDataView()
                            UIView.animate(withDuration: 0.3, animations: {
                                topVC.heightHeaderContraint.constant = 214
                                topVC.view.layoutIfNeeded()
                                }, completion: nil)
                            topVC.clPlayer.reloadData()
                            topVC.clCard.reloadData()
                        }
                        if let topVC = Utils.topViewController() as? DashboardViewController {
                            topVC.setData()
                            topVC.tableView.reloadData()
                        }
                    } else if AppState.role == .client {
                        if let topVC = Utils.topViewController() as? DashboardClientViewController {
                            
//                            if AppState.state == .inGame {
//                                topVC.isStarted = true
//                            }
                            topVC.setupData()
                        }
                    }
                }
                SocketManager.shared.startGame { (users) in
                    Room.curRoom.users = users
                    AppState.state = .inGame
                    if AppState.role == .host {
                        if let topVC = Utils.topViewController() as? ChooseCardViewController {
                            // TO-DO: - Update
                        }
                    } else if AppState.role == .client {
                        if let topVC = Utils.topViewController() as? DashboardClientViewController {
                            // TO-DO: - Update
                            if let me = Room.curRoom.users.filter({ (user) -> Bool in
                                return user._id == User.me._id
                            }).first {
                                User.me = me
                            }
                            topVC.isStarted = true
                            topVC.setupData()
                        }
                    }
                }
                SocketManager.shared.listenClosedRoom {
                    AppState.state = .connected
                    BannerManager.share.showMessage(withContent: "Phòng đã bị đóng", theme: BannerManager.BannerTheme.defaultTheme)
                    Utils.topViewController()?.view.window!.rootViewController?.dismiss(animated: true, completion: nil)
                }
                break
            case .inGame:
                break
            case .notConnect:
                break
            }
        }
    }
    
}
