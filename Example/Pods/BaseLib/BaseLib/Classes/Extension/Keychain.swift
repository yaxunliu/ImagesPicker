//
//  Keychain.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/7/18.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit
import KeychainSwift

enum KeychainsKeys: String {
    case userid = "userid"
    case usernick = "usernick"
    case token = "token"
    case type = "type"
    case phone = "phoneNumer"
    case timeOut = "tokenTimeOut"
    case uuid = "uuid"
}


class Keychain {

    static func save(_ key: KeychainsKeys, value: String) {
        KeychainSwift().set(value, forKey: key.rawValue)
    }
    
    static func get(_ key: KeychainsKeys) -> String? {
        return KeychainSwift().get(key.rawValue)
    }
}
