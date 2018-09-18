//
//  UIView-Extension.swift
//  Alamofire
//
//  Created by yaxun on 2018/7/27.
//

import UIKit
import Kingfisher

public extension UIImageView {
    func setImage(url: URL, place: UIImage? = nil, completion: CompletionHandler? = nil)  {
        self.kf.setImage(with: url, placeholder: place, options: nil, progressBlock: nil, completionHandler: completion)
    }
}

public extension UIButton {
    func setImage(url: URL, place: UIImage? = nil, state: UIControlState) {
        self.kf.setImage(with: url, for: state, placeholder: place, options: nil, progressBlock: nil, completionHandler: nil)
    }
}



public extension UIViewController {
    public func show (_ title: String?, content: String, cancel: String?) {
        let vc = UIAlertController.init(title: title, message: content, preferredStyle: .alert)
        vc.addAction(UIAlertAction.init(title: cancel, style: .cancel, handler: nil))
        present(vc, animated: true, completion: nil)
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
    
    class func getImage(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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
    
    public static func rateAdaptorWidth(_ standWidth: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.width / 375 * standWidth
    }
    
    public static func rateAdaptorHeight(_ standHeight: CGFloat) -> CGFloat {
        return UIScreen.main.bounds.height / 667 * standHeight
    }
    
    
    public static func adaptor(_ se: CGFloat, _ normal: CGFloat, _ plus: CGFloat, _ x: CGFloat, _ unAdaptor: CGFloat) -> CGFloat {
        switch self.screenEnum {
            case .unAdaptor:
                return unAdaptor
            case .iPhoneSE:
                return se
            case .iPhoneX:
                return x
            case .iPhone6s:
                return normal
            case .iPhone6sPlus:
                return plus
        }
    }
    
    public static var screenEnum: AdaptorScreen {
        get {
            let size = UIScreen.main.bounds.size
            if size.width == 320 && size.height == 568 { // 5s 屏幕
                return .iPhoneSE
            } else if size.width == 375 && size.height == 667 { // 6s 屏幕
                return .iPhone6s
            } else if size.width == 540 && size.height == 960 { // 6s+ 屏幕
                return .iPhone6sPlus
            } else if size.width == 375 && size.height == 812 { // 6s+ 屏幕
                return .iPhoneX
            }
            return .unAdaptor
        }
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
    
    func drawCorner (rect: CGRect?, corners: UIRectCorner, radius: CGFloat) {
        
        guard let bounds = rect else {
            let rounded = UIBezierPath.init(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let shape = CAShapeLayer.init()
            shape.path = rounded.cgPath
            self.layer.mask = shape
            return
        }
        let rounded = UIBezierPath.init(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let shape = CAShapeLayer.init()
        shape.path = rounded.cgPath
        self.layer.mask = shape
    }
}

