//
//  RequestManager.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import UIKit
import Alamofire


class RequestManager {
    
    // MARK: - Path
    enum path: String {
        case test = "http://api.football-data.org/v1/competitions/424"
        case createRoom = "/rooms"
        case joinRoom = "/rooms/join"
        case getCard = "/cards"
        case quitGame = "/rooms/close"
        case play = "/rooms/play"
        case leave = "/rooms/leave"
        case getUser = "/rooms/users"
    }
    
    // MARK: - instance
    static var shared = RequestManager()
    
    // MARK: - API
    
    // MARK: - Test
    func apiTest(completeHandle:(()->Void)?) {
        let request = ServerRequest(method: .get, encoding: Alamofire.URLEncoding.default, path: path.test.rawValue, parameters: nil, datas: nil, responseType: ServerResponse.self)
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
        }, animate: false, showErrorMessage: false)
    }
    
    // MARK: - Create Room
    func apiCreateRoom(complete:((_ isSuccess: Bool, _ codeStr: Int)->Void)?) {
        let request = ServerRequest(method: .post, encoding: Alamofire.URLEncoding.default, path: path.createRoom.rawValue, parameters: nil, datas: nil, responseType: ServerResponse.self)
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            if let dataDict = response?.data {
                let roomData = Room(dictionary: dataDict)
                Room.curRoom = roomData
                complete?(isSuccess, roomData.code?.intValue ?? -1)
            } else {
                complete?(false, -1)
            }
            
        }, animate: true, showErrorMessage: true)
    }
    
    // MARK: - Join Room
    func apiJoinRoom(name: String, room: String, complete:((_ isSuccess: Bool)->Void)?) {
        let params: [String : Any] = [
            "name": name,
            "room": room
        ]
        let request = ServerRequest(method: .post, encoding: Alamofire.JSONEncoding.default, path: path.joinRoom.rawValue, parameters: params as [String : AnyObject], datas: nil, responseType: ServerResponse.self)
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            if let data = response?.data {
                User.me = User(dictionary: data)
            }
            complete?(isSuccess)
        }, animate: true, showErrorMessage: true)
    }
    
    // MARK: - Get Cards
    func apiGetCard(complete:((_ isSuccess: Bool, _ cards: [Card])->Void)?) {
        let request = ServerRequest(method: .get, encoding: Alamofire.URLEncoding.default, path: path.getCard.rawValue, parameters: nil, datas: nil, responseType: ServerResponse.self)
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            if let data = response?.responseData.value(forKey: "data") as? [NSDictionary] {
                let cards = [Card].init(dictionaryArray: data)
                complete?(true, cards)
            } else {
                return
            }
        }, animate: true, showErrorMessage: true)
    }
    
    // MARK: - Quit game
    func apiQuitGame(complete:((_ isSuccess: Bool)->Void)?) {
        let params: [String: Any] = [
            "room": Room.curRoom.code?.intValue ?? -1
        ]
        let request = ServerRequest(method: .post, encoding: Alamofire.URLEncoding.default, path: path.quitGame.rawValue, parameters: params as [String : AnyObject], datas: nil, responseType: ServerResponse.self)
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            complete?(isSuccess)
        }, animate: true, showErrorMessage: true)
    }
    
    // MARK: - Quit game
    func apiLeave(complete:((_ isSuccess: Bool)->Void)?) {
        let params: [String : Any] = [
            "name": User.me.name ?? "",
            "room": Room.curRoom.code?.intValue ?? ""
        ]
        let request = ServerRequest(method: .post, encoding: Alamofire.URLEncoding.default, path: path.leave.rawValue, parameters: params as [String : AnyObject], datas: nil, responseType: ServerResponse.self)
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            complete?(isSuccess)
        }, animate: true, showErrorMessage: true)
    }
    
    // MARK: - Play game
    func apiPlayGame(complete:((_ isSuccess: Bool)->Void)?) {
        let cards = Card.cards.filter { (card) -> Bool in
            return card.isSelect
            }.map { (card) -> CardMin in
                let cardMin = CardMin()
                cardMin.id = card._id
                cardMin.total = NSNumber.init(value: card.quantity)
                return cardMin
        }
        let params: [String: Any] = [
            "room": Room.curRoom.code?.intValue ?? -1,
            "cards": cards.toDictionaryArray()
        ]
        let request = ServerRequest(method: .post, encoding: Alamofire.JSONEncoding.default, path: path.play.rawValue, parameters: params as [String : AnyObject], datas: nil, responseType: ServerResponse.self)
        
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            if let dataDict = response?.data {
                let roomData = Room(dictionary: dataDict)
                Room.curRoom = roomData
                complete?(isSuccess)
            } else {
                complete?(isSuccess)
            }
        }, animate: true, showErrorMessage: true)
    }
    
    // Func get User
    func getUser(id: String, complete:((_ isSuccess: Bool, _ users: [User])->Void)?) {
        let params: [String: Any] = [
            "room": id
        ]
        let request = ServerRequest(method: .post, encoding: Alamofire.JSONEncoding.default, path: path.getUser.rawValue, parameters: params as [String : AnyObject], datas: nil, responseType: ServerResponse.self)
        
        ServiceManager.execute(request, completionHandle: { (isSuccess, response) in
            print(response)
            if let dataDict = response?.responseData.value(forKey: "data") as? [NSDictionary] {
                let userData = [User].init(dictionaryArray: dataDict)
                complete?(true, userData)
            } else {
                complete?(false, [])
            }
        }, animate: true, showErrorMessage: true)
    }
}
