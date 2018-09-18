//
//  UIViewController-Extension.swift
//  BaseLib_Example
//
//  Created by yaxun on 2018/8/14.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit
import SVProgressHUD


public extension UIViewController {
    
    public func showait(message: String?) {
        SVProgressHUD.showInfo(withStatus: message)
    }
    
    public func showSuccess(message: String?) {
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    public func showError(message: String?) {
        SVProgressHUD.showError(withStatus: message)
    }
    
    public func hidden(_ delayTime: TimeInterval = 0) {
        SVProgressHUD.dismiss(withDelay: delayTime)
    }
    

}
