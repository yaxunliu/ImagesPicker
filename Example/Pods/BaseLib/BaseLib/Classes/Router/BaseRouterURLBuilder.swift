//
//  BaseRouterURLBuilder.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/8/16.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public enum BaseRouterURLBuilder {
    /// 用户主页
    case userHome(name: String, id: String)
    /// 股票详情页
    case stockDetail(name: String, symbol: String)
    /// 动态详情页面
    case dynamicDetail(dynamicID: String)
    /// 评论动态 (choose_id: 策略选股的id) 只需要传递动态id 和
    case commenDynamic(dynamicID: String, placeholder: String)
    /// 回复评论
    case replyCommen(dynamicID: String?, choose_id: String?, replyUserId: String?, commenID: String?, replyRootID: String?, placeholder: String)
    
}

extension BaseRouterURLBuilder {
    public var routerURL: String {
        switch self {
        case .userHome(let name, let id):
            return "hxg://userProfile?username=\(name)&userid=\(id)"
        case .stockDetail(let name, let symbol):
            return "hxg://stock?stockName=\(name)&symbol=\(symbol)"
        case .dynamicDetail(let dynamicID):
            return "hxg://dynamicDetail?dynamicID=\(dynamicID)"
        case .commenDynamic(let dynamicID, let placeholder):
            return "hxg://commen?commentOrReply=1&dynamicID=\(dynamicID)&placeholder=\(placeholder)"
        case .replyCommen(let dynamicID, let choose_id, let replyUserId, let commenID, let replyRootID, let placeholder):
            var url = "hxg://commen?commentOrReply=0&placeholder=\(placeholder)&"
            if dynamicID != nil {
                url.append("dynamicID=\(dynamicID!)&")
            }
            if choose_id != nil {
                url.append("choose_id=\(choose_id!)&")
            }
            if replyUserId != nil {
                url.append("replyUserId=\(replyUserId!)&")
            }
            if commenID != nil {
                url.append("commenID=\(commenID!)&")
            }
            if replyRootID != nil {
                url.append("replyRootID=\(replyRootID!)")
            }
            return url
        }
    }
}
