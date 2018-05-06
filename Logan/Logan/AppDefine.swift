//
//  AppDefine.swift
//  Logan
//
//  Created by Anh Son Le on 5/5/18.
//  Copyright © 2018 campathon. All rights reserved.
//

import Foundation

class AppDefine {
    enum domain: String {
        case host = "http://logan.blogk.xyz"
    }
    
    enum segue: String {
        case splashToLogin = "splashToLogin"
        case loginToChooseCard = "loginToChooseCard"
        case chooseCardToDashboard = "chooseCardToDashboard"
        case loginToClient = "loginToClient"
    }
}
