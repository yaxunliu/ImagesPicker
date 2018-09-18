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
    /******************
     登录  注册  验证码 相关
     *******************/
    case login(email_mobile: String, psw: String, vCode: String?) // 账号登录
    case getAuthCode(type: AuthCodeType, email_mobile: String, vCode: String) // 获取手机验证码
    case loginByAuthcode(mobile: String, code: String)  // 验证码登录
    case resetPassword(email_mobile: String, psw: String, code: String) // 重置密码
    case regist(email_mobile: String, code: String, psw: String, utype: String?) // 注册账户
    
    
    
    /******************
     动态相关
    *******************/
    /// 点赞
    case nice(dynamic_id: Int, token: String)
    /// 删除动态
    case remove(token: String, dynamic_id: Int)
    /*
     * start 开始位置
     * limit 请求数量
     * time_tran 默认TRUE
     * lastes 获取全部动态数据 (上拉刷新  下拉加载更多)
     */
    case allDynamic(start: Int?, limit: Int?, time_tran: Bool?, lastes: Bool?)
    /// 个人动态
    case profileDynamic(token: String, start: Int?, limit: Int?, time_tran: Bool?, lt_gt: Bool?)
    /// 发表
    case publish(editContent: String, secret: Bool, token: String, client: String, images: [MultipartFormData])
    /// 回复/评论 comment: true 评论 false: 回复
    case commen(feedId: String?, choose_id: String?, content: String, comment: Bool, isCommenFeed: Bool, commenUserId: String, commentId: String, commenRootId: String)
    /// 获取详情评论列表
    case commenList(dynamicId: String, lastDynamicId: String?, commenNum: Int?, replyNum: Int?)
    /// 获取动态的详情
    case dynamicDetail(dynamicId: String, commenNum: Int?, replyNum: Int?)
    /// 获取回复列表
    case dynamicReplyList(dynamicId: String, commentId: String, lastCommenId: String?, replyNum: Int?)
    /// 点赞评论
    case niceCommen(commentID: String)
    /// 分享动态
    case shareDynamic(dynamicID: String)
    /// 转发动态
    case forwardDynamic(dynamicID: String, content: String?)
}


extension BaseNetworkApi: TargetType {
    public var task: Task {
        switch self {
            
        /******************
         登录  注册  验证码 相关
         *******************/
        case .login(let email_mobile, let psw, let vCode):
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
        case .regist(let email_mobile, let code, let psw, let utype):
            var paramdict = ["email_mobile": email_mobile, "psw": psw, "code": code]
            guard let type = utype else { return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)}
            paramdict["utype"] = type
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            
        /******************
         动态相关
         *******************/
        case .allDynamic(let start, let limit, let time_tran, let lastes):
            var lt = "gt"
            if lastes != nil { lt = lastes! ? "gt" : "lt" }
            var st = 0
            if start != nil { st = start! }
            var count = 10
            if limit != nil { count = limit! }
            var trans = true
            if time_tran != nil { trans = time_tran! }
            let paramdict = ["start": st, "limit": count, "time_tran": trans, "lt_gt": lt] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        case .profileDynamic(let token, let start, let limit, let time_tran, let lt_gt):
            var lt = "gt"
            if lt_gt != nil { lt = lt_gt! ? "gt" : "lt" }
            var st = 0
            if start != nil { st = start! }
            var count = 10
            if limit != nil { count = limit! }
            var trans = true
            if time_tran != nil { trans = time_tran! }
            let paramdict = ["start": st, "limit": count, "time_tran": trans, "lt_gt": lt, "token": token] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        case .publish(let editContent, let secret, let token, let client, let images):
            let paramdict = ["myclient": client, "token": token, "feed": editContent, "secret": secret] as [String : Any]
                return .uploadCompositeMultipart(images, urlParameters: paramdict)
        case .nice(let dynamic_id, let token):
            let paramdict = ["token": token, "feed_id": dynamic_id] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        case .remove(let token, let dynamic_id):
            let paramdict = ["token": token, "feed_id": dynamic_id] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            
        case .commen(let feedId, let choose_id, let content, let comment, let commenUserId, let commentId, let isCommenFeed, let commenRootId):
            let paramdict = ["feed_id": feedId ?? "", "choose_id": choose_id ?? "", "content": content, "is_comment": comment, "to_user_id": commenUserId, "comment_id": commentId, "root_id": commenRootId, "is_to_feed": isCommenFeed] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        
        case .commenList(let dynamicId, let lastDynamicId, let commenNum, let replyNum):
            let paramdict = ["feed_id": dynamicId , "max_id": lastDynamicId ?? 0, "comment_size": commenNum ?? 0, "reply_size": replyNum ?? 0] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            
        case .dynamicDetail(let dynamicId, let commenNum, let replyNum):
            let paramdict = ["feed_id": dynamicId , "comment_size": commenNum ?? 0 , "reply_size": replyNum ?? 0] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        case .dynamicReplyList(let dynamicId, let commentId, let lastCommenId, let replyNum):
            let paramdict = ["feed_id": dynamicId , "comment_id": commentId , "max_id": lastCommenId ?? 0, "reply_size": replyNum ?? 0] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        case .niceCommen(let commentID):
            let paramdict = ["comment_id": commentID] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
        case .shareDynamic(let dynamicID):
            let paramdict = ["feed_id": dynamicID] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
            
        case .forwardDynamic(let dynamicID, let content):
            let paramdict = ["feed_id": dynamicID, "content": content ?? ""] as [String : Any]
            return .requestParameters(parameters: paramdict, encoding: URLEncoding.default)
         }
    }
    public var baseURL: URL {
        guard let url = BaseNetworkConfig.config().baseUrl else {
            return URL.init(string: "http://ceshi3.huixuangu.com")!
        }
        return URL.init(string: url)!
    }
    
    public var path: String {
        switch self {
        /******************
         登录  注册  验证码 相关
         *******************/
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
            
        /******************
         动态相关
         *******************/
        case .nice:
            return "/priapi1/like_feed"
        case .niceCommen:
            return "/priapi1/like_comment"
        case .publish:
            return "/priapi1/publish"
        case .shareDynamic:
            return "/priapi1/share_feed"
        case .dynamicDetail:
            return "/pubapi1/get_feed_info"
        case .profileDynamic:
            return "/priapi1/my_feeds"
        case .dynamicReplyList:
            return "/pubapi1/reply_list"
        case .commenList:
            return "/pubapi1/comment_list"
        case .allDynamic:
            return "/pubapi1/get_feeds"
        case .commen:
            return "/priapi1/comment"
        case .remove:
            return "/priapi1/del_feed"
        case .forwardDynamic:
            return "/priapi1/forward_feed"
        

        }
    }
    
    public var method: Moya.Method {
        return .post
    }
    
    public var sampleData: Data {
        return "".data(using: String.Encoding.utf8)!
    }
    
    public var headers: [String : String]? {
        guard let dict = BaseNetworkConfig.config().header else {
            return ["Content-type":"application/x-www-form-urlencoded"]
        }
        return dict.merging(["Content-type":"application/x-www-form-urlencoded"]) { (current, _) in current}
    }
    
}


