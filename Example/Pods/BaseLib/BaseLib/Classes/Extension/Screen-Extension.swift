//
//  Screen-Extension.swift
//  huiXuanGu
//
//  Created by yaxun on 2018/7/5.
//  Copyright © 2018年 yaxun. All rights reserved.
//

import UIKit

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

