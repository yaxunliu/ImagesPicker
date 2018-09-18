//
//  BaseLib-Index.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/8/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import URLNavigator
import SVProgressHUD

public class BaseLibConfig {
    public static func initialize(_ navigator: NavigatorType) {
        // 1. 登录
        navigator.register("hxg://login") {url, values, context in
            guard let handle = context as? (Bool)->() else {
                return LoginViewController.init(nil)
            }
            let loginVc = LoginViewController.init(handle)
            return loginVc
        }
        
        // 2. 注册
        navigator.register("hxg://regist") {url, values, context in
            return RegisterViewController.init(.regist)
        }
        
        // 3. 找回密码
        navigator.register("hxg://findback") {url, values, context in
            return RegisterViewController.init(.reset)
        }
    }
    
    public static func initHudConfig() {
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.setBackgroundColor(UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.5))
    }
}
