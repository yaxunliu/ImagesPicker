//
//  String-Extension.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/6/29.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit

public extension String {

    var isMobile: Bool {
        get {
            let phoneRegex: String = "^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(17[0,0-9]))\\d{8}$"
            let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
            return phoneTest.evaluate(with: self)
        }
    }
    

    func encryptAuthCode() -> String? {
        let authArr = self.map { character in
            return String(character)
        }
        if authArr.count > 7 { return nil }
        let sercuteCodes = ["!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "_"]
        var str = ""
        for (index, value) in authArr.enumerated() {
            let code = sercuteCodes[index]
            str += (code + value)
        }
        return str
    }

}

public extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
        
        return ceil(boundingBox.width)
    }
}


