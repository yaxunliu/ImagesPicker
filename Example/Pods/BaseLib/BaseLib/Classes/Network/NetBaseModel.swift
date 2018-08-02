//
//  NetBaseModel.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/7/30.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import ObjectMapper

open class NetBaseModel<T: Mappable>: Mappable {
    open var code: Int?
    open var data: T?
    open var err_info: String?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        code <- map["code"]
        data <- map["data"]
        err_info <- map["err_info"]
    }
    
}

open class NetArryaModel<T: Mappable>: Mappable {
    open var code: Int?
    open var data: [T]?
    open var err_info: String?
    
    required public init?(map: Map) {
    }
    
    public func mapping(map: Map) {
        code <- map["code"]
        data <- map["data"]
        err_info <- map["err_info"]
    }
    
    

}
