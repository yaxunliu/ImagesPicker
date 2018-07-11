//
//  BaseNetworkApi.swift
//  BaseNetWork_Example
//
//  Created by yaxun on 2018/6/26.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import Moya

public class BaseNetworkConfig {
    private static let _shareConfig = BaseNetworkConfig()
    public var baseUrl: String?
    public var header: [String : String]?
    public class func config() -> BaseNetworkConfig {
        return _shareConfig
    }
}

/// 验证码类型
public enum AuthCodeType : String {
    case login = "login"
    case regist = "regist"
    case forget = "forget"
    case reset = "reset"
}


public enum BaseNetworkApi {
    case login(email_mobile: String, psw: String, vCode: String?) // 账号登录
    case getAuthCode(type: AuthCodeType, email_mobile: String, vCode: String) // 获取手机验证码
    case loginByAuthcode(mobile: String, code: String)  // 验证码登录
    case resetPassword(email_mobile: String, psw: String, code: String) // 重置密码
    case regist(email_mobile: String, code: String, psw: String, utype: String?) // 注册账户
}


extension BaseNetworkApi: TargetType {
    public var task: Task {
        switch self {
            case .login(let email_mobile, let psw, var vCode):
                var paramdict = ["email_mobile": email_mobile, "psw": psw]
                guard let code = vCode else { return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)}
                paramdict["vCode"] = code
                return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            case .getAuthCode(let type, let email_mobile, let vCode):
                let paramdict = ["type": type.rawValue, "email_mobile": email_mobile, "vCode": vCode]
                return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            case .loginByAuthcode(let mobile, let code):
                let paramdict = ["mobile": mobile, "code": code]
                return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            case .resetPassword(let email_mobile, let psw, let code):
                let paramdict = ["email_mobile": email_mobile, "psw": psw, "code": code]
                return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            case .regist(let email_mobile, let code, let psw, var utype):
                var paramdict = ["email_mobile": email_mobile, "psw": psw, "code": code]
                guard let type = utype else { return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)}
                paramdict["utype"] = type
                return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        }
    }
    public var baseURL: URL {
        guard let url = BaseNetworkConfig.config().baseUrl else {
            assert(false, "需要设置baseURL")
            return URL.init(string: "http://ceshi3.huixuangu.com")!
        }
        return URL.init(string: url)!
    }
    
    public var path: String {
        switch self {
            case .login:
                return "/pubapi1/login"
            case .getAuthCode:
                return "/pubapi1/get_mobile_code"
            case .loginByAuthcode:
                return "/pubapi1/login_by_code"
            case .resetPassword:
                return "/pubapi1/reset_forget_password"
            case .regist:
                return "/pubapi1/regist"
        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        return ["Content-type" : "application/x-www-form-urlencoded"]
    }
    
}


