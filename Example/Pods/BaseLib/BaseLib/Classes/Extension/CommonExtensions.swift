//
//  UIViewController-Extension.swift
//  ImagesPicker_Example
//
//  Created by yaxun on 2018/7/12.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

public extension UIViewController {
    public func show (_ title: String?, content: String, cancel: String?) {
        let vc = UIAlertController.init(title: title, message: content, preferredStyle: .alert)
        vc.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
    }
}

public enum AdaptorScreen {
    case iPhoneSE
    case iPhone6s
    case iPhone6sPlus
    case iPhoneX
    case unAdaptor
}

public extension UIScreen {
    
    func adaptor(se: CGFloat, normal: CGFloat, plus: CGFloat, x: CGFloat, unAdaptor: CGFloat) -> CGFloat {
        
        switch screenEnum() {
        case .iPhoneSE:
            return se
        case .iPhone6s:
            return normal
        case .iPhone6sPlus:
            return plus
        case .iPhoneX:
            return x
        case .unAdaptor:
            return unAdaptor
        }
    }
    
    func screenEnum() -> AdaptorScreen {
        if self.bounds.width == 320 && self.bounds.height == 568 { // 5s 屏幕
            return .iPhoneSE
        } else if self.bounds.width == 375 && self.bounds.height == 667 { // 6s 屏幕
            return .iPhone6s
        } else if self.bounds.width == 540 && self.bounds.height == 960 { // 6s+ 屏幕
            return .iPhone6sPlus
        } else if self.bounds.width == 375 && self.bounds.height == 812 { // 6s+ 屏幕
            return .iPhoneX
        }
        return .unAdaptor
    }
    
}



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

public extension UIColor {
    
    /// hex : 00000000
    class func getColor(hex: String) -> UIColor? {
        var red: CGFloat   = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat  = 0.0
        var alpha: CGFloat = 1.0
        
        let scanner = Scanner(string: hex)
        var hexValue: CUnsignedLongLong = 0
        if scanner.scanHexInt64(&hexValue) {
            switch (hex.count) {
            case 3:
                red   = CGFloat((hexValue & 0xF00) >> 8)       / 15.0
                green = CGFloat((hexValue & 0x0F0) >> 4)       / 15.0
                blue  = CGFloat(hexValue & 0x00F)              / 15.0
            case 4:
                red   = CGFloat((hexValue & 0xF000) >> 12)     / 15.0
                green = CGFloat((hexValue & 0x0F00) >> 8)      / 15.0
                blue  = CGFloat((hexValue & 0x00F0) >> 4)      / 15.0
                alpha = CGFloat(hexValue & 0x000F)             / 15.0
            case 6:
                red   = CGFloat((hexValue & 0xFF0000) >> 16)   / 255.0
                green = CGFloat((hexValue & 0x00FF00) >> 8)    / 255.0
                blue  = CGFloat(hexValue & 0x0000FF)           / 255.0
            case 8:
                red   = CGFloat((hexValue & 0xFF000000) >> 24) / 255.0
                green = CGFloat((hexValue & 0x00FF0000) >> 16) / 255.0
                blue  = CGFloat((hexValue & 0x0000FF00) >> 8)  / 255.0
                alpha = CGFloat(hexValue & 0x000000FF)         / 255.0
            default:
                return nil
            }
        } else {
            return nil
        }
        #if os(iOS) || os(tvOS) || os(watchOS)
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        #else
        return NSColor(calibratedRed: red, green: green, blue: blue, alpha: alpha)
        #endif
    }
    
    class func randomColor() -> UIColor {
        let r = CGFloat(arc4random_uniform(255))
        let g = CGFloat(arc4random_uniform(255))
        let b = CGFloat(arc4random_uniform(255))
        return UIColor.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: 1)
    }
}

public extension UIView {
    /*
     * 弹性动画
     */
    func show(bigger: Bool) {
        let animationScale1 = bigger ? 1.15 : 0.5
        let animationScale2 = bigger ? 0.92 : 1.15
        UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
            self.layer.setValue(animationScale1, forKeyPath: "transform.scale")
        }) { _ in
            UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                self.layer.setValue(animationScale2, forKeyPath: "transform.scale")
            }, completion: { _ in
                UIView.animate(withDuration: 0.15, delay: 0, options: [.beginFromCurrentState, .curveEaseInOut], animations: {
                    self.layer.setValue(1.0, forKeyPath: "transform.scale")
                }, completion: nil)
            })
        }
    }

}
