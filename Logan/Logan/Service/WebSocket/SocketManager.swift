//
//  SocketManager.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import Foundation
import SocketIO
import RxSwift
import EVReflection
import SwiftMessages

class SocketManager {
    
    // MARK: - Key socket
    enum key: String {
        case newUser = "newUser"
        case userChanged = "usersChanged"
        case startGame = "startGame"
        case roomClosed = "roomClosed"
        case joinRoom = "joinRoom"
        case leaveRoom = "leaveRoom"
    }
    
    // MARK: - Instance
    static var shared = SocketManager()
    
    // MARK: - SocketIO
    
    // One Socket client
    var socket: SocketIOClient!
    
    //socket client
    func initSocketClient() -> Bool {
        let param = [:
//            "room": "\(Room.curRoom.code?.intValue ?? -1)"
            ] as [String : String]
        socket = SocketIOClient(socketURL: URL(string: AppDefine.domain.host.rawValue)!, config: [.log(false), .forcePolling(false),.reconnects(true), .reconnectWait(5), .reconnectAttempts(-1), .connectParams(param), .extraHeaders(param)])
        return true
    }
    
    func disconnect() {
        guard socket != nil else {
            return
        }
        socket.disconnect()
    }
    
    func checkInternet() -> Bool {
        return true
    }
    
}

extension SocketManager {
    // MARK: - Connect
    func establishConnection(completeHandle: ((_ isSuccess: Bool)->Void)? = nil) {
        if !self.checkInternet() {
            return
        } else {
            let success = self.initSocketClient()
            if !success {
                return
            }
            socket.connect(timeoutAfter: 30, withHandler: {
                // TODO: - socket fail handle
                completeHandle?(false)
            })
        }
        listenConnection(completeHandle: completeHandle)
        listenError()
        listenDisconnect()
        listenStatusChange()
        listenReconnectAttemp()
        socket.onAny { [weak self] (event) in
            if event.event != "reconnectAttempt" && event.event != "reconnect" && event.event != "error" && event.event != "statusChange" {
                
            }
        }
    }
    
    func listenConnection(completeHandle: ((_ isSuccess: Bool)->Void)?) {
        socket.off("connect")
        socket.on("connect") { [weak self] (data, ack) in
            print("________connected")
            completeHandle?(true)
        }
    }
    
    func listenError() {
        socket.off("error")
        socket.on("error") { (data, ack) in
            print(data)
        }
    }
    
    func listenDisconnect() {
        socket.off("disconnect")
        socket.on("disconnect", callback: { (data, ack) in
            print("________disconnected")
            print(data)
        })
    }
    
    func listenStatusChange() {
        socket.off("statusChange")
        socket.on("statusChange") { (data, ack) in
            print("___________status change")
            if let status = data.first as? SocketIOClientStatus {
                print(status.rawValue)
            }
        }
    }
    
    func listenReconnectAttemp() {
        socket.off("reconnectAttempt")
        socket.on("reconnectAttempt") { (data, ack) in
            print("___________reconnectAttempt")
            print(data)
        }
    }
    
    func listenReConnect() {
        socket.off("reconnect")
        socket.on("reconnect") { (data, ack) in
            print("___________reconnect")
            print(data)
        }
    }
    
    func newUser(complete:((_ newUser: User?)->Void)?) {
        socket.off(key.newUser.rawValue)
        socket.on(key.newUser.rawValue) { (data, ack) in
            print(data)
            if let dataDict = data.first as? NSDictionary {
                let new = User(dictionary: dataDict)
                complete?(new)
            } else {
                complete?(nil)
            }
        }
    }
    
    func userChange(complete:((_ newUser: [User])->Void)?) {
        socket.off(key.userChanged.rawValue)
        socket.on(key.userChanged.rawValue) { (data, ack) in
            print(data)
            if let dataDict = data.first as? [NSDictionary] {
                let new = [User].init(dictionaryArray: dataDict)
                complete?(new)
            } else {
                complete?([])
            }
        }
    }
    
    func startGame(complete:((_ user: [User])->Void)?) {
        socket.off(key.startGame.rawValue)
        socket.on(key.startGame.rawValue) { (data, ack) in
            print(data)
            if let dataDict = data.first as? [NSDictionary] {
                let users = [User].init(dictionaryArray: dataDict)
                complete?(users)
            } else {
                complete?([])
            }
        }
    }
    
    func listenClosedRoom(complete:(()->Void)?) {
        socket.off(key.roomClosed.rawValue)
        socket.on(key.roomClosed.rawValue) { (data, ack) in
            print(data)
            complete?()
        }
    }
    
    func joinRoom(room: Int, complete:((_ room: Int?)->Void)?) {
        socket.off(key.joinRoom.rawValue)
        socket.on(key.joinRoom.rawValue) { (data, ack) in
            complete?(data.first as? Int)
        }
        socket.emit(key.joinRoom.rawValue, room)
    }
    
    func leftRooom() {
        socket.emit(key.leaveRoom.rawValue, "")
    }
    
}











