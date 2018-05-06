//
//  Room.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import Foundation
import EVReflection

class Room: EVObject {
    
    static var curRoom = Room()
    
    var users: [User] = []
    var _id: String?
    var code: NSNumber?
    var created: String?
    var __v: NSNumber?
    var status: String?
}

class User: EVObject {
    
    static var me = User()
    
    var name: String?
    var _id: String?
    var status: String?
    var card: Card?
}
