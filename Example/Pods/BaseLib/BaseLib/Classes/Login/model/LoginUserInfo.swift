//
//  LoginResult.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/7/2.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit
import ObjectMapper
import KeychainSwift

public struct LoginUserInfo: Mappable {
    var id:    String?     // 用户的id
    var nick:  String?
    var token: String?
    var utype: String?    // 0 普通用户 1专家
    
    static public var _userinfo = LoginUserInfo() {
        didSet {
            if _userinfo.nick != nil && _userinfo.id != nil && _userinfo.token != nil && _userinfo.utype != nil {
                // 1.存储到keychain中
                Keychain.save(.userid, value: _userinfo.id!)
                Keychain.save(.usernick, value: _userinfo.nick!)
                Keychain.save(.token, value: _userinfo.token!)
                Keychain.save(.type, value: _userinfo.utype!)
                Keychain.save(.timeOut, value: "\(Int32(Date().timeIntervalSince1970) + 60 * 60 * 24 * 7)")
            }
        }
    }
    static public var share: LoginUserInfo {
        if _userinfo.nick == nil && _userinfo.id == nil && _userinfo.token == nil && _userinfo.utype == nil {
            _userinfo.id = KeychainSwift().get("user_id")
            _userinfo.nick = KeychainSwift().get("nick")
            _userinfo.utype = KeychainSwift().get("utype")
            _userinfo.token = KeychainSwift().get("token")
        }
        return _userinfo
    }
    
    private init() {}
    
    public init?(map: Map) {
    }
    mutating public func mapping(map: Map) {
        token <- map["token"]
        utype <- map["utype"]
        nick  <- map["nick"]
        id    <- map["id"]
        LoginUserInfo._userinfo.id = id
        LoginUserInfo._userinfo.nick = nick
        LoginUserInfo._userinfo.utype = utype
        LoginUserInfo._userinfo.token = token
    }
}

