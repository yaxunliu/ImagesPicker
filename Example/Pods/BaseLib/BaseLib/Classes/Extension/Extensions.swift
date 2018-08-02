//
//  Extensions.swift
//  Alamofire
//
//  Created by yaxun on 2018/7/27.
//

import UIKit

public enum ImgType: String {
    case jpeg = "jpg"
    case gif = "gif"
    case png = "png"
}

public extension Data {
    var imgType: ImgType {
        let byte = [UInt8](self)[0]
        switch byte {
        case 0xFF:
            return .jpeg
        case 0x89:
            return .gif
        case 0x47:
            return .png
        default:
            return .png
        }
    }
}
