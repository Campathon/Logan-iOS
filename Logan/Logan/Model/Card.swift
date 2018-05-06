//
//  Card.swift
//  Logan
//
//  Created by Anh Son Le on 5/6/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import Foundation
import EVReflection

class Card: EVObject {
    
    static var cards: [Card] = []
    
    var created: String?
    var _id: String?
    var name: String?
    var image: String?
    var alias: String?
//    var description: String?
    
    var isSelect: Bool = false
    var quantity: Int = 0
    
}

class CardMin: EVObject {
    var id: String?
    var total: NSNumber?
}
